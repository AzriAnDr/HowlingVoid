import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const RoboticsControlConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const [tab, setTab] = useSharedState('tab', 1);
  const { can_hack, can_detonate, cyborgs = [], drones = [] } = data;

  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}
          >
            {t('ui.robotics_control.cyborgs')} ({cyborgs.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}
          >
            {t('ui.robotics_control.drones')} ({drones.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Cyborgs
            cyborgs={cyborgs}
            can_hack={can_hack}
            can_detonate={can_detonate}
          />
        )}
        {tab === 2 && <Drones drones={drones} />}
      </Window.Content>
    </Window>
  );
};

const Cyborgs = (props) => {
  const { cyborgs, can_hack, can_detonate } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  if (!cyborgs.length) {
    return <NoticeBox>{t('ui.robotics_control.no_cyborg_units')}</NoticeBox>;
  }
  return cyborgs.map((cyborg) => {
    return (
      <Section
        key={cyborg.ref}
        title={cyborg.name}
        buttons={
          <>
            {!!can_hack && !cyborg.emagged && (
              <Button
                icon="terminal"
                content={t('ui.common.hack')}
                color="bad"
                onClick={() =>
                  act('magbot', {
                    ref: cyborg.ref,
                  })
                }
              />
            )}
            <Button.Confirm
              icon={cyborg.locked_down ? 'unlock' : 'lock'}
              color={cyborg.locked_down ? 'good' : 'default'}
              content={
                cyborg.locked_down
                  ? t('ui.common.release')
                  : t('ui.robotics_control.lockdown')
              }
              onClick={() =>
                act('stopbot', {
                  ref: cyborg.ref,
                })
              }
            />
            {!!can_detonate && (
              <Button.Confirm
                icon="bomb"
                content={t('ui.robotics_control.detonate')}
                color="bad"
                onClick={() =>
                  act('killbot', {
                    ref: cyborg.ref,
                  })
                }
              />
            )}
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.common.status')}>
            <Box
              color={
                cyborg.status ? 'bad' : cyborg.locked_down ? 'average' : 'good'
              }
            >
              {cyborg.status
                ? t('ui.robotics_control.not_responding')
                : cyborg.locked_down
                  ? t('ui.robotics_control.locked_down')
                  : t('ui.robotics_control.nominal')}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.charge')}>
            <Box
              color={
                cyborg.charge <= 30
                  ? 'bad'
                  : cyborg.charge <= 70
                    ? 'average'
                    : 'good'
              }
            >
              {typeof cyborg.charge === 'number'
                ? `${cyborg.charge}%`
                : t('ui.common.not_found')}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.model')}>
            {cyborg.module}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.robotics_control.master_ai')}>
            <Box color={cyborg.synchronization ? 'default' : 'average'}>
              {cyborg.synchronization || t('ui.common.none')}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};

const Drones = (props) => {
  const { drones } = props;
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();

  if (!drones.length) {
    return <NoticeBox>{t('ui.robotics_control.no_drone_units')}</NoticeBox>;
  }

  return drones.map((drone) => {
    return (
      <Section
        key={drone.ref}
        title={drone.name}
        buttons={
          <Button.Confirm
            icon="bomb"
            content={t('ui.robotics_control.detonate')}
            color="bad"
            onClick={() =>
              act('killdrone', {
                ref: drone.ref,
              })
            }
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.common.status')}>
            <Box color={drone.status ? 'bad' : 'good'}>
              {drone.status
                ? t('ui.robotics_control.not_responding')
                : t('ui.robotics_control.nominal')}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
