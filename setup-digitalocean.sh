#!/bin/bash

# 🚀 Quick Setup Script for DigitalOcean
# Run this on your droplet after creating it

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🕌 Quran Explorer - Quick Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Step 1: Update system
echo -e "${BLUE}[1/7]${NC} Updating system packages..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
echo -e "${GREEN}✓ System updated${NC}"

# Step 2: Install Docker
echo -e "${BLUE}[2/7]${NC} Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1
    sh get-docker.sh > /dev/null 2>&1
    rm get-docker.sh
    systemctl enable docker > /dev/null 2>&1
    systemctl start docker > /dev/null 2>&1
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi

# Step 3: Install Docker Compose
echo -e "${BLUE}[3/7]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    apt-get install -y docker-compose-plugin > /dev/null 2>&1
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
fi

# Step 4: Clone repository
echo -e "${BLUE}[4/7]${NC} Cloning repository..."
if [ ! -d "/root/exploringquran" ]; then
    read -p "Enter your GitHub username: " github_user
    read -p "Enter repository name (default: exploringquran): " repo_name
    repo_name=${repo_name:-exploringquran}
    
    git clone https://github.com/$github_user/$repo_name.git /root/exploringquran > /dev/null 2>&1
    echo -e "${GREEN}✓ Repository cloned${NC}"
else
    echo -e "${YELLOW}⚠ Repository already exists, skipping clone${NC}"
fi

# Step 5: Build Docker image
echo -e "${BLUE}[5/7]${NC} Building Docker image (this may take 1-2 minutes)..."
cd /root/exploringquran
docker build -t quran-explorer:latest . > /dev/null 2>&1
echo -e "${GREEN}✓ Docker image built${NC}"

# Step 6: Start services
echo -e "${BLUE}[6/7]${NC} Starting services..."
docker compose down > /dev/null 2>&1
docker compose up -d > /dev/null 2>&1

# Wait for container to be healthy
sleep 5
if docker compose ps | grep -q healthy; then
    echo -e "${GREEN}✓ Services started and healthy${NC}"
else
    echo -e "${YELLOW}⚠ Services started (wait a moment for health check to pass)${NC}"
fi

# Step 7: SSL Setup (optional)
echo -e "${BLUE}[7/7]${NC} SSL Certificate Setup"
read -p "Do you have a domain? (y/n): " has_domain

if [[ $has_domain =~ ^[Yy]$ ]]; then
    apt-get install -y certbot python3-certbot-nginx > /dev/null 2>&1
    
    read -p "Enter your domain (e.g., yourdomain.com): " domain
    read -p "Enter your email for Let's Encrypt: " email
    
    docker compose down > /dev/null 2>&1
    
    certbot certonly --standalone \
      --email $email \
      --agree-tos \
      --non-interactive \
      -d $domain \
      -d www.$domain > /dev/null 2>&1
    
    echo -e "${GREEN}✓ SSL certificate obtained${NC}"
    
    # Create nginx config
    cat > /root/nginx.conf <<EOF
upstream quran-explorer {
    server quran-explorer:3000;
}

server {
    listen 80;
    server_name $domain www.$domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain www.$domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    gzip on;
    gzip_types text/html text/css application/json application/javascript;

    location / {
        proxy_pass http://quran-explorer;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
}
EOF

    # Update docker-compose to include nginx
    cat > /root/docker-compose-ssl.yml <<EOF
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /root/nginx.conf:/etc/nginx/conf.d/default.conf:ro
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
EOF

    mv /root/docker-compose-ssl.yml /root/exploringquran/docker-compose.yml
    
    docker compose up -d > /dev/null 2>&1
    
    # Setup auto-renewal
    cat > /root/renew-cert.sh <<EOF
#!/bin/bash
certbot renew --quiet --pre-hook "cd /root/exploringquran && docker compose down" --post-hook "cd /root/exploringquran && docker compose up -d"
EOF
    chmod +x /root/renew-cert.sh
    
    (crontab -l 2>/dev/null; echo "0 3 * * * /root/renew-cert.sh") | crontab -
    
    echo -e "${GREEN}✓ SSL configured with auto-renewal${NC}"
else
    docker compose up -d > /dev/null 2>&1
    echo -e "${YELLOW}⚠ Skipped SSL setup${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Status:"
docker compose ps
echo ""
echo "🔗 Access your site:"
if [[ $has_domain =~ ^[Yy]$ ]]; then
    echo "   https://$domain"
else
    echo "   http://$(hostname -I | awk '{print $1}'):80"
fi
echo ""
echo "📝 Next steps:"
echo "   1. Point your domain DNS to this server's IP (if not done)"
echo "   2. Check deployment guide: cat DIGITALOCEAN_DEPLOYMENT_GUIDE.md"
echo "   3. Monitor logs: docker compose logs -f"
echo ""
