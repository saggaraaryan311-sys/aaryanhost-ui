#!/bin/bash

# Colors for output - RED THEME
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Preset Configuration
PRESET_DOMAIN=""
PRESET_EMAIL="aaryan311@gmail.com"
PRESET_USERNAME="Aaryan"
PRESET_PASSWORD="AARYAN_IS_LIVE"
PRESET_DB_NAME="panel"
PRESET_DB_USER="pterodactyl"
PRESET_DB_PASS=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
PRESET_SSL="yes"
PRESET_PATH="/var/www/pterodactyl"
PRESET_TIMEZONE="Asia/Kolkata"

# Function to print section headers (RED theme)
print_header_rule() {
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Big ASCII header using heredoc (RED theme)
big_header() {
    local title="$1"
    echo -e "${RED}"
    case "$title" in
        "MAIN MENU")
cat <<'EOF'
███╗   ███╗ █████╗ ██╗███╗   ██╗    ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔══██╗██║████╗  ██║    ████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║███████║██║██╔██╗ ██║    ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══██║██║██║╚██╗██║    ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║██║  ██║██║██║ ╚████║    ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                          
EOF
            ;;
        "SYSTEM INFORMATION")
cat <<'EOF'
 █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║
███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║
██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                                                   
EOF
            ;;
        "WELCOME")
cat <<'EOF'
 █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║
███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║
██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                                                   
EOF
            ;;
        "DATABASE SETUP")
cat <<'EOF'
██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗
██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗  
██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝  
██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗
╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝
                                                                 
EOF
            ;;
        "BLUEPRINT+THEME+EXTENSIONS")
cat <<'EOF'
 █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║
███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║
██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                                                   
EOF
            ;;
        "PRESET AARYAN")
cat <<'EOF'
 █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║
███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║
██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                                                   
EOF
            ;;
        *)
            echo -e "${BOLD}${title}${NC}"
            ;;
    esac
    echo -e "${NC}"
}

