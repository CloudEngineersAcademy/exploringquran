# 🚀 DigitalOcean Deployment Guide - Quran Explorer

Deploy your Quran Explorer site to a DigitalOcean $5/month Droplet with Docker, automatic GitHub deployments, and SSL.

## 📋 Prerequisites

- DigitalOcean account ($5/month credit available for new users)
- GitHub repository with this code
- Custom domain (optional, but recommended for SSL)
- SSH key pair for droplet access

---

## 🔧 Step 1: Create & Configure the Droplet

### 1.1 Create a New Droplet

1. Go to [DigitalOcean Console](https://cloud.digitalocean.com)
2. Click **Create** → **Droplets**
3. **Choose an Image**: Select **Ubuntu 24.04 x64** (LTS)
4. **Choose a Plan**: Select **Basic** → **$5/month** (1GB RAM, 25GB SSD)
5. **Choose Datacenter Region**: Pick closest to your users
6. **Authentication**: 
   - ✅ Add SSH key (recommended)
   - Or use root password (less secure)
7. **Hostname**: `quran-explorer` or your preference
8. Click **Create Droplet**

> **Note**: The $5 droplet has:
> - 1GB RAM
> - 25GB SSD storage (enough for OS + Docker + audio files ~776MB)
> - 1TB/month bandwidth (plenty for your traffic)

### 1.2 Note Your Droplet IP

After creation, note the **IPv4 address** (e.g., `123.45.67.89`)

---

## 📡 Step 2: Initial Server Setup

### 2.1 SSH into Your Droplet

```bash
ssh root@YOUR_DROPLET_IP
# Or if using SSH key:
ssh -i ~/.ssh/your_key root@YOUR_DROPLET_IP
```

### 2.2 Run Initial Setup Script

Copy and paste this entire script into your terminal:

```bash
#!/bin/bash
set -e

echo "🔧 Updating system..."
apt-get update
apt-get upgrade -y

echo "📦 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

echo "📦 Installing Docker Compose..."
apt-get install -y docker-compose-plugin

echo "👤 Adding docker to sudoers..."
usermod -aG docker root

echo "🔐 Installing Certbot for SSL..."
apt-get install -y certbot python3-certbot-nginx

echo "✅ Setup complete!"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
```

### 2.3 Verify Installation

```bash
docker --version
docker compose version
```

---

## 🌐 Step 3: Setup Your Domain (Optional but Recommended)

### 3.1 Point Domain to Droplet

If you have a domain, point it to your droplet IP:

1. Login to your domain registrar (GoDaddy, Namecheap, etc.)
2. Go to DNS settings
3. Add/Update **A record**:
   - **Name**: `@` (for `yourdomain.com`) or `www` (for `www.yourdomain.com`)
   - **Type**: `A`
   - **Value**: Your droplet IP address
4. Wait 5-15 minutes for DNS to propagate

### 3.2 Test DNS Resolution

```bash
nslookup yourdomain.com
# Should show your droplet IP
```

---

## 🐳 Step 4: Deploy with Docker

### 4.1 Clone Your Repository

```bash
cd /root
git clone https://github.com/YOUR_USERNAME/exploringquran.git
cd exploringquran
```

### 4.2 Build and Start Docker Container

```bash
# Build the Docker image
docker build -t quran-explorer:latest .

# Start with Docker Compose
docker compose up -d

# Check if it's running
docker compose ps
docker compose logs -f quran-explorer
```

### 4.3 Test Locally

```bash
# Test the server (inside droplet)
curl http://localhost:3000
```

You should see the HTML response. Press `Ctrl+C` to stop logs.

---

## 🔒 Step 5: Setup SSL with Let's Encrypt

### 5.1 Stop Docker Temporarily (for Certbot)

```bash
docker compose down
```

### 5.2 Get SSL Certificate

```bash
certbot certonly --standalone \
  --email you@example.com \
  --agree-tos \
  --non-interactive \
  -d yourdomain.com \
  -d www.yourdomain.com
```

### 5.3 Create Nginx Configuration

Create `/root/nginx.conf`:

```nginx
upstream quran-explorer {
    server quran-explorer:3000;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # SSL best practices
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Gzip compression
    gzip on;
    gzip_types text/html text/css application/json application/javascript;
    gzip_min_length 1000;

    location / {
        proxy_pass http://quran-explorer;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### 5.4 Update docker-compose.yml

Update to include Nginx:

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - quran-explorer
    restart: unless-stopped

  quran-explorer:
    build: .
    container_name: quran-explorer
    expose:
      - "3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000')"]
      interval: 30s
      timeout: 3s
      retries: 3
```

### 5.5 Start with Nginx

```bash
docker compose up -d
docker compose logs -f
```

### 5.6 Auto-Renew SSL Certificate

Create `/root/renew-cert.sh`:

```bash
#!/bin/bash
certbot renew --quiet --pre-hook "docker compose down" --post-hook "docker compose up -d"
```

Add to crontab:

```bash
crontab -e
# Add this line:
0 3 * * * /root/renew-cert.sh
```

---

## 🚀 Step 6: Automatic Deployment from GitHub

### 6.1 Create a Deploy Key

On your droplet:

```bash
ssh-keygen -t ed25519 -f /root/.ssh/deploy_key -N ""
cat /root/.ssh/deploy_key.pub
```

Copy the public key output.

### 6.2 Add Deploy Key to GitHub

1. Go to your repository → **Settings** → **Deploy Keys**
2. Click **Add deploy key**
3. Paste the public key from above
4. ✅ Check "Allow write access"
5. Click **Add key**

### 6.3 Create Deployment Script

Create `/root/deploy.sh`:

```bash
#!/bin/bash
set -e

REPO_DIR="/root/exploringquran"
LOG_FILE="/var/log/quran-deploy.log"

echo "[$(date)] Starting deployment..." >> $LOG_FILE

cd $REPO_DIR

# Pull latest changes
echo "[$(date)] Pulling from GitHub..." >> $LOG_FILE
git pull origin main >> $LOG_FILE 2>&1

# Rebuild and restart containers
echo "[$(date)] Rebuilding Docker image..." >> $LOG_FILE
docker compose down >> $LOG_FILE 2>&1
docker build -t quran-explorer:latest . >> $LOG_FILE 2>&1
docker compose up -d >> $LOG_FILE 2>&1

# Verify health
sleep 5
if docker compose ps | grep -q "healthy"; then
    echo "[$(date)] ✅ Deployment successful!" >> $LOG_FILE
else
    echo "[$(date)] ❌ Deployment failed - container not healthy" >> $LOG_FILE
    exit 1
fi
```

Make it executable:

```bash
chmod +x /root/deploy.sh
```

### 6.4 Create GitHub Webhook

1. Go to repository → **Settings** → **Webhooks**
2. Click **Add webhook**
3. **Payload URL**: `http://YOUR_DROPLET_IP:3001/deploy`
4. **Content type**: `application/json`
5. **Which events?**: `Just the push event`
6. Click **Add webhook**

### 6.5 Create Webhook Receiver

Create `/root/webhook-receiver.js`:

```javascript
const http = require('http');
const crypto = require('crypto');
const { exec } = require('child_process');

const SECRET = 'your-webhook-secret'; // Change this
const PORT = 3001;

const server = http.createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/deploy') {
    res.writeHead(404);
    res.end('Not Found');
    return;
  }

  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', () => {
    // Verify signature (optional but recommended)
    const signature = req.headers['x-hub-signature-256'];
    const hash = 'sha256=' + crypto
      .createHmac('sha256', SECRET)
      .update(body)
      .digest('hex');

    if (signature && signature !== hash) {
      res.writeHead(401);
      res.end('Unauthorized');
      return;
    }

    console.log('Webhook received, starting deployment...');
    exec('/root/deploy.sh', (error, stdout, stderr) => {
      if (error) {
        console.error('Deployment error:', error);
        res.writeHead(500);
        res.end('Deployment failed');
        return;
      }
      console.log('Deployment successful');
      res.writeHead(200);
      res.end('OK');
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Webhook receiver listening on port ${PORT}`);
});
```

### 6.6 Setup Webhook Receiver as Service

Create `/etc/systemd/system/quran-webhook.service`:

```ini
[Unit]
Description=Quran Explorer Webhook Receiver
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/bin/node /root/webhook-receiver.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
systemctl daemon-reload
systemctl enable quran-webhook
systemctl start quran-webhook
systemctl status quran-webhook
```

---

## 📊 Step 7: Monitoring & Maintenance

### 7.1 Check Logs

```bash
# Docker logs
docker compose logs -f quran-explorer

