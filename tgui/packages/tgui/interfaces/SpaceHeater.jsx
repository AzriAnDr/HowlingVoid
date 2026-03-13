import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const SpaceHeater = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();

  const modeLabel = (mode) => {
    if (mode === 'auto') return t('ui.common.auto');
    if (mode === 'heat') return t('ui.space_heater.heat');
    if (mode === 'cool') return t('ui.space_heater.cool');
    return capitalize(mode);
  };

  return (
    <Window width={400} height={305}>
      <Window.Content>
        <Section
          title={t('ui.common.power')}
          buttons={
            <>
              {!!data.chemHacked && (
                <Button
                  icon="eject"
                  content={t('ui.space_heater.eject_beaker')}
                  disabled={!data.beaker}
                  onClick={() => act('ejectBeaker')}
                />
              )}
              <Button
                icon="eject"
                content={t('ui.space_heater.eject_cell')}
                disabled={!data.hasPowercell || !data.open}
                onClick={() => act('eject')}
              />
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? t('ui.common.on') : t('ui.common.off')}
                selected={data.on}
                disabled={!data.hasPowercell}
                onClick={() => act('power')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label={t('ui.space_heater.cell')}
              color={!data.hasPowercell && 'bad'}
            >
              {(data.hasPowercell && (
                <ProgressBar
                  value={data.powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                >
                  {`${data.powerLevel}%`}
                </ProgressBar>
              )) ||
                t('ui.common.none')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.space_heater.thermostat')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.space_heater.current_temperature')}>
              <Box
                fontSize="18px"
                color={
                  Math.abs(data.targetTemp - data.currentTemp) > 50
                    ? 'bad'
                    : Math.abs(data.targetTemp - data.currentTemp) > 20
                      ? 'average'
                      : 'good'
                }
              >
                {data.currentTemp}
                {t('ui.space_heater.degrees_celsius')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.space_heater.target_temperature')}>
              {(data.open && (
                <NumberInput
                  animated
                  value={parseFloat(data.targetTemp)}
                  width="65px"
                  unit={t('ui.space_heater.degrees_celsius')}
                  step={1}
                  minValue={data.minTemp}
                  maxValue={data.maxTemp}
                  onChange={(value) =>
                    act('target', {
                      target: value,
                    })
                  }
                />
              )) ||
                `${data.targetTemp}${t('ui.space_heater.degrees_celsius')}`}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.mode')}>
              {(!data.open && modeLabel(data.mode)) || (
                <>
                  <Button
                    icon="thermometer-half"
                    content={t('ui.common.auto')}
                    selected={data.mode === 'auto'}
                    onClick={() =>
                      act('mode', {
                        mode: 'auto',
                      })
                    }
                  />
                  <Button
                    icon="fire-alt"
                    content={t('ui.space_heater.heat')}
                    selected={data.mode === 'heat'}
                    onClick={() =>
                      act('mode', {
                        mode: 'heat',
                      })
                    }
                  />
                  <Button
                    icon="fan"
                    content={t('ui.space_heater.cool')}
                    selected={data.mode === 'cool'}
                    onClick={() =>
                      act('mode', {
                        mode: 'cool',
                      })
                    }
                  />
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
