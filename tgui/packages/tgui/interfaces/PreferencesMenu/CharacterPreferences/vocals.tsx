import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  FitText,
  Icon,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { features } from '../preferences/features';
import { FeatureValueInput as BaseFeatureValueInput } from '../preferences/features/base';
import type { PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

type VocalsProps = {
  handleClose: () => void;
  vocals: Record<string, string | number | boolean>;
};

type VocalFeature = {
  id: string;
};

const vocalFeatures: VocalFeature[] = [
  { id: 'voice_type' },
  { id: 'tts_voice' },
  { id: 'tts_voice_pitch' },
  { id: 'fallback_to_blooper' },
  { id: 'blooper_speech' },
  { id: 'blooper_speech_speed' },
  { id: 'blooper_speech_pitch' },
  { id: 'blooper_pitch_range' },
];

type VocalFeatureInputProps = {
  featureId: string;
  value: string | number | boolean;
};

function VocalFeatureInput(props: VocalFeatureInputProps) {
  const registryFeature = features[props.featureId];
  if (!registryFeature) {
    return null;
  }

  return (
    <BaseFeatureValueInput
      feature={registryFeature}
      featureId={props.featureId}
      value={props.value}
    />
  );
}

export function VocalsInput(props: VocalsProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const { vocals, handleClose } = props;
  const { t, localizeFeatureById } = usePreferencesLocalization(data);

  return (
    <Modal>
      <Box
        style={{
          minWidth: '280px',
        }}
      >
        <Section
          title={t('ui.character.voice_settings')}
          buttons={
            <Button color="red" onClick={handleClose}>
              {t('ui.character.close')}
            </Button>
          }
        >
          <LabeledList>
            {vocalFeatures.map((feature) => {
              const value = vocals[feature.id];
              const registryFeature = features[feature.id];
              if (value === undefined || !registryFeature) return null;

              return (
                <LabeledList.Item
                  key={feature.id}
                  label={localizeFeatureById(
                    feature.id,
                    registryFeature.name,
                  )}
                  verticalAlign="top"
                >
                  <VocalFeatureInput featureId={feature.id} value={value} />
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
      </Box>
    </Modal>
  );
}

type VoiceInputProps = {
  openVocalsInput: () => void;
};

export function VoiceInput(props: VoiceInputProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Button
      onClick={(event) => {
        props.openVocalsInput();
        event.cancelBubble = true;
        event.stopPropagation();
      }}
      textAlign="center"
      width="100%"
      height="28px"
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Icon
            style={{
              color: 'rgba(255, 255, 255, 0.5)',
              fontSize: '17px',
            }}
            name="fa-microphone"
          />
        </Stack.Item>

        <Stack.Item grow position="relative" mt={0.6}>
          <FitText maxFontSize={16} maxWidth={130}>
            {t('ui.character.character_voice')}
          </FitText>
        </Stack.Item>
      </Stack>
    </Button>
  );
}
