#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════╗
# ║   AaryanHost UI — Self-Contained Installer v2.0     ║
# ║   No GitHub required. Just run this script!         ║
# ╚══════════════════════════════════════════════════════╝
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}[AaryanHost]${RESET} $1"; }
ok()   { echo -e "${GREEN}[  OK  ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[ WARN ]${RESET} $1"; }
err()  { echo -e "${RED}[ ERR  ]${RESET} $1"; exit 1; }

echo ""
echo -e "${BOLD}${CYAN}"
echo "   █████╗  █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗  ██╗"
echo "  ██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██╔══██╗████╗ ██║"
echo "  ███████║███████║██████╔╝ ╚████╔╝ ███████║██╔██╗██║"
echo "  ██╔══██║██╔══██║██╔══██╗  ╚██╔╝  ██╔══██║██║╚████║"
echo "  ██║  ██║██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚███║"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚══╝"
echo "              H O S T  -  U I  v2.0"
echo -e "${RESET}"

INSTALL_DIR="/var/www/aaryanhost"
PORT=80
DOMAIN=""
USE_SSL=false

for arg in "$@"; do
  case $arg in
    --domain=*) DOMAIN="${arg#*=}" ;;
    --port=*)   PORT="${arg#*=}"   ;;
    --ssl)      USE_SSL=true       ;;
    --dir=*)    INSTALL_DIR="${arg#*=}" ;;
  esac
done

log "Install dir : $INSTALL_DIR"
log "Port        : $PORT"
[[ -n "$DOMAIN" ]] && log "Domain      : $DOMAIN"

# ── Detect web server ─────────────────────────────────
detect_webserver() {
  if command -v nginx &>/dev/null && systemctl is-active nginx &>/dev/null 2>&1; then
    echo "nginx"
  elif command -v apache2 &>/dev/null && systemctl is-active apache2 &>/dev/null 2>&1; then
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
log "Web server: $WEB_SERVER"

log "Updating packages..."
apt-get update -qq

case $WEB_SERVER in
  none)
    log "Installing Nginx..."
    apt-get install -y -qq nginx
    systemctl enable nginx && systemctl start nginx
    WEB_SERVER="nginx"
    ok "Nginx installed." ;;
  nginx-installed)
    systemctl enable nginx && systemctl start nginx
    WEB_SERVER="nginx" ;;
  apache-installed)
    systemctl enable apache2 && systemctl start apache2
    WEB_SERVER="apache2" ;;
esac

# ── Write files ───────────────────────────────────────
log "Writing site files..."
mkdir -p "$INSTALL_DIR/assets"

cat > "$INSTALL_DIR/assets/style.css" << 'ENDCSS'
/* ═══════════════ ROOT & RESET ═══════════════ */
:root {
  --bg: #050810;
  --bg2: #080d1a;
  --bg3: #0d1526;
  --cyan: #00f5ff;
  --cyan-dim: #00b8c8;
  --orange: #ff6b2b;
  --orange-dim: #cc4e1a;
  --white: #f0f4ff;
  --muted: #8090b0;
  --border: rgba(0,245,255,0.12);
  --border2: rgba(0,245,255,0.06);
  --font-display: 'Orbitron', sans-serif;
  --font-body: 'DM Sans', sans-serif;
  --glow-cyan: 0 0 20px rgba(0,245,255,0.35), 0 0 60px rgba(0,245,255,0.12);
  --glow-orange: 0 0 20px rgba(255,107,43,0.5), 0 0 60px rgba(255,107,43,0.2);
  --radius: 12px;
  --radius-lg: 20px;
}

*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

html { scroll-behavior: smooth; font-size: 16px; }

body {
  background: var(--bg);
  color: var(--white);
  font-family: var(--font-body);
  line-height: 1.6;
  overflow-x: hidden;
}

.container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
.accent { color: var(--cyan); }
a { text-decoration: none; color: inherit; }

/* ═══════════════ SCROLLBAR ═══════════════ */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: var(--bg); }
::-webkit-scrollbar-thumb { background: var(--cyan-dim); border-radius: 3px; }

