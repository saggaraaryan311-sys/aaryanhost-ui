# ⬡ NexaHost UI — Professional Hosting Website

A stunning, production-grade game server hosting landing page built for use with Pterodactyl Panel.

---

## 🚀 One-Command Install

```bash
curl -sSL https://raw.githubusercontent.com/YOURUSERNAME/nexahost-ui/main/install.sh | sudo bash
```

### With custom domain:
```bash
curl -sSL https://raw.githubusercontent.com/YOURUSERNAME/nexahost-ui/main/install.sh | sudo bash -s -- --domain=yoursite.com
```

### With SSL (Let's Encrypt):
```bash
curl -sSL https://raw.githubusercontent.com/YOURUSERNAME/nexahost-ui/main/install.sh | sudo bash -s -- --domain=yoursite.com --ssl
```

### All options:
```
--domain=example.com    Your domain name
--port=8080             Custom port (default: 80)
--ssl                   Enable SSL with Certbot (requires domain)
--dir=/custom/path      Custom install directory
```

---

## 📦 What's Included

| File | Description |
|------|-------------|
| `index.html` | Full landing page |
| `assets/style.css` | All CSS (dark theme, responsive) |
| `assets/app.js` | Particles, counters, FAQ, pricing toggle |
| `install.sh` | Smart auto-installer (Nginx/Apache) |

---

## ✏️ Customization

### Change branding name
Search and replace `NexaHost` / `NEXAHOST` in `index.html`

### Change pricing (₹)
Edit the `data-monthly` and `data-yearly` values on the `.price-val` elements in `index.html`

### Change locations
Edit the `.location-cards` section in `index.html`

### Link to your Pterodactyl panel
Change all `href="#"` on buttons to your panel URL:
```html
<a href="https://panel.yoursite.com" ...>
```

### Add your Discord
```html
<a href="https://discord.gg/YOURINVITE">Discord</a>
```

---

## 🎨 Sections

- **Navbar** — Sticky, responsive with mobile hamburger menu
- **Hero** — Animated particle canvas, animated counters
- **Games Strip** — Auto-scrolling ticker of supported games
- **Features** — Feature grid with hover effects
- **Pricing** — Monthly/Yearly toggle with billing switch
- **Locations** — Server node cards with live/coming-soon badges
- **Testimonials** — Customer review cards
- **FAQ** — Accordion with smooth open/close
- **CTA** — Call to action section
- **Footer** — Full multi-column footer

---

## 🖥️ Requirements

- Ubuntu 20.04 / 22.04 / Debian 11+
- Nginx or Apache (auto-installed if missing)
- Root access for installer

---

## 📄 License

MIT — Free to use, modify, and redistribute.

---

Made with ❤️ for Indian hosting entrepreneurs 🇮🇳
