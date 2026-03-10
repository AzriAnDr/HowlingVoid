import { useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Modal, Stack } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

type Props = {
  close: () => void;
};

export function DeleteCharacterPopup(props: Props) {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const [secondsLeft, setSecondsLeft] = useState(3);

  const { close } = props;

  useEffect(() => {
    const interval = setInterval(() => {
      setSecondsLeft((current) => current - 1);
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <Modal className="PreferencesMenu__Character__DeletePopup">
      <Stack vertical textAlign="center" align="center">
        <Stack.Item>
          <Box fontSize="3em">{t('ui.character.delete_popup.wait')}</Box>
        </Stack.Item>

        <Stack.Item maxWidth="300px">
          <Box>
            {t('ui.character.delete_popup.confirm_text').replace(
              '{name}',
              data.character_preferences.names[data.name_to_use],
            )}
          </Box>
        </Stack.Item>

        <Stack.Item>
          <Stack fill>
            <Stack.Item>
              {/* Explicit width so that the layout doesn't shift */}
              <Button
                color="danger"
                disabled={secondsLeft > 0}
                width="80px"
                onClick={() => {
                  act('remove_current_slot');
                  close();
                }}
              >
                {secondsLeft <= 0
                  ? t('ui.character.delete_popup.delete')
                  : `${t('ui.character.delete_popup.delete')} (${secondsLeft})`}
              </Button>
            </Stack.Item>

            <Stack.Item>
              <Button onClick={close}>{t('ui.character.delete_popup.no_delete')}</Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