/* ═══════════════ NAV ═══════════════ */
#navbar {
  position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
  padding: 16px 0;
  background: rgba(5,8,16,0.85);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border2);
  transition: all 0.3s;
}
#navbar.scrolled {
  padding: 10px 0;
  background: rgba(5,8,16,0.97);
  border-bottom-color: var(--border);
}
.nav-inner {
  max-width: 1200px; margin: 0 auto; padding: 0 24px;
  display: flex; align-items: center; justify-content: space-between; gap: 24px;
}
.logo {
  display: flex; align-items: center; gap: 10px;
  font-family: var(--font-display); font-weight: 700; font-size: 1.2rem;
  letter-spacing: 2px;
}
.logo-icon { color: var(--cyan); font-size: 1.4rem; }
.logo-accent { color: var(--cyan); }
.nav-links {
  list-style: none; display: flex; align-items: center; gap: 8px;
}
.nav-links a {
  padding: 8px 14px; font-size: 0.9rem; font-weight: 500;
  color: var(--muted); transition: color 0.2s;
}
.nav-links a:hover { color: var(--white); }
.btn-nav {
  border: 1px solid var(--border) !important;
  border-radius: 8px !important; color: var(--white) !important;
}
.btn-nav:hover { border-color: var(--cyan) !important; color: var(--cyan) !important; }
.btn-glow {
  background: var(--cyan) !important; color: var(--bg) !important;
  border-color: var(--cyan) !important; font-weight: 600 !important;
  box-shadow: var(--glow-cyan);
}
.btn-glow:hover { background: #00dde8 !important; }

.hamburger {
  display: none; flex-direction: column; gap: 5px;
  background: none; border: none; cursor: pointer; padding: 4px;
}
.hamburger span {
  display: block; width: 24px; height: 2px;
  background: var(--white); transition: 0.3s;
}

/* ═══════════════ HERO ═══════════════ */
.hero {
  min-height: 100vh;
  display: flex; align-items: center; justify-content: center;
  position: relative; overflow: hidden; padding: 100px 24px 60px;
}
.hero-grid {
  position: absolute; inset: 0;
  background-image:
    linear-gradient(rgba(0,245,255,0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0,245,255,0.04) 1px, transparent 1px);
  background-size: 60px 60px;
  mask-image: radial-gradient(ellipse at center, black 30%, transparent 80%);
}
#particles { position: absolute; inset: 0; pointer-events: none; }

.hero-content {
  position: relative; z-index: 2;
  text-align: center; max-width: 900px; margin: 0 auto;
}
.hero-badge {
  display: inline-block;
  padding: 8px 20px;
  background: rgba(0,245,255,0.08);
  border: 1px solid rgba(0,245,255,0.25);
  border-radius: 100px;
  font-size: 0.82rem; font-weight: 500; color: var(--cyan);
  letter-spacing: 0.5px; margin-bottom: 32px;
  animation: fadeInDown 0.8s ease both;
}
.hero-title {
  font-family: var(--font-display);
  font-weight: 900; line-height: 1.0;
  margin-bottom: 28px;
  animation: fadeInUp 0.8s ease 0.2s both;
}
.hero-title .line1 { display: block; font-size: clamp(2.5rem, 6vw, 4.5rem); color: var(--muted); letter-spacing: 8px; }
.hero-title .line2 { display: block; font-size: clamp(3rem, 8vw, 6.5rem); color: var(--white); letter-spacing: 4px; text-shadow: var(--glow-cyan); }
.hero-title .line3 {
  display: block; font-size: clamp(3rem, 8vw, 6.5rem); letter-spacing: 4px;
  background: linear-gradient(135deg, var(--cyan), var(--orange));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
}
.hero-sub {
  font-size: 1.1rem; color: var(--muted); max-width: 600px; margin: 0 auto 40px;
  animation: fadeInUp 0.8s ease 0.35s both;
}
.hero-actions {
  display: flex; gap: 16px; justify-content: center; flex-wrap: wrap;
  margin-bottom: 64px;
  animation: fadeInUp 0.8s ease 0.5s both;
}
.btn-primary {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 14px 32px; border-radius: var(--radius);
  background: var(--cyan); color: var(--bg);
  font-weight: 700; font-size: 1rem;
  box-shadow: var(--glow-cyan);
  transition: all 0.2s;
}
.btn-primary:hover { background: #00dde8; transform: translateY(-2px); box-shadow: 0 0 40px rgba(0,245,255,0.5), 0 8px 30px rgba(0,245,255,0.2); }
.btn-primary.btn-lg { padding: 18px 44px; font-size: 1.1rem; }
.btn-ghost {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 14px 32px; border-radius: var(--radius);
  border: 1px solid var(--border);
  color: var(--white); font-weight: 600; font-size: 1rem;
  transition: all 0.2s;
}
.btn-ghost:hover { border-color: var(--cyan); color: var(--cyan); }

.hero-stats {
  display: flex; align-items: center; justify-content: center;
  gap: 0; flex-wrap: wrap;
  animation: fadeInUp 0.8s ease 0.65s both;
}
.stat { padding: 16px 40px; text-align: center; }
.stat-num {
  display: block; font-family: var(--font-display); font-size: 2rem;
  font-weight: 700; color: var(--cyan);
}
.stat-label { font-size: 0.8rem; color: var(--muted); letter-spacing: 1px; text-transform: uppercase; }
.stat-divider { width: 1px; height: 50px; background: var(--border); }

.hero-scroll {
  position: absolute; bottom: 32px; left: 50%; transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center; gap: 8px;
  color: var(--muted); font-size: 0.75rem; letter-spacing: 2px;
}
.scroll-line {
  width: 1px; height: 40px;
  background: linear-gradient(to bottom, var(--cyan), transparent);
  animation: scrollPulse 2s ease infinite;
}

/* ═══════════════ GAMES STRIP ═══════════════ */
.games-strip {
  padding: 28px 0;
  background: var(--bg2);
  border-top: 1px solid var(--border2);
  border-bottom: 1px solid var(--border2);
}
.strip-label {
  text-align: center; font-size: 0.75rem;
  text-transform: uppercase; letter-spacing: 3px;
  color: var(--muted); margin-bottom: 16px;
}
.games-ticker { overflow: hidden; position: relative; }
.games-ticker::before, .games-ticker::after {
  content: ''; position: absolute; top: 0; bottom: 0; width: 80px; z-index: 2;
}
.games-ticker::before { left: 0; background: linear-gradient(to right, var(--bg2), transparent); }
.games-ticker::after { right: 0; background: linear-gradient(to left, var(--bg2), transparent); }
.ticker-inner {
  display: flex; gap: 48px;
  animation: ticker 30s linear infinite;
  width: max-content;
}
.ticker-inner span {
  white-space: nowrap; font-size: 0.9rem;
  color: var(--muted); font-weight: 500;
  transition: color 0.2s;
}
.ticker-inner span:hover { color: var(--cyan); }

/* ═══════════════ SECTION HEADER ═══════════════ */
.section-header { text-align: center; margin-bottom: 60px; }
.section-tag {
  display: inline-block; padding: 5px 16px;
  background: rgba(0,245,255,0.08); border: 1px solid rgba(0,245,255,0.2);
  border-radius: 100px; font-size: 0.78rem;
  color: var(--cyan); letter-spacing: 2px; text-transform: uppercase;
  margin-bottom: 16px;
}
.section-header h2 {
  font-family: var(--font-display); font-size: clamp(2rem, 4vw, 3rem);
  font-weight: 700; letter-spacing: 1px; margin-bottom: 16px;
}
.section-header p { color: var(--muted); font-size: 1.05rem; max-width: 500px; margin: 0 auto; }

/* ═══════════════ FEATURES ═══════════════ */
.features { padding: 120px 0; background: var(--bg); }
.features-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.feat-card {
  background: var(--bg2); border: 1px solid var(--border2);
  border-radius: var(--radius-lg); padding: 32px;
  position: relative; overflow: hidden;
  transition: all 0.3s; cursor: default;
}
.feat-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 1px;
  background: linear-gradient(90deg, transparent, var(--cyan), transparent);
  opacity: 0; transition: opacity 0.3s;
}
.feat-card:hover { border-color: rgba(0,245,255,0.25); transform: translateY(-4px); }
.feat-card:hover::before { opacity: 1; }
.feat-large { grid-column: span 2; }
.feat-right { grid-column: 2 / span 2; }
.feat-icon { font-size: 2rem; margin-bottom: 16px; }
.feat-card h3 { font-family: var(--font-display); font-size: 1rem; font-weight: 600; letter-spacing: 1px; margin-bottom: 12px; }
.feat-card p { color: var(--muted); font-size: 0.92rem; line-height: 1.7; }
.feat-card code { background: rgba(0,245,255,0.1); color: var(--cyan); padding: 2px 6px; border-radius: 4px; font-size: 0.82rem; }
.feat-tag {
  display: inline-block; margin-top: 16px;
  padding: 4px 12px; border-radius: 100px;
  background: rgba(0,245,255,0.1); border: 1px solid rgba(0,245,255,0.2);
  font-size: 0.75rem; color: var(--cyan); letter-spacing: 1px;
}
.feat-location-grid {
  display: flex; flex-wrap: wrap; gap: 8px; margin-top: 20px;
}
.feat-location-grid span {
  padding: 4px 12px; background: rgba(255,255,255,0.04);
  border: 1px solid var(--border); border-radius: 100px;
  font-size: 0.8rem; color: var(--muted);
}

/* ═══════════════ PRICING ═══════════════ */
.pricing { padding: 120px 0; background: var(--bg2); }
.billing-toggle {
  display: flex; align-items: center; justify-content: center; gap: 16px;
  margin-bottom: 56px;
}
.toggle-label { font-size: 0.95rem; color: var(--muted); font-weight: 500; }
.toggle-switch { position: relative; width: 52px; height: 28px; cursor: pointer; }
.toggle-switch input { opacity: 0; width: 0; height: 0; }
.toggle-slider {
  position: absolute; inset: 0; background: var(--bg3);
  border: 1px solid var(--border); border-radius: 100px;
  transition: 0.3s;
}
.toggle-slider::before {
  content: ''; position: absolute;
  width: 20px; height: 20px; border-radius: 50%;
  left: 3px; top: 50%; transform: translateY(-50%);
  background: var(--muted); transition: 0.3s;
}
.toggle-switch input:checked + .toggle-slider { background: rgba(0,245,255,0.15); border-color: var(--cyan); }
.toggle-switch input:checked + .toggle-slider::before { transform: translate(24px, -50%); background: var(--cyan); }
.save-badge {
  background: rgba(255,107,43,0.15); border: 1px solid rgba(255,107,43,0.3);
  color: var(--orange); padding: 2px 8px; border-radius: 100px;
  font-size: 0.72rem; font-weight: 600; letter-spacing: 1px;
  margin-left: 6px; vertical-align: middle;
}

.plans-grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;
}
.plan-card {
  background: var(--bg3); border: 1px solid var(--border2);
  border-radius: var(--radius-lg); padding: 32px 28px;
  position: relative; transition: all 0.3s;
  display: flex; flex-direction: column;
}
.plan-card:hover { border-color: rgba(0,245,255,0.2); transform: translateY(-6px); }
.plan-popular {
  border-color: rgba(0,245,255,0.4) !important;
  background: linear-gradient(180deg, rgba(0,245,255,0.06), var(--bg3)) !important;
  box-shadow: var(--glow-cyan);
}
.plan-custom { border-color: rgba(255,107,43,0.25) !important; }
.popular-badge {
  position: absolute; top: -14px; left: 50%; transform: translateX(-50%);
  padding: 5px 16px; border-radius: 100px;
  background: var(--cyan); color: var(--bg);
  font-size: 0.75rem; font-weight: 700; letter-spacing: 1px; white-space: nowrap;
}
.plan-name {
  font-family: var(--font-display); font-size: 1.1rem;
  font-weight: 700; letter-spacing: 2px; margin-bottom: 4px;
}
.plan-game { font-size: 0.82rem; color: var(--muted); margin-bottom: 20px; }
.plan-price {
  font-family: var(--font-display); font-size: 2.4rem;
  font-weight: 700; color: var(--cyan); line-height: 1;
  margin-bottom: 28px;
}
.plan-price sup { font-size: 1rem; top: -10px; position: relative; }
.plan-price sub { font-size: 0.9rem; color: var(--muted); font-family: var(--font-body); font-weight: 400; }
.custom-price { font-size: 1.4rem; color: var(--orange); }
.plan-features {
  list-style: none; flex: 1;
  display: flex; flex-direction: column; gap: 10px;
  margin-bottom: 32px;
}
.plan-features li { font-size: 0.88rem; color: var(--muted); }
.plan-features li:first-child { color: var(--white); }
.plan-btn {
  display: block; text-align: center;
  padding: 13px; border-radius: var(--radius);
  border: 1px solid var(--border); color: var(--white);
  font-weight: 600; font-size: 0.92rem;
  transition: all 0.2s;
}
.plan-btn:hover { border-color: var(--cyan); color: var(--cyan); }
.plan-btn-glow {
  background: var(--cyan) !important; color: var(--bg) !important;
  border-color: var(--cyan) !important; box-shadow: var(--glow-cyan);
}
.plan-btn-glow:hover { background: #00dde8 !important; }

/* ═══════════════ LOCATIONS ═══════════════ */
.locations { padding: 100px 0; background: var(--bg); }
.location-cards {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;
}
.loc-card {
  display: flex; align-items: center; gap: 14px;
  padding: 18px 20px; border-radius: var(--radius);
  background: var(--bg2); border: 1px solid var(--border2);
  transition: all 0.25s; cursor: default;
}
.loc-card:hover { border-color: rgba(0,245,255,0.25); transform: translateY(-2px); }
.flag { font-size: 1.5rem; }
.loc-card strong { display: block; font-size: 0.92rem; font-weight: 600; }
.loc-card small { font-size: 0.78rem; color: var(--muted); }
.loc-ping {
  margin-left: auto; padding: 3px 9px; border-radius: 100px;
  font-size: 0.7rem; font-weight: 700; letter-spacing: 1px;
  background: rgba(0,255,128,0.12); color: #00ff88;
  border: 1px solid rgba(0,255,128,0.25);
}
.coming { opacity: 0.5; }
.coming-ping { background: rgba(255,107,43,0.12) !important; color: var(--orange) !important; border-color: rgba(255,107,43,0.25) !important; }

/* ═══════════════ TESTIMONIALS ═══════════════ */
.testimonials { padding: 100px 0; background: var(--bg2); }
.testi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
.testi-card {
  background: var(--bg3); border: 1px solid var(--border2);
  border-radius: var(--radius-lg); padding: 32px;
  transition: transform 0.3s;
}
.testi-card:hover { transform: translateY(-4px); }
.testi-featured { border-color: rgba(0,245,255,0.3); background: linear-gradient(135deg, rgba(0,245,255,0.05), var(--bg3)); }
.stars { color: #ffd700; font-size: 1rem; margin-bottom: 16px; letter-spacing: 2px; }
.testi-card p { color: var(--muted); font-size: 0.92rem; line-height: 1.7; margin-bottom: 24px; font-style: italic; }
.testi-author { display: flex; align-items: center; gap: 12px; }
.avatar {
  width: 38px; height: 38px; border-radius: 50%;
  background: linear-gradient(135deg, var(--cyan), var(--orange));
  display: flex; align-items: center; justify-content: center;
  font-weight: 700; color: var(--bg); font-size: 1rem; flex-shrink: 0;
}
.testi-author strong { display: block; font-size: 0.9rem; }
.testi-author small { color: var(--muted); font-size: 0.78rem; }

/* ═══════════════ FAQ ═══════════════ */
.faq { padding: 100px 0; background: var(--bg); }
.faq-inner { display: grid; grid-template-columns: 1fr 2fr; gap: 80px; align-items: start; }
.faq-inner .section-header { text-align: left; }
.faq-list { display: flex; flex-direction: column; gap: 4px; }
.faq-item { border-bottom: 1px solid var(--border2); }
.faq-q {
  width: 100%; text-align: left; background: none; border: none;
  padding: 20px 0; cursor: pointer;
  display: flex; justify-content: space-between; align-items: center;
  font-size: 0.95rem; font-weight: 500; color: var(--white);
  font-family: var(--font-body);
  transition: color 0.2s;
}
.faq-q:hover { color: var(--cyan); }
.faq-arrow { font-size: 1.1rem; color: var(--cyan); transition: transform 0.3s; }
.faq-item.open .faq-arrow { transform: rotate(180deg); }
.faq-a { display: none; padding: 0 0 20px; }
.faq-item.open .faq-a { display: block; }
.faq-a p { color: var(--muted); font-size: 0.92rem; line-height: 1.8; }

/* ═══════════════ CTA ═══════════════ */
.cta-section {
  padding: 100px 0; background: var(--bg2);
  position: relative; overflow: hidden; text-align: center;
}
.cta-glow {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
  width: 600px; height: 300px;
  background: radial-gradient(ellipse, rgba(0,245,255,0.08), transparent 70%);
  pointer-events: none;
}
.cta-inner { position: relative; z-index: 1; }
.cta-inner h2 { font-family: var(--font-display); font-size: clamp(2rem, 4vw, 3rem); font-weight: 700; margin-bottom: 16px; }
.cta-inner p { color: var(--muted); margin-bottom: 40px; font-size: 1.05rem; }

/* ═══════════════ FOOTER ═══════════════ */
.footer { background: var(--bg); border-top: 1px solid var(--border2); padding: 80px 0 0; }
.footer-grid {
  display: grid; grid-template-columns: 2fr 1fr 1fr 1fr 1fr;
  gap: 40px; margin-bottom: 60px;
}
.footer-brand .logo { margin-bottom: 16px; display: inline-flex; }
.footer-brand p { color: var(--muted); font-size: 0.88rem; line-height: 1.7; margin-bottom: 20px; }
.social-links { display: flex; gap: 12px; }
.social-links a {
  padding: 8px 14px; border: 1px solid var(--border2); border-radius: 8px;
  font-size: 0.82rem; color: var(--muted);
  transition: all 0.2s;
}
.social-links a:hover { border-color: var(--cyan); color: var(--cyan); }
.footer-col h4 {
  font-family: var(--font-display); font-size: 0.78rem;
  font-weight: 600; letter-spacing: 2px; color: var(--white);
  margin-bottom: 20px; text-transform: uppercase;
}
.footer-col a {
  display: block; color: var(--muted); font-size: 0.88rem;
  margin-bottom: 10px; transition: color 0.2s;
}
.footer-col a:hover { color: var(--cyan); }
.footer-bottom {
  border-top: 1px solid var(--border2); padding: 24px 0;
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: 16px;
}
.footer-bottom p { color: var(--muted); font-size: 0.82rem; }
.footer-badges { display: flex; gap: 16px; }
.footer-badges span { font-size: 0.78rem; color: var(--muted); }

/* ═══════════════ ANIMATIONS ═══════════════ */
@keyframes fadeInDown {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes ticker {
  from { transform: translateX(0); }
  to { transform: translateX(-50%); }
}
@keyframes scrollPulse {
  0%, 100% { opacity: 1; height: 40px; }
  50% { opacity: 0.3; height: 20px; }
}

/* ═══════════════ REVEAL ═══════════════ */
.reveal { opacity: 0; transform: translateY(30px); transition: all 0.7s ease; }
.reveal.visible { opacity: 1; transform: translateY(0); }

/* ═══════════════ RESPONSIVE ═══════════════ */
@media (max-width: 1100px) {
  .plans-grid { grid-template-columns: repeat(2, 1fr); }
  .features-grid { grid-template-columns: repeat(2, 1fr); }
  .feat-large, .feat-right { grid-column: span 2; }
  .footer-grid { grid-template-columns: 1fr 1fr 1fr; }
  .footer-brand { grid-column: 1/-1; }
}

@media (max-width: 800px) {
  .nav-links { display: none; flex-direction: column; position: fixed; top: 64px; right: 0; width: 100%; background: var(--bg); padding: 20px; border-top: 1px solid var(--border2); gap: 4px; }
  .nav-links.open { display: flex; }
  .hamburger { display: flex; }
  .features-grid { grid-template-columns: 1fr; }
  .feat-large, .feat-right { grid-column: span 1; }
  .plans-grid { grid-template-columns: 1fr; }
  .testi-grid { grid-template-columns: 1fr; }
  .location-cards { grid-template-columns: repeat(2, 1fr); }
  .faq-inner { grid-template-columns: 1fr; gap: 40px; }
  .hero-stats { gap: 0; }
  .stat { padding: 12px 20px; }
  .stat-divider { height: 30px; }
  .footer-grid { grid-template-columns: 1fr 1fr; }
  .footer-brand { grid-column: 1/-1; }
  .footer-bottom { flex-direction: column; text-align: center; }
}

@media (max-width: 500px) {
  .location-cards { grid-template-columns: 1fr; }
  .hero-stats { flex-direction: column; }
  .stat-divider { display: none; }
}
ENDCSS
ok "style.css written."
cat > "$INSTALL_DIR/assets/app.js" << 'ENDJS'
/* ═══════════════ APP.JS ═══════════════ */

// ── Navbar scroll effect ──────────────────────────
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 50);
});

