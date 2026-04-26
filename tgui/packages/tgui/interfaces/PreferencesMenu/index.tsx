import { Suspense, useEffect, useState } from 'react';
import { exhaustiveCheck } from 'tgui-core/exhaustive';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { LoadingScreen } from '../common/LoadingScreen';
import { CharacterPreferenceWindow } from './CharacterPreferences';
import { GamePreferenceWindow } from './GamePreferences';
import { usePreferencesLocalization } from './localization';
import {
  GamePreferencesSelectedPage,
  type PreferencesMenuData,
  PrefsWindow,
  type ServerData,
} from './types';
import { RandomToggleState } from './useRandomToggleState';
import { ServerPrefs } from './useServerPrefs';

export function PreferencesMenu(props) {
  return (
    <Suspense
      fallback={
        <Window width={1080} height={920}>
          <Window.Content>
            <LoadingScreen />
          </Window.Content>
        </Window>
      }
    >
      <PrefsWindowInner />
    </Suspense>
  );
}

/** We're abstracting this by one level to use Suspense */
function PrefsWindowInner(props) {
  const { data } = useBackend<PreferencesMenuData>();
  const { window } = data;
  const { t } = usePreferencesLocalization(data);

  const [serverData, setServerData] = useState<ServerData>();
  const randomization = useState(false);

  useEffect(() => {
    fetchRetry(resolveAsset('preferences.json'))
      .then((response) => response.json())
      .then((data) => {
        setServerData(data);
      })
      .catch((error) => {
        logger.log('Failed to fetch preferences.json', error);
      });
  }, []);

  let content;
  let title;
  switch (window) {
    case PrefsWindow.Character:
      content = <CharacterPreferenceWindow />;
      title = t('ui.character.window_character_preferences');
      break;
    case PrefsWindow.Game:
      content = <GamePreferenceWindow />;
      title = t('ui.character.window_game_preferences');
      break;
    case PrefsWindow.Keybindings:
      content = (
        <GamePreferenceWindow
          startingPage={GamePreferencesSelectedPage.Keybindings}
        />
      );
      title = t('ui.character.window_keybindings');
      break;
    default:
      exhaustiveCheck(window);
  }

  return (
    <Window width={1080} height={920} title={title}>
      <Window.Content>
        <ServerPrefs.Provider value={serverData}>
          <RandomToggleState.Provider value={randomization}>
            {content}
          </RandomToggleState.Provider>
        </ServerPrefs.Provider>
      </Window.Content>
    </Window>
  );
}
