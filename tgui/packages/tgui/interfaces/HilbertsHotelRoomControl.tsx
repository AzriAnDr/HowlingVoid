import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Modal,
  Section,
  Stack,
  Table,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type RoomData = {
  room_number: number;
  user_name: string;
  can_manage: boolean;
  present_players: string[];
  room_preferences: {
    status: number;
    visibility: number;
    privacy: number;
    description: string;
    name: string;
    icon: string;
  };
  access_restrictions: {
    room_owner: string;
    trusted_guests: string[];
  };
};

const AVAILABLE_ICONS = [
  'door-open',
  'bed',
  'coffee',
  'glass-water',
  'burger',
  'dice',
  'gamepad',
  'heart',
  'music',
  'palette',
  'book',
  'dumbbell',
  'skull',
  'ghost',
  'money-bill',
  'user-tag',
  'clock',
  'circle',
] as const;

export const HilbertsHotelRoomControl = () => {
  const { act, data } = useBackend<RoomData>();
  const { t } = usePreferencesLocalization(data);
  const transferableResidents =
    data.present_players?.filter(
      (player) => player !== data.access_restrictions.room_owner,
    ) || [];
  const [iconPickerOpen, setIconPickerOpen] = useSharedState(
    'iconPicker',
    false,
  );
  const [transferOwnershipModalOpen, setTransferOwnershipModalOpen] =
    useSharedState('transferOwnership', false);

  const [statusSectionOpen, setStatusSectionOpen] = useSharedState(
    'statusSection',
    true,
  );
  const [accessSectionOpen, setAccessSectionOpen] = useSharedState(
    'accessSection',
    true,
  );
  const [interfaceLocked, setInterfaceLocked] = useSharedState(
    'interfaceLocked',
    false,
  );

  const [registerNewUser, setRegisterNewUser] = useSharedState(
    'registerNewUser',
    false,
  );

  const [localName, setLocalName] = useState(data.room_preferences.name || '');
  const [localDescription, setLocalDescription] = useState(
    data.room_preferences.description || '',
  );

  useEffect(() => {
    setLocalName(data.room_preferences.name || '');
    setLocalDescription(data.room_preferences.description || '');
  }, [data.room_preferences.name, data.room_preferences.description]);

  return (
    <Window
      width={400}
      height={420}
      title={t(
        'ui.hilberts_hotel_room_control.title',
        'Room Control Panel',
      )}
    >
      {registerNewUser && (
        <Modal
          style={{
            width: '300px',
            padding: '5px',
          }}
        >
          <Section
            title={t('ui.hilberts_hotel_room_control.registration', 'Registration')}
            buttons={
              <Button
                icon="times"
                color="bad"
                onClick={() => setRegisterNewUser(false)}
                style={{ cursor: 'pointer' }}
              />
            }
          >
            <Box>
              <Stack width="100%">
                <Stack.Item>
                  <Button
                    icon="fingerprint"
                    style={{
                      cursor: 'pointer',
                      fontSize: '1.5em',
                    }}
                    onClick={() => {
                      act('modify_trusted_guests', { action: 'add' });
                      setRegisterNewUser(false);
                    }}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  {t(
                    'ui.hilberts_hotel_room_control.register_yourself',
                    'Press the button to register yourself.',
                  )}
                </Stack.Item>
              </Stack>
            </Box>
          </Section>
        </Modal>
      )}
      {interfaceLocked && (
        <Modal
          style={{
            width: '300px',
            padding: '5px',
          }}
        >
          <Section>
            <Box>
              <Stack width="100%">
                <Stack.Item>
                  <Button
                    icon="fingerprint"
                    style={{
                      cursor: 'pointer',
                      fontSize: '1.5em',
                    }}
                    onClick={() =>
                      data.can_manage && setInterfaceLocked(!interfaceLocked)
                    }
                  />
                </Stack.Item>
                <Stack.Item grow>
                  {t(
                    'ui.hilberts_hotel_room_control.unlock_controls',
                    'Press the button to unlock the controls.',
                  )}
                </Stack.Item>
              </Stack>
            </Box>
          </Section>
        </Modal>
      )}
      {!!transferOwnershipModalOpen && (
        <Modal
          style={{
            width: '300px',
            padding: '5px',
          }}
        >
          <Section
            title={t(
              'ui.hilberts_hotel_room_control.room_ownership',
              'Room Ownership',
            )}
            buttons={
              <Button
                icon="times"
                color="bad"
                style={{ cursor: 'pointer' }}
                onClick={() => setTransferOwnershipModalOpen(false)}
              />
            }
          >
            <Box>
              <Stack vertical width="100%">
                <Stack.Item>
                  {t(
                    'ui.hilberts_hotel_room_control.choose_resident_inside_dorm',
                    'Choose a resident who is currently inside this dorm.',
                  )}
                </Stack.Item>
                {transferableResidents.map((player) => (
                  <Stack.Item key={player}>
                    <Button
                      fluid
                      icon="user"
                      onClick={() => {
                        act('transfer_ownership', { target_name: player });
                        setTransferOwnershipModalOpen(false);
                      }}
                    >
                      {player}
                    </Button>
                  </Stack.Item>
                ))}
                {!transferableResidents.length && (
                  <Stack.Item color="label">
                    <Box color="label">
                      {t(
                        'ui.hilberts_hotel_room_control.no_other_residents_inside',
                        'No other residents are currently inside the room.',
                      )}
                    </Box>
                  </Stack.Item>
                )}
              </Stack>
            </Box>
          </Section>
        </Modal>
      )}
      {!!iconPickerOpen && (
        <Modal
          style={{
            width: '300px',
            padding: '5px',
          }}
        >
          <Section>
            <Box
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(6, 1fr)',
                gap: '8px',
                padding: '8px',
              }}
            >
              {AVAILABLE_ICONS.map((icon) => (
                <Button
                  key={icon}
                  onClick={() => {
                    act('set_icon', { icon });
                    setIconPickerOpen(false);
                  }}
                  style={{
                    height: '32px',
                    width: '32px',
                    padding: '3px 8px',
                    lineHeight: '32px',
                    cursor: 'pointer',
                  }}
                >
                  <Icon name={icon} size={1.5} />
                </Button>
              ))}
            </Box>
          </Section>
        </Modal>
      )}
      <Window.Content>
        <Box
          style={{
            height: '100%',
            overflowY: 'auto',
            scrollbarWidth: 'none',
            msOverflowStyle: 'none',
          }}
        >
          <Section>
            <Stack>
              <Stack.Item
                style={{
                  fontSize: '20px',
                  textAlign: 'center',
                  backgroundColor: 'rgb(0, 0, 0)',
                  border: '2px solid rgb(77, 130, 173)',
                  borderRadius: '3px',
                  color: 'rgb(115, 177, 228)',
                  padding: '2px 5px',
                  minWidth: '40px',
                }}
              >
                {data.room_number ||
                  t('ui.hilberts_hotel_room_control.room_number_error', 'Err')}
              </Stack.Item>
              <Stack vertical>
                <Stack.Item
                  style={{
                    marginLeft: '10px',
                    fontSize: '8',
                    color: 'rgb(179, 179, 179)',
                    fontStyle: 'italic',
                  }}
                >
                  {t(
                    'ui.hilberts_hotel_room_control.currently_in',
                    "You're currently in...",
                  )}
                </Stack.Item>
                <Stack.Item
                  style={{
                    fontSize: '18px',
                    lineHeight: '0.8',
                    marginLeft: '10px',
                    marginTop: '1px',
                  }}
                >
                  {data.room_preferences.name ||
                    t(
                      'ui.hilberts_hotel_room_control.custom_room',
                      'Custom Room',
                    )}
                </Stack.Item>
              </Stack>
              <Stack.Item ml="auto" mr="2px">
                <Button
                  disabled={!data.can_manage}
                  onClick={() => setIconPickerOpen(true)}
                  style={{
                    height: '30px',
                    width: '32px',
                    cursor: 'pointer',
                    padding: '6px 8px',
                    marginTop: '1px',
                    marginRight: '1px',
                  }}
                  tooltip={t(
                    'ui.hilberts_hotel_room_control.icon_picker',
                    'Icon picker',
                  )}
                >
                  <Icon
                    size={1.5}
                    name={data.room_preferences.icon || 'snowflake'}
                  />
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
          <Section
            title={t(
              'ui.hilberts_hotel_room_control.room_controls',
              'Room Controls',
            )}
            buttons={
              <Stack>
                {data.can_manage && (
                  <Stack.Item>
                    <Button
                      fluid
                      icon={interfaceLocked ? 'lock-open' : 'lock'}
                      style={{ cursor: 'pointer' }}
                      tooltip={t(
                        'ui.hilberts_hotel_room_control.lock_interface',
                        'Lock the interface',
                      )}
                      color="transparent"
                      onClick={() => setInterfaceLocked(!interfaceLocked)}
                    />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Button
                    fluid
                    icon={statusSectionOpen ? 'chevron-down' : 'chevron-up'}
                    color="transparent"
                    onClick={() => setStatusSectionOpen(!statusSectionOpen)}
                    style={{
                      cursor: 'pointer',
                    }}
                  />
                </Stack.Item>
              </Stack>
            }
          >
            {statusSectionOpen && (
              <Stack vertical>
                <Stack fill textAlign="center">
                  <Stack.Item grow>
                    <Button
                      fluid
                      disabled={!data.can_manage}
                      icon={
                        data.room_preferences.visibility ? 'eye' : 'eye-slash'
                      }
                      onClick={() => act('toggle_visibility')}
                      lineHeight="2.2"
                      color={
                        data.room_preferences.visibility ? 'blue' : 'green'
                      }
                      style={{ cursor: 'pointer' }}
                    >
                      {data.room_preferences.visibility
                        ? t(
                            'ui.hilberts_hotel_room_control.listed',
                            'Listed',
                          )
                        : t(
                            'ui.hilberts_hotel_room_control.hidden',
                            'Hidden',
                          )}
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      disabled={!data.can_manage}
                      icon={
                        data.room_preferences.status === 1
                          ? 'door-open'
                          : data.room_preferences.status === 2
                            ? 'user-check'
                            : 'door-closed'
                      }
                      color={
                        data.room_preferences.status === 1
                          ? 'orange'
                          : data.room_preferences.status === 2
                            ? 'blue'
                            : 'green'
                      }
                      onClick={() => act('toggle_status')}
                      lineHeight="2.2"
                      style={{ cursor: 'pointer' }}
                    >
                      {data.room_preferences.status === 1
                        ? t('ui.hilberts_hotel_room_control.open', 'Open')
                        : data.room_preferences.status === 2
                          ? t(
                              'ui.hilberts_hotel_room_control.guests_only',
                              'Guests Only',
                            )
                          : t(
                              'ui.hilberts_hotel_room_control.closed',
                              'Closed',
                            )}
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      disabled={!data.can_manage}
                      icon={
                        data.room_preferences.privacy ? 'users' : 'user-secret'
                      }
                      onClick={() => act('toggle_privacy')}
                      lineHeight="2.2"
                      color={data.room_preferences.privacy ? 'blue' : 'green'}
                      style={{ cursor: 'pointer' }}
                    >
                      {data.room_preferences.privacy
                        ? t(
                            'ui.hilberts_hotel_room_control.names_shown',
                            'Names shown',
                          )
                        : t(
                            'ui.hilberts_hotel_room_control.names_hidden',
                            'Names hidden',
                          )}
                    </Button>
                  </Stack.Item>
                </Stack>
                <Stack mt="6px">
                  <Stack.Item width="100%">
                    <TextArea
                      fluid
                      height="1.7em"
                      width="100%"
                      placeholder={t(
                        'ui.hilberts_hotel_room_control.enter_room_name',
                        'Enter room name here...',
                      )}
                      value={localName}
                      onChange={(value) => setLocalName(value)}
                      maxLength={20}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Confirm
                      fluid
                      disabled={!data.can_manage}
                      icon="check"
                      tooltip={t(
                        'ui.hilberts_hotel_room_control.update_room_name',
                        'Update room name',
                      )}
                      onClick={() => act('update_name', { name: localName })}
                      style={{
                        cursor: 'pointer',
                        height: '1.7em',
                        width: '1.85em',
                      }}
                      confirmContent={
                        <Tooltip
                          content={t(
                            'ui.hilberts_hotel_room_control.confirm',
                            'Confirm?',
                          )}
                        >
                          <Icon name="question" />
                        </Tooltip>
                      }
                      confirmColor="green"
                    />
                  </Stack.Item>
                </Stack>
                <Stack.Item>
                  <TextArea
                    fluid
                    style={{
                      width: '100%',
                      height: '8em',
                    }}
                    placeholder={t(
                      'ui.hilberts_hotel_room_control.enter_room_description',
                      'Enter room description here...',
                    )}
                    value={localDescription}
                    onChange={(value) => setLocalDescription(value)}
                    maxLength={220}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Confirm
                    fluid
                    disabled={!data.can_manage}
                    icon="check"
                    onClick={() =>
                      act('update_description', {
                        description: localDescription,
                      })
                    }
                    confirmContent={t(
                      'ui.hilberts_hotel_room_control.confirm',
                      'Confirm?',
                    )}
                    confirmColor="green"
                  >
                    {t(
                      'ui.hilberts_hotel_room_control.update_description',
                      'Update description',
                    )}
                  </Button.Confirm>
                </Stack.Item>
              </Stack>
            )}
          </Section>
          <Section
            title={t(
              'ui.hilberts_hotel_room_control.room_access',
              'Room Access',
            )}
            buttons={
              <Stack>
                {accessSectionOpen &&
                  data.user_name !== data.access_restrictions.room_owner && (
                    <Stack.Item>
                      <Button
                        fluid
                        icon="plus"
                        color="transparent"
                        onClick={() => setRegisterNewUser(true)}
                        style={{
                          cursor: 'pointer',
                        }}
                      />
                    </Stack.Item>
                  )}
                {accessSectionOpen &&
                  data.can_manage &&
                  data.access_restrictions.trusted_guests?.length > 0 && (
                    <Stack.Item>
                      <Button
                        icon="trash-alt"
                        color="transparent"
                        style={{ cursor: 'pointer' }}
                        tooltip={t(
                          'ui.hilberts_hotel_room_control.clear_all_guests',
                          'Clear all guests',
                        )}
                        onClick={() =>
                          act('modify_trusted_guests', { action: 'clear' })
                        }
                      />
                    </Stack.Item>
                  )}
                <Stack.Item>
                  <Button
                    fluid
                    icon={accessSectionOpen ? 'chevron-down' : 'chevron-up'}
                    color="transparent"
                    onClick={() => setAccessSectionOpen(!accessSectionOpen)}
                    style={{
                      cursor: 'pointer',
                    }}
                  />
                </Stack.Item>
              </Stack>
            }
          >
            {accessSectionOpen && (
              <Box>
                <Stack lineHeight="1.6">
                  {data.can_manage && (
                    <Stack.Item>
                      <Button
                        icon="exchange-alt"
                        color="transparent"
                        style={{ cursor: 'pointer' }}
                        tooltip={t(
                          'ui.hilberts_hotel_room_control.transfer_ownership',
                          'Transfer ownership',
                        )}
                        onClick={() => setTransferOwnershipModalOpen(true)}
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>{data.access_restrictions.room_owner}</Stack.Item>
                  <Stack.Item textAlign="right" grow>
                    {t(
                      'ui.hilberts_hotel_room_control.room_owner',
                      'Room Owner',
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            )}
          </Section>
          {accessSectionOpen &&
            data.access_restrictions.trusted_guests?.length > 0 && (
              <Section>
                <Table>
                  <tbody>
                    {data.access_restrictions.trusted_guests?.map((guest) => (
                      <GuestRow key={guest} guest_name={guest} />
                    ))}
                  </tbody>
                </Table>
              </Section>
            )}
        </Box>
      </Window.Content>
    </Window>
  );
};

type GuestRowProps = {
  guest_name: string;
};

const GuestRow = (props: GuestRowProps) => {
  const { guest_name } = props;
  const { act, data } = useBackend<RoomData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Table.Row
      className="candystripe"
      style={{
        height: '2em',
        padding: '20px',
        lineHeight: '2em',
      }}
    >
      <Table.Cell width="100%" textAlign="left">
        {guest_name}
      </Table.Cell>
      <Table.Cell>
        {t('ui.hilberts_hotel_room_control.guest', 'Guest')}
      </Table.Cell>
      <Table.Cell>
        {data.can_manage && (
          <Button
            icon="trash-alt"
            color="transparent"
            style={{ cursor: 'pointer' }}
            onClick={() =>
              act('modify_trusted_guests', {
                action: 'remove',
                user: guest_name,
              })
            }
          />
        )}
      </Table.Cell>
    </Table.Row>
  );
};
