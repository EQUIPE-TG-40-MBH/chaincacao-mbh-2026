  const CHAINCACAO_LINKS = {
    app: 'https://drive.google.com/uc?export=download&id=1yqeNHY1xuwYdyQgRzzNIwYxd6z_wXClu',
    dashboard: 'https://chaincacao-dashboard.vercel.app',
    verifier: 'https://chaincacao.netlify.app/verifier',
  };

  function openChainCacaoTarget(target) {
    const href = CHAINCACAO_LINKS[target] || CHAINCACAO_LINKS.dashboard;
    window.location.href = href;
  }

  /* --- Nav scroll --- */
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 40);
  });

  /* --- Mobile menu --- */
  const hamburger = document.getElementById('hamburger');
  const mobileMenu = document.getElementById('mobileMenu');
  hamburger.addEventListener('click', () => {
    mobileMenu.classList.toggle('open');
  });
  
  const mobileMenuLinks = document.querySelectorAll('#mobileMenu a');
  mobileMenuLinks.forEach(link => {
    link.addEventListener('click', () => {
      mobileMenu.classList.remove('open');
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

  /* --- Step animation trigger --- */
  const stepObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const steps = document.querySelectorAll('.step-card');
        steps.forEach((step, i) => {
          setTimeout(() => {
            step.classList.add('active');
            setTimeout(() => step.classList.remove('active'), 2000);
          }, i * 600);
        });
        stepObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.3 });
  const stepsSection = document.getElementById('comment-ca-marche');
  if (stepsSection) stepObserver.observe(stepsSection);

  /* --- Animated counters --- */
  function animateCounter(el) {
    const target = parseInt(el.dataset.target);
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

  /* --- Actor cards toggle --- */
  document.querySelectorAll('.actor-card').forEach(card => {
    card.addEventListener('click', () => {
      const wasActive = card.classList.contains('active');
      document.querySelectorAll('.actor-card').forEach(c => c.classList.remove('active'));
      if (!wasActive) card.classList.add('active');
    });
  });

  /* --- Lot simulator --- */
  const LOTS = {
    'CC-TG-2025-004821': {
      valid: true,
      produit: 'Cacao – Criollo Grade A',
      region: 'Kpalimé, Région des Plateaux',
      producteur: 'Kofi Agbenyegan · Coopérative UCOT',
      poids: '2 450 kg',
      date: '12 mars 2025',
      etapes: ['Récolte', 'Validation', 'QR Code', 'Export', 'Livré'],
      hash: '0x3a8f2c91e4b7d056f8a2c7e1b4d9f3a8f2c91e4b7d056f8a2c7e1b4d9f3a8f2c',
    },
    'CC-TG-2025-001337': {
      valid: true,
      produit: 'Café – Arabica Grade 1',
      region: 'Badou, Région des Plateaux',
      producteur: 'Ama Dossou · Coopérative COPLATAF',
      poids: '1 800 kg',
      date: '5 février 2025',
      etapes: ['Récolte', 'Validation', 'QR Code', 'Export', 'En transit'],
      hash: '0x7f1a3d9e2b6c4f8a0e5b7d3a1f9c2e6b8d4a0f7e3c1b9d5a2e8f4c0b6d2a9f',
    },
    'CC-TG-2025-009999': {
      valid: false,
      produit: 'Cacao – Forastero',
      region: 'Atakpamé, Région des Plateaux',
      producteur: 'ID non reconnu',
      poids: '—',
      date: '—',
      etapes: ['Récolte', '⚠ Échec validation', '', '', ''],
      hash: 'NON ENREGISTRÉ SUR LA BLOCKCHAIN',
    },
    'CC-CF-2025-000042': {
      valid: true,
      produit: 'Café – Robusta Grade A',
      region: 'Danyi, Région des Plateaux',
      producteur: 'Mawuena Komi · Coopérative UGFCC',
      poids: '3 100 kg',
      date: '28 janvier 2025',
      etapes: ['Récolte', 'Validation', 'QR Code', 'Export', 'Livré'],
      hash: '0xb2e9f1c4a7d3e8f0b5c2a9e6d1f4b7c0a3e8f2d5b1c9a6f3e0b7d4c2a1f8e5',
    }
  };

  /* --- Lot simulator --- */

  function simulateLot() {
    const id = document.getElementById('simInput').value.trim().toUpperCase();
    const result = document.getElementById('simResult');

    if (!id) {
      result.className = 'sim-result';
      result.innerHTML = '';
      return;
    }

    const lot = LOTS[id];
    const isKnown = !!lot;

    let html = '';

    if (isKnown) {
      const badgeHtml = lot.valid
        ? '<div class="sim-badge-valid">✓ Lot Certifié</div>'
        : '<div class="sim-badge-invalid">✗ Lot Non Conforme</div>';

      const stepsHtml = lot.etapes.map((s, i) => `
        <div class="sim-step-track">
          <div class="sim-step-dot" style="${!s || s.startsWith('⚠') ? 'background:#F87171' : ''}"></div>
          ${i < lot.etapes.length - 1 ? `<div class="sim-step-line" style="${!lot.etapes[i+1] ? 'background:rgba(255,255,255,.15)' : ''}"></div>` : ''}
          <div class="sim-step-label">${s || '—'}</div>
        </div>
      `).join('');

      html = `
        <div class="sim-result-header">
          <div class="sim-lot-id">${id}</div>
          ${badgeHtml}
        </div>
        <div class="sim-steps-track">${stepsHtml}</div>
        <div class="sim-details-grid">
          <div class="sim-detail-item">
            <div class="sim-detail-label">Produit</div>
            <div class="sim-detail-value">${lot.produit}</div>
          </div>
          <div class="sim-detail-item">
            <div class="sim-detail-label">Région d'origine</div>
            <div class="sim-detail-value">${lot.region}</div>
          </div>
          <div class="sim-detail-item">
            <div class="sim-detail-label">Producteur / Coopérative</div>
            <div class="sim-detail-value">${lot.producteur}</div>
          </div>
          <div class="sim-detail-item">
            <div class="sim-detail-label">Poids certifié</div>
            <div class="sim-detail-value">${lot.poids}</div>
          </div>
          <div class="sim-detail-item">
            <div class="sim-detail-label">Date d'enregistrement</div>
            <div class="sim-detail-value">${lot.date}</div>
          </div>
          <div class="sim-detail-item">
            <div class="sim-detail-label">Conformité EUDR</div>
            <div class="sim-detail-value" style="color:${lot.valid ? '#7AC44A' : '#F87171'}">${lot.valid ? '✓ Conforme' : '✗ Non conforme'}</div>
          </div>
        </div>
        <div class="sim-blockchain-hash">
          🔗 Hash blockchain : <span>${lot.hash}</span>
        </div>
      `;
    } else {
      html = `
        <div class="sim-result-header">
          <div class="sim-lot-id">${id}</div>
          <div class="sim-badge-invalid">✗ Lot Introuvable</div>
        </div>
        <p style="color:rgba(255,255,255,.6);font-size:.9rem;margin-bottom:16px">
          Cet identifiant n'est pas enregistré dans la blockchain ChainCacao. Le lot n'a pas encore été tracé, ou l'ID est incorrect.
        </p>
        <div class="sim-blockchain-hash">
          🔗 Hash blockchain : <span>AUCUN ENREGISTREMENT TROUVÉ</span>
        </div>
        <p style="color:rgba(255,255,255,.45);font-size:.78rem;margin-top:16px">
          Essayez : CC-TG-2025-004821 · CC-TG-2025-001337 · CC-CF-2025-000042
        </p>
      `;
    }

    result.innerHTML = html;
    result.className = 'sim-result show';
  }

  // Enter key on sim input
  const simInput = document.getElementById('simInput');
  if (simInput) {
    simInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') simulateLot();
    });
  }

  const btnSimulate = document.getElementById('btnSimulate');
  if (btnSimulate) {
    btnSimulate.addEventListener('click', simulateLot);
  }

  document.querySelectorAll('.sim-example-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      if (simInput) simInput.value = btn.dataset.simId;
      simulateLot();
    });
  });

  /* --- Original image carousel --- */
  // Open dashboard / APK from the buttons
  document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('solutionModal');
    const openModalButtons = [
      document.getElementById('openSolutionModal'),
      document.getElementById('heroSolutionAccess'),
    ].filter(Boolean);

    function openModal() {
      if (!modal) return;
      modal.classList.add('open');
      modal.setAttribute('aria-hidden', 'false');
      document.body.style.overflow = 'hidden';
    }

    function closeModal() {
      if (!modal) return;
      modal.classList.remove('open');
      modal.setAttribute('aria-hidden', 'true');
      document.body.style.overflow = '';
      sessionStorage.setItem('chaincacaoSolutionModalSeen', 'true');
    }

    openModalButtons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        openModal();
      });
    });

    document.querySelectorAll('[data-close-solution]').forEach(btn => {
      btn.addEventListener('click', closeModal);
    });

    document.querySelectorAll('[data-solution-route]').forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        openChainCacaoTarget(link.dataset.solutionRoute);
      });
    });

    if (!sessionStorage.getItem('chaincacaoSolutionModalSeen')) {
      setTimeout(openModal, 700);
    }

    const openDashboardBtn = document.getElementById('openDashboardBtn');
    if (openDashboardBtn) {
      openDashboardBtn.addEventListener('click', (e) => {
        e.preventDefault();
        openChainCacaoTarget('dashboard');
      });
    }

    const downloadApkLink = document.getElementById('downloadApkLink');
    if (downloadApkLink) {
      downloadApkLink.addEventListener('click', (e) => {
        e.preventDefault();
        openChainCacaoTarget('app');
      });
    }
  });

  (function() {
    const track  = document.getElementById('carouselTrack');
    const dotsEl = document.getElementById('carouselDots');
    const slides = track ? track.querySelectorAll('.carousel-slide') : [];
    let current  = 0;
    let timer;

    if (!slides.length) return;

    // Build dots
    slides.forEach((_, i) => {
      const d = document.createElement('button');
      d.className = 'carousel-dot' + (i === 0 ? ' active' : '');
      d.setAttribute('aria-label', 'Slide ' + (i + 1));
      d.addEventListener('click', () => goTo(i));
      dotsEl.appendChild(d);
    });

    function goTo(idx) {
      slides[current].querySelector('img').style.transform = '';
      current = (idx + slides.length) % slides.length;
      track.style.transform = `translateX(-${current * 100}%)`;
      dotsEl.querySelectorAll('.carousel-dot').forEach((d, i) => {
        d.classList.toggle('active', i === current);
      });
      clearInterval(timer);
      timer = setInterval(() => goTo(current + 1), 4500);
    }

    const prevBtn = document.getElementById('carouselPrevBtn');
    const nextBtn = document.getElementById('carouselNextBtn');
    if (prevBtn) prevBtn.addEventListener('click', () => goTo(current - 1));
    if (nextBtn) nextBtn.addEventListener('click', () => goTo(current + 1));

    timer = setInterval(() => goTo(current + 1), 4500);

    // Pause on hover
    const wrap = document.getElementById('heroCarousel');
    wrap.addEventListener('mouseenter', () => clearInterval(timer));
    wrap.addEventListener('mouseleave', () => {
      clearInterval(timer);
      timer = setInterval(() => goTo(current + 1), 4500);
    });

    // Touch/swipe support
    let startX = 0;
    wrap.addEventListener('touchstart', e => { startX = e.touches[0].clientX; }, { passive: true });
    wrap.addEventListener('touchend', e => {
      const diff = startX - e.changedTouches[0].clientX;
      if (Math.abs(diff) > 40) diff > 0 ? goTo(current + 1) : goTo(current - 1);
    });
  })();
