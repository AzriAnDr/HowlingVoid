import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { formatEnergy } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const MechBayPowerConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { recharge_port } = data;
  const mech = recharge_port?.mech;
  const cell = mech?.cell;
  return (
    <Window width={400} height={200}>
      <Window.Content>
        <Section
          title={t('ui.mech_bay_power_console.mech_status')}
          textAlign="center"
          buttons={
            <Button
              icon="sync"
              content={t('ui.common.sync')}
              onClick={() => act('reconnect')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.integrity')}>
              {(!recharge_port && (
                <NoticeBox>
                  {t('ui.mech_bay_power_console.no_power_port_detected')}
                </NoticeBox>
              )) ||
                (!mech && <NoticeBox>{t('ui.mech_bay_power_console.no_mech_detected')}</NoticeBox>) || (
                  <ProgressBar
                    value={mech.health / mech.maxhealth}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  />
                )}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.power')}>
              {(!recharge_port && (
                <NoticeBox>
                  {t('ui.mech_bay_power_console.no_power_port_detected')}
                </NoticeBox>
              )) ||
                (!mech && <NoticeBox>{t('ui.mech_bay_power_console.no_mech_detected')}</NoticeBox>) ||
                (!cell && <NoticeBox>{t('ui.mech_bay_power_console.no_cell_installed')}</NoticeBox>) || (
                  <ProgressBar
                    value={cell.charge / cell.maxcharge}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  >
                    {formatEnergy(cell.charge) +
                      '/' +
                      formatEnergy(cell.maxcharge)}
                  </ProgressBar>
                )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
