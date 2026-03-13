import { useState } from 'react';
import {
  Button,
  Divider,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const PacketInfo = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { packet } = props;

  return (
    <Stack.Item>
      <Flex justify="space-between">
        <Flex.Item align="left">{packet.name}</Flex.Item>
        <Flex.Item align="right">
          <Button
            icon="trash"
            color="red"
            onClick={() => act('delete_packet', { ref: packet.ref })}
          />
        </Flex.Item>
      </Flex>
      <LabeledList>
        <LabeledList.Item label={t('ui.server_monitor.data_type')}>{packet.type}</LabeledList.Item>
        <LabeledList.Item label={t('ui.common.source')}>
          {packet.source + (packet.job ? ` (${packet.job})` : '')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.class')}>{packet.race}</LabeledList.Item>
        <LabeledList.Item label={t('ui.common.contents')}>{packet.message}</LabeledList.Item>
        <LabeledList.Item label={t('ui.common.language')}>{packet.language}</LabeledList.Item>
      </LabeledList>
      <Divider />
    </Stack.Item>
  );
};

const ServerScreen = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { network, server } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={t('ui.server_monitor.server_information')}
          buttons={
            <Button
              content={t('ui.common.main_menu')}
              icon="home"
              onClick={() => act('return_home')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.network')}>{network}</LabeledList.Item>
            <LabeledList.Item label={t('ui.common.server')}>{server.name}</LabeledList.Item>
            <LabeledList.Item label={t('ui.server_monitor.total_recorded_traffic')}>
              {server.traffic >= 1024
                ? `${server.traffic / 1024} TB`
                : `${server.traffic} GB`}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={t('ui.server_monitor.stored_packets')}>
          <Stack vertical>
            {server.packets?.map((p) => (
              <PacketInfo key={p.ref} packet={p} />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MainScreen = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { servers, network } = data;
  const [networkId, setNetworkId] = useState(network);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Input
            value={networkId}
            onChange={setNetworkId}
            placeholder={t('ui.server_monitor.network_id')}
            onEnter={() => act('scan_network', { network_id: networkId })}
          />
          <Button
            content={t('ui.common.scan')}
            onClick={() => act('scan_network', { network_id: networkId })}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={t('ui.server_monitor.detected_telecommunication_servers')}
          buttons={
            <Button
              content={t('ui.common.clear_buffer')}
              icon="trash"
              color="red"
              disabled={servers.length === 0}
              onClick={() => act('clear_buffer')}
            />
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>{t('ui.common.address')}</Table.Cell>
              <Table.Cell>{t('ui.server_monitor.identification_string')}</Table.Cell>
              <Table.Cell>{t('ui.common.name')}</Table.Cell>
            </Table.Row>
            {servers?.map((s) => (
              <Table.Row key={s.ref}>
                <Table.Cell>{s.ref}</Table.Cell>
                <Table.Cell>{s.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={s.name}
                    onClick={() => act('view_server', { server: s.ref })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const ServerMonitor = (props) => {
  const { act, data } = useBackend();
  const { screen, error } = data;
  return (
    <Window width={575} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {error !== '' && <NoticeBox>{error}</NoticeBox>}
          </Stack.Item>
          <Stack.Item grow>
            {(screen === 0 && <MainScreen />) ||
              (screen === 1 && <ServerScreen />)}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
