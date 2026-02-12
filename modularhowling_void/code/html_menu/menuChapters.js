// BYOND-safe chapter loader (ES5)
(() => {
  // Howling Void Edit start
  var ASSET_MAP = window.__HOWLING_MENU_ASSETS || {};
  var MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
  var BYOND_LEGACY = !!document.documentMode;

  function clampVolume(value) {
    var parsed = Number(value);
    if (isNaN(parsed)) {
      return 0;
    }
    return Math.max(0, Math.min(1, parsed));
  }

  function getConfiguredMenuVolume() {
    return clampVolume(MENU_SETTINGS.musicVolume);
  }

  function isMenuMusicEnabled() {
    if (MENU_SETTINGS.musicEnabled === false) {
      return false;
    }
    return getConfiguredMenuVolume() > 0;
  }

  var MENU_CHAPTERS = {
    ironHeart: {
      id: 'ironHeart',
      subtitle: 'IRON HEART',
      css: 'ironHeart.css',
      js: 'ironHeart.js',
      audio: 'iron_heart.ogg',
    },
    jesusWept: {
      id: 'jesusWept',
      subtitle: 'JESUS WEPT',
      css: 'jesusWept.css',
      js: 'jesusWept.js',
      audio: 'jesus_wept.ogg',
    },
  };

  var CURRENT_CHAPTER = 'ironHeart';
  var currentStyleEl = null;
  var currentScriptEl = null;
  var revealTimer = null;

  function assetUrl(name) {
    return ASSET_MAP[name] || name;
  }

  function applyChapterText(chapter) {
    var subEl = document.querySelector('.menu-title-sub');
    if (subEl) {
      subEl.textContent = chapter.subtitle;
    }
  }

  function ensureMenuDataLabels() {
    var labels = document.querySelectorAll('.menu-item .menu-label');
    var i;
    for (i = 0; i < labels.length; i++) {
      var label = labels[i];
      if (!label.getAttribute('data-label')) {
        label.setAttribute('data-label', (label.textContent || '').trim());
      }
    }
  }

  function revealWhenReady() {
    if (revealTimer) {
      clearTimeout(revealTimer);
      revealTimer = null;
    }
    if (document.body) {
      document.body.classList.add('menu-css-ready');
    }
  }

  function loadCSS(href, onReady) {
    if (!href) {
      if (onReady) {
        onReady();
      }
      return;
    }
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = assetUrl(href);
    link.setAttribute('data-chapter-style', 'true');
    if (onReady) {
      link.onload = onReady;
      link.onerror = onReady;
    }
    document.head.appendChild(link);
    currentStyleEl = link;
  }

  function loadJS(src) {
    if (!src) {
      return;
    }
    var script = document.createElement('script');
    script.src = assetUrl(src);
    script.defer = true;
    script.setAttribute('data-chapter-script', 'true');
    script.onerror = () => {
      if (window.console && console.error) {
        console.error('[MenuChapters] Failed to load script:', src);
      }
    };
    document.body.appendChild(script);
    currentScriptEl = script;
  }

  function setupAudio(src) {
    var bgm = document.getElementById('bgm');
    if (!bgm || !src) {
      return;
    }
    try {
      bgm.pause();
      bgm.currentTime = 0;
      bgm.src = assetUrl(src);
      bgm.loop = true;
      bgm.volume = getConfiguredMenuVolume();
      bgm.load();
    } catch (e) {}
  }

  function unloadPreviousChapter() {
    if (typeof window.__menuChapterTeardown === 'function') {
      try {
        window.__menuChapterTeardown();
      } catch (e) {}
    }
    window.__menuChapterTeardown = null;

    if (currentStyleEl && currentStyleEl.parentNode) {
      currentStyleEl.parentNode.removeChild(currentStyleEl);
    }
    if (currentScriptEl && currentScriptEl.parentNode) {
      currentScriptEl.parentNode.removeChild(currentScriptEl);
    }
    currentStyleEl = null;
    currentScriptEl = null;
  }

  function setupLegacyFallback(chapter) {
    var timers = [];
    var fearVariants = ['menu-fear-v1', 'menu-fear-v2', 'menu-fear-v3'];
    function later(fn, ms) {
      var id = setTimeout(fn, ms);
      timers.push(id);
      return id;
    }

    var startOverlay = document.querySelector('.start-overlay');
    var startButton = document.querySelector('.start-button');
    var skipIntro = document.getElementById('skip-intro');
    var introOverlay = document.querySelector('.intro-overlay');
    var menuWrapper = document.querySelector('.menu-wrapper');
    var menuList = document.querySelector('.menu-list');
    var menuDivider = document.querySelector('.menu-divider');
    var small = document.querySelector('.menu-title-small');
    var smallGhost = document.querySelector('.menu-title-small-ghost');
    var sub = document.querySelector('.menu-title-sub');
    var subGhost = document.querySelector('.menu-title-sub-ghost');
    var mainTitle = document.querySelector('.menu-title-main');
    var crossOverlay = document.querySelector('.inverted-cross-overlay');
    var crossEl = document.querySelector('.inverted-cross');
    var crossFog = document.querySelector('.cross-fog');
    var noiseOverlay = document.querySelector('.noise-overlay');
    var bloodFlash = document.querySelector('.blood-flash');
    var whiteFlash = document.querySelector('.white-flash');
    var fisheyeLens = document.querySelector('.fisheye-lens');
    var menuTitleBlock = document.querySelector('.menu-title');
    var bgm = document.getElementById('bgm');
    var selectSound = document.getElementById('select-sound');
    var menuItems = document.querySelectorAll('.menu-item');
    var menuLinks = document.querySelectorAll('.menu-item a[href]');
    var crossBeatsScheduled = false;
    var impactBeatsScheduled = false;
    var fisheyeScheduled = false;
    var experienceStarted = false;

    function resetLegacyFXState() {
      document.body.classList.remove('void-shader');
      document.body.classList.remove('post-flash-shader');
      document.body.classList.remove('hard-glitch');
      document.body.classList.remove('body-shake');
      document.body.classList.remove('fisheye-warp');
      if (noiseOverlay) {
        noiseOverlay.classList.remove('noise-overlay--hard');
      }
      if (whiteFlash) {
        whiteFlash.classList.remove('white-flash--active');
      }
      if (bloodFlash) {
        bloodFlash.classList.remove('blood-flash--active');
      }
      if (crossEl) {
        crossEl.classList.remove('inverted-cross--beat');
      }
      if (crossFog) {
        crossFog.classList.remove('cross-fog--boost');
      }
      if (fisheyeLens) {
        fisheyeLens.classList.remove('fisheye-lens--active');
      }
      if (menuTitleBlock) {
        menuTitleBlock.classList.remove('menu-title--riff');
      }
    }

    function clearFearClasses(item) {
      var i;
      for (i = 0; i < fearVariants.length; i++) {
        item.classList.remove(fearVariants[i]);
      }
    }

    function applyRandomFear(item) {
      clearFearClasses(item);
      item.classList.add(
        fearVariants[Math.floor(Math.random() * fearVariants.length)],
      );
    }

    function playSelect() {
      if (!selectSound) {
        return;
      }
      try {
        selectSound.currentTime = 0;
        selectSound.volume = 0.18;
        selectSound.play();
      } catch (e) {}
    }

    function playBgm() {
      if (!bgm) {
        return;
      }

      if (!isMenuMusicEnabled()) {
        try {
          bgm.pause();
          bgm.currentTime = 0;
        } catch (e) {}
        scheduleCrossBeats();
        scheduleBeatImpacts();
        scheduleFisheyeBursts();
        return;
      }
      try {
        bgm.volume = 0;
        bgm.play();
        scheduleCrossBeats();
        scheduleBeatImpacts();
        scheduleFisheyeBursts();
        later(() => {
          if (!bgm || !experienceStarted) {
            return;
          }
          bgm.volume = getConfiguredMenuVolume();
        }, 1200);
      } catch (e) {}
    }

    function triggerImpactFX() {
      document.body.classList.add('body-shake');
      later(() => {
        document.body.classList.remove('body-shake');
      }, 400);

      if (bloodFlash) {
        bloodFlash.classList.add('blood-flash--active');
        later(() => {
          bloodFlash.classList.remove('blood-flash--active');
        }, 110);
      }
    }

    function triggerCrossBeat(intensity) {
      if (crossEl) {
        crossEl.classList.add('inverted-cross--beat');
        later(() => {
          crossEl.classList.remove('inverted-cross--beat');
        }, 260);
      }

      if (crossFog) {
        crossFog.classList.add('cross-fog--boost');
        later(() => {
          crossFog.classList.remove('cross-fog--boost');
        }, 500);
      }

      if (intensity === 'hard') {
        later(() => {
          if (!experienceStarted) {
            return;
          }
          if (crossEl) {
            crossEl.classList.add('inverted-cross--beat');
            later(() => {
              crossEl.classList.remove('inverted-cross--beat');
            }, 220);
          }
          if (crossFog) {
            crossFog.classList.add('cross-fog--boost');
            later(() => {
              crossFog.classList.remove('cross-fog--boost');
            }, 420);
          }
        }, 120);
      }
    }

    function triggerFisheyeOnce() {
      if (!fisheyeLens) {
        return;
      }
      fisheyeLens.classList.remove('fisheye-lens--active');
      void fisheyeLens.offsetWidth;
      fisheyeLens.classList.add('fisheye-lens--active');
      document.body.classList.add('fisheye-warp');
      later(() => {
        document.body.classList.remove('fisheye-warp');
      }, 800);
    }

    function triggerFisheyeBurst(times) {
      var i;
      var count = times || 5;
      for (i = 0; i < count; i++) {
        ((idx) => {
          var delay = 80 + idx * 220 + Math.random() * 120;
          later(() => {
            triggerFisheyeOnce();
          }, delay);
        })(i);
      }
    }

    function scheduleCrossBeats() {
      var beatPattern;
      var RIFF = 4.74;
      var CHAPTER_TIME = 9.74;
      var startTime;
      var i;

      if (!bgm || crossBeatsScheduled || chapter.id !== 'jesusWept') {
        return;
      }
      crossBeatsScheduled = true;
      beatPattern = [
        0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.74,
        8.32, 8.47, 9.74, 9.75, 9.92, 10.09, 10.26, 10.43, 10.6, 10.77, 10.91,
        11.08, 11.25, 11.42, 11.59, 11.76, 11.93, 11.94, 11.95, 11.96, 11.97,
        11.98, 11.99, 12.0, 12.1, 12.27, 12.44, 12.61, 12.78, 12.95, 13.12,
        13.29, 13.46, 13.63, 13.8, 13.97, 14.14, 14.31, 14.48, 14.55, 14.77,
        14.92, 15.08, 15.23, 15.38, 15.53, 15.68, 15.84, 15.97, 16.12, 16.28,
        16.42, 16.55, 16.71, 16.87, 17.02, 17.18, 17.33, 17.48, 17.64, 17.81,
        17.98, 18.15, 18.35, 18.49, 18.65, 18.81, 18.97,
      ];
      startTime = bgm.currentTime || 0;

      for (i = 0; i < beatPattern.length; i++) {
        ((t) => {
          var delay = Math.max(0, (t - startTime) * 1000);
          later(() => {
            var isRiffBeat;
            var isChapterBeat;
            if (!experienceStarted) {
              return;
            }

            isRiffBeat = Math.abs(t - RIFF) < 0.001;
            isChapterBeat = Math.abs(t - CHAPTER_TIME) < 0.001;

            if (isRiffBeat) {
              triggerCrossBeat('hard');
              triggerImpactFX();

              if (menuTitleBlock) {
                menuTitleBlock.classList.add('menu-title--riff');
                later(() => {
                  var main = menuTitleBlock.querySelector('.menu-title-main');
                  menuTitleBlock.classList.remove('menu-title--riff');
                  if (main) {
                    main.classList.add('menu-title-main--idle');
                    main.style.opacity = '1';
                    main.style.transform = 'translateY(0)';
                  }
                }, 12500);
              }

              document.body.classList.add('hard-glitch');
              if (noiseOverlay) {
                noiseOverlay.classList.add('noise-overlay--hard');
              }
              later(() => {
                document.body.classList.remove('hard-glitch');
                if (noiseOverlay) {
                  noiseOverlay.classList.remove('noise-overlay--hard');
                }
              }, 9000);

              return;
            }

            if (isChapterBeat) {
              if (whiteFlash) {
                whiteFlash.classList.add('white-flash--active');
                later(() => {
                  whiteFlash.classList.remove('white-flash--active');
                }, 500);
              }

              triggerCrossBeat('hard');

              document.body.classList.add('post-flash-shader');
              later(() => {
                document.body.classList.remove('post-flash-shader');
              }, 6000);

              if (small) {
                small.classList.add('menu-title-small--reveal');
              }
              if (smallGhost) {
                smallGhost.classList.add('menu-title-small-ghost--anim');
              }
              if (sub) {
                sub.classList.add('menu-title-sub--reveal');
              }
              if (subGhost) {
                subGhost.classList.add('menu-title-sub-ghost--anim');
              }

              later(() => {
                document.body.classList.add('void-shader');
                if (menuList) {
                  menuList.classList.add('menu-list--visible');
                }
                if (menuDivider) {
                  menuDivider.classList.add('menu-divider--visible');
                }
              }, 6000);
              return;
            }

            triggerCrossBeat();
          }, delay);
        })(beatPattern[i]);
      }
    }

    function scheduleBeatImpacts() {
      var impactTimes;
      var startTime;
      var i;
      if (!bgm || impactBeatsScheduled || chapter.id !== 'jesusWept') {
        return;
      }
      impactBeatsScheduled = true;
      impactTimes = [
        0.31, 0.62, 2.27, 2.44, 2.6, 2.89, 3.69, 3.85, 4.0, 4.19, 4.41, 4.43,
        4.46, 4.47,
      ];
      startTime = bgm.currentTime || 0;
      for (i = 0; i < impactTimes.length; i++) {
        ((t) => {
          var delay = Math.max(0, (t - startTime) * 1000);
          later(() => {
            if (!experienceStarted) {
              return;
            }
            triggerImpactFX();
          }, delay);
        })(impactTimes[i]);
      }
    }

    function scheduleFisheyeBursts() {
      function queueNextBurst() {
        var baseDelay;
        if (!experienceStarted) {
          fisheyeScheduled = false;
          return;
        }

        baseDelay = 450 + Math.random() * 600;
        later(() => {
          var extraCount;
          var i;
          if (!experienceStarted) {
            fisheyeScheduled = false;
            return;
          }

          triggerFisheyeBurst();

          if (Math.random() < 0.55) {
            extraCount = 2 + Math.floor(Math.random() * 3);
            for (i = 1; i <= extraCount; i++) {
              ((idx) => {
                var gap = 140 + Math.random() * 160;
                later(() => {
                  if (!experienceStarted) {
                    return;
                  }
                  triggerFisheyeBurst();
                }, gap * idx);
              })(i);
            }
          }
          queueNextBurst();
        }, baseDelay);
      }

      if (fisheyeScheduled || chapter.id !== 'jesusWept') {
        return;
      }
      fisheyeScheduled = true;
      later(queueNextBurst, 19000);
    }

    function revealMenu() {
      if (introOverlay) {
        introOverlay.classList.add('intro-overlay--hidden');
      }
      if (menuWrapper) {
        menuWrapper.classList.add('menu-wrapper--visible');
      }
      if (menuList) {
        menuList.classList.add('menu-list--visible');
      }
      if (menuDivider) {
        menuDivider.classList.add('menu-divider--visible');
      }
      if (small) {
        small.classList.add('menu-title-small--reveal');
      }
      if (smallGhost) {
        smallGhost.classList.add('menu-title-small-ghost--anim');
      }
      if (sub) {
        sub.classList.add('menu-title-sub--reveal');
      }
      if (subGhost) {
        subGhost.classList.add('menu-title-sub-ghost--anim');
      }
      if (mainTitle) {
        mainTitle.classList.add('menu-title-main--idle');
      }
    }

    function startExperience() {
      experienceStarted = true;
      MENU_SETTINGS.introAccepted = true;
      resetLegacyFXState();
      playSelect();
      playBgm();
      if (chapter.id === 'jesusWept' && crossOverlay) {
        crossOverlay.classList.add('inverted-cross-overlay--visible');
      }
      if (startButton) {
        startButton.disabled = true;
      }
      if (startOverlay) {
        startOverlay.classList.add('start-overlay--hidden');
        later(() => {
          if (startOverlay.parentNode) {
            startOverlay.parentNode.removeChild(startOverlay);
          }
        }, 600);
      }

      if (skipIntro && skipIntro.checked) {
        revealMenu();
        return;
      }

      if (introOverlay) {
        introOverlay.classList.remove('intro-overlay--hidden');
        introOverlay.classList.add('intro-overlay--animating');
      }
      later(revealMenu, chapter.id === 'jesusWept' ? 3400 : 1800);
    }

    resetLegacyFXState();

    var i;
    for (i = 0; i < menuItems.length; i++) {
      ((item) => {
        item.onmouseenter = () => {
          var j;
          for (j = 0; j < menuItems.length; j++) {
            menuItems[j].classList.remove('menu-item--active');
            clearFearClasses(menuItems[j]);
          }
          item.classList.add('menu-item--active');
          applyRandomFear(item);
        };
        item.onmouseleave = () => {
          if (!item.classList.contains('menu-item--active')) {
            clearFearClasses(item);
          }
        };
        item.onclick = null;
      })(menuItems[i]);
    }

    for (i = 0; i < menuLinks.length; i++) {
      ((link) => {
        link.onclick = (event) => {
          event = event || window.event;
          if (event && event.preventDefault) {
            event.preventDefault();
          }
          if (event && event.stopPropagation) {
            event.stopPropagation();
          }
          if (event) {
            event.returnValue = false;
            event.cancelBubble = true;
          }
          playSelect();
          window.location.href = link.getAttribute('href');
          return false;
        };
      })(menuLinks[i]);
    }

    if (startButton) {
      startButton.onclick = startExperience;
    }

    window.__menuChapterTeardown = () => {
      var j;
      for (j = 0; j < timers.length; j++) {
        clearTimeout(timers[j]);
      }
      timers = [];
      crossBeatsScheduled = false;
      impactBeatsScheduled = false;
      fisheyeScheduled = false;
      experienceStarted = false;
      resetLegacyFXState();
      if (startButton) {
        startButton.onclick = null;
      }
      for (j = 0; j < menuItems.length; j++) {
        menuItems[j].onclick = null;
        menuItems[j].onmouseenter = null;
        menuItems[j].onmouseleave = null;
        clearFearClasses(menuItems[j]);
      }
      for (j = 0; j < menuLinks.length; j++) {
        menuLinks[j].onclick = null;
      }
    };
  }

  function loadChapter(name) {
    var chapter = MENU_CHAPTERS[name];
    if (!chapter) {
      return;
    }

    unloadPreviousChapter();
    applyChapterText(chapter);
    ensureMenuDataLabels();
    loadCSS(chapter.css, revealWhenReady);
    revealTimer = setTimeout(revealWhenReady, 1200);
    setupAudio(chapter.audio);
    document.body.setAttribute('data-chapter', chapter.id);

    if (BYOND_LEGACY) {
      setupLegacyFallback(chapter);
      return;
    }

    loadJS(chapter.js);
  }

  window.setMenuChapter = (name) => {
    loadChapter(name);
  };

  function init() {
    loadChapter(CURRENT_CHAPTER);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  // Howling Void Edit end
})();
