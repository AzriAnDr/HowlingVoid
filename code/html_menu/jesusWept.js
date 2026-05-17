/* =========================================================
   JESUS WEPT
========================================================= */

(() => {
  const getMenuSettings = () =>
    (window.__HOWLING_MENU_SETTINGS = {
      musicEnabled: true,
      musicVolume: 0.6,
      interfaceLanguage: 'russian',
      ...(window.__HOWLING_MENU_SETTINGS || {}),
    });

  const clamp01 = (v) => Math.min(1, Math.max(0, Number(v) || 0));
  const getConfiguredMenuVolume = () =>
    clamp01(getMenuSettings().musicVolume ?? 0.6);
  const isMenuMusicEnabled = () =>
    getMenuSettings().musicEnabled !== false && getConfiguredMenuVolume() > 0;

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
  const menuList = document.querySelector('.menu-list');
  const menuDivider = document.querySelector('.menu-divider');

  const bloodFlash = document.querySelector('.blood-flash');
  const whiteFlash = document.querySelector('.white-flash');

  const crossOverlay = document.querySelector('.inverted-cross-overlay');
  const crossEl = document.querySelector('.inverted-cross');
  const crossFog = document.querySelector('.cross-fog');
  const noiseOverlay = document.querySelector('.noise-overlay');
  const fisheyeLens = document.querySelector('.fisheye-lens');

  const menuTitleBlock = document.querySelector('.menu-title');
  const menuTitleMain = document.querySelector('.menu-title-main');
  const menuTitleSmall = document.querySelector('.menu-title-small');
  const menuTitleSmallGhost = document.querySelector('.menu-title-small-ghost');
  const menuTitleSub = document.querySelector('.menu-title-sub');
  const menuTitleSubGhost = document.querySelector('.menu-title-sub-ghost');
  const whisperLayer = document.querySelector('.whisper-layer');

  const FEAR_VARIANTS = ['menu-fear-v1', 'menu-fear-v2', 'menu-fear-v3'];

  const AUDIO_FADE_IN_MS = 2000;
  const HOVER_SOUND_VOLUME = 0.1;
  const SELECT_SOUND_VOLUME = 0.06;
  const HOVER_THROTTLE_MS = 80;
  const FEAR_CYCLE_INTERVAL_MS = 230;

  const BODY_SHAKE_MS = 400;
  const BLOOD_FLASH_MS = 110;
  const CROSS_BEAT_MS = 260;
  const CROSS_HARD_BEAT_DELAY_MS = 120;
  const CROSS_HARD_BEAT_MS = 220;
  const CROSS_FOG_MS = 500;
  const CROSS_HARD_FOG_MS = 420;
  const FISHEYE_WARP_MS = 800;
  const FISHEYE_BURST_START_MS = 19000;
  const FISHEYE_BURST_COUNT = 5;
  const FISHEYE_BURST_BASE_DELAY_MS = 80;
  const FISHEYE_BURST_STEP_MS = 220;
  const FISHEYE_BURST_RANDOM_MS = 120;
  const FISHEYE_LOOP_MIN_DELAY_MS = 450;
  const FISHEYE_LOOP_RANDOM_DELAY_MS = 600;
  const FISHEYE_EXTRA_GAP_BASE_MS = 140;
  const FISHEYE_EXTRA_GAP_RANDOM_MS = 160;

  const RIFF_AT_SEC = 4.74;
  const CHAPTER_AT_SEC = 9.74;
  const RIFF_END_INTRO_DELAY_MS = 200;
  const RIFF_TITLE_RELEASE_MS = 12500;
  const HARD_GLITCH_MS = 9000;
  const CHAPTER_WHITE_FLASH_MS = 500;
  const CHAPTER_SHADER_MS = 6000;
  const CHAPTER_MENU_REVEAL_DELAY_MS = 6000;
  const START_OVERLAY_REMOVE_MS = 600;

  const BEAT_PATTERN = [
    0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.74, 8.32,
    8.47, 9.74, 9.75, 9.92, 10.09, 10.26, 10.43, 10.6, 10.77, 10.91, 11.08,
    11.25, 11.42, 11.59, 11.76, 11.93, 11.94, 11.95, 11.96, 11.97, 11.98, 11.99,
    12.0, 12.1, 12.27, 12.44, 12.61, 12.78, 12.95, 13.12, 13.29, 13.46, 13.63,
    13.8, 13.97, 14.14, 14.31, 14.48, 14.55, 14.77, 14.92, 15.08, 15.23, 15.38,
    15.53, 15.68, 15.84, 15.97, 16.12, 16.28, 16.42, 16.55, 16.71, 16.87, 17.02,
    17.18, 17.33, 17.48, 17.64, 17.81, 17.98, 18.15, 18.35, 18.49, 18.65, 18.81,
    18.97,
  ];
  const IMPACT_TIMES = [
    0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.43, 4.46,
    4.47,
  ];

  const WHISPER_MIN_DELAY_MS = 20;
  const WHISPER_MAX_DELAY_MS = 300;
  const WHISPER_INTRO_WAIT_MS = 800;
  const WHISPER_SPAWN_CHANCE = 0.85;

  // ===============================
  // STATE + CLEANUP
  // ===============================
  let activeIndex = 0;
  let introEnded = false;
  let started = false;
  let whispersStarted = false;
  let crossBeatsScheduled = false;
  let impactBeatsScheduled = false;
  let fisheyeScheduled = false;
  let fadeToken = 0;
  let lastHoverTime = 0;
  let webglStarted = false;
  let webglCleanup = () => {};

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

  function clearFearVariant(el) {
    FEAR_VARIANTS.forEach((cls) => el.classList.remove(cls));
  }

  function applyRandomFearVariant(el) {
    clearFearVariant(el);
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
    const id = iset(tick, FEAR_CYCLE_INTERVAL_MS);
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

  function playHover() {
    const now = Date.now();
    if (now - lastHoverTime < HOVER_THROTTLE_MS) return;
    lastHoverTime = now;

    if (!hoverSound) return;
    try {
      hoverSound.currentTime = 0;
      hoverSound.volume = HOVER_SOUND_VOLUME;
      hoverSound.play().catch(() => {});
    } catch {}
  }

  function playSelect() {
    if (!selectSound) return;
    try {
      selectSound.currentTime = 0;
      selectSound.volume = SELECT_SOUND_VOLUME;
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
    tset(() => document.body.classList.remove('body-shake'), BODY_SHAKE_MS);

    if (bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(
        () => bloodFlash.classList.remove('blood-flash--active'),
        BLOOD_FLASH_MS,
      );
    }
  }

  function triggerCrossBeat(intensity = 'normal') {
    if (crossEl) {
      crossEl.classList.add('inverted-cross--beat');
      tset(
        () => crossEl.classList.remove('inverted-cross--beat'),
        CROSS_BEAT_MS,
      );
    }

    if (crossFog) {
      crossFog.classList.add('cross-fog--boost');
      tset(() => crossFog.classList.remove('cross-fog--boost'), CROSS_FOG_MS);
    }

    if (intensity === 'hard') {
      tset(() => {
        if (!started) return;
        if (crossEl) {
          crossEl.classList.add('inverted-cross--beat');
          tset(
            () => crossEl.classList.remove('inverted-cross--beat'),
            CROSS_HARD_BEAT_MS,
          );
        }
        if (crossFog) {
          crossFog.classList.add('cross-fog--boost');
          tset(
            () => crossFog.classList.remove('cross-fog--boost'),
            CROSS_HARD_FOG_MS,
          );
        }
      }, CROSS_HARD_BEAT_DELAY_MS);
    }
  }

  function triggerFisheyeOnce() {
    if (!fisheyeLens) return;

    fisheyeLens.classList.remove('fisheye-lens--active');
    void fisheyeLens.offsetWidth;
    fisheyeLens.classList.add('fisheye-lens--active');

    document.body.classList.add('fisheye-warp');
    tset(() => document.body.classList.remove('fisheye-warp'), FISHEYE_WARP_MS);
  }

  function triggerFisheyeBurst(times = FISHEYE_BURST_COUNT) {
    if (!fisheyeLens) return;

    for (let i = 0; i < times; i++) {
      const delay =
        FISHEYE_BURST_BASE_DELAY_MS +
        i * FISHEYE_BURST_STEP_MS +
        Math.random() * FISHEYE_BURST_RANDOM_MS;
      tset(() => triggerFisheyeOnce(), delay);
    }
  }

  function startWebglBackdrop() {
    if (webglStarted) return;
    webglStarted = true;
    webglCleanup = window.__HOWLING_INSTALL_WEBGL_BACKDROP({
      readyClass: 'jesus-wept-webgl-ready',
      colors: ['#030101', '#230405', '#600707', '#110006'],
      intensity: 0.62,
      vignette: 1,
    });
  }

  function revealCrossOverlay() {
    crossOverlay?.classList.add('inverted-cross-overlay--visible');
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

  function revealSupportTitles() {
    menuTitleSmall?.classList.add('menu-title-small--reveal');
    menuTitleSmallGhost?.classList.add('menu-title-small-ghost--anim');
    menuTitleSub?.classList.add('menu-title-sub--reveal');
    menuTitleSubGhost?.classList.add('menu-title-sub-ghost--anim');
  }

  function revealMenuList() {
    startWebglBackdrop();
    menuList?.classList.add('menu-list--visible');
    menuDivider?.classList.add('menu-divider--visible');
  }

  function settleMainTitle() {
    if (!menuTitleMain) return;

    menuTitleMain.style.opacity = '1';
    menuTitleMain.style.transform = 'translateY(0)';
    menuTitleMain.classList.add('menu-title-main--idle');
  }

  function revealMenuNow() {
    endIntro();
    revealCrossOverlay();
    revealSupportTitles();
    revealMenuList();
    settleMainTitle();
  }

  // ===============================
  // AUDIO + SCHEDULING
  // ===============================
  function runRiffBeat() {
    triggerCrossBeat('hard');
    triggerImpactFX();

    if (menuTitleBlock) {
      menuTitleBlock.classList.add('menu-title--riff');
      tset(() => {
        menuTitleBlock.classList.remove('menu-title--riff');
        settleMainTitle();
      }, RIFF_TITLE_RELEASE_MS);
    }

    document.body.classList.add('hard-glitch');
    noiseOverlay?.classList.add('noise-overlay--hard');
    tset(() => {
      document.body.classList.remove('hard-glitch');
      noiseOverlay?.classList.remove('noise-overlay--hard');
    }, HARD_GLITCH_MS);

    if (!introEnded) tset(endIntro, RIFF_END_INTRO_DELAY_MS);
  }

  function runChapterBeat() {
    revealCrossOverlay();

    if (whiteFlash) {
      whiteFlash.classList.add('white-flash--active');
      tset(
        () => whiteFlash.classList.remove('white-flash--active'),
        CHAPTER_WHITE_FLASH_MS,
      );
    }

    triggerCrossBeat('hard');
    document.body.classList.add('post-flash-shader');
    tset(() => {
      document.body.classList.remove('post-flash-shader');
    }, CHAPTER_SHADER_MS);

    revealSupportTitles();

    tset(() => {
      document.body.classList.add('void-shader');
      revealMenuList();
    }, CHAPTER_MENU_REVEAL_DELAY_MS);
  }

  function runBeatAt(timeSec) {
    if (!started) return;

    if (Math.abs(timeSec - RIFF_AT_SEC) < 0.001) {
      runRiffBeat();
      return;
    }

    if (Math.abs(timeSec - CHAPTER_AT_SEC) < 0.001) {
      runChapterBeat();
      return;
    }

    triggerCrossBeat();
  }

  function scheduleTimeline(times, callback) {
    if (!bgm) return;
    const startTime = bgm.currentTime || 0;

    times.forEach((timeSec) => {
      tset(() => callback(timeSec), Math.max(0, (timeSec - startTime) * 1000));
    });
  }

  function scheduleCrossBeats() {
    if (!bgm || crossBeatsScheduled) return;
    crossBeatsScheduled = true;
    scheduleTimeline(BEAT_PATTERN, runBeatAt);
  }

  function scheduleBeatImpacts() {
    if (!bgm || impactBeatsScheduled) return;
    impactBeatsScheduled = true;
    scheduleTimeline(IMPACT_TIMES, () => {
      if (!started) return;
      triggerImpactFX();
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

      const baseDelay =
        FISHEYE_LOOP_MIN_DELAY_MS +
        Math.random() * FISHEYE_LOOP_RANDOM_DELAY_MS;

      tset(() => {
        if (!started) {
          fisheyeScheduled = false;
          return;
        }

        triggerFisheyeBurst();

        if (Math.random() < 0.55) {
          const extraCount = 2 + Math.floor(Math.random() * 3);
          for (let i = 1; i <= extraCount; i++) {
            const gap =
              FISHEYE_EXTRA_GAP_BASE_MS +
              Math.random() * FISHEYE_EXTRA_GAP_RANDOM_MS;
            tset(() => {
              if (!started) return;
              triggerFisheyeBurst();
            }, gap * i);
          }
        }

        queueNextBurst();
      }, baseDelay);
    };

    tset(queueNextBurst, FISHEYE_BURST_START_MS);
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
      fadeBgmTo(getConfiguredMenuVolume(), AUDIO_FADE_IN_MS);
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

    const loop = () => {
      if (!introEnded) {
        tset(loop, WHISPER_INTRO_WAIT_MS);
        return;
      }

      if (Math.random() < WHISPER_SPAWN_CHANCE) spawnWhisperWord();

      const next =
        WHISPER_MIN_DELAY_MS +
        Math.random() * (WHISPER_MAX_DELAY_MS - WHISPER_MIN_DELAY_MS);
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
    getMenuSettings().introAccepted = true;

    playSelect();

    if (startOverlay) {
      startOverlay.classList.add('start-overlay--hidden');
      tset(() => startOverlay.remove(), START_OVERLAY_REMOVE_MS);
    }

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
    }, FISHEYE_BURST_START_MS);
  }

  // ===============================
  // INIT + EVENTS
  // ===============================
  function bindMenuItemEvents(item, index) {
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
  }

  function initMenu() {
    if (menuItems.length) setActiveItem(0);
    menuItems.forEach(bindMenuItemEvents);
    startButton?.addEventListener('click', startExperience, { signal });
  }

  initMenu();

  // ===============================
  // TEARDOWN
  // ===============================
  function clearScheduledWork() {
    timeouts.forEach((id) => clearTimeout(id));
    intervals.forEach((id) => clearInterval(id));
    fadeToken++;
  }

  function resetMenuState() {
    menuItems.forEach((item) => stopFearCycle(item));
    started = false;
    introEnded = false;
    whispersStarted = false;
    fisheyeScheduled = false;
    crossBeatsScheduled = false;
    impactBeatsScheduled = false;
    webglStarted = false;
  }

  window.__menuChapterTeardown = () => {
    controller.abort();
    clearScheduledWork();
    resetMenuState();
    webglCleanup();
    webglCleanup = () => {};
  };
})();
