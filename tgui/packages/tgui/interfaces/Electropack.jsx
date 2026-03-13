import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Electropack = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const { power, code, frequency, minFrequency, maxFrequency } = data;
  return (
    <Window width={260} height={137}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.power')}>
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? t('ui.common.on') : t('ui.common.off')}
                selected={power}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.electropack.frequency')}
              buttons={
                <Button
                  icon="sync"
                  content={t('ui.common.reset')}
                  onClick={() =>
                    act('reset', {
                      reset: 'freq',
                    })
                  }
                />
              }
            >
              <NumberInput
                animate
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
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.common.code')}
              buttons={
                <Button
                  icon="sync"
                  content={t('ui.common.reset')}
                  onClick={() =>
                    act('reset', {
                      reset: 'code',
                    })
                  }
                />
              }
            >
              <NumberInput
                animate
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
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