// ── Hamburger menu ────────────────────────────────
const hamburger = document.getElementById('hamburger');
const navLinks  = document.getElementById('navLinks');
hamburger.addEventListener('click', () => {
  navLinks.classList.toggle('open');
  hamburger.classList.toggle('active');
});
document.querySelectorAll('.nav-links a').forEach(a => {
  a.addEventListener('click', () => {
    navLinks.classList.remove('open');
    hamburger.classList.remove('active');
  });
});

// ── Particle canvas ───────────────────────────────
(function initParticles() {
  const canvas = document.getElementById('particles');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  let W, H, particles = [];

  function resize() {
    W = canvas.width  = canvas.offsetWidth;
    H = canvas.height = canvas.offsetHeight;
  }
  resize();
  window.addEventListener('resize', resize);

  function rand(min, max) { return Math.random() * (max - min) + min; }

  class Particle {
    constructor() { this.reset(); }
    reset() {
      this.x = rand(0, W);
      this.y = rand(0, H);
      this.r = rand(0.5, 2);
      this.vx = rand(-0.3, 0.3);
      this.vy = rand(-0.5, -0.1);
      this.alpha = rand(0.1, 0.5);
      this.cyan = Math.random() > 0.5;
    }
    update() {
      this.x += this.vx;
      this.y += this.vy;
      if (this.y < -5) this.reset();
    }
    draw() {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = this.cyan
        ? `rgba(0,245,255,${this.alpha})`
        : `rgba(255,107,43,${this.alpha * 0.5})`;
      ctx.fill();
    }
  }

  for (let i = 0; i < 80; i++) particles.push(new Particle());

  function loop() {
    ctx.clearRect(0, 0, W, H);
    particles.forEach(p => { p.update(); p.draw(); });
    requestAnimationFrame(loop);
  }
  loop();
})();

