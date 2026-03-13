import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

const getMuleByRef = (mules, ref) => {
  return mules?.find((mule) => mule.mule_ref === ref);
};

export const NtosRoboControl = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const { bots, drones, id_owner, droneaccess, dronepingtypes } = data;

  return (
    <NtosWindow width={550} height={550}>
      <NtosWindow.Content scrollable>
        <Section title={t('ui.ntos_robo.robot_control_console')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.ntos_robo.id_card')}>{id_owner}</LabeledList.Item>
            <LabeledList.Item label={t('ui.ntos_robo.bots_in_range')}>
              {data.botcount}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Stack.Item>
          <Tabs>
            <Tabs.Tab
              icon="robot"
              lineHeight="23px"
              selected={tab_main === 1}
              onClick={() => setTab_main(1)}
            >
              {t('ui.ntos_robo.tab_bots')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="hammer"
              lineHeight="23px"
              selected={tab_main === 2}
              onClick={() => setTab_main(2)}
            >
              {t('ui.ntos_robo.tab_drones')}
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        {tab_main === 1 && (
          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item label={t('ui.ntos_robo.bots_in_range')}>
                  {data.botcount}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            {bots?.map((robot) => (
              <RobotInfo key={robot.bot_ref} robot={robot} />
            ))}
          </Stack.Item>
        )}
        {tab_main === 2 && (
          <Stack.Item grow>
            <Section>
              <Button
                icon="address-card"
                tooltip={t('ui.ntos_robo.tooltip_drone_access')}
                color={droneaccess ? 'good' : 'bad'}
                onClick={() => act('changedroneaccess')}
              >
                {droneaccess
                  ? t('ui.ntos_robo.grant_drone_access')
                  : t('ui.ntos_robo.revoke_drone_access')}
              </Button>
              <Box my={1}>{t('ui.ntos_robo.drone_pings')}</Box>
              {dronepingtypes.map((ping_type) => (
                <Button
                  key={ping_type}
                  icon="bullhorn"
                  tooltip={t('ui.ntos_robo.tooltip_issue_drone_ping')}
                  onClick={() => act('ping_drones', { ping_type })}
                >
                  {ping_type}
                </Button>
              ))}
            </Section>
            {drones?.map((drone) => (
              <DroneInfo key={drone.drone_ref} drone={drone} />
            ))}
          </Stack.Item>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const RobotInfo = (props) => {
  const { robot } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const mules = data.mules || [];
  // Get a mule object
  const mule = !!robot.mule_check && getMuleByRef(mules, robot.bot_ref);
  // Color based on type of a robot
  const color =
    robot.mule_check === 1 ? 'rgba(110, 75, 14, 1)' : 'rgba(74, 59, 140, 1)';
  return (
    <Section
      title={robot.name}
      style={{
        border: `4px solid ${color}`,
      }}
      buttons={
        mule && (
          <>
            <Button
              icon="play"
              tooltip={t('ui.ntos_robo.tooltip_go_destination')}
              onClick={() =>
                act('go', {
                  robot: mule.mule_ref,
                })
              }
            />
            <Button
              icon="pause"
              tooltip={t('ui.ntos_robo.tooltip_stop_moving')}
              onClick={() =>
                act('stop', {
                  robot: mule.mule_ref,
                })
              }
            />
            <Button
              icon="home"
              tooltip={t('ui.ntos_robo.tooltip_travel_home')}
              tooltipPosition="bottom-start"
              onClick={() =>
                act('home', {
                  robot: mule.mule_ref,
                })
              }
            />
          </>
        )
      }
    >
      <Stack>
        <Stack.Item grow={1} basis={0}>
          <LabeledList>
            <LabeledList.Item label={t('ui.ntos_robo.model')}>{robot.model}</LabeledList.Item>
            <LabeledList.Item label={t('ui.ntos_robo.location')}>{robot.locat}</LabeledList.Item>
            <LabeledList.Item label={t('ui.ntos_robo.status')}>{robot.mode}</LabeledList.Item>
            {mule && (
              <>
                <LabeledList.Item label={t('ui.ntos_robo.bot_id')}>{mule.id}</LabeledList.Item>
                <LabeledList.Item label={t('ui.ntos_robo.loaded_cargo')}>
                  {mule.load || t('ui.common.not_available')}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.ntos_robo.home')}>{mule.home}</LabeledList.Item>
                <LabeledList.Item label={t('ui.ntos_robo.destination')}>
                  {mule.dest || t('ui.common.not_available')}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.ntos_robo.power')}>
                  <ProgressBar
                    value={mule.power}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      good: [60, Infinity],
                      average: [20, 60],
                      bad: [-Infinity, 20],
                    }}
                  />
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Stack.Item>
        <Stack.Item width="150px">
          {mule && (
            <>
              <Button
                fluid
                content={t('ui.ntos_robo.set_destination')}
                onClick={() =>
                  act('destination', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.set_id')}
                onClick={() =>
                  act('setid', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.set_home')}
                onClick={() =>
                  act('sethome', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.unload_cargo')}
                onClick={() =>
                  act('unload', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button.Checkbox
                fluid
                content={t('ui.ntos_robo.auto_return')}
                checked={mule.autoReturn}
                onClick={() =>
                  act('autoret', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button.Checkbox
                fluid
                content={t('ui.ntos_robo.auto_pickup')}
                checked={mule.autoPickup}
                onClick={() =>
                  act('autopick', {
                    robot: mule.mule_ref,
                  })
                }
              />
              <Button.Checkbox
                fluid
                content={t('ui.ntos_robo.delivery_report')}
                checked={mule.reportDelivery}
                onClick={() =>
                  act('report', {
                    robot: mule.mule_ref,
                  })
                }
              />
            </>
          )}
          {!mule && (
            <>
              <Button
                fluid
                content={t('ui.ntos_robo.stop_patrol')}
                onClick={() =>
                  act('patroloff', {
                    robot: robot.bot_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.start_patrol')}
                onClick={() =>
                  act('patrolon', {
                    robot: robot.bot_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.summon')}
                onClick={() =>
                  act('summon', {
                    robot: robot.bot_ref,
                  })
                }
              />
              <Button
                fluid
                content={t('ui.ntos_robo.eject_pai')}
                onClick={() =>
                  act('ejectpai', {
                    robot: robot.bot_ref,
                  })
                }
              />
            </>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const DroneInfo = (props) => {
  const { drone } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const color = 'rgba(74, 59, 140, 1)';

  return (
    <Section
      title={drone.name}
      style={{
        border: `4px solid ${color}`,
      }}
    >
      <Stack>
        <Stack.Item grow={1} basis={0}>
          <LabeledList>
            <LabeledList.Item label={t('ui.ntos_robo.status')}>
              <Box color={drone.status ? 'bad' : 'good'}>
                {drone.status
                  ? t('ui.ntos_robo.not_responding')
                  : t('ui.ntos_robo.nominal')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
