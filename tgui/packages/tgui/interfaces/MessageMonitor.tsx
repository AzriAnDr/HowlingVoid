import { type Dispatch, type SetStateAction, useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

enum Screen {
  Main,
  MessageLogs,
  RequestLogs,
  Hacked,
}

type Data = {
  screen: Screen;
  status: BooleanLike;
  server_status: BooleanLike;
  auth: BooleanLike;
  password: string;
  is_malf: BooleanLike;
  error_message: string;
  success_message: string;
  notice_message: string;
  requests: Request[];
  messages: Message[];
};

type Request = {
  ref: string;
  message: string;
  stamp: string;
  sender_department: string;
  id_auth: string;
};

type Message = {
  ref: string;
  message: string;
  sender: string;
  recipient: string;
};

const RequestLogsScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { requests = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={t('ui.message_monitor.requests')}
          buttons={
            <Button
              content={t('ui.message_monitor.main_menu')}
              icon="home"
              onClick={() => act('return_home')}
            />
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>{t('ui.common.delete')}</Table.Cell>
              <Table.Cell>{t('ui.common.message')}</Table.Cell>
              <Table.Cell>{t('ui.message_monitor.stamp')}</Table.Cell>
              <Table.Cell>{t('ui.message_monitor.department')}</Table.Cell>
              <Table.Cell>{t('ui.message_monitor.authentication')}</Table.Cell>
            </Table.Row>
            {requests?.map((request) => (
              <Table.Row key={request.ref} className="candystripe">
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_request', { ref: request.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{request.message}</Table.Cell>
                <Table.Cell>{request.stamp}</Table.Cell>
                <Table.Cell>{request.sender_department}</Table.Cell>
                <Table.Cell>{request.id_auth}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MessageLogsScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { messages = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={t('ui.message_monitor.stored_messages')}
          buttons={
            <Button
              content={t('ui.message_monitor.main_menu')}
              icon="home"
              onClick={() => act('return_home')}
            />
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>{t('ui.common.delete')}</Table.Cell>
              <Table.Cell>{t('ui.message_monitor.sender')}</Table.Cell>
              <Table.Cell>{t('ui.message_monitor.recipient')}</Table.Cell>
              <Table.Cell>{t('ui.common.message')}</Table.Cell>
            </Table.Row>
            {messages?.map((message) => (
              <Table.Row key={message.ref} className="candystripe">
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_message', { ref: message.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{message.sender}</Table.Cell>
                <Table.Cell>{message.recipient}</Table.Cell>
                <Table.Cell>
                  <Box
                    as="span"
                    dangerouslySetInnerHTML={{ __html: message.message }}
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

const HackedScreen = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Stack.Item grow>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow>
          <Box color="red" fontSize="18px" bold mt={5}>
            {t('ui.message_monitor.hacked_error')}
          </Box>
          <Box color="red" fontSize="18px" bold mt={5}>
            {t('ui.message_monitor.hacked_reboot')}
          </Box>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const MainScreenAuth = (props: AuthScreenProps) => {
  const { auth_password, setPassword } = props;

  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { status, is_malf } = data;

  return (
    <>
      <Stack.Item>
        <Section>
          <Input
            value={auth_password}
            onChange={setPassword}
            placeholder={t('ui.common.password')}
          />
          <Button
            content={t('ui.message_monitor.logout')}
            onClick={() => act('auth', { auth_password: auth_password })}
          />
          <Button
            icon={status ? 'power-off' : 'times'}
            content={status ? t('ui.common.on') : t('ui.common.off')}
            color={status ? 'green' : 'red'}
            onClick={() => act('turn_server')}
          />
          {is_malf === 1 && (
            <Button
              icon="terminal"
              content={t('ui.message_monitor.hack')}
              color="red"
              disabled
              onClick={() => act('hack')}
            />
          )}
        </Section>
      </Stack.Item>
      <Table>
        <Table.Row header>
          <Table.Cell>{t('ui.message_monitor.choose_option')}</Table.Cell>
          <Table.Cell>{t('ui.common.description')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={t('ui.message_monitor.view_message_logs')}
              onClick={() => act('view_message_logs')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.shows_all_messages')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={t('ui.message_monitor.view_request_logs')}
              onClick={() => act('view_request_logs')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.shows_all_request_orders')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button.Confirm
              content={t('ui.message_monitor.clear_message_logs')}
              onClick={() => act('clear_message_logs')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.clears_message_logs')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button.Confirm
              content={t('ui.message_monitor.clear_request_logs')}
              onClick={() => act('clear_request_logs')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.clears_request_console_logs')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={t('ui.message_monitor.set_custom_key')}
              onClick={() => act('set_key')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.changes_decryption_key')}</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={t('ui.message_monitor.send_admin_message')}
              onClick={() => act('send_fake_message')}
            />
          </Table.Cell>
          <Table.Cell>{t('ui.message_monitor.sends_custom_message')}</Table.Cell>
        </Table.Row>
      </Table>
    </>
  );
};

type AuthScreenProps = {
  auth_password: string;
  setPassword: Dispatch<SetStateAction<string>>;
};

const MainScreenNotAuth = (props: AuthScreenProps) => {
  const { auth_password, setPassword } = props;
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { status, is_malf } = data;

  return (
    <>
      <Stack.Item>
        <Section>
          <Input
            value={auth_password}
            onChange={setPassword}
            placeholder={t('ui.common.password')}
          />
          <Button onClick={() => act('auth', { auth_password: auth_password })}>
            {t('ui.message_monitor.auth')}
          </Button>
          <Button
            icon={status ? 'power-off' : 'times'}
            color={status ? 'green' : 'red'}
            disabled
            onClick={() => act('turn_server')}
          >
            {status ? t('ui.common.on') : t('ui.common.off')}
          </Button>
          {!!is_malf && (
            <Button color="red" onClick={() => act('hack')}>
              {t('ui.message_monitor.hack')}
            </Button>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={t('ui.message_monitor.choose_option')}>
          <Table>
            <Table.Row header>
              <Table.Cell>{t('ui.message_monitor.choose_option')}</Table.Cell>
              <Table.Cell>{t('ui.common.description')}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  content={t('ui.message_monitor.link_server')}
                  onClick={() => act('link_server')}
                />
              </Table.Cell>
              <Table.Cell>{t('ui.message_monitor.connects_to_server')}</Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

const MainScreen = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { auth, password } = data;

  const [auth_password, setPassword] = useState(password);

  return (
    <Stack fill vertical>
      {auth ? (
        <MainScreenAuth
          auth_password={auth_password}
          setPassword={setPassword}
        />
      ) : (
        <MainScreenNotAuth
          auth_password={auth_password}
          setPassword={setPassword}
        />
      )}
    </Stack>
  );
};

export const MessageMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    screen,
    error_message,
    success_message,
    notice_message,
    server_status,
  } = data;
  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack vertical fill>
          {server_status ? (
            <>
              <Stack.Item>
                {!!error_message && (
                  <NoticeBox color="red">{error_message}</NoticeBox>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!success_message && (
                  <NoticeBox color="green">{success_message}</NoticeBox>
                )}
              </Stack.Item>
              <Stack.Item grow>
                {(screen === Screen.Main && <MainScreen />) ||
                  (screen === Screen.MessageLogs && <MessageLogsScreen />) ||
                  (screen === Screen.RequestLogs && <RequestLogsScreen />) ||
                  (screen === Screen.Hacked && <HackedScreen />)}
              </Stack.Item>
              <Stack.Item>
                {!!notice_message && (
                  <NoticeBox color="yellow">{notice_message}</NoticeBox>
                )}
              </Stack.Item>
              <label>
                {t('ui.message_monitor.regulation_514')}
              </label>
            </>
          ) : (
            <>
              <Stack.Item>
                <NoticeBox color="red">
                  {t('ui.message_monitor.server_not_found')}
                </NoticeBox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  content={t('ui.message_monitor.connect_to_server')}
                  onClick={() => act('connect_server')}
                />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
