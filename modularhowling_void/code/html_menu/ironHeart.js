// =========================================================
// IRON HEART
// =========================================================
(() => {
  const MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
  const timeouts = new Set();
  const tset = (fn, ms) => {
    const id = setTimeout(() => {
      timeouts.delete(id);
      fn();
    }, ms);
    timeouts.add(id);
    return id;
  };
  const clearAllTimers = () => {
    timeouts.forEach((id) => clearTimeout(id));
    timeouts.clear();
  };

  const ac = new AbortController();
  const on = (el, ev, fn, opts = {}) => {
    if (!el) return;
    el.addEventListener(ev, fn, { ...opts, signal: ac.signal });
  };

  const menuItems = Array.from(document.querySelectorAll('.menu-item'));
  const selectSound = document.getElementById('select-sound');
  const bgm = document.getElementById('bgm');

  const startOverlay = document.querySelector('.start-overlay');
  const startButton = document.querySelector('.start-button');
  const skipIntroToggle = document.getElementById('skip-intro');

  const introOverlay = document.querySelector('.intro-overlay');
  const menuWrapper = document.querySelector('.menu-wrapper');

  let started = false;
  let introEnded = false;
  let activeIndex = 0;

  function playSelect() {
    if (!selectSound) return;
    try {
      selectSound.currentTime = 0;
      selectSound.volume = 0.18;
      selectSound.play().catch(() => {});
    } catch {}
  }

  function setActiveItem(index) {
    menuItems.forEach((el, i) =>
      el.classList.toggle('menu-item--active', i === index),
    );
  }

  function handleAction(action) {
    playSelect();

    const activeAnchor = document.querySelector(
      `.menu-item[data-action="${action}"] a[href]`,
    );
    if (activeAnchor) {
      window.location.href = activeAnchor.getAttribute('href');
      return;
    }

    console.log('[IronHeart] Menu action:', action);
  }

  function endIntro() {
    if (introEnded) return;
    introEnded = true;
    introOverlay?.classList.add('intro-overlay--hidden');
    menuWrapper?.classList.add('menu-wrapper--visible');
  }

  let fadeRaf = 0;
  const clamp01 = (x) => Math.max(0, Math.min(1, x));
  const getConfiguredMenuVolume = () =>
    clamp01(Number(MENU_SETTINGS.musicVolume) || 0);
  const isMenuMusicEnabled = () =>
    MENU_SETTINGS.musicEnabled !== false && getConfiguredMenuVolume() > 0;

  function fadeBgmTo(targetVolume, duration) {
    if (!bgm) return;

    const startVolume = clamp01(bgm.volume);
    const target = clamp01(targetVolume);
    const dur = Math.max(1, Number(duration) || 1);
    const startTime = performance.now();

    if (fadeRaf) cancelAnimationFrame(fadeRaf);

    const step = (now) => {
      const t = clamp01((now - startTime) / dur);
      bgm.volume = clamp01(startVolume + (target - startVolume) * t);
      if (t < 1) fadeRaf = requestAnimationFrame(step);
      else fadeRaf = 0;
    };

    fadeRaf = requestAnimationFrame(step);
  }

  function startBgm() {
    if (!bgm) return;

    if (!isMenuMusicEnabled()) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      return;
    }

    bgm.loop = true;
    bgm.volume = 0;

    const p = bgm.play();
    if (p && p.then)
      p.then(() => fadeBgmTo(getConfiguredMenuVolume(), 1800)).catch(() => {});
  }

  const TIMINGS = { REVEAL_SOFT: 6.5 };

  function scheduleReveal() {
    if (!bgm) return;
    const startTime = bgm.currentTime || 0;

    const at = (sec, fn) => {
      const delay = Math.max(0, (sec - startTime) * 1000);
      tset(() => {
        if (!bgm) return;
        fn();
      }, delay);
    };

    at(TIMINGS.REVEAL_SOFT, () => {
      if (!introEnded) endIntro();
      document.querySelector('.menu-list')?.classList.add('menu-list--visible');
      document
        .querySelector('.menu-divider')
        ?.classList.add('menu-divider--visible');
    });
  }

  function revealMenuNow() {
    endIntro();
    document.querySelector('.menu-list')?.classList.add('menu-list--visible');
    document
      .querySelector('.menu-divider')
      ?.classList.add('menu-divider--visible');
  }

  function startExperience() {
    if (started) return;
    started = true;

    playSelect();
    if (startButton) startButton.disabled = true;

    const skipIntro = !!(skipIntroToggle && skipIntroToggle.checked);

    startOverlay?.classList.add('start-overlay--hidden');
    tset(() => startOverlay?.remove(), 650);

    startBgm();

    if (skipIntro) {
      introOverlay?.classList.add('intro-overlay--hidden');
      revealMenuNow();
      return;
    }

    introOverlay?.classList.remove('intro-overlay--hidden');
    introEnded = false;
    scheduleReveal();
  }

  if (menuItems.length) setActiveItem(0);

  menuItems.forEach((item, index) => {
    on(item, 'mouseenter', () => {
      if (!introEnded) return;
      activeIndex = index;
      setActiveItem(activeIndex);
    });

    on(item, 'click', (event) => {
      if (!introEnded) return;
      const target = event?.target;
      if (target && target.closest('a[href]')) {
        event.preventDefault();
        event.stopPropagation();
      }
      handleAction(item.dataset.action);
    });
  });

  on(startButton, 'click', startExperience);

  window.__menuChapterTeardown = () => {
    clearAllTimers();
    if (fadeRaf) cancelAnimationFrame(fadeRaf);
    fadeRaf = 0;
    ac.abort();
  };
})();