// ── Counter animation ─────────────────────────────
function animateCounter(el) {
  const target = parseInt(el.dataset.target, 10);
  const duration = 1800;
  const start = performance.now();
  function step(now) {
    const elapsed = now - start;
    const progress = Math.min(elapsed / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    el.textContent = Math.floor(eased * target).toLocaleString();
    if (progress < 1) requestAnimationFrame(step);
    else el.textContent = target.toLocaleString();
  }
  requestAnimationFrame(step);
}

const countersObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      animateCounter(e.target);
      countersObserver.unobserve(e.target);
    }
  });
}, { threshold: 0.3 });

document.querySelectorAll('.stat-num').forEach(el => countersObserver.observe(el));

// ── Scroll reveal ─────────────────────────────────
function addReveal() {
  const selectors = [
    '.feat-card', '.plan-card', '.loc-card',
    '.testi-card', '.faq-item', '.section-header'
  ];
  selectors.forEach(sel => {
    document.querySelectorAll(sel).forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = `${(i % 4) * 80}ms`;
    });
  });
}

addReveal();

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      revealObserver.unobserve(e.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

// ── Billing toggle ────────────────────────────────
const billingToggle = document.getElementById('billingToggle');
if (billingToggle) {
  billingToggle.addEventListener('change', function () {
    const yearly = this.checked;
    document.querySelectorAll('.price-val').forEach(el => {
      el.textContent = yearly ? el.dataset.yearly : el.dataset.monthly;
    });
    document.getElementById('labelMonthly').style.color = yearly ? '#8090b0' : '#f0f4ff';
    document.getElementById('labelYearly').style.color  = yearly ? '#f0f4ff' : '#8090b0';
  });
}

// ── FAQ accordion ─────────────────────────────────
document.querySelectorAll('.faq-q').forEach(btn => {
  btn.addEventListener('click', () => {
    const item = btn.parentElement;
    const isOpen = item.classList.contains('open');
    // Close all
    document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));
    // Open clicked if it was closed
    if (!isOpen) item.classList.add('open');
  });
});

