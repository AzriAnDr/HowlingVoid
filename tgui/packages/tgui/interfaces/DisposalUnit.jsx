import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const DisposalUnit = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  let stateColor;
  let stateText;
  if (data.full_pressure) {
    stateColor = 'good';
    stateText = t('ui.disposal_unit.ready');
  } else if (data.panel_open) {
    stateColor = 'bad';
    stateText = t('ui.disposal_unit.power_disabled');
  } else if (data.pressure_charging) {
    stateColor = 'average';
    stateText = t('ui.disposal_unit.pressurizing');
  } else {
    stateColor = 'bad';
    stateText = t('ui.common.off');
  }
  return (
    <Window width={300} height={180}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.state')} color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.disposal_unit.pressure')}>
              <ProgressBar value={data.per} color="good" />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.disposal_unit.handle')}>
              <Button
                icon={data.flush ? 'toggle-on' : 'toggle-off'}
                disabled={data.isai || data.panel_open}
                content={
                  data.flush
                    ? t('ui.disposal_unit.disengage')
                    : t('ui.disposal_unit.engage')
                }
                onClick={() => act(data.flush ? 'handle-0' : 'handle-1')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.eject')}>
              <Button
                icon="sign-out-alt"
                disabled={data.isai}
                content={t('ui.disposal_unit.eject_contents')}
                onClick={() => act('eject')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.power')}>
              <Button
                icon="power-off"
                disabled={data.panel_open}
                selected={data.pressure_charging}
                onClick={() =>
                  act(data.pressure_charging ? 'pump-0' : 'pump-1')
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
