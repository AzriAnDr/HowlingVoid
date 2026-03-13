// THIS IS A NOVA SECTOR UI FILE
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Flex,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NifSoulPoem = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    name_to_send,
    text_to_send,
    messages = [],
    receiving_data,
    transmitting_data,
    theme,
  } = data;
  return (
    <Window width={500} height={700} theme={theme}>
      <Window.Content scrollable>
        <Section title={t('ui.nif_soul_poem.messages')}>
          {messages.map((message) => (
            <Flex.Item key={message.key}>
              <Box textAlign="center" fontSize="14px">
                <b>{message.sender_name} </b>
                <Button
                  icon="trash"
                  tooltip={t('ui.nif_soul_poem.delete_this_message')}
                  onClick={() =>
                    act('remove_message', { message_to_remove: message })
                  }
                />
              </Box>
              <Divider />
              <Box>{message.message}</Box>
              <br />
              <BlockQuote>
                {t('ui.nif_soul_poem.time_received')}: {message.timestamp}
              </BlockQuote>
            </Flex.Item>
          ))}
        </Section>
        <Section title={t('ui.common.settings')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.nif_soul_poem.display_name')}>
              <Input
                value={name_to_send}
                onChange={(value) => act('change_name', { new_name: value })}
                width="100%"
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.message')}>
              <Input
                value={text_to_send}
                onChange={(value) =>
                  act('change_message', { new_message: value })
                }
                width="100%"
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.nif_soul_poem.toggle_transmitting')}>
              <Button
                fluid
                onClick={() => act('toggle_transmitting', {})}
                color={transmitting_data ? 'green' : 'red'}
              >
                {transmitting_data ? t('ui.common.true') : t('ui.common.false')}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.nif_soul_poem.toggle_receiving')}>
              <Button
                fluid
                onClick={() => act('toggle_receiving', {})}
                color={receiving_data ? 'green' : 'red'}
              >
                {receiving_data ? t('ui.common.true') : t('ui.common.false')}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
