import { useState } from 'react';
import { Button, ByondUi, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  mmi_view: string;
};

export const LingMMITalk = (props) => {
  const { data, act } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [mmiMessage, setmmiMessage] = useState('');

  return (
    <Window
      title={t('ui.ling_mmi_talk.decoy_brain_mmi_view')}
      height={360}
      width={360}
    >
      <Window.Content>
        <Stack vertical>
          <Stack.Item align="center">
            <ByondUi
              width="240px"
              height="240px"
              params={{
                id: data.mmi_view,
                type: 'map',
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Stack width="100%">
              <Stack.Item width="85%">
                <TextArea
                  fluid
                  height="60px"
                  placeholder={t('ui.ling_mmi_talk.send_message_placeholder')}
                  onChange={setmmiMessage}
                  value={mmiMessage}
                />
              </Stack.Item>
              <Stack.Item align="center">
                <Button
                  textAlign="center"
                  onClick={() => {
                    act('send_mmi_message', { message: mmiMessage });
                    setmmiMessage('');
                  }}
                >
                  Send
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