// ── Smooth anchor scroll ──────────────────────────
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});
ENDJS
ok "app.js written."
cat > "$INSTALL_DIR/index.html" << 'ENDHTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>NexaHost — Game Server Hosting</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;700;900&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="assets/style.css" />
</head>
<body>

  <!-- ═══════════════════════════ NAV ═══════════════════════════ -->
  <nav id="navbar">
    <div class="nav-inner">
      <a href="#" class="logo">
        <span class="logo-icon">⬡</span>
        <span class="logo-text">NEXA<span class="logo-accent">HOST</span></span>
      </a>
      <ul class="nav-links" id="navLinks">
        <li><a href="#features">Features</a></li>
        <li><a href="#pricing">Pricing</a></li>
        <li><a href="#locations">Locations</a></li>
        <li><a href="#faq">FAQ</a></li>
        <li><a href="#" class="btn-nav">Login</a></li>
        <li><a href="#pricing" class="btn-nav btn-glow">Get Started</a></li>
      </ul>
      <button class="hamburger" id="hamburger" aria-label="Menu">
        <span></span><span></span><span></span>
      </button>
    </div>
  </nav>

  <!-- ═══════════════════════════ HERO ═══════════════════════════ -->
  <section class="hero" id="home">
    <div class="hero-grid"></div>
    <canvas id="particles"></canvas>
    <div class="hero-content">
      <div class="hero-badge">⚡ 99.99% Uptime SLA · DDoS Protected · Instant Deploy</div>
      <h1 class="hero-title">
        <span class="line1">NEXT-GEN</span>
        <span class="line2">GAME SERVER</span>
        <span class="line3">HOSTING</span>
      </h1>
      <p class="hero-sub">Deploy your Minecraft, Rust, Valheim, or ARK server in under 60 seconds. Powered by NVMe SSDs, protected by enterprise-grade DDoS mitigation.</p>
      <div class="hero-actions">
        <a href="#pricing" class="btn-primary">Deploy Now →</a>
        <a href="#features" class="btn-ghost">See Features</a>
      </div>
      <div class="hero-stats">
        <div class="stat"><span class="stat-num" data-target="12000">0</span>+<div class="stat-label">Active Servers</div></div>
        <div class="stat-divider"></div>
        <div class="stat"><span class="stat-num" data-target="99">0</span>.99%<div class="stat-label">Uptime</div></div>
        <div class="stat-divider"></div>
        <div class="stat"><span class="stat-num" data-target="8">0</span><div class="stat-label">Global Nodes</div></div>
        <div class="stat-divider"></div>
        <div class="stat"><span class="stat-num" data-target="24">0</span>/7<div class="stat-label">Support</div></div>
      </div>
    </div>
    <div class="hero-scroll">
      <div class="scroll-line"></div>
      <span>Scroll</span>
    </div>
  </section>

  <!-- ═══════════════════════════ GAMES ═══════════════════════════ -->
  <section class="games-strip">
    <div class="container">
      <p class="strip-label">Supported Games</p>
      <div class="games-ticker">
        <div class="ticker-inner">
          <span>⛏ Minecraft</span>
          <span>🔫 CS2</span>
          <span>🦀 Rust</span>
          <span>🐉 ARK</span>
          <span>🧟 Valheim</span>
          <span>🚀 Satisfactory</span>
          <span>🌍 7 Days to Die</span>
          <span>🏹 DayZ</span>
          <span>🔮 Terraria</span>
          <span>⚡ Palworld</span>
          <span>🏔 Squad</span>
          <span>🎮 FiveM</span>
          <!-- duplicate for seamless loop -->
          <span>⛏ Minecraft</span>
          <span>🔫 CS2</span>
          <span>🦀 Rust</span>
          <span>🐉 ARK</span>
          <span>🧟 Valheim</span>
          <span>🚀 Satisfactory</span>
          <span>🌍 7 Days to Die</span>
          <span>🏹 DayZ</span>
          <span>🔮 Terraria</span>
          <span>⚡ Palworld</span>
          <span>🏔 Squad</span>
          <span>🎮 FiveM</span>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ FEATURES ═══════════════════════════ -->
  <section class="features" id="features">
    <div class="container">
      <div class="section-header">
        <span class="section-tag">Why NexaHost</span>
        <h2>Built For <span class="accent">Performance</span></h2>
        <p>Every feature engineered to give your players the smoothest experience possible.</p>
      </div>
      <div class="features-grid">

        <div class="feat-card feat-large">
          <div class="feat-icon">🛡️</div>
          <h3>Enterprise DDoS Shield</h3>
          <p>Up to 1Tbps+ mitigation on every plan. Volumetric, protocol, and application-layer attacks blocked automatically — zero downtime for your players.</p>
          <div class="feat-tag">Always On</div>
        </div>

        <div class="feat-card">
          <div class="feat-icon">⚡</div>
          <h3>NVMe SSD Storage</h3>
          <p>Gen4 NVMe drives with 7,000 MB/s read speeds. World loads in seconds, not minutes.</p>
        </div>

        <div class="feat-card">
          <div class="feat-icon">🎮</div>
          <h3>Pterodactyl Panel</h3>
          <p>Sleek custom-branded control panel. One-click installs, file manager, console, backups — all in one place.</p>
        </div>

        <div class="feat-card">
          <div class="feat-icon">🔄</div>
          <h3>Instant Backups</h3>
          <p>Schedule automated backups or trigger them manually. Restore in one click, any time.</p>
        </div>

        <div class="feat-card feat-large feat-right">
          <div class="feat-icon">🌐</div>
          <h3>Global Low-Latency Network</h3>
          <p>8 nodes across 4 continents. Players connect to the closest node automatically. Sub-20ms ping for most regions.</p>
          <div class="feat-location-grid">
            <span>🇮🇳 Mumbai</span>
            <span>🇸🇬 Singapore</span>
            <span>🇩🇪 Frankfurt</span>
            <span>🇺🇸 New York</span>
            <span>🇺🇸 LA</span>
            <span>🇧🇷 São Paulo</span>
            <span>🇦🇺 Sydney</span>
            <span>🇬🇧 London</span>
          </div>
        </div>

        <div class="feat-card">
          <div class="feat-icon">📊</div>
          <h3>Real-Time Analytics</h3>
          <p>CPU, RAM, network graphs. Player count tracking. Performance alerts via Discord or email.</p>
        </div>

        <div class="feat-card">
          <div class="feat-icon">🤖</div>
          <h3>Auto-Scaling RAM</h3>
          <p>Burst RAM available on demand. No crashes during peak hours or modded server spikes.</p>
        </div>

        <div class="feat-card">
          <div class="feat-icon">🔌</div>
          <h3>Custom Subdomains</h3>
          <p>Free <code>play.yourserver.nexahost.gg</code> subdomain or connect your own domain with SRV records.</p>
        </div>

      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ PRICING ═══════════════════════════ -->
  <section class="pricing" id="pricing">
    <div class="container">
      <div class="section-header">
        <span class="section-tag">Pricing</span>
        <h2>Simple, Transparent <span class="accent">Plans</span></h2>
        <p>No hidden fees. Cancel anytime. All plans include DDoS protection & 24/7 support.</p>
      </div>

      <div class="billing-toggle">
        <span class="toggle-label" id="labelMonthly">Monthly</span>
        <label class="toggle-switch">
          <input type="checkbox" id="billingToggle" />
          <span class="toggle-slider"></span>
        </label>
        <span class="toggle-label" id="labelYearly">Yearly <span class="save-badge">Save 20%</span></span>
      </div>

      <div class="plans-grid">

        <div class="plan-card">
          <div class="plan-name">Dirt</div>
          <div class="plan-game">Perfect for small SMP</div>
          <div class="plan-price">
            <sup>₹</sup><span class="price-val" data-monthly="149" data-yearly="119">149</span><sub>/mo</sub>
          </div>
          <ul class="plan-features">
            <li>✓ 2 GB RAM</li>
            <li>✓ 2 vCPU Cores</li>
            <li>✓ 15 GB NVMe SSD</li>
            <li>✓ 3 Player Slots (unlimited on Minecraft)</li>
            <li>✓ DDoS Protection</li>
            <li>✓ 1 Database</li>
            <li>✓ Daily Backups</li>
            <li>✗ Dedicated IP</li>
          </ul>
          <a href="#" class="plan-btn">Order Now</a>
        </div>

        <div class="plan-card plan-popular">
          <div class="popular-badge">⭐ Most Popular</div>
          <div class="plan-name">Diamond</div>
          <div class="plan-game">Best for growing servers</div>
          <div class="plan-price">
            <sup>₹</sup><span class="price-val" data-monthly="349" data-yearly="279">349</span><sub>/mo</sub>
          </div>
          <ul class="plan-features">
            <li>✓ 6 GB RAM</li>
            <li>✓ 4 vCPU Cores</li>
            <li>✓ 40 GB NVMe SSD</li>
            <li>✓ Unlimited Player Slots</li>
            <li>✓ DDoS Protection</li>
            <li>✓ 5 Databases</li>
            <li>✓ Hourly Backups</li>
            <li>✓ Free Dedicated IP</li>
          </ul>
          <a href="#" class="plan-btn plan-btn-glow">Order Now</a>
        </div>

        <div class="plan-card">
          <div class="plan-name">Netherite</div>
          <div class="plan-game">For large networks</div>
          <div class="plan-price">
            <sup>₹</sup><span class="price-val" data-monthly="799" data-yearly="639">799</span><sub>/mo</sub>
          </div>
          <ul class="plan-features">
            <li>✓ 16 GB RAM</li>
            <li>✓ 8 vCPU Cores</li>
            <li>✓ 100 GB NVMe SSD</li>
            <li>✓ Unlimited Player Slots</li>
            <li>✓ Enterprise DDoS Protection</li>
            <li>✓ Unlimited Databases</li>
            <li>✓ Continuous Backups</li>
            <li>✓ Dedicated IP + Port</li>
          </ul>
          <a href="#" class="plan-btn">Order Now</a>
        </div>

        <div class="plan-card plan-custom">
          <div class="plan-name">⚙️ Custom</div>
          <div class="plan-game">Dedicated bare-metal</div>
          <div class="plan-price custom-price">Let's Talk</div>
          <ul class="plan-features">
            <li>✓ 32–256 GB RAM</li>
            <li>✓ Dedicated CPU</li>
            <li>✓ 2–10 TB NVMe RAID</li>
            <li>✓ Multiple Game Servers</li>
            <li>✓ Priority Support SLA</li>
            <li>✓ Custom Panel Branding</li>
            <li>✓ BGP Anycast DDoS</li>
            <li>✓ Managed Setup</li>
          </ul>
          <a href="#" class="plan-btn">Contact Sales</a>
        </div>

      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ LOCATIONS ═══════════════════════════ -->
  <section class="locations" id="locations">
    <div class="container">
      <div class="section-header">
        <span class="section-tag">Global Network</span>
        <h2>8 Nodes, <span class="accent">4 Continents</span></h2>
        <p>Choose the node closest to your players for the lowest ping.</p>
      </div>
      <div class="location-cards">
        <div class="loc-card active"><span class="flag">🇮🇳</span><div><strong>Mumbai</strong><small>Asia South · ~5ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇸🇬</span><div><strong>Singapore</strong><small>Asia SEA · ~18ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇩🇪</span><div><strong>Frankfurt</strong><small>Europe · ~12ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇬🇧</span><div><strong>London</strong><small>Europe · ~8ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇺🇸</span><div><strong>New York</strong><small>US East · ~6ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇺🇸</span><div><strong>Los Angeles</strong><small>US West · ~4ms</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card active"><span class="flag">🇧🇷</span><div><strong>São Paulo</strong><small>South America</small></div><span class="loc-ping">LIVE</span></div>
        <div class="loc-card coming"><span class="flag">🇦🇺</span><div><strong>Sydney</strong><small>Oceania</small></div><span class="loc-ping coming-ping">SOON</span></div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ TESTIMONIALS ═══════════════════════════ -->
  <section class="testimonials" id="reviews">
    <div class="container">
      <div class="section-header">
        <span class="section-tag">Reviews</span>
        <h2>Trusted by <span class="accent">10,000+</span> Server Owners</h2>
      </div>
      <div class="testi-grid">
        <div class="testi-card">
          <div class="stars">★★★★★</div>
          <p>"Migrated from another host and the difference is insane. Zero lag, instant panel response. My 200-player SMP runs perfectly."</p>
          <div class="testi-author"><span class="avatar">S</span><div><strong>Steve_MC</strong><small>Minecraft SMP · 200 Players</small></div></div>
        </div>
        <div class="testi-card testi-featured">
          <div class="stars">★★★★★</div>
          <p>"NexaHost's DDoS protection saved our Rust server during a massive attack. Didn't even notice anything happened. Support responded in 4 minutes."</p>
          <div class="testi-author"><span class="avatar">R</span><div><strong>RustKing_99</strong><small>Rust · 500+ Players</small></div></div>
        </div>
        <div class="testi-card">
          <div class="stars">★★★★★</div>
          <p>"The Pterodactyl panel is clean, fast, and easy to use. Set up our ARK cluster in under 10 minutes. Highly recommend for Indian server owners."</p>
          <div class="testi-author"><span class="avatar">A</span><div><strong>ARKLord</strong><small>ARK Survival · Mumbai Node</small></div></div>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ FAQ ═══════════════════════════ -->
  <section class="faq" id="faq">
    <div class="container faq-inner">
      <div class="section-header">
        <span class="section-tag">FAQ</span>
        <h2>Got <span class="accent">Questions?</span></h2>
      </div>
      <div class="faq-list" id="faqList">

        <div class="faq-item">
          <button class="faq-q">How quickly can I deploy a server? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>Instantly! After payment, your server is automatically provisioned and online within 30–60 seconds. You'll receive your panel login via email.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">Which games are supported? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>We support 50+ games including Minecraft (all versions/forks), Rust, Valheim, ARK, CS2, FiveM, Terraria, Palworld, 7 Days to Die, DayZ, Squad and many more. New games are added regularly.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">Do I get full FTP/SFTP access? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>Yes! Every server comes with SFTP access so you can upload mods, plugins, worlds, and custom configs using FileZilla or any SFTP client.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">What DDoS protection do you offer? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>All plans include enterprise-grade DDoS mitigation that can absorb attacks up to 1Tbps+. Protection is always on, automatic, and requires no configuration from your side.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">Can I upgrade/downgrade my plan? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>Absolutely. Upgrades take effect instantly with no data loss. Downgrades are processed at the next billing cycle.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">Do you offer refunds? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>We offer a 72-hour money-back guarantee on your first order. If you're not happy, contact support and we'll refund you — no questions asked.</p></div>
        </div>

        <div class="faq-item">
          <button class="faq-q">What payment methods do you accept? <span class="faq-arrow">↓</span></button>
          <div class="faq-a"><p>We accept UPI, Paytm, Razorpay, PayPal, and all major debit/credit cards. Crypto payments available on request.</p></div>
        </div>

      </div>
    </div>
  </section>

  <!-- ═══════════════════════════ CTA ═══════════════════════════ -->
  <section class="cta-section">
    <div class="cta-glow"></div>
    <div class="container cta-inner">
      <h2>Ready to <span class="accent">Go Live?</span></h2>
      <p>Deploy in 60 seconds. No credit card required for the trial.</p>
      <a href="#pricing" class="btn-primary btn-lg">Start Hosting Today →</a>
    </div>
  </section>

  <!-- ═══════════════════════════ FOOTER ═══════════════════════════ -->
  <footer class="footer">
    <div class="container footer-grid">
      <div class="footer-brand">
        <a href="#" class="logo"><span class="logo-icon">⬡</span><span class="logo-text">NEXA<span class="logo-accent">HOST</span></span></a>
        <p>Next-generation game server hosting. Fast, reliable, and built for gamers.</p>
        <div class="social-links">
          <a href="#">Discord</a>
          <a href="#">Twitter</a>
          <a href="#">GitHub</a>
          <a href="#">Instagram</a>
        </div>
      </div>
      <div class="footer-col">
        <h4>Hosting</h4>
        <a href="#">Minecraft Hosting</a>
        <a href="#">Rust Hosting</a>
        <a href="#">ARK Hosting</a>
        <a href="#">FiveM Hosting</a>
        <a href="#">All Games</a>
      </div>
      <div class="footer-col">
        <h4>Company</h4>
        <a href="#">About Us</a>
        <a href="#">Status Page</a>
        <a href="#">Blog</a>
        <a href="#">Affiliate Program</a>
      </div>
      <div class="footer-col">
        <h4>Support</h4>
        <a href="#">Knowledge Base</a>
        <a href="#">Discord Server</a>
        <a href="#">Submit Ticket</a>
        <a href="#">Contact Us</a>
      </div>
      <div class="footer-col">
        <h4>Legal</h4>
        <a href="#">Terms of Service</a>
        <a href="#">Privacy Policy</a>
        <a href="#">Refund Policy</a>
        <a href="#">Acceptable Use</a>
      </div>
    </div>
    <div class="footer-bottom">
      <p>© 2025 NexaHost. All rights reserved. | Crafted with ❤️ for gamers.</p>
      <div class="footer-badges">
        <span>🛡 DDoS Protected</span>
        <span>🔒 SSL Secured</span>
        <span>⚡ 99.99% Uptime</span>
      </div>
    </div>
  </footer>

  <script src="assets/app.js"></script>
