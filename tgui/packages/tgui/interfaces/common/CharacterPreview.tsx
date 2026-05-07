import {
  type KeyboardEvent,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
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
  width?: string;
  height: string;
  id?: string | null;
  animationMap?: Record<string, PreviewAnimationData | null> | null;
  imageUrl?: string | null;
  imageMap?: Record<string, string | null> | null;
  direction?: string | null;
  onClick?: (() => void) | null;
  title?: string;
}) => {
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
  const lastSettledPreviewRef = useRef<{
    animation: PreviewAnimationData | null;
    imageUrl: string | null;
  }>({
    animation: null,
    imageUrl: null,
  });
  const [settledPreview, setSettledPreview] = useState<{
    animation: PreviewAnimationData | null;
    imageUrl: string | null;
  }>({
    animation: null,
    imageUrl: null,
  });
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

  const selectedDirectionImageUrl =
    (normalizedDirection && imageMap?.[normalizedDirection]) ||
    (direction && imageMap?.[direction]) ||
    null;

  const selectedDirectionAnimation =
    (normalizedDirection && animationMap?.[normalizedDirection]) ||
    (direction && animationMap?.[direction]) ||
    null;

  const shouldDeferDirectionSwap = Boolean(
    selectedDirectionImageUrl && animationMap && !selectedDirectionAnimation,
  );

  const candidateImageUrl = shouldDeferDirectionSwap
    ? lastSettledPreviewRef.current.imageUrl
    : resolvedImageUrl;

  const candidateAnimation = shouldDeferDirectionSwap
    ? lastSettledPreviewRef.current.animation
    : resolvedAnimation;

  useEffect(() => {
    if (!candidateImageUrl) {
      if (!lastSettledPreviewRef.current.imageUrl) {
        setSettledPreview({
          animation: null,
          imageUrl: null,
        });
      }
      return;
    }

    if (lastSettledPreviewRef.current.imageUrl === candidateImageUrl) {
      setSettledPreview(lastSettledPreviewRef.current);
      return;
    }

    let cancelled = false;
    const previewImage = new Image();

    const settlePreview = () => {
      if (cancelled) {
        return;
      }

      const nextSettledPreview = {
        animation: candidateAnimation,
        imageUrl: candidateImageUrl,
      };

      lastSettledPreviewRef.current = nextSettledPreview;
      setSettledPreview(nextSettledPreview);
    };

    previewImage.addEventListener('load', settlePreview);
    previewImage.src = candidateImageUrl;

    if (previewImage.complete && previewImage.naturalWidth > 0) {
      settlePreview();
    } else if (
      !lastSettledPreviewRef.current.imageUrl &&
      typeof previewImage.decode === 'function'
    ) {
      void previewImage
        .decode()
        .then(settlePreview)
        .catch(() => undefined);
    }

    return () => {
      cancelled = true;
      previewImage.removeEventListener('load', settlePreview);
    };
  }, [candidateAnimation, candidateImageUrl]);

  const renderedImageUrl = settledPreview.imageUrl;
  const renderedAnimation = settledPreview.animation;

  const animationSignature = useMemo(
    () => JSON.stringify(renderedAnimation),
    [renderedAnimation],
  );

  const animationAspectRatio = useMemo(() => {
    const frameCount = Math.max(Number(renderedAnimation?.frames) || 1, 1);
    const width = Math.max(
      Number(renderedAnimation?.width)
        ? Number(renderedAnimation?.width)
        : Number(resolvedImageDimensions?.width)
          ? Number(resolvedImageDimensions?.width) / frameCount
          : 1,
      1,
    );
    const height = Math.max(
      Number(renderedAnimation?.height) ||
        Number(resolvedImageDimensions?.height) ||
        1,
      1,
    );

    return `${width} / ${height}`;
  }, [renderedAnimation, resolvedImageDimensions]);

  const animationViewportStyle = useMemo(() => {
    const frameCount = Math.max(Number(renderedAnimation?.frames) || 1, 1);
    const frameWidth = Math.max(
      Number(renderedAnimation?.width)
        ? Number(renderedAnimation?.width)
        : Number(resolvedImageDimensions?.width)
          ? Number(resolvedImageDimensions?.width) / frameCount
          : 1,
      1,
    );
    const frameHeight = Math.max(
      Number(renderedAnimation?.height) ||
        Number(resolvedImageDimensions?.height) ||
        1,
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
  }, [renderedAnimation, resolvedImageDimensions]);

  useEffect(() => {
    if (!renderedImageUrl) {
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
    previewImage.src = renderedImageUrl;

    if (previewImage.complete) {
      updateDimensions();
    }

    return () => {
      cancelled = true;
      previewImage.removeEventListener('load', updateDimensions);
    };
  }, [renderedImageUrl]);

  useEffect(() => {
    const urlsToPreload = new Set<string>();

    if (resolvedImageUrl) {
      urlsToPreload.add(resolvedImageUrl);
    }

    if (renderedImageUrl) {
      urlsToPreload.add(renderedImageUrl);
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
  }, [imageMap, renderedImageUrl, resolvedImageUrl]);

  useEffect(() => {
    setCurrentFrame(0);

    if (
      !renderedAnimation ||
      !renderedImageUrl ||
      renderedAnimation.frames <= 1
    ) {
      return;
    }

    const frameCount = renderedAnimation.frames;
    const delays = renderedAnimation.delays?.length
      ? renderedAnimation.delays
      : Array.from({ length: frameCount }, () => 1);
    const frameSequence =
      renderedAnimation.rewind && frameCount > 1
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
        Number(delays[currentSequenceFrame] ?? delays[delays.length - 1] ?? 1) *
          100,
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
  }, [animationSignature, renderedImageUrl]);

  useEffect(() => {
    if (!id || renderedImageUrl) {
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
  }, [id, renderedImageUrl]);

  const interactive = !!onClick;

  const handleKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    if (!interactive || !onClick) {
      return;
    }

    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      onClick();
    }
  };

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
        backgroundColor: renderedImageUrl ? 'black' : undefined,
        cursor: interactive ? 'zoom-in' : undefined,
      }}
    >
      {renderedImageUrl ? (
        renderedAnimation && renderedAnimation.frames > 1 ? (
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
                src={renderedImageUrl}
                style={{
                  position: 'absolute',
                  inset: 0,
                  width: `${renderedAnimation.frames * 100}%`,
                  height: '100%',
                  display: 'block',
                  imageRendering: 'pixelated',
                  transform: `translateX(-${currentFrame * (100 / renderedAnimation.frames)}%)`,
                }}
              />
            </div>
          </div>
        ) : (
          <img
            alt=""
            src={renderedImageUrl}
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
          width="100%"
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
