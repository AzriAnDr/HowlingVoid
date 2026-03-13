import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const MassDriverControl = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { connected, minutes, seconds, timing, power, poddoor } = data;
  return (
    <Window width={300} height={connected ? 215 : 107}>
      <Window.Content>
        {!!connected && (
          <Section
            title={t('ui.mass_driver.auto_launch')}
            buttons={
              <Button
                icon={'clock-o'}
                content={timing ? t('ui.common.stop') : t('ui.common.start')}
                selected={timing}
                onClick={() => act('time')}
              />
            }
          >
            <Button
              icon="fast-backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -30 })}
            />
            <Button
              icon="backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -1 })}
            />{' '}
            {String(minutes).padStart(2, '0')}:
            {String(seconds).padStart(2, '0')}{' '}
            <Button
              icon="forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 1 })}
            />
            <Button
              icon="fast-forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 30 })}
            />
          </Section>
        )}
        <Section
          title={t('ui.common.controls')}
          buttons={
            <Button
              icon={'toggle-on'}
              content={t('ui.mass_driver.toggle_outer_door')}
              disabled={timing || !poddoor}
              onClick={() => act('door')}
            />
          }
        >
          {(!!connected && (
            <>
              <LabeledList>
                <LabeledList.Item
                  label={t('ui.mass_driver.power_level')}
                  buttons={
                    <Button
                      icon={'bomb'}
                      content={t('ui.mass_driver.test_fire')}
                      disabled={timing}
                      onClick={() => act('driver_test')}
                    />
                  }
                >
                  <NumberInput
                    value={power}
                    width="40px"
                    step={1}
                    minValue={0.25}
                    maxValue={16}
                    onChange={(value) => {
                      return act('set_power', {
                        power: value,
                      });
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
              <Button
                fluid
                content={t('ui.mass_driver.launch')}
                disabled={timing}
                mt={1.5}
                icon="arrow-up"
                textAlign="center"
                onClick={() => act('launch')}
              />
            </>
          )) || <Box color="bad">{t('ui.mass_driver.no_connected_mass_driver')}</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};
