/* =========================================================
   HOWLING VOID — SISTER RAY / THE GROWING STONES
========================================================= */

(() => {
  const settings = () =>
    (window.__HOWLING_MENU_SETTINGS = {
      musicEnabled: true,
      musicVolume: 0.6,
      interfaceLanguage: 'russian',
      ...(window.__HOWLING_MENU_SETTINGS || {}),
    });

  const clamp01 = (v) => Math.min(1, Math.max(0, Number(v) || 0));
  const configuredVolume = () => clamp01(settings().musicVolume ?? 0.6);
  const musicEnabled = () =>
    settings().musicEnabled !== false && configuredVolume() > 0;

  const q = (selector) => document.querySelector(selector);
  const qa = (selector) => Array.from(document.querySelectorAll(selector));

  const menuItems = qa('.menu-item');
  const startOverlay = q('.start-overlay');
  const startButton = q('.start-button');
  const skipIntro = q('#skip-intro');
  const introOverlay = q('.intro-overlay');
  const menuWrapper = q('.menu-wrapper');
  const menuList = q('.menu-list');
  const menuDivider = q('.menu-divider');
  const titleMain = q('.menu-title-main');
  const titleSmall = q('.menu-title-small');
  const titleSmallGhost = q('.menu-title-small-ghost');
  const titleSub = q('.menu-title-sub');
  const titleSubGhost = q('.menu-title-sub-ghost');
  const whiteFlash = q('.white-flash');
  const bloodFlash = q('.blood-flash');
  const bgm = q('#bgm');
  const selectSound = q('#select-sound');

  const timers = [];
  const intervals = [];
  const listeners = [];
  const glCleanups = [];
  let webglFrame = 0;
  let started = false;
  let introEnded = false;
  let activeIndex = Math.max(
    0,
    menuItems.findIndex((el) => el.classList.contains('menu-item--active')),
  );
  let fadeToken = 0;
  let captionIndex = 0;
  let actionLocked = false;

  const CAPTIONS_RU = [
    'сигнал выцветает, но камни продолжают расти',
    'воспоминание не исчезло — оно сменило цвет',
    'мягкая плёнка, резкий свет, чужой коридор',
    'она сказала: не смотри прямо на вспышку',
    'howling void x Sister Ray - Прогулка на дикой улице',
  ];

  const CAPTIONS_EN = [
    'the signal fades, but the stones keep growing',
    'the memory did not vanish — it changed color',
    'soft film, sharp light, a borrowed corridor',
    'she said: do not look directly at the flash',
    'howling void x Sister Ray - Прогулка на дикой улице',
  ];

  const SIDE_NOTES_RU = [
    'никто не должен знать',
    'ломка растет',
    'продай картину',
    'держи себя в руках',
    'сестра не узнает',
    'деньги к вечеру',
    'пережить день',
    'не подавай виду',
    'цветовой трип',
    'плёнка повреждена',
    'мягкий разлом',
    'отложенное эхо',
  ];

  const SIDE_NOTES_EN = [
    'no one should know',
    'withdrawal grows',
    'sell the painting',
    'keep composure',
    'she must not know',
    'cash by evening',
    'survive the day',
    'do not show it',
    'color trip',
    'film damaged',
    'soft fracture',
    'delayed echo',
  ];

  function on(target, type, handler, options) {
    if (!target) return;
    target.addEventListener(type, handler, options);
    listeners.push([target, type, handler, options]);
  }

  function tset(fn, ms) {
    const id = window.setTimeout(fn, ms);
    timers.push(id);
    return id;
  }

  function iset(fn, ms) {
    const id = window.setInterval(fn, ms);
    intervals.push(id);
    return id;
  }

  function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  function createProgram(gl, vertexSource, fragmentSource) {
    const vertex = createShader(gl, gl.VERTEX_SHADER, vertexSource);
    const fragment = createShader(gl, gl.FRAGMENT_SHADER, fragmentSource);
    if (!vertex || !fragment) return null;

    const program = gl.createProgram();
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      gl.deleteProgram(program);
      return null;
    }
    return program;
  }

  function setupWebgl(canvas) {
    if (!canvas) return false;

    const gl = canvas.getContext('webgl', {
      alpha: true,
      antialias: false,
      depth: false,
      preserveDrawingBuffer: false,
      stencil: false,
    });
    if (!gl) return false;

    const backdropProgram = createProgram(
      gl,
      `
        attribute vec2 a_position;
        varying vec2 v_uv;
        void main() {
          v_uv = a_position * 0.5 + 0.5;
          gl_Position = vec4(a_position, 0.0, 1.0);
        }
      `,
      `
        precision mediump float;
        varying vec2 v_uv;
        uniform vec2 u_resolution;
        uniform float u_time;

        float blob(vec2 uv, vec2 center, float radius) {
          float d = distance(uv, center);
          return smoothstep(radius, 0.0, d);
        }

        void main() {
          vec2 uv = v_uv;
          float aspect = u_resolution.x / max(1.0, u_resolution.y);
          vec2 centered = vec2((uv.x - 0.5) * aspect, uv.y - 0.5);
          float t = u_time * 0.001;

          vec2 drift = vec2(sin(t * 0.19) * 0.035, cos(t * 0.16) * 0.03);
          vec3 color = vec3(0.10, 0.18, 0.18);
          color = mix(color, vec3(0.94, 0.78, 0.38), smoothstep(0.0, 1.18, uv.x + uv.y));
          color = mix(color, vec3(0.75, 0.13, 0.36), blob(uv + drift, vec2(0.72, 0.78), 0.46) * 0.56);
          color = mix(color, vec3(0.16, 0.72, 0.56), blob(uv - drift, vec2(0.18, 0.22), 0.38) * 0.62);
          color += vec3(0.38, 0.30, 0.08) * blob(uv + vec2(drift.y, -drift.x), vec2(0.70, 0.16), 0.32);

          float beamA = smoothstep(0.085, 0.0, abs((uv.y - 0.22) - (uv.x - 0.15) * 0.52));
          float beamB = smoothstep(0.07, 0.0, abs((uv.y - 0.82) + (uv.x - 0.55) * 0.42));
          color += vec3(0.32, 0.24, 0.04) * beamA * 0.42;
          color += vec3(0.38, 0.04, 0.18) * beamB * 0.28;

          float vignette = smoothstep(0.82, 0.18, length(centered));
          color = mix(color, color * vec3(0.52, 0.26, 0.38), 1.0 - vignette);

          gl_FragColor = vec4(color, 0.94);
        }
      `,
    );

    const stonesProgram = createProgram(
      gl,
      `
        attribute vec2 a_origin;
        attribute vec2 a_drift;
        attribute float a_size;
        attribute float a_phase;
        uniform vec2 u_resolution;
        uniform float u_time;
        varying float v_alpha;

        void main() {
          float t = u_time * 0.001;
          float wave = sin(t * (0.32 + a_phase * 0.08) + a_phase);
          vec2 pos = a_origin + a_drift * (0.5 + wave * 0.5);
          vec2 clip = pos * 2.0 - 1.0;
          gl_Position = vec4(clip * vec2(1.0, -1.0), 0.0, 1.0);
          gl_PointSize = a_size * (0.82 + wave * 0.22);
          v_alpha = 0.22 + max(0.0, wave) * 0.34;
        }
      `,
      `
        precision mediump float;
        varying float v_alpha;

        void main() {
          vec2 p = gl_PointCoord - 0.5;
          float d = length(p);
          float core = smoothstep(0.5, 0.08, d);
          float ring = smoothstep(0.5, 0.42, d) * smoothstep(0.24, 0.42, d);
          vec3 color = mix(vec3(0.86, 0.23, 0.42), vec3(1.0, 0.88, 0.52), core);
          color += vec3(0.05, 0.38, 0.30) * ring;
          gl_FragColor = vec4(color, (core * 0.7 + ring * 0.28) * v_alpha);
        }
      `,
    );

    if (!backdropProgram || !stonesProgram) return false;

    const quadBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
    gl.bufferData(
      gl.ARRAY_BUFFER,
      new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]),
      gl.STATIC_DRAW,
    );

    const stones = [];
    for (let i = 0; i < 28; i++) {
      stones.push(
        Math.random(),
        Math.random(),
        -0.035 + Math.random() * 0.07,
        -0.07 + Math.random() * 0.14,
        4 + Math.random() * 13,
        Math.random() * 12,
      );
    }
    const stoneBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, stoneBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(stones), gl.STATIC_DRAW);

    const backdropPosition = gl.getAttribLocation(
      backdropProgram,
      'a_position',
    );
    const backdropResolution = gl.getUniformLocation(
      backdropProgram,
      'u_resolution',
    );
    const backdropTime = gl.getUniformLocation(backdropProgram, 'u_time');
    const stoneOrigin = gl.getAttribLocation(stonesProgram, 'a_origin');
    const stoneDrift = gl.getAttribLocation(stonesProgram, 'a_drift');
    const stoneSize = gl.getAttribLocation(stonesProgram, 'a_size');
    const stonePhase = gl.getAttribLocation(stonesProgram, 'a_phase');
    const stoneResolution = gl.getUniformLocation(
      stonesProgram,
      'u_resolution',
    );
    const stoneTime = gl.getUniformLocation(stonesProgram, 'u_time');

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

    function render(now) {
      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);

      gl.disable(gl.BLEND);
      gl.useProgram(backdropProgram);
      gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
      gl.enableVertexAttribArray(backdropPosition);
      gl.vertexAttribPointer(backdropPosition, 2, gl.FLOAT, false, 0, 0);
      gl.uniform2f(backdropResolution, canvas.width, canvas.height);
      gl.uniform1f(backdropTime, now);
      gl.drawArrays(gl.TRIANGLES, 0, 6);

      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      gl.useProgram(stonesProgram);
      gl.bindBuffer(gl.ARRAY_BUFFER, stoneBuffer);
      const stride = 6 * Float32Array.BYTES_PER_ELEMENT;
      gl.enableVertexAttribArray(stoneOrigin);
      gl.vertexAttribPointer(stoneOrigin, 2, gl.FLOAT, false, stride, 0);
      gl.enableVertexAttribArray(stoneDrift);
      gl.vertexAttribPointer(
        stoneDrift,
        2,
        gl.FLOAT,
        false,
        stride,
        2 * Float32Array.BYTES_PER_ELEMENT,
      );
      gl.enableVertexAttribArray(stoneSize);
      gl.vertexAttribPointer(
        stoneSize,
        1,
        gl.FLOAT,
        false,
        stride,
        4 * Float32Array.BYTES_PER_ELEMENT,
      );
      gl.enableVertexAttribArray(stonePhase);
      gl.vertexAttribPointer(
        stonePhase,
        1,
        gl.FLOAT,
        false,
        stride,
        5 * Float32Array.BYTES_PER_ELEMENT,
      );
      gl.uniform2f(stoneResolution, canvas.width, canvas.height);
      gl.uniform1f(stoneTime, now);
      gl.drawArrays(gl.POINTS, 0, 28);

      webglFrame = requestAnimationFrame(render);
    }

    resize();
    on(window, 'resize', resize);
    webglFrame = requestAnimationFrame(render);
    document.body.classList.add('sr-webgl-ready');
    glCleanups.push(() => {
      cancelAnimationFrame(webglFrame);
      gl.deleteBuffer(quadBuffer);
      gl.deleteBuffer(stoneBuffer);
      gl.deleteProgram(backdropProgram);
      gl.deleteProgram(stonesProgram);
      document.body.classList.remove('sr-webgl-ready');
    });
    return true;
  }

  function currentLanguage() {
    return settings().interfaceLanguage === 'english' ? 'english' : 'russian';
  }

  function textPool(ru, en) {
    return currentLanguage() === 'english' ? en : ru;
  }

  function playTick() {
    const audio = selectSound;
    if (!audio) return;

    try {
      audio.currentTime = 0;
      audio.volume = 0.055;
      audio.play().catch(() => {});
    } catch {}
  }

  function fadeBgmTo(target, duration = 1600) {
    if (!bgm) return;
    const token = ++fadeToken;
    const from = clamp01(bgm.volume);
    const to = clamp01(target);
    const start = performance.now();
    const dur = Math.max(1, duration);

    const step = (now) => {
      if (token !== fadeToken) return;
      const p = Math.min(1, (now - start) / dur);
      const eased = 1 - (1 - p) ** 3;
      bgm.volume = clamp01(from + (to - from) * eased);
      if (p < 1) requestAnimationFrame(step);
    };

    requestAnimationFrame(step);
  }

  function startBgm() {
    if (!bgm) return;

    if (!musicEnabled()) {
      try {
        bgm.pause();
        bgm.currentTime = 0;
      } catch {}
      return;
    }

    try {
      bgm.loop = true;
      bgm.volume = 0;
      const play = bgm.play();
      const after = () => fadeBgmTo(configuredVolume(), 2200);
      if (play && play.then) play.then(after).catch(() => {});
      else after();
    } catch {}
  }

  function createStage() {
    if (q('.sr-stage')) return q('.sr-stage');

    const stage = document.createElement('div');
    stage.className = 'sr-stage';
    stage.innerHTML = `
      <canvas class="sr-webgl-canvas" aria-hidden="true"></canvas>
      <div class="sr-side-notes">archive scene<br>color drift<br>soft fracture</div>
      <div class="sr-frame-index">FRAME 00 / SIGNAL 72</div>
      <div class="sr-caption"></div>
    `;
    document.body.appendChild(stage);

    setupWebgl(stage.querySelector('.sr-webgl-canvas'));

    return stage;
  }

  function updateCaption() {
    const caption = q('.sr-caption');
    const notes = q('.sr-side-notes');
    const frame = q('.sr-frame-index');
    if (!caption) return;

    const captions = textPool(CAPTIONS_RU, CAPTIONS_EN);
    const side = textPool(SIDE_NOTES_RU, SIDE_NOTES_EN);
    caption.textContent = captions[captionIndex % captions.length];
    caption.classList.add('sr-caption--visible');

    if (notes) {
      const start = captionIndex % side.length;
      notes.innerHTML = [0, 1, 2]
        .map((n) => side[(start + n) % side.length])
        .join('<br>');
    }

    if (frame) {
      const frameNo = String(
        (captionIndex * 7 + Math.floor(Math.random() * 4)) % 99,
      ).padStart(2, '0');
      const signal = String(58 + Math.floor(Math.random() * 39)).padStart(
        2,
        '0',
      );
      frame.textContent = `FRAME ${frameNo} / SIGNAL ${signal}`;
    }

    captionIndex += 1;
    tset(() => caption.classList.remove('sr-caption--visible'), 2600);
  }

  function frameCut(strength = 'soft') {
    document.body.classList.add('sr-cut');
    menuWrapper?.classList.add('sr-cut');

    if (strength === 'hard' && whiteFlash) {
      whiteFlash.classList.add('white-flash--active');
      tset(() => whiteFlash.classList.remove('white-flash--active'), 180);
    }

    if (strength === 'blood' && bloodFlash) {
      bloodFlash.classList.add('blood-flash--active');
      tset(() => bloodFlash.classList.remove('blood-flash--active'), 140);
    }

    tset(() => {
      document.body.classList.remove('sr-cut');
      menuWrapper?.classList.remove('sr-cut');
    }, 320);
  }

  function revealSupportTitles() {
    titleSmall?.classList.add('menu-title-small--reveal');
    titleSmallGhost?.classList.add('menu-title-small-ghost--anim');
    titleSub?.classList.add('menu-title-sub--reveal');
    titleSubGhost?.classList.add('menu-title-sub-ghost--anim');
  }

  function revealMenu() {
    if (introEnded) return;
    introEnded = true;
    introOverlay?.classList.add('intro-overlay--hidden');
    menuWrapper?.classList.add('menu-wrapper--visible');
    menuList?.classList.add('menu-list--visible');
    menuDivider?.classList.add('menu-divider--visible');
    revealSupportTitles();

    if (titleMain) {
      titleMain.style.opacity = '1';
      titleMain.classList.add('menu-title-main--idle');
    }

    document.body.classList.add('menu-chrome-ready');
    updateCaption();
  }

  function runIntro() {
    introOverlay?.classList.remove('intro-overlay--hidden');
    introOverlay?.classList.add('intro-overlay--animating');
    frameCut('hard');
    tset(() => frameCut('soft'), 1200);
    tset(() => frameCut('blood'), 2700);
    tset(revealMenu, 3900);
  }

  function start(skip = false) {
    if (started) return;
    started = true;
    createStage();
    startOverlay?.classList.add('start-overlay--hidden');
    tset(() => startOverlay?.remove(), 700);
    startBgm();

    if (skip) revealMenu();
    else runIntro();

    iset(updateCaption, 5200);
  }

  function setActive(index) {
    if (!menuItems.length) return;
    activeIndex = (index + menuItems.length) % menuItems.length;
    menuItems.forEach((item, i) =>
      item.classList.toggle('menu-item--active', i === activeIndex),
    );
  }

  function actionOf(item) {
    return item?.dataset?.action || '';
  }

  function handleAction(action) {
    if (!action || actionLocked) return;

    actionLocked = true;
    tset(() => {
      actionLocked = false;
    }, 700);

    playTick();
    frameCut('hard');

    const activeAnchor = document.querySelector(
      `.menu-item[data-action="${CSS.escape(action)}"] a[href]`,
    );
    if (activeAnchor) {
      tset(() => {
        window.location.href = activeAnchor.getAttribute('href');
      }, 130);
      return;
    }

    // Same bridge-friendly behavior as the previous variants: log when BYOND wires it.
    console.log('[SisterRay] Menu action:', action);
  }

  function setupMenu() {
    menuItems.forEach((item, index) => {
      const label = item.querySelector('.menu-label');
      if (label && !label.dataset.label)
        label.dataset.label = label.textContent.trim();
      if (!item.dataset.label && label?.dataset.label)
        item.dataset.label = label.dataset.label;

      on(item, 'mouseenter', () => {
        setActive(index);
      });

      on(item, 'mousemove', (event) => {
        const rect = item.getBoundingClientRect();
        const x = ((event.clientX - rect.left) / Math.max(1, rect.width)) * 100;
        const y = ((event.clientY - rect.top) / Math.max(1, rect.height)) * 100;
        item.style.setProperty('--sr-hover-x', `${x}%`);
        item.style.setProperty('--sr-hover-y', `${y}%`);
      });

      on(item, 'click', (event) => {
        const target = event?.target;
        if (target?.closest?.('a[href]')) {
          event.preventDefault();
          event.stopPropagation();
        }
        handleAction(actionOf(item));
      });
    });

    setActive(activeIndex);
  }

  function setupKeys() {
    on(document, 'keydown', (event) => {
      if (!started || !menuItems.length) return;
      if (event.key === 'ArrowDown' || event.key === 'ArrowRight') {
        event.preventDefault();
        setActive(activeIndex + 1);
      } else if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') {
        event.preventDefault();
        setActive(activeIndex - 1);
      } else if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        handleAction(actionOf(menuItems[activeIndex]));
      } else if (event.key === 'Escape') {
        revealMenu();
      }
    });
  }

  function setupStart() {
    on(startButton, 'click', () => {
      playTick();
      start(!!skipIntro?.checked);
    });
    on(document, 'keydown', (event) => {
      if (started) return;
      if (event.key === 'Enter') {
        playTick();
        start(!!skipIntro?.checked);
      }
    });
  }

  function teardown() {
    timers.forEach(clearTimeout);
    intervals.forEach(clearInterval);
    listeners.forEach(([target, type, handler, options]) =>
      target.removeEventListener(type, handler, options),
    );
    glCleanups.forEach((cleanup) => cleanup());
    glCleanups.length = 0;
    q('.sr-stage')?.remove();
    document.body.classList.remove(
      'sr-cut',
      'menu-chrome-ready',
      'sr-webgl-ready',
    );
    menuWrapper?.classList.remove('sr-cut');
    if (bgm) {
      try {
        bgm.pause();
      } catch {}
    }
  }

  window.__menuChapterTeardown = teardown;

  document.body.dataset.chapter = 'sisterRay';
  createStage();
  setupMenu();
  setupKeys();
  setupStart();

  // Useful for direct file preview without clicking through the disclaimer every time.
  if (new URLSearchParams(window.location.search).has('autostart')) {
    tset(() => start(true), 80);
  }
})();
