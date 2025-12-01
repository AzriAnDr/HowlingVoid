// ===============================
// ELEMENTS
// ===============================

const menuItems = Array.from(document.querySelectorAll('.menu-item'));

const hoverSound = document.getElementById('hover-sound');
const selectSound = document.getElementById('select-sound');
const bgm = document.getElementById('bgm');

const startOverlay = document.querySelector('.start-overlay');
const startButton = document.querySelector('.start-button');

const introOverlay = document.querySelector('.intro-overlay');
const menuWrapper = document.querySelector('.menu-wrapper');

const bloodFlash = document.querySelector('.blood-flash');
const whiteFlash = document.querySelector('.white-flash');

const crossOverlay = document.querySelector('.inverted-cross-overlay');
const crossEl = document.querySelector('.inverted-cross');
const crossFog = document.querySelector('.cross-fog');
const noiseOverlay = document.querySelector('.noise-overlay');

const subTitle = document.querySelector('.menu-title-sub');
const smallTitle = document.querySelector('.menu-title-small');
const menuTitleBlock = document.querySelector('.menu-title');
const FEAR_VARIANTS = ['menu-fear-v1', 'menu-fear-v2', 'menu-fear-v3'];
const fisheyeLens = document.querySelector('.fisheye-lens');

let activeIndex = 0;
let introEnded = false;
let started = false;

// ===============================
// MENU HANDLING
// ===============================
function applyRandomFearVariant(el) {
  // снимаем старые профили
  FEAR_VARIANTS.forEach((cls) => el.classList.remove(cls));
  // выбираем новый
  const v = FEAR_VARIANTS[Math.floor(Math.random() * FEAR_VARIANTS.length)];
  el.classList.add(v);
}
const fearTimers = new WeakMap();

function startFearCycle(item) {
  stopFearCycle(item);

  function tick() {
    if (
      !item.matches(':hover') &&
      !item.classList.contains('menu-item--active')
    ) {
      stopFearCycle(item);
      return;
    }

    applyRandomFearVariant(item);
  }

  tick();

  const id = setInterval(tick, 230);
  fearTimers.set(item, id);
}

function stopFearCycle(item) {
  const id = fearTimers.get(item);
  if (id) {
    clearInterval(id);
    fearTimers.delete(item);
  }
}

function setActiveItem(index) {
  menuItems.forEach((el, i) => {
    const isActive = i === index;
    el.classList.toggle('menu-item--active', isActive);

    if (isActive) {
      startFearCycle(el);
    } else {
      stopFearCycle(el);
    }
  });
}

let lastHoverTime = 0;
function playHover() {
  const now = Date.now();
  if (now - lastHoverTime < 80) return;
  lastHoverTime = now;

  if (hoverSound) {
    hoverSound.currentTime = 0;
    hoverSound.volume = 0.3;
    hoverSound.play().catch(() => {});
  }
}

function playSelect() {
  if (selectSound) {
    selectSound.currentTime = 0;
    selectSound.volume = 0.5;
    selectSound.play().catch(() => {});
  }
}

function handleAction(action) {
  playSelect();
  console.log('Menu action:', action);
}

// ===============================
// AUDIO
// ===============================

function fadeBgmTo(targetVolume, duration) {
  if (!bgm) return;

  const startVolume = bgm.volume;
  const startTime = performance.now();

  function step(now) {
    const t = Math.min(1, (now - startTime) / duration);
    bgm.volume = startVolume + (targetVolume - startVolume) * t;
    if (t < 1) requestAnimationFrame(step);
  }

  requestAnimationFrame(step);
}

function startBgm() {
  if (!bgm) return;

  bgm.volume = 0.0;
  const p = bgm.play();
  bgm.loop = true;
  if (p && p.then) {
    p.then(() => {
      fadeBgmTo(0.4, 2000);
      scheduleCrossBeats();
      scheduleBeatImpacts();
      scheduleFisheyeBursts();
    }).catch(() => {});
  } else {
    scheduleCrossBeats();
    scheduleBeatImpacts();
  }
}

// ===============================
// INTRO FX
// ===============================

