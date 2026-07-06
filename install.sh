#!/bin/bash

# ==========================================
# PTERODACTYL PANEL + BLUEPRINT + NEBULA 
# COMPLETE AUTO INSTALLER - AARYAN EDITION
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
echo -e "${CYAN}            Complete Auto Installer by Aaryan${NC}"
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

# ============================================
# STEP 1: FULL SYSTEM UPDATE
# ============================================
echo -e "${YELLOW}⏳ [1/9] Updating system...${NC}"
apt update -y
apt upgrade -y
apt autoremove -y
echo -e "${GREEN}✅ System updated${NC}"

# ============================================
# STEP 2: INSTALL ALL DEPENDENCIES
# ============================================
echo -e "${YELLOW}⏳ [2/9] Installing all dependencies...${NC}"

# Essential packages
apt install -y software-properties-common curl wget git unzip \
    apt-transport-https ca-certificates gnupg lsb-release

# Install PHP 8.1 and all extensions
apt install -y php8.1 php8.1-cli php8.1-common php8.1-curl \
    php8.1-mbstring php8.1-gd php8.1-mysql php8.1-zip \
    php8.1-bcmath php8.1-xml php8.1-json php8.1-tokenizer \
    php8.1-fpm php8.1-redis php8.1-intl

# Install Nginx
apt install -y nginx nginx-common

# Install MariaDB
apt install -y mariadb-server mariadb-client

# Install other required packages
apt install -y certbot python3-certbot-nginx \
    composer redis-server cron supervisor \
    nodejs npm

# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install Yarn globally
npm install -g yarn

# Install additional tools
apt install -y htop net-tools ufw fail2ban

echo -e "${GREEN}✅ All dependencies installed${NC}"

# ============================================
# STEP 3: START AND ENABLE SERVICES
# ============================================
echo -e "${YELLOW}⏳ [3/9] Starting services...${NC}"

# Start MariaDB
systemctl start mariadb
systemctl enable mariadb

# Start Nginx
systemctl start nginx
systemctl enable nginx

# Start Redis
systemctl start redis-server
systemctl enable redis-server

# Start PHP-FPM
systemctl start php8.1-fpm
systemctl enable php8.1-fpm

echo -e "${GREEN}✅ All services started${NC}"

# ============================================
# STEP 4: INSTALL PTERODACTYL PANEL
# ============================================
echo -e "${YELLOW}⏳ [4/9] Installing Pterodactyl Panel...${NC}"

# Create directory
mkdir -p $PANEL_PATH
cd $PANEL_PATH

# Download latest Panel
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
cp .env.example .env

# Install composer dependencies
composer install --no-dev --optimize-autoloader

# Generate application key
php artisan key:generate --force

# Set permissions
chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

echo -e "${GREEN}✅ Pterodactyl Panel installed${NC}"

# ============================================
# STEP 5: CONFIGURE DATABASE
# ============================================
echo -e "${YELLOW}⏳ [5/9] Configuring database...${NC}"

# Secure MariaDB installation
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'127.0.0.1' WITH GRANT OPTION;"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Update .env file
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $PANEL_PATH/.env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" $PANEL_PATH/.env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" $PANEL_PATH/.env
sed -i "s/DB_HOST=.*/DB_HOST=127.0.0.1/" $PANEL_PATH/.env

echo -e "${GREEN}✅ Database configured${NC}"

# ============================================
# STEP 6: INSTALL BLUEPRINT
# ============================================
echo -e "${YELLOW}⏳ [6/9] Installing Blueprint Framework...${NC}"

cd $PANEL_PATH
curl -Lo blueprint.sh https://raw.githubusercontent.com/BlueprintFramework/framework/master/scripts/install.sh
chmod +x blueprint.sh
bash blueprint.sh
php artisan blueprint:install

echo -e "${GREEN}✅ Blueprint installed${NC}"

# ============================================
# STEP 7: INSTALL NEBULA THEME
# ============================================
echo -e "${YELLOW}⏳ [7/9] Installing Nebula Theme...${NC}"

cd $PANEL_PATH
git clone https://github.com/notnotnotswipez/Nebula
cp -r Nebula/* .
rm -rf Nebula
yarn install
yarn build
echo "APP_THEME=nebula" >> .env

echo -e "${GREEN}✅ Nebula theme installed${NC}"

# ============================================
# STEP 8: CONFIGURE NGINX
# ============================================
echo -e "${YELLOW}⏳ [8/9] Configuring Nginx...${NC}"

# Create Nginx config
cat > /etc/nginx/sites-available/pterodactyl.conf <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;
    
    root /var/www/pterodactyl/public;
    index index.php index.html index.htm;
    
    client_max_body_size 100M;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /etc/nginx/sites-available/pterodactyl.conf

# Enable site
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
nginx -t
systemctl restart nginx

echo -e "${GREEN}✅ Nginx configured${NC}"

# ============================================
# STEP 9: SETUP SSL AND FINALIZE
# ============================================
echo -e "${YELLOW}⏳ [9/9] Setting up SSL and finalizing...${NC}"

# Setup SSL if domain has dot
if [[ $DOMAIN == *"."* ]]; then
    echo -e "${YELLOW}🔒 Attempting SSL setup...${NC}"
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL 2>/dev/null || {
        echo -e "${YELLOW}⚠️ SSL failed - check DNS or use HTTP${NC}"
    }
else
    echo -e "${YELLOW}⚠️ IP detected, skipping SSL${NC}"
fi

# Run migrations
cd $PANEL_PATH
php artisan migrate --seed --force

# Create admin user
php artisan p:user:make --email=$ADMIN_EMAIL --username=$ADMIN_USERNAME --password=$ADMIN_PASSWORD --name="Admin" --no-interaction

# Set permissions
chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

# Setup cron
(crontab -l 2>/dev/null; echo "* * * * * php $PANEL_PATH/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Create queue worker
cat > /etc/systemd/system/pterodactyl-queue.service <<'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --sleep=3 --tries=3
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now pterodactyl-queue

# Configure firewall (if UFW is available)
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 22/tcp
    ufw --force enable
fi

echo -e "${GREEN}✅ Installation finalized!${NC}"

# ============================================
# COMPLETE - SHOW DETAILS
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 INSTALLATION COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🌐 Panel URL: http://$DOMAIN${NC}"
if [[ $DOMAIN == *"."* ]]; then
    echo -e "${WHITE}🔒 HTTPS URL: https://$DOMAIN${NC}"
fi
echo -e "${WHITE}👤 Username: $ADMIN_USERNAME${NC}"
echo -e "${WHITE}🔑 Password: $ADMIN_PASSWORD${NC}"
echo -e "${WHITE}📧 Email: $ADMIN_EMAIL${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show services status
echo -e "\n${YELLOW}📊 Services Status:${NC}"
for service in nginx mariadb php8.1-fpm redis-server pterodactyl-queue; do
    status=$(systemctl is-active $service 2>/dev/null)
    if [ "$status" == "active" ]; then
        echo -e "${GREEN}✅ $service: $status${NC}"
    else
        echo -e "${RED}❌ $service: $status${NC}"
    fi
done

echo -e "\n${YELLOW}💡 Next Steps:${NC}"
echo -e "1. Visit your panel: ${GREEN}http://$DOMAIN${NC}"
echo -e "2. Login with: ${GREEN}$ADMIN_USERNAME / $ADMIN_PASSWORD${NC}"
echo -e "3. Setup Wings (Node) for hosting"
echo -e "4. Configure your first server!"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
