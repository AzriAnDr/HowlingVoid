import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { NtosWindow } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { ChatScreen } from './ChatScreen';
import type { NtChat, NtMessenger, NtPicture } from './types';

type NtosMessengerData = {
  can_spam: BooleanLike;
  is_silicon: BooleanLike;
  remote_silicon: BooleanLike;
  owner?: NtMessenger;
  saved_chats: Record<string, NtChat>;
  messengers: Record<string, NtMessenger>;
  sort_by_job: BooleanLike;
  alert_silenced: BooleanLike;
  alert_able: BooleanLike;
  sending_and_receiving: BooleanLike;
  open_chat: string;
  stored_photos?: NtPicture[];
  selected_photo_path?: string;
  on_spam_cooldown: BooleanLike;
  virus_attach: BooleanLike;
  sending_virus: BooleanLike;
};

export const NtosMessenger = (props) => {
  const { data } = useBackend<NtosMessengerData>();
  const { t } = usePreferencesLocalization(data);
  const {
    is_silicon,
    remote_silicon,
    saved_chats,
    stored_photos,
    selected_photo_path,
    open_chat,
    messengers,
    sending_virus,
  } = data;

  let content: React.JSX.Element;
  if (remote_silicon) {
    content = <AccessDeniedScreen t={t} />;
  } else if (open_chat !== null) {
    const openChat = saved_chats[open_chat];
    const temporaryRecipient = messengers[open_chat];

    if (!openChat && !temporaryRecipient) {
      content = <ContactsScreen t={t} />;
    } else {
      content = (
        <ChatScreen
          storedPhotos={stored_photos}
          selectedPhoto={selected_photo_path}
          isSilicon={is_silicon}
          sendingVirus={sending_virus}
          canReply={openChat ? openChat.can_reply : !!temporaryRecipient}
          messages={openChat ? openChat.messages : []}
          recipient={openChat ? openChat.recipient : temporaryRecipient}
          unreads={openChat ? openChat.unread_messages : 0}
          chatRef={openChat?.ref}
          t={t}
        />
      );
    }
  } else {
    content = <ContactsScreen t={t} />;
  }

  return (
    <NtosWindow width={600} height={850}>
      <NtosWindow.Content>{content}</NtosWindow.Content>
    </NtosWindow>
  );
};

const AccessDeniedScreen = (props: any) => {
  const { t } = props;
  const { act, data } = useBackend<NtosMessengerData>();

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" />
              {t('ui.ntos_messenger.app_title')}
            </Box>
          </Stack>
        </Section>
      </Stack.Item>
      <NoticeBox
        color="white"
        position="relative"
        top="30%"
        fontSize="30px"
        textAlign="center"
      >
        {t('ui.ntos_messenger.error_connection_refused')}
      </NoticeBox>
      <Stack vertical position="relative" top="35%" textAlign="left">
        <Section>
          <Box>{t('ui.ntos_messenger.message_from_host')}</Box>
          <Box>- {t('ui.ntos_messenger.remote_access_restricted')}</Box>
          <Box>- {t('ui.ntos_messenger.contact_admin_assistance')}</Box>
        </Section>
      </Stack>
    </Stack>
  );
};

