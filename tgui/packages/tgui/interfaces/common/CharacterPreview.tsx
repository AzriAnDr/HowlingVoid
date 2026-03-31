import { useEffect, useRef } from 'react';
import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string; // NOVA EDIT
  height: string;
  id: string;
}) => {
  // NOVA EDIT
  const { width = '272px' } = props;
  const wrapperRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
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
  }, [props.id, width, props.height]);
  // NOVA EDIT END
  return (
    <div ref={wrapperRef} style={{ width, height: props.height }}>
      <ByondUi
        width="100%" // NOVA EDIT
        height="100%"
        params={{
          id: props.id,
          type: 'map',
        }}
      />
    </div>
  );
};
