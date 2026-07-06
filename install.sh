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

# Fixed read command - this was the issue
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
timedatectl set-timezone $TIMEZONE > /dev/null 2>&1

# Install dependencies
echo -e "${YELLOW}⏳ [1/8] Installing dependencies...${NC}"
apt update -y > /dev/null 2>&1
apt install -y software-properties-common curl wget git unzip \
    nginx mariadb-server mariadb-client php8.1 php8.1-{cli,common,curl,mbstring,gd,mysql,zip,bcmath,xml,json,tokenizer} \
    certbot python3-certbot-nginx \
    composer redis-server nodejs npm > /dev/null 2>&1

curl -fsSL https://deb.nodesource.com/setup_16.x | bash - > /dev/null 2>&1
apt install -y nodejs > /dev/null 2>&1
npm install -g yarn > /dev/null 2>&1
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Install Panel
echo -e "${YELLOW}⏳ [2/8] Installing Pterodactyl Panel...${NC}"
mkdir -p $PANEL_PATH
cd $PANEL_PATH
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz > /dev/null 2>&1
tar -xzvf panel.tar.gz > /dev/null 2>&1
cp .env.example .env
composer install --no-dev --optimize-autoloader > /dev/null 2>&1
php artisan key:generate --force > /dev/null 2>&1
chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache
echo -e "${GREEN}✅ Panel installed${NC}"

# Configure database
echo -e "${YELLOW}⏳ [3/8] Configuring database...${NC}"
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'127.0.0.1' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" $PANEL_PATH/.env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" $PANEL_PATH/.env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" $PANEL_PATH/.env
echo -e "${GREEN}✅ Database configured${NC}"

# Install Blueprint
echo -e "${YELLOW}⏳ [4/8] Installing Blueprint Framework...${NC}"
cd $PANEL_PATH
curl -Lo blueprint.sh https://raw.githubusercontent.com/BlueprintFramework/framework/master/scripts/install.sh > /dev/null 2>&1
chmod +x blueprint.sh
bash blueprint.sh > /dev/null 2>&1
php artisan blueprint:install > /dev/null 2>&1
echo -e "${GREEN}✅ Blueprint installed${NC}"

# Install Nebula Theme
echo -e "${YELLOW}⏳ [5/8] Installing Nebula Theme...${NC}"
cd $PANEL_PATH
git clone https://github.com/notnotnotswipez/Nebula > /dev/null 2>&1
cp -r Nebula/* . > /dev/null 2>&1
rm -rf Nebula
yarn install > /dev/null 2>&1
yarn build > /dev/null 2>&1
echo "APP_THEME=nebula" >> .env
echo -e "${GREEN}✅ Nebula theme installed${NC}"

# Configure Nginx
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

ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t > /dev/null 2>&1 && systemctl restart nginx
echo -e "${GREEN}✅ Nginx configured${NC}"

# Setup SSL
echo -e "${YELLOW}⏳ [7/8] Setting up SSL with Certbot...${NC}"
if [[ $DOMAIN != *"."* ]]; then
    echo -e "${YELLOW}⚠️ IP detected, skipping SSL${NC}"
else
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL > /dev/null 2>&1
    echo -e "${GREEN}✅ SSL configured${NC}"
fi

# Finalize
echo -e "${YELLOW}⏳ [8/8] Finalizing installation...${NC}"
cd $PANEL_PATH
php artisan migrate --seed --force > /dev/null 2>&1

# Create admin user automatically
php artisan p:user:make --email=$ADMIN_EMAIL --username=$ADMIN_USERNAME --password=$ADMIN_PASSWORD --name="Admin" --no-interaction > /dev/null 2>&1

chown -R www-data:www-data $PANEL_PATH
chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

# Setup queue
echo "* * * * * php $PANEL_PATH/artisan schedule:run >> /dev/null 2>&1" | crontab -

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

systemctl enable --now pterodactyl-queue > /dev/null 2>&1
echo -e "${GREEN}✅ Installation finalized!${NC}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 INSTALLATION COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🌐 Panel URL: http://$DOMAIN${NC}"
echo -e "${WHITE}👤 Username: $ADMIN_USERNAME${NC}"
echo -e "${WHITE}🔑 Password: $ADMIN_PASSWORD${NC}"
echo -e "${WHITE}📧 Email: $ADMIN_EMAIL${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
