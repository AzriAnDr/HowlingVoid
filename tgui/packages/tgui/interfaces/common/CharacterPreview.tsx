import { useEffect, useRef } from 'react';
import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string | null;
}) => {
  const { width = '272px' } = props;
  const wrapperRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!props.id) {
      return;
    }

    let timeoutId: ReturnType<typeof setTimeout> | undefined;
    let rafId: number | undefined;
    let resizeObserver: ResizeObserver | undefined;

    const notifyResize = () => {
      window.dispatchEvent(new Event('resize'));
    };

    rafId = requestAnimationFrame(() => {
      requestAnimationFrame(notifyResize);
    });
    timeoutId = setTimeout(notifyResize, 150);

    if (wrapperRef.current && 'ResizeObserver' in window) {
      resizeObserver = new ResizeObserver(notifyResize);
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
  }, [props.id]);

  return (
    <div
      ref={wrapperRef}
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
      }}
    >
      {props.id ? (
        <ByondUi
          width="100%"
          height="100%"
          params={{
            id: props.id,
            type: 'map',
          }}
        />
      ) : null}
    </div>
  );
};
