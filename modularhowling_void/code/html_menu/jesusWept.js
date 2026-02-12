/* =========================================================
   JESUS WEPT
========================================================= */

(() => {
  const MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};

  const clamp01 = (v) => Math.min(1, Math.max(0, Number(v) || 0));
  const getConfiguredMenuVolume = () => clamp01(MENU_SETTINGS.musicVolume);
  const isMenuMusicEnabled = () =>
    MENU_SETTINGS.musicEnabled !== false && getConfiguredMenuVolume() > 0;

  // ===============================
  // ELEMENTS
  // ===============================
  const menuItems = Array.from(document.querySelectorAll('.menu-item'));
  const hoverSound = document.getElementById('hover-sound');
  const selectSound = document.getElementById('select-sound');
  const bgm = document.getElementById('bgm');

  const startOverlay = document.querySelector('.start-overlay');
  const startButton = document.querySelector('.start-button');
  const skipIntro = document.getElementById('skip-intro');

  const introOverlay = document.querySelector('.intro-overlay');
  const menuWrapper = document.querySelector('.menu-wrapper');

  const bloodFlash = document.querySelector('.blood-flash');
  const whiteFlash = document.querySelector('.white-flash');

  const crossOverlay = document.querySelector('.inverted-cross-overlay');
  const crossEl = document.querySelector('.inverted-cross');
  const crossFog = document.querySelector('.cross-fog');
  const noiseOverlay = document.querySelector('.noise-overlay');
  const fisheyeLens = document.querySelector('.fisheye-lens');

  const menuTitleBlock = document.querySelector('.menu-title');

  const FEAR_VARIANTS = ['menu-fear-v1', 'menu-fear-v2', 'menu-fear-v3'];

  // ===============================
  // STATE + CLEANUP
  // ===============================
  let activeIndex = 0;
  let introEnded = false;
  let started = false;

  const controller = new AbortController();
  const { signal } = controller;

  /** @type {number[]} */
  const timeouts = [];
  /** @type {number[]} */
  const intervals = [];

  const tset = (fn, ms) => {
    const id = window.setTimeout(fn, ms);
    timeouts.push(id);
    return id;
  };

  const iset = (fn, ms) => {
    const id = window.setInterval(fn, ms);
    intervals.push(id);
    return id;
  };

  let fadeToken = 0;
  function fadeBgmTo(targetVolume, duration = 1200) {
    if (!bgm) return;

    const token = ++fadeToken;
    const from = clamp01(bgm.volume);
    const to = clamp01(targetVolume);
    const dur = Math.max(1, Number(duration) || 1);
    const start = performance.now();

    const step = (now) => {
      if (token !== fadeToken) return;
      const t = Math.min(1, (now - start) / dur);
      bgm.volume = clamp01(from + (to - from) * t);
      if (t < 1) requestAnimationFrame(step);
    };

    requestAnimationFrame(step);
  }

  // ===============================
  // MENU HANDLING
  // ===============================
  const fearTimers = new WeakMap();

  function applyRandomFearVariant(el) {
    FEAR_VARIANTS.forEach((cls) => el.classList.remove(cls));
    const v = FEAR_VARIANTS[Math.floor(Math.random() * FEAR_VARIANTS.length)];
    el.classList.add(v);
  }

  function stopFearCycle(item) {
    const id = fearTimers.get(item);
    if (id) {
      clearInterval(id);
      fearTimers.delete(item);
    }
  }

  function startFearCycle(item) {
    stopFearCycle(item);

    const tick = () => {
      if (
        !item.matches(':hover') &&
        !item.classList.contains('menu-item--active')
      ) {
        stopFearCycle(item);
        return;
      }
      applyRandomFearVariant(item);
    };

    tick();
    const id = iset(tick, 230);
    fearTimers.set(item, id);
  }

  function setActiveItem(index) {
    menuItems.forEach((el, i) => {
      const isActive = i === index;
      el.classList.toggle('menu-item--active', isActive);
      if (isActive) startFearCycle(el);
      else stopFearCycle(el);
    });
  }

  let lastHoverTime = 0;
  function playHover() {
    const now = Date.now();
    if (now - lastHoverTime < 80) return;
    lastHoverTime = now;

    if (!hoverSound) return;
    try {
      hoverSound.currentTime = 0;
      hoverSound.volume = 0.3;
      hoverSound.play().catch(() => {});
    } catch {}
  }

  function playSelect() {
    if (!selectSound) return;
    try {
      selectSound.currentTime = 0;
      selectSound.volume = 0.18;
      selectSound.play().catch(() => {});
    } catch {}
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

    console.log('[JesusWept] Menu action:', action);
  }

  // ===============================
  // FX helpers
  // ===============================
  function triggerImpactFX() {
    document.body.classList.add('body-shake');
    tset(() => document.body.classList.remove('body-shake'), 400);

    if (bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(() => bloodFlash.classList.remove('blood-flash--active'), 110);
    }
  }

  function triggerCrossBeat(intensity = 'normal') {
    if (crossEl) {
      crossEl.classList.add('inverted-cross--beat');
      tset(() => crossEl.classList.remove('inverted-cross--beat'), 260);
    }

    if (crossFog) {
      crossFog.classList.add('cross-fog--boost');
      tset(() => crossFog.classList.remove('cross-fog--boost'), 500);
    }

    if (intensity === 'hard') {
      tset(() => {
        if (!started) return;
        if (crossEl) {
          crossEl.classList.add('inverted-cross--beat');
          tset(() => crossEl.classList.remove('inverted-cross--beat'), 220);
        }
        if (crossFog) {
          crossFog.classList.add('cross-fog--boost');
          tset(() => crossFog.classList.remove('cross-fog--boost'), 420);
        }
      }, 120);
    }
  }

  function triggerFisheyeOnce() {
    if (!fisheyeLens) return;

    fisheyeLens.classList.remove('fisheye-lens--active');
    void fisheyeLens.offsetWidth;
    fisheyeLens.classList.add('fisheye-lens--active');

    document.body.classList.add('fisheye-warp');
    tset(() => document.body.classList.remove('fisheye-warp'), 800);
  }

  function triggerFisheyeBurst(times = 5) {
    if (!fisheyeLens) return;

    for (let i = 0; i < times; i++) {
      const delay = 80 + i * 220 + Math.random() * 120;
      tset(() => triggerFisheyeOnce(), delay);
    }
  }

  // ===============================
  // INTRO / REVEAL
  // ===============================
  function endIntro() {
    if (introEnded) return;
    introEnded = true;

    introOverlay?.classList.add('intro-overlay--hidden');
    menuWrapper?.classList.add('menu-wrapper--visible');
    startWhispers();
  }

  function revealMenuNow() {
    endIntro();

    const small = document.querySelector('.menu-title-small');
    const smallGhost = document.querySelector('.menu-title-small-ghost');
    const sub = document.querySelector('.menu-title-sub');
    const subGhost = document.querySelector('.menu-title-sub-ghost');
    const menuList = document.querySelector('.menu-list');
    const menuDivider = document.querySelector('.menu-divider');
    const mainTitle = document.querySelector('.menu-title-main');

    small?.classList.add('menu-title-small--reveal');
    smallGhost?.classList.add('menu-title-small-ghost--anim');
    sub?.classList.add('menu-title-sub--reveal');
    subGhost?.classList.add('menu-title-sub-ghost--anim');

    menuList?.classList.add('menu-list--visible');
    menuDivider?.classList.add('menu-divider--visible');

    if (mainTitle) {
      mainTitle.style.opacity = '1';
      mainTitle.style.transform = 'translateY(0)';
      mainTitle.classList.add('menu-title-main--idle');
    }
  }

  // ===============================
  // AUDIO + SCHEDULING
  // ===============================
  let crossBeatsScheduled = false;
  let impactBeatsScheduled = false;
  let fisheyeScheduled = false;

  function scheduleCrossBeats() {
    if (!bgm || crossBeatsScheduled) return;
    crossBeatsScheduled = true;

    const beatPattern = [
      0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.74,
      8.32, 8.47, 9.74, 9.75, 9.92, 10.09, 10.26, 10.43, 10.6, 10.77, 10.91,
      11.08, 11.25, 11.42, 11.59, 11.76, 11.93, 11.94, 11.95, 11.96, 11.97,
      11.98, 11.99, 12.0, 12.1, 12.27, 12.44, 12.61, 12.78, 12.95, 13.12, 13.29,
      13.46, 13.63, 13.8, 13.97, 14.14, 14.31, 14.48, 14.55, 14.77, 14.92,
      15.08, 15.23, 15.38, 15.53, 15.68, 15.84, 15.97, 16.12, 16.28, 16.42,
      16.55, 16.71, 16.87, 17.02, 17.18, 17.33, 17.48, 17.64, 17.81, 17.98,
      18.15, 18.35, 18.49, 18.65, 18.81, 18.97,
    ];

    const RIFF = 4.74;
    const CHAPTER = 9.74;
    const startTime = bgm.currentTime || 0;

    beatPattern.forEach((t) => {
      const delay = Math.max(0, (t - startTime) * 1000);

      tset(() => {
        if (!started) return;

        const isRiff = Math.abs(t - RIFF) < 0.001;
        const isChapter = Math.abs(t - CHAPTER) < 0.001;

        if (isRiff) {
          triggerCrossBeat('hard');
          triggerImpactFX();

          if (menuTitleBlock) {
            menuTitleBlock.classList.add('menu-title--riff');

            tset(() => {
              menuTitleBlock.classList.remove('menu-title--riff');
              const main = menuTitleBlock.querySelector('.menu-title-main');
              if (main) {
                main.style.opacity = '1';
                main.style.transform = 'translateY(0)';
                main.classList.add('menu-title-main--idle');
              }
            }, 12500);
          }

          document.body.classList.add('hard-glitch');
          noiseOverlay?.classList.add('noise-overlay--hard');
          tset(() => {
            document.body.classList.remove('hard-glitch');
            noiseOverlay?.classList.remove('noise-overlay--hard');
          }, 9000);

          if (!introEnded) tset(endIntro, 200);
          return;
        }

        if (isChapter) {
          if (whiteFlash) {
            whiteFlash.classList.add('white-flash--active');
            tset(() => whiteFlash.classList.remove('white-flash--active'), 500);
          }

          triggerCrossBeat('hard');

          document.body.classList.add('post-flash-shader');
          tset(() => {
            document.body.classList.remove('post-flash-shader');
          }, 6000);

          const small = document.querySelector('.menu-title-small');
          const smallGhost = document.querySelector('.menu-title-small-ghost');
          small?.classList.add('menu-title-small--reveal');
          smallGhost?.classList.add('menu-title-small-ghost--anim');

          const sub = document.querySelector('.menu-title-sub');
          const subGhost = document.querySelector('.menu-title-sub-ghost');
          sub?.classList.add('menu-title-sub--reveal');
          subGhost?.classList.add('menu-title-sub-ghost--anim');

          tset(() => {
            document.body.classList.add('void-shader');
            const menuList = document.querySelector('.menu-list');
            const menuDivider = document.querySelector('.menu-divider');
            menuList?.classList.add('menu-list--visible');
            menuDivider?.classList.add('menu-divider--visible');
          }, 6000);

          return;
        }

        triggerCrossBeat();
      }, delay);
    });
  }

  function scheduleBeatImpacts() {
    if (!bgm || impactBeatsScheduled) return;
    impactBeatsScheduled = true;

    const impactTimes = [
      0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.43,
      4.46, 4.47,
    ];
    const startTime = bgm.currentTime || 0;

    impactTimes.forEach((t) => {
      const delay = Math.max(0, (t - startTime) * 1000);
      tset(() => {
        if (!started) return;
        triggerImpactFX();
      }, delay);
    });
  }

  function scheduleFisheyeBursts() {
    if (fisheyeScheduled) return;
    fisheyeScheduled = true;

    const queueNextBurst = () => {
      if (!started) {
        fisheyeScheduled = false;
        return;
      }

      const baseDelay = 450 + Math.random() * 600;

      tset(() => {
        if (!started) {
          fisheyeScheduled = false;
          return;
        }

        triggerFisheyeBurst();

        if (Math.random() < 0.55) {
          const extraCount = 2 + Math.floor(Math.random() * 3);
          for (let i = 1; i <= extraCount; i++) {
            const gap = 140 + Math.random() * 160;
            tset(() => {
              if (!started) return;
              triggerFisheyeBurst();
            }, gap * i);
          }
        }

        queueNextBurst();
      }, baseDelay);
    };

    tset(queueNextBurst, 19000);
  }

  function startBgm() {
    if (!bgm) return;
    const afterStart = () => {
      scheduleCrossBeats();
      scheduleBeatImpacts();
      scheduleFisheyeBursts();
    };

    if (!isMenuMusicEnabled()) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      afterStart();
      return;
    }

    bgm.loop = true;
    bgm.volume = 0;
    const p = bgm.play();

    const afterPlay = () => {
      fadeBgmTo(getConfiguredMenuVolume(), 2000);
      afterStart();
    };

    if (p && p.then) p.then(afterPlay).catch(afterStart);
    else afterPlay();
  }

  // ===============================
  // WHISPERS (ЛЕТАЮЩИЕ СЛОВА)
  // ===============================
  const WHISPER_WORDS = [
    'ПЛОТЬ',
    'КРОВЬ',
    'МЯСО',
    'КОСТИ',
    'ГНИЛЬ',
    'РАСПАД',
    'ГНИЁТ',
    'СНИМИ СКАЛЬП',
    'СЛОМЛЕН',
    'БЕЗ КОЖИ',
    'РАЗРЕЗ',
    'ПУЛЬС',
    'НЕ ДЫШИ',
    'ЗАДОХНИСЬ',
    'СМЕРТЬ',
    'СТРАХ',
    'БОЛЬ',
    'УМРИ',
    'БОЙСЯ',
    'ТРУП',
    'СДОХНИ',
    'ПЕРЕЛОМ',
    'КРИК',
    'ШЕПОТ',
    'БЛЕВОТИНА',
    'ОБРЫВ',
    'ТЬМА ВНУТРИ',
    'НЕ ПРОСНЕШСЯ',
    'УБЕЙ',
    'РАСЧЛЕНИ',
    'ГРЕХ',
    'ПОРОК',
    'ВИНА',
    'КАРА',
    'РАСПЯТИЕ',
    'ПРОКЛЯТ',
    'СОЖГИ СЕБЯ',
    'НЕ ОТПУСТЯТ',
    'НЕ ПРОСТЯТ',
    'СДОХНИ В ВЕРЕ',
    'БЕЗ ИСПОВЕДИ',
    'ПУСТОЙ КРЕСТ',
    'НАРКОТИКИ',
    'КОЛЬНИ ДОЗУ',
    'ШЛЮХА',
    'ПСИНА',
    'ПОЛЗИ',
    'РАСПУСТИСЬ',
    'РАСТЛЕН',
    'ГРЯЗЬ',
    'НИЧТО',
    'КЛОАКА',
    'МОЛЧИ',
    'СТЫД',
    'Я ЗНАЮ ТЕБЯ',
    'ИЗВРАТ',
    'ПОЗОР',
    'ЗАТКНИСЬ',
    'ЛИЧ',
    'ДРОЧИ',
    'ЖИГАЛО',
    'НАСИЛУЙ',
    'ИЗНАСИЛУЙ',
    'СЛУШАЙ',
    'ПОВИНУЙСЯ',
    'СЛАБЫЙ',
    'СЛОМАЙСЯ',
    'СОЙДИ С УМА',
    'ТЫ НЕ СВОЙ',
    'ТЫ ЧУЖАК',
    'ГОЛОСА',
    'ИМ ХОЧЕТСЯ',
    'ОНИ СМОТРЯТ',
    'ОНИ РЯДОМ',
    'ЗДЕСЬ НЕТ ТЕБЯ',
    'НИКОГДА',
    'СЛИШКОМ ПОЗДНО',
    'УЖЕ ПОЗДНО',
    'НЕ УСПЕЕШЬ',
    'ЗАБУДЬ ДОМ',
    'НЕТ ВОЗВРАТА',
    'ТЫ ЗАСТРЯЛ',
    'ПОТЕРЯН',
    'РАСТВОРИСЬ',
    'РАССЫПЬСЯ',
    'НЕ СУЩЕСТВУЕШЬ',
    'ЭТО ВСЁ ТЫ',
    'ТЫ ХОТЕЛ ЭТОГО',
    'Я ВНУТРИ ТЕБЯ',
    'НИКТО НЕ ПРИДЁТ',
    'НИКОМУ НЕ НУЖЕН',
    'СМОТРИ НА КРОВЬ',
    'ОЩУТИ КОСТИ',
    'ТЫ ЛИШНИЙ',
    'УПАДИ НИЖЕ',
    'ТЫ УЖЕ ЗДЕСЬ',
    'ВОЗВРАТА НЕТ',
    'ТЫ НЕ ОН',
    'ТЫ НЕ ОНА',
    'ТЫ НИЧТО',
    'РЕЖЬ',
    'БУХАЙ',
    'ПЛЫВИ',
    'ПАДАЙ',
    'СГОРИ',
    'СЛОМАТЬ',
    'НЕСИ',
    'СМОТРИ',
    'ЗАБУДЬ',
    'ALOHADAWN',
    'AHINUS',
    'WarKr1me',
    'cerberushopeless',
    '_maslina',
    'TOXA',
    'sillyzhook',
    'MiFRiLiK',
    'stihar',
    'Imperskiy',
    'MOGEKO',
  ];

  let whispersStarted = false;

  function spawnWhisperWord() {
    const layer = document.querySelector('.whisper-layer');
    if (!layer) return;

    const el = document.createElement('span');
    el.className = 'whisper-word';
    el.textContent =
      WHISPER_WORDS[Math.floor(Math.random() * WHISPER_WORDS.length)];

    const r = (min, max) => min + Math.random() * (max - min);
    const t = Math.random();
    let x0, y0, x1, y1, xMid, yMid, x2, y2, rot;

    if (t < 0.33) {
      x0 = r(10, 90);
      y0 = r(10, 90);
      x2 = x0 + r(-15, 15);
      y2 = y0 + r(-30, -10);
      x1 = (x0 + x2) / 2 + r(-5, 5);
      y1 = (y0 + y2) / 2 + r(-5, 5);
      xMid = (x0 + x2) / 2 + r(-10, 10);
      yMid = (y0 + y2) / 2 + r(-10, 10);
      rot = r(-25, 25);
    } else if (t < 0.66) {
      const corners = [
        { x: -10, y: -10 },
        { x: 110, y: -10 },
        { x: -10, y: 110 },
        { x: 110, y: 110 },
      ];
      const sIdx = Math.floor(Math.random() * corners.length);
      let eIdx = Math.floor(Math.random() * corners.length);
      if (eIdx === sIdx) eIdx = (eIdx + 1) % corners.length;

      const s = corners[sIdx],
        e = corners[eIdx];
      x0 = s.x;
      y0 = s.y;
      x2 = e.x;
      y2 = e.y;
      x1 = (x0 + x2) / 2 + r(-10, 10);
      y1 = (y0 + y2) / 2 + r(-10, 10);
      xMid = (x0 + x2) / 2 + r(-20, 20);
      yMid = (y0 + y2) / 2 + r(-20, 20);
      const orientations = [0, 90, 180, 270];
      rot = orientations[Math.floor(Math.random() * orientations.length)];
    } else {
      const fromLeft = Math.random() < 0.5;
      x0 = fromLeft ? -20 : 120;
      x2 = fromLeft ? 120 : -20;
      y0 = r(10, 90);
      y2 = y0 + r(-15, 15);
      x1 = (x0 + x2) / 2 + r(-10, 10);
      y1 = (y0 + y2) / 2 + r(-10, 10);
      xMid = (x0 + x2) / 2 + r(-15, 15);
      yMid = (y0 + y2) / 2 + r(-15, 15);

      if (Math.random() < 0.6) rot = (fromLeft ? 90 : -90) + r(-15, 15);
      else if (Math.random() < 0.3) rot = 180 + r(-20, 20);
      else rot = r(-15, 15);
    }

    const scale = 0.7 + Math.random() * 2.5;
    const duration = 320 + Math.random() * 650;

    el.style.setProperty('--x0', x0 + 'vw');
    el.style.setProperty('--y0', y0 + 'vh');
    el.style.setProperty('--x1', x1 + 'vw');
    el.style.setProperty('--y1', y1 + 'vh');
    el.style.setProperty('--xMid', xMid + 'vw');
    el.style.setProperty('--yMid', yMid + 'vh');
    el.style.setProperty('--x2', x2 + 'vw');
    el.style.setProperty('--y2', y2 + 'vh');
    el.style.setProperty('--scale', scale.toString());
    el.style.setProperty('--wrot', rot + 'deg');
    el.style.setProperty('--wdur', duration + 'ms');

    layer.appendChild(el);
    el.addEventListener('animationend', () => el.remove(), { once: true });
  }

  function startWhispers() {
    if (whispersStarted) return;
    whispersStarted = true;

    const minDelay = 20;
    const maxDelay = 300;

    const loop = () => {
      if (!introEnded) {
        tset(loop, 800);
        return;
      }

      if (Math.random() < 0.85) spawnWhisperWord();

      const next = minDelay + Math.random() * (maxDelay - minDelay);
      tset(loop, next);
    };

    loop();
  }

  // ===============================
  // START EXPERIENCE
  // ===============================
  function startExperience() {
    if (started) return;
    started = true;
    MENU_SETTINGS.introAccepted = true;

    playSelect();

    if (startOverlay) {
      startOverlay.classList.add('start-overlay--hidden');
      tset(() => startOverlay.remove(), 600);
    }

    crossOverlay?.classList.add('inverted-cross-overlay--visible');
    triggerImpactFX();

    startBgm();

    if (skipIntro && skipIntro.checked) {
      revealMenuNow();
      return;
    }

    if (introOverlay) {
      introOverlay.classList.add('intro-overlay--animating');
      introOverlay.classList.remove('intro-overlay--hidden');
      introEnded = false;
    } else {
      endIntro();
    }

    tset(() => {
      if (!started) return;
      triggerFisheyeOnce();
    }, 19000);
  }

  // ===============================
  // INIT + EVENTS
  // ===============================
  if (menuItems.length) setActiveItem(0);

  menuItems.forEach((item, index) => {
    item.addEventListener(
      'mouseenter',
      () => {
        if (!introEnded) return;
        activeIndex = index;
        setActiveItem(activeIndex);
        startFearCycle(item);
        playHover();
      },
      { signal },
    );

    item.addEventListener(
      'mouseleave',
      () => {
        if (!item.classList.contains('menu-item--active')) stopFearCycle(item);
      },
      { signal },
    );

    item.addEventListener(
      'click',
      (event) => {
        if (!introEnded) return;
        const target = event?.target;
        if (target && target.closest('a[href]')) {
          event.preventDefault();
          event.stopPropagation();
        }
        handleAction(item.dataset.action);
      },
      { signal },
    );
  });

  startButton?.addEventListener('click', startExperience, { signal });

  // ===============================
  // TEARDOWN
  // ===============================
  window.__menuChapterTeardown = () => {
    controller.abort();

    timeouts.forEach((id) => clearTimeout(id));
    intervals.forEach((id) => clearInterval(id));

    fadeToken++;

    menuItems.forEach((item) => stopFearCycle(item));
    started = false;
    introEnded = false;
    fisheyeScheduled = false;
    crossBeatsScheduled = false;
    impactBeatsScheduled = false;
  };
})();