const ContactsScreen = (props: any) => {
  const { t } = props;
  const { act, data } = useBackend<NtosMessengerData>();
  const {
    owner,
    alert_silenced,
    alert_able,
    sending_and_receiving,
    saved_chats,
    messengers,
    sort_by_job,
    can_spam,
    is_silicon,
    virus_attach,
    sending_virus,
  } = data;

  const [searchUser, setSearchUser] = useState('');

  const sortByUnreads = (array: NtChat[]) =>
    sortBy(array, [(chat) => chat.unread_messages]);

  const searchChatByName = createSearch(
    searchUser,
    (chat: NtChat) => chat.recipient.name + chat.recipient.job,
  );
  const searchMessengerByName = createSearch(
    searchUser,
    (messenger: NtMessenger) => messenger.name + messenger.job,
  );

  const chatToButton = (chat: NtChat) => {
    return (
      <ChatButton
        key={chat.ref}
        name={`${chat.recipient.name} (${chat.recipient.job})`}
        chatRef={chat.ref}
        unreads={chat.unread_messages}
      />
    );
  };

  const messengerToButton = (messenger: NtMessenger) => {
    return (
      <ChatButton
        key={messenger.ref}
        name={`${messenger.name} (${messenger.job})`}
        chatRef={messenger.ref!}
        unreads={0}
      />
    );
  };

  const openChatsArray = sortByUnreads(Object.values(saved_chats)).filter(
    searchChatByName,
  );

  const filteredChatButtons = openChatsArray
    .filter((c) => c.visible)
    .map(chatToButton);

  const messengerButtons = Object.entries(messengers)
    .filter(
      ([ref, messenger]) =>
        openChatsArray.every((chat) => chat.recipient.ref !== ref) &&
        searchMessengerByName(messenger),
    )
    .map(([_, messenger]) => messenger)
    .map(messengerToButton)
    .concat(openChatsArray.filter((chat) => !chat.visible).map(chatToButton));

  const noId = !owner && !is_silicon;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              {t('ui.ntos_messenger.app_title')}
            </Box>
            <Box italic opacity={0.3} mt={1}>
              {t('ui.ntos_messenger.tagline')}
            </Box>
            <Divider hidden />
            <Box>
              <Button
                icon="bell"
                disabled={!alert_able}
                content={
                  alert_able && !alert_silenced
                    ? t('ui.ntos_messenger.ringer_on')
                    : t('ui.ntos_messenger.ringer_off')
                }
                onClick={() => act('PDA_toggleAlerts')}
              />
              <Button
                icon="address-card"
                content={
                  sending_and_receiving
                    ? t('ui.ntos_messenger.send_receive_on')
                    : t('ui.ntos_messenger.send_receive_off')
                }
                onClick={() => act('PDA_toggleSendingAndReceiving')}
              />
              <Button
                icon="bell"
                content={t('ui.ntos_messenger.set_ringtone')}
                onClick={() => act('PDA_ringSet')}
              />
              <Button
                icon="sort"
                content={`${t('ui.ntos_messenger.sort_by')}: ${
                  sort_by_job ? t('ui.ntos_messenger.job') : t('ui.common.name')
                }`}
                onClick={() => act('PDA_changeSortStyle')}
              />
              {!!virus_attach && (
                <Button
                  icon="bug"
                  color="bad"
                  content={`${t('ui.ntos_messenger.attach_virus')}: ${
                    sending_virus ? t('ui.common.yes') : t('ui.common.no')
                  }`}
                  onClick={() => act('PDA_toggleVirus')}
                />
              )}
            </Box>
          </Stack>
          <Divider hidden />
          <Stack justify="space-between">
            <Box m={0.5}>
              <Icon name="magnifying-glass" mr={1} />
              {t('ui.ntos_messenger.search_for_user')}
            </Box>
            <Input
              width="220px"
              placeholder={t('ui.ntos_messenger.search_by_name_or_job')}
              value={searchUser}
              onChange={setSearchUser}
            />
          </Stack>
        </Section>
      </Stack.Item>
      {filteredChatButtons.length > 0 && (
        <Stack.Item grow={1}>
          <Stack vertical fill>
            <Section>
              <Icon name="comments" mr={1} />
              {t('ui.ntos_messenger.previous_messages')}
            </Section>
            <Section fill scrollable>
              <Stack vertical>{filteredChatButtons}</Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow={2}>
        <Stack vertical fill>
          <Section>
            <Stack>
              <Box m={0.5}>
                <Icon name="address-card" mr={1} />
                {t('ui.ntos_messenger.detected_messengers')}
              </Box>
            </Stack>
          </Section>
          <Section fill scrollable>
            <Stack vertical pb={1} fill>
              {messengerButtons.length === 0 && (
                <Stack align="center" justify="center" fill pl={4}>
                  <Icon color="gray" name="user-slash" size={2} />
                  <Stack.Item fontSize={1.5} ml={3}>
                    {t('ui.ntos_messenger.no_users_found')}
                  </Stack.Item>
                </Stack>
              )}
              {messengerButtons}
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
      {!!can_spam && (
        <Stack.Item>
          <SendToAllSection t={t} />
        </Stack.Item>
      )}
      {noId && <NoIDDimmer t={t} />}
    </Stack>
  );
};

type ChatButtonProps = {
  name: string;
  unreads: number;
  chatRef: string;
};

const ChatButton = (props: ChatButtonProps) => {
  const { t } = usePreferencesLocalization();
  const { act } = useBackend();
  const unreadMessages = props.unreads;
  const hasUnreads = unreadMessages > 0;
  return (
    <Button
      icon={hasUnreads && 'envelope'}
      key={props.chatRef}
      fluid
      onClick={() => {
        act('PDA_viewMessages', { ref: props.chatRef });
      }}
    >
      {hasUnreads &&
        `[${unreadMessages <= 9 ? unreadMessages : '9+'} ${t(
          'ui.ntos_messenger.unread_messages_count',
        )}]`}{' '}
      {props.name}
    </Button>
  );
};

const SendToAllSection = (props) => {
  const { t } = props;
  const { data, act } = useBackend<NtosMessengerData>();
  const { on_spam_cooldown } = data;

  const [message, setMessage] = useState('');

  return (
    <>
      <Section>
        <Stack justify="space-between">
          <Stack.Item align="center">
            <Icon name="satellite-dish" mr={1} ml={0.5} />
            {t('ui.ntos_messenger.send_to_all')}
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrow-right"
              disabled={on_spam_cooldown || message === ''}
              tooltip={
                on_spam_cooldown &&
                t('ui.ntos_messenger.wait_before_sending_more_messages')
              }
              onClick={() => {
                act('PDA_sendEveryone', { message: message });
                setMessage('');
              }}
            >
              {t('ui.common.send')}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <TextArea
          height={6}
          value={message}
          placeholder={t('ui.ntos_messenger.send_message_to_everyone')}
          onChange={setMessage}
          selfClear
          onEnter={() => {
            act('PDA_sendEveryone', { message: message });
          }}
        />
      </Section>
    </>
  );
};

const NoIDDimmer = (props) => {
  const { t } = props;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack ml={-2}>
          <Icon color="red" name="address-card" size={10} />
        </Stack>
        <Stack.Item fontSize="18px">
          {t('ui.ntos_messenger.please_imprint_id')}
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
