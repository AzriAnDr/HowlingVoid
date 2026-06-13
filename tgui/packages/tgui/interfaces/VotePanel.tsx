import { useState } from 'react';

import {
  Box,
  Button,
  Collapsible,
  Dimmer,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
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
  storytellerVote?: StorytellerVoteData;
};

type StorytellerModeInfo = {
  id: string;
  name: string;
  summary: string;
};

type StorytellerChance = {
  id: string | number;
  name: string;
  weight?: number;
  chancePercent: number;
  predicted?: BooleanLike;
};

type StorytellerReadyPlayer = {
  ckey: string;
  name: string;
  job: string;
};

type StorytellerVoteData = {
  enabled: BooleanLike;
  roundMode: string;
  modeFinalized: BooleanLike;
  selectedMode: string | null;
  infoRequested: BooleanLike;
  profileName?: string;
  phase?: number;
  phaseCap?: number;
  interfaceLanguage: string;
  menuChapter: string;
  storytellerSummary: string;
  modes: StorytellerModeInfo[];
  alternation: {
    playerCount: number;
    history: string[];
    forcedMode?: string;
    reason?: string;
    lowPopThreshold: number;
    highPopThreshold: number;
  };
  admin?: {
    playerCount: number;
    readyCount: number;
    readyPlayers: StorytellerReadyPlayer[];
    profileChances: StorytellerChance[];
    stageChances: StorytellerChance[];
  };
};

export const VotePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { currentVote, user, LastVoteTime, VoteCD } = data;

  if (
    data.storytellerVote &&
    (currentVote?.vote?.name === 'Storyteller Mode' ||
      data.storytellerVote.infoRequested)
  ) {
    return <StorytellerVotePanel />;
  }

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

const storytellerPalette = (chapter: string) => {
  if (chapter === 'sisterRay') {
    return {
      bg: '#2b1017',
      panel: 'rgba(255, 239, 191, 0.10)',
      panelStrong: 'rgba(255, 239, 191, 0.16)',
      border: 'rgba(239, 185, 76, 0.28)',
      text: '#ffecc6',
      dim: 'rgba(255, 236, 198, 0.72)',
      accent: '#efb94c',
      accent2: '#2fb78d',
      bad: '#bf226d',
    };
  }

  return {
    bg: '#050912',
    panel: 'rgba(132, 191, 255, 0.08)',
    panelStrong: 'rgba(132, 191, 255, 0.14)',
    border: 'rgba(132, 191, 255, 0.24)',
    text: '#e8f2ff',
    dim: 'rgba(222, 234, 248, 0.70)',
    accent: '#84bfff',
    accent2: '#a33040',
    bad: '#d65c72',
  };
};

