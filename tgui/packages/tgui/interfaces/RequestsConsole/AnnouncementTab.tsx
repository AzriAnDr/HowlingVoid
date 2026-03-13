import { useState } from 'react';
import { Button, NoticeBox, Section, TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { RequestsData } from './types';

export const AnnouncementTab = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { t } = usePreferencesLocalization(data);
  const { authentication_data, is_admin_ghost_ai } = data;
  const [messageText, setMessageText] = useState('');
  return (
    <Section>
      <TextArea
        fluid
        height={20}
        maxLength={1025}
        value={messageText}
        onChange={setMessageText}
        placeholder={t('ui.requests_console.type_announcement_placeholder')}
      />
      <Section>
        <AuthenticationNoticeBox />
        <Button
          disabled={
            !(
              authentication_data.announcement_authenticated ||
              is_admin_ghost_ai
            ) || !messageText
          }
          icon="bullhorn"
          content={t('ui.requests_console.send_announcement')}
          onClick={() => {
            if (
              !(
                authentication_data.announcement_authenticated ||
                is_admin_ghost_ai
              ) ||
              !messageText
            ) {
              return;
            }
            act('send_announcement', { message: messageText });
            setMessageText('');
          }}
        />
        <Button
          icon="trash-can"
          content={t('ui.requests_console.discard_announcement')}
          onClick={() => {
            act('clear_authentication');
            setMessageText('');
          }}
        />
      </Section>
    </Section>
  );
};

const AuthenticationNoticeBox = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { t } = usePreferencesLocalization(data);
  const { authentication_data, is_admin_ghost_ai } = data;
  return (
    (!authentication_data.announcement_authenticated && !is_admin_ghost_ai && (
      <NoticeBox>{t('ui.requests_console.swipe_card_to_authenticate')}</NoticeBox>
    )) || <NoticeBox info>{t('ui.requests_console.successfully_authenticated')}</NoticeBox>
  );
};
