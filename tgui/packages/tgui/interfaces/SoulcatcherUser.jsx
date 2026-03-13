// THIS IS A NOVA SECTOR UI FILE
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const SoulcatcherUser = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { current_room, user_data, communicate_as_parent, souls = [] } = data;

  return (
    <Window width={520} height={400} resizable>
      <Window.Content scrollable>
        <Section
          key={current_room.key}
          title={
            <span style={{ color: current_room.color }}>
              {current_room.name}
            </span>
          }
        >
          <BlockQuote preserveWhitespace>
            {' '}
            {current_room.description}
          </BlockQuote>
          <br />
          <Box textAlign="center" fontSize="15px" opacity={0.8}>
            <b>{user_data.name} </b>
            {!user_data.scan_needed && user_data.able_to_rename ? (
              <>
                <Button
                  color="green"
                  icon="pen"
                  tooltip={t('ui.soulcatcheruser.change_your_name')}
                  onClick={() => act('change_name', {})}
                />
                <Button
                  color="red"
                  icon="arrow-rotate-left"
                  tooltip={t('ui.soulcatcheruser.reset_your_name')}
                  onClick={() => act('reset_name', {})}
                />
              </>
            ) : (
              null
            )}
            {communicate_as_parent ? (
              <Button
                color={user_data.communicating_externally ? 'green' : 'red'}
                icon={
                  user_data.communicating_externally ? 'bullhorn' : 'microphone'
                }
                tooltip={t(
                  'ui.soulcatcheruser.toggle_sending_messages_as_part_of_the_soulcatcher',
                )}
                onClick={() => act('toggle_external_communication', {})}
              />
            ) : (
              null
            )}
          </Box>
          <Divider />
          <Collapsible title={t('ui.soulcatcheruser.flavor_text')}>
            <BlockQuote preserveWhitespace>{user_data.description}</BlockQuote>
          </Collapsible>
          <Collapsible title={t('ui.soulcatcheruser.ooc_notes')}>
            <BlockQuote preserveWhitespace>{user_data.ooc_notes}</BlockQuote>
          </Collapsible>
          <Collapsible title={t('ui.soulcatcheruser.soul_info')}>
            <LabeledList textAlign>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_see_outside')}>
                {user_data.outside_sight
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_hear_outside')}>
                {user_data.outside_hearing
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_see_inside')}>
                {user_data.internal_sight
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_hear_inside')}>
                {user_data.internal_hearing
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_speak')}>
                {user_data.able_to_speak
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_emote')}>
                {user_data.able_to_emote
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              {communicate_as_parent ? (
                <>
                  <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_speak_as_container')}>
                    {user_data.able_to_speak_as_container
                      ? t('ui.common.enabled')
                      : t('ui.common.disabled')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_emote_as_container')}>
                    {user_data.able_to_emote_as_container
                      ? t('ui.common.enabled')
                      : t('ui.common.disabled')}
                  </LabeledList.Item>
                </>
              ) : (
                null
              )}
              <LabeledList.Item label={t('ui.soulcatcheruser.ability_to_change_name')}>
                {user_data.able_to_rename && !user_data.scan_needed
                  ? t('ui.common.enabled')
                  : t('ui.common.disabled')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.soulcatcheruser.body_scan_needed')}>
                {user_data.scan_needed ? t('ui.common.true') : t('ui.common.false')}
              </LabeledList.Item>
            </LabeledList>
          </Collapsible>

          {souls && user_data.internal_sight ? (
            <>
              <br />
              <Box textAlign="center" fontSize="15px" opacity={0.8}>
                <b>{t('ui.soulcatcheruser.souls')}</b>
              </Box>
              <Divider />
              <Flex direction="column">
                {souls.map((soul) => (
                  <Flex.Item key={soul.key}>
                    <Collapsible title={soul.name}>
                      <Box textAlign="center" fontSize="13px" opacity={0.8}>
                        <b>{t('ui.soulcatcheruser.flavor_text')}</b>
                      </Box>
                      <Divider />
                      <BlockQuote preserveWhitespace>
                        {soul.description}
                      </BlockQuote>
                      <br />
                      <Box textAlign="center" fontSize="13px" opacity={0.8}>
                        <b>{t('ui.soulcatcheruser.ooc_notes')}</b>
                      </Box>
                      <Divider />
                      <BlockQuote preserveWhitespace>
                        {soul.ooc_notes}
                      </BlockQuote>
                    </Collapsible>
                  </Flex.Item>
                ))}
              </Flex>
            </>
          ) : (
            null
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
