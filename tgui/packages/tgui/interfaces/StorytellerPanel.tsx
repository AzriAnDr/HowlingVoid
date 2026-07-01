import {
  getInterfaceLanguageUpdatedEvent,
  getLanguageUpdatedEvent,
  type PanelLanguage,
} from 'common/panelLocalization';
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import {
  resolveStorytellerLanguage as resolveStorytellerLanguageFromFile,
  formatMode as storytellerFormatMode,
  formatPercent as storytellerFormatPercent,
  formatTime as storytellerFormatTime,
  t as storytellerT,
  translateDepartmentLabel as storytellerTranslateDepartmentLabel,
  translateFamilyName as storytellerTranslateFamilyName,
  translateNeedSummary as storytellerTranslateNeedSummary,
  translateNeedTitle as storytellerTranslateNeedTitle,
  translateActionDescription as storytellerTranslateActionDescription,
  translateProfileName as storytellerTranslateProfileName,
  translateReason as storytellerTranslateReason,
  translateTooltip as storytellerTranslateTooltip,
} from './StorytellerPanel/localization';

type SnapshotData = {
  activePopulation: number;
  aliveCrew: number;
  recentDeaths: number;
  recentExplosions: number;
  activeAlarms: number;
  controlScore: number;
  dangerScore: number;
  livingAntagCount: number;
  livingAntagTypes: Record<string, number>;
  keyJobsOccupied: Record<string, string>;
  keyJobsFilledCount: number;
  totalKeyJobs: number;
  departmentStaffing: Record<string, number>;
  departmentMoney: Record<string, number>;
  cargoBudget: number;
  cookCount: number;
  serviceStaffCount: number;
  engineerCount: number;
  atmosCount: number;
  cargoStaffCount: number;
  minerCount: number;
  kitchenFoodTotal: number;
  serviceFoodTotal: number;
  oreSiloMaterialTotal: number;
  oreSiloMaterials: Record<string, number>;
  looseMaterialTotal: number;
  looseMaterials: Record<string, number>;
  materialGainRecent: number;
  activeRoundEventCount: number;
  activeRoundEvents: Record<string, number>;
  stationIntegrity: number;
  stationBreachTiles: number;
  brokenFloorCount: number;
  damagedWindowCount: number;
  damagedGrilleCount: number;
};

type DecisionEntry = {
  time: string;
  message: string;
};

type CooldownEntry = {
  family: string;
  remaining: number;
};

type ModifierEntry = {
  id: string;
  title: string;
  label: string;
  description?: string;
  value: number;
  remaining: number;
  positive: boolean;
};

type ActionEntry = {
  id: string;
  name: string;
  type?: string;
  category?: string;
  description?: string;
  context: string;
  polarity?: string;
  chancePercent?: number;
  family?: string;
  stage?: number;
  cost?: number;
  weight?: number;
  reason?: string;
  eligible?: boolean;
  isAntag?: boolean;
  discarded?: boolean;
  activeWindow?: boolean;
  needId?: string;
  needTitle?: string;
};

type ProfileOption = {
  id: string;
  name: string;
};

type RoundModeOption = {
  id: string;
  name: string;
};

type QueuedAntagEntry = {
  id: string;
  name: string;
  context: string;
  prefFlag?: string;
  reservedCost?: number;
  remaining?: number;
  scheduledFor?: string;
  sourceName?: string;
  storytellerGenerated?: boolean;
};

type QueuedActionEntry = {
  id: string;
  name: string;
  label: string;
  tone: 'good' | 'average';
};

type ScheduledActionEntry = {
  id: string;
  name: string;
  context: string;
  polarity?: string;
  source: string;
  sourceName?: string;
  storytellerGenerated: boolean;
  remaining: number;
  scheduledFor: string;
  position: number;
};

type NeedEntry = {
  id: string;
  title: string;
  department: string;
  severity: number;
  priority: number;
  family?: string;
  summary?: string;
  details?: Record<string, string | number>;
};

type Data = {
  enabled: boolean;
  ownsPacing: boolean;
  paused: boolean;
  interfaceLanguage?: string;
  panelLanguages?: Record<string, string>;
  profileName: string;
  profileId: string;
  profileOptions: ProfileOption[];
  manualProfileOverride: boolean;
  roundMode: string;
  roundModeOptions: RoundModeOption[];
  phase: number;
  phaseCap: number;
  manualPhaseOverride: boolean;
  budgetCap: number;
  threatBudget: number;
  aidBudget: number;
  positiveFatigueRemaining: number;
  negativeFatigueRemaining: number;
  latejoinHostileRemaining: number;
  positiveChannelRemaining: number;
  negativeChannelRemaining: number;
  latejoinRoundstartRemaining: number;
  skipNextPulse: boolean;
  roundStarted: boolean;
  defaultQueueDelay: number;
  currentContext: string;
  queuedPositiveActionId?: string;
  queuedNegativeActionId?: string;
  snapshot: SnapshotData;
  activeModifiers: ModifierEntry[];
  detectedNeeds: NeedEntry[];
  decisionHistory: DecisionEntry[];
  familyCooldowns: CooldownEntry[];
  eligiblePositiveActions: ActionEntry[];
  eligibleNegativeActions: ActionEntry[];
  eligibleAntagActions: ActionEntry[];
  scheduledActions: ScheduledActionEntry[];
  queuedAntagActions: QueuedAntagEntry[];
  eligibleActions: ActionEntry[];
  allActions: ActionEntry[];
};

const t = (language: PanelLanguage, key: string) => storytellerT(language, key);

let activeStorytellerLanguage: PanelLanguage = 'english';

const translateTooltip = (
  _label: string | React.JSX.Element,
  tooltip: string,
) => {
  return storytellerTranslateTooltip(activeStorytellerLanguage, tooltip);
};

const formatTime = (deciseconds: number, language: PanelLanguage) => {
  return storytellerFormatTime(deciseconds, language);
};

const formatMode = (value: string | undefined, language: PanelLanguage) => {
  return storytellerFormatMode(value, language);
};

const formatPercent = (value?: number) => {
  return storytellerFormatPercent(value);
};

const translateNeedTitle = (
  language: PanelLanguage,
  needId: string,
  fallback: string,
) => {
  return storytellerTranslateNeedTitle(language, needId, fallback);
};

const translateNeedSummary = (
  language: PanelLanguage,
  needId: string,
  fallback?: string,
) => {
  return storytellerTranslateNeedSummary(language, needId, fallback);
};

const translateDepartmentLabel = (
  language: PanelLanguage,
  department: string,
) => {
  return storytellerTranslateDepartmentLabel(language, department);
};

const translateProfileName = (
  language: PanelLanguage,
  profileId: string,
  fallback: string,
) => storytellerTranslateProfileName(language, profileId, fallback);

const translateFamilyName = (language: PanelLanguage, family: string) =>
  storytellerTranslateFamilyName(language, family);

