import { Button, NumberInput, Section, Stack } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  code: number;
  frequency: number;
  cooldown: number;
  minFrequency: number;
  maxFrequency: number;
};

export const Signaler = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={280} height={128}>
      <Window.Content>
        <SignalerContent />
      </Window.Content>
    </Window>
  );
};

export const SignalerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { code, frequency, cooldown, minFrequency, maxFrequency } = data;

  return (
    <Section>
      <Stack>
        <Stack.Item color="label">{t('ui.signaler.frequency')}:</Stack.Item>
        <Stack.Item>
          <NumberInput
            animated
            tickWhileDragging
            unit="kHz"
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={(value) => toFixed(value, 1)}
            width="80px"
            onChange={(value) =>
              act('freq', {
                freq: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={1.3}
            icon="sync"
            content={t('ui.common.reset')}
            onClick={() =>
              act('reset', {
                reset: 'freq',
              })
            }
          />
        </Stack.Item>
      </Stack>
      <Stack mt={0.6}>
        <Stack.Item pr={5.3} color="label">
          {t('ui.signaler.code')}:
        </Stack.Item>
        <Stack.Item>
          <NumberInput
            animated
            tickWhileDragging
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width="80px"
            onChange={(value) =>
              act('code', {
                code: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={1.3}
            icon="sync"
            content={t('ui.common.reset')}
            onClick={() =>
              act('reset', {
                reset: 'code',
              })
            }
          />
        </Stack.Item>
      </Stack>
      <Stack mt={0.8}>
        <Stack.Item ml={10.5}>
          <Button
            mb={-0.1}
            fluid
            tooltip={
              cooldown &&
              `${t('ui.signaler.cooldown')}: ${cooldown * 0.1} ${t('ui.common.seconds_lower')}`
            }
            icon="arrow-up"
            content={t('ui.signaler.send_signal')}
            textAlign="center"
            onClick={() => act('signal')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