</body>
</html>
ENDHTML
ok "index.html written."

chown -R www-data:www-data "$INSTALL_DIR" 2>/dev/null || true
chmod -R 755 "$INSTALL_DIR"
ok "Permissions set."

# ── Nginx config ──────────────────────────────────────
write_nginx_config() {
  local SERVER_NAME="${DOMAIN:-_}"
  local CONFIG_FILE="/etc/nginx/sites-available/aaryanhost"
  cat > "$CONFIG_FILE" << NGINX
server {
    listen ${PORT};
    listen [::]:${PORT};
    server_name ${SERVER_NAME};
    root ${INSTALL_DIR};
    index index.html;

    gzip on;
    gzip_types text/css application/javascript text/html image/svg+xml;

    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
}
NGINX
  ln -sf "$CONFIG_FILE" /etc/nginx/sites-enabled/aaryanhost
  rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
  nginx -t -q && systemctl reload nginx
  ok "Nginx configured."
}

# ── Apache config ─────────────────────────────────────
write_apache_config() {
  local SERVER_NAME="${DOMAIN:-localhost}"
  local CONFIG_FILE="/etc/apache2/sites-available/aaryanhost.conf"
  cat > "$CONFIG_FILE" << APACHE
<VirtualHost *:${PORT}>
    ServerName ${SERVER_NAME}
    DocumentRoot ${INSTALL_DIR}
    <Directory ${INSTALL_DIR}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
APACHE
  a2ensite aaryanhost.conf &>/dev/null
  a2dissite 000-default.conf &>/dev/null || true
  a2enmod rewrite &>/dev/null
  systemctl reload apache2
  ok "Apache configured."
}

