import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Flex,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Slider,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SoundVariant = {
  key: string;
  name: string;
  isMeta?: BooleanLike;
};

type EmoteOption = {
  key: string;
  name: string;
  message?: string;
  hasVariants?: BooleanLike;
  variants?: SoundVariant[];
};

type ColorInfo = {
  value?: string;
  timestamp?: number;
};

type EmoteData = {
  revision: number;
  key: string;
  name: string;
  message: string;
  text_enabled: BooleanLike;
  sound_enabled: BooleanLike;
  effect_enabled: BooleanLike;
  sound_key?: string;
  effect_key?: string;
  color?: ColorInfo;
  volume?: number;
};

type CustomEmoteEditorData = {
  emote: EmoteData;
  sounds: EmoteOption[];
  effects: EmoteOption[];
  limits: {
    key: number;
    name: number;
    message: number;
  };
  is_edit: BooleanLike;
  status?: {
    message: string;
    is_error: BooleanLike;
  };
};

type FormState = {
  key: string;
  name: string;
  message: string;
  textEnabled: boolean;
  soundEnabled: boolean;
  effectEnabled: boolean;
  soundKey: string;
  effectKey: string;
  color: string;
  volume: number;
};

const toBoolean = (value: BooleanLike | undefined, defaultValue = false) => {
  if (value === undefined || value === null) {
    return defaultValue;
  }
  const normalized = String(value).toLowerCase();
  return normalized !== '0' && normalized !== 'false';
};

const buildInitialForm = (emote?: EmoteData): FormState => ({
  key: emote?.key || '',
  name: emote?.name || '',
  message: emote?.message || '',
  textEnabled: toBoolean(emote?.text_enabled, true),
  soundEnabled: toBoolean(emote?.sound_enabled),
  effectEnabled: toBoolean(emote?.effect_enabled),
  soundKey: emote?.sound_key || '',
  effectKey: emote?.effect_key || '',
  color: emote?.color?.value || '#ffffff',
  volume: emote?.volume ?? 100,
});

const clampVolume = (
  value: number | undefined,
  min = 0,
  max = 125,
  fallback = 100,
): number => {
  if (value === undefined || value === null || Number.isNaN(value)) {
    return fallback;
  }
  return Math.round(Math.max(min, Math.min(max, value)));
};

const sortOptions = (options: EmoteOption[]) =>
  [...options].sort((a, b) => {
    const nameA = a.name?.toLowerCase() ?? '';
    const nameB = b.name?.toLowerCase() ?? '';
    if (nameA !== nameB) return nameA.localeCompare(nameB);
    return a.key.toLowerCase().localeCompare(b.key.toLowerCase());
  });

const filterOptions = (options: EmoteOption[], query: string) => {
  if (!query) return options;
  const lower = query.toLowerCase();
  return options.filter(
    (o) =>
      o.name.toLowerCase().includes(lower) ||
      o.key.toLowerCase().includes(lower) ||
      (o.message?.toLowerCase().includes(lower) ?? false),
  );
};

const renderOptionButtons = (
  options: EmoteOption[],
  selectedKey: string,
  onSelect: (next: string) => void,
) => (
  <Flex wrap="wrap">
    {options.map((option) => (
      <Flex.Item key={option.key} mx={0.25} my={0.25}>
        <Button
          selected={selectedKey === option.key}
          onClick={() => onSelect(option.key)}
          tooltip={
            option.message
              ? `*${option.key}: ${option.message}`
              : `*${option.key}`
          }
        >
          {option.name}
        </Button>
      </Flex.Item>
    ))}
  </Flex>
);

const renderSoundButtons = (
  options: EmoteOption[],
  selectedKey: string,
  onSelect: (next: string) => void,
  onOpenVariants: (option: EmoteOption) => void,
) => (
  <Flex wrap="wrap">
    {options.map((option) => {
      const hasVariants = toBoolean(option.hasVariants);
      const isSelected =
        selectedKey === option.key ||
        selectedKey.startsWith(`${option.key}:`);
      return (
        <Flex.Item key={option.key} mx={0.25} my={0.25}>
          {hasVariants ? (
            <Button
              selected={isSelected}
              icon="list"
              onClick={() => onOpenVariants(option)}
              tooltip={
                option.message
                  ? `*${option.key}: ${option.message} (click to choose variant)`
                  : `*${option.key} (click to choose variant)`
              }
            >
              {option.name} (choose)
            </Button>
          ) : (
            <Button
              selected={isSelected}
              onClick={() => onSelect(option.key)}
              tooltip={
                option.message
                  ? `*${option.key}: ${option.message}`
                  : `*${option.key}`
              }
            >
              {option.name}
            </Button>
          )}
        </Flex.Item>
      );
    })}
  </Flex>
);

