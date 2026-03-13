import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  capacity: number;
  charge: number;
  inputAttempt: number;
  inputting: number;
  inputLevel: number;
  inputLevelMax: number;
  inputAvailable: number;
  outputAttempt: number;
  outputting: number;
  outputLevel: number;
  outputLevelMax: number;
  outputUsed: number;
};

// Common power multiplier
const POWER_MUL = 1e3;

export const Smes = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    capacity,
    charge,
    inputAttempt,
    inputting,
    inputLevel,
    inputLevelMax,
    inputAvailable,
    outputAttempt,
    outputting,
    outputLevel,
    outputLevelMax,
    outputUsed,
  } = data;

  const capacityPercent = round(100 * (charge / capacity), 0.1);
  const inputState =
    (capacityPercent >= 100 && 'good') || (inputting && 'average') || 'bad';
  const outputState =
    (outputting && 'good') || (charge > 0 && 'average') || 'bad';
  return (
    <Window width={340} height={350}>
      <Window.Content>
        <Section title={t('ui.smes.stored_energy')}>
          <ProgressBar
            value={capacityPercent * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
        </Section>
        <Section
          title={t('ui.smes.input')}
          buttons={
            <Button
              icon={inputAttempt ? 'sync-alt' : 'times'}
              selected={inputAttempt}
              onClick={() => act('tryinput')}
            >
              {inputAttempt ? t('ui.smes.auto') : t('ui.smes.off')}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.smes.charge_mode')}>
              <Box color={inputState}>
                {(capacityPercent >= 100 && t('ui.smes.fully_charged')) ||
                  (inputting && t('ui.smes.charging')) ||
                  t('ui.smes.not_charging')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.smes.target_input')}>
              <Stack fill>
                <Stack.Item>
                  <Button
                    icon="fast-backward"
                    disabled={inputLevel === 0}
                    onClick={() =>
                      act('input', {
                        target: 'min',
                      })
                    }
                  />
                  <Button
                    icon="backward"
                    disabled={inputLevel === 0}
                    onClick={() =>
                      act('input', {
                        adjust: -10000,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow={1} mx={1}>
                  <Slider
                    value={inputLevel / POWER_MUL}
                    fillValue={inputAvailable / POWER_MUL}
                    minValue={0}
                    maxValue={inputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={(value) => formatPower(value * POWER_MUL, 1)}
                    onChange={(e, value) =>
                      act('input', {
                        target: value * POWER_MUL,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() =>
                      act('input', {
                        adjust: 10000,
                      })
                    }
                  />
                  <Button
                    icon="fast-forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() =>
                      act('input', {
                        target: 'max',
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.smes.available')}>
              {formatPower(inputAvailable)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.smes.output')}
          buttons={
            <Button
              icon={outputAttempt ? 'power-off' : 'times'}
              selected={outputAttempt}
              onClick={() => act('tryoutput')}
            >
              {outputAttempt ? t('ui.smes.on') : t('ui.smes.off')}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.smes.output_mode')}>
              <Box color={outputState}>
                {outputting
                  ? t('ui.smes.sending')
                  : charge > 0
                    ? t('ui.smes.not_sending')
                    : t('ui.smes.no_charge')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.smes.target_output')}>
              <Stack fill>
                <Stack.Item>
                  <Button
                    icon="fast-backward"
                    disabled={outputLevel === 0}
                    onClick={() =>
                      act('output', {
                        target: 'min',
                      })
                    }
                  />
                  <Button
                    icon="backward"
                    disabled={outputLevel === 0}
                    onClick={() =>
                      act('output', {
                        adjust: -10000,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow={1} mx={1}>
                  <Slider
                    value={outputLevel / POWER_MUL}
                    minValue={0}
                    maxValue={outputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={(value) => formatPower(value * POWER_MUL, 1)}
                    onChange={(e, value) =>
                      act('output', {
                        target: value * POWER_MUL,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() =>
                      act('output', {
                        adjust: 10000,
                      })
                    }
                  />
                  <Button
                    icon="fast-forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() =>
                      act('output', {
                        target: 'max',
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.smes.outputting')}>
              {formatPower(outputUsed)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
