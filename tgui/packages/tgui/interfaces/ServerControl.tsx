import {
  Button,
  Collapsible,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  server_connected: BooleanLike;
  servers: ServerData[];
  consoles: ConsoleData[];
  logs: LogData[];
};

type ServerData = {
  server_name: string;
  server_details: string;
  server_disabled: string;
  server_ref: string;
};

type ConsoleData = {
  console_name: string;
  console_location: string;
  console_locked: string;
  console_ref: string;
};

type LogData = {
  node_name: string;
  node_cost: string;
  node_researcher: string;
  node_research_location: string;
};

export const ServerControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { server_connected, servers, consoles, logs } = data;
  if (!server_connected) {
    return (
      <Window width={575} height={450}>
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            {t('ui.server_control.not_connected_to_server')}
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={575} height={400}>
      <Window.Content scrollable>
        {!servers ? (
          <NoticeBox mt={2} info>
            {t('ui.server_control.no_servers_found')}
          </NoticeBox>
        ) : (
          <Section>
            <Table textAlign="center">
              <Table.Row header>
                <Table.Cell>{t('ui.server_control.research_servers')}</Table.Cell>
              </Table.Row>
              {servers.map((server) => (
                <>
                  <Table.Row
                    header
                    key={server.server_ref}
                    className="candystripe"
                  />
                  <Table.Cell> {server.server_name}</Table.Cell>
                  <Button
                    mt={1}
                    tooltip={server.server_details}
                    color={server.server_disabled ? 'bad' : 'good'}
                    content={
                      server.server_disabled
                        ? t('ui.common.offline')
                        : t('ui.common.online')
                    }
                    fluid
                    textAlign="center"
                    onClick={() =>
                      act('lockdown_server', {
                        selected_server: server.server_ref,
                      })
                    }
                  />
                </>
              ))}
            </Table>
          </Section>
        )}

        {!consoles ? (
          <NoticeBox mt={2} info>
            {t('ui.server_control.no_consoles_found')}
          </NoticeBox>
        ) : (
          <Section align="right">
            <Table textAlign="center">
              <Table.Row header>
                <Table.Cell>{t('ui.server_control.research_consoles')}</Table.Cell>
              </Table.Row>
              {consoles.map((console) => (
                <>
                  <Table.Row
                    header
                    key={console.console_ref}
                    className="candystripe"
                  />
                  <Table.Cell>
                    {console.console_name} - {t('ui.common.location')}:{' '}
                    {console.console_location}
                  </Table.Cell>
                  <Button
                    mt={1}
                    color={console.console_locked ? 'bad' : 'good'}
                    content={
                      console.console_locked
                        ? t('ui.common.locked')
                        : t('ui.common.unlocked')
                    }
                    fluid
                    textAlign="center"
                    onClick={() =>
                      act('lock_console', {
                        selected_console: console.console_ref,
                      })
                    }
                  />
                </>
              ))}
            </Table>
          </Section>
        )}

        <Collapsible title={t('ui.server_control.research_history')}>
          {!logs.length ? (
            <NoticeBox mt={2} info>
              {t('ui.server_control.no_history_found')}
            </NoticeBox>
          ) : (
            <Section>
              <Table>
                <Table.Row header>
                  <Table.Cell>{t('ui.server_control.research_name')}</Table.Cell>
                  <Table.Cell>{t('ui.common.cost')}</Table.Cell>
                  <Table.Cell>{t('ui.server_control.researcher_name')}</Table.Cell>
                  <Table.Cell>{t('ui.server_control.console_location')}</Table.Cell>
                </Table.Row>
                {logs.map((server_log) => (
                  <Table.Row
                    mt={1}
                    key={server_log.node_name}
                    className="candystripe"
                  >
                    <Table.Cell>{server_log.node_name}</Table.Cell>
                    <Table.Cell>{server_log.node_cost}</Table.Cell>
                    <Table.Cell>{server_log.node_researcher}</Table.Cell>
                    <Table.Cell>{server_log.node_research_location}</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          )}
        </Collapsible>
      </Window.Content>
    </Window>
  );
};
