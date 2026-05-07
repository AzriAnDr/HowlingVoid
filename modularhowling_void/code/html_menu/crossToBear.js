/* =========================================================
   CROSS TO BEAR
========================================================= */

(() => {
  const menuItems = Array.from(document.querySelectorAll('.menu-item'));
  const hoverSound = document.getElementById('hover-sound');
  const selectSound = document.getElementById('select-sound');
  const bgm = document.getElementById('bgm');

  const startOverlay = document.querySelector('.start-overlay');
  const startButton = document.querySelector('.start-button');
  const skipIntro = document.getElementById('skip-intro');

  const introOverlay = document.querySelector('.intro-overlay');
  const introCenter = document.querySelector('.intro-center');
  const introLineSmall = document.querySelector('.intro-line-small');
  const introLineMain = document.querySelector('.intro-line-main');
  const introLineSub = document.querySelector('.intro-line-sub');

  const menuWrapper = document.querySelector('.menu-wrapper');
  const menuList = document.querySelector('.menu-list');
  const menuDivider = document.querySelector('.menu-divider');

  const bloodFlash = document.querySelector('.blood-flash');
  const whiteFlash = document.querySelector('.white-flash');

  const crossOverlay = document.querySelector('.inverted-cross-overlay');
  const crossEl = document.querySelector('.inverted-cross');
  const crossFog = document.querySelector('.cross-fog');
  const noiseOverlay = document.querySelector('.noise-overlay');
  const fisheyeLens = document.querySelector('.fisheye-lens');
  const whisperLayer = document.querySelector('.whisper-layer');

  const menuTitleMain = document.querySelector('.menu-title-main');
  const menuTitleSmall = document.querySelector('.menu-title-small');
  const menuTitleSmallGhost = document.querySelector('.menu-title-small-ghost');
  const menuTitleSub = document.querySelector('.menu-title-sub');
  const menuTitleSubGhost = document.querySelector('.menu-title-sub-ghost');

  const FEAR_VARIANTS = ['menu-fear-v1', 'menu-fear-v2', 'menu-fear-v3'];
  const FEAR_VARIANT_DURATIONS_MS = {
    'menu-fear-v1': 200,
    'menu-fear-v2': 240,
    'menu-fear-v3': 280,
  };
  const FEAR_VARIANT_RESTART_PAD_MS = 30;

  const INTRO_COPY = {
    small: 'a build by',
    main: 'Syndicate: CODE RED',
    sub: 'HOWLING VOID',
  };

  const AUDIO_FADE_IN_MS = 2400;

  const INTRO_FLASH_TOTAL_MS = 3500;
  const INTRO_TAPE_GLITCH_AT_SEC = 2.693;
  const INTRO_FLASH_SOFT_MS = 1950;
  const INTRO_FLASH_HARD_MS = 220;
  const IMPACT_PHASE_START_MS = 4000;
  const IMPACT_PHASE_END_MS = 23000;
  const IMPACT_PULSE_INTERVAL_MS = 100;
  const IMPACT_PULSES_MS = Array.from(
    {
      length: Math.floor(
        (IMPACT_PHASE_END_MS - IMPACT_PHASE_START_MS) /
          IMPACT_PULSE_INTERVAL_MS,
      ),
    },
    (_, index) => index * IMPACT_PULSE_INTERVAL_MS,
  );
  const INTRO_FLASH_TIMELINE = [
    0.052, 0.059, 0.093, 0.126, 0.178, 0.202, 0.215, 0.229, 0.24, 0.255, 0.263,
    0.273, 0.294, 0.3, 0.317, 0.32, 0.33, 0.341, 0.358, 0.366, 0.371, 0.382,
    0.41, 0.43, 0.437, 0.441, 0.452, 0.459, 0.478, 0.506, 0.521, 0.525, 0.526,
    0.527, 0.53, 0.537, 0.542, 0.551, 0.559, 0.562, 0.566, 0.57, 0.575, 0.578,
    0.587, 0.593, 0.602, 0.61, 0.62, 0.63, 0.643, 0.699, 0.713, 0.72, 0.726,
    0.733, 0.75, 0.77, 0.799, 0.828, 0.832, 0.835, 0.84, 0.846, 0.853, 0.858,
    0.864, 0.869, 0.881, 0.939, 0.946, 0.972, 0.981, 0.996, 1.008, 1.033, 1.034,
    1.035, 1.036, 1.037, 1.046, 1.052, 1.062, 1.07, 1.08, 1.09, 1.097, 1.103,
    1.105, 1.111, 1.119, 1.127, 1.135, 1.197, 1.263, 1.283, 1.302, 1.317, 1.331,
    1.383, 1.395, 1.413, 1.422, 1.454, 1.469, 1.473, 1.49, 1.542, 1.556, 1.62,
    1.639, 1.688, 1.706, 1.73, 1.75, 1.78, 1.8, 1.83, 1.85, 1.87, 1.9, 1.92,
    1.95, 1.963, 2.03, 2.042, 2.05, 2.062, 2.07, 2.08, 2.1, 2.18, 2.21, 2.3,
    2.4, 2.5, 2.6, 2.65, 2.9, 3.0, 3.1, 3.261, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8,
    3.9,
  ];
  const INTRO_FLASH_CUTOFF_MS = IMPACT_PHASE_START_MS - INTRO_FLASH_HARD_MS;
  const EFFECTIVE_INTRO_FLASH_TIMELINE = INTRO_FLASH_TIMELINE.filter(
    (timeSec) => Math.round(timeSec * 1000) < INTRO_FLASH_CUTOFF_MS,
  );

  const INTRO_HIDE_AT_MS = IMPACT_PHASE_START_MS;
  const TITLE_SEQUENCE_START_MS = 10000;
  const SERVER_TITLE_REVEAL_AT_MS = 10000;
  const CHAPTER_TITLE_REVEAL_AT_MS = 13000;
  const TEAM_TITLE_REVEAL_AT_MS = 16000;
  const MENU_LIST_REVEAL_AT_MS = IMPACT_PHASE_END_MS + 500;
  const CEREMONY_LOOP_DELAY_MS = 17800;
  const CEREMONY_PULSES_MS = [900, 1900, 3050, 4550, 6100, 7600, 9800, 12100];
  const TEAM_TITLE_TEXT = 'Syndicate: CODE RED';
  const CHAPTER_TITLE_TEXT = 'JESUS WEPT';
  const SERVER_TITLE_TEXT =
    (
      menuTitleMain?.textContent ||
      menuTitleMain?.dataset?.text ||
      'HOWLING VOID'
    ).trim() || 'HOWLING VOID';

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

  let activeIndex = 0;
  let introEnded = false;
  let started = false;
  let whispersStarted = false;
  let ceremonyStarted = false;
  let fisheyeLoopStarted = false;

  const controller = new AbortController();
  const { signal } = controller;
  const timeouts = [];
  const intervals = [];
  const fearTimers = new WeakMap();

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

  const clamp01 = (v) => Math.min(1, Math.max(0, Number(v) || 0));

  let fadeToken = 0;
  let lastHoverTime = 0;

  function setIntroCopy() {
    if (introLineSmall) introLineSmall.textContent = INTRO_COPY.small;
    if (introLineMain) introLineMain.textContent = INTRO_COPY.main;
    if (introLineSub) introLineSub.textContent = INTRO_COPY.sub;
  }

  function fadeBgmTo(targetVolume, duration = 1200) {
    if (!bgm) return;

    const token = ++fadeToken;
    const from = clamp01(bgm.volume);
    const to = clamp01(targetVolume);
    const dur = Math.max(1, Number(duration) || 1);
    const start = performance.now();

    const step = (now) => {
      if (token !== fadeToken) return;
      const settings = window.__HOWLING_MENU_SETTINGS || {};
      if (settings.musicEnabled === false || clamp01(settings.musicVolume) <= 0.0001) {
        try {
          bgm.pause();
        } catch {}
        return;
      }
      const t = Math.min(1, (now - start) / dur);
      bgm.volume = clamp01(from + (to - from) * t);
      if (t < 1) requestAnimationFrame(step);
    };

    requestAnimationFrame(step);
  }

  function playHover() {
    const now = Date.now();
    if (now - lastHoverTime < 80 || !hoverSound) return;
    lastHoverTime = now;

    try {
      hoverSound.currentTime = 0;
      hoverSound.volume = 0.28;
      hoverSound.play().catch(() => {});
    } catch {}
  }

  function playSelect() {
    if (!selectSound) return;
    try {
      selectSound.currentTime = 0;
      selectSound.volume = 0.3;
      selectSound.play().catch(() => {});
    } catch {}
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

    console.log('[CrossToBear] Menu action:', action);
  }

  function clearFearVariant(item) {
    FEAR_VARIANTS.forEach((cls) => item.classList.remove(cls));
  }

  function currentFearVariant(item) {
    return FEAR_VARIANTS.find((cls) => item.classList.contains(cls));
  }

  function randomFearVariantExcept(current) {
    const variants = FEAR_VARIANTS.filter((cls) => cls !== current);
    return variants[Math.floor(Math.random() * variants.length)];
  }

  function applyRandomFearVariant(item, previous = currentFearVariant(item)) {
    clearFearVariant(item);
    const variant = randomFearVariantExcept(previous);
    item.classList.add(variant);
    return variant;
  }

  function stopFearCycle(item) {
    const id = fearTimers.get(item);
    if (id) {
      clearTimeout(id);
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
        clearFearVariant(item);
        stopFearCycle(item);
        return;
      }
      const variant = applyRandomFearVariant(item);
      const delay =
        (FEAR_VARIANT_DURATIONS_MS[variant] || 220) +
        FEAR_VARIANT_RESTART_PAD_MS;
      fearTimers.set(item, tset(tick, delay));
    };

    tick();
  }

  function setActiveItem(index) {
    menuItems.forEach((item, itemIndex) => {
      const isActive = itemIndex === index;
      item.classList.toggle('menu-item--active', isActive);
      if (isActive) {
        startFearCycle(item);
      } else {
        clearFearVariant(item);
        stopFearCycle(item);
      }
    });
  }

  function revealSupportTitles() {
    menuTitleSmall?.classList.add('menu-title-small--reveal');
    menuTitleSmallGhost?.classList.add('menu-title-small-ghost--anim');
    menuTitleSub?.classList.add('menu-title-sub--reveal');
    menuTitleSubGhost?.classList.add('menu-title-sub-ghost--anim');
  }

  function revealMenuList() {
    menuList?.classList.add('menu-list--visible');
    menuDivider?.classList.add('menu-divider--visible');
  }

  function settleMainTitle() {
    if (!menuTitleMain) return;
    menuTitleMain.style.opacity = '1';
    menuTitleMain.style.transform = 'translateY(0)';
    menuTitleMain.classList.remove('menu-title-main--idle');

    if ((menuTitleMain.dataset.text || '').trim() === SERVER_TITLE_TEXT) {
      menuTitleMain.classList.add('menu-title-main--chaos');
    } else {
      menuTitleMain.classList.remove('menu-title-main--chaos');
    }
  }

  function setMainTitleText(text) {
    if (!menuTitleMain) return;
    menuTitleMain.classList.remove('menu-title-main--chaos');

    if (text === SERVER_TITLE_TEXT) {
      menuTitleMain.innerHTML = Array.from(text)
        .map((char) => {
          if (char === ' ') {
            return '<span class="menu-title-letter menu-title-letter--space">&nbsp;</span>';
          }

          return `<span class="menu-title-letter">${char}</span>`;
        })
        .join('');
    } else {
      menuTitleMain.textContent = text;
    }

    menuTitleMain.dataset.text = text;
  }

  function triggerSoftTitleFlash() {
    document.body.classList.remove('dark-title-flash');
    void document.body.offsetWidth;
    document.body.classList.add('dark-title-flash');
    tset(() => document.body.classList.remove('dark-title-flash'), 220);
  }

  function flashTitleStep(text) {
    if (!menuTitleMain) return;

    triggerSoftTitleFlash();

    menuTitleMain.classList.remove(
      'menu-title-main--idle',
      'menu-title-main--chaos',
    );
    menuTitleMain.style.transition = 'none';
    menuTitleMain.style.opacity = '0';
    menuTitleMain.style.filter = 'blur(8px)';
    menuTitleMain.style.transform = 'translateY(10px) scale(1.035)';
    setMainTitleText(text);
    void menuTitleMain.offsetWidth;

    menuTitleMain.style.transition =
      'opacity 0.42s ease-out, transform 0.42s ease-out, filter 0.42s ease-out';

    requestAnimationFrame(() => {
      menuTitleMain.style.opacity = '1';
      menuTitleMain.style.filter = 'blur(0)';
      menuTitleMain.style.transform = 'translateY(0) scale(1)';
      tset(() => {
        if (!menuTitleMain) return;
        if ((menuTitleMain.dataset.text || '').trim() === SERVER_TITLE_TEXT) {
          menuTitleMain.classList.add('menu-title-main--chaos');
        }
      }, 460);
    });
  }

  function revealSupportLine(type, text) {
    const isSmall = type === 'small';
    const target = isSmall ? menuTitleSmall : menuTitleSub;
    const ghost = isSmall ? menuTitleSmallGhost : menuTitleSubGhost;

    if (!target) return;

    triggerSoftTitleFlash();

    target.classList.remove(
      'menu-title-small--reveal',
      'menu-title-sub--reveal',
    );
    ghost?.classList.remove(
      'menu-title-small-ghost--anim',
      'menu-title-sub-ghost--anim',
    );
    target.style.transition = 'none';
    target.style.opacity = '0';
    target.style.filter = 'blur(6px)';
    target.style.transform = 'translateY(8px)';
    target.textContent = text;

    if (ghost) {
      ghost.textContent = text;
    }

    void target.offsetWidth;
    target.style.transition =
      'opacity 0.42s ease-out, transform 0.42s ease-out, filter 0.42s ease-out';

    requestAnimationFrame(() => {
      target.style.opacity = '1';
      target.style.filter = 'blur(0)';
      target.style.transform = 'translateY(0)';
    });
  }

  function runFinalTitleSequence() {
    flashTitleStep(SERVER_TITLE_TEXT);

    tset(() => {
      if (!started) return;
      revealSupportLine('sub', CHAPTER_TITLE_TEXT);
    }, CHAPTER_TITLE_REVEAL_AT_MS - TITLE_SEQUENCE_START_MS);

    tset(() => {
      if (!started) return;
      revealSupportLine('small', TEAM_TITLE_TEXT);
    }, TEAM_TITLE_REVEAL_AT_MS - TITLE_SEQUENCE_START_MS);
  }

  function setSupportLineImmediate(type, text) {
    const isSmall = type === 'small';
    const target = isSmall ? menuTitleSmall : menuTitleSub;
    const ghost = isSmall ? menuTitleSmallGhost : menuTitleSubGhost;

    if (!target) return;

    target.classList.remove(
      'menu-title-small--reveal',
      'menu-title-sub--reveal',
    );
    ghost?.classList.remove(
      'menu-title-small-ghost--anim',
      'menu-title-sub-ghost--anim',
    );

    target.textContent = text;
    target.style.transition = 'none';
    target.style.opacity = '1';
    target.style.filter = 'blur(0)';
    target.style.transform = 'translateY(0)';

    if (ghost) {
      ghost.textContent = text;
      ghost.style.opacity = '0';
    }
  }

  function triggerImpactFX(strength = 'soft') {
    document.body.classList.add('body-shake');
    tset(
      () => document.body.classList.remove('body-shake'),
      strength === 'hard' ? 520 : 320,
    );

    if (bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(
        () => bloodFlash.classList.remove('blood-flash--active'),
        strength === 'hard' ? 180 : 100,
      );
    }
  }

  function triggerCrossBeat(intensity = 'normal') {
    if (crossEl) {
      crossEl.classList.add('inverted-cross--beat');
      tset(() => crossEl.classList.remove('inverted-cross--beat'), 260);
    }

    if (crossFog) {
      crossFog.classList.add('cross-fog--boost');
      tset(() => crossFog.classList.remove('cross-fog--boost'), 520);
    }

    if (intensity === 'hard') {
      tset(() => {
        if (crossEl) {
          crossEl.classList.add('inverted-cross--beat');
          tset(() => crossEl.classList.remove('inverted-cross--beat'), 220);
        }
      }, 130);
    }
  }

  function triggerIntroGlitchFlash() {
    if (bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(() => bloodFlash.classList.remove('blood-flash--active'), 240);
    }

    if (whiteFlash) {
      whiteFlash.classList.add('white-flash--active');
      tset(() => whiteFlash.classList.remove('white-flash--active'), 80);
    }

    noiseOverlay?.classList.add('noise-overlay--hard');
    tset(() => noiseOverlay?.classList.remove('noise-overlay--hard'), 320);
  }

  function triggerTimelineGlitch(mode = 'soft', index = 0) {
    const isHard = mode === 'hard';
    const shouldTear =
      isHard &&
      (index % 3 === 0 ||
        index % 5 === 0 ||
        index === INTRO_FLASH_TIMELINE.length - 1);

    document.body.classList.remove('body-shake', 'void-shader');
    void document.body.offsetWidth;
    document.body.classList.add('body-shake');
    document.body.classList.add('void-shader');

    noiseOverlay?.classList.add('noise-overlay--hard');

    if (isHard) {
      triggerIntroGlitchFlash();
      tset(() => triggerFisheyeOnce(), 24);
    } else if (index % 4 === 0) {
      if (whiteFlash) {
        whiteFlash.classList.remove('white-flash--active');
        void whiteFlash.offsetWidth;
        whiteFlash.classList.add('white-flash--active');
        tset(() => whiteFlash?.classList.remove('white-flash--active'), 45);
      }
    }

    if (shouldTear) {
      tset(() => triggerTapeGlitchBurst(), 18);
    }

    tset(
      () => {
        document.body.classList.remove('body-shake', 'void-shader');
        noiseOverlay?.classList.remove('noise-overlay--hard');
      },
      isHard ? 260 : 140,
    );
  }

  function clearImpactPhaseState() {
    introCenter?.classList.remove('intro-center--hidden');

    crossOverlay?.classList.remove(
      'inverted-cross-overlay--contour-flash',
      'inverted-cross-overlay--contour-soft',
      'inverted-cross-overlay--contour-hard',
      'inverted-cross-overlay--contour-breaker',
    );

    document.body.classList.remove(
      'red-contour-shader',
      'red-contour-shader--hard',
      'red-contour-shader--breaker',
      'impact-rumble',
      'impact-phase-live',
    );
  }

  function transitionToImpactPhase() {
    introOverlay?.classList.add('intro-overlay--hidden');
    introCenter?.classList.add('intro-center--hidden');
    clearFlashIntroState();

    bloodFlash?.classList.remove('blood-flash--active');
    whiteFlash?.classList.remove('white-flash--active');
    noiseOverlay?.classList.remove('noise-overlay--hard');
    fisheyeLens?.classList.remove('fisheye-lens--active');

    document.body.classList.remove(
      'body-shake',
      'void-shader',
      'fisheye-warp',
      'tape-glitch-burst',
      'impact-rumble',
      'red-contour-shader',
      'red-contour-shader--hard',
      'red-contour-shader--breaker',
    );

    crossOverlay?.classList.add('inverted-cross-overlay--visible');
  }

  function triggerRedContourPulse(intensity = 'hard', index = 0) {
    const isHard = intensity === 'hard';
    const isAccent = index % 4 === 1 || index % 4 === 3;
    const isBreaker = index === 7 || index === 15 || index === 21;

    crossOverlay?.classList.add('inverted-cross-overlay--visible');
    crossOverlay?.classList.remove(
      'inverted-cross-overlay--contour-flash',
      'inverted-cross-overlay--contour-soft',
      'inverted-cross-overlay--contour-hard',
      'inverted-cross-overlay--contour-breaker',
    );

    document.body.classList.remove(
      'red-contour-shader',
      'red-contour-shader--hard',
      'red-contour-shader--breaker',
      'impact-rumble',
    );

    void crossOverlay?.offsetWidth;
    void document.body.offsetWidth;
    if (crossEl) void crossEl.offsetWidth;

    crossOverlay?.classList.add('inverted-cross-overlay--contour-flash');
    crossOverlay?.classList.add(
      isBreaker
        ? 'inverted-cross-overlay--contour-breaker'
        : isHard
          ? 'inverted-cross-overlay--contour-hard'
          : 'inverted-cross-overlay--contour-soft',
    );

    document.body.classList.add('red-contour-shader');
    document.body.classList.add(
      isBreaker ? 'red-contour-shader--breaker' : 'red-contour-shader--hard',
    );
    document.body.classList.add('impact-rumble');

    triggerCrossBeat(isBreaker || isHard ? 'hard' : 'normal');
    triggerImpactFX(isBreaker || isHard ? 'hard' : 'soft');

    noiseOverlay?.classList.add('noise-overlay--hard');
    crossFog?.classList.add('cross-fog--boost');

    if (isHard || isAccent) {
      triggerIntroGlitchFlash();
    }

    if (isAccent) {
      tset(() => triggerFisheyeOnce(), 18);
    }

    if (isBreaker) {
      tset(() => triggerFisheyeBurst(3), 24);
      tset(() => triggerTapeGlitchBurst(), 36);
    }

    tset(
      () => {
        crossOverlay?.classList.remove(
          'inverted-cross-overlay--contour-flash',
          'inverted-cross-overlay--contour-soft',
          'inverted-cross-overlay--contour-hard',
          'inverted-cross-overlay--contour-breaker',
        );
        document.body.classList.remove(
          'red-contour-shader',
          'red-contour-shader--hard',
          'red-contour-shader--breaker',
          'impact-rumble',
          'body-shake',
        );
        noiseOverlay?.classList.remove('noise-overlay--hard');
        crossFog?.classList.remove('cross-fog--boost');
      },
      isBreaker ? 340 : isHard ? 240 : 180,
    );
  }

  function startCrossImpactPhase() {
    introCenter?.classList.add('intro-center--hidden');
    crossOverlay?.classList.add('inverted-cross-overlay--visible');

    document.body.classList.remove('post-impact-live');
    document.body.classList.add('impact-phase-live');

    // Fire the first impact immediately on the 4s transition,
    // then continue the barrage from the remaining timeline points.
    triggerRedContourPulse('hard', 0);

    IMPACT_PULSES_MS.slice(1).forEach((offset, index) => {
      tset(() => {
        if (!started) return;

        const pulseIndex = index + 1;
        const intensity =
          pulseIndex === IMPACT_PULSES_MS.length - 1 ||
          pulseIndex % 4 === 1 ||
          pulseIndex % 4 === 3
            ? 'hard'
            : 'soft';

        triggerRedContourPulse(intensity, pulseIndex);
      }, offset);
    });

    tset(
      () => {
        document.body.classList.remove('impact-phase-live');
        document.body.classList.add('post-impact-live');
        clearImpactPhaseState();
      },
      IMPACT_PHASE_END_MS - IMPACT_PHASE_START_MS + 120,
    );
  }

  function triggerTapeGlitchBurst() {
    document.body.classList.remove('tape-glitch-burst');
    void document.body.offsetWidth;
    document.body.classList.add('tape-glitch-burst');

    if (whiteFlash) {
      whiteFlash.classList.remove('white-flash--active');
      void whiteFlash.offsetWidth;
      whiteFlash.classList.add('white-flash--active');
      tset(() => whiteFlash?.classList.remove('white-flash--active'), 65);
    }

    if (bloodFlash) {
      bloodFlash.classList.remove('blood-flash--active');
      void bloodFlash.offsetWidth;
      bloodFlash.classList.add('blood-flash--active');
      tset(() => bloodFlash?.classList.remove('blood-flash--active'), 120);
    }

    noiseOverlay?.classList.add('noise-overlay--hard');
    triggerFisheyeOnce();

    tset(() => {
      document.body.classList.remove('tape-glitch-burst');
      noiseOverlay?.classList.remove('noise-overlay--hard');
    }, 420);
  }

  function triggerFisheyeOnce() {
    if (!fisheyeLens) return;

    fisheyeLens.classList.remove('fisheye-lens--active');
    void fisheyeLens.offsetWidth;
    fisheyeLens.classList.add('fisheye-lens--active');

    document.body.classList.add('fisheye-warp');
    tset(() => document.body.classList.remove('fisheye-warp'), 760);
  }

  function triggerFisheyeBurst(times = 3) {
    for (let i = 0; i < times; i++) {
      const delay = 70 + i * 180 + Math.random() * 90;
      tset(() => triggerFisheyeOnce(), delay);
    }
  }

  function runCeremonyPulse(index) {
    const isHeavy = index === 2 || index === 5 || index === 7;

    triggerCrossBeat(isHeavy ? 'hard' : 'normal');
    triggerImpactFX(isHeavy ? 'hard' : 'soft');

    if (index === 4 || isHeavy) {
      triggerFisheyeBurst(isHeavy ? 4 : 2);
    }

    if (isHeavy) {
      document.body.classList.add('post-flash-shader');
      noiseOverlay?.classList.add('noise-overlay--hard');
      tset(() => {
        document.body.classList.remove('post-flash-shader');
        noiseOverlay?.classList.remove('noise-overlay--hard');
      }, 2200);
    }
  }

  function scheduleCeremonyLoop() {
    if (ceremonyStarted) return;
    ceremonyStarted = true;
    document.body.classList.add('post-impact-live');

    CEREMONY_PULSES_MS.forEach((delay, index) => {
      tset(() => {
        if (!started) return;
        runCeremonyPulse(index);
      }, delay);
    });

    tset(() => {
      if (!started || !bgm || bgm.paused) {
        ceremonyStarted = false;
        return;
      }
      ceremonyStarted = false;
      scheduleCeremonyLoop();
    }, CEREMONY_LOOP_DELAY_MS);
  }

  function schedulePostImpactFisheyeLoop() {
    if (fisheyeLoopStarted) return;
    fisheyeLoopStarted = true;

    const queueNextBurst = () => {
      if (!started || !bgm || bgm.paused) {
        fisheyeLoopStarted = false;
        return;
      }

      const baseDelay = 450 + Math.random() * 600;

      tset(() => {
        if (!started || !bgm || bgm.paused) {
          fisheyeLoopStarted = false;
          return;
        }

        triggerFisheyeBurst();

        if (Math.random() < 0.55) {
          const extraCount = 2 + Math.floor(Math.random() * 3);
          for (let i = 1; i <= extraCount; i++) {
            const gap = 140 + Math.random() * 160;
            tset(() => {
              if (!started || !bgm || bgm.paused) return;
              triggerFisheyeBurst();
            }, gap * i);
          }
        }

        queueNextBurst();
      }, baseDelay);
    };

    queueNextBurst();
  }

  function clearFlashIntroState() {
    introOverlay?.classList.remove('intro-overlay--flash-phase');

    introCenter?.classList.remove(
      'intro-center--preflash',
      'intro-center--flash-on',
      'intro-center--flash-soft',
      'intro-center--flash-hard',
      'intro-center--afterimage-soft',
      'intro-center--afterimage-hard',
    );

    crossOverlay?.classList.remove(
      'inverted-cross-overlay--visible',
      'inverted-cross-overlay--flash-on',
      'inverted-cross-overlay--flash-soft',
      'inverted-cross-overlay--flash-hard',
      'inverted-cross-overlay--afterimage-soft',
      'inverted-cross-overlay--afterimage-hard',
    );
  }

  function flashIntroOnce(mode = 'hard') {
    if (!introCenter) return;

    introOverlay?.classList.add('intro-overlay--flash-phase');

    introCenter.classList.remove(
      'intro-center--flash-on',
      'intro-center--flash-soft',
      'intro-center--flash-hard',
      'intro-center--afterimage-soft',
      'intro-center--afterimage-hard',
    );

    crossOverlay?.classList.remove(
      'inverted-cross-overlay--visible',
      'inverted-cross-overlay--flash-on',
      'inverted-cross-overlay--flash-soft',
      'inverted-cross-overlay--flash-hard',
      'inverted-cross-overlay--afterimage-soft',
      'inverted-cross-overlay--afterimage-hard',
    );

    void introCenter.offsetWidth;
    if (crossOverlay) void crossOverlay.offsetWidth;

    introCenter.classList.add('intro-center--flash-on');
    introCenter.classList.add(
      mode === 'soft' ? 'intro-center--flash-soft' : 'intro-center--flash-hard',
    );
    introCenter.classList.add(
      mode === 'soft'
        ? 'intro-center--afterimage-soft'
        : 'intro-center--afterimage-hard',
    );

    crossOverlay?.classList.add('inverted-cross-overlay--visible');
    crossOverlay?.classList.add('inverted-cross-overlay--flash-on');
    crossOverlay?.classList.add(
      mode === 'soft'
        ? 'inverted-cross-overlay--flash-soft'
        : 'inverted-cross-overlay--flash-hard',
    );
    crossOverlay?.classList.add(
      mode === 'soft'
        ? 'inverted-cross-overlay--afterimage-soft'
        : 'inverted-cross-overlay--afterimage-hard',
    );

    if (mode === 'hard') {
      triggerCrossBeat('hard');
    } else {
      triggerCrossBeat('normal');
    }

    if (bloodFlash && mode === 'hard') {
      bloodFlash.classList.remove('blood-flash--active');
      void bloodFlash.offsetWidth;
      bloodFlash.classList.add('blood-flash--active');

      tset(() => {
        bloodFlash?.classList.remove('blood-flash--active');
      }, 80);
    }

    tset(
      () => {
        introCenter?.classList.remove(
          'intro-center--flash-on',
          'intro-center--flash-soft',
          'intro-center--flash-hard',
          'intro-center--afterimage-soft',
          'intro-center--afterimage-hard',
        );

        crossOverlay?.classList.remove(
          'inverted-cross-overlay--flash-on',
          'inverted-cross-overlay--flash-soft',
          'inverted-cross-overlay--flash-hard',
          'inverted-cross-overlay--afterimage-soft',
          'inverted-cross-overlay--afterimage-hard',
          'inverted-cross-overlay--visible',
        );
      },
      mode === 'soft' ? INTRO_FLASH_SOFT_MS : INTRO_FLASH_HARD_MS,
    );
  }

  function runIntroFlashSequence() {
    setIntroCopy();

    if (introOverlay) {
      introOverlay.classList.remove(
        'intro-overlay--hidden',
        'intro-overlay--animating',
      );
      introOverlay.classList.add('intro-overlay--flash-phase');
    }

    if (introCenter) {
      introCenter.classList.add('intro-center--preflash');
    }

    EFFECTIVE_INTRO_FLASH_TIMELINE.forEach((timeSec, index) => {
      const ms = Math.round(timeSec * 1000);

      tset(() => {
        if (!started) return;

        const mode =
          index === 2 ||
          index === 5 ||
          index === 8 ||
          index === 12 ||
          index === 15 ||
          index === 18 ||
          index % 11 === 0 ||
          index === EFFECTIVE_INTRO_FLASH_TIMELINE.length - 1
            ? 'hard'
            : 'soft';

        flashIntroOnce(mode);
        triggerTimelineGlitch(mode, index);

        if (Math.abs(timeSec - INTRO_TAPE_GLITCH_AT_SEC) < 0.001) {
          triggerTapeGlitchBurst();
        }
      }, ms);
    });

    tset(
      () => {
        if (!started) return;
        clearFlashIntroState();
      },
      Math.min(INTRO_FLASH_TOTAL_MS, INTRO_FLASH_CUTOFF_MS),
    );
  }

  function endIntro() {
    if (introEnded) return;
    introEnded = true;

    introOverlay?.classList.add('intro-overlay--hidden');
    introCenter?.classList.remove('intro-center--hidden');
    crossOverlay?.classList.add('inverted-cross-overlay--visible');

    menuWrapper?.classList.add('menu-wrapper--visible');
    startWhispers();
  }

  function revealMenuNow() {
    clearFlashIntroState();
    clearImpactPhaseState();

    introOverlay?.classList.add('intro-overlay--hidden');
    introCenter?.classList.add('intro-center--hidden');
    crossOverlay?.classList.add('inverted-cross-overlay--visible');

    document.body.classList.remove('impact-phase-live');
    document.body.classList.add('post-impact-live', 'void-shader');

    endIntro();
    setSupportLineImmediate('small', TEAM_TITLE_TEXT);
    setSupportLineImmediate('sub', CHAPTER_TITLE_TEXT);
    setMainTitleText(SERVER_TITLE_TEXT);
    revealMenuList();
    settleMainTitle();
    scheduleCeremonyLoop();
    schedulePostImpactFisheyeLoop();
  }

  function startBgm() {
    if (!bgm) return;

    const settings = window.__HOWLING_MENU_SETTINGS || {};
    const settingsVolume = clamp01(settings.musicVolume);
    const settingsEnabled = settings.musicEnabled !== false;
    if (!settingsEnabled || settingsVolume <= 0.0001) {
      try {
        bgm.pause();
      } catch {}
      return;
    }

    bgm.loop = true;
    bgm.volume = 0;

    const afterPlay = () => {
      fadeBgmTo(settingsVolume, AUDIO_FADE_IN_MS);
    };

    const promise = bgm.play();
    if (promise && promise.then) promise.then(afterPlay).catch(() => {});
    else afterPlay();
  }

  function spawnWhisperWord() {
    if (!whisperLayer) return;

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

    whisperLayer.appendChild(el);
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

  function startExperience() {
    if (started) return;
    started = true;

    window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
    window.__HOWLING_MENU_SETTINGS.introAccepted = true;

    playSelect();
    setIntroCopy();

    if (startOverlay) {
      startOverlay.classList.add('start-overlay--hidden');
      tset(() => startOverlay.remove(), 600);
    }

    triggerImpactFX('soft');
    startBgm();

    if (skipIntro?.checked) {
      revealMenuNow();
      return;
    }

    if (introOverlay) {
      runIntroFlashSequence();
    } else {
      endIntro();
    }

    tset(
      transitionToImpactPhase,
      Math.max(INTRO_HIDE_AT_MS, INTRO_FLASH_TOTAL_MS),
    );
    tset(startCrossImpactPhase, IMPACT_PHASE_START_MS);
    tset(endIntro, TITLE_SEQUENCE_START_MS);
    tset(runFinalTitleSequence, TITLE_SEQUENCE_START_MS);
    tset(() => {
      if (!started || !bgm || bgm.paused) return;
      document.body.classList.add('post-impact-live');
      scheduleCeremonyLoop();
      schedulePostImpactFisheyeLoop();
    }, IMPACT_PHASE_END_MS);

    tset(() => {
      document.body.classList.add('void-shader');
      revealMenuList();
    }, MENU_LIST_REVEAL_AT_MS);
  }

  if (menuItems.length) setActiveItem(0);
  setIntroCopy();

  menuItems.forEach((item, index) => {
    item.addEventListener(
      'mouseenter',
      () => {
        if (!introEnded) return;
        activeIndex = index;
        setActiveItem(activeIndex);
        playHover();
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

  window.__menuChapterTeardown = () => {
    controller.abort();
    timeouts.forEach((id) => clearTimeout(id));
    intervals.forEach((id) => clearInterval(id));
    fadeToken++;
    menuItems.forEach((item) => {
      clearFearVariant(item);
      stopFearCycle(item);
    });

    started = false;
    introEnded = false;
    whispersStarted = false;
    ceremonyStarted = false;
    fisheyeLoopStarted = false;

    introOverlay?.classList.remove(
      'intro-overlay--flash-phase',
      'intro-overlay--animating',
      'intro-overlay--hidden',
    );

    introCenter?.classList.remove(
      'intro-center--preflash',
      'intro-center--flash-on',
      'intro-center--flash-soft',
      'intro-center--flash-hard',
      'intro-center--hidden',
    );

    crossOverlay?.classList.remove(
      'inverted-cross-overlay--visible',
      'inverted-cross-overlay--flash-on',
      'inverted-cross-overlay--flash-soft',
      'inverted-cross-overlay--flash-hard',
      'inverted-cross-overlay--contour-flash',
    );

    crossEl?.classList.remove('inverted-cross--beat');
    crossFog?.classList.remove('cross-fog--boost');

    bloodFlash?.classList.remove('blood-flash--active');
    whiteFlash?.classList.remove('white-flash--active');
    noiseOverlay?.classList.remove('noise-overlay--hard');
    fisheyeLens?.classList.remove('fisheye-lens--active');

    menuWrapper?.classList.remove('menu-wrapper--visible');
    menuList?.classList.remove('menu-list--visible');
    menuDivider?.classList.remove('menu-divider--visible');

    menuTitleSmall?.classList.remove('menu-title-small--reveal');
    menuTitleSmallGhost?.classList.remove('menu-title-small-ghost--anim');
    menuTitleSub?.classList.remove('menu-title-sub--reveal');
    menuTitleSubGhost?.classList.remove('menu-title-sub-ghost--anim');
    menuTitleMain?.classList.remove('menu-title-main--idle');

    document.body.classList.remove(
      'body-shake',
      'fisheye-warp',
      'post-impact-live',
      'post-flash-shader',
      'red-contour-shader',
      'tape-glitch-burst',
      'void-shader',
    );
  };
})();
