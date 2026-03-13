import {
  BlockQuote,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import {
  type RequestMessage,
  RequestPriority,
  type RequestsData,
  RequestType,
} from './types';

export const MessageViewTab = (props) => {
  const { act, data } = useBackend<RequestsData>();
  usePreferencesLocalization(data);
  const { messages = [] } = data;
  return (
    <Section fill scrollable>
      <Stack vertical>
        {messages.map((message) => (
          <MessageDisplay key={message.received_time} message={message} />
        ))}
      </Stack>
    </Section>
  );
};

const MessageDisplay = (props: { message: RequestMessage }) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { message } = props;
  const append_list_keys = message.appended_list
    ? Object.keys(message.appended_list)
    : [];
  return (
    <Stack.Item>
      <Section
        title={
          message.request_type +
          ' from ' +
          message.sender_department +
          ', ' +
          message.received_time
        }
      >
        {message.priority === RequestPriority.HIGH && (
          <NoticeBox>{t('ui.requests_console.high_priority')}</NoticeBox>
        )}
        {message.priority === RequestPriority.EXTREME && (
          <NoticeBox danger>{t('ui.requests_console.extreme_priority')}</NoticeBox>
        )}
        <BlockQuote>
          {decodeHtmlEntities(message.content)}
          {!!message.appended_list && !!append_list_keys.length && (
            <LabeledList>
              {append_list_keys.map((list_key) => (
                <LabeledList.Item key={list_key} label={list_key}>
                  {message.appended_list[list_key]}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </BlockQuote>
        <LabeledList>
          <LabeledList.Item label={t('ui.requests_console.message_verified_by')}>
            {message.message_verified_by || t('ui.requests_console.not_verified')}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.requests_console.message_stamped_by')}>
            {message.message_stamped_by || t('ui.requests_console.not_stamped')}
          </LabeledList.Item>
        </LabeledList>
        {message.request_type !== RequestType.ORE_UPDATE && (
          <Section>
            <Button
              icon="reply"
              content="Quick Reply"
              onClick={() => {
                act('quick_reply', {
                  reply_recipient: message.sender_department,
                });
              }}
            />
          </Section>
        )}
      </Section>
    </Stack.Item>
  );
};
