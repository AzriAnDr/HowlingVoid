import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { formatEnergy } from 'tgui-core/format';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosRobotact = (props) => {
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <NtosRobotactContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosRobotactContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [tab_main, setTab_main] = useState(1);
  const [tab_sub, setTab_sub] = useState(1);
  const {
    charge,
    maxcharge,
    integrity,
    lampIntensity,
    lampConsumption,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
    sensors,
    printerPictures,
    printerToner,
    printerTonerMax,
    thrustersInstalled,
    thrustersStatus,
    selfDestructAble,
    cyborg_groups = [],
    masterAI_online,
    MasterAI_connected,
  } = data;
  const borgName = data.borgName || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
  const borgUpgrades = data.borgUpgrades || [];

  return (
    <Flex direction={'column'}>
      <Flex.Item position="relative" mb={1}>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}
          >
            {t('ui.ntos_robotact.tab_status')}
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}
          >
            {t('ui.ntos_robotact.tab_logs')}
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 3}
            onClick={() => setTab_main(3)}
          >
            {t('ui.ntos_robotact.tab_network')}
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      {tab_main === 1 && (
        <>
          <Flex direction={'row'}>
            <Flex.Item width="30%">
              <Section title={t('ui.ntos_robotact.configuration')} fill>
                <LabeledList>
                  <LabeledList.Item label={t('ui.ntos_robotact.unit')}>
                    {borgName.slice(0, 17)}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.common.type')}>{borgType}</LabeledList.Item>
                  <LabeledList.Item label={t('ui.ntos_robotact.ai')}>
                    {masterAI.slice(0, 17)}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} basis="content" ml={1}>
              <Section title={t('ui.common.status')}>
                {t('ui.ntos_robotact.charge')}:
                <Button
                  content={t('ui.ntos_robotact.power_alert')}
                  disabled={charge}
                  onClick={() => act('alertPower')}
                />
                <ProgressBar
                  value={charge / maxcharge}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.1, 0.5],
                    bad: [-Infinity, 0.1],
                  }}
                >
                  <AnimatedNumber
                    value={charge}
                    format={(charge) => formatEnergy(charge)}
                  />
                </ProgressBar>
                {t('ui.ntos_robotact.chassis_integrity')}:
                <ProgressBar
                  value={integrity}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    bad: [-Infinity, 25],
                    average: [25, 75],
                    good: [75, Infinity],
                  }}
                />
              </Section>
              <Section title={t('ui.ntos_robotact.lamp_power')}>
                <Slider
                  value={lampIntensity}
                  step={1}
                  stepPixelSize={25}
                  maxValue={5}
                  minValue={1}
                  onChange={(e, value) =>
                    act('lampIntensity', {
                      ref: value,
                    })
                  }
                />
                {t('ui.ntos_robotact.lamp_power_usage')}:{' '}
                {formatPower(lampIntensity * lampConsumption)}
              </Section>
            </Flex.Item>
            <Flex.Item width="50%" ml={1}>
              <Section fitted>
                <Tabs fluid={1} textAlign="center">
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 1}
                    onClick={() => setTab_sub(1)}
                  >
                    {t('ui.common.actions')}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 2}
                    onClick={() => setTab_sub(2)}
                  >
                    {t('ui.ntos_robotact.upgrades')}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 3}
                    onClick={() => setTab_sub(3)}
                  >
                    {t('ui.ntos_robotact.diagnostics')}
                  </Tabs.Tab>
                </Tabs>
              </Section>
              {tab_sub === 1 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.ntos_robotact.maintenance_cover')}>
                      <Button.Confirm
                        content={t('ui.ntos_robotact.unlock')}
                        disabled={cover === 'UNLOCKED'}
                        onClick={() => act('coverunlock')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label={t('ui.ntos_robotact.sensor_overlay')}>
                      <Button
                        content={sensors}
                        onClick={() => act('toggleSensors')}
                      />
                    </LabeledList.Item>
                    {/* NOVA EDIT ADDITION START */}
                    <LabeledList.Item label={t('ui.ntos_robotact.camera_status')}>
                      <Button
                        content={wireCamera}
                        onClick={() => act('cameraToggle')}
                      />
                    </LabeledList.Item>
                    {/* NOVA EDIT ADDITION END */}
                    <LabeledList.Item
                      label={`Stored Photos (${printerPictures})`}
                    >
                      <Button
                        content={t('ui.ntos_robotact.view')}
                        disabled={!printerPictures}
                        onClick={() => act('viewImage')}
                      />
                      <Button
                        content={t('ui.common.print')}
                        disabled={!printerPictures}
                        onClick={() => act('printImage')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label={t('ui.ntos_robotact.printer_toner')}>
                      <ProgressBar value={printerToner / printerTonerMax} />
                    </LabeledList.Item>
                    {!!thrustersInstalled && (
                      <LabeledList.Item label={t('ui.ntos_robotact.toggle_thrusters')}>
                        <Button
                          content={thrustersStatus}
                          onClick={() => act('toggleThrusters')}
                        />
                      </LabeledList.Item>
                    )}
                    {!!selfDestructAble && (
                      <LabeledList.Item label={t('ui.ntos_robotact.self_destruct')}>
                        <Button.Confirm
                          content={t('ui.ntos_robotact.activate')}
                          color="red"
                          onClick={() => act('selfDestruct')}
                        />
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              )}
              {tab_sub === 2 && (
                <Section>
                  {borgUpgrades.map((upgrade) => (
                    <Box mb={1} key={upgrade}>
                      {upgrade}
                    </Box>
                  ))}
                </Section>
              )}
              {tab_sub === 3 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.ai_connection')}
                      color={
                        wireAI === 'FAULT'
                          ? 'red'
                          : wireAI === 'READY'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {wireAI}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.lawsync')}
                      color={wireLaw === 'FAULT' ? 'red' : 'green'}
                    >
                      {wireLaw}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.camera')}
                      color={
                        wireCamera === 'FAULT'
                          ? 'red'
                          : wireCamera === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {wireCamera}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.module_controller')}
                      color={wireModule === 'FAULT' ? 'red' : 'green'}
                    >
                      {wireModule}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.motor_controller')}
                      color={
                        locomotion === 'FAULT'
                          ? 'red'
                          : locomotion === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {locomotion}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.ntos_robotact.maintenance_cover')}
                      color={cover === 'UNLOCKED' ? 'red' : 'green'}
                    >
                      {cover}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              )}
            </Flex.Item>
          </Flex>
          <Flex.Item height={21} mt={1}>
            <Section
              title={t('ui.common.laws')}
              fill
              scrollable
              buttons={
                <>
                  <Button
                    content={t('ui.ntos_robotact.state_laws')}
                    onClick={() => act('lawstate')}
                  />
                  <Button icon="volume-off" onClick={() => act('lawchannel')} />
                </>
              }
            >
              {laws.map((law) => (
                <Box mb={1} key={law}>
                  {law}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </>
      )}
      {tab_main === 2 && (
        <Flex.Item height={40}>
          <Section fill scrollable backgroundColor="black">
            {borgLog.map((log) => (
              <Box mb={1} key={log}>
                <font color="green">{log}</font>
              </Box>
            ))}
          </Section>
        </Flex.Item>
      )}
      {tab_main === 3 && (
        <Flex.Item height={40}>
          <Section
            title={MasterAI_connected ? masterAI : t('ui.ntos_robotact.not_configured')}
            textAlign="center"
          >
            <LabeledList>
              <LabeledList.Item label={t('ui.common.status')}>
                <Box color={masterAI_online ? 'good' : 'bad'}>
                  {!MasterAI_connected
                    ? t('ui.ntos_robotact.no_connection')
                    : masterAI_online
                      ? t('ui.ntos_robotact.online')
                      : t('ui.ntos_robotact.unresponsive')}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Stack vertical>
            {cyborg_groups.map((borggroup, cyborgindex) => (
              <Stack.Item key={cyborgindex}>
                <Stack>
                  {borggroup.map((cyborg, borgindex) => (
                    <Stack.Item key={borgindex} width="24.25%">
                      <Section
                        key={cyborg.ref}
                        title={cyborg.otherBorgName.slice(0, 20)}
                      >
                        <LabeledList>
                          <LabeledList.Item label={t('ui.common.status')}>
                            <Box
                              color={
                                cyborg.status
                                  ? 'bad'
                                  : cyborg.locked_down
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {cyborg.status
                                ? t('ui.ntos_robotact.not_responding')
                                : cyborg.locked_down
                                  ? t('ui.ntos_robotact.locked_down')
                                  : cyborg.shell_discon
                                    ? t('ui.ntos_robotact.nominal_disconnected')
                                    : t('ui.ntos_robotact.nominal')}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.ntos_robotact.condition')}>
                            <Box
                              color={
                                cyborg.integ <= 25
                                  ? 'bad'
                                  : cyborg.integ <= 75
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {cyborg.integ === 0
                                ? t('ui.ntos_robotact.hard_fault')
                                : cyborg.integ <= 25
                                  ? t('ui.ntos_robotact.functionality_disrupted')
                                  : cyborg.integ <= 75
                                    ? t('ui.ntos_robotact.functionality_impaired')
                                    : t('ui.ntos_robotact.operational')}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.ntos_robotact.charge')}>
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
                                : t('ui.ntos_robotact.no_cell')}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label={t('ui.ntos_robotact.model')}>
                            {cyborg.module}
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
                <Stack.Divider />
              </Stack.Item>
            ))}
          </Stack>

          {!cyborg_groups.length && (
            <NoticeBox textAlign="center" top="30%" position="relative">
              <Box fontSize={2}>
                {t('ui.ntos_robotact.connection_unavailable')}
              </Box>
            </NoticeBox>
          )}
        </Flex.Item>
      )}
    </Flex>
  );
};
