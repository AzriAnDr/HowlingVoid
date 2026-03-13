import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import {
  GamePreferencesSelectedPage,
  type PreferencesMenuData,
} from '../types';
import { usePreferencesLocalization } from '../localization';
import { GamePreferencesPage } from './GamePreferencesPage';
import { KeybindingsPage } from './KeybindingsPage';

type Props = {
  startingPage?: GamePreferencesSelectedPage;
};

export function GamePreferenceWindow(props: Props) {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  const [currentPage, setCurrentPage] = useState(
    props.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  let pageContents;

  switch (currentPage) {
    case GamePreferencesSelectedPage.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case GamePreferencesSelectedPage.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  const topTabBaseStyle = {
    border: '1px solid hsla(210, 20%, 40%, 0.68)',
    borderRadius: '7px',
    background:
      'linear-gradient(180deg, hsla(218, 20%, 30%, 0.92) 0%, hsla(221, 23%, 20%, 0.97) 100%)',
    color: 'hsla(210, 18%, 92%, 0.96)',
    boxShadow:
      'inset 0 1px 0 hsla(0, 0%, 100%, 0.09), inset 0 -1px 0 hsla(0, 0%, 0%, 0.15)',
  } as const;

  const topTabSelectedStyle = {
    border: '1px solid hsla(39, 58%, 61%, 0.75)',
    borderRadius: '7px',
    background:
      'linear-gradient(180deg, hsla(38, 46%, 27%, 0.92) 0%, hsla(33, 44%, 14%, 0.97) 100%)',
    color: 'hsla(40, 92%, 87%, 0.97)',
    boxShadow:
      'inset 0 1px 0 hsla(42, 45%, 84%, 0.16), 0 0 10px hsla(38, 60%, 45%, 0.2)',
  } as const;

  return (
    <Stack vertical fill>
      <Stack.Item className="PreferencesMenu__GameTopTabsContainer">
        <Stack fill className="PreferencesMenu__GameTopTabs">
          <Stack.Item grow>
            <Button
              className="PreferencesMenu__GameTopTabs__Button"
              align="center"
              fontSize="1.2em"
              fluid
              selected={currentPage === GamePreferencesSelectedPage.Settings}
              style={
                currentPage === GamePreferencesSelectedPage.Settings
                  ? topTabSelectedStyle
                  : topTabBaseStyle
              }
              onClick={() => setCurrentPage(GamePreferencesSelectedPage.Settings)}
            >
              {t('ui.game.game_settings')}
            </Button>
          </Stack.Item>

          <Stack.Item grow>
            <Button
              className="PreferencesMenu__GameTopTabs__Button"
              align="center"
              fontSize="1.2em"
              fluid
              selected={currentPage === GamePreferencesSelectedPage.Keybindings}
              style={
                currentPage === GamePreferencesSelectedPage.Keybindings
                  ? topTabSelectedStyle
                  : topTabBaseStyle
              }
              onClick={() =>
                setCurrentPage(GamePreferencesSelectedPage.Keybindings)
              }
            >
              {t('ui.game.game_keybindings')}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Divider />

      <Stack.Item grow shrink basis="1px">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
}

