const slides = Array.from(document.querySelectorAll('.carousel-slide'));
const dots = Array.from(document.querySelectorAll('.dot'));
let currentSlide = 0;
let slideTimer = null;

function setActiveSlide(index) {
  currentSlide = (index + slides.length) % slides.length;
  slides.forEach((slide, idx) => {
    slide.classList.toggle('active', idx === currentSlide);
  });
  dots.forEach((dot, idx) => {
    dot.classList.toggle('active', idx === currentSlide);
  });
}

function goToSlide(index) {
  setActiveSlide(index);
  resetCarouselTimer();
}

function resetCarouselTimer() {
  clearInterval(slideTimer);
  slideTimer = setInterval(() => setActiveSlide(currentSlide + 1), 6000);
}

function initMobileMenu() {
  const mobileMenu = document.getElementById('mobile-menu');
  const navList = document.getElementById('nav-list');
  if (!mobileMenu || !navList) return;

  mobileMenu.addEventListener('click', () => {
    mobileMenu.classList.toggle('active');
    navList.classList.toggle('active');
  });

  navList.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navList.classList.remove('active');
      mobileMenu.classList.remove('active');
    });
  });
}

function initFadeUp() {
  const elements = document.querySelectorAll('.fade-up');
  if (!elements.length) return;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.2 });
  elements.forEach(el => observer.observe(el));
}

function initFlowModal() {
  const steps = document.querySelectorAll('.flow-step');
  const modal = document.getElementById('flow-modal');
  if (!modal) return;
  const img = modal.querySelector('.flow-modal-img');
  const title = modal.querySelector('.flow-modal-title');
  const desc = modal.querySelector('.flow-modal-desc');
  const closeBtn = modal.querySelector('.flow-modal-close');

  function open(dataImg, dataTitle, dataDesc) {
    img.src = dataImg || '';
    img.alt = dataTitle || '';
    title.textContent = dataTitle || '';
    desc.textContent = dataDesc || '';
    modal.classList.add('open');
    modal.setAttribute('aria-hidden', 'false');
  }

  function close() {
    modal.classList.remove('open');
    modal.setAttribute('aria-hidden', 'true');
    img.src = '';
  }

  steps.forEach(s => {
    s.addEventListener('click', () => {
      const dImg = s.dataset.img || s.getAttribute('data-img');
      const dTitle = s.dataset.title || '';
      const dDesc = s.dataset.desc || '';
      open(dImg, dTitle, dDesc);
    });
  });

  closeBtn.addEventListener('click', close);
  modal.addEventListener('click', (e) => { if (e.target === modal) close(); });
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });
}

function initStatsAnimation() {
  const stats = document.querySelectorAll('.stat');
  if (!stats.length) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const stat = entry.target;
        const numEl = stat.querySelector('.stat-num');
        if (numEl && !numEl.classList.contains('started')) {
          animateCount(numEl);
          numEl.classList.add('started');
          // subtle periodic pulse
          setInterval(() => {
            stat.classList.add('pulse');
            setTimeout(() => stat.classList.remove('pulse'), 1100);
          }, 5000 + Math.floor(Math.random() * 3000));
        }
        observer.unobserve(stat);
      }
    });
  }, { threshold: 0.25 });

  stats.forEach(s => observer.observe(s));

  function animateCount(el) {
    const target = Number(el.dataset.target) || 0;
    const format = el.dataset.format || 'number';
    const suffix = el.dataset.suffix || '';
    const duration = 1800;
    const start = performance.now();

    function tick(now) {
      const t = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - t, 3);
      const value = Math.floor(eased * target);

      if (format === 'thousands') {
        // show as rounded thousands (e.g., 40K+)
        const k = Math.round(value / 1000);
        el.textContent = k + (suffix || 'K');
      } else {
        el.textContent = value + (suffix || '');
      }

      if (t < 1) requestAnimationFrame(tick);
      else {
        // final value
        if (format === 'thousands') el.textContent = Math.round(target / 1000) + (suffix || 'K');
        else el.textContent = target + (suffix || '');
      }
    }

    requestAnimationFrame(tick);
  }
}

