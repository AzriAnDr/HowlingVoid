// Howling Void chapter loader.
(() => {
  const ASSET_MAP = window.__HOWLING_MENU_ASSETS || {};
  const SCRIPT_SRC = document.currentScript?.src || '';
  const SCRIPT_BASE = SCRIPT_SRC.slice(0, SCRIPT_SRC.lastIndexOf('/') + 1);

  const MENU_CHAPTERS = {
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
    crossToBear: {
      id: 'crossToBear',
      subtitle: 'JESUS WEPT',
      css: 'crossToBear.css',
      js: 'crossToBear.js',
      audio: 'cross_to_bear.ogg',
    },
  };

  const DEFAULT_CHAPTER = 'jesusWept';
  const CSS_READY_FALLBACK_MS = 1200;
  const MENU_CHROME_STYLE_ID = 'howling-menu-chrome-style';

  let currentStyleEl = null;
  let currentScriptEl = null;
  let revealTimer = null;

  function isRootedUrl(name) {
    return /^(?:[a-z][a-z\d+.-]*:|\/\/|\/)/i.test(name);
  }

  function assetUrl(name) {
    if (ASSET_MAP[name] || !name || isRootedUrl(name)) {
      return ASSET_MAP[name] || name;
    }

    return SCRIPT_BASE ? SCRIPT_BASE + name : name;
  }

  function injectMenuChromeStyle() {
    if (document.getElementById(MENU_CHROME_STYLE_ID)) {
      return;
    }

    const style = document.createElement('style');
    style.id = MENU_CHROME_STYLE_ID;
    style.textContent = `
      .menu-audio-control {
        position: fixed;
        z-index: 130;
        bottom: 56px;
        left: 50%;
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 260px;
        padding: 10px 16px;
        color: var(--menu-chrome-fg, rgba(246, 226, 202, 0.82));
        font: 700 11px/1 "Crimson Text", serif;
        letter-spacing: 0.24em;
        text-transform: uppercase;
        background: var(--menu-chrome-bg, rgba(8, 0, 0, 0.34));
        border: var(--menu-chrome-border, 1px solid rgba(180, 30, 30, 0.34));
        box-shadow: var(--menu-chrome-shadow, 0 0 24px rgba(130, 0, 0, 0.22), inset 0 0 18px rgba(255, 230, 200, 0.04));
        opacity: 0;
        pointer-events: none;
        transform: translate(-50%, 8px);
        transition: opacity 0.22s ease-out, transform 0.22s ease-out;
      }

      .menu-audio-control--visible {
        opacity: 0.76;
        pointer-events: auto;
        transform: translate(-50%, 0);
      }

      .menu-audio-control:hover,
      .menu-audio-control:focus-within {
        opacity: 0.96;
      }

      .menu-audio-control__range {
        width: 170px;
        height: 18px;
        margin: 0;
        accent-color: var(--menu-chrome-accent, #9f1717);
        cursor: pointer;
      }

      .menu-character-footer {
        position: fixed;
        z-index: 45;
        left: 50%;
        bottom: 22px;
        max-width: min(520px, calc(100vw - 52px));
        color: var(--menu-chrome-name-fg, rgba(255, 238, 214, 0.88));
        font: 700 15px/1.2 "Crimson Text", serif;
        letter-spacing: 0.22em;
        text-align: center;
        text-transform: uppercase;
        text-shadow: var(--menu-chrome-name-shadow, 0 0 12px rgba(150, 0, 0, 0.42), 0 0 28px rgba(0, 0, 0, 0.9));
        opacity: 0;
        pointer-events: none;
        transform: translateX(-50%);
        transition: opacity 0.22s ease-out;
      }

      .menu-chrome-ready .menu-character-footer {
        opacity: 0.88;
      }

      .menu-language-control {
        position: fixed;
        z-index: 130;
        top: 18px;
        right: 18px;
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 6px;
        background: var(--menu-chrome-bg, rgba(8, 0, 0, 0.34));
        border: var(--menu-chrome-border, 1px solid rgba(180, 30, 30, 0.34));
        box-shadow: var(--menu-chrome-shadow, 0 0 24px rgba(130, 0, 0, 0.22), inset 0 0 18px rgba(255, 230, 200, 0.04));
        opacity: 0.82;
      }

      .menu-language-control:hover,
      .menu-language-control:focus-within {
        opacity: 0.98;
      }

      .menu-language-control__button {
        min-width: 34px;
        height: 26px;
        border: 0;
        padding: 0 8px;
        color: var(--menu-chrome-fg, rgba(246, 226, 202, 0.82));
        background: transparent;
        font: 700 11px/1 "Crimson Text", serif;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        cursor: pointer;
      }

      .menu-language-control__button:hover,
      .menu-language-control__button:focus-visible,
      .menu-language-control__button--active {
        color: var(--menu-chrome-name-fg, rgba(255, 238, 214, 0.92));
        background: rgba(159, 23, 23, 0.34);
        outline: none;
      }
    `;
    document.head.appendChild(style);
  }

  function getCurrentCharacterName() {
    const slot = document.getElementById('character_slot');
    const text = (slot?.textContent || '').trim();
    return text || 'UNKNOWN';
  }

  function updateCharacterFooter(name) {
    const footerName = document.getElementById('selected_character_name');
    if (footerName) {
      footerName.textContent = String(
        name || getCurrentCharacterName(),
      ).toUpperCase();
    }
  }

  function setupCharacterFooter() {
    if (!document.querySelector('.menu-character-footer')) {
      const footer = document.createElement('div');
      footer.className = 'menu-character-footer';
      footer.innerHTML =
        '<span class="menu-character-footer__name" id="selected_character_name"></span>';
      document.body.appendChild(footer);
    }

    updateCharacterFooter();

    const originalUpdate = window.update_current_character;
    if (!originalUpdate || originalUpdate.__howlingWrapped) {
      return;
    }

    window.update_current_character = function updateCurrentCharacterWithFooter(
      name,
    ) {
      originalUpdate(name);
      updateCharacterFooter(name);
    };
    window.update_current_character.__howlingWrapped = true;
  }

  function setupAudioControl() {
    if (!document.querySelector('.menu-audio-control')) {
      const control = document.createElement('div');
      control.className = 'menu-audio-control';
      control.innerHTML =
        '<span class="menu-audio-control__label">Sound</span>' +
        '<input class="menu-audio-control__range" id="menu-volume-slider" type="range" min="0" max="100" step="1" />' +
        '<span class="menu-audio-control__value" id="menu-volume-value"></span>';
      document.body.appendChild(control);
    }

    const control = document.querySelector('.menu-audio-control');
    const slider = document.getElementById('menu-volume-slider');
    const value = document.getElementById('menu-volume-value');
    if (control.dataset.ready === 'true') {
      return;
    }
    control.dataset.ready = 'true';

    let lastTick = 0;
    let commitTimer = null;
    let hideTimer = null;

    function currentVolumePercent() {
      const settings = window.__HOWLING_MENU_SETTINGS || {};
      const volume = Number(settings.musicVolume);
      if (Number.isNaN(volume)) {
        return 0;
      }
      return Math.max(0, Math.min(100, Math.round(volume * 100)));
    }

    function syncSlider() {
      const percent = currentVolumePercent();
      slider.value = String(percent);
      value.textContent = String(percent);
    }

    function hideControlSoon() {
      if (hideTimer) {
        clearTimeout(hideTimer);
      }
      hideTimer = setTimeout(() => {
        if (
          control.matches(':hover') ||
          control.contains(document.activeElement)
        ) {
          hideControlSoon();
          return;
        }
        control.classList.remove('menu-audio-control--visible');
      }, 1800);
    }

    function showControl() {
      control.classList.add('menu-audio-control--visible');
      hideControlSoon();
    }

    function sendVolumePreference(percent) {
      const src = window.__HOWLING_MENU_SRC;
      if (!src) {
        return;
      }

      if (commitTimer) {
        clearTimeout(commitTimer);
      }
      commitTimer = setTimeout(() => {
        window.location.href =
          'byond://?src=' +
          src +
          ';set_menu_music_volume=' +
          Math.max(0, Math.min(100, Math.round(percent)));
      }, 120);
    }

    function tickSelectSound() {
      const now = Date.now();
      if (now - lastTick < 90) {
        return;
      }
      lastTick = now;
      const select = document.getElementById('select-sound');
      if (!select) {
        return;
      }
      try {
        select.currentTime = 0;
        select.volume = 0.035;
        select.play().catch(() => {});
      } catch {}
    }

    syncSlider();
    if (
      typeof window.set_menu_music_volume === 'function' &&
      !window.set_menu_music_volume.__howlingVolumeWrapped
    ) {
      const originalSetMenuMusicVolume = window.set_menu_music_volume;
      window.set_menu_music_volume = function setMenuMusicVolumeWithSlider(
        volume,
      ) {
        originalSetMenuMusicVolume(volume);
        syncSlider();
      };
      window.set_menu_music_volume.__howlingVolumeWrapped = true;
    }

    document.addEventListener('mousemove', showControl);
    control.addEventListener('mouseenter', showControl);
    control.addEventListener('focusin', showControl);
    control.addEventListener('mouseleave', hideControlSoon);
    control.addEventListener('focusout', hideControlSoon);

    slider.addEventListener('input', () => {
      const percent = Number(slider.value) || 0;
      value.textContent = String(percent);
      if (typeof window.set_menu_music_volume === 'function') {
        window.set_menu_music_volume(percent);
      } else {
        window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
        window.__HOWLING_MENU_SETTINGS.musicVolume = Math.max(
          0,
          Math.min(1, percent / 100),
        );
      }
      sendVolumePreference(percent);
      tickSelectSound();
      showControl();
    });
  }

  function setupLanguageControl() {
    if (!document.querySelector('.menu-language-control')) {
      const control = document.createElement('div');
      control.className = 'menu-language-control';
      control.innerHTML =
        '<button class="menu-language-control__button" type="button" data-language="english">EN</button>' +
        '<button class="menu-language-control__button" type="button" data-language="russian">RU</button>';
      document.body.appendChild(control);
    }

    const control = document.querySelector('.menu-language-control');
    if (control.dataset.ready === 'true') {
      syncLanguageControl();
      return;
    }
    control.dataset.ready = 'true';

    control.addEventListener('click', (event) => {
      const button = event.target.closest('[data-language]');
      if (!button) {
        return;
      }

      setMenuLanguage(button.dataset.language);
    });

    if (
      typeof window.set_menu_language === 'function' &&
      !window.set_menu_language.__howlingLanguageWrapped
    ) {
      const originalSetMenuLanguage = window.set_menu_language;
      window.set_menu_language = function setMenuLanguageWithControl(language) {
        originalSetMenuLanguage(language);
        syncLanguageControl();
      };
      window.set_menu_language.__howlingLanguageWrapped = true;
    }

    syncLanguageControl();
  }

  function currentMenuLanguage() {
    const settings = window.__HOWLING_MENU_SETTINGS || {};
    return settings.interfaceLanguage === 'russian' ? 'russian' : 'english';
  }

  function syncLanguageControl() {
    const activeLanguage = currentMenuLanguage();
    document
      .querySelectorAll('.menu-language-control__button[data-language]')
      .forEach((button) => {
        button.classList.toggle(
          'menu-language-control__button--active',
          button.dataset.language === activeLanguage,
        );
      });
  }

  function setMenuLanguage(language) {
    const normalized = language === 'russian' ? 'russian' : 'english';
    window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
    window.__HOWLING_MENU_SETTINGS.interfaceLanguage = normalized;
    window.__HOWLING_INTERFACE_LANGUAGE = normalized;
    syncLanguageControl();

    if (typeof window.set_menu_language === 'function') {
      window.set_menu_language(normalized);
    }

    const src = window.__HOWLING_MENU_SRC;
    if (src) {
      window.location.href =
        'byond://?src=' + src + ';set_interface_language=' + normalized;
    }
  }

  function setupMenuChrome() {
    injectMenuChromeStyle();
    setupCharacterFooter();
    setupAudioControl();
    setupLanguageControl();
    setupRoundStartHandler();
    watchMenuChromeReady();
  }

  function setupRoundStartHandler() {
    if (window.set_round_started?.__howlingRoundWrapped) {
      return;
    }

    const originalSetRoundStarted = window.set_round_started;
    window.set_round_started = function setRoundStartedWithMenuRefresh() {
      if (typeof originalSetRoundStarted === 'function') {
        originalSetRoundStarted.apply(window, arguments);
      }
      replaceReadyWithJoin();
    };
    window.set_round_started.__howlingRoundWrapped = true;

    if (window.__HOWLING_ROUND_STARTED === true) {
      replaceReadyWithJoin();
    }
  }

  function replaceReadyWithJoin() {
    const src = window.__HOWLING_MENU_SRC;
    const joinHref = src ? 'byond://?src=' + src + ';late_join=1' : null;
    const readyLink = document.getElementById('ready');
    const readyItem =
      readyLink?.closest?.('.menu-item') ||
      document.querySelector('.menu-item[data-action="toggle-ready"]');
    const targetLink = readyLink || readyItem?.querySelector?.('a.menu-link');

    if (!targetLink) {
      return;
    }

    targetLink.id = '';
    if (joinHref) {
      targetLink.href = joinHref;
    }
    targetLink.innerHTML = '<span class="menu-label">JOIN GAME</span>';

    if (readyItem) {
      readyItem.dataset.action = 'join-game';
      readyItem.dataset.label = 'JOIN GAME';
      readyItem.querySelectorAll('.menu-label').forEach((label) => {
        label.dataset.label = 'JOIN GAME';
      });
    }
  }

  function watchMenuChromeReady() {
    if (document.body.dataset.menuChromeWatcher === 'true') {
      return;
    }
    document.body.dataset.menuChromeWatcher = 'true';

    function syncReady() {
      const wrapper = document.querySelector('.menu-wrapper');
      const list = document.querySelector('.menu-list');
      const isReady =
        !!wrapper?.classList.contains('menu-wrapper--visible') ||
        !!list?.classList.contains('menu-list--visible');
      document.body.classList.toggle('menu-chrome-ready', isReady);
      if (!isReady) {
        return;
      }
    }

    const observer = new MutationObserver(syncReady);
    const wrapper = document.querySelector('.menu-wrapper');
    const list = document.querySelector('.menu-list');
    if (wrapper) {
      observer.observe(wrapper, {
        attributes: true,
        attributeFilter: ['class'],
      });
    }
    if (list) {
      observer.observe(list, { attributes: true, attributeFilter: ['class'] });
    }
    syncReady();
  }

  function setCssReady() {
    if (revealTimer) {
      clearTimeout(revealTimer);
      revealTimer = null;
    }
    document.body?.classList.add('menu-css-ready');
  }

  function ensureMenuDataLabels() {
    document.querySelectorAll('.menu-item .menu-label').forEach((label) => {
      if (!label.dataset.label) {
        label.dataset.label = (label.textContent || '').trim();
      }
      const item = label.closest('.menu-item');
      if (item && !item.dataset.label) {
        item.dataset.label = label.dataset.label;
      }
    });
  }

  function applyChapterText(chapter) {
    document.querySelectorAll('.menu-title-sub').forEach((node) => {
      node.textContent = chapter.subtitle;
    });
    document.querySelectorAll('.menu-title-sub-ghost').forEach((node) => {
      node.textContent = chapter.subtitle;
    });
  }

  function removeNode(node) {
    if (node?.parentNode) {
      node.parentNode.removeChild(node);
    }
  }

  function unloadCurrentChapter() {
    if (typeof window.__menuChapterTeardown === 'function') {
      try {
        window.__menuChapterTeardown();
      } catch (error) {
        console.error('[MenuChapters] Chapter teardown failed:', error);
      }
    }
    window.__menuChapterTeardown = null;

    removeNode(currentStyleEl);
    removeNode(currentScriptEl);
    currentStyleEl = null;
    currentScriptEl = null;
  }

  function loadCSS(href) {
    if (!href) {
      setCssReady();
      return;
    }

    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = assetUrl(href);
    link.dataset.chapterStyle = 'true';
    link.onload = setCssReady;
    link.onerror = setCssReady;
    document.head.appendChild(link);
    currentStyleEl = link;

    revealTimer = setTimeout(setCssReady, CSS_READY_FALLBACK_MS);
  }

  function loadJS(src) {
    if (!src) {
      return;
    }

    const script = document.createElement('script');
    script.src = assetUrl(src);
    script.defer = true;
    script.dataset.chapterScript = 'true';
    script.onerror = () => {
      console.error('[MenuChapters] Failed to load script:', src);
    };
    document.body.appendChild(script);
    currentScriptEl = script;
  }

  function setupAudio(src) {
    const bgm = document.getElementById('bgm');
    if (!bgm || !src) {
      return;
    }

    try {
      bgm.pause();
      bgm.currentTime = 0;
      bgm.src = assetUrl(src);
      bgm.loop = true;
      bgm.load();
    } catch {}
  }

  function loadChapter(name) {
    const chapter = MENU_CHAPTERS[name] || MENU_CHAPTERS[DEFAULT_CHAPTER];
    if (!chapter || !document.body) {
      return;
    }

    unloadCurrentChapter();
    document.body.classList.remove('menu-css-ready');
    document.body.dataset.chapter = chapter.id;

    applyChapterText(chapter);
    ensureMenuDataLabels();
    setupAudio(chapter.audio);
    setupMenuChrome();
    loadCSS(chapter.css);
    loadJS(chapter.js);
  }

  window.setMenuChapter = loadChapter;
  window.__HOWLING_MENU_CHAPTERS = MENU_CHAPTERS;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () =>
      loadChapter(DEFAULT_CHAPTER),
    );
  } else {
    loadChapter(DEFAULT_CHAPTER);
  }
})();
