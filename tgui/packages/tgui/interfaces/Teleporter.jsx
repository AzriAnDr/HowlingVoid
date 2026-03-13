import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Teleporter = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    calibrated,
    calibrating,
    power_station,
    regime_set,
    teleporter_hub,
    target,
  } = data;
  return (
    <Window width={360} height={130}>
      <Window.Content>
        <Section>
          {(!power_station && (
            <Box color="bad" textAlign="center">
              {t('ui.teleporter.no_power_station_linked')}
            </Box>
          )) ||
            (!teleporter_hub && (
              <Box color="bad" textAlign="center">
                {t('ui.teleporter.no_hub_linked')}
              </Box>
            )) || (
              <LabeledList>
                <LabeledList.Item label={t('ui.teleporter.regime')}>
                  <Button
                    content={regime_set}
                    onClick={() => act('regimeset')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.common.target')}>
                  <Button
                    icon="edit"
                    content={target}
                    onClick={() => act('settarget')}
                  />
                </LabeledList.Item>
                <LabeledList.Item
                  label={t('ui.teleporter.calibration')}
                  buttons={
                    <Button
                      icon="tools"
                      content={t('ui.teleporter.calibrate')}
                      onClick={() => act('calibrate')}
                    />
                  }
                >
                  {(calibrating && (
                    <Box color="average">{t('ui.teleporter.in_progress')}</Box>
                  )) ||
                    (calibrated && (
                      <Box color="good">{t('ui.teleporter.optimal')}</Box>
                    )) || (
                      <Box color="bad">{t('ui.teleporter.sub_optimal')}</Box>
                    )}
                </LabeledList.Item>
              </LabeledList>
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};
