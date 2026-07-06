#!/bin/bash

# ==========================================
# PTERODACTYL PANEL + BLUEPRINT + NEBULA 
# AUTO INSTALLER - AARYAN EDITION
# ==========================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Check root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Must be root${NC}"
    exit 1
fi

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     🚀 PTERODACTYL + BLUEPRINT + NEBULA${NC}"
echo -e "${CYAN}            Auto Installer by Aaryan${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Ask for domain only
echo -e -n "${YELLOW}Enter your Domain/IP: ${NC}"
read DOMAIN

if [ -z "$DOMAIN" ]; then
    DOMAIN=$(curl -s ifconfig.me)
    echo -e "${YELLOW}⚠️ Using IP: $DOMAIN${NC}"
fi

echo ""
echo -e "${GREEN}✅ Using Preset Configuration:${NC}"
echo -e "${WHITE}📧 Email: saggaraaryan311@gmail.com${NC}"
echo -e "${WHITE}👤 Username: Aaryan${NC}"
echo -e "${WHITE}🔑 Password: AARYAN_IS_LIVE${NC}"
echo -e "${WHITE}🌐 Domain: $DOMAIN${NC}"
echo -e "${WHITE}🕐 Timezone: Asia/Kolkata${NC}"
echo ""

echo -e -n "${YELLOW}Continue with installation? (y/n): ${NC}"
read -n 1 REPLY
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Installation cancelled${NC}"
    exit 1
fi

# Preset Variables
ADMIN_EMAIL="saggaraaryan311@gmail.com"
ADMIN_USERNAME="Aaryan"
ADMIN_PASSWORD="AARYAN_IS_LIVE"
DB_NAME="panel"
DB_USER="pterodactyl"
DB_PASSWORD=$(openssl rand -base64 32)
PANEL_PATH="/var/www/pterodactyl"
TIMEZONE="Asia/Kolkata"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Set timezone
timedatectl set-timezone $TIMEZONE 2>/dev/null

# ============================================
# STEP 1: Install Dependencies
# ============================================
echo -e "${YELLOW}⏳ [1/8] Installing dependencies...${NC}"

# Update system
apt update -y

# Install essential packages
apt install -y software-properties-common curl wget git unzip \
    nginx mariadb-server mariadb-client \
    php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-mbstring \
    php8.1-gd php8.1-mysql php8.1-zip php8.1-bcmath php8.1-xml \
    php8.1-json php8.1-tokenizer \
    certbot python3-certbot-nginx \
    composer redis-server nodejs npm cron

# Install Node.js 16+
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs

# Install Yarn
npm install -g yarn

# Start MySQL
systemctl start mariadb
systemctl enable mariadb

# Start Nginx
systemctl start nginx
systemctl enable nginx

echo -e "${GREEN}✅ Dependencies installed${NC}"

# ============================================
# STEP 2: Install Panel
# ============================================
echo -e "${YELLOW}⏳ [2/8] Installing Pterodactyl Panel...${NC}"

mkdir -p $PANEL_PATH
cd $PANEL_PATH

# Download Panel
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
cp .env.example .env

# Install composer dependencies
composer install --no-dev --optimize-autoloader

# Generate key
php artisan key:generate --force

# Set permissions
chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

echo -e "${GREEN}✅ Panel installed${NC}"

# ============================================
# STEP 3: Configure Database
# ============================================
echo -e "${YELLOW}⏳ [3/8] Configuring database...${NC}"

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'127.0.0.1' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Update .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $PANEL_PATH/.env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" $PANEL_PATH/.env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" $PANEL_PATH/.env

echo -e "${GREEN}✅ Database configured${NC}"

# ============================================
# STEP 4: Install Blueprint
# ============================================
echo -e "${YELLOW}⏳ [4/8] Installing Blueprint Framework...${NC}"

cd $PANEL_PATH
curl -Lo blueprint.sh https://raw.githubusercontent.com/BlueprintFramework/framework/master/scripts/install.sh
chmod +x blueprint.sh
bash blueprint.sh
php artisan blueprint:install

echo -e "${GREEN}✅ Blueprint installed${NC}"

# ============================================
# STEP 5: Install Nebula Theme
# ============================================
echo -e "${YELLOW}⏳ [5/8] Installing Nebula Theme...${NC}"

cd $PANEL_PATH
git clone https://github.com/notnotnotswipez/Nebula
cp -r Nebula/* .
rm -rf Nebula
yarn install
yarn build
echo "APP_THEME=nebula" >> .env

echo -e "${GREEN}✅ Nebula theme installed${NC}"

# ============================================
# STEP 6: Configure Nginx
# ============================================
echo -e "${YELLOW}⏳ [6/8] Configuring Nginx...${NC}"

cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    
    root /var/www/pterodactyl/public;
    index index.php index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart
nginx -t && systemctl restart nginx

echo -e "${GREEN}✅ Nginx configured${NC}"

# ============================================
# STEP 7: Setup SSL
# ============================================
echo -e "${YELLOW}⏳ [7/8] Setting up SSL with Certbot...${NC}"

if [[ $DOMAIN != *"."* ]]; then
    echo -e "${YELLOW}⚠️ IP detected, skipping SSL${NC}"
else
    # Try to get SSL certificate
    if certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL; then
        echo -e "${GREEN}✅ SSL configured${NC}"
    else
        echo -e "${YELLOW}⚠️ SSL failed - check DNS or use HTTP${NC}"
    fi
fi

# ============================================
# STEP 8: Finalize
# ============================================
echo -e "${YELLOW}⏳ [8/8] Finalizing installation...${NC}"

cd $PANEL_PATH

# Run migrations
php artisan migrate --seed --force

# Create admin user
php artisan p:user:make --email=$ADMIN_EMAIL --username=$ADMIN_USERNAME --password=$ADMIN_PASSWORD --name="Admin" --no-interaction

# Set permissions
chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

# Setup cron
echo "* * * * * php $PANEL_PATH/artisan schedule:run >> /dev/null 2>&1" | crontab -

# Create queue worker
cat > /etc/systemd/system/pterodactyl-queue.service <<EOF
[Unit]
Description=Pterodactyl Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
ExecStart=/usr/bin/php $PANEL_PATH/artisan queue:work --sleep=3 --tries=3
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now pterodactyl-queue

echo -e "${GREEN}✅ Installation finalized!${NC}"

# ============================================
# COMPLETE
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 INSTALLATION COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🌐 Panel URL: http://$DOMAIN${NC}"
if [[ $DOMAIN != *"."* ]]; then
    echo -e "${YELLOW}⚠️ SSL not installed (IP address detected)${NC}"
else
    echo -e "${WHITE}🔒 HTTPS URL: https://$DOMAIN${NC}"
fi
echo -e "${WHITE}👤 Username: $ADMIN_USERNAME${NC}"
echo -e "${WHITE}🔑 Password: $ADMIN_PASSWORD${NC}"
echo -e "${WHITE}📧 Email: $ADMIN_EMAIL${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show services status
echo -e "\n${YELLOW}📊 Services Status:${NC}"
systemctl status nginx --no-pager | grep "Active:"
systemctl status mariadb --no-pager | grep "Active:"
systemctl status pterodactyl-queue --no-pager | grep "Active:"
