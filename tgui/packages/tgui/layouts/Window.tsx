/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  type ComponentProps,
  type PropsWithChildren,
  type ReactNode,
  useEffect,
  useLayoutEffect,
  useState,
} from 'react';
import { type Box, Button, Dropdown } from 'tgui-core/components';
import { UI_DISABLED, UI_INTERACTIVE } from 'tgui-core/constants';
import { type BooleanLike, classes } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';
import { useBackend } from '../backend';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
  setWindowPosition,
  storeWindowGeometry,
} from '../drag';
import { suspendStart } from '../events/handlers/suspense';
import { createLogger } from '../logging';
import { Layout } from './Layout';
import { TitleBar } from './TitleBar';

const logger = createLogger('Window');
const DEFAULT_SIZE: [number, number] = [400, 600];

type Props = Partial<{
  buttons: ReactNode;
  canClose: BooleanLike;
  height: number;
  theme: string;
  title: string;
  width: number;
}> &
  PropsWithChildren;

export function Window(props: Props) {
  const {
    canClose = true,
    theme,
    title,
    children,
    buttons,
    width,
    height,
  } = props;

  const { act, config, suspended, debug } = useBackend();

  const [isReadyToRender, setIsReadyToRender] = useState(false);
  const [optimisticTheme, setOptimisticTheme] = useState<string | undefined>();
  const [optimisticBackdrop, setOptimisticBackdrop] = useState<
    string | undefined
  >();
  const isStorytellerPanel = config.interface?.name === 'StorytellerPanel';
  const allowAdminAppearanceOverride =
    theme === 'admin' && !isStorytellerPanel;
  const useClientAppearance = !theme || allowAdminAppearanceOverride;
  const currentConfigTheme = config.window?.theme || 'nanotrasen';
  const currentConfigBackdrop = config.window?.backdrop || 'nanotrasen';
  const resolvedTheme = useClientAppearance
    ? optimisticTheme || currentConfigTheme || 'nanotrasen'
    : theme || currentConfigTheme || 'nanotrasen';
  const resolvedBackdrop = useClientAppearance
    ? optimisticBackdrop || currentConfigBackdrop || 'nanotrasen'
    : undefined;
  const showAppearanceControls = useClientAppearance;

  useEffect(() => {
    setOptimisticTheme(undefined);
  }, [currentConfigTheme]);

  useEffect(() => {
    setOptimisticBackdrop(undefined);
  }, [currentConfigBackdrop]);

  // We need to set the window to be invisible before we can set its geometry
  // Otherwise, we get a flicker effect when the window is first rendered
  useLayoutEffect(() => {
    Byond.winset(Byond.windowId, {
      'is-visible': false,
    });
    setIsReadyToRender(true);
  }, []);

  const { scale } = config?.window || false;

  useEffect(() => {
    if (!suspended && isReadyToRender) {
      const updateGeometry = () => {
        const options = {
          ...config.window,
          size: DEFAULT_SIZE,
        };

        if (width && height) {
          options.size = [width, height];
        }
        if (config.window?.key) {
          setWindowKey(config.window.key);
        }
        recallWindowGeometry(options);
        Byond.winset(Byond.windowId, {
          'is-visible': true,
        });
        logger.log('set to visible');
      };

      Byond.winset(Byond.windowId, {
        'can-close': Boolean(canClose),
      });
      logger.log('mounting');
      updateGeometry();
    }
    return () => {
      logger.log('unmounting');
    };
  }, [isReadyToRender, width, height, scale]);

  // Determine when to show dimmer
  const showDimmer =
    config.user &&
    (config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE);

  return suspended ? null : (
    <Layout
      className="Window"
      theme={resolvedTheme}
      backdrop={resolvedBackdrop}
    >
      <TitleBar
        title={title || decodeHtmlEntities(config.title)}
        status={config.status}
        onDragStart={dragStartHandler}
        onClose={suspendStart}
        canClose={canClose}
      >
        {showAppearanceControls && (
          <WindowAppearanceControls
            interfaceLanguage={config.client?.interface_language}
            theme={resolvedTheme}
            themeOptions={config.window?.theme_options}
            themeDisplayNames={config.window?.theme_display_names}
            backdrop={resolvedBackdrop || 'nanotrasen'}
            backdropOptions={config.window?.backdrop_options}
            backdropDisplayNames={config.window?.backdrop_display_names}
            onThemeSelected={(value) => {
              setOptimisticTheme(value);
              act('__tgui_set_theme', {
                theme: value,
              });
            }}
            onBackdropSelected={(value) => {
              setOptimisticBackdrop(value);
              act('__tgui_set_backdrop', {
                backdrop: value,
              });
            }}
          />
        )}
        {buttons}
      </TitleBar>
      <div
        className={classes([
          'Window__rest',
          debug.debugLayout && 'debug-layout',
        ])}
      >
        {!suspended && children}
        {showDimmer && <div className="Window__dimmer" />}
      </div>
      <div
        className="Window__resizeHandle__e"
        onMouseDown={resizeStartHandler(1, 0) as any}
      />
      <div
        className="Window__resizeHandle__s"
        onMouseDown={resizeStartHandler(0, 1) as any}
      />
      <div
        className="Window__resizeHandle__se"
        onMouseDown={resizeStartHandler(1, 1) as any}
      />
      <div
        className="Window__resizeHandle__sw"
        onMouseDown={resizeStartHandler(-1, 1) as any}
      />
    </Layout>
  );
}