function endIntro() {
  if (introEnded) return;
  introEnded = true;

  if (introOverlay) introOverlay.classList.add('intro-overlay--hidden');
  if (menuWrapper) menuWrapper.classList.add('menu-wrapper--visible');
  startWhispers();
}

function triggerImpactFX() {
  document.body.classList.add('body-shake');
  setTimeout(() => document.body.classList.remove('body-shake'), 400);

  if (bloodFlash) {
    bloodFlash.classList.add('blood-flash--active');
    setTimeout(() => bloodFlash.classList.remove('blood-flash--active'), 100);
  }
}

// ===============================
// CROSS FX
// ===============================

function triggerCrossBeat() {
  if (crossEl) {
    crossEl.classList.add('inverted-cross--beat');
    setTimeout(() => {
      crossEl.classList.remove('inverted-cross--beat');
    }, 260);
  }

  if (crossFog) {
    crossFog.classList.add('cross-fog--boost');
    setTimeout(() => {
      crossFog.classList.remove('cross-fog--boost');
    }, 500);
  }
}
// ===============================
// FISHEYE PULSE
// ===============================

function triggerFisheyeOnce() {
  if (!fisheyeLens) return;

  fisheyeLens.classList.remove('fisheye-lens--active');
  void fisheyeLens.offsetWidth;
  fisheyeLens.classList.add('fisheye-lens--active');

  document.body.classList.add('fisheye-warp');
  setTimeout(() => {
    document.body.classList.remove('fisheye-warp');
  }, 800);
}

function triggerFisheyeBurst(times = 5) {
  if (!fisheyeLens) return;

  for (let i = 0; i < times; i++) {
    const delay = 80 + i * 220 + Math.random() * 120;

    setTimeout(() => {
      triggerFisheyeOnce();
    }, delay);
  }
}
let fisheyeScheduled = false;

function scheduleFisheyeBursts() {
  if (fisheyeScheduled) return;
  fisheyeScheduled = true;

  function queueNextBurst() {
    if (!bgm || bgm.paused) {
      fisheyeScheduled = false;
      return;
    }

    const baseDelay = 900 + Math.random() * 1300;

    setTimeout(() => {
      if (!bgm || bgm.paused) {
        fisheyeScheduled = false;
        return;
      }

      triggerFisheyeBurst();

      if (Math.random() < 0.55) {
        const extraCount = 2 + Math.floor(Math.random() * 3);
        for (let i = 1; i <= extraCount; i++) {
          const gap = 140 + Math.random() * 160;
          setTimeout(() => {
            if (!bgm || bgm.paused) return;
            triggerFisheyeBurst();
            scheduleCrossBeats();
          }, gap * i);
        }
      }

      queueNextBurst();
    }, baseDelay);
  }

  setTimeout(queueNextBurst, 19000);
}

// ===============================
// BEAT SCHEDULING
// ===============================

let crossBeatsScheduled = false;

