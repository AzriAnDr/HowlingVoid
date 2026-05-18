// Howling Void chapter loader.
(() => {
  // Local/default config. BYOND can override these before this script loads.
  // This keeps the menu usable when index.html is opened directly from disk.
  window.__HOWLING_MENU_SETTINGS = {
    musicEnabled: true,
    musicVolume: 0.6,
    interfaceLanguage: 'russian',
    ...(window.__HOWLING_MENU_SETTINGS || {}),
  };

  const getMenuSettings = () =>
    (window.__HOWLING_MENU_SETTINGS = {
      musicEnabled: true,
      musicVolume: 0.6,
      interfaceLanguage: 'russian',
      ...(window.__HOWLING_MENU_SETTINGS || {}),
    });

  const ASSET_MAP = window.__HOWLING_MENU_ASSETS || {};
  const SCRIPT_SRC = document.currentScript?.src || '';
  const SCRIPT_BASE = SCRIPT_SRC.slice(0, SCRIPT_SRC.lastIndexOf('/') + 1);

  const MENU_CHAPTERS = {
    ironHeart: {
      id: 'ironHeart',
      subtitle: 'IRON HEART',
      variantLabel: 'IRON HEART',
      css: 'ironHeart.css',
      js: 'ironHeart.js',
      audio: 'iron_heart.ogg',
    },
    jesusWept: {
      id: 'jesusWept',
      subtitle: 'JESUS WEPT',
      variantLabel: 'JESUS WEPT',
      css: 'jesusWept.css',
      js: 'jesusWept.js',
      audio: 'jesus_wept.ogg',
    },
    crossToBear: {
      id: 'crossToBear',
      subtitle: 'JESUS WEPT',
      variantLabel: 'CROSS TO BEAR',
      css: 'crossToBear.css',
      js: 'crossToBear.js',
      audio: 'cross_to_bear.ogg',
    },
    sisterRay: {
      id: 'sisterRay',
      subtitle: 'IRON HEART',
      variantLabel: 'SISTER RAY',
      css: 'sisterRay.css',
      js: 'sisterRay.js',
      audio: 'Sister_Ray.mp3',
    },
    molesHamsters: {
      id: 'molesHamsters',
      subtitle: 'КРОТЫ — ХОМЯКИ',
      variantLabel: 'MOLES / HAMSTERS',
      css: 'molesHamsters.css',
      js: 'molesHamsters.js',
      audio: 'molesHamsters.mp3',
    },
  };

  MENU_CHAPTERS.molesHamsters.variantLabel = 'MOLES / HAMSTERS';

  const MENU_VARIANT_GROUPS = {
    ironHeart: {
      label: 'CHAPTER I MENU:',
      variants: ['ironHeart', 'sisterRay'],
    },
    jesusWept: {
      label: 'CHAPTER III MENU:',
      variants: ['jesusWept', 'crossToBear'],
    },
    event: {
      label: 'EVENT MENU:',
      variants: ['molesHamsters'],
    },
  };

  const DEFAULT_CHAPTER = 'sisterRay';
  const MENU_VARIANT_STORAGE_KEY = `howlingMenuChapterVariant:${DEFAULT_CHAPTER}`;
  const CSS_READY_FALLBACK_MS = 1200;
  const MENU_CHROME_STYLE_ID = 'howling-menu-chrome-style';

  let currentStyleEl = null;
  let currentScriptEl = null;
  let currentChapterId = null;
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

  window.__HOWLING_INSTALL_WEBGL_BACKDROP = (options = {}) => {
    const canvas = document.createElement('canvas');
    canvas.className = options.className || 'menu-webgl-backdrop';
    canvas.setAttribute('aria-hidden', 'true');
    Object.assign(canvas.style, {
      position: 'fixed',
      inset: '0',
      width: '100%',
      height: '100%',
      zIndex: String(options.zIndex ?? 0),
      pointerEvents: 'none',
    });
    document.body.prepend(canvas);

    const gl = canvas.getContext('webgl', {
      alpha: true,
      antialias: false,
      depth: false,
      preserveDrawingBuffer: false,
      stencil: false,
    });

    if (!gl) {
      canvas.remove();
      return () => {};
    }

    const createShader = (type, source) => {
      const shader = gl.createShader(type);
      gl.shaderSource(shader, source);
      gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        gl.deleteShader(shader);
        return null;
      }
      return shader;
    };

    const vertex = createShader(
      gl.VERTEX_SHADER,
      `
        attribute vec2 a_position;
        varying vec2 v_uv;
        void main() {
          v_uv = a_position * 0.5 + 0.5;
          gl_Position = vec4(a_position, 0.0, 1.0);
        }
      `,
    );
    const fragment = createShader(
      gl.FRAGMENT_SHADER,
      `
        precision mediump float;
        varying vec2 v_uv;
        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec3 u_color0;
        uniform vec3 u_color1;
        uniform vec3 u_color2;
        uniform vec3 u_color3;
        uniform float u_intensity;
        uniform float u_vignette;

        float blob(vec2 uv, vec2 center, float radius) {
          return smoothstep(radius, 0.0, distance(uv, center));
        }

        void main() {
          vec2 uv = v_uv;
          float aspect = u_resolution.x / max(1.0, u_resolution.y);
          vec2 centered = vec2((uv.x - 0.5) * aspect, uv.y - 0.5);
          float t = u_time * 0.001;
          vec2 driftA = vec2(sin(t * 0.13) * 0.065, cos(t * 0.11) * 0.052);
          vec2 driftB = vec2(cos(t * 0.09) * 0.055, sin(t * 0.10) * 0.06);

          vec3 color = mix(u_color0, u_color1, smoothstep(-0.08, 1.15, uv.x + uv.y));
          color = mix(color, u_color2, blob(uv + driftA, vec2(0.22, 0.26), 0.42) * u_intensity);
          color = mix(color, u_color3, blob(uv - driftB, vec2(0.76, 0.68), 0.50) * u_intensity);
          color += u_color1 * blob(uv + vec2(driftB.y, -driftB.x), vec2(0.56, 0.46), 0.38) * 0.18;

          float vignette = smoothstep(0.88, 0.18, length(centered));
          color = mix(color, color * 0.42, (1.0 - vignette) * u_vignette);
          gl_FragColor = vec4(color, 0.96);
        }
      `,
    );

    if (!vertex || !fragment) {
      canvas.remove();
      return () => {};
    }

    const program = gl.createProgram();
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      gl.deleteProgram(program);
      canvas.remove();
      return () => {};
    }

    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(
      gl.ARRAY_BUFFER,
      new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]),
      gl.STATIC_DRAW,
    );

    const parseColor = (hex, defaultColor) => {
      const value = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(
        String(hex || ''),
      );
      if (!value) return defaultColor;
      return [
        Number.parseInt(value[1], 16) / 255,
        Number.parseInt(value[2], 16) / 255,
        Number.parseInt(value[3], 16) / 255,
      ];
    };

    const colors = options.colors || [];
    const uniforms = {
      position: gl.getAttribLocation(program, 'a_position'),
      resolution: gl.getUniformLocation(program, 'u_resolution'),
      time: gl.getUniformLocation(program, 'u_time'),
      color0: gl.getUniformLocation(program, 'u_color0'),
      color1: gl.getUniformLocation(program, 'u_color1'),
      color2: gl.getUniformLocation(program, 'u_color2'),
      color3: gl.getUniformLocation(program, 'u_color3'),
      intensity: gl.getUniformLocation(program, 'u_intensity'),
      vignette: gl.getUniformLocation(program, 'u_vignette'),
    };

    function resize() {
      const dpr = Math.min(1.5, window.devicePixelRatio || 1);
      const width = Math.max(1, Math.floor(canvas.clientWidth * dpr));
      const height = Math.max(1, Math.floor(canvas.clientHeight * dpr));
      if (canvas.width !== width || canvas.height !== height) {
        canvas.width = width;
        canvas.height = height;
      }
      gl.viewport(0, 0, width, height);
    }

    let frame = 0;
    const render = (now) => {
      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.useProgram(program);
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.enableVertexAttribArray(uniforms.position);
      gl.vertexAttribPointer(uniforms.position, 2, gl.FLOAT, false, 0, 0);

      gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);
      gl.uniform1f(uniforms.time, now);
      [
        uniforms.color0,
        uniforms.color1,
        uniforms.color2,
        uniforms.color3,
      ].forEach((uniform, index) => {
        gl.uniform3fv(uniform, parseColor(colors[index], [0.02, 0.02, 0.02]));
      });
      gl.uniform1f(uniforms.intensity, options.intensity ?? 0.55);
      gl.uniform1f(uniforms.vignette, options.vignette ?? 0.85);
      gl.drawArrays(gl.TRIANGLES, 0, 6);
      frame = requestAnimationFrame(render);
    };

    const readyClass = options.readyClass || 'menu-webgl-backdrop-ready';
    resize();
    window.addEventListener('resize', resize);
    document.body.classList.add(readyClass);
    frame = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener('resize', resize);
      document.body.classList.remove(readyClass);
      gl.deleteBuffer(buffer);
      gl.deleteProgram(program);
      canvas.remove();
    };
  };

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

      .menu-variant-control {
        position: fixed;
        z-index: 130;
        top: 18px;
        left: 18px;
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 6px;
        background: var(--menu-chrome-bg, rgba(8, 0, 0, 0.34));
        border: var(--menu-chrome-border, 1px solid rgba(180, 30, 30, 0.34));
        box-shadow: var(--menu-chrome-shadow, 0 0 24px rgba(130, 0, 0, 0.22), inset 0 0 18px rgba(255, 230, 200, 0.04));
        opacity: 0.82;
      }

      .menu-variant-control:hover,
      .menu-variant-control:focus-within {
        opacity: 0.98;
      }

      .menu-variant-control__label {
        padding: 0 8px 0 4px;
        color: var(--menu-chrome-fg, rgba(246, 226, 202, 0.72));
        font: 700 10px/1 "Crimson Text", serif;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        pointer-events: none;
      }

      .menu-variant-control__button {
        min-width: 38px;
        height: 26px;
        border: 0;
        padding: 0 9px;
        color: var(--menu-chrome-fg, rgba(246, 226, 202, 0.82));
        background: transparent;
        font: 700 11px/1 "Crimson Text", serif;
        letter-spacing: 0.12em;
        text-transform: uppercase;
        cursor: pointer;
      }

      .menu-variant-control__button:hover,
      .menu-variant-control__button:focus-visible,
      .menu-variant-control__button--active {
        color: var(--menu-chrome-name-fg, rgba(255, 238, 214, 0.92));
        background: rgba(159, 23, 23, 0.34);
        outline: none;
      }

      body[data-menu-variant-locked] .menu-variant-control,
      body.menu-chrome-ready .menu-variant-control {
        opacity: 0;
        pointer-events: none;
      }

      body[data-chapter] .start-skip {
        display: flex !important;
        width: fit-content !important;
        align-items: center !important;
        justify-content: center !important;
        margin-left: auto !important;
        margin-right: auto !important;
      }

      body[data-chapter] .start-button {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        margin-left: auto !important;
        margin-right: auto !important;
      }

      body[data-chapter="jesusWept"] .start-text .epilepsy-warning,
      body[data-chapter="crossToBear"] .start-text .epilepsy-warning {
        position: relative;
        display: inline-block;
        padding: 0 0.08em;
        color: #ff0000 !important;
        background:
          linear-gradient(90deg, rgba(255, 255, 255, 0.92) 0 8%, transparent 8% 18%, rgba(255, 0, 0, 0.92) 18% 34%, transparent 34% 100%),
          #070000;
        filter: contrast(2.2) saturate(2.6);
        text-shadow:
          -3px 0 0 #00fff0,
          3px 0 0 #ff0000,
          0 0 3px rgba(255, 255, 255, 0.95),
          0 0 7px rgba(255, 0, 0, 0.98),
          0 0 18px rgba(255, 0, 0, 0.88);
        box-shadow:
          0 0 0 1px rgba(255, 0, 0, 0.7),
          0 0 18px rgba(255, 0, 0, 0.72),
          inset 0 0 16px rgba(0, 0, 0, 0.95);
        transform-origin: 50% 55%;
        animation:
          epilepsyWarningJitter 520ms steps(1, end) infinite,
          epilepsyWarningNegative 880ms steps(1, end) infinite;
        will-change: transform, filter, color, background;
      }

      body[data-chapter="jesusWept"] .start-text .epilepsy-warning::before,
      body[data-chapter="jesusWept"] .start-text .epilepsy-warning::after,
      body[data-chapter="crossToBear"] .start-text .epilepsy-warning::before,
      body[data-chapter="crossToBear"] .start-text .epilepsy-warning::after {
        content: attr(data-text);
        position: absolute;
        inset: 0;
        overflow: hidden;
        pointer-events: none;
        mix-blend-mode: screen;
      }

      body[data-chapter="jesusWept"] .start-text .epilepsy-warning::before,
      body[data-chapter="crossToBear"] .start-text .epilepsy-warning::before {
        color: #00fff0;
        clip-path: inset(0 0 56% 0);
        text-shadow: -2px 0 0 #00fff0;
        transform: translate(-3px, -1px);
        animation: epilepsyWarningSliceTop 310ms steps(1, end) infinite;
      }

      body[data-chapter="jesusWept"] .start-text .epilepsy-warning::after,
      body[data-chapter="crossToBear"] .start-text .epilepsy-warning::after {
        color: #ffffff;
        clip-path: inset(48% 0 0 0);
        text-shadow: 2px 0 0 #ff1010;
        transform: translate(3px, 1px);
        animation: epilepsyWarningSliceBottom 260ms steps(1, end) infinite;
      }

      @keyframes epilepsyWarningJitter {
        0% { transform: translate(0, 0) skewX(0deg); }
        10% { transform: translate(-3px, 1px) skewX(-8deg); }
        18% { transform: translate(4px, -2px) skewX(7deg); }
        28% { transform: translate(-1px, 2px) skewX(-3deg); }
        40% { transform: translate(5px, 0) skewX(10deg); }
        52% { transform: translate(-5px, -1px) skewX(-9deg); }
        64% { transform: translate(2px, 3px) skewX(4deg); }
        76% { transform: translate(-2px, -3px) skewX(-6deg); }
        88% { transform: translate(3px, 1px) skewX(5deg); }
        100% { transform: translate(0, 0) skewX(0deg); }
      }

      @keyframes epilepsyWarningNegative {
        0%, 24%, 42%, 69%, 100% {
          color: #ff0000;
          background-color: #060000;
          filter: contrast(2.2) saturate(2.6);
        }
        25%, 31% {
          color: #000000;
          background-color: #ffffff;
          filter: invert(1) contrast(4) saturate(3.4);
        }
        43%, 48% {
          color: #ffffff;
          background-color: #ff0000;
          filter: contrast(4) saturate(4);
        }
        70%, 76% {
          color: #00fff0;
          background-color: #120000;
          filter: invert(0.75) contrast(3.4) saturate(5);
        }
      }

      @keyframes epilepsyWarningSliceTop {
        0% { clip-path: inset(0 0 62% 0); transform: translate(-5px, -1px); opacity: 0.9; }
        18% { clip-path: inset(0 0 30% 0); transform: translate(4px, 1px); opacity: 1; }
        37% { clip-path: inset(18% 0 52% 0); transform: translate(-8px, 0); opacity: 0.78; }
        58% { clip-path: inset(0 0 72% 0); transform: translate(7px, -2px); opacity: 1; }
        82% { clip-path: inset(28% 0 42% 0); transform: translate(-3px, 2px); opacity: 0.84; }
        100% { clip-path: inset(0 0 62% 0); transform: translate(-5px, -1px); opacity: 0.9; }
      }

      @keyframes epilepsyWarningSliceBottom {
        0% { clip-path: inset(48% 0 0 0); transform: translate(5px, 1px); opacity: 0.88; }
        22% { clip-path: inset(66% 0 0 0); transform: translate(-6px, -1px); opacity: 1; }
        43% { clip-path: inset(38% 0 18% 0); transform: translate(8px, 0); opacity: 0.78; }
        63% { clip-path: inset(58% 0 0 0); transform: translate(-3px, 2px); opacity: 1; }
        85% { clip-path: inset(44% 0 26% 0); transform: translate(4px, -2px); opacity: 0.84; }
        100% { clip-path: inset(48% 0 0 0); transform: translate(5px, 1px); opacity: 0.88; }
      }

      @media (max-width: 1366px), (max-height: 820px) {
        body[data-chapter] .start-overlay {
          padding: 16px !important;
        }

        body[data-chapter] .start-center {
          max-width: min(900px, calc(100vw - 56px)) !important;
          max-height: calc(100vh - 46px) !important;
          padding: 22px 28px !important;
          overflow: auto !important;
        }

        body[data-chapter] .start-title {
          font-size: clamp(22px, 3.2vw, 34px) !important;
          line-height: 1.05 !important;
        }

        body[data-chapter] .start-text {
          max-height: min(46vh, 360px) !important;
          font-size: clamp(14px, 1.7vw, 18px) !important;
          line-height: 1.32 !important;
        }

        body[data-chapter] .menu-wrapper {
          padding-top: clamp(22px, 4vh, 46px) !important;
          padding-bottom: clamp(54px, 8vh, 86px) !important;
        }

        body[data-chapter] .menu-title-main {
          font-size: clamp(42px, 7.2vw, 96px) !important;
          line-height: 0.9 !important;
        }

        body[data-chapter] .menu-title-small,
        body[data-chapter] .menu-title-sub {
          font-size: clamp(11px, 1.3vw, 17px) !important;
          line-height: 1.15 !important;
        }

        body[data-chapter] .menu-list {
          max-width: min(620px, calc(100vw - 72px)) !important;
        }

        body[data-chapter] .menu-item {
          min-height: 0 !important;
          font-size: clamp(15px, 1.8vw, 22px) !important;
          line-height: 1.05 !important;
        }

        .menu-audio-control {
          bottom: 34px !important;
          min-width: 210px !important;
          padding: 8px 12px !important;
        }

        .menu-audio-control__range {
          width: 130px !important;
        }

        .menu-character-footer {
          bottom: 10px !important;
          font-size: 12px !important;
          max-width: calc(100vw - 38px) !important;
        }
      }

      @media (max-width: 1100px), (max-height: 680px) {
        body[data-chapter] .start-center {
          padding: 18px 22px !important;
        }

        body[data-chapter] .menu-title-main {
          font-size: clamp(34px, 6.4vw, 72px) !important;
        }

        body[data-chapter] .menu-item {
          font-size: clamp(13px, 1.65vw, 18px) !important;
          padding-top: 7px !important;
          padding-bottom: 7px !important;
        }

        body[data-chapter] .menu-language-control {
          top: 10px !important;
          right: 10px !important;
          padding: 4px !important;
        }

        body[data-chapter] .menu-variant-control {
          top: 10px !important;
          left: 10px !important;
          padding: 4px !important;
        }

        body[data-chapter] .menu-language-control__button,
        body[data-chapter] .menu-variant-control__button {
          min-width: 28px !important;
          height: 22px !important;
          padding: 0 6px !important;
        }

        body[data-chapter] .menu-variant-control__label {
          display: none !important;
        }
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
    const selectSound = document.getElementById('select-sound');
    if (selectSound && selectSound.dataset.assetReady !== 'true') {
      selectSound.src = assetUrl('buttonclickrelease.ogg');
      selectSound.dataset.assetReady = 'true';
    }

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
      const settings = getMenuSettings();
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
        getMenuSettings().musicVolume = Math.max(0, Math.min(1, percent / 100));
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
    const settings = getMenuSettings();
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
    getMenuSettings().interfaceLanguage = normalized;
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

  function getVariantGroupForChapter(chapterId) {
    return Object.values(MENU_VARIANT_GROUPS).find((group) =>
      group.variants.includes(chapterId),
    );
  }

  function setupVariantControl() {
    const chapterId =
      currentChapterId || document.body?.dataset.chapter || DEFAULT_CHAPTER;
    const group = getVariantGroupForChapter(chapterId);
    const existingControl = document.querySelector('.menu-variant-control');

    if (!group) {
      existingControl?.remove();
      return;
    }

    const desiredVariantList = group.variants.join('|');
    let control = existingControl;
    if (!control || control.dataset.variants !== desiredVariantList) {
      control?.remove();
      control = document.createElement('div');
      control.className = 'menu-variant-control';
      control.dataset.variants = desiredVariantList;

      const label = document.createElement('span');
      label.className = 'menu-variant-control__label';
      label.textContent = group.label;
      control.appendChild(label);

      group.variants.forEach((variantId) => {
        const chapter = MENU_CHAPTERS[variantId];
        if (!chapter) {
          return;
        }

        const button = document.createElement('button');
        button.className = 'menu-variant-control__button';
        button.type = 'button';
        button.dataset.chapter = variantId;
        button.textContent =
          chapter.variantLabel || chapter.subtitle || variantId;
        control.appendChild(button);
      });

      document.body.appendChild(control);
    }

    if (control.dataset.ready !== 'true') {
      control.dataset.ready = 'true';
      control.addEventListener('click', (event) => {
        const button = event.target.closest('[data-chapter]');
        if (!button) {
          return;
        }

        setMenuVariant(button.dataset.chapter);
      });
    }

    syncVariantControl();
    setupVariantAvailabilityWatcher();
    syncVariantAvailability();
  }

  function syncVariantControl() {
    const activeChapter =
      currentChapterId || document.body?.dataset.chapter || DEFAULT_CHAPTER;
    document
      .querySelectorAll('.menu-variant-control__button[data-chapter]')
      .forEach((button) => {
        const isActive = button.dataset.chapter === activeChapter;
        button.classList.toggle(
          'menu-variant-control__button--active',
          isActive,
        );
        button.setAttribute('aria-pressed', String(isActive));
      });
  }

  function syncVariantAvailability() {
    const startOverlay = document.querySelector('.start-overlay');
    const isLocked =
      !startOverlay || startOverlay.classList.contains('start-overlay--hidden');
    document.body?.toggleAttribute('data-menu-variant-locked', isLocked);
  }

  function setupVariantAvailabilityWatcher() {
    if (document.body?.dataset.menuVariantWatcher === 'true') {
      return;
    }
    document.body.dataset.menuVariantWatcher = 'true';

    const observer = new MutationObserver(syncVariantAvailability);
    observer.observe(document.body, { childList: true });

    const startOverlay = document.querySelector('.start-overlay');
    if (startOverlay) {
      observer.observe(startOverlay, {
        attributes: true,
        attributeFilter: ['class'],
      });
    }
  }

  function rememberMenuVariant(chapterId, notifyServer) {
    getMenuSettings().menuChapter = chapterId;
    try {
      localStorage.setItem(MENU_VARIANT_STORAGE_KEY, chapterId);
    } catch {}

    if (!notifyServer) {
      return;
    }

    const src = getMenuSettings().byondSrc || window.__HOWLING_MENU_SRC;
    if (!src) {
      return;
    }

    window.location.href =
      'byond://?src=' +
      src +
      ';set_menu_chapter=' +
      encodeURIComponent(chapterId);
  }

  function setMenuVariant(chapterId) {
    if (!MENU_CHAPTERS[chapterId]) {
      return;
    }

    if (document.body?.hasAttribute('data-menu-variant-locked')) {
      return;
    }

    rememberMenuVariant(chapterId, true);
    loadChapter(chapterId);
  }

  function setMenuChapterFromServer(chapterId) {
    if (!MENU_CHAPTERS[chapterId]) {
      return;
    }

    rememberMenuVariant(chapterId, false);
    if (currentChapterId === chapterId) {
      setupAudio(MENU_CHAPTERS[chapterId].audio);
      syncVariantControl();
      return;
    }
    loadChapter(chapterId);
  }

  function setupMenuChrome() {
    injectMenuChromeStyle();
    setupCharacterFooter();
    setupAudioControl();
    setupLanguageControl();
    setupVariantControl();
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

    if (currentChapterId === chapter.id) {
      syncVariantControl();
      return;
    }

    unloadCurrentChapter();
    document.body.classList.remove('menu-css-ready');
    document.body.dataset.chapter = chapter.id;
    currentChapterId = chapter.id;
    getMenuSettings().menuChapter = chapter.id;

    applyChapterText(chapter);
    ensureMenuDataLabels();
    setupAudio(chapter.audio);
    setupMenuChrome();
    loadCSS(chapter.css);
    loadJS(chapter.js);
  }

  function getInitialChapter() {
    const settingsChapter = getMenuSettings().menuChapter;
    if (MENU_CHAPTERS[settingsChapter]) {
      return settingsChapter;
    }

    try {
      const storedChapter = localStorage.getItem(MENU_VARIANT_STORAGE_KEY);
      if (MENU_CHAPTERS[storedChapter]) {
        return storedChapter;
      }
    } catch {}

    return DEFAULT_CHAPTER;
  }

  window.setMenuChapter = loadChapter;
  window.setMenuChapterFromServer = setMenuChapterFromServer;
  window.setMenuVariant = setMenuVariant;
  window.__HOWLING_MENU_CHAPTERS = MENU_CHAPTERS;
  window.__HOWLING_MENU_VARIANT_GROUPS = MENU_VARIANT_GROUPS;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () =>
      loadChapter(getInitialChapter()),
    );
  } else {
    loadChapter(getInitialChapter());
  }
})();
