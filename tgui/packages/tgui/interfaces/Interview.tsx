import { type ReactNode, useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  NoticeBox,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  connected: BooleanLike;
  is_admin: BooleanLike;
  questions: Question[];
  queue_pos: number;
  read_only: BooleanLike;
  status: string;
  welcome_message: string;
  centcom_connected: BooleanLike;
  has_permabans: BooleanLike;
};

type Question = {
  qidx: number;
  question: string;
  response: string | null;
};

enum STATUS {
  Approved = 'interview_approved',
  Denied = 'interview_denied',
}

// Matches a complete markdown-style link, capturing the whole [...](...)
const linkRegex = /(\[[^[]+\]\([^)]+\))/;
// Decomposes a markdown-style link into the link and display text
const linkDecomposeRegex = /\[([^[]+)\]\(([^)]+)\)/;

// Renders any markdown-style links within a provided body of text
const linkifyText = (text: string) => {
  const parts: ReactNode[] = text.split(linkRegex);
  for (let i = 1; i < parts.length; i += 2) {
    const match = linkDecomposeRegex.exec(parts[i] as string);
    if (!match) continue;

    parts[i] = (
      <a key={`link${i}`} href={match[2]}>
        {match[1]}
      </a>
    );
  }
  return parts;
};

export const Interview = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const {
    connected,
    is_admin,
    questions = [],
    queue_pos,
    read_only,
    status,
    welcome_message = '',
    centcom_connected,
    has_permabans,
  } = data;

  const allAnswered = questions.every((q) => q.response);
  const numAnswered = questions.filter((q) => q.response)?.length;

  return (
    <Window
      width={550}
      height={600}
      canClose={is_admin || status === 'interview_approved'}
    >
      <Window.Content scrollable>
        {(!read_only && (
          <Section title={t('ui.interview.welcome')}>
            <p>{linkifyText(welcome_message)}</p>
          </Section>
        )) || <RenderedStatus status={status} queue_pos={queue_pos} />}
        <Section
          title={t('ui.interview.questionnaire')}
          buttons={
            <span>
              <Button
                onClick={() => act('submit')}
                disabled={read_only || !allAnswered || !questions.length}
                icon="envelope"
                tooltip={
                  !allAnswered &&
                  `${t('ui.interview.please_answer_all_questions')}
                     ${numAnswered} / ${questions.length}`
                }
              >
                {read_only ? t('ui.interview.submitted') : t('ui.common.submit')}
              </Button>
              {!!is_admin && status === 'interview_pending' && (
                <span>
                  <Button disabled={!connected} onClick={() => act('adminpm')}>
                    {t('ui.interview.admin_pm')}
                  </Button>
                  <Button color="good" onClick={() => act('approve')}>
                    {t('ui.common.approve')}
                  </Button>
                  <Button color="bad" onClick={() => act('deny')}>
                    {t('ui.common.deny')}
                  </Button>
                  {!!centcom_connected && (
                    <Button
                      color={has_permabans ? 'bad' : 'average'}
                      tooltip={
                        has_permabans
                          ? t('ui.interview.user_has_permabans')
                          : ''
                      }
                      onClick={() => act('check_centcom')}
                    >
                      {t('ui.interview.check_centcom')}
                    </Button>
                  )}
                </span>
              )}
            </span>
          }
        >
          {!read_only && (
            <>
              <Box as="p" color="label">
                {t('ui.interview.please_answer_the_following_questions')}
                <ul>
                  <li>
                    {t('ui.interview.tip_press_enter_or_save')}
                  </li>
                  <li>
                    {t('ui.interview.tip_edit_until_submit')}
                  </li>
                  <li>{t('ui.interview.tip_press_submit_when_done')}</li>
                </ul>
              </Box>
              <NoticeBox info align="center">
                {t('ui.interview.cannot_edit_after_submit')}
              </NoticeBox>
            </>
          )}
          {questions.map((question) => (
            <QuestionArea key={question.qidx} {...question} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RenderedStatus = (props: { status: string; queue_pos: number }) => {
  const { t } = usePreferencesLocalization();
  const { status, queue_pos } = props;

  switch (status) {
    case STATUS.Approved:
      return <NoticeBox success>{t('ui.interview.interview_was_approved')}</NoticeBox>;
    case STATUS.Denied:
      return <NoticeBox danger>{t('ui.interview.interview_was_denied')}</NoticeBox>;
    default:
      return (
        <NoticeBox info>
          {t('ui.interview.answers_submitted_prefix')} {queue_pos}{' '}
          {t('ui.interview.answers_submitted_suffix')}
        </NoticeBox>
      );
  }
};

const QuestionArea = (props: Question) => {
  const { t } = usePreferencesLocalization();
  const { qidx, question, response } = props;
  const { act, data } = useBackend<Data>();
  const { is_admin, read_only } = data;

  const [userInput, setUserInput] = useState(response);

  const saveResponse = () => {
    act('update_answer', {
      qidx,
      answer: userInput,
    });
  };

  const changedResponse = userInput !== response;

  const saveAvailable = !read_only && !!userInput && changedResponse;

  const isSaved = !!response && !changedResponse;

  return (
    <Section
      title={`${t('ui.interview.question')} ${qidx}`}
      buttons={
        <Button
          disabled={!saveAvailable}
          onClick={saveResponse}
          icon={isSaved ? 'check' : 'save'}
        >
          {isSaved ? t('ui.common.saved') : t('ui.common.save')}
        </Button>
      }
    >
      <p>{linkifyText(question)}</p>
      {read_only || is_admin ? (
        <BlockQuote>{response || t('ui.interview.no_response')}</BlockQuote>
      ) : (
        <TextArea
          fluid
          height={10}
          maxLength={500}
          onChange={setUserInput}
          onEnter={saveResponse}
          placeholder={t('ui.interview.write_response_placeholder')}
          value={response || undefined}
        />
      )}
    </Section>
  );
};
