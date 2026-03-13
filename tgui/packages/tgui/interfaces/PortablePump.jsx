import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';
import { usePreferencesLocalization } from './localization';

export const PortablePump = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    direction,
    connected,
    holding,
    targetPressure,
    defaultPressure,
    minPressure,
    maxPressure,
  } = data;
  const pump_or_port = connected
    ? t('ui.portablepump.port')
    : t('ui.portablepump.pump');
  const area_or_tank = holding
    ? t('ui.portablepump.tank')
    : t('ui.portablepump.area');
  return (
    <Window width={300} height={340}>
      <Window.Content>
        <PortableBasicInfo />
        <Section
          title={t('ui.portablepump.pumping')}
          buttons={
            <Button
              content={
                direction
                  ? `${area_or_tank} → ${pump_or_port}`
                  : `${pump_or_port} → ${area_or_tank}`
              }
              color={!direction && !holding ? 'caution' : null}
              onClick={() => act('direction')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.portablepump.output')}>
              <NumberInput
                value={targetPressure}
                unit="kPa"
                width="75px"
                minValue={minPressure}
                maxValue={maxPressure}
                step={10}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.portablepump.presets')}>
              <Button
                icon="minus"
                disabled={targetPressure === minPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <Button
                icon="sync"
                disabled={targetPressure === defaultPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
              <Button
                icon="plus"
                disabled={targetPressure === maxPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
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