const getStorytellerVoteText = (language: string | undefined) => {
  const ru = language === 'russian';
  return {
    windowTitle: ru ? 'Голосование за режим раунда' : 'Round Storyteller Selection',
    headerTitle: ru ? 'РЕЖИМ СТОРИТЕЛЛЕРА' : 'STORYTELLER MODE',
    voteOpen: ru ? 'Голосование открыто' : 'Vote is open',
    voteClosed: ru ? 'Голосование завершено' : 'Vote finished',
    infoOnly: ru ? 'Справка по режимам раунда' : 'Round mode reference',
    timeRemaining: ru ? 'Осталось' : 'Time remaining',
    selectedMode: ru ? 'Выбранный режим' : 'Selected mode',
    notSelected: ru ? 'Пока не выбран' : 'Not selected yet',
    alternationLock: ru ? 'Чередование режимов' : 'Alternation lock',
    nextRoundMode: ru ? 'Режим следующего раунда' : 'Next round mode',
    vote: ru ? 'Голосовать' : 'Vote',
    selected: ru ? 'Выбрано' : 'Selected',
    winningMode: ru ? 'Победивший режим' : 'Winning mode',
    lockedByAlternation: ru ? 'Будет применен по чередованию' : 'Locked by alternation',
    votes: ru ? 'голосов' : 'votes',
    tabVote: ru ? 'Голосование' : 'Vote',
    tabInfo: ru ? 'Справка' : 'Info',
    tabAdmin: ru ? 'Админ' : 'Admin',
    modesTitle: ru ? 'Режимы' : 'Modes',
    profilesTitle: ru ? 'Профили сторителлера' : 'Storyteller profiles',
    phasesTitle: ru ? 'Фазы' : 'Stages',
    alternationTitle: ru ? 'Чередование' : 'Alternation',
    recentModes: ru ? 'Последние выбранные режимы' : 'Recent selected modes',
    noHistory: ru ? 'Истории пока нет' : 'No history',
    extendedException: ru ? 'Исключение для Extended' : 'Extended exception',
    dynamicException: ru ? 'Исключение для Dynamic' : 'Dynamic exception',
    below: ru ? 'меньше' : 'Below',
    above: ru ? 'больше' : 'Above',
    players: ru ? 'игроков' : 'players',
    alternationDescription: ru
      ? 'Если один и тот же режим выбирается два раунда подряд, следующий выбор может быть заменен противоположным режимом. Исключения завязаны на текущую популяцию.'
      : 'If the same mode is selected for two rounds in a row, the next pick can be replaced with the opposite mode. Population exceptions still apply.',
    alternationReason: {
      dynamic: ru
        ? 'Последние два раунда были Extended.'
        : 'The previous two rounds were Extended.',
      extended: ru
        ? 'Последние два раунда были Dynamic.'
        : 'The previous two rounds were Dynamic.',
    },
    finishedHint: ru
      ? 'Голосование уже завершено. Это окно можно открыть из лобби, чтобы посмотреть выбранный режим и справку.'
      : 'The vote is already finished. This window can still be opened from the lobby to review the selected mode and reference information.',
    noActiveHint: ru
      ? 'Сейчас нет активного голосования за режим. Здесь показана справка и последний выбранный режим, если он уже есть.'
      : 'There is no active mode vote. This view shows reference information and the last selected mode if one exists.',
    currentState: ru ? 'Текущее состояние' : 'Current state',
    currentProfile: ru ? 'Текущий профиль' : 'Current profile',
    currentStage: ru ? 'Текущая фаза' : 'Current stage',
    roster: ru ? 'Состав' : 'Roster',
    serverPlayers: ru ? 'Игроков на сервере' : 'Players on server',
    readyPlayers: ru ? 'Готовых игроков' : 'Ready players',
    ckey: 'Ckey',
    character: ru ? 'Персонаж' : 'Character',
    jobIntent: ru ? 'Профессия' : 'Job intent',
    profileChances: ru ? 'Шансы профилей' : 'Profile chances',
    stageForecast: ru ? 'Прогноз фаз' : 'Stage forecast',
    endNow: ru ? 'Завершить сейчас' : 'End Now',
    cancelVote: ru ? 'Отменить воут' : 'Cancel Vote',
    dynamicName: 'Dynamic',
    extendedName: 'Extended',
    modeSummary: {
      dynamic: ru
        ? 'Активный станционный раунд: сторителлер может подготовить стартовые угрозы, реагировать на состав экипажа, запускать midround-события и выдавать помощь по ситуации.'
        : 'An active station round: the storyteller can prepare roundstart pressure, react to crew composition, run midround events, and provide situational aid.',
      extended: ru
        ? 'Более спокойный станционный раунд: естественное враждебное давление подавлено, но полезные и фоновые реакции сторителлера могут оставаться доступными.'
        : 'A calmer station round: natural hostile pressure is suppressed, while helpful and ambient storyteller reactions can remain available.',
    },
    profiles: [
      {
        name: 'Balanced Drama',
        text: ru
          ? 'Средний темп. Старается держать баланс между передышками, проблемами станции и антагонистическим давлением.'
          : 'Medium pacing. Tries to balance relief, station problems, and antagonist pressure.',
      },
      {
        name: 'Patient Custodian',
        text: ru
          ? 'Более осторожный профиль. Чаще дает станции время восстановиться и медленнее повышает давление.'
          : 'A more cautious profile. Gives the station more recovery time and raises pressure more slowly.',
      },
      {
        name: 'Aggressive Escalation',
        text: ru
          ? 'Более резкий профиль. Быстрее открывает опасные окна и активнее подталкивает раунд к кризисам.'
          : 'A sharper profile. Opens danger windows faster and pushes the round toward crises more actively.',
      },
    ],
    phases: [
      {
        name: ru ? 'Фаза 1' : 'Stage 1',
        text: ru
          ? 'Низкая стартовая интенсивность: легкие события, помощь и осторожная оценка экипажа.'
          : 'Low starting intensity: light events, aid, and cautious crew evaluation.',
      },
      {
        name: ru ? 'Фаза 2' : 'Stage 2',
        text: ru
          ? 'Средняя интенсивность: больше системных проблем и шире пул событий.'
          : 'Medium intensity: more station problems and a wider event pool.',
      },
      {
        name: ru ? 'Фаза 3' : 'Stage 3',
        text: ru
          ? 'Высокая интенсивность: серьезные угрозы становятся вероятнее при подходящем составе экипажа.'
          : 'High intensity: serious threats become more likely with enough crew coverage.',
      },
      {
        name: ru ? 'Фаза 4' : 'Stage 4',
        text: ru
          ? 'Максимальная интенсивность: крупные кризисы и тяжелое давление для больших, готовых составов.'
          : 'Maximum intensity: major crises and heavy pressure for large, ready rosters.',
      },
    ],
  };
};

