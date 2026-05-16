const CHAINCACAO_LINKS = {
  app: 'https://drive.google.com/uc?export=download&id=1yqeNHY1xuwYdyQgRzzNIwYxd6z_wXClu',
  dashboard: 'https://web-tresor1hs-projects.vercel.app',
  verifier: 'https://chaincacao.netlify.app/verifier',
};

function openChainCacaoTarget(target) {
  const href = CHAINCACAO_LINKS[target] || CHAINCACAO_LINKS.dashboard;
  window.location.href = href;
}

/* --- Nav scroll --- */
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  if (navbar) navbar.classList.toggle('scrolled', window.scrollY > 40);
});

/* --- Mobile menu --- */
const hamburger = document.getElementById('hamburger');
const mobileMenu = document.getElementById('mobileMenu');
if (hamburger && mobileMenu) {
  hamburger.addEventListener('click', () => {
    mobileMenu.classList.toggle('open');
  });
}

document.querySelectorAll('#mobileMenu a').forEach(link => {
  link.addEventListener('click', () => {
    if (mobileMenu) mobileMenu.classList.remove('open');
  });
});

/* --- Scroll reveal --- */
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.15 });

document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

/* --- Animated counters --- */
function animateCounter(el) {
  const target = parseInt(el.dataset.target, 10) || 0;
  const suffix = el.dataset.suffix || '';
  const duration = 2000;
  const start = performance.now();

  function format(val) {
    if (target >= 100000) return Math.round(val / 1000) + 'K';
    if (target >= 10000) return Math.round(val / 1000) + 'K';
    return Math.round(val).toLocaleString('fr-FR');
  }

  function step(now) {
    const elapsed = now - start;
    const progress = Math.min(elapsed / duration, 1);
    const ease = 1 - Math.pow(1 - progress, 3);
    const current = target * ease;
    el.textContent = format(current) + suffix;
    if (progress < 1) requestAnimationFrame(step);
  }

  requestAnimationFrame(step);
}

const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      animateCounter(entry.target);
      counterObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.5 });

document.querySelectorAll('.counter').forEach(el => counterObserver.observe(el));

/* --- Access links --- */
function attachRouteLinks() {
  document.querySelectorAll('[data-solution-route]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      openChainCacaoTarget(link.dataset.solutionRoute);
    });
  });
}

function setupHeroCarousel() {
  const track = document.querySelector('.hero-carousel .carousel-track');
  const dotsContainer = document.getElementById('heroCarouselDots');
  const slides = track ? Array.from(track.children) : [];
  if (!track || !slides.length || !dotsContainer) return;

  let current = 0;
  let timer;

  slides.forEach((_, index) => {
    const dot = document.createElement('button');
    dot.className = 'carousel-dot' + (index === 0 ? ' active' : '');
    dot.setAttribute('aria-label', `Slide ${index + 1}`);
    dot.addEventListener('click', () => goTo(index));
    dotsContainer.appendChild(dot);
  });

  function goTo(index) {
    current = (index + slides.length) % slides.length;
    track.style.transform = `translateX(-${current * 100}%)`;
    dotsContainer.querySelectorAll('.carousel-dot').forEach((dot, idx) => {
      dot.classList.toggle('active', idx === current);
    });
    resetTimer();
  }

  function resetTimer() {
    clearInterval(timer);
    timer = setInterval(() => goTo(current + 1), 4500);
  }

  const carousel = document.getElementById('heroCarousel');
  if (carousel) {
    carousel.addEventListener('mouseenter', () => clearInterval(timer));
    carousel.addEventListener('mouseleave', resetTimer);
  }

  resetTimer();
}

document.addEventListener('DOMContentLoaded', () => {
  attachRouteLinks();
  setupHeroCarousel();
});

