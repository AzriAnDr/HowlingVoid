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