# Deployment logs
tail -f /var/log/quran-deploy.log

# Webhook logs
journalctl -u quran-webhook -f
```

### 7.2 Monitor Disk Space

The audio files are ~776MB. Check available space:

```bash
df -h
```

If you're running low on space (< 5GB free), consider:
- Hosting audio on DigitalOcean Spaces (S3-compatible) - $5/month for 250GB
- Using a CDN like Cloudflare

### 7.3 Backup Your Audio Files

```bash
# Create a tar backup
tar -czf /root/audio-backup.tar.gz /root/exploringquran/audio/

# Optional: Upload to DigitalOcean Spaces
# Would require rclone setup
```

### 7.4 Monitor CPU & Memory

```bash
docker stats
```

For a $5 droplet with 1GB RAM, you should have plenty of headroom for static content + audio.

---

## 🎯 Step 8: Go Live

### 8.1 Point Domain to Droplet

If not done in Step 3, do it now:
- Add `A` record pointing to your droplet IP

### 8.2 Test Everything

```bash
# From your local machine
curl https://yourdomain.com
# Should return the Quran Explorer HTML

# Check SSL
curl -I https://yourdomain.com
# Should show 200 and SSL info
```

### 8.3 Performance Testing

```bash
# Inside the droplet, check response times
time curl http://localhost:3000

