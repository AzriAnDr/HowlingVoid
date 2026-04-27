import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const GulagTeleporterConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    teleporter,
    teleporter_lock,
    teleporter_state_open,
    teleporter_location,
    beacon,
    beacon_location,
    id,
    id_name,
    can_teleport,
    goal = 0,
    prisoner = {},
  } = data;
  return (
    <Window width={350} height={295}>
      <Window.Content>
        <Section
          title={t('ui.gulag_teleporter_console.title')}
          buttons={
            <>
              <Button
                content={
                  teleporter_state_open
                    ? t('ui.common.open')
                    : t('ui.common.closed')
                }
                disabled={teleporter_lock}
                selected={teleporter_state_open}
                onClick={() => act('toggle_open')}
              />
              <Button
                icon={teleporter_lock ? 'lock' : 'unlock'}
                content={
                  teleporter_lock
                    ? t('ui.common.locked')
                    : t('ui.common.unlocked')
                }
                selected={teleporter_lock}
                disabled={teleporter_state_open}
                onClick={() => act('teleporter_lock')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label={t('ui.gulag_teleporter_console.teleporter_unit')}
              color={teleporter ? 'good' : 'bad'}
              buttons={
                !teleporter && (
                  <Button
                    content={t('ui.common.reconnect')}
                    onClick={() => act('scan_teleporter')}
                  />
                )
              }
            >
              {teleporter
                ? teleporter_location
                : t('ui.common.not_connected')}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.gulag_teleporter_console.receiver_beacon')}
              color={beacon ? 'good' : 'bad'}
              buttons={
                !beacon && (
                  <Button
                    content={t('ui.common.reconnect')}
                    onClick={() => act('scan_beacon')}
                  />
                )
              }
            >
              {beacon ? beacon_location : t('ui.common.not_connected')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.gulag_teleporter_console.prisoner_details')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.gulag_teleporter_console.prisoner_id')}>
              <Button
                fluid
                content={id ? id_name : t('ui.gulag_teleporter_console.no_id')}
                onClick={() => act('handle_id')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.gulag_teleporter_console.point_goal')}>
              <NumberInput
                value={goal}
                step={1}
                width="80px"
                minValue={1}
                maxValue={1000000}
                onChange={(value) => act('set_goal', { value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.gulag_teleporter_console.occupant')}>
              {prisoner.name || t('ui.gulag_teleporter_console.no_occupant')}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.gulag_teleporter_console.criminal_status')}
            >
              {prisoner.crimstat || t('ui.gulag_teleporter_console.no_status')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Button
          fluid
          content={t('ui.gulag_teleporter_console.process_prisoner')}
          disabled={!can_teleport}
          textAlign="center"
          color="bad"
          onClick={() => act('teleport')}
        />
      </Window.Content>
    </Window>
  );
};
