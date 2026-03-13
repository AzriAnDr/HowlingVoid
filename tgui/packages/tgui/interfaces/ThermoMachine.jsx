import {
  AnimatedNumber,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ThermoMachine = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window width={300} height={350}>
      <Window.Content>
        <Section title={t('ui.thermo_machine.status')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.thermo_machine.temperature')}>
              <AnimatedNumber
                value={data.temperature}
                format={(value) => toFixed(value, 2)}
              />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.thermo_machine.pressure')}>
              <AnimatedNumber
                value={data.pressure}
                format={(value) => toFixed(value, 2)}
              />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.thermo_machine.controls')}
          buttons={
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? t('ui.thermo_machine.on') : t('ui.thermo_machine.off')}
              selected={data.on}
              onClick={() => act('power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.thermo_machine.target_temperature')}>
              <NumberInput
                animated
                tickWhileDragging
                value={Math.round(data.target)}
                unit="K"
                width="62px"
                minValue={Math.round(data.min)}
                maxValue={Math.round(data.max)}
                step={5}
                stepPixelSize={3}
                onChange={(value) =>
                  act('target', {
                    target: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.thermo_machine.presets')}>
              <Button
                icon="fast-backward"
                disabled={data.target === data.min}
                title={t('ui.thermo_machine.minimum_temperature')}
                onClick={() =>
                  act('target', {
                    target: data.min,
                  })
                }
              />
              <Button
                icon="sync"
                disabled={data.target === data.initial}
                title={t('ui.thermo_machine.room_temperature')}
                onClick={() =>
                  act('target', {
                    target: data.initial,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.target === data.max}
                title={t('ui.thermo_machine.maximum_temperature')}
                onClick={() =>
                  act('target', {
                    target: data.max,
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
