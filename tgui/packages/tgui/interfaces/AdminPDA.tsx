import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type UserList = Record<string, User>;

type User = {
  ref: string;
  username: string;
  invisible: BooleanLike;
};

type Data = {
  users: UserList;
};

export function AdminPDA(props) {
  const { t } = usePreferencesLocalization();
  const jobState = useState('');
  const nameState = useState('');
  const spamState = useState(false);
  const userState = useState('');
  const invisibleState = useState<BooleanLike>(0);

  return (
    <Window
      title={t('ui.admin_pda.send_pda_message')}
      width={300}
      height={575}
      theme="admin"
    >
      <Window.Content>
        <ReceiverChoice
          invisibleState={invisibleState}
          spamState={spamState}
          userState={userState}
        />
        <SenderInfo jobState={jobState} nameState={nameState} />
        <MessageInput
          invisibleState={invisibleState}
          jobState={jobState}
          nameState={nameState}
          spamState={spamState}
          userState={userState}
        />
      </Window.Content>
    </Window>
  );
}

type ReceiverProps = {
  invisibleState: [BooleanLike, (value: BooleanLike) => void];
  userState: [string, (value: string) => void];
  spamState: [boolean, (value: boolean) => void];
};

function ReceiverChoice(props: ReceiverProps) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { users } = data;

  const [user, setUser] = props.userState;
  const [spam, setSpam] = props.spamState;
  const [showInvisible, setShowInvisible] = props.invisibleState;

  const receivers = Array.from(Object.values(users));
  const dropdownOptions = receivers
    .filter((rcvr) => showInvisible || !rcvr.invisible)
    .map((rcvr) => ({
      displayText: rcvr.username,
      value: rcvr.ref,
    }));

  return (
    <Section title={t('ui.admin_pda.to_who')} textAlign="center">
      <Dropdown
        disabled={spam}
        selected={user}
        displayText={users[user]?.username}
        placeholder={t('ui.admin_pda.pick_a_user')}
        options={dropdownOptions}
        width="275px"
        mb={1}
        onSelected={(value) => {
          setUser(value);
        }}
      />
      <Box>
        <Button.Checkbox
          checked={showInvisible}
          fluid
          onClick={() => setShowInvisible(!showInvisible)}
        >
          {t('ui.admin_pda.include_invisible')}
        </Button.Checkbox>
        <Button.Checkbox checked={spam} fluid onClick={() => setSpam(!spam)}>
          {t('ui.admin_pda.send_to_everyone')}
        </Button.Checkbox>
      </Box>
    </Section>
  );
}

type SenderInfoProps = {
  nameState: [string, (value: string) => void];
  jobState: [string, (value: string) => void];
};

function SenderInfo(props: SenderInfoProps) {
  const { t } = usePreferencesLocalization();
  const [_name, setName] = props.nameState;
  const [_job, setJob] = props.jobState;

  return (
    <Section title={t('ui.admin_pda.from_who')} textAlign="center">
      <Box fontSize="14px">
        <Input
          placeholder={t('ui.admin_pda.sender_name_placeholder')}
          fluid
          onChange={setName}
        />
      </Box>
      <Box fontSize="14px" pt="10px">
        <Input
          placeholder={t('ui.admin_pda.sender_job_placeholder')}
          fluid
          onChange={setJob}
        />
      </Box>
    </Section>
  );
}

type MessageInputProps = {
  jobState: [string, (value: string) => void];
  nameState: [string, (value: string) => void];
  spamState: [boolean, (value: boolean) => void];
  userState: [string, (value: string) => void];
  invisibleState: [BooleanLike, (value: BooleanLike) => void];
};

function getErrorText(
  t: (key: string) => string,
  name: string,
  job: string,
  message: string,
  target: boolean,
) {
  const reasonList: string[] = [];
  if (!target) reasonList.push(t('ui.admin_pda.target'));
  if (!name) reasonList.push(t('ui.common.name'));
  if (!job) reasonList.push(t('ui.common.job'));
  if (!message) reasonList.push(t('ui.admin_pda.message_text'));
  return reasonList.join(', ');
}

function MessageInput(props: MessageInputProps) {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();

  const [messageText, setMessageText] = useState('');
  const [force, setForce] = useState(false);

  const [user] = props.userState;
  const [name] = props.nameState;
  const [job] = props.jobState;
  const [spam] = props.spamState;
  const [showInvisible] = props.invisibleState;

  const blocked = !name || !job || !messageText;

  return (
    <Section title={t('ui.common.message')} textAlign="center">
      <Box>
        <TextArea
          fluid
          placeholder={t('ui.admin_pda.message_placeholder')}
          height="200px"
          mb={1}
          onChange={setMessageText}
        />
      </Box>
      <Box>
        <Button.Checkbox
          fluid
          checked={force}
          tooltip={
            t('ui.admin_pda.force_send_tooltip')
          }
          onClick={() => setForce(!force)}
        >
          {t('ui.admin_pda.force_send')}
        </Button.Checkbox>
        <Button
          tooltip={
            blocked
              ? `${t('ui.admin_pda.fill_in_following_lines')}: ` +
                getErrorText(t, name, job, messageText, spam || !!user)
              : t('ui.admin_pda.send_message_to_users')
          }
          fluid
          disabled={blocked}
          icon="envelope-open-text"
          onClick={() =>
            act('sendMessage', {
              force: force,
              include_invisible: showInvisible,
              job: job,
              message: messageText,
              name: name,
              ref: user,
              spam: spam,
            })
          }
        >
          {t('ui.admin_pda.send_message')}
        </Button>
      </Box>
    </Section>
  );
}
