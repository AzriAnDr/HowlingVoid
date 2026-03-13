import {
  Box,
  Button,
  Chart,
  Icon,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  supply: number;
  capacity: number;
  azimuth_current: number;
  azimuth_rate: number;
  max_rotation_rate: number;
  tracking_state: number;
  connected_panels: number;
  connected_tracker: BooleanLike;
  history: History;
};

type History = {
  supply: number[];
  capacity: number[];
};

export const SolarControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const {
    supply,
    capacity,
    azimuth_current,
    azimuth_rate,
    max_rotation_rate,
    tracking_state,
    connected_panels,
    connected_tracker,
    history,
  } = data;
  const supplyData = history.supply.map((value, i) => [i, value]);
  const capacityData = history.capacity.map((value, i) => [i, value]);
  const maxValue = Math.max(1, ...history.capacity, ...history.supply);

  return (
    <Window width={330} height={330}>
      <Window.Content>
        <Section title={t('ui.solar_control.status')}>
          <Box
            mb={1}
            position="relative"
            overflow="visible"
            height="64px"
            backgroundColor={'black'}
          >
            <Chart.Line
              p={1}
              fillPositionedParent
              data={capacityData}
              rangeX={[0, capacityData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(150, 117, 39, 1)"
              fillColor="rgba(150, 117, 39, 0.5)"
            />
            <Chart.Line
              p={1}
              fillPositionedParent
              data={supplyData}
              rangeX={[0, supplyData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(235, 210, 52, 1)"
              fillColor="rgba(235, 210, 52, 0.5)"
            />
          </Box>
          <Stack>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label={t('ui.solar_control.power_output')}>
                  <ProgressBar
                    value={capacity > 0 ? supply / capacity : 0}
                    minValue={0}
                    maxValue={1}
                    ranges={{
                      good: [0.66, Infinity],
                      average: [0.33, 0.66],
                      bad: [-Infinity, 0.33],
                    }}
                  >
                    {capacity > 0
                      ? `${formatPower(supply)} ${t('ui.common.of')} ${formatPower(
                          capacity,
                        )} (${Math.round((100 * supply) / capacity)}%)`
                      : formatPower(0)}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item
                  label={t('ui.solar_control.solar_panels')}
                  color={connected_panels > 0 ? 'good' : 'bad'}
                >
                  {connected_panels}
                </LabeledList.Item>
                <LabeledList.Item
                  label={t('ui.solar_control.solar_tracker')}
                  color={connected_tracker ? 'good' : 'bad'}
                >
                  {connected_tracker ? t('ui.common.ok') : 'N/A'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title={t('ui.common.controls')}
          buttons={
            <Button
              icon="sync"
              content={t('ui.solar_control.scan_for_new_hardware')}
              onClick={() => act('refresh')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.solar_control.tracking')}>
              <Button
                icon="times"
                content={t('ui.common.off')}
                selected={tracking_state === 0}
                onClick={() => act('tracking', { mode: 0 })}
              />
              <Button
                icon="clock-o"
                content={t('ui.solar_control.timed')}
                selected={tracking_state === 1}
                onClick={() => act('tracking', { mode: 1 })}
              />
              <Button
                icon="sync"
                content={t('ui.common.auto')}
                selected={tracking_state === 2}
                disabled={!connected_tracker}
                onClick={() => act('tracking', { mode: 2 })}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.solar_control.azimuth')}>
              <Icon mr={1} name="arrow-up" rotation={azimuth_current} />
              {(tracking_state === 0 || tracking_state === 1) && (
                <NumberInput
                  tickWhileDragging
                  width="52px"
                  unit={t('ui.solar_control.degrees')}
                  step={1}
                  stepPixelSize={2}
                  minValue={-360}
                  maxValue={+720}
                  value={azimuth_current}
                  onChange={(value) => act('azimuth', { value })}
                />
              )}
              {tracking_state === 1 && (
                <NumberInput
                  tickWhileDragging
                  width="80px"
                  unit={t('ui.solar_control.degrees_per_minute')}
                  step={0.01}
                  stepPixelSize={1}
                  minValue={-max_rotation_rate - 0.01}
                  maxValue={max_rotation_rate + 0.01}
                  value={azimuth_rate}
                  format={(rate) => {
                    const sign = Math.sign(rate) > 0 ? '+' : '-';
                    return sign + Math.abs(rate);
                  }}
                  onChange={(value) => act('azimuth_rate', { value })}
                />
              )}
              {tracking_state === 2 && (
                <Box inline color="label" mt="3px">
                  {`${azimuth_current} ${t('ui.solar_control.degrees')}`} ({t('ui.common.auto')})
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

