import { LabeledList, NumberInput } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  chem_temp: number;
  target_temperature: number;
  max_volume: number;
  acclimate_state: string;
};

export const ChemAcclimator = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { chem_temp, target_temperature, max_volume, acclimate_state } = data;
  const states = [
    t('ui.chem_acclimator.filling'),
    t('ui.chem_acclimator.heating'),
    t('ui.chem_acclimator.cooling'),
    t('ui.chem_acclimator.emptying'),
  ] as const;

  return (
    <Window width={320} height={130}>
      <Window.Content>
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
          <LabeledList.Item label={t('ui.chem_acclimator.buffer')}>
            <NumberInput
              value={max_volume}
              unit="u"
              width="50px"
              minValue={1}
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
          <LabeledList.Item label={t('ui.chem_acclimator.current_state')}>
            {states[acclimate_state] || acclimate_state}
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
