// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Icon,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

type BodyExposureEntry = {
  part: string;
  state: 'open' | 'closed' | 'missing';
};

type HeaderInfo = {
  isTargetSelf: BooleanLike;
  user_name: string;
  target_name: string;
  pleasure: number;
  arousal: number;
  pain: number;
  theirPleasure: number;
  theirArousal: number;
  theirPain: number;
  arousalLimit: number;
  user_body_exposure: BodyExposureEntry[];
  target_body_exposure: BodyExposureEntry[];
};

const BODY_PART_FALLBACK_LABELS: Record<string, string> = {
  chest: 'Chest',
  groin: 'Groin',
  hands: 'Hands',
  feet: 'Feet',
  mouth: 'Mouth',
  ears: 'Ears',
  eyes: 'Eyes',
  cap: 'Cap',
  snout: 'Snout',
  horns: 'Horns',
  frills: 'Frills',
  fluff: 'Fluff',
  moth_antennae: 'Moth Antennae',
  neck_accessory: 'Neck Accessory',
  skrell_hair: 'Skrell Hair',
  synth_antenna: 'Synth Antenna',
  breasts: 'Breasts',
  penis: 'Penis',
  vagina: 'Vagina',
  anus: 'Anus',
  butt: 'Butt',
  belly: 'Belly',
  spines: 'Spines',
  tail: 'Tail',
  wings: 'Wings',
  taur: 'Taur',
  xeno_head: 'Xeno Head',
  xenodorsal: 'Xenodorsal',
};

const getExposureColor = (state: BodyExposureEntry['state']) => {
  switch (state) {
    case 'open':
      return 'good';
    case 'closed':
      return 'average';
    default:
      return 'grey';
  }
};

const getExposureIcon = (state: BodyExposureEntry['state']) => {
  switch (state) {
    case 'open':
      return 'eye';
    case 'closed':
      return 'eye-slash';
    default:
      return 'minus';
  }
};

const getBodyPartLabel = (
  t: (key: string) => string,
  part: string,
) => {
  const translationKey = `ui.interaction_panel.body_part.${part}`;
  const localized = t(translationKey);
  if (localized !== translationKey) {
    return localized;
  }
  return BODY_PART_FALLBACK_LABELS[part] || part;
};

export const InfoSection = () => {
  const { data } = useBackend<HeaderInfo>();
  const { t } = usePreferencesLocalization(data);
  const {
    isTargetSelf,
    user_name,
    target_name,
    pleasure,
    arousal,
    pain,
    theirPleasure,
    theirArousal,
    theirPain,
    arousalLimit,
    user_body_exposure = [],
    target_body_exposure = [],
  } = data;

  const renderExposureList = (entries: BodyExposureEntry[]) => (
    <Box
      style={{
        display: 'flex',
        flexWrap: 'wrap',
        gap: '4px',
      }}
    >
      {entries.map((entry) => (
        <Box
          key={entry.part}
          color={getExposureColor(entry.state)}
          style={{
            border: '1px solid rgba(255,255,255,0.15)',
            borderRadius: '4px',
            padding: '2px 6px',
            whiteSpace: 'nowrap',
            maxWidth: '100%',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          <Icon name={getExposureIcon(entry.state)} mr={0.35} />
          {getBodyPartLabel(t, entry.part)}
        </Box>
      ))}
    </Box>
  );

  return (
    <Section fill>
      <Stack fill>
        <Stack.Item
          basis={isTargetSelf ? '100%' : '50%'}
          grow={1}
          shrink={1}
          style={{ minWidth: 0 }}
        >
          <Section
            fill
            title={(
              <Box
                style={{
                  display: 'block',
                  width: '100%',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {`${t('ui.interaction_panel.your_body_title')} - ${user_name || t('ui.interaction_panel.you_label')}`}
              </Box>
            )}
          >
            <Stack vertical>
              <Stack.Item>
                {renderExposureList(user_body_exposure)}
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={pleasure}
                  maxValue={arousalLimit}
                  color="purple"
                >
                  <Icon name="heart" /> {t('ui.interaction_panel.pleasure')}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={arousal}
                  maxValue={arousalLimit}
                  color="pink"
                >
                  <Icon name="tint" /> {t('ui.interaction_panel.arousal')}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={pain}
                  maxValue={arousalLimit}
                  color="red"
                >
                  <Icon name="bolt" /> {t('ui.interaction_panel.pain')}
                </ProgressBar>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        {!isTargetSelf && (
          <Stack.Item
            basis="50%"
            grow={1}
            shrink={1}
            style={{ minWidth: 0 }}
          >
            <Section
              fill
              title={(
                <Box
                  style={{
                    display: 'block',
                    width: '100%',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {`${t('ui.interaction_panel.partner_title')} - ${target_name || t('ui.interaction_panel.partner_unknown')}`}
                </Box>
              )}
            >
              <Stack vertical>
                <Stack.Item>
                  {renderExposureList(target_body_exposure)}
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar
                    value={theirPleasure}
                    maxValue={arousalLimit}
                    color="purple"
                  >
                    <Icon name="heart" /> {t('ui.interaction_panel.pleasure')}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar
                    value={theirArousal}
                    maxValue={arousalLimit}
                    color="pink"
                  >
                    <Icon name="tint" /> {t('ui.interaction_panel.arousal')}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar
                    value={theirPain}
                    maxValue={arousalLimit}
                    color="red"
                  >
                    <Icon name="bolt" /> {t('ui.interaction_panel.pain')}
                  </ProgressBar>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
