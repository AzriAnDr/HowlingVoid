// THIS IS A NOVA SECTOR UI FILE
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Soulcatcher = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    require_approval,
    current_rooms = [],
    ghost_joinable,
    current_soul_count,
    max_souls,
    removable,
    communicate_as_parent,
    theme,
  } = data;

  return (
    <Window width={520} height={400} theme={theme} resizable>
      <Window.Content scrollable>
        {current_rooms.map((room) => (
          <Section
            key={room.key}
            title={<span style={{ color: room.color }}>{room.name}</span>}
            buttons={
              <>
                <Button
                  icon="palette"
                  tooltip={t('ui.soulcatcher.change_room_color_tooltip')}
                  onClick={() =>
                    act('change_room_color', { room_ref: room.reference })
                  }
                >
                  {t('ui.soulcatcher.recolor')}
                </Button>
                <Button
                  icon="pen"
                  tooltip={t('ui.soulcatcher.change_room_name_tooltip')}
                  onClick={() =>
                    act('rename_room', { room_ref: room.reference })
                  }
                >
                  {t('ui.common.rename')}
                </Button>
                <Button
                  icon="trash"
                  tooltip={t('ui.soulcatcher.delete_room_tooltip')}
                  color="red"
                  onClick={() =>
                    act('delete_room', { room_ref: room.reference })
                  }
                >
                  {t('ui.common.delete')}
                </Button>
              </>
            }
          >
            <BlockQuote preserveWhitespace> {room.description}</BlockQuote>
            <Box>
              <Button
                icon="scroll"
                tooltip={t('ui.soulcatcher.narrate_tooltip')}
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: true,
                    narration: true,
                  })
                }
              >
                {t('ui.soulcatcher.narrate')}
              </Button>

              <Button
                icon="comment"
                tooltip={t('ui.soulcatcher.say_tooltip')}
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: false,
                  })
                }
              >
                {t('ui.common.say')}
              </Button>

              <Button
                icon="face-smile"
                tooltip={t('ui.soulcatcher.emote_tooltip')}
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: true,
                  })
                }
              >
                {t('ui.common.emote')}
              </Button>

              <Button
                icon="user-gear"
                tooltip={t('ui.soulcatcher.edit_name_tooltip')}
                onClick={() =>
                  act('modify_name', {
                    room_ref: room.reference,
                  })
                }
              >
                {t('ui.soulcatcher.edit_name')}
              </Button>
              <Button
                icon="book"
                tooltip={t('ui.soulcatcher.redecorate_tooltip')}
                onClick={() =>
                  act('redescribe_room', { room_ref: room.reference })
                }
              >
                {t('ui.soulcatcher.redecorate')}
              </Button>
              <Button
                color={room.joinable ? 'green' : 'red'}
                icon={room.joinable ? 'door-open' : 'door-closed'}
                onClick={() =>
                  act('toggle_joinable_room', { room_ref: room.reference })
                }
              >
                {room.joinable
                  ? t('ui.soulcatcher.room_joinable')
                  : t('ui.soulcatcher.room_unjoinable')}
              </Button>
              <Button
                icon={room.currently_targeted ? 'check' : 'xmark'}
                tooltip={t('ui.soulcatcher.targeted_room_tooltip')}
                color={room.currently_targeted ? 'green' : 'red'}
                onClick={() =>
                  act('change_targeted_room', { room_ref: room.reference })
                }
              >
                {room.currently_targeted
                  ? t('ui.soulcatcher.targeted')
                  : t('ui.soulcatcher.untargeted')}
              </Button>
            </Box>
            {room.souls ? (
              <>
                <br />
                <Box textAlign="center" fontSize="15px" opacity={0.8}>
                  <b>{t('ui.soulcatcher.current_souls')}</b>
                </Box>
                <Divider />
                <Flex direction="column">
                  {room.souls.map((soul) => (
                    <Flex.Item key={soul.key}>
                      <Collapsible
                        title={soul.name}
                        buttons={
                          <>
                            {soul.scan_needed ? (
                              null
                            ) : (
                              <>
                                <Button
                                  color="green"
                                  icon="pen"
                                  tooltip={t('ui.soulcatcher.change_soul_name_tooltip')}
                                  onClick={() =>
                                    act('change_name', {
                                      target_soul: soul.reference,
                                      room_ref: room.reference,
                                    })
                                  }
                                />
                                <Button
                                  color="red"
                                  icon="arrow-rotate-left"
                                  tooltip={t('ui.soulcatcher.reset_soul_name_tooltip')}
                                  onClick={() =>
                                    act('reset_name', {
                                      target_soul: soul.reference,
                                      room_ref: room.reference,
                                    })
                                  }
                                />
                              </>
                            )}
                            <Button
                              icon="paper-plane"
                              tooltip={t('ui.soulcatcher.transfer_soul_tooltip')}
                              onClick={() =>
                                act('transfer_soul', {
                                  room_ref: room.reference,
                                  target_soul: soul.reference,
                                })
                              }
                            />
                          </>
                        }
                      >
                        <Box textAlign="center" fontSize="13px" opacity={0.8}>
                          <b>{t('ui.soulcatcher.flavor_text')}</b>
                        </Box>
                        <Divider />
                        <BlockQuote preserveWhitespace>
                          {soul.description}
                        </BlockQuote>
                        <br />
                        <Box textAlign="center" fontSize="13px" opacity={0.8}>
                          <b>{t('ui.soulcatcher.ooc_notes')}</b>
                        </Box>
                        <Divider />
                        <BlockQuote preserveWhitespace>
                          {soul.ooc_notes}
                        </BlockQuote>
                        <br />
                        <LabeledList>
                          <LabeledList.Item label={t('ui.soulcatcher.outside_hearing')}>
                            <Button
                              color={soul.outside_hearing ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.outside_hearing_tooltip')}
                              onClick={() =>
                                act('toggle_soul_outside_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'hearing',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.outside_hearing
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.soulcatcher.outside_sight')}>
                            <Button
                              color={soul.outside_sight ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.outside_sight_tooltip')}
                              onClick={() =>
                                act('toggle_soul_outside_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'sight',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.outside_sight
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.soulcatcher.hearing')}>
                            <Button
                              color={soul.internal_hearing ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.hearing_tooltip')}
                              onClick={() =>
                                act('toggle_soul_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'hearing',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.internal_hearing
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.soulcatcher.sight')}>
                            <Button
                              color={soul.internal_sight ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.sight_tooltip')}
                              onClick={() =>
                                act('toggle_soul_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'sight',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.internal_sight
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.soulcatcher.speech')}>
                            <Button
                              color={soul.able_to_speak ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.speech_tooltip')}
                              onClick={() =>
                                act('toggle_soul_communication', {
                                  target_soul: soul.reference,
                                  communication_type: 'speech',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_speak
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.common.emote')}>
                            <Button
                              color={soul.able_to_emote ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.emote_enabled_tooltip')}
                              onClick={() =>
                                act('toggle_soul_communication', {
                                  target_soul: soul.reference,
                                  communication_type: 'emote',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_emote
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                          {communicate_as_parent ? (
                            <>
                              <LabeledList.Item label={t('ui.soulcatcher.external_speech')}>
                                <Button
                                  color={
                                    soul.able_to_speak_as_container
                                      ? 'green'
                                      : 'red'
                                  }
                                  fluid
                                  tooltip={t('ui.soulcatcher.external_speech_tooltip')}
                                  onClick={() =>
                                    act('toggle_soul_external_communication', {
                                      target_soul: soul.reference,
                                      communication_type: 'speech',
                                      room_ref: room.reference,
                                    })
                                  }
                                >
                                  {soul.able_to_speak_as_container
                                    ? t('ui.common.enabled')
                                    : t('ui.common.disabled')}
                                </Button>
                              </LabeledList.Item>
                              <LabeledList.Item label={t('ui.soulcatcher.external_emote')}>
                                <Button
                                  color={
                                    soul.able_to_emote_as_container
                                      ? 'green'
                                      : 'red'
                                  }
                                  fluid
                                  tooltip={t('ui.soulcatcher.external_emote_tooltip')}
                                  onClick={() =>
                                    act('toggle_soul_external_communication', {
                                      target_soul: soul.reference,
                                      communication_type: 'emote',
                                      room_ref: room.reference,
                                    })
                                  }
                                >
                                  {soul.able_to_emote_as_container
                                    ? t('ui.common.enabled')
                                    : t('ui.common.disabled')}
                                </Button>
                              </LabeledList.Item>
                            </>
                          ) : (
                            null
                          )}
                          <LabeledList.Item label={t('ui.common.rename')}>
                            <Button
                              color={soul.able_to_rename ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.soulcatcher.rename_self_tooltip')}
                              onClick={() =>
                                act('toggle_soul_renaming', {
                                  target_soul: soul.reference,
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_rename
                                ? t('ui.common.enabled')
                                : t('ui.common.disabled')}
                            </Button>
                          </LabeledList.Item>
                        </LabeledList>
                        <br />
                        <Button
                          fluid
                          icon="eject"
                          color="red"
                          onClick={() =>
                            act('remove_soul', {
                              target_soul: soul.reference,
                              room_ref: room.reference,
                            })
                          }
                        >
                          {t('ui.soulcatcher.remove_soul')}
                        </Button>
                      </Collapsible>
                    </Flex.Item>
                  ))}
                </Flex>
              </>
            ) : (
              null
            )}
          </Section>
        ))}
        {max_souls ? (
          <Section>
            <ProgressBar
              textAlign="left"
              minValue={0}
              color="blue"
              maxValue={max_souls}
              value={max_souls - current_soul_count}
            >
              {t('ui.soulcatcher.remaining_soul_capacity')}: {max_souls - current_soul_count}
            </ProgressBar>
          </Section>
        ) : (
          null
        )}
        <Button
          fluid
          color="green"
          icon="plus"
          onClick={() => act('create_room', {})}
        >
          {t('ui.soulcatcher.create_new_room')}
        </Button>
        <Button
          fluid
          color={ghost_joinable ? 'green' : 'red'}
          icon={ghost_joinable ? 'door-open' : 'door-closed'}
          onClick={() => act('toggle_joinable', {})}
        >
          {ghost_joinable
            ? t('ui.soulcatcher.opened')
            : t('ui.soulcatcher.closed')}{' '}
          {t('ui.soulcatcher.to_ghosts')}
        </Button>
        <Button
          fluid
          color={require_approval ? 'green' : 'red'}
          icon={require_approval ? 'lock' : 'lock-open'}
          onClick={() => act('toggle_approval', {})}
        >
          {t('ui.soulcatcher.approval_is')} {require_approval ? '' : t('ui.soulcatcher.not')}{' '}
          {t('ui.soulcatcher.required_to_join')}
        </Button>
        {removable ? (
          <Button
            require_approval
            fluid
            color="red"
            icon="eject"
            onClick={() => act('delete_self', {})}
          >
            {t('ui.soulcatcher.remove_from_parent')}
          </Button>
        ) : (
          null
        )}
      </Window.Content>
    </Window>
  );
};