const translateActionDescription = (
  language: PanelLanguage,
  actionId: string,
  fallback?: string,
) => storytellerTranslateActionDescription(language, actionId, fallback);

const translateReason = (language: PanelLanguage, reason?: string) => {
  return storytellerTranslateReason(language, reason);
};

const renderAssoc = (
  data: Record<string, string | number> | undefined,
  language: PanelLanguage,
) => {
  if (!data || !Object.keys(data).length) {
    return <Box color="label">{t(language, 'none')}</Box>;
  }

  return Object.entries(data)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => (
      <Box key={key}>
        {key}: {String(value)}
      </Box>
    ));
};

const tooltipLabel = (label: string, tooltip: string) => (
  <Tooltip content={translateTooltip(label, tooltip)}>
    <span>{label}</span>
  </Tooltip>
);

const Meter = (props: {
  label: string | React.JSX.Element;
  value: number;
  maxValue?: number;
  inverse?: boolean;
}) => {
  const { label, value, maxValue = 100, inverse } = props;
  const clampedValue = Math.max(0, Math.min(maxValue, value));
  const ranges = inverse
    ? {
        good: [0, Math.round(maxValue * 0.33)] as const,
        average: [
          Math.round(maxValue * 0.33),
          Math.round(maxValue * 0.66),
        ] as const,
        bad: [Math.round(maxValue * 0.66), Infinity] as const,
      }
    : {
        bad: [0, Math.round(maxValue * 0.33)] as const,
        average: [
          Math.round(maxValue * 0.33),
          Math.round(maxValue * 0.66),
        ] as const,
        good: [Math.round(maxValue * 0.66), Infinity] as const,
      };

  return (
    <LabeledList.Item label={label}>
      <ProgressBar value={clampedValue} maxValue={maxValue} ranges={ranges}>
        {Math.round(value)}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const MiniStat = (props: {
  label: string | React.JSX.Element;
  value: string | number;
  color?: string;
  tooltip?: string;
}) => (
  <Box
    backgroundColor="#20262d"
    p={1}
    style={{ border: '1px solid rgba(255,255,255,0.06)' }}
  >
    <Box color="label">
      {props.tooltip
        ? tooltipLabel(String(props.label), props.tooltip)
        : props.label}
    </Box>
    <Box bold color={props.color}>
      {props.value}
    </Box>
  </Box>
);

const cardChromeStyle = {
  borderRadius: '6px',
  boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.05)',
};

const NeedCard = (props: { entry: NeedEntry; language: PanelLanguage }) => {
  const { entry, language } = props;
  const color =
    entry.severity >= 75 ? 'bad' : entry.severity >= 45 ? 'average' : 'good';
  return (
    <Box
      key={`${entry.id}_${entry.title}`}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${color})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Box bold>
        {translateNeedTitle(language, entry.id, entry.title)} [
        {translateDepartmentLabel(language, entry.department)}]
      </Box>
      <Box color="label">
        {t(language, 'severity')} {entry.severity} | {t(language, 'priority')}{' '}
        {entry.priority}
      </Box>
      {!!entry.summary && (
        <Box mt={0.5}>
          {translateNeedSummary(language, entry.id, entry.summary)}
        </Box>
      )}
    </Box>
  );
};

