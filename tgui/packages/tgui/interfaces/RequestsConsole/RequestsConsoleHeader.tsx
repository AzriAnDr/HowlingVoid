import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { RequestPriority, type RequestsData } from './types';

export const RequestsConsoleHeader = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { has_mail_send_error, new_message_priority } = data;
  return (
    <Stack.Item mb={1}>
      {!!has_mail_send_error && <ErrorNoticeBox />}
      {!!new_message_priority && <MessageNoticeBox />}
      <EmergencyBox />
    </Stack.Item>
  );
};

const EmergencyBox = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { t } = usePreferencesLocalization(data);
  const { emergency } = data;
  return (
    <>
      {!!emergency && (
        <NoticeBox danger>
          {t('ui.requests_console.emergency_called_notice')
            .replace('{emergency}', emergency)}
        </NoticeBox>
      )}
      {!emergency && (
        <Stack fill>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="shield"
              content={t('ui.requests_console.call_security')}
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Security',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="screwdriver-wrench"
              content={t('ui.requests_console.call_engineering')}
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Engineering',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="suitcase-medical"
              content={t('ui.requests_console.call_medical')}
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Medical',
                })
              }
            />
          </Stack.Item>
        </Stack>
      )}
    </>
  );
};

const ErrorNoticeBox = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <NoticeBox danger>{t('ui.requests_console.send_message_error')}</NoticeBox>
  );
};

const MessageNoticeBox = (props) => {
  const { data } = useBackend<RequestsData>();
  const { t } = usePreferencesLocalization(data);
  const { new_message_priority } = data;
  return (
    <NoticeBox>
      {t('ui.requests_console.new_unread_prefix')}
      {new_message_priority === RequestPriority.HIGH &&
        ` ${t('ui.requests_console.high_priority_uppercase')} `}
      {new_message_priority === RequestPriority.EXTREME &&
        ` ${t('ui.requests_console.extreme_priority_uppercase')} `}
      {t('ui.requests_console.new_unread_suffix')}
    </NoticeBox>
  );
};
