import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosCyborgRemoteMonitor = (props) => {
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const ProgressSwitch = (param, t) => {
  switch (param) {
    case -1:
      return '_';
    case 0:
      return t('ui.ntoscyborgremotemonitor.connecting');
    case 25:
      return t('ui.ntoscyborgremotemonitor.starting_transfer');
    case 50:
      return t('ui.ntoscyborgremotemonitor.downloading');
    case 75:
      return t('ui.ntoscyborgremotemonitor.downloading');
    case 100:
      return t('ui.ntoscyborgremotemonitor.formatting');
  }
};

export const NtosCyborgRemoteMonitorContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const { card, cyborgs = [], DL_progress } = data;
  const storedlog = data.borglog || [];

  if (!cyborgs.length) {
    return <NoticeBox>{t('ui.ntoscyborgremotemonitor.no_cyborg_units_detected')}</NoticeBox>;
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            icon="robot"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}
          >
            {t('ui.ntoscyborgremotemonitor.cyborgs')}
          </Tabs.Tab>
          <Tabs.Tab
            icon="clipboard"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}
          >
            {t('ui.ntoscyborgremotemonitor.stored_log_file')}
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      {tab_main === 1 && (
        <>
          {!card && (
            <Stack.Item>
              <NoticeBox>
                {t(
                  'ui.ntoscyborgremotemonitor.certain_features_require_an_id_card_login',
                )}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow={1}>
            <Section fill scrollable>
              {cyborgs.map((cyborg) => (
                <Section
                  key={cyborg.ref}
                  title={cyborg.name}
                  buttons={
                    <Button
                      icon="terminal"
                      content={t('ui.ntoscyborgremotemonitor.send_message')}
                      color="blue"
                      disabled={!card}
                      onClick={() =>
                        act('messagebot', {
                          ref: cyborg.ref,
                        })
                      }
                    />
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label={t('ui.ntoscyborgremotemonitor.status')}>
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
                          ? t('ui.ntos_robo.not_responding')
                          : cyborg.locked_down
                            ? t('ui.ntos_robotact.locked_down')
                            : cyborg.shell_discon
                              ? t('ui.ntos_robotact.nominal_disconnected')
                              : t('ui.ntos_robo.nominal')}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label={t('ui.ntoscyborgremotemonitor.condition')}>
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
                    <LabeledList.Item label={t('ui.ntoscyborgremotemonitor.charge')}>
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
                    <LabeledList.Item label={t('ui.ntoscyborgremotemonitor.model')}>
                      {cyborg.module}
                    </LabeledList.Item>
                    <LabeledList.Item label={t('ui.ntoscyborgremotemonitor.upgrades')}>
                      {cyborg.upgrades}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))}
            </Section>
          </Stack.Item>
        </>
      )}
      {tab_main === 2 && (
        <>
          <Stack.Item>
            <Section>
              {t('ui.ntoscyborgremotemonitor.scan_cyborg_to_download_logs')}
              <ProgressBar value={DL_progress / 100}>
                {ProgressSwitch(DL_progress, t)}
              </ProgressBar>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill scrollable backgroundColor="black">
              {storedlog.map((log) => (
                <Box mb={1} key={log} color="green">
                  {log}
                </Box>
              ))}
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

