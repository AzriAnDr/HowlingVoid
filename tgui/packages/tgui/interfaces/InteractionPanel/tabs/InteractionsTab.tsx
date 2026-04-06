// THIS IS A NOVA SECTOR UI FILE
import { useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import {
  Box,
  Button,
  Collapsible,
  Icon,
  Modal,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../../backend';
import { usePreferencesLocalization } from '../../localization';

type AutoInteractionEntry = {
  speed: number;
  target: string;
  target_name: string;
  next_interaction: number;
  duration_limit_seconds?: number;
  thresholds?: Record<string, number>;
};

type Interaction = {
  categories: string[];
  interactions: Record<string, string[]>;
  erp_categories: string[];
  erp_interactions: Record<string, string[]>;
  interaction_names: Record<string, string>;
  descriptions: Record<string, string>;
  translation_keys: Record<string, string>;
  description_translation_keys: Record<string, string>;
  category_translation_keys: Record<string, string>;
  colors: Record<string, string>;
  interaction_usages: Record<string, string>;
  auto_interaction_info: Record<string, AutoInteractionEntry>;
  auto_interaction_speed_values: number[];
  self: string;
  ref_self: string;
  ref_user: string;
  user_name?: string;
  target_name?: string;
  arousalLimit: number;
  block_interact: BooleanLike;
  use_subtler: BooleanLike;
};

interface InteractionsTabPropsData {
  searchText;
  showCategories;
  categories;
  interactions;
}

type AutoInteractionModalProps = {
  interactionId: string;
  interactionName: string;
  interactionKey: string;
  onClose: () => void;
};

const thresholdStatOptions = ['pleasure', 'arousal', 'pain'] as const;

const getStatLabel = (stat: string, t: (key: string) => string) => {
  switch (stat) {
    case 'pleasure':
      return t('ui.interaction_panel.pleasure');
    case 'pain':
      return t('ui.interaction_panel.pain');
    default:
      return t('ui.interaction_panel.arousal');
  }
};

const getLocalizedText = (
  t: (key: string) => string,
  key: string,
  fallback: string,
) => {
  const localized = t(key);
  return localized !== key ? localized : fallback;
};

const AutoInteractionModal = ({
  interactionId,
  interactionName,
  interactionKey,
  onClose,
}: AutoInteractionModalProps) => {
  const { act, data } = useBackend<Interaction>();
  const { t } = usePreferencesLocalization(data);
  const {
    auto_interaction_info = {},
    auto_interaction_speed_values = [1, 5],
    arousalLimit,
    ref_self,
  } = data;

  const existing = auto_interaction_info[interactionKey];
  const [speed, setSpeed] = useState(
    existing?.speed || auto_interaction_speed_values[1],
  );
  const [enabledThresholds, setEnabledThresholds] = useState<
    Record<string, boolean>
  >({
    pleasure: !!existing?.thresholds?.pleasure,
    arousal: !!existing?.thresholds?.arousal,
    pain: !!existing?.thresholds?.pain,
  });
  const [thresholdValues, setThresholdValues] = useState<
    Record<string, number>
  >({
    pleasure: existing?.thresholds?.pleasure || Math.ceil(arousalLimit * 0.75),
    arousal: existing?.thresholds?.arousal || Math.ceil(arousalLimit * 0.75),
    pain: existing?.thresholds?.pain || Math.ceil(arousalLimit * 0.5),
  });
  const [durationEnabled, setDurationEnabled] = useState(
    !!existing?.duration_limit_seconds,
  );
  const [durationValue, setDurationValue] = useState(
    existing?.duration_limit_seconds || 15,
  );

  const activeThresholdStats = thresholdStatOptions.filter(
    (stat) => enabledThresholds[stat],
  );
  const existingSummary = activeThresholdStats.length
    ? activeThresholdStats
        .map((stat) => `${getStatLabel(stat, t)} ${thresholdValues[stat]}`)
        .join(' / ')
    : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.no_limit', 'No limit');
  const fullSummary =
    [
      durationEnabled ? `${durationValue}s timer` : null,
      activeThresholdStats.length ? existingSummary : null,
    ]
      .filter(Boolean)
      .join(' / ') || getLocalizedText(t, 'ui.interaction_panel.auto_repeat.no_limit', 'No limit');

  return createPortal(
    <Modal width="460px" height="520px">
      <Section
        fill
        title={`${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.title', 'Auto Repeat')}: ${interactionName}`}
        buttons={<Button color="red" icon="times" onClick={onClose} />}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Box
              p={1}
              style={{
                background:
                  'linear-gradient(135deg, rgba(219,39,119,0.22), rgba(17,24,39,0.65))',
                border: '1px solid rgba(244,114,182,0.35)',
                borderRadius: '8px',
              }}
            >
              <Box bold mb={0.5}>
                {existing
                  ? `${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.active_on', 'Active on')} ${existing.target_name}`
                  : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.setup', 'Repeat setup')}
              </Box>
              <Box color="label">
                {existing
                  ? `${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.every', 'Every')} ${existing.speed}s. ${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.stop_on', 'Stop on')}: ${fullSummary}.`
                  : getLocalizedText(
                      t,
                      'ui.interaction_panel.auto_repeat.setup_description',
                      'Choose the repeat interval, then enable any limits you want. Leave all limits off for infinite repeat.',
                    )}
              </Box>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={getLocalizedText(t, 'ui.interaction_panel.auto_repeat.timing', 'Timing')}
              fill
            >
              <Box mb={0.5}>
                {getLocalizedText(t, 'ui.interaction_panel.auto_repeat.repeat_every', 'Repeat every')}: {speed}{' '}
                {getLocalizedText(t, 'ui.interaction_panel.auto_repeat.seconds_short', 'sec')}
              </Box>
              <Slider
                minValue={auto_interaction_speed_values[0]}
                maxValue={auto_interaction_speed_values[1]}
                value={speed}
                step={1}
                stepPixelSize={32}
                onChange={(_, value) => setSpeed(value)}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={getLocalizedText(t, 'ui.interaction_panel.auto_repeat.duration', 'Duration')}
              fill
              buttons={
                <Box color="label">
                  {durationEnabled
                    ? `${durationValue}s`
                    : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.off', 'Off')}
                </Box>
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Button.Checkbox
                    checked={durationEnabled}
                    onClick={() => setDurationEnabled((prev) => !prev)}
                  >
                    {getLocalizedText(
                      t,
                      'ui.interaction_panel.auto_repeat.stop_after_time',
                      'Stop after a set time',
                    )}
                  </Button.Checkbox>
                </Stack.Item>
                {durationEnabled && (
                  <Stack.Item>
                    <Box mb={0.25}>
                      {getLocalizedText(t, 'ui.interaction_panel.auto_repeat.duration', 'Duration')}:{' '}
                      {durationValue} {getLocalizedText(t, 'ui.interaction_panel.auto_repeat.seconds_short', 'sec')}
                    </Box>
                    <Slider
                      minValue={1}
                      maxValue={60}
                      value={durationValue}
                      step={1}
                      stepPixelSize={5}
                      onChange={(_, value) => setDurationValue(value)}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={getLocalizedText(
                t,
                'ui.interaction_panel.auto_repeat.stop_conditions',
                'Stop Conditions',
              )}
              fill
              buttons={
                <Box color="label">
                  {activeThresholdStats.length
                    ? `${activeThresholdStats.length} ${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.active', 'active')}`
                    : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.infinite', 'Infinite')}
                </Box>
              }
            >
              <Stack vertical>
                {thresholdStatOptions.map((stat) => (
                  <Stack.Item key={stat}>
                    <Box
                      p={0.75}
                      style={{
                        background: enabledThresholds[stat]
                          ? 'rgba(236,72,153,0.12)'
                          : 'rgba(255,255,255,0.04)',
                        border: enabledThresholds[stat]
                          ? '1px solid rgba(236,72,153,0.4)'
                          : '1px solid rgba(255,255,255,0.08)',
                        borderRadius: '6px',
                      }}
                    >
                      <Stack vertical>
                        <Stack.Item>
                          <Button.Checkbox
                            checked={enabledThresholds[stat]}
                            onClick={() =>
                              setEnabledThresholds((prev) => ({
                                ...prev,
                                [stat]: !prev[stat],
                              }))
                            }
                          >
                            {getLocalizedText(t, 'ui.interaction_panel.auto_repeat.stop_at', 'Stop at')}{' '}
                            {getStatLabel(stat, t)}
                          </Button.Checkbox>
                        </Stack.Item>
                        {enabledThresholds[stat] && (
                          <Stack.Item>
                            <Box mb={0.25}>
                              {getStatLabel(stat, t)}: {thresholdValues[stat]}
                            </Box>
                            <Slider
                              minValue={1}
                              maxValue={arousalLimit}
                              value={thresholdValues[stat]}
                              step={1}
                              stepPixelSize={6}
                              onChange={(_, value) =>
                                setThresholdValues((prev) => ({
                                  ...prev,
                                  [stat]: value,
                                }))
                              }
                            />
                          </Stack.Item>
                        )}
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow />
          <Stack.Item>
            <Stack fill>
              {existing && (
                <Stack.Item grow>
                  <Button
                    fluid
                    color="red"
                    icon="stop"
                    onClick={() => {
                      act('auto_interaction', {
                        action: 'stop',
                        interaction: interactionId,
                        selfref: ref_self,
                      });
                      onClose();
                    }}
                  >
                    Stop
                  </Button>
                </Stack.Item>
              )}
              <Stack.Item grow>
                <Button
                  fluid
                  color="green"
                  icon={existing ? 'save' : 'play'}
                  onClick={() => {
                    act('auto_interaction', {
                      interaction: interactionId,
                      selfref: ref_self,
                      speed,
                      threshold_pleasure_enabled: enabledThresholds.pleasure,
                      threshold_pleasure_value: thresholdValues.pleasure,
                      threshold_arousal_enabled: enabledThresholds.arousal,
                      threshold_arousal_value: thresholdValues.arousal,
                      threshold_pain_enabled: enabledThresholds.pain,
                      threshold_pain_value: thresholdValues.pain,
                      duration_enabled: durationEnabled,
                      duration_value: durationValue,
                    });
                    onClose();
                  }}
                >
                  {existing
                    ? getLocalizedText(t, 'ui.interaction_panel.auto_repeat.update', 'Update')
                    : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.start', 'Start')}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>,
    document.body,
  );
};

export const InteractionsTab = ({
  searchText,
  showCategories,
  categories = [],
  interactions = {},
}: InteractionsTabPropsData) => {
  const { act, data } = useBackend<Interaction>();
  const { t } = usePreferencesLocalization(data);
  const [autoInteractionModal, setAutoInteractionModal] = useState<
    string | null
  >(null);
  const {
    descriptions = {},
    interaction_names = {},
    translation_keys = {},
    description_translation_keys = {},
    category_translation_keys = {},
    colors = {},
    interaction_usages = {},
    auto_interaction_info = {},
    ref_self,
    ref_user,
    block_interact,
    use_subtler,
  } = data;

  const searchLower = searchText.toLowerCase();

  const getInteractionName = (interactionId: string) =>
    interaction_names[interactionId] || interactionId;

  const localizeInteractionName = (interactionId: string) => {
    const fallback = getInteractionName(interactionId);
    const key = translation_keys[interactionId];
    if (!key) {
      return fallback;
    }
    const localized = t(key);
    return localized !== key ? localized : fallback;
  };

  const localizeInteractionDescription = (interactionId: string) => {
    const fallback = descriptions[interactionId] || '';
    const key = description_translation_keys[interactionId];
    if (!key) {
      return fallback;
    }
    const localized = t(key);
    return localized !== key ? localized : fallback;
  };

  const localizeCategory = (category: string) => {
    const key = category_translation_keys[category];
    if (!key) {
      return category;
    }
    const localized = t(key);
    return localized !== key ? localized : category;
  };

  const getInteractionTargetRef = (interactionId: string) =>
    interaction_usages[interactionId] === 'self' ? ref_user : ref_self;

  const getInteractionAutoKey = (interactionId: string) =>
    `${interactionId}_target_${getInteractionTargetRef(interactionId)}`;

  const renderInteractionButton = (interactionId: string) => {
    const localizedName = localizeInteractionName(interactionId);
    const localizedDescription = localizeInteractionDescription(interactionId);
    const autoInteractionKey = getInteractionAutoKey(interactionId);
    const autoInteractionEntry = auto_interaction_info[autoInteractionKey];
    const autoThresholds = autoInteractionEntry?.thresholds || {};
    const autoDurationSummary = autoInteractionEntry?.duration_limit_seconds
      ? `${autoInteractionEntry.duration_limit_seconds}s timer`
      : '';
    const autoThresholdSummary = thresholdStatOptions
      .filter((stat) => autoThresholds[stat] !== undefined)
      .map((stat) => `${getStatLabel(stat, t)} ${autoThresholds[stat]}`)
      .join(' / ');
    const autoSummary = [autoDurationSummary, autoThresholdSummary]
      .filter(Boolean)
      .join(' / ');

    return (
      <Stack key={interactionId} fill>
        <Stack.Item grow>
          <Button
            fluid
            lineHeight={1.75}
            disabled={block_interact}
            color={block_interact ? 'grey' : colors[interactionId]}
            tooltip={
              block_interact
                ? 'You cannot interact right now'
                : `${localizedName}${localizedDescription ? `: ${localizedDescription}` : ''}`
            }
            onClick={() =>
              act('interact', {
                interaction: interactionId,
                selfref: ref_self,
                userref: ref_user,
                use_subtler,
              })
            }
          >
            <Box
              style={{
                alignItems: 'center',
                display: 'flex',
                gap: '6px',
                width: '100%',
              }}
            >
              <Icon name="exclamation-circle" />
              <Box
                style={{
                  flex: 1,
                  minWidth: 0,
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {localizedName}
              </Box>
            </Box>
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color={autoInteractionEntry ? 'green' : 'default'}
            icon="repeat"
            tooltip={
              autoInteractionEntry
                ? `${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.tooltip_active', 'Auto repeat active')}: ${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.every', 'Every')} ${autoInteractionEntry.speed}s${
                    autoSummary
                      ? `, ${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.stop_at', 'stop at').toLowerCase()} ${autoSummary}`
                      : `, ${getLocalizedText(t, 'ui.interaction_panel.auto_repeat.no_stop_limit', 'no stop limit')}`
                  }`
                : getLocalizedText(t, 'ui.interaction_panel.auto_repeat.button', 'Auto repeat')
            }
            onClick={() => setAutoInteractionModal(interactionId)}
          />
        </Stack.Item>
      </Stack>
    );
  };

  const filterInteractions = (category: string) => {
    let categoryInteractions = interactions[category] || [];
    if (searchText) {
      categoryInteractions = categoryInteractions.filter((interactionId) =>
        localizeInteractionName(interactionId)
          .toLowerCase()
          .includes(searchLower),
      );
    }
    return categoryInteractions;
  };

  const allInteractions = useMemo(() => {
    return categories.flatMap((category) =>
      filterInteractions(category).map((interactionId) => ({
        id: interactionId,
        category,
      })),
    );
  }, [categories, interactions, searchLower, searchText]);

  const activeAutoCount = Object.keys(auto_interaction_info).length;
  const activeModalName = autoInteractionModal
    ? localizeInteractionName(autoInteractionModal)
    : '';

  return (
    <Stack fill vertical>
      {autoInteractionModal && (
        <AutoInteractionModal
          interactionId={autoInteractionModal}
          interactionKey={getInteractionAutoKey(autoInteractionModal)}
          interactionName={activeModalName}
          onClose={() => setAutoInteractionModal(null)}
        />
      )}
      <Stack.Item>
        <NoticeBox>
          <Stack align="center">
          <Stack.Item grow>
              {block_interact
                ? getLocalizedText(t, 'ui.interaction_panel.unable_to_interact', 'Unable to Interact')
                : getLocalizedText(t, 'ui.interaction_panel.able_to_interact', 'Able to Interact')}
            </Stack.Item>
            {activeAutoCount > 0 && (
              <Stack.Item>
                <Button
                  color="red"
                  icon="stop"
                  onClick={() => act('auto_interaction', { stop_all: true })}
                >
                  {getLocalizedText(
                    t,
                    'ui.interaction_panel.auto_repeat.stop_all',
                    'Stop All Repeats',
                  )}
                </Button>
              </Stack.Item>
            )}
          </Stack>
        </NoticeBox>
      </Stack.Item>
      <Stack.Item grow>
        {showCategories ? (
          categories.map((category) => {
            const filteredInteractions = filterInteractions(category);
            if (filteredInteractions.length === 0) return null;
            return (
              <Collapsible
                key={category}
                title={localizeCategory(category)}
                buttons={
                  <Box
                    color="grey"
                    fontSize={0.9}
                    style={{
                      minWidth: '88px',
                      textAlign: 'right',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    {filteredInteractions.length}{' '}
                    {getLocalizedText(t, 'ui.interaction_panel.interaction_count', 'interactions')}
                  </Box>
                }
              >
                <Section fill>
                  <Box mt={0.2}>
                    {filteredInteractions.map((interaction) =>
                      renderInteractionButton(interaction),
                    )}
                  </Box>
                </Section>
              </Collapsible>
            );
          })
        ) : (
          <Section fill>
            <Box mt={0.2}>
              {allInteractions.map(({ id }) => renderInteractionButton(id))}
            </Box>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