case $WEB_SERVER in
  nginx*)  write_nginx_config  ;;
  apache*) write_apache_config ;;
esac

# ── SSL ───────────────────────────────────────────────
if [[ "$USE_SSL" == true && -n "$DOMAIN" ]]; then
  log "Setting up SSL..."
  if ! command -v certbot &>/dev/null; then
    apt-get install -y -qq certbot python3-certbot-nginx
  fi
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email || \
    warn "SSL failed. Run manually: certbot --nginx -d $DOMAIN"
fi

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║     ✅  INSTALLATION COMPLETE!           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${RESET}"
echo ""
if [[ -n "$DOMAIN" ]]; then
  echo -e "${BOLD}🌐 Live at: ${CYAN}https://${DOMAIN}${RESET}"
else
  echo -e "${BOLD}🌐 Live at: ${CYAN}http://${SERVER_IP}${RESET}"
fi
echo -e "${BOLD}📁 Files:   ${RESET}${INSTALL_DIR}"
echo ""
echo -e "Branding change: ${YELLOW}nano ${INSTALL_DIR}/index.html${RESET}"
echo -e "Find & replace 'NexaHost' / 'NEXAHOST' with your brand name"
echo ""
echo -e "${CYAN}🚀 Good luck with your hosting business!${RESET}"
echo ""
