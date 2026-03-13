import { map } from 'es-toolkit/compat';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type RadioData = {
  freqlock: BooleanLike;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  listening: BooleanLike;
  broadcasting: BooleanLike;
  command: BooleanLike;
  useCommand: BooleanLike;
  subspace: BooleanLike;
  subspaceSwitchable: BooleanLike;
  channels: Record<string, BooleanLike>;
  radio_noises: number;
};

export const Radio = (props) => {
  const { act, data } = useBackend<RadioData>();
  const { t } = usePreferencesLocalization(data);
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
    radio_noises,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency,
  );
  const channels = map(data.channels, (value, key) => ({
    name: key,
    status: !!value,
  }));
  // Calculate window height
  let height = 133;
  if (channels.length > 0) {
    height += channels.length * 25 + 8;
  } else if (subspace) {
    height += 24;
  }
  return (
    <Window width={380} height={height}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.radio.frequency')}>
              {(freqlock && (
                <Box inline color="light-gray">
                  {`${toFixed(frequency / 10, 1)} kHz`}
                </Box>
              )) || (
                <NumberInput
                  animated
                  tickWhileDragging
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={10}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={(value) => toFixed(value, 1)}
                  onChange={(value) =>
                    act('frequency', {
                      adjust: value - frequency / 10,
                    })
                  }
                />
              )}
              {tunedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.radio.audio')}>
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                onClick={() => act('broadcast')}
              />
              {!!command && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={useCommand}
                  content={`${t('ui.radio.high_volume')} ${useCommand ? t('ui.common.on') : t('ui.common.off')}`}
                  onClick={() => act('command')}
                />
              )}
              {!!subspaceSwitchable && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={subspace}
                  content={`${t('ui.radio.subspace_tx')} ${subspace ? t('ui.common.on') : t('ui.common.off')}`}
                  onClick={() => act('subspace')}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.radio.radio_noise_volume')}>
              <Slider
                onChange={(e, value) => {
                  act('set_radio_volume', {
                    volume: value,
                  });
                }}
                minValue={0}
                maxValue={100}
                step={1}
                value={radio_noises}
                stepPixelSize={10}
              />
            </LabeledList.Item>
            {(!!subspace || channels.length > 0) && (
              <LabeledList.Item label={t('ui.radio.channels')}>
                {channels.length === 0 && (
                  <Box inline color="bad">
                    {t('ui.radio.no_encryption_keys_installed')}
                  </Box>
                )}
                <Stack vertical>
                  {channels.map((channel) => (
                    <Box key={channel.name}>
                      <Button
                        icon={channel.status ? 'check-square-o' : 'square-o'}
                        selected={channel.status}
                        content={channel.name}
                        onClick={() =>
                          act('channel', {
                            channel: channel.name,
                          })
                        }
                      />
                      {!subspace && !freqlock && (
                        <Button
                          icon="walkie-talkie"
                          ml={1}
                          disabled={
                            RADIO_CHANNELS.find((c) => c.name === channel.name)
                              ?.freq === frequency
                          }
                          onClick={() =>
                            act('tune_to_channel', {
                              channel: channel.name,
                            })
                          }
                        >
                          {t('ui.radio.tune')}
                        </Button>
                      )}
                    </Box>
                  ))}
                </Stack>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
