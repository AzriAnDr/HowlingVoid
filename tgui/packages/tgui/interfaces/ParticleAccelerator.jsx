// THIS IS A NOVA SECTOR UI FILE
import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ParticleAccelerator = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    assembled,
    power,
    powered,
    power_available,
    power_enough,
    power_required,
    powernet_connected,
    strength,
  } = data;
  return (
    <Window width={350} height={350}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.common.status')}
              buttons={
                <Button
                  icon={'sync'}
                  content={t('ui.particle_accelerator.run_scan')}
                  onClick={() => act('scan')}
                />
              }
            >
              <Box color={assembled ? 'good' : 'bad'}>
                {assembled
                  ? t('ui.particle_accelerator.ready_all_parts_in_place')
                  : t('ui.particle_accelerator.unable_to_detect_all_parts')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.particle_accelerator.power_budget')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.particle_accelerator.required_power')}
            >
              {formatSiUnit(power_required, 0, 'W')}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.particle_accelerator.available_power')}
            >
              {formatSiUnit(power_available, 0, 'W')}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.particle_accelerator.powernet')}
            >
              <Box color={powernet_connected ? 'good' : 'bad'}>
                {powernet_connected
                  ? t('ui.particle_accelerator.connected')
                  : t('ui.particle_accelerator.disconnected')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.particle_accelerator.power_status')}
            >
              <Box color={power_enough && (!power || powered) ? 'good' : 'bad'}>
                {power_enough
                  ? t('ui.particle_accelerator.enough_power')
                  : t('ui.particle_accelerator.not_enough_power')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.particle_accelerator.controls')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.power')}>
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? t('ui.common.on') : t('ui.common.off')}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.particle_accelerator.particle_strength')}
            >
              <Button
                icon="backward"
                disabled={!assembled}
                onClick={() => act('remove_strength')}
              />{' '}
              {String(strength).padStart(1, '0')}{' '}
              <Button
                icon="forward"
                disabled={!assembled}
                onClick={() => act('add_strength')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