function makeDemoHistory() {
  return {
    lotId: document.getElementById('lot-id')?.value || 'LOT-DEMO-2026-0001',
    statut: 'Validé (démo)',
    scoreConfiance: 98,
    producteur: 'COOP KAFO - Togo',
    details: [
      { stage: 'Création du lot', desc: 'Enregistrement des poids + coordonnées GPS au champ.', date: '2026-05-02', actor: 'Producteur' },
      { stage: 'Double validation', desc: 'Validation coopérative + exportateur, empreinte immuable du lot.', date: '2026-05-03', actor: 'Coopérative / Exportateur' },
      { stage: 'Transport & transfert', desc: 'Transfert physique vers le point de consolidation.', date: '2026-05-05', actor: 'Logistique' },
      { stage: 'Vérification (QR)', desc: 'Scan QR : consultation de l’historique et authentification.', date: '2026-05-09', actor: 'Acheteur' },
    ]
  };
}

function ensureDemoUI() {
  const verifierContainer = document.querySelector('.verifier-container');
  if (!verifierContainer) return null;

  let out = document.getElementById('verifier-result');
  if (!out) {
    out = document.createElement('div');
    out.id = 'verifier-result';
    out.style.marginTop = '14px';
    out.style.display = 'block';
    out.style.padding = '14px';
    out.style.borderRadius = '14px';
    out.style.border = '1px solid rgba(201,137,42,.22)';
    out.style.background = 'rgba(255,255,255,0.65)';
    out.style.boxShadow = '0 10px 40px rgba(59,31,10,.06)';

    const form = document.querySelector('.verifier-form');
    (form || verifierContainer).appendChild(out);
  }
  return out;
}

