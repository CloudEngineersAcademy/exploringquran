# Architecture Overview for DigitalOcean Deployment

## 🏗️ Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│          GitHub Repository (Your Code)          │
│                                                 │
│  • QuranExplorer/ (HTML/CSS/JS)                 │
│  • audio/ (776 MB MP3 files)                    │
│  • server.js (Node.js static server)            │
│  • Dockerfile (Container definition)            │
│  • docker-compose.yml (Service orchestration)   │
└────────────────────┬────────────────────────────┘
                     │ (git push)
                     ↓
        ┌────────────────────────┐
        │  GitHub Actions CI/CD  │
        │  (Optional automated   │
        │   deployments)         │
        └────────────┬───────────┘
                     │ (SSH + Deploy)
                     ↓
┌─────────────────────────────────────────────────┐
│         DigitalOcean $5 Droplet (Ubuntu)        │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │        Nginx (SSL Reverse Proxy)         │  │
│  │  • Port 80 → 443 redirect               │  │
│  │  • SSL/TLS via Let's Encrypt            │  │
│  │  • Gzip compression                      │  │
│  │  • Security headers                      │  │
│  └──────────────────────────────────────────┘  │
│                    ↓                           │
│  ┌──────────────────────────────────────────┐  │
│  │     Docker Container (Node.js Server)    │  │
│  │  • Serves static HTML/CSS/JS             │  │
│  │  • Streams MP3 audio files               │  │
│  │  • Handles image/font requests           │  │
│  │  • Implements caching headers            │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  Storage:                                       │
│  • 25 GB SSD (OS ~2GB, Docker ~5GB, Audio ~1GB)|
│  • ~15 GB free for growth                       │
│                                                 │
│  RAM: 1 GB (more than enough for static site) │
│  Bandwidth: 1 TB/month (unlimited for you)    │
└─────────────────────────────────────────────────┘
         Public Internet (Port 80/443)
                     ↑
         ┌──────────────────────┐
         │  Your Domain DNS     │
         │  Points to Droplet IP│
         └──────────────────────┘
```

---

## 📦 What's Included

### Files We Created:

1. **server.js** - Node.js HTTP server for static file serving
   - Handles CORS headers
   - Sets appropriate MIME types
   - Implements caching strategies
   - Security features (path traversal prevention)

2. **Dockerfile** - Container definition
   - Alpine Linux base (lightweight)
   - Node.js 20
   - Health checks included

3. **docker-compose.yml** - Service orchestration
   - Quran Explorer app service
   - Nginx reverse proxy (if SSL enabled)
   - Auto-restart policies
   - Resource limits for $5 droplet

4. **.dockerignore** - Build optimization
   - Excludes unnecessary files from image
   - Reduces build time and image size

5. **DIGITALOCEAN_DEPLOYMENT_GUIDE.md** - Complete setup guide
   - Step-by-step instructions
   - SSL configuration
   - GitHub integration
   - Monitoring and maintenance

6. **.github/workflows/deploy.yml** - GitHub Actions CI/CD
   - Automatic deployment on push to main
   - SSH into droplet
   - Pull changes and rebuild

7. **setup-digitalocean.sh** - Interactive setup script
   - Automates initial server configuration
   - Installs Docker, Docker Compose
   - Clones your repository
   - Optional SSL setup

8. **quran-explorer.service** - Systemd service file
   - Manages Docker container lifecycle
   - Auto-restart on failure
   - Resource limits

---

## 🚀 Quick Start (3 Steps)

### Step 1: Create DigitalOcean Droplet
- Go to [DigitalOcean](https://digitalocean.com)
- Create Ubuntu 24.04 LTS droplet ($5/month)
- Note your IP address

### Step 2: Run Setup Script
```bash
ssh root@YOUR_DROPLET_IP
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/exploringquran/main/setup-digitalocean.sh
chmod +x setup-digitalocean.sh
./setup-digitalocean.sh
```

### Step 3: Point Domain (Optional)
```
DNS A Record:
Name: @
Value: YOUR_DROPLET_IP
TTL: 3600
```

---

## 💾 Storage Breakdown ($5 Droplet - 25GB)

```
Ubuntu OS:             ~2 GB
Docker:                ~3 GB
Node.js base image:    ~500 MB
Quran Explorer HTML:   ~10 MB
Audio files (776MB):   ~776 MB
Nginx image (opt.):    ~50 MB
Other/Buffer:          ~18 GB (available)

