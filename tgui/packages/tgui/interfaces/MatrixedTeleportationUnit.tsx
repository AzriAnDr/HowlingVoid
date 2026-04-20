import { useEffect } from 'react';
import {
  Box,
  Button,
  Icon,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type CondoTemplate = {
  name: string;
  title: string;
  category: string;
};

type CondoRoom = {
  room_number: number;
  room_name: string;
  template_name: string;
  icon: string;
  guest_names: string[];
  is_open: boolean;
};

type Data = {
  max_room_number: number;
  categories: string[];
  templates: CondoTemplate[];
  open_rooms: CondoRoom[];
  reserved_rooms: CondoRoom[];
};

const RoomListing = (props: {
  room: CondoRoom;
  onEnter: (roomNumber: number) => void;
  t: (key: string, fallback?: string) => string;
}) => {
  const { room, onEnter, t } = props;
  const guestNames = room.guest_names?.join(', ');

  return (
    <Button
      fluid
      textAlign="left"
      mb="4px"
      color="transparent"
      onClick={() => onEnter(room.room_number)}
      style={{
        padding: '0',
        border: `1px solid ${room.is_open ? '#4d8b2a' : '#35506a'}`,
        background: room.is_open
          ? 'linear-gradient(180deg, #244314 0%, #1c3211 100%)'
          : 'linear-gradient(180deg, #16212b 0%, #101921 100%)',
      }}
    >
      <Box p="6px 8px">
        <Stack align="center">
          <Stack.Item>
            <Icon
              name={room.icon || 'door-open'}
              color={room.is_open ? '#e8ffd8' : '#b8d7f1'}
            />
          </Stack.Item>
          <Stack.Item width="64px" color="#ffffff">
            {t('ui.matrixed_teleportation_unit.room_label', 'Room {number}').replace(
              '{number}',
              String(room.room_number),
            )}
          </Stack.Item>
          <Stack.Item grow color="#ffffff">
            {room.room_name}
          </Stack.Item>
          <Stack.Item
            style={{
              color: room.is_open ? '#c6f0ab' : '#8fc2f0',
              fontWeight: 600,
            }}
          >
            {room.template_name}
          </Stack.Item>
        </Stack>
        {!!guestNames && (
          <Box
            mt="3px"
            ml="22px"
            style={{
              color: room.is_open ? '#d8efc1' : '#b8cfe3',
              fontSize: '13px',
            }}
          >
            {guestNames}
          </Box>
        )}
      </Box>
    </Button>
  );
};

export const MatrixedTeleportationUnit = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [selectedCategory, setSelectedCategory] = useSharedState<string>(
    'selectedCategory',
    data.categories?.[0] || 'Condo',
  );
  const [selectedTemplate, setSelectedTemplate] = useSharedState<string>(
    'selectedTemplate',
    '',
  );
  const [roomNumber, setRoomNumber] = useSharedState<number>('roomNumber', 1);

  const filteredTemplates = data.templates.filter(
    (template) => template.category === selectedCategory,
  );

  const handleCheckIn = (targetRoomNumber: number) =>
    act('check_in', {
      room_number: targetRoomNumber,
      template_name: selectedTemplate,
    });

  useEffect(() => {
    if (!data.categories.includes(selectedCategory)) {
      setSelectedCategory(data.categories?.[0] || 'Condo');
    }
  }, [data.categories, selectedCategory]);

  useEffect(() => {
    if (
      !selectedTemplate ||
      !filteredTemplates.some((template) => template.name === selectedTemplate)
    ) {
      setSelectedTemplate(filteredTemplates[0]?.name || '');
    }
  }, [selectedTemplate, filteredTemplates]);

  return (
    <Window
      width={600}
      height={560}
      title={t(
        'ui.matrixed_teleportation_unit.title',
        "Dr. Hilbert's Hotel Room Reception",
      )}
    >
      <Window.Content scrollable>
        <Section
          title={t(
            'ui.matrixed_teleportation_unit.room_check_in',
            'Room Check-In',
          )}
        >
          <Tabs>
            {data.categories.map((category) => (
              <Tabs.Tab
                key={category}
                selected={selectedCategory === category}
                onClick={() => setSelectedCategory(category)}
              >
                {category}
              </Tabs.Tab>
            ))}
          </Tabs>
          <Stack mt="6px">
            <Stack.Item grow basis={0}>
              <Section fill scrollable height="200px">
                {filteredTemplates.map((template) => (
                  <Button
                    key={template.name}
                    fluid
                    icon="door-open"
                    selected={selectedTemplate === template.name}
                    onClick={() => setSelectedTemplate(template.name)}
                    mb="4px"
                  >
                    {template.title}
                  </Button>
                ))}
              </Section>
            </Stack.Item>
            <Stack.Item width="170px">
              <Section fill>
                <Box
                  textAlign="center"
                  style={{
                    backgroundColor: 'rgb(5, 12, 18)',
                    border: '1px solid rgb(77, 130, 173)',
                    color: 'rgb(115, 177, 228)',
                    fontSize: '32px',
                    marginBottom: '8px',
                    padding: '10px 8px',
                  }}
                >
                  {roomNumber}
                </Box>
                <NumberInput
                  fluid
                  step={1}
                  minValue={1}
                  maxValue={data.max_room_number}
                  value={roomNumber}
                  onChange={(value) => setRoomNumber(value)}
                />
                <Button
                  fluid
                  icon="sign-in-alt"
                  mt="8px"
                  onClick={() => handleCheckIn(roomNumber)}
                >
                  {t('ui.matrixed_teleportation_unit.check_in', 'Check-in')}
                </Button>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>

        <Section
          title={t('ui.matrixed_teleportation_unit.open_rooms', 'Open Rooms')}
        >
          {data.open_rooms.length ? (
            data.open_rooms.map((room) => (
              <RoomListing
                key={`open-${room.room_number}`}
                room={room}
                onEnter={handleCheckIn}
                t={t}
              />
            ))
          ) : (
            <Box italic color="label">
              {t(
                'ui.matrixed_teleportation_unit.no_open_rooms',
                'No open rooms now...',
              )}
            </Box>
          )}
        </Section>

        <Section
          title={t(
            'ui.matrixed_teleportation_unit.reserved_rooms',
            'Reserved Rooms',
          )}
        >
          {data.reserved_rooms.length ? (
            data.reserved_rooms.map((room) => (
              <RoomListing
                key={`reserved-${room.room_number}`}
                room={room}
                onEnter={handleCheckIn}
                t={t}
              />
            ))
          ) : (
            <Box italic color="label">
              {t(
                'ui.matrixed_teleportation_unit.no_reserved_rooms',
                'No reserved rooms now...',
              )}
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
