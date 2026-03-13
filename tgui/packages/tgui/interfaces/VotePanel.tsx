import {
  Box,
  Button,
  Collapsible,
  Dimmer,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

enum VoteConfig {
  None = -1,
  Disabled = 0,
  Enabled = 1,
}

type Vote = {
  name: string;
  canBeInitiated: BooleanLike;
  config: VoteConfig;
  message: string;
};

type Option = {
  name: string;
  votes: number;
};

type ActiveVote = {
  vote: Vote;
  question: string | null;
  timeRemaining: number;
  displayStatistics: boolean;
  choices: Option[];
  countMethod: number;
};

type UserData = {
  ckey: string;
  isGhost: BooleanLike;
  isLowerAdmin: BooleanLike;
  isUpperAdmin: BooleanLike;
  singleSelection: string | null;
  multiSelection: string[] | null;
  countMethod: VoteSystem;
};

enum VoteSystem {
  VOTE_SINGLE = 1,
  VOTE_MULTI = 2,
}

type Data = {
  currentVote: ActiveVote;
  possibleVotes: Vote[];
  user: UserData;
  voting: string[];
  LastVoteTime: number;
  VoteCD: number;
};

export const VotePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { currentVote, user, LastVoteTime, VoteCD } = data;

  /**
   * Adds the voting type to title if there is an ongoing vote.
   */
  let windowTitle = t('ui.vote_panel.vote');
  if (currentVote) {
    windowTitle +=
      ': ' +
      (currentVote.question || currentVote.vote.name).replace(/^\w/, (c) =>
        c.toUpperCase(),
      );
  }

  return (
    <Window title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Section
            title={t('ui.vote_panel.create_vote')}
            buttons={
              !!user.isLowerAdmin && (
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="refresh"
                      content={t('ui.vote_panel.reset_cooldown')}
                      disabled={LastVoteTime + VoteCD <= 0}
                      onClick={() => act('resetCooldown')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="skull"
                      content={t('ui.vote_panel.toggle_dead_vote')}
                      disabled={!user.isUpperAdmin}
                      onClick={() => act('toggleDeadVote')}
                    />
                  </Stack.Item>
                </Stack>
              )
            }
          >
            <VoteOptions />
            {!!user.isLowerAdmin && currentVote && <VotersList />}
          </Section>
          <ChoicesPanel />
          <TimePanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const VoteOptionDimmer = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { LastVoteTime, VoteCD } = data;

  return (
    <Dimmer>
      <Box textAlign="center">
        <Box fontSize={2} bold>
          {t('ui.vote_panel.vote_cooldown')}
        </Box>
        <Box fontSize={1.5}>{Math.floor((VoteCD + LastVoteTime) / 10)}s</Box>
      </Box>
    </Dimmer>
  );
};

/**
 * The create vote options menu. Only upper admins can disable voting.
 * @returns A section visible to everyone with vote options.
 */
const VoteOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { possibleVotes, user, LastVoteTime, VoteCD } = data;

  return (
    <Stack.Item>
      <Collapsible title={t('ui.vote_panel.start_a_vote')}>
        <Section>
          {LastVoteTime + VoteCD > 0 && <VoteOptionDimmer />}
          <Stack vertical justify="space-between">
            {possibleVotes.map((option) => (
              <Stack.Item key={option.name}>
                <Stack>
                  {!!user.isLowerAdmin && (
                    <Stack.Item>
                      <Button.Checkbox
                        width={7}
                        color="red"
                        checked={option.config === VoteConfig.Enabled}
                        disabled={
                          !user.isUpperAdmin ||
                          option.config === VoteConfig.None
                        }
                        tooltip={
                          option.config === VoteConfig.None
                            ? t('ui.vote_panel.vote_cannot_be_disabled')
                            : null
                        }
                        content={
                          option.config === VoteConfig.Enabled
                            ? t('ui.common.enabled')
                            : t('ui.common.disabled')
                        }
                        onClick={() =>
                          act('toggleVote', {
                            voteName: option.name,
                          })
                        }
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button
                      width={12}
                      textAlign={'center'}
                      disabled={!option.canBeInitiated}
                      tooltip={option.message}
                      content={option.name}
                      onClick={() =>
                        act('callVote', {
                          voteName: option.name,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Collapsible>
    </Stack.Item>
  );
};

/**
 * View Voters by ckey. Admin only.
 * @returns A collapsible list of voters
 */
const VotersList = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Stack.Item>
      <Collapsible
        title={`${t('ui.vote_panel.view_active_voters')}${
          data.voting.length ? ` (${data.voting.length})` : ''
        }`}
      >
        <Section height={4} fill scrollable>
          {data.voting.map((voter) => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Section>
      </Collapsible>
    </Stack.Item>
  );
};

/**
 * The choices panel which displays all options in the list.
 * @returns A section visible to all users.
 */
const ChoicesPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { currentVote, user } = data;

  return (
    <Stack.Item grow>
      <Section fill scrollable title={t('ui.vote_panel.active_vote')}>
        {currentVote && currentVote.countMethod === VoteSystem.VOTE_SINGLE ? (
          <NoticeBox success>{t('ui.vote_panel.select_one_option')}</NoticeBox>
        ) : null}
        {currentVote &&
        currentVote.choices.length !== 0 &&
        currentVote.countMethod === VoteSystem.VOTE_SINGLE ? (
          <LabeledList>
            {currentVote.choices.map((choice) => (
              <Box key={choice.name}>
                <LabeledList.Item
                  label={choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                  textAlign="right"
                  buttons={
                    <Button
                      tooltip={
                        user.isGhost &&
                        t('ui.vote_panel.ghost_voting_disabled')
                      }
                      disabled={
                        user.singleSelection === choice.name || user.isGhost
                      }
                      onClick={() => {
                        act('voteSingle', { voteOption: choice.name });
                      }}
                    >
                      {t('ui.common.vote')}
                    </Button>
                  }
                >
                  {user.singleSelection &&
                    choice.name === user.singleSelection && (
                      <Icon
                        align="right"
                        mr={2}
                        color="green"
                        name="vote-yea"
                      />
                    )}
                  {currentVote.displayStatistics /* NOVA EDIT CHANGE - isLowerAdmin - ORIGINAL: {currentVote.displayStatistics */ ||
                  user.isLowerAdmin // NoVA EDIT ADDITION
                    ? `${choice.votes} ${t('ui.common.votes')}`
                    : null}
                </LabeledList.Item>
                <LabeledList.Divider />
              </Box>
            ))}
          </LabeledList>
        ) : null}
        {currentVote && currentVote.countMethod === VoteSystem.VOTE_MULTI ? (
          <NoticeBox success>{t('ui.vote_panel.select_any_options')}</NoticeBox>
        ) : null}
        {currentVote &&
        currentVote.choices.length !== 0 &&
        currentVote.countMethod === VoteSystem.VOTE_MULTI ? (
          <LabeledList>
            {currentVote.choices.map((choice) => (
              <Box key={choice.name}>
                <LabeledList.Item
                  label={choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                  textAlign="right"
                  buttons={
                    <Button
                      tooltip={
                        user.isGhost &&
                        t('ui.vote_panel.ghost_voting_disabled')
                      }
                      disabled={user.isGhost}
                      onClick={() => {
                        act('voteMulti', { voteOption: choice.name });
                      }}
                    >
                      {t('ui.common.vote')}
                    </Button>
                  }
                >
                  {user.multiSelection &&
                  user.multiSelection[user.ckey.concat(choice.name)] === 1 ? (
                    <Icon align="right" mr={2} color="blue" name="vote-yea" />
                  ) : null}
                  {
                    user.isLowerAdmin
                      ? `${choice.votes} ${t('ui.common.votes')}`
                      : '' /* NOVA EDIT*/
                  }
                </LabeledList.Item>
                <LabeledList.Divider />
              </Box>
            ))}
          </LabeledList>
        ) : null}
        {currentVote ? null : (
          <NoticeBox>{t('ui.vote_panel.no_vote_active')}</NoticeBox>
        )}
      </Section>
    </Stack.Item>
  );
};

/**
 * Countdown timer at the bottom. Includes a cancel vote option for admins.
 * @returns A section visible to everyone.
 */
const TimePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { currentVote, user } = data;

  return (
    <Stack.Item mt={1}>
      <Section>
        <Stack justify="space-between">
          <Box fontSize={1.5}>
            {t('ui.vote_panel.time_remaining')}:&nbsp;
            {currentVote?.timeRemaining || 0}s
          </Box>
          {!!user.isLowerAdmin && (
            <Stack>
              <Stack.Item>
                <Button
                  color="green"
                  disabled={!user.isLowerAdmin || !currentVote}
                  onClick={() => act('endNow')}
                >
                  {t('ui.vote_panel.end_now')}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="red"
                  disabled={!user.isLowerAdmin || !currentVote}
                  onClick={() => act('cancel')}
                >
                  {t('ui.vote_panel.cancel_vote')}
                </Button>
              </Stack.Item>
            </Stack>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};