type ContentProps = Partial<{
  className: string;
  fitted: boolean;
  scrollable: boolean;
  vertical: boolean;
}> &
  ComponentProps<typeof Box> &
  PropsWithChildren;

function WindowContent(props: ContentProps) {
  const { className, fitted, children, ...rest } = props;

  Byond.subscribeTo('resetposition', () => {
    setWindowPosition([0, 0]);
    storeWindowGeometry();
  });

  return (
    <Layout.Content className={classes(['Window__content', className])} {...rest}>
      {fitted ? (
        children
      ) : (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
}

Window.Content = WindowContent;

type AppearanceControlStrings = {
  appearance: string;
  backdrop: string;
  close: string;
  theme: string;
};

type AppearanceOption = {
  displayText: string;
  value: string;
};

type WindowAppearanceControlsProps = {
  backdrop: string;
  backdropDisplayNames?: Record<string, string>;
  backdropOptions?: string[];
  interfaceLanguage?: string;
  onBackdropSelected: (value: string) => void;
  onThemeSelected: (value: string) => void;
  theme: string;
  themeDisplayNames?: Record<string, string>;
  themeOptions?: string[];
};

function getAppearanceStrings(
  interfaceLanguage?: string,
): AppearanceControlStrings {
  if (interfaceLanguage === 'russian') {
    return {
      appearance:
        '\u041e\u0444\u043e\u0440\u043c\u043b\u0435\u043d\u0438\u0435 \u043e\u043a\u043d\u0430',
      backdrop: '\u0424\u043e\u043d',
      close: '\u0417\u0430\u043a\u0440\u044b\u0442\u044c',
      theme: '\u0422\u0435\u043c\u0430',
    };
  }

  return {
    appearance: 'Window appearance',
    backdrop: 'Backdrop',
    close: 'Close',
    theme: 'Theme',
  };
}

function formatAppearanceLabel(value: string): string {
  return value
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function buildAppearanceOptions(
  options: string[] | undefined,
  displayNames: Record<string, string> | undefined,
  fallbackValue: string,
): AppearanceOption[] {
  const optionValues = options?.length
    ? options
    : Object.keys(displayNames || {});
  const values = optionValues.length ? optionValues : [fallbackValue];

  return values.map((value) => ({
    displayText: displayNames?.[value] || formatAppearanceLabel(value),
    value,
  }));
}

function WindowAppearanceControls(props: WindowAppearanceControlsProps) {
  const {
    backdrop,
    backdropDisplayNames,
    backdropOptions,
    interfaceLanguage,
    onBackdropSelected,
    onThemeSelected,
    theme,
    themeDisplayNames,
    themeOptions,
  } = props;
  const [isOpen, setIsOpen] = useState(false);
  const strings = getAppearanceStrings(interfaceLanguage);
  const resolvedTheme = theme || 'nanotrasen';
  const resolvedBackdrop = backdrop || 'nanotrasen';
  const themeDropdownOptions = buildAppearanceOptions(
    themeOptions,
    themeDisplayNames,
    resolvedTheme,
  );
  const backdropDropdownOptions = buildAppearanceOptions(
    backdropOptions,
    backdropDisplayNames,
    resolvedBackdrop,
  );

  return (
    <div
      className="TitleBar__appearance"
      onMouseDown={(event) => event.stopPropagation()}
    >
      <Button
        className={classes([
          'TitleBar__appearanceTrigger',
          isOpen && 'TitleBar__appearanceTrigger--active',
        ])}
        color="transparent"
        icon="palette"
        tooltip={strings.appearance}
        tooltipPosition="bottom"
        onClick={() => setIsOpen((open) => !open)}
      />
      {isOpen && (
        <div className="TitleBar__appearanceMenu">
          <div className="TitleBar__appearanceMenuHeader">
            <span>{strings.appearance}</span>
            <Button
              className="TitleBar__appearanceMenuClose"
              color="transparent"
              icon="times"
              tooltip={strings.close}
              tooltipPosition="left"
              onClick={() => setIsOpen(false)}
            />
          </div>
          <div className="TitleBar__appearanceField">
            <div className="TitleBar__appearanceLabel">{strings.theme}</div>
            <Dropdown
              menuWidth="100%"
              onSelected={(value) => onThemeSelected(String(value))}
              options={themeDropdownOptions}
              selected={resolvedTheme}
              width="100%"
            />
          </div>
          <div className="TitleBar__appearanceField">
            <div className="TitleBar__appearanceLabel">{strings.backdrop}</div>
            <Dropdown
              menuWidth="100%"
              onSelected={(value) => onBackdropSelected(String(value))}
              options={backdropDropdownOptions}
              selected={resolvedBackdrop}
              width="100%"
            />
          </div>
        </div>
      )}
    </div>
  );
}