const ActionCard = (props: {
  entry: ActionEntry;
  language: PanelLanguage;
  queueDelayLabel: string;
  onDiscard?: (id: string) => void;
  onQueue?: (id: string) => void;
  onForceNext?: (id: string) => void;
  onForceNow?: (id: string) => void;
}) => {
  const {
    entry,
    language,
    queueDelayLabel,
    onDiscard,
    onQueue,
    onForceNext,
    onForceNow,
  } = props;
  const color =
    entry.polarity === 'positive'
      ? 'good'
      : entry.polarity === 'negative'
        ? 'average'
        : undefined;
  const actionDescription = translateActionDescription(
    language,
    entry.id,
    entry.description,
  );
  return (
    <Box
      key={entry.id}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${color || 'label'})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          {actionDescription ? (
            <Tooltip content={actionDescription}>
              <Box bold inline>
                {entry.name}
              </Box>
            </Tooltip>
          ) : (
            <Box bold>{entry.name}</Box>
          )}
          <Box color="label">
            {formatMode(entry.polarity, language)} |{' '}
            {formatMode(entry.context, language)} | {t(language, 'chance')}{' '}
            {formatPercent(entry.chancePercent)} | {t(language, 'cost')}{' '}
            {entry.cost} | {t(language, 'weight')} {entry.weight}
            {!!entry.stage && ` | ${t(language, 'stage')} ${entry.stage}`}
            {entry.activeWindow ? ` | ${t(language, 'active_window')}` : ''}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            color={entry.discarded ? 'bad' : 'transparent'}
            icon={entry.discarded ? 'undo' : 'minus-circle'}
            onClick={() => onDiscard?.(entry.id)}
          >
            {entry.discarded
              ? t(language, 'return_action')
              : t(language, 'discard')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="hourglass-half"
            onClick={() => onQueue?.(entry.id)}
          >
            {t(language, 'queue')} ({queueDelayLabel})
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="clock"
            onClick={() => onForceNext?.(entry.id)}
          >
            {t(language, 'force_next')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            color="bad"
            icon="bolt"
            confirmContent={t(language, 'force_now_confirm')}
            onClick={() => onForceNow?.(entry.id)}
          >
            {t(language, 'force_now')}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
      {!!entry.needTitle && (
        <Box mt={0.5}>
          {t(language, 'targets_need')}:{' '}
          {translateNeedTitle(
            language,
            entry.needId || entry.needTitle,
            entry.needTitle,
          )}
        </Box>
      )}
      {!!entry.reason &&
        entry.reason !== 'Ready' &&
        entry.reason !== t(language, 'ready') && (
          <Box mt={0.5} color="label">
            {translateReason(language, entry.reason)}
          </Box>
        )}
    </Box>
  );
};

const ScheduledActionCard = (props: {
  entry: ScheduledActionEntry;
  language: PanelLanguage;
  onRemove?: (id: string) => void;
  onMove?: (id: string, direction: string) => void;
  onForceNow?: (id: string) => void;
  onSetDelay?: (id: string, delay: number) => void;
}) => {
  const { entry, language, onRemove, onMove, onForceNow, onSetDelay } = props;
  const [delayMinutes, setDelayMinutes] = useLocalState<number>(
    `storytellerScheduledDelay_${entry.id}`,
    Math.max(0, Math.ceil(entry.remaining / 600)),
  );
  const sourceLabel = entry.storytellerGenerated
    ? t(language, 'source_storyteller')
    : `${t(language, 'source_admin')}${
        entry.sourceName ? `: ${entry.sourceName}` : ''
      }`;
  const color =
    entry.polarity === 'positive'
      ? 'good'
      : entry.polarity === 'negative'
        ? 'average'
        : 'label';

  return (
    <Box
      key={entry.id}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${color})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            #{entry.position} {entry.name}
          </Box>
          <Box color="label">
            {formatMode(entry.polarity, language)} |{' '}
            {formatMode(entry.context, language)} | {sourceLabel}
          </Box>
          <Box color="label">
            {t(language, 'scheduled_for')}: {entry.scheduledFor} |{' '}
            {formatTime(entry.remaining, language)} {t(language, 'left')}
          </Box>
          <Stack mt={0.5} align="center">
            <Stack.Item>
              <NumberInput
                width="58px"
                step={1}
                minValue={0}
                maxValue={180}
                value={delayMinutes}
                onChange={(value) => setDelayMinutes(Number(value) || 0)}
              />
            </Stack.Item>
            <Stack.Item>
              <Box color="label">{t(language, 'minutes_short')}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                icon="clock"
                onClick={() =>
                  onSetDelay?.(
                    entry.id,
                    Math.max(0, Math.round(delayMinutes * 60 * 10)),
                  )
                }
              >
                {t(language, 'set_timer')}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                color="bad"
                icon="bolt"
                confirmContent={t(language, 'force_now_confirm')}
                onClick={() => onForceNow?.(entry.id)}
              >
                {t(language, 'force_now')}
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="angle-double-up"
            onClick={() => onMove?.(entry.id, 'top')}
          >
            {t(language, 'move_to_top')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="angle-up"
            onClick={() => onMove?.(entry.id, 'up')}
          >
            {t(language, 'move_up')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="angle-down"
            onClick={() => onMove?.(entry.id, 'down')}
          >
            {t(language, 'move_down')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="angle-double-down"
            onClick={() => onMove?.(entry.id, 'bottom')}
          >
            {t(language, 'move_to_bottom')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            color="bad"
            icon="times"
            confirmContent={t(language, 'cancel_queue_confirm')}
            onClick={() => onRemove?.(entry.id)}
          >
            {t(language, 'remove_from_queue')}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const QueuedAntagCard = (props: {
  entry: QueuedAntagEntry;
  language: PanelLanguage;
  onCancel?: (id: string) => void;
}) => {
  const { entry, language, onCancel } = props;
  const sourceLabel = entry.storytellerGenerated
    ? t(language, 'source_storyteller')
    : entry.sourceName
      ? `${t(language, 'source_admin')}: ${entry.sourceName}`
      : '';
  const hasTimer = typeof entry.remaining === 'number' && entry.remaining > 0;

  return (
    <Box
      key={`${entry.id}_${entry.name}`}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: '4px solid var(--color-average)',
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>{entry.name}</Box>
          <Box color="label">
            {formatMode(entry.context, language)}
            {!!entry.prefFlag && ` | ${t(language, 'pref')} ${entry.prefFlag}`}
            {!!entry.reservedCost &&
              ` | ${t(language, 'refund_threat')} ${entry.reservedCost}`}
            {!!sourceLabel && ` | ${sourceLabel}`}
          </Box>
          {hasTimer && (
            <Box color="label">
              {t(language, 'scheduled_for')}: {entry.scheduledFor} |{' '}
              {formatTime(entry.remaining || 0, language)} {t(language, 'left')}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            color="bad"
            icon="times"
            confirmContent={t(language, 'cancel_queue_confirm')}
            onClick={() => onCancel?.(entry.id)}
          >
            {t(language, 'cancel')}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const QueuedActionCard = (props: { entry: QueuedActionEntry }) => (
  <Box
    key={`${props.entry.label}_${props.entry.id}`}
    backgroundColor="#1f2731"
    p={1}
    mb={1}
    style={{
      ...cardChromeStyle,
      borderLeft: `4px solid var(--color-${props.entry.tone})`,
      background:
        'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
    }}
  >
    <Box bold>{props.entry.name}</Box>
    <Box color="label">{props.entry.label}</Box>
  </Box>
);

const ModifierCard = (props: {
  entry: ModifierEntry;
  language: PanelLanguage;
}) => {
  const { entry, language } = props;
  return (
    <Box
      key={entry.id}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${entry.positive ? 'good' : 'average'})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Box bold>{entry.title}</Box>
      <Box color="label">
        {entry.label} | {formatTime(entry.remaining, language)}{' '}
        {t(language, 'left')}
      </Box>
      {!!entry.description && <Box mt={0.5}>{entry.description}</Box>}
    </Box>
  );
};

const DecisionLine = (props: { entry: DecisionEntry; index: number }) => (
  <Box key={`${props.entry.time}_${props.index}`} mb={0.5}>
    <Box as="span" color="label">
      [{props.entry.time}]
    </Box>{' '}
    {props.entry.message}
  </Box>
);

const ModeNotice = (props: { data: Data; language: PanelLanguage }) => {
  const { data, language } = props;
  if (!data.enabled) {
    return <NoticeBox danger>{t(language, 'disabled_notice')}</NoticeBox>;
  }

  if (data.roundMode === 'extended') {
    return <NoticeBox danger>{t(language, 'extended_notice')}</NoticeBox>;
  }

  return <NoticeBox info>{t(language, 'dynamic_notice')}</NoticeBox>;
};

export const StorytellerPanel = () => {
  const { act, data } = useBackend<Data>();
  const [, setLanguageRevision] = useState(0);
  const language = resolveStorytellerLanguageFromFile(data);
  activeStorytellerLanguage = language;
  const [selectedAction, setSelectedAction] = useLocalState(
    'storytellerAction',
    data.allActions[0]?.id || '',
  );
  const [actionSearch, setActionSearch] = useLocalState(
    'storytellerActionSearch',
    '',
  );
  const [selectedPhase, setSelectedPhase] = useLocalState(
    'storytellerPhase',
    String(data.phase),
  );
  const [selectedProfile, setSelectedProfile] = useLocalState(
    'storytellerProfile',
    data.profileId,
  );
  const [selectedRoundMode, setSelectedRoundMode] = useLocalState(
    'storytellerRoundMode',
    data.roundMode,
  );
  const [queueDelayMinutes, setQueueDelayMinutes] = useLocalState(
    'storytellerQueueDelayMinutes',
    Math.max(1, Math.round((data.defaultQueueDelay || 0) / 600) || 5),
  );
  const [positiveLockMinutes, setPositiveLockMinutes] = useLocalState(
    'storytellerPositiveLockMinutes',
    Math.round(((data.positiveFatigueRemaining || 0) / 600) * 10) / 10,
  );
  const [positiveWindowMinutes, setPositiveWindowMinutes] = useLocalState(
    'storytellerPositiveWindowMinutes',
    Math.round(((data.positiveChannelRemaining || 0) / 600) * 10) / 10,
  );
  const [negativeLockMinutes, setNegativeLockMinutes] = useLocalState(
    'storytellerNegativeLockMinutes',
    Math.round(((data.negativeFatigueRemaining || 0) / 600) * 10) / 10,
  );
  const [negativeWindowMinutes, setNegativeWindowMinutes] = useLocalState(
    'storytellerNegativeWindowMinutes',
    Math.round(((data.negativeChannelRemaining || 0) / 600) * 10) / 10,
  );
  const [listSearch, setListSearch] = useLocalState(
    'storytellerListSearch',
    '',
  );
  const [tab, setTab] = useLocalState('storytellerTab', 'overview');

  useEffect(() => {
    if (data.profileId && selectedProfile !== data.profileId) {
      setSelectedProfile(data.profileId);
    }
  }, [data.profileId]);

  useEffect(() => {
    if (data.roundMode && selectedRoundMode !== data.roundMode) {
      setSelectedRoundMode(data.roundMode);
    }
  }, [data.roundMode]);

  useEffect(() => {
    const refreshLanguage = () => setLanguageRevision((value) => value + 1);
    window.addEventListener(
      getLanguageUpdatedEvent('storyteller'),
      refreshLanguage,
    );
    window.addEventListener(
      getInterfaceLanguageUpdatedEvent(),
      refreshLanguage,
    );
    return () => {
      window.removeEventListener(
        getLanguageUpdatedEvent('storyteller'),
        refreshLanguage,
      );
      window.removeEventListener(
        getInterfaceLanguageUpdatedEvent(),
        refreshLanguage,
      );
    };
  }, []);

  const phaseOptions =
    data.phaseCap > 1
      ? Array.from({ length: data.phaseCap }, (_, index) => ({
          displayText: `${t(language, 'stage')} ${index + 1}`,
          value: String(index + 1),
        }))
      : [
          {
            displayText: `${t(language, 'stage')} 1`,
            value: '1',
          },
        ];
  const profileOptions = data.profileOptions
    .slice()
    .sort((left, right) => left.name.localeCompare(right.name))
    .map((entry) => ({
      displayText: translateProfileName(language, entry.id, entry.name),
      value: entry.id,
    }));
  const roundModeOptions = data.roundModeOptions.map((entry) => ({
    displayText: formatMode(entry.id, language),
    value: entry.id,
  }));

  const actionOptions = data.allActions
    .filter((entry) => {
      if (!actionSearch.trim()) {
        return true;
      }
      const search = actionSearch.toLowerCase();
      return (
        entry.name.toLowerCase().includes(search) ||
        (entry.id || '').toLowerCase().includes(search) ||
        (entry.type || '').toLowerCase().includes(search) ||
        (entry.category || '').toLowerCase().includes(search) ||
        translateActionDescription(language, entry.id, entry.description)
          .toLowerCase()
          .includes(search) ||
        entry.context.toLowerCase().includes(search) ||
        (entry.polarity || '').toLowerCase().includes(search)
      );
    })
    .slice()
    .sort((left, right) => left.name.localeCompare(right.name))
    .map((entry) => ({
      displayText: `${entry.name} (${formatMode(entry.context, language)}${
        entry.isAntag ? `, ${t(language, 'antagonist_tag')}` : ''
      })`,
      value: entry.id,
    }));

  const filterListedAction = (entry: ActionEntry) => {
    if (!listSearch.trim()) {
      return true;
    }
    const search = listSearch.toLowerCase();
    return (
      entry.name.toLowerCase().includes(search) ||
      (entry.id || '').toLowerCase().includes(search) ||
      (entry.type || '').toLowerCase().includes(search) ||
      (entry.category || '').toLowerCase().includes(search) ||
      translateActionDescription(language, entry.id, entry.description)
        .toLowerCase()
        .includes(search) ||
      entry.context.toLowerCase().includes(search) ||
      (entry.polarity || '').toLowerCase().includes(search) ||
      (entry.family || '').toLowerCase().includes(search) ||
      (entry.needTitle || '').toLowerCase().includes(search) ||
      (entry.reason || '').toLowerCase().includes(search)
    );
  };

  const sortActionEntries = (left: ActionEntry, right: ActionEntry) =>
    (right.chancePercent || 0) - (left.chancePercent || 0) ||
    Number(!!left.discarded) - Number(!!right.discarded) ||
    left.name.localeCompare(right.name);

  const sortedNeeds = data.detectedNeeds
    .slice()
    .sort((left, right) => right.priority - left.priority);
  const positiveActions = data.eligiblePositiveActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const negativeActions = data.eligibleNegativeActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const antagActions = data.eligibleAntagActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const queuedPositiveName = data.allActions.find(
    (entry) => entry.id === data.queuedPositiveActionId,
  )?.name;
  const queuedNegativeName = data.allActions.find(
    (entry) => entry.id === data.queuedNegativeActionId,
  )?.name;
  const queuedNextActions: QueuedActionEntry[] = [
    ...(queuedPositiveName
      ? [
          {
            id: data.queuedPositiveActionId || 'queued_positive',
            name: queuedPositiveName,
            label: t(language, 'positive_channel'),
            tone: 'good' as const,
          },
        ]
      : []),
    ...(queuedNegativeName
      ? [
          {
            id: data.queuedNegativeActionId || 'queued_negative',
            name: queuedNegativeName,
            label: t(language, 'negative_channel'),
            tone: 'average' as const,
          },
        ]
      : []),
  ];
  const queueDelayDeciseconds = Math.max(
    0,
    Math.round(Number(queueDelayMinutes || 0) * 60 * 10),
  );
  const queueDelayLabel = formatTime(queueDelayDeciseconds, language);

  const doDiscard = (actionId: string) =>
    act('discard_action', { action_id: actionId });
  const doQueue = (actionId: string) =>
    act('queue_action_delayed', {
      action_id: actionId,
      delay: queueDelayDeciseconds,
    });
  const doForceNext = (actionId: string) =>
    act('force_action_next', { action_id: actionId });
  const doForceNow = (actionId: string) =>
    act('force_action', { action_id: actionId });
  const doCancelQueuedAntag = (queueId: string) =>
    act('cancel_queued_antag', { queue_id: queueId });
  const doRemoveScheduledAction = (queueId: string) =>
    act('remove_scheduled_action', { queue_id: queueId });
  const doMoveScheduledAction = (queueId: string, direction: string) =>
    act('move_scheduled_action', { queue_id: queueId, direction });
  const doForceScheduledAction = (queueId: string) =>
    act('force_scheduled_action', { queue_id: queueId });
  const doSetScheduledActionDelay = (queueId: string, delay: number) =>
    act('set_scheduled_action_delay', { queue_id: queueId, delay });

  return (
    <Window
      width={1280}
      height={800}
      title={t(language, 'window_title')}
      theme="admin"
    >
      <Window.Content
        scrollable
        style={{
          background:
            'radial-gradient(circle at top left, rgba(67,119,184,0.14), transparent 26%), radial-gradient(circle at top right, rgba(214,139,53,0.12), transparent 24%), linear-gradient(180deg, rgba(16,20,26,0.98), rgba(12,15,20,0.98)), repeating-linear-gradient(135deg, rgba(255,255,255,0.015) 0 2px, transparent 2px 14px)',
        }}
      >
        <Section
          title={t(language, 'header_title')}
          buttons={
            <>
              <Button disabled={data.paused} onClick={() => act('pause')}>
                {t(language, 'pause')}
              </Button>
              <Button disabled={!data.paused} onClick={() => act('resume')}>
                {t(language, 'resume')}
              </Button>
              <Button onClick={() => act('skip_next_pulse')}>
                {t(language, 'skip_next_pulse')}
              </Button>
            </>
          }
        >
          <Box
            mb={1}
            p={1}
            style={{
              borderRadius: '6px',
              background:
                'linear-gradient(90deg, rgba(53,93,145,0.55), rgba(28,44,67,0.4))',
              border: '1px solid rgba(132,179,255,0.18)',
            }}
          >
            <Box color="#d8e9ff" italic bold>
              {t(language, 'header_subtitle')}
            </Box>
          </Box>
          <ModeNotice data={data} language={language} />
          <Stack mt={1}>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'round_mode')}
                value={formatMode(data.roundMode, language)}
                tooltip="The current storyteller ruleset. Dynamic enables full pacing, while Extended suppresses roundstart and latejoin hostile storyteller picks and keeps only softer pressure in circulation."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'profile')}
                value={translateProfileName(
                  language,
                  data.profileId,
                  data.profileName,
                )}
                tooltip="The active storyteller temperament. Profiles retune cadence delays, budget pressure, escalation pace, and how aggressively the subsystem pushes the round."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'content_stage')}
                value={`${data.phase} / ${data.phaseCap}`}
                tooltip="The current content gate. Higher stages unlock heavier events and antagonists. By default it escalates automatically unless an admin pins it."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'trigger_window')}
                value={formatMode(data.currentContext, language)}
                tooltip="The scheduling window the storyteller currently treats as active. During the round this is normally Midround; before setup it is Roundstart."
              />
            </Stack.Item>
          </Stack>
        </Section>

        <Tabs fluid mt={1}>
          <Tabs.Tab
            selected={tab === 'overview'}
            onClick={() => setTab('overview')}
          >
            {t(language, 'overview_tab')}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'operations'}
            onClick={() => setTab('operations')}
          >
            {t(language, 'operations_tab')}
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'snapshot'}
            onClick={() => setTab('snapshot')}
          >
            {t(language, 'snapshot_tab')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 'logs'} onClick={() => setTab('logs')}>
            {t(language, 'logs_tab')}
          </Tabs.Tab>
        </Tabs>

        {tab === 'overview' && (
          <Stack mt={1}>
            <Stack.Item grow basis="50%">
              <Section title={t(language, 'round_overview')}>
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'enabled'),
                      'Whether the storyteller subsystem is turned on by config at all. If this is off, the panel becomes informational only.',
                    )}
                  >
                    {data.enabled ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'full_owner'),
                      'When enabled, storyteller suppresses the natural autonomous pacing from SSdynamic and SSevents and becomes the round pacing owner.',
                    )}
                  >
                    {data.ownsPacing ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'paused'),
                      'Pausing stops storyteller from scheduling new actions, but does not remove already running modifiers or already queued deliveries.',
                    )}
                  >
                    {data.paused ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'profile'),
                      'Balanced Drama is the baseline. Patient Custodian leans toward relief and slower escalation, while Aggressive Escalation shortens hostile cadence and unlocks heavier pressure faster.',
                    )}
                  >
                    {translateProfileName(
                      language,
                      data.profileId,
                      data.profileName,
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'round_mode'),
                      'Extended keeps relief and mild pressure. Dynamic enables the full storyteller pacing model, including hostile round pressure.',
                    )}
                  >
                    {formatMode(data.roundMode, language)}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'content_stage'),
                      'This is the active content gate. Higher stages unlock heavier storyteller actions. By default it escalates automatically with round time, population, casualties, and pressure unless an admin overrides it.',
                    )}
                  >
                    {data.phase} / {data.phaseCap}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'population'),
                      'The active connected player count the storyteller is currently reading for scaling population-sensitive timing and action weights.',
                    )}
                  >
                    {data.snapshot.activePopulation}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'alive_crew'),
                      'Living station crew detected by the storyteller snapshot. This strongly affects staffing checks, aid scaling, and cadence.',
                    )}
                  >
                    {data.snapshot.aliveCrew}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'living_antags'),
                      'Count of living antagonists currently detected on station. This feeds danger scoring and slows or blocks some extra hostile pressure.',
                    )}
                  >
                    {data.snapshot.livingAntagCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'station_integrity'),
                      'A structural health estimate versus the storyteller baseline snapshot. Lower integrity increases danger and pushes engineering-focused relief.',
                    )}
                  >
                    {Math.round(data.snapshot.stationIntegrity * 100)}%
                  </LabeledList.Item>
                </LabeledList>
                {data.phaseCap <= 1 && (
                  <NoticeBox mt={1}>
                    {t(language, 'stage_one_notice')}
                  </NoticeBox>
                )}
                {data.phaseCap > 1 &&
                  (data.manualPhaseOverride ? (
                    <NoticeBox mt={1} danger>
                      {t(language, 'manual_stage_notice')}
                    </NoticeBox>
                  ) : (
                    <NoticeBox mt={1} info>
                      {t(language, 'auto_stage_notice')}
                    </NoticeBox>
                  ))}
              </Section>

              <Section title={t(language, 'budgets_pressure')} mt={1}>
                <LabeledList>
                  <Meter
                    label={tooltipLabel(
                      t(language, 'control_score'),
                      'A stability score built from staffing, intact structure, resources, and general station control. Higher control supports more negative pressure.',
                    )}
                    value={data.snapshot.controlScore}
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'danger_score'),
                      'A crisis score built from deaths, explosions, alarms, station damage, active threats, and weak staffing. Higher danger pushes relief and slows extra punishment.',
                    )}
                    value={data.snapshot.dangerScore}
                    inverse
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'threat_budget'),
                      'Negative storyteller actions spend from this pool. It generally grows when the station is stable enough to withstand more pressure.',
                    )}
                    value={data.threatBudget}
                    maxValue={data.budgetCap}
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'aid_budget'),
                      'Positive storyteller actions spend from this pool. It generally grows when the station is struggling and needs intervention.',
                    )}
                    value={data.aidBudget}
                    maxValue={data.budgetCap}
                  />
                </LabeledList>
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="50%">
              <Section title={t(language, 'cadence')}>
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'positive_lock'),
                      'A short fatigue lock after a positive action fires. While this is active, the aid channel cannot immediately fire again.',
                    )}
                  >
                    <Stack vertical fill>
                      <Stack.Item>
                        {data.positiveFatigueRemaining > 0
                          ? formatTime(data.positiveFatigueRemaining, language)
                          : t(language, 'ready')}
                      </Stack.Item>
                      <Stack.Item mt={0.5}>
                        <Stack>
                          <Stack.Item grow>
                            <NumberInput
                              fluid
                              minValue={0}
                              maxValue={180}
                              step={0.5}
                              format={(value) =>
                                `${Number(value).toFixed(1)} ${t(language, 'minutes_short')}`
                              }
                              value={positiveLockMinutes}
                              onChange={(value) =>
                                setPositiveLockMinutes(Number(value) || 0)
                              }
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('set_cadence_timer', {
                                  timer_id: 'positive_lock',
                                  delay: Math.max(
                                    0,
                                    Math.round(positiveLockMinutes * 600),
                                  ),
                                })
                              }
                            >
                              {t(language, 'set_timer')}
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'positive_window'),
                      'Time until the positive channel is allowed to roll again. This scales with round state, population, and prior action impact.',
                    )}
                  >
                    <Stack vertical fill>
                      <Stack.Item>
                        {data.positiveChannelRemaining > 0
                          ? formatTime(data.positiveChannelRemaining, language)
                          : t(language, 'ready')}
                      </Stack.Item>
                      <Stack.Item mt={0.5}>
                        <Stack>
                          <Stack.Item grow>
                            <NumberInput
                              fluid
                              minValue={0}
                              maxValue={180}
                              step={0.5}
                              format={(value) =>
                                `${Number(value).toFixed(1)} ${t(language, 'minutes_short')}`
                              }
                              value={positiveWindowMinutes}
                              onChange={(value) =>
                                setPositiveWindowMinutes(Number(value) || 0)
                              }
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('set_cadence_timer', {
                                  timer_id: 'positive_window',
                                  delay: Math.max(
                                    0,
                                    Math.round(positiveWindowMinutes * 600),
                                  ),
                                })
                              }
                            >
                              {t(language, 'set_timer')}
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'negative_lock'),
                      'A short fatigue lock after a negative action fires. While this is active, the hostile channel cannot immediately fire again.',
                    )}
                  >
                    <Stack vertical fill>
                      <Stack.Item>
                        {data.negativeFatigueRemaining > 0
                          ? formatTime(data.negativeFatigueRemaining, language)
                          : t(language, 'ready')}
                      </Stack.Item>
                      <Stack.Item mt={0.5}>
                        <Stack>
                          <Stack.Item grow>
                            <NumberInput
                              fluid
                              minValue={0}
                              maxValue={180}
                              step={0.5}
                              format={(value) =>
                                `${Number(value).toFixed(1)} ${t(language, 'minutes_short')}`
                              }
                              value={negativeLockMinutes}
                              onChange={(value) =>
                                setNegativeLockMinutes(Number(value) || 0)
                              }
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('set_cadence_timer', {
                                  timer_id: 'negative_lock',
                                  delay: Math.max(
                                    0,
                                    Math.round(negativeLockMinutes * 600),
                                  ),
                                })
                              }
                            >
                              {t(language, 'set_timer')}
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'negative_window'),
                      'Time until the negative channel is allowed to roll again. This is dynamically scaled by population, damage, casualties, and previous impact.',
                    )}
                  >
                    <Stack vertical fill>
                      <Stack.Item>
                        {data.negativeChannelRemaining > 0
                          ? formatTime(data.negativeChannelRemaining, language)
                          : t(language, 'ready')}
                      </Stack.Item>
                      <Stack.Item mt={0.5}>
                        <Stack>
                          <Stack.Item grow>
                            <NumberInput
                              fluid
                              minValue={0}
                              maxValue={180}
                              step={0.5}
                              format={(value) =>
                                `${Number(value).toFixed(1)} ${t(language, 'minutes_short')}`
                              }
                              value={negativeWindowMinutes}
                              onChange={(value) =>
                                setNegativeWindowMinutes(Number(value) || 0)
                              }
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('set_cadence_timer', {
                                  timer_id: 'negative_window',
                                  delay: Math.max(
                                    0,
                                    Math.round(negativeWindowMinutes * 600),
                                  ),
                                })
                              }
                            >
                              {t(language, 'set_timer')}
                            </Button>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'latejoin_lock'),
                      'Cooldown before another hostile latejoin storyteller antagonist can be assigned.',
                    )}
                  >
                    {data.latejoinHostileRemaining > 0
                      ? formatTime(data.latejoinHostileRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'latejoin_warmup'),
                      'The initial start-of-round lock that prevents storyteller latejoin antagonists from firing too early.',
                    )}
                  >
                    {data.latejoinRoundstartRemaining > 0
                      ? formatTime(data.latejoinRoundstartRemaining, language)
                      : t(language, 'expired')}
                  </LabeledList.Item>
                </LabeledList>
              </Section>

              <Section title={t(language, 'current_snapshot')} mt={1}>
                <Stack>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'cargo_budget')}
                      value={data.snapshot.cargoBudget}
                      tooltip="Current cargo department budget. Low cargo funds can increase cargo-focused aid or economic support actions."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'active_alarms')}
                      value={data.snapshot.activeAlarms}
                      tooltip="Active alarms detected across the station. This contributes to danger and several department crisis analyzers."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'recent_deaths')}
                      value={data.snapshot.recentDeaths}
                      tooltip="Crew deaths seen within the storyteller's recent tracking window. This strongly increases danger and medical/security response pressure."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'recent_explosions')}
                      value={data.snapshot.recentExplosions}
                      tooltip="Recent on-station explosions seen within the storyteller tracking window. This boosts danger and several engineering-focused reactions."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'kitchen_service_food')}
                      value={`${data.snapshot.kitchenFoodTotal} / ${data.snapshot.serviceFoodTotal}`}
                      tooltip="Approximate food stock the storyteller sees in kitchen and service areas. Low values drive food-shortage relief."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'cargo_miners')}
                      value={`${data.snapshot.cargoStaffCount} / ${data.snapshot.minerCount}`}
                      tooltip="Current staffing snapshot for cargo technicians and miners. This affects cargo relief and several mining/material pressure calculations."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'breaches_floors')}
                      value={`${data.snapshot.stationBreachTiles} / ${data.snapshot.brokenFloorCount}`}
                      tooltip="Approximate breached space exposure versus broken floor tiles. Both feed structural damage estimates, but breaches are treated as more urgent."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'windows_grilles')}
                      value={`${data.snapshot.damagedWindowCount} / ${data.snapshot.damagedGrilleCount}`}
                      tooltip="Damaged windows and grilles detected by the structural scan. These help measure engineering backlog beyond raw integrity."
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'operations' && (
          <Stack mt={1}>
            <Stack.Item grow basis="42%">
              <Section title={t(language, 'controls')}>
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'round_mode_override'),
                      'Switch the storyteller between Dynamic and Extended for the current round. Extended suppresses storyteller antagonists and keeps only support plus softer pressure.',
                    )}
                  >
                    <Box ml={1}>
                      <Stack>
                        <Stack.Item grow>
                          <Dropdown
                            options={roundModeOptions}
                            selected={selectedRoundMode}
                            onSelected={(value) =>
                              setSelectedRoundMode(String(value))
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selectedRoundMode}
                            onClick={() =>
                              act('set_round_mode', {
                                round_mode: selectedRoundMode,
                              })
                            }
                          >
                            {t(language, 'set_mode')}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'profile_override'),
                      'Set a specific storyteller temperament manually. Auto returns control to population-weighted random profile selection.',
                    )}
                  >
                    <Box ml={1}>
                      <Stack>
                        <Stack.Item grow>
                          <Dropdown
                            options={profileOptions}
                            selected={selectedProfile}
                            onSelected={(value) =>
                              setSelectedProfile(String(value))
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selectedProfile}
                            onClick={() =>
                              act('set_profile', {
                                profile_id: selectedProfile,
                              })
                            }
                          >
                            {t(language, 'set_profile')}
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button onClick={() => act('auto_profile')}>
                            {t(language, 'auto')}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'set_content_stage'),
                      'Pins the maximum unlocked storyteller stage manually. Auto hands control back to the automatic escalation model.',
                    )}
                  >
                    <Box ml={1}>
                      <Stack>
                        <Stack.Item grow>
                          <Dropdown
                            options={phaseOptions}
                            selected={selectedPhase}
                            onSelected={(value) =>
                              setSelectedPhase(String(value))
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={data.phaseCap <= 1}
                            onClick={() =>
                              act('set_phase', { phase: selectedPhase })
                            }
                          >
                            {t(language, 'set_stage')}
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={data.phaseCap <= 1}
                            onClick={() => act('auto_phase')}
                          >
                            {t(language, 'auto')}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'force_action'),
                      'Search the storyteller catalog and arm or immediately force an action. Force NOW bypasses normal availability checks.',
                    )}
                  >
                    <Box ml={1}>
                      <Stack vertical fill>
                        <Stack.Item>
                          <Input
                            fluid
                            value={actionSearch}
                            placeholder={t(
                              language,
                              'search_storyteller_actions',
                            )}
                            onChange={(value) => setActionSearch(String(value))}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Stack>
                            <Stack.Item grow>
                              <Dropdown
                                options={actionOptions}
                                selected={selectedAction}
                                onSelected={(value) =>
                                  setSelectedAction(String(value))
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                disabled={!selectedAction}
                                onClick={() => doForceNext(selectedAction)}
                              >
                                {t(language, 'force_next')}
                              </Button>
                            </Stack.Item>
                            <Stack.Item>
                              <Button.Confirm
                                color="bad"
                                disabled={!selectedAction}
                                confirmContent={t(
                                  language,
                                  'force_now_confirm',
                                )}
                                onClick={() => doForceNow(selectedAction)}
                              >
                                {t(language, 'force_now')}
                              </Button.Confirm>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'queue_delay'),
                      'Delay used by the Queue buttons in the positive, negative, and antagonist lists. Automatic storyteller-picked midround actions use their own fixed five-minute preparation delay.',
                    )}
                  >
                    <Box ml={1}>
                      <Stack align="center">
                        <Stack.Item grow>
                          <NumberInput
                            fluid
                            minValue={1}
                            maxValue={120}
                            step={1}
                            value={Number(queueDelayMinutes || 1)}
                            onChange={(value) =>
                              setQueueDelayMinutes(Number(value))
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Box color="label">
                            {queueDelayLabel}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'scheduled_actions'),
                  'All storyteller actions currently waiting in the delayed execution queue, whether they were placed there automatically by storyteller cadence or manually by an administrator.',
                )}
                mt={1}
              >
                {data.scheduledActions.length ? (
                  data.scheduledActions.map((entry) => (
                    <ScheduledActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      onRemove={doRemoveScheduledAction}
                      onMove={doMoveScheduledAction}
                      onForceNow={doForceScheduledAction}
                      onSetDelay={doSetScheduledActionDelay}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_scheduled_actions')}</NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'detected_needs')} mt={1}>
                {sortedNeeds.length ? (
                  sortedNeeds.map((entry) => (
                    <NeedCard
                      key={`${entry.id}_${entry.title}`}
                      entry={entry}
                      language={language}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_detected_needs')}</NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'queued_next_actions')} mt={1}>
                {!queuedNextActions.length ? (
                  <NoticeBox>{t(language, 'no_queued_next')}</NoticeBox>
                ) : (
                  queuedNextActions.map((entry) => (
                    <QueuedActionCard
                      key={`${entry.id}_${entry.label}`}
                      entry={entry}
                    />
                  ))
                )}
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'queued_antagonists'),
                  'Antagonists already armed for roundstart, latejoin, or the next storyteller hostile window. Canceling a queued storyteller antag refunds any reserved threat budget.',
                )}
                mt={1}
              >
                {data.queuedAntagActions.length ? (
                  data.queuedAntagActions.map((entry) => (
                    <QueuedAntagCard
                      key={`${entry.id}_${entry.name}`}
                      entry={entry}
                      language={language}
                      onCancel={doCancelQueuedAntag}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_queued_antags')}</NoticeBox>
                )}
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="58%">
              <Section
                title={tooltipLabel(
                  t(language, 'active_modifiers'),
                  'Currently running temporary storyteller buffs and debuffs. These are live round effects with their own timers and department-specific behavior.',
                )}
              >
                {data.activeModifiers.length ? (
                  data.activeModifiers.map((entry) => (
                    <ModifierCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_active_modifiers')}</NoticeBox>
                )}
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'action_search'),
                  'Filters the positive, negative, and antagonist action lists below by name, context, polarity, family, need target, and availability reason.',
                )}
                mt={1}
              >
                <Input
                  fluid
                  value={listSearch}
                  placeholder={t(language, 'search_all_actions')}
                  onChange={(value) => setListSearch(String(value))}
                />
              </Section>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'positive_actions'),
                  'All positive storyteller actions currently in the catalog. Chance reflects the current positive candidate pool; unavailable actions remain visible with their blocking reason.',
                )}
                mt={1}
              >
                {positiveActions.length ? (
                  positiveActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      queueDelayLabel={queueDelayLabel}
                      onDiscard={doDiscard}
                      onQueue={doQueue}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_positive_filtered')}</NoticeBox>
                )}
              </Collapsible>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'negative_actions'),
                  'All non-antagonist negative storyteller actions currently in the catalog. Chance reflects the current negative candidate pool; unavailable actions remain visible with their blocking reason.',
                )}
                mt={1}
              >
                {negativeActions.length ? (
                  negativeActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      queueDelayLabel={queueDelayLabel}
                      onDiscard={doDiscard}
                      onQueue={doQueue}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_negative_filtered')}</NoticeBox>
                )}
              </Collapsible>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'antagonist_actions'),
                  'All storyteller antagonist actions across roundstart, midround, and latejoin contexts. Discard marks an antag as disabled for the rest of the round without removing it from the list.',
                )}
                mt={1}
              >
                {antagActions.length ? (
                  antagActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      queueDelayLabel={queueDelayLabel}
                      onDiscard={doDiscard}
                      onQueue={doQueue}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_antag_filtered')}</NoticeBox>
                )}
              </Collapsible>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'snapshot' && (
          <Stack mt={1}>
            <Stack.Item grow basis="50%">
              <Section
                title={tooltipLabel(
                  t(language, 'crew_staffing'),
                  'The staffing half of the storyteller snapshot. These values feed job coverage checks, department aid routing, and several event weight modifiers.',
                )}
              >
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'key_jobs_filled'),
                      'How many critical command and department anchor jobs are currently occupied out of the storyteller key-job list.',
                    )}
                  >
                    {data.snapshot.keyJobsFilledCount} /{' '}
                    {data.snapshot.totalKeyJobs}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'cooks_service'),
                      'Service staffing focus numbers used for food, janitorial, and hospitality-related needs.',
                    )}
                  >
                    {data.snapshot.cookCount} /{' '}
                    {data.snapshot.serviceStaffCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'engineers_atmos'),
                      'Engineering and atmospherics staffing counts used for repair, power, and environmental pressure calculations.',
                    )}
                  >
                    {data.snapshot.engineerCount} / {data.snapshot.atmosCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'cargo_miners'),
                      'Cargo office and mining staffing counts used for ore, logistics, and budget relief calculations.',
                    )}
                  >
                    {data.snapshot.cargoStaffCount} / {data.snapshot.minerCount}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'key_jobs'),
                    'A per-role occupancy breakdown for storyteller-critical jobs such as command, engineering, medical, and other round anchors.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.keyJobsOccupied, language)}
                </Collapsible>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'department_staffing'),
                    'A department-level headcount breakdown the storyteller uses for staffing-aware relief and pressure.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.departmentStaffing, language)}
                </Collapsible>
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'threats_events'),
                  'The danger-facing half of the storyteller snapshot. These values show live hostile presence and currently running event pressure.',
                )}
                mt={1}
              >
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'living_antags'),
                      'Total living antagonists currently detected by the storyteller snapshot.',
                    )}
                  >
                    {data.snapshot.livingAntagCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'active_round_events'),
                      'The number of currently active round-event instances the storyteller can see right now.',
                    )}
                  >
                    {data.snapshot.activeRoundEventCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'active_alarms'),
                      'The number of active alarms currently contributing to the danger picture.',
                    )}
                  >
                    {data.snapshot.activeAlarms}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'living_antag_types'),
                    'A live type breakdown of antagonists the storyteller sees in the current round snapshot.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.livingAntagTypes, language)}
                </Collapsible>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'active_event_breakdown'),
                    'A live breakdown of currently running round events grouped by event type. This is not a history log; entries disappear once those events end.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.activeRoundEvents, language)}
                </Collapsible>
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="50%">
              <Section
                title={tooltipLabel(
                  t(language, 'resources_economy'),
                  'The supply side of the storyteller snapshot: money, food, ore-silo stock, loose materials, and recent material intake.',
                )}
              >
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'cargo_budget'),
                      'Current cargo budget available to the station economy.',
                    )}
                  >
                    {data.snapshot.cargoBudget}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'kitchen_service_food'),
                      'Food stock the storyteller counts in kitchen and service spaces.',
                    )}
                  >
                    {data.snapshot.kitchenFoodTotal} /{' '}
                    {data.snapshot.serviceFoodTotal}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'silo_materials'),
                      'Total raw materials currently accessible in the ore silo.',
                    )}
                  >
                    {data.snapshot.oreSiloMaterialTotal}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'loose_materials'),
                      'Total loose material stacks found around the station during the heavy scan.',
                    )}
                  >
                    {data.snapshot.looseMaterialTotal}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'recent_material_gain'),
                      'Change in total known material stock since the previous heavy snapshot. Useful for detecting whether mining is keeping up.',
                    )}
                  >
                    {data.snapshot.materialGainRecent}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'department_money'),
                    'Per-department account balances available to the storyteller for budget-aware actions and needs.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.departmentMoney, language)}
                </Collapsible>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'silo_breakdown'),
                    'Raw material stock currently detected in the ore silo, grouped by material type.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.oreSiloMaterials, language)}
                </Collapsible>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'loose_breakdown'),
                    'Loose station-side material stacks grouped by material type.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.looseMaterials, language)}
                </Collapsible>
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'structural_condition'),
                  'Structural health metrics used to estimate station integrity and the engineering repair backlog.',
                )}
                mt={1}
              >
                <LabeledList>
                  <Meter
                    label={tooltipLabel(
                      t(language, 'station_integrity'),
                      'A high-level estimate of current station integrity compared to the storyteller baseline snapshot.',
                    )}
                    value={Math.round(data.snapshot.stationIntegrity * 100)}
                  />
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'breaches_floors'),
                      'Station breach tiles versus broken floors currently detected by the heavy scan.',
                    )}
                  >
                    {data.snapshot.stationBreachTiles} /{' '}
                    {data.snapshot.brokenFloorCount}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'windows_grilles'),
                      'Damaged windows and grilles currently detected by the heavy structural scan.',
                    )}
                  >
                    {data.snapshot.damagedWindowCount} /{' '}
                    {data.snapshot.damagedGrilleCount}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'logs' && (
          <Stack mt={1}>
            <Stack.Item grow basis="60%">
              <Section
                title={tooltipLabel(
                  t(language, 'recent_decisions'),
                  'A rolling log of storyteller decisions, scheduling outcomes, forced actions, and major subsystem state changes.',
                )}
              >
                {data.decisionHistory.length ? (
                  data.decisionHistory
                    .slice()
                    .reverse()
                    .map((entry, index) => (
                      <DecisionLine
                        key={`${entry.time}_${index}`}
                        entry={entry}
                        index={index}
                      />
                    ))
                ) : (
                  <NoticeBox>{t(language, 'no_decisions')}</NoticeBox>
                )}
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="40%">
              <Section
                title={tooltipLabel(
                  t(language, 'active_cooldowns'),
                  'Family cooldowns that temporarily block repeated actions from the same storyteller family, to prevent immediate repetition.',
                )}
              >
                {data.familyCooldowns.length ? (
                  data.familyCooldowns.map((entry) => (
                    <Box key={entry.family} mb={0.5}>
                      {translateFamilyName(language, entry.family)}:{' '}
                      {formatTime(entry.remaining, language)}
                    </Box>
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_cooldowns')}</NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'advanced_notes')} mt={1}>
                <Box mb={1}>{t(language, 'advanced_notes_body')}</Box>
                <Box color="label">{t(language, 'advanced_notes_footer')}</Box>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
