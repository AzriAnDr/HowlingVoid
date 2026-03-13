import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Holopad = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { calling } = data;
  return (
    <Window width={440} height={245}>
      {!!calling && (
        <Modal fontSize="36px" fontFamily="monospace">
          <Flex align="center">
            <Flex.Item mr={2} mt={2}>
              <Icon name="phone-alt" rotation={25} />
            </Flex.Item>
            <Flex.Item mr={2}>{t('ui.holopad.dialing')}</Flex.Item>
          </Flex>
          <Box mt={2} textAlign="center" fontSize="24px">
            <Button
              lineHeight="40px"
              icon="times"
              content={t('ui.holopad.hang_up')}
              color="bad"
              onClick={() => act('hang_up')}
            />
          </Box>
        </Modal>
      )}
      <Window.Content scrollable>
        <HolopadContent />
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    on_network,
    on_cooldown,
    allowed,
    disk,
    disk_record,
    replay_mode,
    loop_mode,
    record_mode,
    holo_calls = [],
  } = data;
  return (
    <>
      <Section
        title={t('ui.holopad.title')}
        buttons={
          <Button
            icon="bell"
            content={
              on_cooldown
                ? t('ui.holopad.ai_presence_requested')
                : t('ui.holopad.request_ai_presence')
            }
            disabled={!on_network || on_cooldown}
            onClick={() => act('AIrequest')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.holopad.communicator')}>
            <Button
              icon="phone-alt"
              content={
                allowed
                  ? t('ui.holopad.connect_to_holopad')
                  : t('ui.holopad.call_holopad')
              }
              disabled={!on_network}
              onClick={() => act('holocall', { headcall: allowed })}
            />
          </LabeledList.Item>
          {holo_calls.map((call) => {
            return (
              <LabeledList.Item
                label={
                  call.connected
                    ? t('ui.holopad.current_call')
                    : t('ui.holopad.incoming_call')
                }
                key={call.ref}
              >
                <Button
                  icon={call.connected ? 'phone-slash' : 'phone-alt'}
                  content={
                    call.connected
                      ? `${t('ui.holopad.disconnect_call_from')} ${call.caller}`
                      : `${t('ui.holopad.answer_call_from')} ${call.caller}`
                  }
                  color={call.connected ? 'bad' : 'good'}
                  disabled={!on_network}
                  onClick={() =>
                    act(call.connected ? 'disconnectcall' : 'connectcall', {
                      holopad: call.ref,
                    })
                  }
                />
              </LabeledList.Item>
            );
          })}
          {holo_calls.filter((call) => !call.connected).length > 0 && (
            <LabeledList.Item key="reject">
              <Button
                icon="phone-slash"
                content={t('ui.holopad.reject_incoming_calls')}
                color="bad"
                onClick={() => act('rejectall')}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title={t('ui.holopad.holodisk')}
        buttons={
          <Button
            icon="eject"
            content={t('ui.common.eject')}
            disabled={!disk || replay_mode || record_mode}
            onClick={() => act('disk_eject')}
          />
        }
      >
        {(!disk && <NoticeBox>{t('ui.holopad.no_holodisk')}</NoticeBox>) || (
          <LabeledList>
            <LabeledList.Item label={t('ui.holopad.disk_player')}>
              <Button
                icon={replay_mode ? 'pause' : 'play'}
                content={replay_mode ? t('ui.common.stop') : t('ui.holopad.replay')}
                selected={replay_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('replay_mode')}
              />
              <Button
                icon={'sync'}
                content={
                  loop_mode ? t('ui.holopad.looping') : t('ui.holopad.loop')
                }
                selected={loop_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('loop_mode')}
              />
              <Button
                icon="exchange-alt"
                content={t('ui.holopad.change_offset')}
                disabled={!replay_mode}
                onClick={() => act('offset')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.holopad.recorder')}>
              <Button
                icon={record_mode ? 'pause' : 'video'}
                content={
                  record_mode
                    ? t('ui.holopad.end_recording')
                    : t('ui.holopad.record')
                }
                selected={record_mode}
                disabled={(disk_record && !record_mode) || replay_mode}
                onClick={() => act('record_mode')}
              />
              <Button
                icon="trash"
                content={t('ui.holopad.clear_recording')}
                color="bad"
                disabled={!disk_record || replay_mode || record_mode}
                onClick={() => act('record_clear')}
              />
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </>
  );
};