export const CustomEmoteEditor = () => {
  const { act, data } = useBackend<CustomEmoteEditorData>();
  const { emote, sounds = [], effects = [], limits, is_edit, status } = data;
  const isEdit = toBoolean(is_edit);

  const [form, setForm] = useState<FormState>(() => buildInitialForm(emote));
  const [soundFilter, setSoundFilter] = useState<string>('');
  const [effectFilter, setEffectFilter] = useState<string>('');
  const [soundPickerOpen, setSoundPickerOpen] = useState<boolean>(false);
  const [effectPickerOpen, setEffectPickerOpen] = useState<boolean>(false);
  const [variantModal, setVariantModal] = useState<{
    open: boolean;
    option: EmoteOption | null;
  }>({ open: false, option: null });

  const sortedSounds = useMemo(() => sortOptions(sounds), [sounds]);
  const sortedEffects = useMemo(() => sortOptions(effects), [effects]);

  useEffect(() => {
    setForm(buildInitialForm(emote));
  }, [emote?.revision]);

  useEffect(() => {
    if (emote?.color?.timestamp) {
      setForm((prev) => ({
        ...prev,
        color: emote?.color?.value || prev.color || '#ffffff',
      }));
    }
  }, [emote?.color?.timestamp]);

  const toggleCheckbox = (
    field: 'textEnabled' | 'soundEnabled' | 'effectEnabled',
  ) => {
    setForm((prev) => ({ ...prev, [field]: !prev[field] }));
  };

  const handleSave = () => {
    act('save', {
      key: form.key,
      name: form.name,
      message: form.message,
      text_enabled: form.textEnabled,
      sound_enabled: form.soundEnabled,
      effect_enabled: form.effectEnabled,
      sound_key: form.soundKey,
      effect_key: form.effectKey,
      color: form.color,
      volume: form.volume,
    });
  };

  const resolveOptionLabel = (
    options: EmoteOption[],
    selectedKey: string,
    placeholder: string,
  ) => {
    if (!selectedKey) return placeholder;
    return options.find((o) => o.key === selectedKey)?.name || selectedKey;
  };

  const getSelectedSoundLabel = (selectedKey: string) => {
    if (!selectedKey) return 'Select Sound';
    const colonPos = selectedKey.indexOf(':');
    if (colonPos !== -1) {
      const baseKey = selectedKey.substring(0, colonPos);
      const variantPart = selectedKey.substring(colonPos + 1);
      const baseOption = sortedSounds.find((o) => o.key === baseKey);
      if (baseOption) {
        if (variantPart === 'default') return `${baseOption.name} (auto)`;
        if (variantPart === 'random') return `${baseOption.name} (random)`;
        if (variantPart.startsWith('random:')) {
          const category = variantPart.substring(7);
          return `${baseOption.name} (random ${category})`;
        }
        return `${baseOption.name} (${variantPart})`;
      }
    }
    return sortedSounds.find((o) => o.key === selectedKey)?.name || selectedKey;
  };

  return (
    <Window
      title={isEdit ? 'Edit Custom Emote' : 'Create Custom Emote'}
      width={640}
      height={580}
    >
      <Window.Content scrollable>
        <Stack vertical>
          {status?.message && (
            <Stack.Item>
              <NoticeBox danger={toBoolean(status.is_error)}>
                {status.message}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Section title="Emote Details">
              <Stack vertical>
                <Stack.Item>
                  <Box mb={0.5} bold>
                    Emote Key (what you type in chat)
                  </Box>
                  <Input
                    fluid
                    value={form.key}
                    maxLength={limits?.key}
                    placeholder="Enter key, e.g. wave"
                    onChange={(value) =>
                      setForm((prev) => ({ ...prev, key: value }))
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box mb={0.5} bold>
                    Emote Name
                  </Box>
                  <Input
                    fluid
                    value={form.name}
                    maxLength={limits?.name}
                    placeholder="Display name on the panel"
                    onChange={(value) =>
                      setForm((prev) => ({ ...prev, name: value }))
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box mb={0.5} bold>
                    Emote Message
                  </Box>
                  <TextArea
                    fluid
                    maxLength={limits?.message}
                    value={form.message}
                    placeholder="Optional message shown in chat"
                    onChange={(value) =>
                      setForm((prev) => ({ ...prev, message: value }))
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Flex wrap="wrap">
                    <Flex.Item mr={1} mb={0.5}>
                      <Button.Checkbox
                        checked={form.textEnabled}
                        onClick={() => toggleCheckbox('textEnabled')}
                      >
                        Text
                      </Button.Checkbox>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button.Checkbox
                        checked={form.soundEnabled}
                        onClick={() => toggleCheckbox('soundEnabled')}
                      >
                        Sound
                      </Button.Checkbox>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button.Checkbox
                        checked={form.effectEnabled}
                        onClick={() => toggleCheckbox('effectEnabled')}
                      >
                        Effect
                      </Button.Checkbox>
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Sound">
              <Stack vertical>
                <Stack.Item>
                  <Flex align="center" wrap="wrap">
                    <Flex.Item grow mr={1} mb={0.5}>
                      <Button
                        icon={soundPickerOpen ? 'chevron-up' : 'chevron-down'}
                        fluid
                        onClick={() => setSoundPickerOpen((prev) => !prev)}
                      >
                        {getSelectedSoundLabel(form.soundKey)}
                      </Button>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button
                        icon="play"
                        disabled={!form.soundKey}
                        onClick={() =>
                          act('preview_sound', {
                            sound_key: form.soundKey,
                            volume: form.volume,
                          })
                        }
                      >
                        Preview
                      </Button>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button
                        icon="ban"
                        disabled={!form.soundKey}
                        onClick={() =>
                          setForm((prev) => ({ ...prev, soundKey: '' }))
                        }
                      >
                        Clear
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
                {soundPickerOpen && (
                  <Stack.Item>
                    <Input
                      fluid
                      value={soundFilter}
                      placeholder="Filter sounds..."
                      onChange={setSoundFilter}
                    />
                  </Stack.Item>
                )}
                {soundPickerOpen && (
                  <Stack.Item>
                    {renderSoundButtons(
                      filterOptions(sortedSounds, soundFilter),
                      form.soundKey,
                      (next) => setForm((prev) => ({ ...prev, soundKey: next })),
                      (option) => setVariantModal({ open: true, option }),
                    )}
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Box mb={0.5} bold>
                    Volume
                  </Box>
                  <Flex align="center">
                    <Flex.Item grow mr={1}>
                      <Slider
                        value={form.volume}
                        minValue={0}
                        maxValue={125}
                        step={5}
                        stepPixelSize={5}
                        onChange={(_event, value) =>
                          setForm((prev) => ({
                            ...prev,
                            volume: clampVolume(value),
                          }))
                        }
                      />
                    </Flex.Item>
                    <Flex.Item width="4rem">
                      <NumberInput
                        value={form.volume}
                        minValue={0}
                        maxValue={125}
                        step={5}
                        onChange={(value) =>
                          setForm((prev) => ({
                            ...prev,
                            volume: clampVolume(value),
                          }))
                        }
                      />
                    </Flex.Item>
                    <Flex.Item ml={0.5}>
                      <Box inline>%</Box>
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Button
                        icon="undo"
                        tooltip="Reset to 100%"
                        onClick={() =>
                          setForm((prev) => ({ ...prev, volume: 100 }))
                        }
                      />
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Effect">
              <Stack vertical>
                <Stack.Item>
                  <Flex align="center" wrap="wrap">
                    <Flex.Item grow mr={1} mb={0.5}>
                      <Button
                        icon={effectPickerOpen ? 'chevron-up' : 'chevron-down'}
                        fluid
                        onClick={() => setEffectPickerOpen((prev) => !prev)}
                      >
                        {resolveOptionLabel(
                          sortedEffects,
                          form.effectKey,
                          'Select Effect',
                        )}
                      </Button>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button
                        icon="magic"
                        disabled={!form.effectKey}
                        tooltip="You must be alive in-game to preview effects."
                        onClick={() =>
                          act('preview_effect', {
                            effect_key: form.effectKey,
                          })
                        }
                      >
                        Preview
                      </Button>
                    </Flex.Item>
                    <Flex.Item mr={1} mb={0.5}>
                      <Button
                        icon="ban"
                        disabled={!form.effectKey}
                        onClick={() =>
                          setForm((prev) => ({ ...prev, effectKey: '' }))
                        }
                      >
                        Clear
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
                {effectPickerOpen && (
                  <Stack.Item>
                    <Input
                      fluid
                      value={effectFilter}
                      placeholder="Filter effects..."
                      onChange={setEffectFilter}
                    />
                  </Stack.Item>
                )}
                {effectPickerOpen && (
                  <Stack.Item>
                    {renderOptionButtons(
                      filterOptions(sortedEffects, effectFilter),
                      form.effectKey,
                      (next) =>
                        setForm((prev) => ({ ...prev, effectKey: next })),
                    )}
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Button Color">
              <Flex align="center" wrap="wrap">
                <Flex.Item mr={1} mb={0.5}>
                  <Box
                    width="3rem"
                    height="1.5rem"
                    style={{
                      border: '1px solid rgba(255, 255, 255, 0.2)',
                      backgroundColor: form.color || 'transparent',
                    }}
                  />
                </Flex.Item>
                <Flex.Item mr={1} mb={0.5}>
                  <Button
                    icon="palette"
                    onClick={() =>
                      act('pick_color', { current_color: form.color })
                    }
                  >
                    Choose Color
                  </Button>
                </Flex.Item>
                <Flex.Item mr={1} mb={0.5}>
                  <Button
                    icon="ban"
                    onClick={() =>
                      setForm((prev) => ({ ...prev, color: '' }))
                    }
                  >
                    Clear
                  </Button>
                </Flex.Item>
                <Flex.Item mb={0.5}>
                  <Box fontFamily="monospace">{form.color || 'Default'}</Box>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Flex align="center" wrap="wrap" style={{ width: '100%' }}>
              <Flex.Item mb={0.5}>
                <Button
                  color="red"
                  icon="trash"
                  minWidth={11}
                  onClick={() => act('discard')}
                >
                  Discard
                </Button>
              </Flex.Item>
              <Flex.Item grow />
              <Flex.Item mb={0.5}>
                <Button
                  color="green"
                  icon="save"
                  minWidth={11}
                  onClick={handleSave}
                >
                  Save
                </Button>
              </Flex.Item>
            </Flex>
          </Stack.Item>
        </Stack>
        {variantModal.open && variantModal.option && (
          <Dimmer>
            <Box
              backgroundColor="black"
              p={2}
              style={{
                border: '1px solid rgba(255, 255, 255, 0.3)',
                borderRadius: '5px',
                maxWidth: '450px',
                maxHeight: '80vh',
                overflow: 'auto',
              }}
            >
              <Stack vertical>
                <Stack.Item>
                  <Box bold fontSize={1.2} mb={1}>
                    Choose variant for {variantModal.option.name}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box color="label" mb={0.5}>
                    Behavior Options
                  </Box>
                  <Stack vertical>
                    {variantModal.option.variants
                      ?.filter((v) => toBoolean(v.isMeta))
                      .map((variant) => (
                        <Stack.Item key={variant.key}>
                          <Flex align="center">
                            <Flex.Item grow>
                              <Button
                                fluid
                                icon={
                                  variant.name.includes('Default')
                                    ? 'user'
                                    : 'random'
                                }
                                selected={form.soundKey === variant.key}
                                onClick={() =>
                                  setForm((prev) => ({
                                    ...prev,
                                    soundKey: variant.key,
                                  }))
                                }
                              >
                                {variant.name}
                              </Button>
                            </Flex.Item>
                            <Flex.Item ml={0.5}>
                              <Button
                                icon="play"
                                onClick={() =>
                                  act('preview_sound', {
                                    sound_key: variant.key,
                                    volume: form.volume,
                                  })
                                }
                                tooltip="Preview this sound"
                              />
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Divider />
                </Stack.Item>
                <Stack.Item>
                  <Box color="label" mb={0.5}>
                    Specific Sounds
                  </Box>
                  <Stack vertical>
                    {variantModal.option.variants
                      ?.filter((v) => !toBoolean(v.isMeta))
                      .map((variant) => (
                        <Stack.Item key={variant.key}>
                          <Flex align="center">
                            <Flex.Item grow>
                              <Button
                                fluid
                                selected={form.soundKey === variant.key}
                                onClick={() =>
                                  setForm((prev) => ({
                                    ...prev,
                                    soundKey: variant.key,
                                  }))
                                }
                              >
                                {variant.name}
                              </Button>
                            </Flex.Item>
                            <Flex.Item ml={0.5}>
                              <Button
                                icon="play"
                                onClick={() =>
                                  act('preview_sound', {
                                    sound_key: variant.key,
                                    volume: form.volume,
                                  })
                                }
                                tooltip="Preview this sound"
                              />
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item mt={1}>
                  <Button
                    fluid
                    icon="check"
                    color="green"
                    onClick={() =>
                      setVariantModal({ open: false, option: null })
                    }
                  >
                    Done
                  </Button>
                </Stack.Item>
              </Stack>
            </Box>
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};
