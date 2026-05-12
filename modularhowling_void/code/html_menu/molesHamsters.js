/* =========================================================
   HOWLING VOID — MOLES / HAMSTERS
========================================================= */
(() => {
  const timers = [];
  const intervals = [];
  const listeners = [];
  const created = [];
  const webglCleanup = window.__HOWLING_INSTALL_WEBGL_BACKDROP({
    readyClass: 'moles-hamsters-webgl-ready',
    zIndex: 3,
    colors: ['#f4efe2', '#d7c9aa', '#b34034', '#7b5c43'],
    intensity: 0.36,
    vignette: 0.35,
  });
  let started = false;
  let activeIndex = 0;

  const later = (fn, ms) => {
    const id = window.setTimeout(fn, ms);
    timers.push(id);
    return id;
  };

  const every = (fn, ms) => {
    const id = window.setInterval(fn, ms);
    intervals.push(id);
    return id;
  };

  const listen = (target, type, fn, opts) => {
    target?.addEventListener?.(type, fn, opts);
    listeners.push([target, type, fn, opts]);
  };

  function append(className, parent = document.body) {
    const el = document.createElement('div');
    el.className = className;
    parent.appendChild(el);
    created.push(el);
    return el;
  }

  function random(min, max) {
    return min + Math.random() * (max - min);
  }

  function makeDoodle(layer, type, x, y, w, h, extra = {}) {
    const el = append(`moles-doodle moles-doodle--${type}`, layer);
    el.style.setProperty('--x', x);
    el.style.setProperty('--y', y);
    el.style.setProperty('--w', w);
    el.style.setProperty('--h', h || w);
    el.style.setProperty('--r', `${extra.rotate ?? random(-8, 8)}deg`);
    el.style.setProperty('--s', String(extra.scale ?? random(0.82, 1.12)));
    el.style.setProperty('--o', String(extra.opacity ?? random(0.28, 0.76)));
    el.style.setProperty('--b', `${extra.blur ?? 0}px`);
    if (extra.text) el.textContent = extra.text;
    return el;
  }

  function makeRedScribble(layer, x, y, w, opacity = 0.38) {
    const el = append('moles-red-scribble', layer);
    el.style.setProperty('--x', x);
    el.style.setProperty('--y', y);
    el.style.setProperty('--w', w);
    el.style.setProperty('--o', String(opacity));
    el.style.setProperty('--r', `${random(-24, 24)}deg`);
    return el;
  }

  function installLayers() {
    append('moles-paper-grain');
    append('moles-torn-band');
    append('moles-crawl-line');

    const doodles = append('moles-doodle-layer');
    const red = append('moles-red-scribble-layer');

    makeDoodle(doodles, 'word', '4vw', '5vh', 'auto', 'auto', {
      text: 'КРОТЫ',
      rotate: -3,
      opacity: 0.58,
    });
    makeDoodle(doodles, 'word', '72vw', '9vh', 'auto', 'auto', {
      text: 'ХОМЯКИ',
      rotate: 2,
      opacity: 0.42,
    });
    makeDoodle(doodles, 'grass', '0vw', '72vh', '100vw', '70px', {
      rotate: 0,
      opacity: 0.3,
    });
    makeDoodle(doodles, 'hamster', '74vw', '62vh', '160px', '110px', {
      rotate: 6,
      opacity: 0.36,
    });
    makeDoodle(doodles, 'mole', '82vw', '39vh', '130px', '90px', {
      rotate: -8,
      opacity: 0.28,
    });
    makeDoodle(doodles, 'hamster', '8vw', '75vh', '120px', '86px', {
      rotate: -10,
      opacity: 0.26,
    });

    makeRedScribble(red, '52vw', '44vh', '180px', 0.22);
    makeRedScribble(red, '87vw', '21vh', '86px', 0.18);
    makeRedScribble(red, '14vw', '58vh', '120px', 0.14);
  }

  function installMenuTextTreatment() {
    document.body.dataset.chapter = 'molesHamsters';

    const small = document.querySelector('.menu-title-small');
    const smallGhost = document.querySelector('.menu-title-small-ghost');
    const sub = document.querySelector('.menu-title-sub');
    const subGhost = document.querySelector('.menu-title-sub-ghost');

    if (small) small.textContent = 'ALOHADAWN // WarKr1me';
    if (smallGhost) smallGhost.textContent = 'ALOHADAWN // WarKr1me';
    if (sub) sub.textContent = 'КРОТЫ — ХОМЯКИ';
    if (subGhost) subGhost.textContent = 'КРОТЫ — ХОМЯКИ';

    document.querySelectorAll('.menu-item').forEach((item, index) => {
      item.style.setProperty('--moles-item-tilt', '0deg');
      const label = item.querySelector('.menu-label');
      if (label && !label.dataset.molesOriginal) {
        label.dataset.molesOriginal = label.textContent.trim();
      }
    });
  }

  function spawnScratch() {
    const layer = document.querySelector('.moles-doodle-layer');
    if (!layer) return;

    const type = Math.random() > 0.55 ? 'hamster' : 'mole';
    const el = makeDoodle(
      layer,
      type,
      `${random(8, 88)}vw`,
      `${random(12, 82)}vh`,
      `${random(72, 150)}px`,
      `${random(56, 110)}px`,
      {
        opacity: random(0.14, 0.38),
        rotate: random(-14, 14),
        scale: random(0.7, 1.2),
      },
    );

    el.animate(
      [
        {
          opacity: 0,
          transform: `${el.style.transform || ''} translateY(8px)`,
        },
        { opacity: 1, offset: 0.18 },
        { opacity: 0.4, offset: 0.72 },
        {
          opacity: 0,
          transform: `${el.style.transform || ''} translateY(-6px)`,
        },
      ],
      { duration: random(1400, 2600), easing: 'steps(3, end)' },
    ).onfinish = () => el.remove();
  }

  function installBehavior() {
    every(spawnScratch, 1800);

    document.querySelectorAll('.menu-item').forEach((item, index) => {
      item.tabIndex = 0;
      listen(item, 'mouseenter', () => {
        setActive(index);
        playTick('hover');
      });
      listen(item, 'focus', () => setActive(index));
      listen(item, 'click', () => handleAction(item.dataset.action, item));
    });

    listen(document, 'keydown', (event) => {
      if (!document.querySelector('.menu-list--visible')) return;

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
        handleAction(document.querySelectorAll('.menu-item')[activeIndex]?.dataset.action, document.querySelectorAll('.menu-item')[activeIndex]);
      }
    });
  }

  function playTick(kind = 'hover') {
    const audio =
      document.getElementById(kind === 'select' ? 'select-sound' : 'hover-sound') ||
      document.getElementById('select-sound');
    if (!audio) return;

    try {
      audio.currentTime = 0;
      audio.volume = kind === 'select' ? 0.055 : 0.025;
      audio.play().catch(() => {});
    } catch {}
  }

  function setActive(index) {
    const items = Array.from(document.querySelectorAll('.menu-item'));
    if (!items.length) return;

    activeIndex = (index + items.length) % items.length;
    items.forEach((item, itemIndex) =>
      item.classList.toggle('menu-item--active', itemIndex === activeIndex),
    );
  }

  function actionToHref(action, item) {
    const anchor = item?.querySelector?.('a[href]');
    if (anchor) return anchor.getAttribute('href');

    const src = window.__HOWLING_MENU_SRC;
    if (!src) return null;

    const actions = {
      'join-game': 'late_join=1',
      'toggle-ready': 'ready=1',
      'character-setup': 'preferences=1',
      ghost: 'observe=1',
      options: 'crew_manifest=1',
      'character-directory': 'character_directory=1',
      'be-antagonist': 'preferences=1;tab=antagonists',
      'game-settings': 'game_preferences=1',
      'game-settigs': 'game_preferences=1',
    };

    return actions[action] ? `byond://?src=${src};${actions[action]}` : null;
  }

  function handleAction(action, item) {
    if (!action) return;
    playTick('select');

    const href = actionToHref(action, item);
    if (href) {
      later(() => {
        window.location.href = href;
      }, 90);
      return;
    }

    console.log('[MolesHamsters] Menu action:', action);
  }

  function startBgm() {
    const bgm = document.getElementById('bgm');
    if (!bgm) return;

    const settings = window.__HOWLING_MENU_SETTINGS || {};
    const volume = Math.max(0, Math.min(1, Number(settings.musicVolume) || 0));
    if (settings.musicEnabled === false || volume <= 0) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      return;
    }

    try {
      bgm.loop = true;
      bgm.volume = volume;
      bgm.play().catch(() => {});
    } catch {}
  }

  function revealMenu() {
    document.querySelector('.intro-overlay')?.classList.add('intro-overlay--hidden');
    document.querySelector('.menu-wrapper')?.classList.add('menu-wrapper--visible');
    document.querySelector('.menu-list')?.classList.add('menu-list--visible');
    document.querySelector('.menu-divider')?.classList.add('menu-divider--visible');
    document.querySelector('.menu-title-small')?.classList.add('menu-title-small--reveal');
    document.querySelector('.menu-title-sub')?.classList.add('menu-title-sub--reveal');
    document.body.classList.add('menu-chrome-ready');
    setActive(0);
  }

  function runIntro(skipIntro) {
    const intro = document.querySelector('.intro-overlay');
    if (skipIntro || !intro) {
      revealMenu();
      return;
    }

    intro.classList.remove('intro-overlay--hidden');
    later(revealMenu, 3000);
  }

  function begin() {
    if (started) return;
    started = true;

    const startOverlay = document.querySelector('.start-overlay');
    const skipIntro = document.getElementById('skip-intro');
    startOverlay?.classList.add('start-overlay--hidden');
    later(() => startOverlay?.remove(), 450);

    startBgm();
    runIntro(!!skipIntro?.checked);
  }

  function installStart() {
    listen(document.querySelector('.start-button'), 'click', begin);
    listen(document, 'keydown', (event) => {
      if (!started && event.key === 'Enter') begin();
    });

    const startOverlay = document.querySelector('.start-overlay');
    if (!startOverlay || startOverlay.classList.contains('start-overlay--hidden')) {
      later(begin, 120);
    }

    if (new URLSearchParams(window.location.search).has('autostart')) {
      later(() => {
        const skip = document.getElementById('skip-intro');
        if (skip) {
          skip.checked = true;
        }
        begin();
      }, 120);
    }
  }

  function install() {
    installLayers();
    installMenuTextTreatment();
    installBehavior();
    installStart();
  }

  function teardown() {
    timers.forEach(clearTimeout);
    intervals.forEach(clearInterval);
    listeners.forEach(([target, type, fn, opts]) =>
      target?.removeEventListener?.(type, fn, opts),
    );
    created.forEach((el) => el.remove());
    webglCleanup();
    document.body.classList.remove('moles-panic', 'moles-red-cut');
  }

  window.__menuChapterTeardown = teardown;
  install();
})();
