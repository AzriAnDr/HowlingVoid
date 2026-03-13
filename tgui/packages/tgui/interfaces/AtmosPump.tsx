import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  on: BooleanLike;
  max_rate: number;
  rate: number;
  pressure: number;
  max_pressure: number;
};

export const AtmosPump = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { on, max_rate, max_pressure, rate, pressure } = data;

  return (
    <Window width={335} height={115}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.power')}>
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? t('ui.common.on') : t('ui.common.off')}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            {max_rate ? (
              <LabeledList.Item label={t('ui.atmos_pump.transfer_rate')}>
                <NumberInput
                  animated
                  value={rate}
                  step={1}
                  width="63px"
                  unit="L/s"
                  minValue={0}
                  maxValue={max_rate}
                  onChange={(value) =>
                    act('rate', {
                      rate: value,
                    })
                  }
                />
                <Button
                  ml={1}
                  icon="plus"
                  content={t('ui.atmos_pump.max')}
                  disabled={rate === max_rate}
                  onClick={() =>
                    act('rate', {
                      rate: 'max',
                    })
                  }
                />
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label={t('ui.atmos_pump.output_pressure')}>
                <NumberInput
                  animated
                  value={pressure}
                  unit="kPa"
                  width="75px"
                  minValue={0}
                  maxValue={max_pressure}
                  step={10}
                  onChange={(value) =>
                    act('pressure', {
                      pressure: value,
                    })
                  }
                />
                <Button
                  ml={1}
                  icon="plus"
                  content={t('ui.atmos_pump.max')}
                  disabled={pressure === max_pressure}
                  onClick={() =>
                    act('pressure', {
                      pressure: 'max',
                    })
                  }
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