# Function to print status messages
print_status() { echo -e "${YELLOW}⏳ $1...${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${MAGENTA}⚠️  $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# Check if curl is installed
check_curl() {
    if ! command -v curl &>/dev/null; then
        print_error "curl is not installed"
        print_status "Installing curl..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y curl
        else
            print_error "Could not install curl automatically. Please install it manually"
            exit 1
        fi
        print_success "curl installed successfully"
    fi
}

# Function to run remote scripts
run_remote_script() {
    local url=$1
    local script_name
    script_name=$(basename "$url" .sh)
    script_name=$(echo "$script_name" | sed 's/.*/\u&/')

    print_header_rule
    big_header "WELCOME"
    print_header_rule
    echo -e "${RED}Running: ${BOLD}${script_name}${NC}"
    print_header_rule

    check_curl
    local temp_script
    temp_script=$(mktemp)
    print_status "Downloading script"

    if curl -fsSL "$url" -o "$temp_script"; then
        print_success "Download successful"
        chmod +x "$temp_script"
        bash "$temp_script"
        local exit_code=$?
        rm -f "$temp_script"
        if [ $exit_code -eq 0 ]; then
            print_success "Script executed successfully"
        else
            print_error "Script execution failed with exit code: $exit_code"
        fi
    else
        print_error "Failed to download script"
    fi

    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Get server IP
get_server_ip() {
    local ip
    ip=$(curl -s -4 ifconfig.me 2>/dev/null || curl -s -4 icanhazip.com 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')
    echo "$ip"
}

# Install Certbot
install_certbot() {
    print_status "Installing Certbot..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
    elif command -v yum &>/dev/null; then
        sudo yum install -y certbot python3-certbot-nginx
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y certbot python3-certbot-nginx
    fi
    print_success "Certbot installed"
}

# AARYAN PRESET - One Click All Set
aaryan_preset_all_set() {
    print_header_rule
    big_header "PRESET AARYAN"
    print_header_rule
    echo -e "${RED}${BOLD}⚡ AARYAN PRESET - ONE CLICK ALL SET ⚡${NC}"
    print_header_rule

    # Get domain/IP
    echo -e "${CYAN}Enter domain/IP (leave empty for auto-detect):${NC}"
    read -p "Domain/IP: " input_domain
    if [ -z "$input_domain" ]; then
        PRESET_DOMAIN=$(get_server_ip)
        echo -e "${GREEN}Auto-detected IP: ${PRESET_DOMAIN}${NC}"
    else
        PRESET_DOMAIN="$input_domain"
    fi

    # Confirm preset values
    echo -e "\n${YELLOW}${BOLD}📋 PRESET CONFIGURATION:${NC}"
    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║ ${GREEN}Domain/IP:${NC} ${WHITE}${PRESET_DOMAIN}${NC}${WHITE}                          ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Admin Email:${NC} ${WHITE}${PRESET_EMAIL}${NC}                             ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Admin Username:${NC} ${WHITE}${PRESET_USERNAME}${NC}                          ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Admin Password:${NC} ${WHITE}${PRESET_PASSWORD}${NC}                         ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Database Name:${NC} ${WHITE}${PRESET_DB_NAME}${NC}                           ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Database User:${NC} ${WHITE}${PRESET_DB_USER}${NC}                        ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Database Pass:${NC} ${WHITE}${PRESET_DB_PASS}${NC}         ║${NC}"
    echo -e "${WHITE}║ ${GREEN}SSL Setup:${NC} ${WHITE}${PRESET_SSL}${NC}                                ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Install Path:${NC} ${WHITE}${PRESET_PATH}${NC}                 ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Timezone:${NC} ${WHITE}${PRESET_TIMEZONE}${NC}                            ║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"

    echo -e "\n${YELLOW}Do you want to proceed with this preset? (y/n):${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_warning "Preset installation cancelled"
        read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
        return 1
    fi

    # Set timezone
    print_status "Setting timezone to ${PRESET_TIMEZONE}"
    sudo timedatectl set-timezone "${PRESET_TIMEZONE}" 2>/dev/null || print_warning "Could not set timezone"

    # Step 1: Install Panel
    print_header_rule
    echo -e "${RED}${BOLD}📦 STEP 1: Installing Panel${NC}"
    print_header_rule
    run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/panel2.sh"

    # Step 2: Install Wings
    print_header_rule
    echo -e "${RED}${BOLD}📦 STEP 2: Installing Wings${NC}"
    print_header_rule
    run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/wing2.sh"

    # Step 3: Setup Database with preset values
    print_header_rule
    echo -e "${RED}${BOLD}📦 STEP 3: Configuring Database${NC}"
    print_header_rule
    
    print_status "Creating database user '${PRESET_DB_USER}'..."
    mysql -u root -p <<MYSQL_SCRIPT 2>/dev/null
CREATE DATABASE IF NOT EXISTS ${PRESET_DB_NAME};
CREATE USER IF NOT EXISTS '${PRESET_DB_USER}'@'%' IDENTIFIED BY '${PRESET_DB_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${PRESET_DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    if [ $? -eq 0 ]; then
        print_success "Database '${PRESET_DB_NAME}' and user '${PRESET_DB_USER}' created"
    else
        print_warning "Database setup may have failed. Please check MySQL/MariaDB is installed"
    fi

    # Configure remote access
    CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
    if [ -f "$CONF_FILE" ]; then
        print_status "Enabling remote database access..."
        sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$CONF_FILE"
        sudo systemctl restart mysql 2>/dev/null
        sudo systemctl restart mariadb 2>/dev/null
        print_success "Remote database access enabled"
    fi

    # Step 4: SSL Setup with Certbot
    if [ "$PRESET_SSL" == "yes" ] && [[ "$PRESET_DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_header_rule
        echo -e "${RED}${BOLD}🔒 STEP 4: Setting up SSL with Let's Encrypt${NC}"
        print_header_rule
        install_certbot
        print_status "Obtaining SSL certificate for ${PRESET_DOMAIN}..."
        sudo certbot --nginx -d "${PRESET_DOMAIN}" --non-interactive --agree-tos --email "${PRESET_EMAIL}" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "SSL certificate installed successfully"
        else
            print_warning "SSL setup failed. You may need to run certbot manually"
        fi
    else
        print_info "Skipping SSL setup (domain required for Let's Encrypt)"
    fi

    # Step 5: Install Blueprint
    print_header_rule
    echo -e "${RED}${BOLD}🎨 STEP 5: Installing Blueprint${NC}"
    print_header_rule
    run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/Blueprint2.sh"

    # Step 6: Install Themes + Extensions (Nebula Theme)
    print_header_rule
    echo -e "${RED}${BOLD}🎨 STEP 6: Installing Nebula Theme & Extensions${NC}"
    print_header_rule
    print_status "Installing Themes + Extensions from GitHub..."
    bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/thame/chang.sh)
    if [ $? -eq 0 ]; then
        print_success "Themes + Extensions installed successfully"
    else
        print_warning "Theme installation may have failed"
    fi

    # Step 7: Install Cloudflare Setup
    print_header_rule
    echo -e "${RED}${BOLD}🌐 STEP 7: Cloudflare Setup${NC}"
    print_header_rule
    run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/cloudflare.sh"

    # Step 8: Install Tailscale
    print_header_rule
    echo -e "${RED}${BOLD}🔗 STEP 8: Installing Tailscale${NC}"
    print_header_rule
    run_remote_script "https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/tools/Tailscale.sh"

    # Summary
    print_header_rule
    echo -e "${GREEN}${BOLD}🎉 AARYAN PRESET - INSTALLATION COMPLETE! 🎉${NC}"
    print_header_rule
    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║           📋 INSTALLATION SUMMARY            ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║ ${GREEN}Panel URL:${NC} ${WHITE}https://${PRESET_DOMAIN}${NC}${WHITE}                  ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Username:${NC} ${WHITE}${PRESET_USERNAME}${NC}${WHITE}                          ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Password:${NC} ${WHITE}${PRESET_PASSWORD}${NC}${WHITE}                         ║${NC}"
    echo -e "${WHITE}║ ${GREEN}Database:${NC} ${WHITE}${PRESET_DB_NAME}${NC}${WHITE}                           ║${NC}"
    echo -e "${WHITE}║ ${GREEN}DB User:${NC} ${WHITE}${PRESET_DB_USER}${NC}${WHITE}                        ║${NC}"
    echo -e "${WHITE}║ ${GREEN}DB Pass:${NC} ${WHITE}${PRESET_DB_PASS}${NC}${WHITE}         ║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${YELLOW}${BOLD}⚠️  IMPORTANT:${NC}"
    echo -e "${WHITE}- Save these credentials securely${NC}"
    echo -e "${WHITE}- Run 'sudo ufw allow 443/tcp' if firewall is enabled${NC}"
    echo -e "${WHITE}- Use 'nginx -t' to verify nginx configuration${NC}"
    
    print_header_rule
    echo -e "${RED}           Thank you for using Aaryan Tools!       ${NC}"
    print_header_rule
    
    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function for combined Blueprint+Theme+Extensions menu
blueprint_theme_menu() {
    while true; do
        clear
        print_header_rule
        echo -e "${RED}           🔧 BLUEPRINT + THEME + EXTENSIONS            ${NC}"
        print_header_rule
        big_header "BLUEPRINT+THEME+EXTENSIONS"
        print_header_rule

        echo -e "${WHITE}${BOLD}  1)${NC} ${RED}${BOLD}Blueprint Setup${NC}"
        echo -e "${WHITE}${BOLD}  2)${NC} ${RED}${BOLD}Themes + Extensions${NC}"
        echo -e "${WHITE}${BOLD}  0)${NC} ${RED}${BOLD}Back to Main Menu${NC}"

        print_header_rule
        echo -e "${YELLOW}${BOLD}📝 Select an option [0-2]: ${NC}"
        read -r subchoice

        case $subchoice in
            1)
                run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/Blueprint2.sh"
                ;;
            2)
                print_header_rule
                big_header "WELCOME"
                print_header_rule
                echo -e "${RED}Running: ${BOLD}Themes + Extensions${NC}"
                print_header_rule
                print_status "Installing Themes + Extensions"
                bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/thame/chang.sh)
                print_success "Themes + Extensions completed successfully"
                echo -e ""
                read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
                ;;
            0)
                return 0
                ;;
            *)
                print_error "Invalid option! Please choose between 0-2"
                sleep 1.2
                ;;
        esac
    done
}

