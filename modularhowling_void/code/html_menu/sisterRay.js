/* =========================================================
   HOWLING VOID — SISTER RAY / THE GROWING STONES
========================================================= */

(() => {
  const settings = () =>
    (window.__HOWLING_MENU_SETTINGS = {
      musicEnabled: true,
      musicVolume: 0.6,
      interfaceLanguage: 'russian',
      ...(window.__HOWLING_MENU_SETTINGS || {}),
    });

  const clamp01 = (v) => Math.min(1, Math.max(0, Number(v) || 0));
  const configuredVolume = () => clamp01(settings().musicVolume ?? 0.6);
  const musicEnabled = () =>
    settings().musicEnabled !== false && configuredVolume() > 0;

  const q = (selector) => document.querySelector(selector);
  const qa = (selector) => Array.from(document.querySelectorAll(selector));

  const menuItems = qa('.menu-item');
  const startOverlay = q('.start-overlay');
  const startButton = q('.start-button');
  const skipIntro = q('#skip-intro');
  const introOverlay = q('.intro-overlay');
  const menuWrapper = q('.menu-wrapper');
  const menuList = q('.menu-list');
  const menuDivider = q('.menu-divider');
  const titleMain = q('.menu-title-main');
  const titleSmall = q('.menu-title-small');
  const titleSmallGhost = q('.menu-title-small-ghost');
  const titleSub = q('.menu-title-sub');
  const titleSubGhost = q('.menu-title-sub-ghost');
  const whiteFlash = q('.white-flash');
  const bloodFlash = q('.blood-flash');
  const bgm = q('#bgm');
  const selectSound = q('#select-sound');
  const hoverSound = q('#hover-sound');

  const timers = [];
  const intervals = [];
  const listeners = [];
  let started = false;
  let introEnded = false;
  let activeIndex = Math.max(
    0,
    menuItems.findIndex((el) => el.classList.contains('menu-item--active')),
  );
  let fadeToken = 0;
  let captionIndex = 0;
  let lastHover = 0;

  const CAPTIONS_RU = [
    'сигнал выцветает, но камни продолжают расти',
    'воспоминание не исчезло — оно сменило цвет',
    'мягкая плёнка, резкий свет, чужой коридор',
    'она сказала: не смотри прямо на вспышку',
    'howling void x Sister Ray - Прогулка на дикой улице',
  ];

  const CAPTIONS_EN = [
    'the signal fades, but the stones keep growing',
    'the memory did not vanish — it changed color',
    'soft film, sharp light, a borrowed corridor',
    'she said: do not look directly at the flash',
    'howling void x Sister Ray - Прогулка на дикой улице',
  ];

  const SIDE_NOTES_RU = [
    'архивная сцена',
    'цветовой сдвиг',
    'плёнка повреждена',
    'мягкий разлом',
    'отложенное эхо',
  ];

  const SIDE_NOTES_EN = [
    'archive scene',
    'color drift',
    'film damaged',
    'soft fracture',
    'delayed echo',
  ];

  function on(target, type, handler, options) {
    if (!target) return;
    target.addEventListener(type, handler, options);
    listeners.push([target, type, handler, options]);
  }

  function tset(fn, ms) {
    const id = window.setTimeout(fn, ms);
    timers.push(id);
    return id;
  }

  function iset(fn, ms) {
    const id = window.setInterval(fn, ms);
    intervals.push(id);
    return id;
  }

  function currentLanguage() {
    return settings().interfaceLanguage === 'english' ? 'english' : 'russian';
  }

  function textPool(ru, en) {
    return currentLanguage() === 'english' ? en : ru;
  }

  function playTick(kind = 'hover') {
    const audio = kind === 'select' ? selectSound : hoverSound || selectSound;
    if (!audio) return;

    try {
      audio.currentTime = 0;
      audio.volume = kind === 'select' ? 0.055 : 0.028;
      audio.play().catch(() => {});
    } catch {}
  }

  function fadeBgmTo(target, duration = 1600) {
    if (!bgm) return;
    const token = ++fadeToken;
    const from = clamp01(bgm.volume);
    const to = clamp01(target);
    const start = performance.now();
    const dur = Math.max(1, duration);

    const step = (now) => {
      if (token !== fadeToken) return;
      const p = Math.min(1, (now - start) / dur);
      const eased = 1 - (1 - p) ** 3;
      bgm.volume = clamp01(from + (to - from) * eased);
      if (p < 1) requestAnimationFrame(step);
    };

    requestAnimationFrame(step);
  }

  function startBgm() {
    if (!bgm) return;

    if (!musicEnabled()) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      return;
    }

    try {
      bgm.loop = true;
      bgm.volume = 0;
      const play = bgm.play();
      const after = () => fadeBgmTo(configuredVolume(), 2200);
      if (play && play.then) play.then(after).catch(() => {});
      else after();
    } catch {}
  }

  function createStage() {
    if (q('.sr-stage')) return q('.sr-stage');

    const stage = document.createElement('div');
    stage.className = 'sr-stage';
    stage.innerHTML = `
      <div class="sr-paint"></div>
      <div class="sr-burn"></div>
      <div class="sr-stone-field" aria-hidden="true"></div>
      <div class="sr-side-notes">archive scene<br>color drift<br>soft fracture</div>
      <div class="sr-frame-index">FRAME 00 / SIGNAL 72</div>
      <div class="sr-caption"></div>
    `;
    document.body.appendChild(stage);

    const field = stage.querySelector('.sr-stone-field');
    for (let i = 0; i < 28; i++) {
      const stone = document.createElement('span');
      stone.className = 'sr-stone';
      const size = 4 + Math.random() * 12;
      stone.style.width = `${size}px`;
      stone.style.height = `${size}px`;
      stone.style.left = `${Math.random() * 100}%`;
      stone.style.top = `${Math.random() * 100}%`;
      stone.style.setProperty('--sr-x', `${-22 + Math.random() * 44}px`);
      stone.style.setProperty('--sr-y', `${-42 + Math.random() * 84}px`);
      stone.style.setProperty('--sr-dur', `${9 + Math.random() * 18}s`);
      stone.style.animationDelay = `${-Math.random() * 14}s`;
      field.appendChild(stone);
    }

    return stage;
  }

  function updateCaption() {
    const caption = q('.sr-caption');
    const notes = q('.sr-side-notes');
    const frame = q('.sr-frame-index');
    if (!caption) return;

    const captions = textPool(CAPTIONS_RU, CAPTIONS_EN);
    const side = textPool(SIDE_NOTES_RU, SIDE_NOTES_EN);
    caption.textContent = captions[captionIndex % captions.length];
    caption.classList.add('sr-caption--visible');

    if (notes) {
      const start = captionIndex % side.length;
      notes.innerHTML = [0, 1, 2]
        .map((n) => side[(start + n) % side.length])
        .join('<br>');
    }

    if (frame) {
      const frameNo = String(
        (captionIndex * 7 + Math.floor(Math.random() * 4)) % 99,
      ).padStart(2, '0');
      const signal = String(58 + Math.floor(Math.random() * 39)).padStart(
        2,
        '0',
      );
      frame.textContent = `FRAME ${frameNo} / SIGNAL ${signal}`;
    }

    captionIndex += 1;
    tset(() => caption.classList.remove('sr-caption--visible'), 2600);
  }

  function frameCut(strength = 'soft') {
    document.body.classList.add('sr-cut');
    menuWrapper?.classList.add('sr-cut');

    if (strength === 'hard' && whiteFlash) {
      whiteFlash.classList.add('white-flash--active');
      tset(() => whiteFlash.classList.remove('white-flash--active'), 180);
    }

    if (strength === 'blood' && bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(() => bloodFlash.classList.remove('blood-flash--active'), 140);
    }

    tset(() => {
      document.body.classList.remove('sr-cut');
      menuWrapper?.classList.remove('sr-cut');
    }, 320);
  }

  function revealSupportTitles() {
    titleSmall?.classList.add('menu-title-small--reveal');
    titleSmallGhost?.classList.add('menu-title-small-ghost--anim');
    titleSub?.classList.add('menu-title-sub--reveal');
    titleSubGhost?.classList.add('menu-title-sub-ghost--anim');
  }

  function revealMenu() {
    if (introEnded) return;
    introEnded = true;
    introOverlay?.classList.add('intro-overlay--hidden');
    menuWrapper?.classList.add('menu-wrapper--visible');
    menuList?.classList.add('menu-list--visible');
    menuDivider?.classList.add('menu-divider--visible');
    revealSupportTitles();

    if (titleMain) {
      titleMain.style.opacity = '1';
      titleMain.style.transform = 'translateY(0)';
      titleMain.classList.add('menu-title-main--idle');
    }

    document.body.classList.add('menu-chrome-ready');
    updateCaption();
  }

  function runIntro() {
    introOverlay?.classList.remove('intro-overlay--hidden');
    introOverlay?.classList.add('intro-overlay--animating');
    frameCut('hard');
    tset(() => frameCut('soft'), 1200);
    tset(() => frameCut('blood'), 2700);
    tset(revealMenu, 3900);
  }

  function start(skip = false) {
    if (started) return;
    started = true;
    createStage();
    startOverlay?.classList.add('start-overlay--hidden');
    tset(() => startOverlay?.remove(), 700);
    startBgm();

    if (skip) revealMenu();
    else runIntro();

    iset(updateCaption, 5200);
    iset(() => frameCut(Math.random() < 0.22 ? 'hard' : 'soft'), 4300);
  }

  function setActive(index) {
    if (!menuItems.length) return;
    activeIndex = (index + menuItems.length) % menuItems.length;
    menuItems.forEach((item, i) =>
      item.classList.toggle('menu-item--active', i === activeIndex),
    );
  }

  function actionOf(item) {
    return item?.dataset?.action || '';
  }

  function handleAction(action) {
    if (!action) return;
    playTick('select');
    frameCut('hard');

    const activeAnchor = document.querySelector(
      `.menu-item[data-action="${CSS.escape(action)}"] a[href]`,
    );
    if (activeAnchor) {
      tset(() => {
        window.location.href = activeAnchor.getAttribute('href');
      }, 130);
      return;
    }

    // Same bridge-friendly behavior as the previous variants: log when BYOND wires it.
    console.log('[SisterRay] Menu action:', action);
  }

  function setupMenu() {
    menuItems.forEach((item, index) => {
      const label = item.querySelector('.menu-label');
      if (label && !label.dataset.label)
        label.dataset.label = label.textContent.trim();
      if (!item.dataset.label && label?.dataset.label)
        item.dataset.label = label.dataset.label;

      on(item, 'mouseenter', () => {
        setActive(index);
        const now = Date.now();
        if (now - lastHover > 80) {
          lastHover = now;
          playTick('hover');
        }
      });

      on(item, 'mousemove', (event) => {
        const rect = item.getBoundingClientRect();
        const x = ((event.clientX - rect.left) / Math.max(1, rect.width)) * 100;
        const y = ((event.clientY - rect.top) / Math.max(1, rect.height)) * 100;
        item.style.setProperty('--sr-hover-x', `${x}%`);
        item.style.setProperty('--sr-hover-y', `${y}%`);
      });

      on(item, 'click', () => handleAction(actionOf(item)));
    });

    setActive(activeIndex);
  }

  function setupKeys() {
    on(document, 'keydown', (event) => {
      if (!started || !menuItems.length) return;
      if (event.key === 'ArrowDown' || event.key === 'ArrowRight') {
        event.preventDefault();
        setActive(activeIndex + 1);
        playTick('hover');
      } else if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') {
        event.preventDefault();
        setActive(activeIndex - 1);
        playTick('hover');
      } else if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        handleAction(actionOf(menuItems[activeIndex]));
      } else if (event.key === 'Escape') {
        revealMenu();
      }
    });
  }

  function setupStart() {
    on(startButton, 'click', () => start(!!skipIntro?.checked));
    on(document, 'keydown', (event) => {
      if (started) return;
      if (event.key === 'Enter') start(!!skipIntro?.checked);
    });
  }

  function teardown() {
    timers.forEach(clearTimeout);
    intervals.forEach(clearInterval);
    listeners.forEach(([target, type, handler, options]) =>
      target.removeEventListener(type, handler, options),
    );
    q('.sr-stage')?.remove();
    document.body.classList.remove('sr-cut', 'menu-chrome-ready');
    menuWrapper?.classList.remove('sr-cut');
    if (bgm) {
      try {
        bgm.pause();
      } catch {}
    }
  }

  window.__menuChapterTeardown = teardown;

  document.body.dataset.chapter = 'sisterRay';
  createStage();
  setupMenu();
  setupKeys();
  setupStart();

  // Useful for direct file preview without clicking through the disclaimer every time.
  if (new URLSearchParams(window.location.search).has('autostart')) {
    tset(() => start(true), 80);
  }
})();
