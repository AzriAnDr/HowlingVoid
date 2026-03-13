import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const RadioactiveMicrolaser = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    irradiate,
    stealth,
    scanmode,
    intensity,
    wavelength,
    on_cooldown,
    cooldown,
  } = data;
  return (
    <Window
      title={t('ui.radioactive_microlaser.title')}
      width={320}
      height={335}
      theme="syndicate"
    >
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.radioactive_microlaser.laser_status')}>
              <Box color={on_cooldown ? 'average' : 'good'}>
                {on_cooldown
                  ? t('ui.radioactive_microlaser.recharging')
                  : t('ui.radioactive_microlaser.ready')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.radioactive_microlaser.scanner_controls')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.radioactive_microlaser.irradiation')}>
              <Button
                icon={irradiate ? 'power-off' : 'times'}
                content={
                  irradiate
                    ? t('ui.common.on')
                    : t('ui.common.off')
                }
                selected={irradiate}
                onClick={() => act('irradiate')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.radioactive_microlaser.stealth_mode')}>
              <Button
                icon={stealth ? 'eye-slash' : 'eye'}
                content={stealth ? t('ui.common.on') : t('ui.common.off')}
                disabled={!irradiate}
                selected={stealth}
                onClick={() => act('stealth')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.radioactive_microlaser.scan_mode')}>
              <Button
                icon={scanmode ? 'mortar-pestle' : 'heartbeat'}
                content={
                  scanmode
                    ? t('ui.radioactive_microlaser.scan_reagents')
                    : t('ui.radioactive_microlaser.scan_health')
                }
                disabled={irradiate && stealth}
                onClick={() => act('scanmode')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.radioactive_microlaser.laser_settings')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.radioactive_microlaser.radiation_intensity')}
            >
              <Button
                icon="fast-backward"
                onClick={() => act('radintensity', { adjust: -5 })}
              />
              <Button
                icon="backward"
                onClick={() => act('radintensity', { adjust: -1 })}
              />{' '}
              <NumberInput
                value={Math.round(intensity)}
                width="40px"
                minValue={1}
                maxValue={20}
                step={1}
                onChange={(value) => {
                  return act('radintensity', {
                    target: value,
                  });
                }}
              />{' '}
              <Button
                icon="forward"
                onClick={() => act('radintensity', { adjust: 1 })}
              />
              <Button
                icon="fast-forward"
                onClick={() => act('radintensity', { adjust: 5 })}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.radioactive_microlaser.radiation_wavelength')}
            >
              <Button
                icon="fast-backward"
                onClick={() => act('radwavelength', { adjust: -5 })}
              />
              <Button
                icon="backward"
                onClick={() => act('radwavelength', { adjust: -1 })}
              />{' '}
              <NumberInput
                value={Math.round(wavelength)}
                width="40px"
                minValue={0}
                maxValue={120}
                step={1}
                onChange={(value) => {
                  return act('radwavelength', {
                    target: value,
                  });
                }}
              />{' '}
              <Button
                icon="forward"
                onClick={() => act('radwavelength', { adjust: 1 })}
              />
              <Button
                icon="fast-forward"
                onClick={() => act('radwavelength', { adjust: 5 })}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.radioactive_microlaser.laser_cooldown')}>
              <Box inline bold>
                {cooldown}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