function scheduleCrossBeats() {
  if (!bgm || crossBeatsScheduled) return;
  crossBeatsScheduled = true;

  const beatPattern = [
    0.31,
    0.62,

    2.27,
    2.44,
    2.6,
    2.89,

    3.69,
    3.85,
    4.0,
    4.19,
    4.41,
    4.74, // главный рифф

    8.32,
    8.47,
    9.74, // белая вспышка

    14.55,
    14.77,
    14.92,
    15.08,
    15.23,
    15.38,
    15.53,
    15.68,
    15.84,
    15.97,
    16.12,
    16.28,
    16.42,
    16.55,
    16.71,
    16.87,
    17.02,
    17.18,
    17.33,
    17.48,
    17.64,
    17.81,
    17.98,
    18.15,
    18.35,
    18.49,
    18.65,
    18.81,
    18.97,
  ];

  const RIFF = 4.74;
  const CHAPTER = 9.74;

  const startTime = bgm.currentTime || 0;

  beatPattern.forEach((t) => {
    const delay = Math.max(0, (t - startTime) * 1000);

    setTimeout(() => {
      if (bgm.paused) return;

      const cur = bgm.currentTime;
      const isRiff = Math.abs(cur - RIFF) < 0.08;
      const isChapter = Math.abs(cur - CHAPTER) < 0.08;

      const menuTitleBlock = document.querySelector('.menu-title');

      if (isRiff) {
        triggerCrossBeat();
        triggerImpactFX();

        if (menuTitleBlock) {
          menuTitleBlock.classList.add('menu-title--riff');

          setTimeout(() => {
            menuTitleBlock.classList.remove('menu-title--riff');
            const mainTitle = menuTitleBlock.querySelector('.menu-title-main');
            if (mainTitle) {
              mainTitle.style.opacity = '1';
              mainTitle.style.transform = 'translateY(0)';
              mainTitle.classList.add('menu-title-main--idle');
            }
          }, 3000);
        }

        document.body.classList.add('hard-glitch');
        if (noiseOverlay) noiseOverlay.classList.add('noise-overlay--hard');

        setTimeout(() => {
          document.body.classList.remove('hard-glitch');
          if (noiseOverlay)
            noiseOverlay.classList.remove('noise-overlay--hard');
        }, 9000);

        if (!introEnded) {
          setTimeout(() => endIntro(), 200);
        }

        return;
      }

      // ==== 9.74s — белая вспышка + BROKEN COVENANT ====
      if (isChapter) {
        if (whiteFlash) {
          whiteFlash.classList.add('white-flash--active');
          setTimeout(() => {
            whiteFlash.classList.remove('white-flash--active');
          }, 500);
        }

        triggerCrossBeat();

        document.body.classList.add('post-flash-shader');
        setTimeout(() => {
          document.body.classList.remove('post-flash-shader');
        }, 6000);

        // small + ghost
        const small = document.querySelector('.menu-title-small');
        const smallGhost = document.querySelector('.menu-title-small-ghost');
        small?.classList.add('menu-title-small--reveal');
        smallGhost?.classList.add('menu-title-small-ghost--anim');

        // sub + ghost
        const sub = document.querySelector('.menu-title-sub');
        const subGhost = document.querySelector('.menu-title-sub-ghost');
        sub?.classList.add('menu-title-sub--reveal');
        subGhost?.classList.add('menu-title-sub-ghost--anim');
        setTimeout(() => {
          document.body.classList.add('void-shader');

          // меню появляется в момент Ч/Б шейдера
          const menuList = document.querySelector('.menu-list');
          const menuDivider = document.querySelector('.menu-divider');

          menuList.classList.add('menu-list--visible');

          if (menuDivider) {
            menuDivider.classList.add('menu-divider--visible');
          }

          //setTimeout(() => {
          //    document.body.classList.remove("void-shader");
          //}, 6000);
        }, 6000);
        return;
      }

      // ==== остальные биты — только крест/туман ====
      triggerCrossBeat();
    }, delay);
  });
}

// ===============================
// BLOOD + SHAKE BEATS
// ===============================

let impactBeatsScheduled = false;
function scheduleBeatImpacts() {
  if (!bgm || impactBeatsScheduled) return;
  impactBeatsScheduled = true;

  const impactTimes = [
    0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41,
  ];
  const startTime = bgm.currentTime || 0;

  impactTimes.forEach((t) => {
    const delay = Math.max(0, (t - startTime) * 1000);

    setTimeout(() => {
      if (!bgm || bgm.paused) return;
      triggerImpactFX();
    }, delay);
  });
}

// ===============================
// START EXPERIENCE
// ===============================

function startExperience() {
  playSelect();
  if (started) return;
  started = true;

  if (startOverlay) {
    startOverlay.classList.add('start-overlay--hidden');
    setTimeout(() => startOverlay.remove(), 600);
  }

  if (crossOverlay) {
    crossOverlay.classList.add('inverted-cross-overlay--visible');
  }

  triggerImpactFX();
  startBgm();

  if (introOverlay) {
    introOverlay.classList.add('intro-overlay--animating');
    introOverlay.classList.remove('intro-overlay--hidden');
    introEnded = false;
  } else {
    endIntro();
  }

  setTimeout(() => {
    if (!bgm || bgm.paused) return;
    triggerFisheyeOnce();
  }, 19000);
}

// ===============================
// MENU INIT
// ===============================

if (menuItems.length) {
  setActiveItem(0);
}

