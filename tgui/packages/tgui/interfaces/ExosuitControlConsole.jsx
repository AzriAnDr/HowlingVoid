import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ExosuitControlConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { mechs = [] } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        {mechs.length === 0 && (
          <NoticeBox>{t('ui.exosuit_control_console.no_exosuits_detected')}</NoticeBox>
        )}
        {mechs.map((mech) => (
          <Section
            key={mech.tracker_ref}
            title={mech.name}
            buttons={
              <>
                <Button
                  icon="envelope"
                  content={t('ui.common.message')}
                  disabled={!mech.pilot}
                  onClick={() =>
                    act('send_message', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                />
                <Button
                  icon="wifi"
                  content={
                    mech.emp_recharging
                      ? t('ui.common.recharging')
                      : t('ui.exosuit_control_console.emp_burst')
                  }
                  color="bad"
                  disabled={mech.emp_recharging}
                  onClick={() =>
                    act('shock', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                />
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item label={t('ui.common.integrity')}>
                <Box
                  color={
                    (mech.integrity <= 30 && 'bad') ||
                    (mech.integrity <= 70 && 'average') ||
                    'good'
                  }
                >
                  {mech.integrity}%
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.common.charge')}>
                <Box
                  color={
                    (mech.charge <= 30 && 'bad') ||
                    (mech.charge <= 70 && 'average') ||
                    'good'
                  }
                >
                  {(typeof mech.charge === 'number' && `${mech.charge}%`) ||
                    t('ui.common.not_found')}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.exosuit_control_console.airtank')}>
                {(typeof mech.airtank === 'number' && (
                  <AnimatedNumber
                    value={mech.airtank}
                    format={(value) => `${toFixed(value, 2)} kPa`}
                  />
                )) ||
                  t('ui.exosuit_control_console.not_equipped')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.common.pilot')}>
                {(mech.pilot.length > 0 &&
                  mech.pilot.map((pilot) => (
                    <Box key={pilot} inline>
                      {pilot}
                      {mech.pilot.length > 1 ? '|' : ''}
                    </Box>
                  ))) ||
                  t('ui.common.none')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.common.location')}>
                {mech.location || t('ui.common.unknown')}
              </LabeledList.Item>
              {mech.cargo_space >= 0 && (
                <LabeledList.Item
                  label={t('ui.exosuit_control_console.used_cargo_space')}
                >
                  <Box
                    color={
                      (mech.cargo_space <= 30 && 'good') ||
                      (mech.cargo_space <= 70 && 'average') ||
                      'bad'
                    }
                  >
                    {mech.cargo_space}%
                  </Box>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
