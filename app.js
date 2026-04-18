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