menuItems.forEach((item, index) => {
  item.addEventListener('mouseenter', () => {
    if (!introEnded) return;
    activeIndex = index;
    setActiveItem(activeIndex);
    startFearCycle(item);
    playHover();
  });

  item.addEventListener('mouseleave', () => {
    if (!item.classList.contains('menu-item--active')) {
      stopFearCycle(item);
    }
  });

  item.addEventListener('click', () => {
    if (!introEnded) return;
    handleAction(item.dataset.action);
  });
});

// ===============================
// BEAT LOGGER — key: B
// ===============================
/*
document.addEventListener('keydown', (e) => {
    if ((e.key === 'b' || e.key === 'B') && bgm) {
        console.log("BEAT @", bgm.currentTime.toFixed(2));
    }
});


// ===============================
// INPUT
// ===============================

document.addEventListener('keydown', (e) => {
    if (!started) return;

    // во время интро — любая клавиша скипает интро и сразу в меню
    if (!introEnded) {
        endIntro();
        return;
    }

    if (e.key === 'ArrowUp') {
        e.preventDefault();
        activeIndex = (activeIndex - 1 + menuItems.length) % menuItems.length;
        setActiveItem(activeIndex);
        playHover();
    }

    if (e.key === 'ArrowDown') {
        e.preventDefault();
        activeIndex = (activeIndex + 1) % menuItems.length;
        setActiveItem(activeIndex);
        playHover();
    }

    if (e.key === 'Enter') {
        e.preventDefault();
        handleAction(menuItems[activeIndex].dataset.action);
    }
});
*/

// ===============================
// DISCLAIMER BUTTON
// ===============================

if (startButton) {
  startButton.addEventListener('click', () => startExperience());
}
function summonMenuGhostsOnce() {
  const menuList = document.querySelector('.menu-list');
  if (!menuList) return;

  menuList.classList.add('menu-list--summon');

  setTimeout(() => {
    menuList.classList.remove('menu-list--summon');
  }, 900);
}

// ===============================
// WHISPERS (ЛЕТАЮЩИЕ СЛОВА)
// ===============================

