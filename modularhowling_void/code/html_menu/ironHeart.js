// =========================================================
// IRON HEART
// =========================================================
(() => {
  const MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
  const INTRO_DURATION_MS = 8000;
  const INTRO_COPY = {
    small: 'A build by',
    main: 'Syndicate: CODE RED',
    sub: 'Presents...',
  };
  const INTRO_PHASES = [
    {
      at: 0,
      scene: 'hold',
      bodyClass: 'iron-heart-phase-hold',
    },
    {
      at: 7000,
      scene: 'collapse',
      bodyClass: 'iron-heart-phase-collapse',
    },
  ];

  const timeouts = new Set();
  let fadeRaf = 0;

  const schedule = (fn, delay) => {
    const id = setTimeout(() => {
      timeouts.delete(id);
      fn();
    }, delay);
    timeouts.add(id);
    return id;
  };

  const clearScheduled = () => {
    timeouts.forEach((id) => clearTimeout(id));
    timeouts.clear();
  };

  const ac = new AbortController();
  const on = (node, eventName, handler, options = {}) => {
    if (!node) {
      return;
    }
    node.addEventListener(eventName, handler, {
      ...options,
      signal: ac.signal,
    });
  };

  const body = document.body;
  const menuItems = Array.from(document.querySelectorAll('.menu-item'));
  const menuList = document.querySelector('.menu-list');
  const menuDivider = document.querySelector('.menu-divider');
  const menuWrapper = document.querySelector('.menu-wrapper');
  const startOverlay = document.querySelector('.start-overlay');
  const startButton = document.querySelector('.start-button');
  const skipIntroToggle = document.getElementById('skip-intro');
  const introOverlay = document.querySelector('.intro-overlay');
  const introLineSmall = document.querySelector('.intro-line-small');
  const introLineMain = document.querySelector('.intro-line-main');
  const introLineSub = document.querySelector('.intro-line-sub');
  const titleMain = document.querySelector('.menu-title-main');
  const selectSound = document.getElementById('select-sound');
  const bgm = document.getElementById('bgm');

  let activeIndex = 0;
  let started = false;
  let introVisible = false;
  let menuReady = false;

  const clamp01 = (value) => Math.max(0, Math.min(1, value));
  const getConfiguredMenuVolume = () =>
    clamp01(Number(MENU_SETTINGS.musicVolume) || 0);
  const isMenuMusicEnabled = () =>
    MENU_SETTINGS.musicEnabled !== false && getConfiguredMenuVolume() > 0;

  function playSelect() {
    if (!selectSound) {
      return;
    }

    try {
      selectSound.currentTime = 0;
      selectSound.volume = 0.06;
      const playPromise = selectSound.play();
      if (playPromise && playPromise.catch) {
        playPromise.catch(() => {});
      }
    } catch {}
  }

  function setActiveItem(index) {
    menuItems.forEach((item, itemIndex) => {
      item.classList.toggle('menu-item--active', itemIndex === index);
    });
  }

  function splitIntoAnimatedLetters(node) {
    if (!node || node.dataset.lettersReady === 'true') {
      return;
    }

    const source = node.getAttribute('data-text') || node.textContent || '';
    const fragment = document.createDocumentFragment();
    let visibleIndex = 0;

    source.split('').forEach((character) => {
      if (character === ' ') {
        fragment.appendChild(document.createTextNode(' '));
        return;
      }

      const span = document.createElement('span');
      span.className = 'title-letter';
      span.style.setProperty('--delay', String(visibleIndex * 55));
      span.textContent = character;
      fragment.appendChild(span);
      visibleIndex += 1;
    });

    node.textContent = '';
    node.appendChild(fragment);
    node.dataset.lettersReady = 'true';
  }

  function setIntroCopy() {
    if (introLineSmall) {
      introLineSmall.textContent = INTRO_COPY.small;
    }
    if (introLineMain) {
      introLineMain.textContent = INTRO_COPY.main;
    }
    if (introLineSub) {
      introLineSub.textContent = INTRO_COPY.sub;
      introLineSub.classList.toggle('intro-line-sub--empty', !INTRO_COPY.sub);
    }
  }

  function clearPhaseClasses() {
    body.classList.remove(
      'iron-heart-phase-hold',
      'iron-heart-phase-collapse',
    );
  }

  function applyIntroPhase(phase) {
    if (!introOverlay) {
      return;
    }

    clearPhaseClasses();
    body.classList.add(phase.bodyClass);
    introOverlay.dataset.scene = phase.scene;
  }

  function showIntroOverlay() {
    if (!introOverlay || introVisible) {
      return;
    }

    introVisible = true;
    introOverlay.classList.remove(
      'intro-overlay--hidden',
      'intro-overlay--fadeout',
    );
    introOverlay.classList.add('intro-overlay--active');
    schedule(() => {
      introOverlay.classList.add('intro-overlay--visible');
    }, 40);
  }

  function hideIntroOverlay() {
    if (!introOverlay) {
      return;
    }

    introOverlay.classList.add('intro-overlay--fadeout');
    introOverlay.classList.remove('intro-overlay--visible');
    schedule(() => {
      introOverlay.classList.remove('intro-overlay--active');
      introVisible = false;
    }, 900);
  }

  function revealMenu() {
    if (menuReady) {
      return;
    }

    menuReady = true;
    hideIntroOverlay();
    clearPhaseClasses();
    menuWrapper?.classList.add('menu-wrapper--visible');
    menuDivider?.classList.add('menu-divider--visible');
    menuList?.classList.add('menu-list--visible');
    setActiveItem(activeIndex);
  }

  function fadeBgmTo(targetVolume, duration) {
    if (!bgm) {
      return;
    }

    const startVolume = clamp01(bgm.volume);
    const endVolume = clamp01(targetVolume);
    const startTime = performance.now();
    const safeDuration = Math.max(1, Number(duration) || 1);

    if (fadeRaf) {
      cancelAnimationFrame(fadeRaf);
    }

    const step = (now) => {
      const t = clamp01((now - startTime) / safeDuration);
      bgm.volume = clamp01(startVolume + (endVolume - startVolume) * t);
      if (t < 1) {
        fadeRaf = requestAnimationFrame(step);
      } else {
        fadeRaf = 0;
      }
    };

    fadeRaf = requestAnimationFrame(step);
  }

  function startBgm() {
    if (!bgm) {
      return;
    }

    if (!isMenuMusicEnabled()) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      return;
    }

    bgm.loop = true;
    bgm.volume = 0;

    try {
      const playPromise = bgm.play();
      if (playPromise && playPromise.then) {
        playPromise
          .then(() => fadeBgmTo(getConfiguredMenuVolume(), 2400))
          .catch(() => {});
      }
    } catch {}
  }

  function runIntroTimeline() {
    showIntroOverlay();

    INTRO_PHASES.forEach((phase) => {
      schedule(() => applyIntroPhase(phase), phase.at);
    });

    schedule(revealMenu, INTRO_DURATION_MS);
  }

  function skipToMenu() {
    if (introOverlay) {
      introOverlay.classList.remove(
        'intro-overlay--active',
        'intro-overlay--visible',
        'intro-overlay--fadeout',
      );
      introOverlay.classList.add('intro-overlay--hidden');
      introVisible = false;
    }
    revealMenu();
  }

  function handleAction(action) {
    playSelect();

    const anchor = document.querySelector(
      `.menu-item[data-action="${action}"] a[href]`,
    );
    if (anchor) {
      window.location.href = anchor.getAttribute('href');
      return;
    }

    console.log('[IronHeart] Menu action:', action);
  }

  function startExperience() {
    if (started) {
      return;
    }

    started = true;
    MENU_SETTINGS.introAccepted = true;
    playSelect();

    if (startButton) {
      startButton.disabled = true;
    }

    startOverlay?.classList.add('start-overlay--hidden');
    schedule(() => startOverlay?.remove(), 650);

    startBgm();

    if (skipIntroToggle && skipIntroToggle.checked) {
      skipToMenu();
      return;
    }

    runIntroTimeline();
  }

  setIntroCopy();
  splitIntoAnimatedLetters(titleMain);
  if (menuItems.length) {
    setActiveItem(activeIndex);
  }

  menuItems.forEach((item, index) => {
    on(item, 'mouseenter', () => {
      if (!menuReady) {
        return;
      }
      activeIndex = index;
      setActiveItem(activeIndex);
    });

    on(item, 'click', (event) => {
      if (!menuReady) {
        return;
      }

      const target = event && event.target;
      if (target && target.closest && target.closest('a[href]')) {
        event.preventDefault();
        event.stopPropagation();
      }

      handleAction(item.dataset.action);
    });
  });

  on(startButton, 'click', startExperience);

  window.__menuChapterTeardown = () => {
    clearScheduled();
    clearPhaseClasses();

    if (fadeRaf) {
      cancelAnimationFrame(fadeRaf);
      fadeRaf = 0;
    }

    ac.abort();
  };
})();