const modeDisplayName = (
  mode: string | null | undefined,
  text: ReturnType<typeof getStorytellerVoteText>,
) => {
  if (mode === 'dynamic') {
    return text.dynamicName;
  }
  if (mode === 'extended') {
    return text.extendedName;
  }
  return text.notSelected;
};

const getAlternationReason = (
  mode: string,
  text: ReturnType<typeof getStorytellerVoteText>,
) => {
  return (
    text.alternationReason[
      mode as keyof typeof text.alternationReason
    ] || ''
  );
};

const StorytellerVotePanel = () => {
  const { act, data } = useBackend<Data>();
  const { currentVote, user, storytellerVote } = data;
  const [tab, setTab] = useState('vote');
  const palette = storytellerPalette(storytellerVote?.menuChapter || '');
  const text = getStorytellerVoteText(storytellerVote?.interfaceLanguage);
  const forcedMode = storytellerVote?.alternation?.forcedMode;
  const selectedMode = storytellerVote?.selectedMode || null;
  const voteActive = currentVote?.vote?.name === 'Storyteller Mode';
  const question = voteActive
    ? currentVote?.question || text.windowTitle
    : text.windowTitle;

  return (
    <Window title={question} width={780} height={620}>
      <Window.Content
        scrollable
        style={{
          background: `linear-gradient(145deg, ${palette.bg}, #050607)`,
          color: palette.text,
        }}
      >
        <Box
          p={2}
          style={{
            border: `1px solid ${palette.border}`,
            background: palette.panel,
            boxShadow: `0 0 36px ${palette.panelStrong}`,
          }}
        >
          <Stack align="center" justify="space-between">
            <Stack.Item>
              <Box fontSize={2} bold style={{ letterSpacing: '0.12em' }}>
                {text.headerTitle}
              </Box>
              <Box color={palette.dim}>
                {voteActive
                  ? text.voteOpen
                  : storytellerVote?.modeFinalized
                    ? `${text.selectedMode}: ${modeDisplayName(
                        selectedMode,
                        text,
                      )}`
                    : text.infoOnly}
              </Box>
            </Stack.Item>
            <Stack.Item textAlign="right">
              {voteActive ? (
                <>
                  <Box color={palette.dim}>{text.timeRemaining}</Box>
                  <Box fontSize={1.8} color={palette.accent}>
                    {currentVote?.timeRemaining || 0}s
                  </Box>
                </>
              ) : (
                <>
                  <Box color={palette.dim}>{text.voteClosed}</Box>
                  <Box fontSize={1.2} color={palette.accent}>
                    {modeDisplayName(selectedMode, text)}
                  </Box>
                </>
              )}
            </Stack.Item>
          </Stack>
          {!!forcedMode && (
            <NoticeBox mt={1}>
              {text.alternationLock}: {text.nextRoundMode} -{' '}
              {modeDisplayName(forcedMode, text)}.{' '}
              {getAlternationReason(forcedMode, text)}
            </NoticeBox>
          )}
        </Box>

        <Tabs mt={1}>
          <Tabs.Tab selected={tab === 'vote'} onClick={() => setTab('vote')}>
            {text.tabVote}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'overview'}
            onClick={() => setTab('overview')}
          >
            {text.tabInfo}
          </Tabs.Tab>
          {!!user.isLowerAdmin && (
            <Tabs.Tab
              selected={tab === 'admin'}
              onClick={() => setTab('admin')}
            >
              {text.tabAdmin}
            </Tabs.Tab>
          )}
        </Tabs>

        {tab === 'vote' && (
          <StorytellerVoteChoices
            palette={palette}
            forcedMode={forcedMode}
            selectedMode={selectedMode}
            text={text}
            voteActive={voteActive}
          />
        )}
        {tab === 'overview' && (
          <StorytellerVoteOverview palette={palette} text={text} />
        )}
        {tab === 'admin' && !!user.isLowerAdmin && (
          <StorytellerVoteAdmin palette={palette} text={text} />
        )}

        <Section mt={1}>
          <Stack justify="space-between" align="center">
            <Stack.Item color="label">
              {text.currentState}:{' '}
              {voteActive
                ? text.voteOpen
                : storytellerVote?.modeFinalized
                  ? `${text.winningMode}: ${modeDisplayName(
                      selectedMode,
                      text,
                    )}`
                  : text.noActiveHint}
            </Stack.Item>
            {!!user.isLowerAdmin && (
              <Stack.Item>
                <Button
                  color="green"
                  disabled={!voteActive}
                  onClick={() => act('endNow')}
                >
                  {text.endNow}
                </Button>
                <Button
                  ml={1}
                  color="red"
                  disabled={!voteActive}
                  onClick={() => act('cancel')}
                >
                  {text.cancelVote}
                </Button>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const StorytellerVoteChoices = (props: {
  palette: ReturnType<typeof storytellerPalette>;
  forcedMode?: string;
  selectedMode: string | null;
  text: ReturnType<typeof getStorytellerVoteText>;
  voteActive: boolean;
}) => {
  const { act, data } = useBackend<Data>();
  const { currentVote, user, storytellerVote } = data;
  const { palette, forcedMode, selectedMode, text, voteActive } = props;

  return (
    <Stack mt={1}>
      {(storytellerVote?.modes || []).map((mode) => {
        const choice = currentVote?.choices?.find(
          (entry) => entry.name.toLowerCase() === mode.name.toLowerCase(),
        );
        const selected = user.singleSelection === choice?.name;
        const locked = forcedMode === mode.id;
        const finalized = selectedMode === mode.id;
        const summary =
          text.modeSummary[mode.id as keyof typeof text.modeSummary] ||
          mode.summary;
        return (
          <Stack.Item key={mode.id} grow basis={0}>
            <Section
              title={modeDisplayName(mode.id, text)}
              buttons={
                locked ? (
                  <Box color={palette.accent}>
                    {text.lockedByAlternation}
                  </Box>
                ) : finalized ? (
                  <Box color={palette.accent}>{text.winningMode}</Box>
                ) : null
              }
            >
              <Box minHeight="72px" color={palette.dim}>
                {summary}
              </Box>
              <Stack align="center" justify="space-between" mt={1}>
                <Stack.Item>
                  {finalized && !voteActive && (
                    <Box color={palette.accent}>
                      <Icon name="trophy" /> {text.selectedMode}
                    </Box>
                  )}
                  {selected && voteActive && (
                    <Box color={palette.accent}>
                      <Icon name="vote-yea" /> {text.selected}
                    </Box>
                  )}
                  {!selected && choice && voteActive && (
                    <Button
                      icon="vote-yea"
                      disabled={!!user.isGhost}
                      onClick={() => act('voteSingle', { voteOption: choice.name })}
                    >
                      {text.vote}
                    </Button>
                  )}
                </Stack.Item>
                <Stack.Item color="label">
                  {!!data.user.isLowerAdmin &&
                    voteActive &&
                    `${choice?.votes || 0} ${text.votes}`}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const StorytellerVoteOverview = (props: {
  palette: ReturnType<typeof storytellerPalette>;
  text: ReturnType<typeof getStorytellerVoteText>;
}) => {
  const { data } = useBackend<Data>();
  const { storytellerVote } = data;
  const { palette, text } = props;
  const history = storytellerVote?.alternation?.history || [];

  return (
    <Stack mt={1} vertical>
      <Stack.Item>
        <Section title={text.modesTitle}>
          <Stack>
            {(storytellerVote?.modes || []).map((mode) => (
              <Stack.Item key={mode.id} grow basis={0}>
                <Box bold color={palette.accent}>
                  {modeDisplayName(mode.id, text)}
                </Box>
                <Box color={palette.dim}>
                  {text.modeSummary[
                    mode.id as keyof typeof text.modeSummary
                  ] || mode.summary}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <Section title={text.profilesTitle}>
              {text.profiles.map((profile) => (
                <Box key={profile.name} mb={1}>
                  <Box bold color={palette.accent}>
                    {profile.name}
                  </Box>
                  <Box color={palette.dim}>{profile.text}</Box>
                </Box>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section title={text.phasesTitle}>
              {text.phases.map((phase) => (
                <Box key={phase.name} mb={1}>
                  <Box bold color={palette.accent}>
                    {phase.name}
                  </Box>
                  <Box color={palette.dim}>{phase.text}</Box>
                </Box>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section title={text.alternationTitle}>
          <Box color={palette.dim}>{text.alternationDescription}</Box>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label={text.recentModes}>
                {history.length
                  ? history
                      .map((mode) => modeDisplayName(mode, text))
                      .join(' / ')
                  : text.noHistory}
              </LabeledList.Item>
              <LabeledList.Item label={text.extendedException}>
                {text.below}{' '}
                {storytellerVote?.alternation?.lowPopThreshold || 20}{' '}
                {text.players}
              </LabeledList.Item>
              <LabeledList.Item label={text.dynamicException}>
                {text.above}{' '}
                {storytellerVote?.alternation?.highPopThreshold || 50}{' '}
                {text.players}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ChanceBars = (props: {
  title: string;
  entries: StorytellerChance[];
  palette: ReturnType<typeof storytellerPalette>;
}) => {
  const { title, entries, palette } = props;
  return (
    <Section title={title}>
      {entries.map((entry) => (
        <Box key={entry.id} mb={1}>
          <Stack justify="space-between">
            <Stack.Item color={palette.text}>{entry.name}</Stack.Item>
            <Stack.Item color="label">{entry.chancePercent}%</Stack.Item>
          </Stack>
          <ProgressBar value={entry.chancePercent / 100} color="blue" />
        </Box>
      ))}
    </Section>
  );
};

const StorytellerVoteAdmin = (props: {
  palette: ReturnType<typeof storytellerPalette>;
  text: ReturnType<typeof getStorytellerVoteText>;
}) => {
  const { data } = useBackend<Data>();
  const admin = data.storytellerVote?.admin;
  const { palette, text } = props;

  return (
    <Stack mt={1} vertical>
      <Stack.Item>
        <Section title={text.currentState}>
          <LabeledList>
            <LabeledList.Item label={text.currentProfile}>
              {data.storytellerVote?.profileName || text.notSelected}
            </LabeledList.Item>
            <LabeledList.Item label={text.currentStage}>
              {data.storytellerVote?.phase || 1}/
              {data.storytellerVote?.phaseCap || 1}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={text.roster}>
          <LabeledList>
            <LabeledList.Item label={text.serverPlayers}>
              {admin?.playerCount || 0}
            </LabeledList.Item>
            <LabeledList.Item label={text.readyPlayers}>
              {admin?.readyCount || 0}
            </LabeledList.Item>
          </LabeledList>
          <Table mt={1}>
            <Table.Row header>
              <Table.Cell>{text.ckey}</Table.Cell>
              <Table.Cell>{text.character}</Table.Cell>
              <Table.Cell>{text.jobIntent}</Table.Cell>
            </Table.Row>
            {(admin?.readyPlayers || []).map((player) => (
              <Table.Row key={player.ckey} className="candystripe">
                <Table.Cell>{player.ckey}</Table.Cell>
                <Table.Cell>{player.name}</Table.Cell>
                <Table.Cell>{player.job}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <ChanceBars
              title={text.profileChances}
              entries={admin?.profileChances || []}
              palette={palette}
            />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <ChanceBars
              title={text.stageForecast}
              entries={admin?.stageChances || []}
              palette={palette}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
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