const WHISPER_WORDS = [
  // тело / плоть / гниение
  'ПЛОТЬ',
  'КРОВЬ',
  'МЯСО',
  'КОСТИ',
  'ГНИЛЬ',
  'РАСПАД',
  'ГНИЁТ',
  'СОХНИ',
  'СЛЕЗАЙ С КОЖИ',
  'СЛОМАНО',
  'БЕЗ КОЖИ',
  'РАЗРЕЗ',
  'ПУЛЬС',
  'НЕ ДЫШИ',
  'ЗАДОХНИСЬ',

  // смерть / страх / боль
  'СМЕРТЬ',
  'СТРАХ',
  'БОЛЬ',
  'УМРИ',
  'УЖЕ МЕРТВ',
  'НЕ ЖИВ',
  'ХРУСТ',
  'КРИК',
  'ШЕПОТ',
  'ТОШНОТА',
  'ОБРЫВ',
  'ТЬМА ВНУТРИ',
  'НЕ ПРОСНЁШЬСЯ',
  'УБИЙСТВО',
  'РАСЧЛЕНЕНИЕ',

  // грех / вина / религия
  'ГРЕХ',
  'ПОРОК',
  'ВИНА',
  'КАРА',
  'РАСПЯТ',
  'ПРОКЛЯТ',
  'СОЖГИ СЕБЯ',
  'НЕ ОТПУСТЯТ',
  'НЕ ПРОСТЯТ',
  'СДОХНИ В ВЕРЕ',
  'БЕЗ ИСПОВЕДИ',
  'ПУСТОЙ КРЕСТ',
  'НАРКОТИКИ',

  // секс / грязь / унижение
  'ШЛЮХА',
  'СОБАКА',
  'ПОЛЗИ',
  'РАСПУСТИСЬ',
  'РАСТЛЁН',
  'ГРЯЗЬ',
  'НИЧТО',
  'КЛОАКА',
  'РТОМ МОЛЧИ',
  'СТЫД',
  'Я ЗНАЮ ТЕБЯ',
  'ИЗВРАТ',
  'ПОЗОР',

  // контроль / голоса / безумие
  'МОЛЧИ',
  'СЛУШАЙ',
  'ПОВИНОСЬ',
  'СЛАБЫЙ',
  'СЛОМАЙСЯ',
  'СОЙДИ С УМА',
  'ТЫ НЕ СВОЙ',
  'ГОЛОСА',
  'ИМ ХОЧЕТСЯ',
  'ОНИ СМОТРЯТ',
  'ОНИ РЯДОМ',
  'ЗДЕСЬ НЕТ ТЕБЯ',

  // время / пространство / потеря
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

  // шепоты-фразы
  'ЭТО ВСЁ ТЫ',
  'ТЫ ХОТЕЛ ЭТОГО',
  'Я ВНУТРИ ТЕБЯ',
  'НИКТО НЕ ПРИЙДЁТ',
  'НИКОМУ НЕ НУЖЕН',
  'СМОТРИ НА КРОВЬ',
  'ОЩУТИ КОСТИ',
  'ТЫ ЛИШНIЙ',
  'УПАДИ НИЖЕ',
  'ТЫ УЖЕ ЗДЕСЬ',
  'НАЗАД НЕТ',
  'ТЫ НЕ ОН',
  'ТЫ НЕ ОНА',
  'ТЫ НИЧТО',

  // совсем короткие «мигалки»
  'РЕЖЬ',
  'ПЕЙ',
  'ПЛЫВИ',
  'ПАДАЙ',
  'СГНИЙ',
  'СГОРИ',
  'СЛОМАТЬ',
  'НЕСИ',
  'СМОТРИ',
  'ЗАБУДЬ',
  // мат, оскорбления
  'ЕБАЛ ТВОЮ МАТЬ',
  'ИДИ НАХУЙ',
  'ЕБАНЫЙ',
  'ПИЗДЕЦ',
  'БЛЯТЬ',
  'СУКА',
  'НАХУЙ',
  'ЗАЕБАЛ',
  'МРАЗЬ',
  'МУДАК',
  'ПОЁБИЩЕ',
  'ПИЗДА',
  'ЕБАТЬ',
  'МАНДА',
];

let whispersStarted = false;
function spawnWhisperWord() {
  const layer = document.querySelector('.whisper-layer');
  if (!layer) return;

  const el = document.createElement('span');
  el.className = 'whisper-word';

  // слово
  el.textContent =
    WHISPER_WORDS[Math.floor(Math.random() * WHISPER_WORDS.length)];

  // тип траектории
  const t = Math.random();
  let x0, y0, x1, y1, xMid, yMid, x2, y2, rot;

  // helper для случайного числа
  const r = (min, max) => min + Math.random() * (max - min);

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
    // 2) из угла в угол
    const corners = [
      { x: -10, y: -10 },
      { x: 110, y: -10 },
      { x: -10, y: 110 },
      { x: 110, y: 110 },
    ];
    const sIdx = Math.floor(Math.random() * corners.length);
    let eIdx = Math.floor(Math.random() * corners.length);
    if (eIdx === sIdx) eIdx = (eIdx + 1) % corners.length;

    const s = corners[sIdx];
    const e = corners[eIdx];

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

    if (Math.random() < 0.6) {
      rot = (fromLeft ? 90 : -90) + r(-15, 15);
    } else if (Math.random() < 0.3) {
      rot = 180 + r(-20, 20);
    } else {
      rot = r(-15, 15);
    }
  }

  const scale = 0.7 + Math.random() * 2.5;

  // прокидываем координаты в vw/vh
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

  const duration = 320 + Math.random() * 650;
  el.style.setProperty('--wdur', duration + 'ms');

  layer.appendChild(el);
  el.addEventListener('animationend', () => el.remove());
}

function startWhispers() {
  if (whispersStarted) return;
  whispersStarted = true;

  const minDelay = 20;
  const maxDelay = 300;

  function loop() {
    if (!introEnded) {
      setTimeout(loop, 800);
      return;
    }

    if (Math.random() < 0.85) {
      spawnWhisperWord();
    }

    const next = minDelay + Math.random() * (maxDelay - minDelay);
    setTimeout(loop, next);
  }

  loop();
}