Total used: ~7 GB
Free space: ~18 GB
```

✅ **Plenty of room for the audio files and future growth!**

---

## 🔄 Deployment Workflows

### Option A: Manual Deployment
```bash
ssh root@your-droplet
cd /root/exploringquran
git pull origin main
docker compose up -d --build
```

### Option B: GitHub Actions (Automatic)
1. Add secrets to GitHub:
   - `DROPLET_IP`: Your droplet IP
   - `DEPLOY_KEY`: SSH private key (from droplet)

2. Push to main branch → Automatic deployment!

### Option C: Webhook Receiver
Edit `nginx.conf` to expose webhook endpoint on specific port:
```nginx
location /deploy {
    proxy_pass http://webhook-receiver:3001;
}
```

---

## 🔒 Security Features

✅ **SSL/TLS Encryption**
- Let's Encrypt certificates (free)
- Auto-renewal (90-day certs)
- Forced HTTPS redirect

✅ **Security Headers**
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block

✅ **Path Traversal Prevention**
- Server sanitizes file paths
- Prevents ../ access

✅ **Rate Limiting** (via Nginx)
- Can add `limit_req` to nginx.conf if needed

✅ **CORS Headers**
- Properly set for audio playback

---

## 📊 Performance Metrics

### Expected Performance:
- **Page Load Time**: < 500ms (HTML cached)
- **Audio Load Time**: ~100-200ms (MP3 streamed)
- **Concurrent Users**: 50-100+ (for a $5 droplet)
- **Memory Usage**: 150-250 MB (under 1 GB limit)

### Optimization Tips:
1. ✅ Gzip compression enabled (HTML/JS/CSS)
2. ✅ Browser caching headers set (1 year for static assets)
3. ✅ Docker uses Alpine (lightweight base)
4. ✅ Nginx reverse proxy layer

---

## 🛠️ Monitoring & Logs

### Check Container Status
```bash
docker compose ps
docker compose logs -f quran-explorer
```

### Monitor Resources
```bash
docker stats
# Or SSH monitoring:
top
df -h
free -h
```

### Check SSL Certificate
```bash
certbot certificates
```

### View Deployment history
```bash
tail -f /var/log/quran-deploy.log
```

---

## 💰 Cost Comparison

| Option | Cost | Setup | Management |
|--------|------|-------|-----------|
| **GitHub Pages** | $0 | 5 min | None |
| **Netlify** | $0 | 2 min | None |
| **DigitalOcean $5** | $5/mo | 15 min | Moderate |
| **AWS EC2** | $10-50/mo | 30 min | High |

**You chose DigitalOcean because:**
✅ Full server control for future features
✅ Cheap at $5/month
✅ Easy Docker deployment
✅ Custom domain + SSL included
✅ Good for future scaling

---

## 🚨 Troubleshooting Quick Links

### Container won't start
→ Run: `docker compose logs quran-explorer`

### Audio files not loading
→ Check: `docker exec quran-explorer ls /app/public/audio/`

### Domain not resolving
→ Wait 15 minutes for DNS, then: `nslookup yourdomain.com`

### Port 80/443 in use
→ Run: `sudo lsof -i :80`

### SSL certificate expired
→ Run: `certbot renew` or wait for auto-renewal (cron job)

---

## 📚 Next Steps

1. **Commit these files to GitHub**
   ```bash
   git add Dockerfile docker-compose.yml server.js .dockerignore
   git add DIGITALOCEAN_DEPLOYMENT_GUIDE.md setup-digitalocean.sh
   git add .github/workflows/deploy.yml quran-explorer.service
   git commit -m "Add DigitalOcean deployment setup"
   git push origin main
   ```

2. **Create DigitalOcean Droplet** (takes 2-3 minutes)

3. **Run setup script** (takes 5-10 minutes)

4. **Test your site** (should be live immediately)

5. _(Optional)_ Set up GitHub Actions for auto-deployment

---

## 📞 Support & Resources

- DigitalOcean Docs: https://docs.digitalocean.com/
- Docker Docs: https://docs.docker.com/
- Let's Encrypt: https://letsencrypt.org/
- Full Guide: `DIGITALOCEAN_DEPLOYMENT_GUIDE.md`

---

**Ready to go live? Follow the steps in DIGITALOCEAN_DEPLOYMENT_GUIDE.md!** 🚀
