#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════╗
# ║          NexaHost – One-Line Install Script          ║
# ║    github.com/YOURUSERNAME/nexahost-ui               ║
# ╚══════════════════════════════════════════════════════╝

set -e

# ── Colors ─────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}[NexaHost]${RESET} $1"; }
ok()   { echo -e "${GREEN}[  OK  ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[ WARN ]${RESET} $1"; }
err()  { echo -e "${RED}[ ERR  ]${RESET} $1"; exit 1; }

echo ""
echo -e "${BOLD}${CYAN}"
echo "  ███╗   ██╗███████╗██╗  ██╗ █████╗ "
echo "  ████╗  ██║██╔════╝╚██╗██╔╝██╔══██╗"
echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ███████║"
echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██╔══██║"
echo "  ██║ ╚████║███████╗██╔╝ ██╗██║  ██║"
echo "  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝"
echo "         H O S T  -  U I  v1.0"
echo -e "${RESET}"

# ── Root check ────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  err "Please run as root: sudo bash install.sh"
fi

# ── Defaults ─────────────────────────────────────────
INSTALL_DIR="/var/www/nexahost"
PORT=80
REPO_URL="https://github.com/YOURUSERNAME/nexahost-ui"
DOMAIN=""
USE_SSL=false

# ── Argument parsing ──────────────────────────────────
for arg in "$@"; do
  case $arg in
    --domain=*) DOMAIN="${arg#*=}" ;;
    --port=*)   PORT="${arg#*=}"   ;;
    --ssl)      USE_SSL=true       ;;
    --dir=*)    INSTALL_DIR="${arg#*=}" ;;
    --help|-h)
      echo "Usage: bash install.sh [options]"
      echo "  --domain=example.com   Your domain name"
      echo "  --port=8080            Custom port (default: 80)"
      echo "  --ssl                  Enable SSL (requires domain + certbot)"
      echo "  --dir=/path/to/dir     Install directory (default: /var/www/nexahost)"
      exit 0 ;;
  esac
done

log "Starting installation..."
log "Install dir : $INSTALL_DIR"
log "Port        : $PORT"
[[ -n "$DOMAIN" ]] && log "Domain      : $DOMAIN"

# ── Detect web server ────────────────────────────────
detect_webserver() {
  if command -v nginx &>/dev/null && systemctl is-active nginx &>/dev/null; then
    echo "nginx"
  elif command -v apache2 &>/dev/null && systemctl is-active apache2 &>/dev/null; then
    echo "apache2"
  elif command -v nginx &>/dev/null; then
    echo "nginx-installed"
  elif command -v apache2 &>/dev/null; then
    echo "apache-installed"
  else
    echo "none"
  fi
}

WEB_SERVER=$(detect_webserver)
log "Web server detected: $WEB_SERVER"

# ── Install dependencies ──────────────────────────────
log "Updating package lists..."
apt-get update -qq

case $WEB_SERVER in
  none)
    log "No web server found. Installing Nginx..."
    apt-get install -y -qq nginx
    systemctl enable nginx
    systemctl start nginx
    WEB_SERVER="nginx"
    ok "Nginx installed and started."
    ;;
  nginx-installed)
    systemctl enable nginx && systemctl start nginx
    WEB_SERVER="nginx"
    ;;
  apache-installed)
    systemctl enable apache2 && systemctl start apache2
    WEB_SERVER="apache2"
    ;;
esac

# ── Download files directly via curl ─────────────────
RAW="https://raw.githubusercontent.com/saggaraaryan311-sys/aaryanhost-ui/main"

log "Downloading NexaHost UI files..."
mkdir -p "$INSTALL_DIR/assets"

curl -fsSL "$RAW/index.html"        -o "$INSTALL_DIR/index.html"        || err "Failed to download index.html"
curl -fsSL "$RAW/assets/style.css"  -o "$INSTALL_DIR/assets/style.css"  || err "Failed to download style.css"
curl -fsSL "$RAW/assets/app.js"     -o "$INSTALL_DIR/assets/app.js"     || err "Failed to download app.js"

ok "All files downloaded successfully."

# ── Set permissions ───────────────────────────────────
chown -R www-data:www-data "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
ok "Permissions set."

# ── Write Nginx config ────────────────────────────────
write_nginx_config() {
  local SERVER_NAME="${DOMAIN:-_}"
  local CONFIG_FILE="/etc/nginx/sites-available/nexahost"

  cat > "$CONFIG_FILE" <<NGINX
server {
    listen ${PORT};
    listen [::]:${PORT};
    server_name ${SERVER_NAME};
    root ${INSTALL_DIR};
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/css application/javascript text/html image/svg+xml;
    gzip_min_length 1024;

    # Cache static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
}
NGINX

  # Enable site
  ln -sf "$CONFIG_FILE" /etc/nginx/sites-enabled/nexahost
  rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

  # Test config
  nginx -t -q 2>/dev/null || err "Nginx config test failed! Check /etc/nginx/sites-available/nexahost"
  systemctl reload nginx
  ok "Nginx configured and reloaded."
}

# ── Write Apache config ───────────────────────────────
write_apache_config() {
  local SERVER_NAME="${DOMAIN:-localhost}"
  local CONFIG_FILE="/etc/apache2/sites-available/nexahost.conf"

  cat > "$CONFIG_FILE" <<APACHE
<VirtualHost *:${PORT}>
    ServerName ${SERVER_NAME}
    DocumentRoot ${INSTALL_DIR}

    <Directory ${INSTALL_DIR}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nexahost_error.log
    CustomLog \${APACHE_LOG_DIR}/nexahost_access.log combined
</VirtualHost>
APACHE

  a2ensite nexahost.conf &>/dev/null
  a2dissite 000-default.conf &>/dev/null || true
  a2enmod rewrite &>/dev/null
  systemctl reload apache2
  ok "Apache configured and reloaded."
}

# ── Configure web server ──────────────────────────────
case $WEB_SERVER in
  nginx*)  write_nginx_config  ;;
  apache*) write_apache_config ;;
esac

# ── SSL with Certbot ──────────────────────────────────
if [[ "$USE_SSL" == true && -n "$DOMAIN" ]]; then
  log "Setting up SSL with Certbot..."
  if ! command -v certbot &>/dev/null; then
    apt-get install -y -qq certbot python3-certbot-nginx
  fi
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email || {
    warn "Certbot failed. You can run it manually: certbot --nginx -d $DOMAIN"
  }
fi

# ── Get server IP ─────────────────────────────────────
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

# ── Done! ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║     ✅  INSTALLATION COMPLETE!           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}🌐 Your site is live at:${RESET}"
if [[ -n "$DOMAIN" ]]; then
  echo -e "   ${CYAN}https://${DOMAIN}${RESET}"
else
  echo -e "   ${CYAN}http://${SERVER_IP}${RESET}"
fi
echo ""
echo -e "${BOLD}📁 Files installed to:${RESET}  ${INSTALL_DIR}"
echo -e "${BOLD}⚙  Web server:${RESET}         ${WEB_SERVER}"
echo ""
echo -e "Edit site content: ${YELLOW}nano ${INSTALL_DIR}/index.html${RESET}"
echo -e "Change branding  : Find & replace 'NexaHost' in index.html"
echo ""
echo -e "${CYAN}Good luck with your hosting business! 🚀${RESET}"
echo ""