# Check audio files
curl -I http://yourdomain.com/audio/alafasy/001.mp3
# Should return audio/mpeg
```

---

## 💰 Cost Summary

| Service | Cost | Notes |
|---------|------|-------|
| Droplet | $5/month | 1GB RAM, 25GB SSD, 1TB bandwidth |
| Domain | $10-15/year | GoDaddy, Namecheap, DigitalOcean Registrar |
| SSL | Free | Let's Encrypt (auto-renewing) |
| **Total** | **~$5/month** | Just the droplet! |

*Optional upgrades if you need more:*
- **Spaces** (object storage): $5/month for 250GB - use for audio files instead of droplet storage
- **Managed Database**: $15+/month - if you add user accounts later
- **CDN**: Free via Cloudflare - improves global performance

---

## 🆘 Troubleshooting

### Container won't start

```bash
docker compose logs quran-explorer
# Check the error message

# Try rebuilding
docker compose down
docker build --no-cache -t quran-explorer:latest .
docker compose up -d
```

### Port 80/443 already in use

```bash
# Kill the process
sudo lsof -i :80
sudo kill -9 <PID>

# Or use different ports in docker-compose.yml
```

### Audio files not loading

```bash
# Check if files exist
ls -lah /root/exploringquran/audio/alafasy/ | head

# Check permissions
docker exec quran-explorer ls -la /app/public/audio/alafasy/ | head
```

### SSL Certificate not renewing

```bash
# Test renewal
certbot renew --dry-run

# Check renewal status
certbot certificates

# Manual renewal
certbot renew --force-renewal
```

---

## 📚 Additional Resources

- [DigitalOcean Droplet Documentation](https://docs.digitalocean.com/products/droplets/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

---

## ✅ Deployment Checklist

- [ ] Created DigitalOcean account with $5/month droplet
- [ ] SSH'd into droplet and ran setup script
- [ ] Docker and Docker Compose installed
- [ ] Cloned GitHub repository
- [ ] Built and ran Docker container
- [ ] Domain configured to point to droplet
- [ ] SSL certificate obtained from Let's Encrypt
- [ ] Nginx configured with SSL
- [ ] GitHub deploy key added
- [ ] Webhook receiver set up and running
- [ ] Tested end-to-end deployment (push to GitHub → automatic deployment)
- [ ] Site accessible at `https://yourdomain.com`
- [ ] Audio files loading properly
- [ ] Set up log monitoring and backups

---

**Happy hosting! 🕌**

Need help? Check the troubleshooting section or review the Docker logs.
