import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosNetMonitor = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const {
    ntnetrelays,
    idsalarm,
    idsstatus,
    ntnetlogs = [],
    tablets = [],
  } = data;

  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Stack.Item>
          <Tabs>
            <Tabs.Tab
              icon="network-wired"
              lineHeight="23px"
              selected={tab_main === 1}
              onClick={() => setTab_main(1)}
            >
              {t('ui.ntosnetmonitor.ntnet')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="tablet"
              lineHeight="23px"
              selected={tab_main === 2}
              onClick={() => setTab_main(2)}
            >
              {t('ui.ntosnetmonitor.tablets')} ({tablets.length})
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        {tab_main === 1 && (
          <Stack.Item>
            <MainPage
              ntnetrelays={ntnetrelays}
              idsalarm={idsalarm}
              idsstatus={idsstatus}
              ntnetlogs={ntnetlogs}
            />
          </Stack.Item>
        )}
        {tab_main === 2 && (
          <Stack.Item>
            <TabletPage tablets={tablets} />
          </Stack.Item>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const MainPage = (props) => {
  const { ntnetrelays, idsalarm, idsstatus, ntnetlogs = [] } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  return (
    <Section>
      <NoticeBox>
        {t(
          'ui.ntosnetmonitor.warning_disabling_wireless_transmitters_when_using_a_wireless_device_may_prevent_you_from_reenabling_them',
        )}
      </NoticeBox>
      <Section title={t('ui.ntosnetmonitor.wireless_connectivity')}>
        {ntnetrelays.map((relay) => (
          <Section
            key={relay.ref}
            title={relay.name}
            buttons={
              <Button.Confirm
                color={relay.is_operational ? 'good' : 'bad'}
                content={
                  relay.is_operational
                    ? t('ui.common.enabled_uppercase')
                    : t('ui.common.disabled_uppercase')
                }
                onClick={() =>
                  act('toggle_relay', {
                    ref: relay.ref,
                  })
                }
              />
            }
          />
        ))}
      </Section>
      <Section title={t('ui.ntosnetmonitor.security_systems')}>
        {!!idsalarm && (
          <>
            <NoticeBox>{t('ui.ntosnetmonitor.network_incursion_detected')}</NoticeBox>
            <Box italics>
              {t(
                'ui.ntosnetmonitor.abnormal_activity_detected_check_system_logs_for_more_information',
              )}
            </Box>
          </>
        )}
        <LabeledList>
          <LabeledList.Item
            label={t('ui.ntosnetmonitor.ids_status')}
            buttons={
              <>
                <Button
                  icon={idsstatus ? 'power-off' : 'times'}
                  content={
                    idsstatus
                      ? t('ui.common.enabled_uppercase')
                      : t('ui.common.disabled_uppercase')
                  }
                  selected={idsstatus}
                  onClick={() => act('toggleIDS')}
                />
                <Button
                  icon="sync"
                  content={t('ui.ntosnetmonitor.reset')}
                  color="bad"
                  onClick={() => act('resetIDS')}
                />
              </>
            }
          />
        </LabeledList>
        <Section
          title={t('ui.ntosnetmonitor.system_log')}
          buttons={
            <Button.Confirm
              icon="trash"
              content={t('ui.ntosnetmonitor.clear_logs')}
              onClick={() => act('purgelogs')}
            />
          }
        >
          {ntnetlogs.map((log) => (
            <Box key={log.entry} className="candystripe">
              {log.entry}
            </Box>
          ))}
        </Section>
      </Section>
    </Section>
  );
};

const TabletPage = (props) => {
  const { tablets } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  if (!tablets.length) {
    return <NoticeBox>{t('ui.ntosnetmonitor.no_tablets_detected')}</NoticeBox>;
  }
  return (
    <Section>
      <Stack vertical mt={1}>
        <Section fill textAlign="center">
          <Icon name="comment" mr={1} />
          {t('ui.ntosnetmonitor.active_tablets')}
        </Section>
      </Stack>
      <Stack vertical mt={1}>
        <Section fill>
          <Stack vertical>
            {tablets.map((tablet) => (
              <Section
                key={tablet.ref}
                title={tablet.name}
                buttons={
                  <Button.Confirm
                    icon={tablet.enabled_spam ? 'unlock' : 'lock'}
                    color={tablet.enabled_spam ? 'good' : 'default'}
                    content={
                      tablet.enabled_spam
                        ? t('ui.ntosnetmonitor.restrict_mass_pda')
                        : t('ui.ntosnetmonitor.allow_mass_pda')
                    }
                    onClick={() =>
                      act('toggle_mass_pda', {
                        ref: tablet.ref,
                      })
                    }
                  />
                }
              />
            ))}
          </Stack>
        </Section>
      </Stack>
    </Section>
  );
};

