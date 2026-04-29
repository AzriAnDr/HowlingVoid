import { type KeyboardEvent, useEffect, useMemo, useRef, useState } from 'react';
import { ByondUi } from 'tgui-core/components';

type PreviewAnimationData = {
  delays?: number[] | null;
  frames: number;
  height: number;
  rewind?: unknown;
  width: number;
};

const preloadedPreviewUrls = new Set<string>();

function normalizePreviewDirection(direction?: string | null) {
  return direction?.toLowerCase() || null;
}

function preloadPreviewUrl(url: string) {
  if (!url || preloadedPreviewUrls.has(url)) {
    return;
  }

  preloadedPreviewUrls.add(url);

  const preloadedImage = new Image();
  preloadedImage.src = url;

  if (typeof preloadedImage.decode === 'function') {
    void preloadedImage.decode().catch(() => undefined);
  }
}

export const CharacterPreview = (props: {
  width?: string; // NOVA EDIT
  height: string;
  id?: string | null;
  animationMap?: Record<string, PreviewAnimationData | null> | null;
  imageUrl?: string | null;
  imageMap?: Record<string, string | null> | null;
  direction?: string | null;
  onClick?: (() => void) | null;
  title?: string;
}) => {
  // NOVA EDIT
  const {
    animationMap,
    width = '272px',
    direction,
    id,
    imageMap,
    imageUrl,
    onClick,
    title,
  } = props;
  const wrapperRef = useRef<HTMLDivElement | null>(null);
  const [currentFrame, setCurrentFrame] = useState(0);
  const [resolvedImageDimensions, setResolvedImageDimensions] = useState<{
    width: number;
    height: number;
  } | null>(null);
  const normalizedDirection = useMemo(
    () => normalizePreviewDirection(direction),
    [direction],
  );
  const resolvedImageUrl = useMemo(() => {
    if (normalizedDirection && imageMap?.[normalizedDirection]) {
      return imageMap[normalizedDirection];
    }

    if (direction && imageMap?.[direction]) {
      return imageMap[direction];
    }

    return imageUrl;
  }, [direction, imageMap, imageUrl, normalizedDirection]);
  const resolvedAnimation = useMemo(() => {
    if (normalizedDirection && animationMap?.[normalizedDirection]) {
      return animationMap[normalizedDirection];
    }

    if (direction && animationMap?.[direction]) {
      return animationMap[direction];
    }

    return null;
  }, [animationMap, direction, normalizedDirection]);
  const animationSignature = useMemo(
    () => JSON.stringify(resolvedAnimation),
    [resolvedAnimation],
  );
  const animationAspectRatio = useMemo(() => {
    const frameCount = Math.max(Number(resolvedAnimation?.frames) || 1, 1);
    const width = Math.max(
      Number(resolvedAnimation?.width)
        ? Number(resolvedAnimation?.width)
        : Number(resolvedImageDimensions?.width)
          ? Number(resolvedImageDimensions?.width) / frameCount
          : 1,
      1,
    );
    const height = Math.max(
      Number(resolvedAnimation?.height) || Number(resolvedImageDimensions?.height) || 1,
      1,
    );

    return `${width} / ${height}`;
  }, [resolvedAnimation, resolvedImageDimensions]);
  const animationViewportStyle = useMemo(() => {
    const frameCount = Math.max(Number(resolvedAnimation?.frames) || 1, 1);
    const frameWidth = Math.max(
      Number(resolvedAnimation?.width)
        ? Number(resolvedAnimation?.width)
        : Number(resolvedImageDimensions?.width)
          ? Number(resolvedImageDimensions?.width) / frameCount
          : 1,
      1,
    );
    const frameHeight = Math.max(
      Number(resolvedAnimation?.height) || Number(resolvedImageDimensions?.height) || 1,
      1,
    );
    const frameRatio = Math.max(frameWidth / frameHeight, 1 / 1024);

    if (frameRatio >= 1) {
      return {
        width: '100%',
        height: `${Math.min(100 / frameRatio, 100)}%`,
      };
    }

    return {
      width: `${Math.min(frameRatio * 100, 100)}%`,
      height: '100%',
    };
  }, [resolvedAnimation, resolvedImageDimensions]);

  useEffect(() => {
    if (!resolvedImageUrl) {
      setResolvedImageDimensions(null);
      return;
    }

    let cancelled = false;
    const previewImage = new Image();

    const updateDimensions = () => {
      if (cancelled) {
        return;
      }

      const naturalWidth = Number(previewImage.naturalWidth) || 0;
      const naturalHeight = Number(previewImage.naturalHeight) || 0;

      if (!naturalWidth || !naturalHeight) {
        setResolvedImageDimensions(null);
        return;
      }

      setResolvedImageDimensions({
        width: naturalWidth,
        height: naturalHeight,
      });
    };

    previewImage.addEventListener('load', updateDimensions);
    previewImage.src = resolvedImageUrl;

    if (previewImage.complete) {
      updateDimensions();
    }

    return () => {
      cancelled = true;
      previewImage.removeEventListener('load', updateDimensions);
    };
  }, [resolvedImageUrl]);

  useEffect(() => {
    const urlsToPreload = new Set<string>();

    if (resolvedImageUrl) {
      urlsToPreload.add(resolvedImageUrl);
    }

    if (imageMap) {
      for (const url of Object.values(imageMap)) {
        if (!url) {
          continue;
        }

        urlsToPreload.add(url);
      }
    }

    for (const url of urlsToPreload) {
      preloadPreviewUrl(url);
    }
  }, [imageMap, resolvedImageUrl]);

  useEffect(() => {
    setCurrentFrame(0);

    if (!resolvedAnimation || !resolvedImageUrl || resolvedAnimation.frames <= 1) {
      return;
    }

    const frameCount = resolvedAnimation.frames;
    const delays = resolvedAnimation.delays?.length
      ? resolvedAnimation.delays
      : Array.from({ length: frameCount }, () => 1);
    const frameSequence = resolvedAnimation.rewind && frameCount > 1
      ? [
          ...Array.from({ length: frameCount }, (_, index) => index),
          ...Array.from(
            { length: frameCount - 2 },
            (_, index) => frameCount - index - 2,
          ),
        ]
      : Array.from({ length: frameCount }, (_, index) => index);

    let sequenceIndex = 0;
    let timeoutId: ReturnType<typeof setTimeout> | undefined;

    const scheduleFrame = () => {
      const currentSequenceFrame = frameSequence[sequenceIndex];
      const delay = Math.max(
        50,
        Number(delays[currentSequenceFrame] ?? delays[delays.length - 1] ?? 1) * 100,
      );

      timeoutId = setTimeout(() => {
        sequenceIndex = (sequenceIndex + 1) % frameSequence.length;
        setCurrentFrame(frameSequence[sequenceIndex]);
        scheduleFrame();
      }, delay);
    };

    scheduleFrame();

    return () => {
      if (timeoutId !== undefined) {
        clearTimeout(timeoutId);
      }
    };
  }, [animationSignature, resolvedImageUrl]);

  useEffect(() => {
    if (!id || resolvedImageUrl) {
      return;
    }

    let timeoutId: ReturnType<typeof setTimeout> | undefined;
    let rafId: number | undefined;
    let resizeObserver: ResizeObserver | undefined;

    const notifyResize = () => {
      window.dispatchEvent(new Event('resize'));
    };

    // ByondUi measures itself on mount, but PreferencesMenu layout can
    // still be settling for a frame or two when we switch tabs/windows.
    rafId = requestAnimationFrame(() => {
      requestAnimationFrame(notifyResize);
    });
    timeoutId = setTimeout(notifyResize, 150);

    if (wrapperRef.current && 'ResizeObserver' in window) {
      resizeObserver = new ResizeObserver(() => {
        notifyResize();
      });
      resizeObserver.observe(wrapperRef.current);
    }

    return () => {
      if (rafId !== undefined) {
        cancelAnimationFrame(rafId);
      }
      if (timeoutId !== undefined) {
        clearTimeout(timeoutId);
      }
      resizeObserver?.disconnect();
    };
  }, [props.height, id, resolvedImageUrl, width]);

  const interactive = !!onClick;

  const handleKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    if (!onClick) {
      return;
    }

    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      onClick();
    }
  };
  // NOVA EDIT END
  return (
    <div
      ref={wrapperRef}
      onClick={onClick || undefined}
      onKeyDown={handleKeyDown}
      role={interactive ? 'button' : undefined}
      tabIndex={interactive ? 0 : undefined}
      title={title}
      style={{
        width,
        height: props.height,
        maxWidth: '100%',
        minWidth: 0,
        minHeight: 0,
        boxSizing: 'border-box',
        overflow: 'hidden',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: resolvedImageUrl ? 'black' : undefined,
        cursor: interactive ? 'zoom-in' : undefined,
      }}
    >
      {resolvedImageUrl ? (
        resolvedAnimation && resolvedAnimation.frames > 1 ? (
          <div
            style={{
              width: '100%',
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                ...animationViewportStyle,
                position: 'relative',
                maxWidth: '100%',
                maxHeight: '100%',
                minWidth: 0,
                minHeight: 0,
                flex: '0 0 auto',
                aspectRatio: animationAspectRatio,
                overflow: 'hidden',
              }}
            >
              <img
                alt=""
                src={resolvedImageUrl}
                style={{
                  position: 'absolute',
                  inset: 0,
                  width: `${resolvedAnimation.frames * 100}%`,
                  height: '100%',
                  display: 'block',
                  imageRendering: 'pixelated',
                  transform: `translateX(-${currentFrame * (100 / resolvedAnimation.frames)}%)`,
                }}
              />
            </div>
          </div>
        ) : (
          <img
            alt=""
            src={resolvedImageUrl}
            style={{
              width: '100%',
              height: '100%',
              display: 'block',
              objectFit: 'contain',
              imageRendering: 'pixelated',
            }}
          />
        )
      ) : id ? (
        <ByondUi
          width="100%" // NOVA EDIT
          height="100%"
          params={{
            id,
            type: 'map',
          }}
        />
      ) : null}
    </div>
  );
};
