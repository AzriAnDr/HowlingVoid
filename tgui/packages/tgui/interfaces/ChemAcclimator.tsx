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
  chem_temp: number;
  target_temperature: number;
  allowed_temperature_difference: number;
  enabled: BooleanLike;
  max_volume: number;
  reagent_volume: number;
  acclimate_state: string;
  emptying: BooleanLike;
};

export const ChemAcclimator = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    chem_temp,
    target_temperature,
    allowed_temperature_difference,
    enabled,
    max_volume,
    reagent_volume,
    acclimate_state,
    emptying,
  } = data;

  return (
    <Window width={320} height={271}>
      <Window.Content>
        <Section title={t('ui.chem_acclimator.acclimator')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.chem_acclimator.current_temperature')}>
              {chem_temp} K
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.chem_acclimator.target_temperature')}>
              <NumberInput
                value={target_temperature}
                unit="K"
                width="59px"
                minValue={0}
                maxValue={1000}
                step={5}
                stepPixelSize={2}
                onChange={(value) =>
                  act('set_target_temperature', {
                    temperature: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.chem_acclimator.acceptable_temp_difference')}
            >
              <NumberInput
                step={1}
                value={allowed_temperature_difference}
                unit="K"
                width="59px"
                minValue={1}
                maxValue={target_temperature}
                stepPixelSize={2}
                onChange={(value) => {
                  act('set_allowed_temperature_difference', {
                    temperature: value,
                  });
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.common.status')}
          buttons={
            <Button
              icon="power-off"
              content={enabled ? t('ui.common.on') : t('ui.common.off')}
              selected={enabled}
              onClick={() => act('toggle_power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.volume')}>
              <NumberInput
                value={max_volume}
                unit="u"
                width="50px"
                minValue={reagent_volume}
                maxValue={200}
                step={2}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_volume', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.chem_acclimator.current_operation')}>
              {acclimate_state}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.chem_acclimator.current_state')}>
              {emptying
                ? t('ui.chem_acclimator.emptying')
                : t('ui.chem_acclimator.filling')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