function handleDemoLot() {
  const input = document.getElementById('lot-id');
  if (input) input.value = 'LOT-DEMO-2026-0001';

  const result = ensureDemoUI();
  if (!result) return;

  const demo = makeDemoHistory();
  const stepsHtml = demo.details
    .map((d, i) => `
      <div style="margin-top:10px; padding-top:${i === 0 ? 0 : 10}px; border-top:${i === 0 ? 'none' : '1px solid rgba(201,137,42,.16)'}">
        <div style="font-weight:800; color: var(--cacao);">${d.stage}</div>
        <div style="color: var(--muted); font-size:13px; margin-top:4px; line-height:1.5;">${d.desc}</div>
        <div style="font-size:12px; color: rgba(26,15,6,.65); margin-top:6px;">
          <strong>Date</strong> : ${d.date} · <strong>Acteur</strong> : ${d.actor}
        </div>
      </div>
    `)
    .join('');

  result.innerHTML = `
    <div style="display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap;">
      <div>
        <div style="font-family: 'Playfair Display', serif; font-weight:900; color: var(--cacao); font-size:18px;">Historique simulé</div>
        <div style="color: var(--muted); font-size:13px; margin-top:3px;">Lot : <strong>${demo.lotId}</strong> · ${demo.statut}</div>
      </div>
      <div style="min-width:160px; text-align:right;">
        <div style="font-family: 'Playfair Display', serif; font-weight:900; color: var(--gold); font-size:28px;">${demo.scoreConfiance}%</div>
        <div style="color: rgba(26,15,6,.65); font-size:12px;">Score confiance (démo)</div>
      </div>
    </div>
    ${stepsHtml}
    <div style="margin-top:12px; color: rgba(26,15,6,.6); font-size:12px; line-height:1.5;">
      Astuce test : entrez un ID et cliquez sur <strong>Vérifier</strong> (la démo simule un historique local).
    </div>
  `;

  result.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function handleVerifyLot() {
  const input = document.getElementById('lot-id');
  const lotId = (input?.value || '').trim();

  if (!lotId) {
    const result = ensureDemoUI();
    if (result) {
      result.innerHTML = `<div style="color: var(--cacao); font-weight:800;">Veuillez entrer un ID de lot.</div>`;
      result.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    return;
  }

  // Démo : on simule l’historique local quelle que soit la valeur saisie.
  const result = ensureDemoUI();
  if (!result) return;

  const demo = makeDemoHistory();
  demo.lotId = lotId;

  const stepsHtml = demo.details
    .map((d, i) => `
      <div style="margin-top:10px; padding-top:${i === 0 ? 0 : 10}px; border-top:${i === 0 ? 'none' : '1px solid rgba(201,137,42,.16)'}">
        <div style="font-weight:800; color: var(--cacao);">${d.stage}</div>
        <div style="color: var(--muted); font-size:13px; margin-top:4px; line-height:1.5;">${d.desc}</div>
        <div style="font-size:12px; color: rgba(26,15,6,.65); margin-top:6px;">
          <strong>Date</strong> : ${d.date} · <strong>Acteur</strong> : ${d.actor}
        </div>
      </div>
    `)
    .join('');

  const confStat = `
    <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:14px; flex-wrap:wrap;">
      <div style="flex:1; min-width:260px;">
        <div style="font-family: 'Playfair Display', serif; font-weight:900; color: var(--cacao); font-size:18px;">🚨 Statut de conformité réglementaire</div>
        <div style="margin-top:8px; padding:12px 14px; border-radius:14px; border:1px solid rgba(45,90,39,.25); background: rgba(45,90,39,.07);">
          <div style="font-weight:900; color: var(--leaf);">Statut EUDR : <span style="color: var(--leaf);">CONFORME</span> (VERT)</div>
          <div style="color: var(--muted); font-size:13px; margin-top:6px; line-height:1.5;">
            Éligibilité à l'importation : <strong>Autorisé</strong> sur le marché de l'Union Européenne.
          </div>
          <div style="color: var(--muted); font-size:13px; margin-top:6px; line-height:1.5;">
            Alerte Déforestation : <strong style="color:#b00020;">❌ Aucune intersection</strong> détectée avec les zones forestières protégées du Togo.
          </div>
        </div>
      </div>
      <div style="min-width:220px; text-align:right;">
        <div style="font-family: 'Playfair Display', serif; font-weight:900; color: var(--gold); font-size:32px;">${demo.scoreConfiance}%</div>
        <div style="color: rgba(26,15,6,.65); font-size:12px; line-height:1.4;">Score confiance (démo)</div>
        <div style="margin-top:10px; color: var(--muted); font-size:12px;">Lot : <strong>${demo.lotId}</strong></div>
      </div>
    </div>
  `;

  const geoHtml = `
    <div style="margin-top:14px;">
      <div style="font-weight:900; color: var(--cacao);">📋 1. Données de traçabilité géographique (origine)</div>
      <div style="margin-top:8px; display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div style="padding:12px 14px; border-radius:14px; border:1px solid rgba(201,137,42,.18); background: rgba(253,246,236,.65);">
          <div style="font-size:12px; color: rgba(26,15,6,.6);">Identifiant unique de la parcelle</div>
          <div style="margin-top:6px; font-weight:900; color: var(--cacao);">PRC-TOG-2026-8841</div>
          <div style="margin-top:8px; font-size:12px; color: rgba(26,15,6,.65);">Propriétaire : <strong>Georges GNANLE</strong></div>
          <div style="margin-top:4px; font-size:12px; color: rgba(26,15,6,.65);">Date d'enregistrement : <strong>22 Février 2026 · 08:30</strong></div>
        </div>
        <div style="padding:12px 14px; border-radius:14px; border:1px solid rgba(201,137,42,.18); background: rgba(253,246,236,.65);">
          <div style="font-size:12px; color: rgba(26,15,6,.6);">Coordonnées polygonales (GPS)</div>
          <div style="margin-top:6px; font-weight:800; color: var(--cacao);">Plaintext</div>
          <div style="margin-top:8px; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size:12px; color: rgba(26,15,6,.8); line-height:1.6;">
            [6.9074, 0.6321], [6.9079, 0.6325], [6.9071, 0.6330], [6.9065, 0.6322]
          </div>
          <div style="margin-top:10px; font-size:12px; color: rgba(26,15,6,.65); line-height:1.5;">
            (Mini-carte interactive : tracé exact de la plantation pour prouver l'absence d'empiètement.)
          </div>
        </div>
      </div>
    </div>
  `;

  const commercialHtml = `
    <div style="margin-top:14px;">
      <div style="font-weight:900; color: var(--cacao);">⚖️ 2. Données de conformité commerciale (mass-balance)</div>
      <div style="margin-top:8px; display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
        <div style="padding:12px 14px; border-radius:14px; border:1px solid rgba(201,137,42,.18); background: rgba(253,246,236,.65);">
          <div style="font-size:12px; color: rgba(26,15,6,.6);">Poids net à la récolte</div>
          <div style="margin-top:6px; font-weight:900; color: var(--cacao);">1 230 kg</div>
          <div style="margin-top:10px; font-size:12px; color: rgba(26,15,6,.65);">Humidité : <strong>7.2%</strong> (Grade 1 - Conforme)</div>
        </div>
        <div style="padding:12px 14px; border-radius:14px; border:1px solid rgba(201,137,42,.18); background: rgba(253,246,236,.65);">
          <div style="font-size:12px; color: rgba(26,15,6,.6);">Poids net à la pesée centrale</div>
          <div style="margin-top:6px; font-weight:900; color: var(--cacao);">1 250 kg</div>
          <div style="margin-top:8px; font-size:12px; color: rgba(26,15,6,.65);">Écart de masse : <strong>+1.62%</strong> (seuil < 5%)</div>
        </div>
      </div>
    </div>
  `;

  const cryptoHtml = `
    <div style="margin-top:14px;">
      <div style="font-weight:900; color: var(--cacao);">⛓️ 3. Preuves cryptographiques & audit blockchain</div>
      <div style="margin-top:8px; padding:12px 14px; border-radius:14px; border:1px solid rgba(201,137,42,.18); background: rgba(253,246,236,.65);">
        <div style="font-size:12px; color: rgba(26,15,6,.6);">ID du Smart Contract</div>
        <div style="margin-top:6px; font-weight:900; color: var(--cacao);">0x71C...B29</div>
        <div style="margin-top:10px; font-size:12px; color: rgba(26,15,6,.6);">Transaction Hash (ancrage)</div>
        <div style="margin-top:6px; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size:12px; color: rgba(26,15,6,.85); line-height:1.6;">
          0x5c8f9a72b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0
        </div>
        <div style="margin-top:10px; font-size:12px; color: rgba(26,15,6,.65);">Horodatage blockchain : <strong>2026-02-22 14:15:02 UTC</strong></div>
      </div>
    </div>
  `;

  result.innerHTML = `
    ${confStat}
    ${geoHtml}
    ${commercialHtml}
    ${cryptoHtml}
    <div style="margin-top:14px; font-weight:900; color: var(--cacao);">Historique des étapes (démo)</div>
    ${stepsHtml}
    <div style="margin-top:12px; color: rgba(26,15,6,.6); font-size:12px; line-height:1.5;">
      Astuce test : essayez un autre ID (ex: <strong>${lotId}</strong>) et cliquez sur <strong>Vérifier</strong>.
    </div>
  `;


  result.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

window.addEventListener('DOMContentLoaded', () => {
  initMobileMenu();
  initFadeUp();
  initFlowModal();
  initStatsAnimation();
  if (slides.length) {
    setActiveSlide(0);
    resetCarouselTimer();
  }
});