# Function to show system info
system_info() {
    print_header_rule
    big_header "SYSTEM INFORMATION"
    print_header_rule

    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║               📊 SYSTEM STATUS               ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}Hostname:${NC} ${WHITE}$(hostname)${NC}                  ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}User:${NC} ${WHITE}$(whoami)${NC}                          ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}Directory:${NC} ${WHITE}$(pwd)${NC}           ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}System:${NC} ${WHITE}$(uname -srm)${NC}              ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}Uptime:${NC} ${WHITE}$(uptime -p | sed 's/up //')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}Memory:${NC} ${WHITE}$(free -h | awk '/Mem:/ {print $3"/"$2}')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${RED}•${NC} ${GREEN}Disk:${NC} ${WHITE}$(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')${NC}        ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"

    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function to display the main menu
show_menu() {
    clear
    print_header_rule
    echo -e "${RED}           🚀 AARYAN HOSTING MANAGER            ${NC}"
    echo -e "${RED}              made by Aaryan           ${NC}"
    print_header_rule

    big_header "MAIN MENU"
    print_header_rule

    echo -e "${WHITE}${BOLD}  1)${NC} ${RED}${BOLD}Panel Installation${NC}"
    echo -e "${WHITE}${BOLD}  2)${NC} ${RED}${BOLD}Wings Installation${NC}"
    echo -e "${WHITE}${BOLD}  3)${NC} ${RED}${BOLD}Uninstall Tools${NC}"
    echo -e "${WHITE}${BOLD}  4)${NC} ${RED}${BOLD}Blueprint+Theme+Extensions${NC}"
    echo -e "${WHITE}${BOLD}  5)${NC} ${RED}${BOLD}Cloudflare Setup${NC}"
    echo -e "${WHITE}${BOLD}  6)${NC} ${RED}${BOLD}System Information${NC}"
    echo -e "${WHITE}${BOLD}  7)${NC} ${RED}${BOLD}Tailscale (install + up)${NC}"
    echo -e "${WHITE}${BOLD}  8)${NC} ${RED}${BOLD}Database Setup${NC}"
    echo -e "${WHITE}${BOLD}  9)${NC} ${GREEN}${BOLD}⭐ AARYAN PRESET - ONE CLICK ALL SET ⭐${NC}"
    echo -e "${WHITE}${BOLD}  0)${NC} ${RED}${BOLD}Exit${NC}"

    print_header_rule
    echo -e "${YELLOW}${BOLD}📝 Select an option [0-9]: ${NC}"
}

# Welcome animation (RED theme)
welcome_animation() {
    clear
    print_header_rule
    echo -e "${RED}"
cat <<'EOF'
 █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║
███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║
██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║
██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                                                   
EOF
    echo -e "${NC}"
    echo -e "${RED}                   Hosting Manager${NC}"
    print_header_rule
    sleep 1.2
}

# Main loop
welcome_animation

while true; do
    show_menu
    read -r choice

    case $choice in
        1) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/panel2.sh" ;;
        2) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/wing2.sh" ;;
        3) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/uninstall2.sh" ;;
        4) blueprint_theme_menu ;;
        5) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/cloudflare.sh" ;;
        6) system_info ;;
        7) run_remote_script "https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/tools/Tailscale.sh" ;;
        8)
            print_header_rule
            big_header "DATABASE SETUP"
            print_header_rule
            echo -e "${RED}Running: ${BOLD}MySQL / MariaDB Database Setup${NC}"
            print_header_rule

            read -p "Enter new database username: " DB_USER
            read -sp "Enter password for $DB_USER: " DB_PASS
            echo ""
            echo -e "${YELLOW}Creating database user '$DB_USER'...${NC}"

            mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

            CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
            if [ -f "$CONF_FILE" ]; then
                echo -e "${YELLOW}Updating bind-address in $CONF_FILE...${NC}"
                sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$CONF_FILE"
            else
                echo -e "${MAGENTA}⚠️  Config file not found: $CONF_FILE${NC}"
            fi

            echo -e "${YELLOW}Restarting MySQL and MariaDB services...${NC}"
            sudo systemctl restart mysql 2>/dev/null
            sudo systemctl restart mariadb 2>/dev/null

            if command -v ufw &>/dev/null; then
                sudo ufw allow 3306/tcp >/dev/null 2>&1 && echo -e "${GREEN}Opened port 3306 for remote connections${NC}"
            fi

            echo -e "${GREEN}✅ Database user '$DB_USER' created and remote access enabled!${NC}"

            echo -e ""
            read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
            ;;
        9)
            aaryan_preset_all_set
            ;;
        0)
            echo -e "${GREEN}Exiting Aaryan Hosting Manager...${NC}"
            print_header_rule
            echo -e "${RED}           Thank you for using our tools!       ${NC}"
            print_header_rule
            sleep 1
            exit 0
            ;;
        *)
            print_error "Invalid option! Please choose between 0-9"
            sleep 1.2
            ;;
    esac
done
