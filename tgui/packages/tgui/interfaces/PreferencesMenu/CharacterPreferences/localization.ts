import { useCallback } from 'react';
import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../types';
import { features } from '../preferences/features';
import dataLabelsEn from './locales/data_labels.en.json';
import dataLabelsRu from './locales/data_labels.ru.json';
import featureLabelsEn from './locales/feature_labels.en.json';
import featureLabelsRu from './locales/feature_labels.ru.json';
import uiCharacterEn from './locales/ui.character.en.json';
import uiCharacterRu from './locales/ui.character.ru.json';
import uiGameEn from './locales/ui.game.en.json';
import uiGameRu from './locales/ui.game.ru.json';
import gameFeaturesRu from '../GamePreferences/locales/features.ru.json';

export type InterfaceLanguage = 'english' | 'russian';

const EN_UI_BY_KEY = {
  ...(uiCharacterEn as Record<string, string>),
  ...(uiGameEn as Record<string, string>),
} as Record<string, string>;

const RU_UI_BY_KEY = {
  ...(uiCharacterRu as Record<string, string>),
  ...(uiGameRu as Record<string, string>),
} as Record<string, string>;

const UI_BY_LANGUAGE: Record<InterfaceLanguage, Record<string, string>> = {
  english: EN_UI_BY_KEY,
  russian: RU_UI_BY_KEY,
};

const GENDER_TEXT_KEY_BY_ID: Record<string, string> = {
  male: 'gender_male_pronouns',
  female: 'gender_female_pronouns',
  plural: 'gender_plural_pronouns',
  neuter: 'gender_neuter_pronouns',
};

// Feature IDs can differ from the normalized label ID.
// Keep explicit aliases for Character tab mismatches so ID lookup stays primary.
const CHARACTER_FEATURE_ID_ALIASES: Record<string, string> = {
  tts_voice: 'voice',
  tts_voice_pitch: 'voice_pitch_adjustment',
  fallback_to_blooper: 'vocal_bark_fallback',
  blooper_speech: 'vocal_bark',
  blooper_speech_speed: 'vocal_bark_speed',
  blooper_speech_pitch: 'vocal_bark_pitch',
  blooper_pitch_range: 'vocal_bark_range',
  allow_genitals_toggle: 'allow_genital_parts',
  allow_emissives_toggle: 'allow_emissives',
  allow_mismatched_parts_toggle: 'allow_mismatched_parts',
  feature_anus: 'anus_choice',
  feature_breasts: 'breast_choice',
  breasts_color: 'breast_color',
  breasts_lactation_toggle: 'breast_lactation',
  breasts_size: 'breast_size',
  breasts_skin_color: 'breasts_use_skin_color',
  breasts_skin_tone: 'breasts_use_skin_tone',
  caps_toggle: 'cap',
  feature_caps: 'cap_selection',
  caps_color: 'cap_colors',
  caps_emissive: 'caps_emissives',
  ears_toggle: 'ears',
  feature_ears: 'ears_selection',
  ears_color: 'ears_colors',
  ears_emissive: 'ears_emissives',
  feature_tail: 'tail_selection',
  tail_color: 'tail_colors',
  tail_emissive: 'tail_emissives',
  feature_snout: 'snout_selection',
  snout_color: 'snout_colors',
  snout_emissive: 'snout_emissives',
  feature_horns: 'horns_selection',
  horns_color: 'horns_colors',
  horns_emissive: 'horns_emissives',
  feature_frills: 'frills_selection',
  frills_color: 'frills_colors',
  frills_emissive: 'frills_emissives',
  feature_spines: 'spines_selection',
  spines_color: 'spines_colors',
  spines_emissive: 'spines_emissives',
  feature_wings: 'wings_selection',
  wings_color: 'wings_colors',
  wings_emissive: 'wings_emissives',
  pda_ringer: 'pda_ringtone',
  character_ad: 'character_advert',
  attraction: 'character_attraction',
  display_gender: 'character_gender',
  custom_species: 'custom_species_name',
  silicon_flavor_text: 'flavor_text_silicon',
  silicon_flavor_text_nsfw: 'flavor_text_silicon_nsfw',
  general_record: 'records_general',
  security_record: 'records_security',
  medical_record: 'records_medical',
  exploitable_info: 'records_exploitable',
  background_info: 'records_background',
  feature_penis: 'penis_choice',
  feature_testicles: 'testicles_choice',
  feature_vagina: 'vagina_choice',
  feature_womb: 'womb_choice',
  penis_skin_color: 'penis_uses_skin_color',
  penis_skin_tone: 'penis_uses_skin_tone',
  testicles_skin_color: 'testicles_uses_skin_color',
  testicles_skin_tone: 'testicles_uses_skin_tone',
  vagina_skin_color: 'vagina_uses_skin_color',
  vagina_skin_tone: 'vagina_uses_skin_tone',
  breasts_emissive: 'breast_emissives',
  feature_head_acc: 'head_accessory_selection',
  head_acc_toggle: 'head_accessory',
  head_acc_color: 'head_accessory_colors',
  head_acc_emissive: 'head_accessory_emissives',
  feature_neck_acc: 'neck_accessory_selection',
  neck_acc_toggle: 'neck_accessory',
  neck_acc_color: 'neck_accessory_colors',
  neck_acc_emissive: 'neck_accessory_emissives',
  feature_moth_antennae: 'moth_antenna_selection',
  moth_antennae_toggle: 'moth_antenna',
  moth_antennae_color: 'moth_antenna_colors',
  moth_antennae_emissive: 'moth_antenna_emissives',
  feature_moth_markings: 'moth_markings_selection',
  moth_markings_toggle: 'moth_markings',
  moth_markings_color: 'moth_markings_colors',
  moth_markings_emissive: 'moth_markings_emissives',
  feature_ipc_antenna: 'synth_antenna_selection',
  ipc_antenna_toggle: 'synth_antenna',
  ipc_antenna_color: 'synth_antenna_colors',
  ipc_antenna_emissive: 'synth_antenna_emissives',
  feature_ipc_screen: 'ipc_screen_selection',
  ipc_screen_color: 'ipc_screen_greyscale_color',
  ipc_screen_emissive: 'ipc_screen_emissive',
  feature_ipc_chassis: 'synth_chassis_selection',
  ipc_chassis_color: 'synth_chassis_colors',
  feature_ipc_head: 'synth_head_selection',
  ipc_head_color: 'synth_head_colors',
  feature_hair_opacity_toggle: 'hair_opacity_override',
  feature_skrell_hair: 'skrell_hair_selection',
  feature_xenohead: 'xeno_head_selection',
  xenohead_toggle: 'xeno_head',
  xenohead_color: 'xeno_head_colors',
  xenohead_emissive: 'xeno_head_emissives',
  feature_leg_type: 'leg_type',
  feature_mcolor2: 'mutant_color_2',
  feature_mcolor3: 'mutant_color_3',
  allow_mismatched_hair_color_toggle: 'allow_mismatched_hair_color',
  body_markings_toggle: 'body_markings',
  feature_body_markings: 'body_markings_selection',
  body_markings_color: 'body_markings_colors',
  body_markings_emissive: 'body_markings_emissives',
  heterochromia_toggle: 'heterochromia',
  feature_heterochromia: 'heterochromia_selection',
  heterochromia_color: 'heterochromia_colors',
  heterochromia_emissive: 'heterochromia_emissives',
  naga_sole: 'taur_naga_disable_hardened_soles',
  nv_color: 'night_vision_color',
  pod_hair_color: 'floral_hair_color',
  vox_bodycolor: 'vox_bodycolor',
  voice_actor: 'voice_actor',
  voice_actor_color: 'voice_actor_color',
  ic_chat_color: 'chat_message_color',
  blindfold_color: 'blindfold_color',
  paint_color: 'paint_color',
  socks_color: 'socks_color',
  undershirt_color: 'undershirt_color',
  jumpsuit_style: 'jumpsuit',
  hairstyle_name: 'hairstyle',
  facial_style_name: 'facial_hairstyle',
  facial_hair: 'facial_hairstyle',
  facial_hairstyle: 'facial_hairstyle',
};

const DATA_LABELS_EN = dataLabelsEn as Record<string, string>;
const DATA_LABELS_RU = dataLabelsRu as Record<string, string>;
const FEATURE_LABELS_EN = featureLabelsEn as Record<string, string>;
const FEATURE_LABELS_RU = featureLabelsRu as Record<string, string>;

const DATA_LABELS_BY_LANGUAGE: Record<InterfaceLanguage, Record<string, string>> = {
  english: DATA_LABELS_EN,
  russian: DATA_LABELS_RU,
};

const FEATURE_LABELS_BY_LANGUAGE: Record<InterfaceLanguage, Record<string, string>> = {
  english: FEATURE_LABELS_EN,
  russian: FEATURE_LABELS_RU,
};

type GameFeaturesRuJson = {
  feature_names_by_id?: Record<string, string>;
  feature_descriptions_by_id?: Record<string, string>;
};

const GAME_FEATURES_RU = gameFeaturesRu as GameFeaturesRuJson;

function toDataId(value: string): string {
  const normalized = (value ?? '')
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[:]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');

  return normalized || 'unknown';
}

const DATA_ID_PREFIXES = [
  'job',
  'language',
  'species',
  'quirk',
  'personality',
  'antag',
  'limb',
  'organ',
  'loadout_item',
  'loadout_group',
  'experience_type',
  'preview_option',
  'name_type',
  'background_state',
  'robotic_style',
];

function deriveDataIdCandidates(id: string): string[] {
  const normalized = toDataId(id);
  const candidates = new Set<string>([normalized]);

  const stripPrefix = (value: string) => {
    for (const prefix of DATA_ID_PREFIXES) {
      const token = `${prefix}_`;
      if (value.startsWith(token)) {
        return value.slice(token.length);
      }
    }
    return value;
  };

  const withoutPrefix = stripPrefix(normalized);
  if (withoutPrefix && withoutPrefix !== normalized) {
    candidates.add(withoutPrefix);
  }

  if (normalized.endsWith('_name')) {
    const nameBase = normalized.slice(0, -'_name'.length);
    candidates.add(nameBase);
    candidates.add(stripPrefix(nameBase));
  } else if (normalized.endsWith('_choice')) {
    const choiceBase = normalized.slice(0, -'_choice'.length);
    candidates.add(choiceBase);
    candidates.add(stripPrefix(choiceBase));
  } else if (normalized.endsWith('_option')) {
    const optionBase = normalized.slice(0, -'_option'.length);
    candidates.add(optionBase);
    candidates.add(stripPrefix(optionBase));
  } else if (normalized.endsWith('_preference')) {
    const preferenceBase = normalized.slice(0, -'_preference'.length);
    candidates.add(preferenceBase);
    candidates.add(stripPrefix(preferenceBase));
  }

  return [...candidates];
}

function deriveCharacterFeatureIdCandidates(featureId: string): string[] {
  const normalizedId = toDataId(featureId);
  const candidates: string[] = [];
  const pushUnique = (value: string) => {
    if (value && !candidates.includes(value)) {
      candidates.push(value);
    }
  };

  pushUnique(normalizedId);

  const aliased = CHARACTER_FEATURE_ID_ALIASES[normalizedId];
  if (aliased) {
    pushUnique(aliased);
  }

  if (normalizedId.startsWith('feature_')) {
    const base = normalizedId.slice('feature_'.length);
    if (base) {
      pushUnique(`${base}_selection`);
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_toggle')) {
    const base = normalizedId.slice(0, -'_toggle'.length);
    if (base) {
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_emissive')) {
    const base = normalizedId.slice(0, -'_emissive'.length);
    if (base) {
      pushUnique(`${base}_emissives`);
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_color')) {
    const base = normalizedId.slice(0, -'_color'.length);
    if (base) {
      pushUnique(`${base}_colors`);
      pushUnique(base);
    }
  }

  // Use the static feature registry as an id bridge for downstream keys:
  // featureId -> feature.name -> normalized id.
  const registryFeature = features[featureId];
  if (registryFeature?.name) {
    pushUnique(toDataId(registryFeature.name));
  }

  return candidates;
}

function resolveFeatureKey(
  language: InterfaceLanguage,
  featureId: string,
  suffix: 'name' | 'description',
  fallback?: string,
): string {
  for (const candidate of deriveCharacterFeatureIdCandidates(featureId)) {
    const key = `feature.${candidate}.${suffix}`;
    const translated =
      FEATURE_LABELS_BY_LANGUAGE[language][key] ??
      FEATURE_LABELS_BY_LANGUAGE.english[key];
    if (translated) {
      return translated;
    }
  }

  if (
    suffix === 'description' &&
    toDataId(fallback ?? '') === 'emissive_parts_glow_in_the_dark'
  ) {
    return language === 'russian'
      ? 'Эмиссивные части светятся в темноте.'
      : 'Emissive parts glow in the dark.';
  }

  return fallback ?? `feature.${toDataId(featureId)}.${suffix}`;
}

function translateUi(
  language: InterfaceLanguage,
  key: string,
  fallback?: string,
): string {
  const textKey = (key ?? '').toString();

  return (
    UI_BY_LANGUAGE[language][textKey] ??
    EN_UI_BY_KEY[textKey] ??
    fallback ??
    textKey
  );
}

function normalizeLanguage(raw: unknown): InterfaceLanguage | null {
  if (typeof raw !== 'string') {
    return null;
  }

  const value = raw.trim().toLowerCase();
  if (value === 'russian' || value === 'ru' || value.includes('russ')) {
    return 'russian';
  }
  if (value === 'english' || value === 'en' || value.includes('engl')) {
    return 'english';
  }

  return null;
}

function extractLanguage(raw: unknown, depth = 0): InterfaceLanguage | null {
  if (depth > 3 || raw == null) {
    return null;
  }

  const direct = normalizeLanguage(raw);
  if (direct) {
    return direct;
  }

  if (typeof raw === 'object') {
    const obj = raw as Record<string, unknown>;

    const commonValue = normalizeLanguage(obj.value);
    if (commonValue) {
      return commonValue;
    }

    // Some choiced payloads can carry selected value under alternative keys.
    for (const selectedKey of [
      'selected_value',
      'selectedValue',
      'selected_key',
      'selectedKey',
      'id',
      'key',
      'name',
    ]) {
      const selectedValue = normalizeLanguage(obj[selectedKey]);
      if (selectedValue) {
        return selectedValue;
      }
    }

    // Handle payloads where selected index points into choices list.
    if (Array.isArray(obj.choices) && typeof obj.selected === 'number') {
      const selectedByIndex = normalizeLanguage(obj.choices[obj.selected]);
      if (selectedByIndex) {
        return selectedByIndex;
      }
    }

    for (const key of [
      'interface_language',
      'language',
      'selected',
      'current',
    ]) {
      const nested = extractLanguage(obj[key], depth + 1);
      if (nested) {
        return nested;
      }
    }
  }

  return null;
}

export function getCharacterPreferencesLanguage(data: any): InterfaceLanguage {
  // Prefer top-level interface language because it's player-wide and authoritative.
  const candidates = [
    data?.interface_language,
    data?.game_preferences?.interface_language,
    data?.character_preferences?.interface_language,
    data?.character_preferences?.game_preferences?.interface_language,
    data?.character_preferences?.non_contextual?.interface_language,
  ];

  for (const raw of candidates) {
    const detected = extractLanguage(raw);
    if (detected) {
      return detected;
    }
  }

  return 'english';
}

export function localizeCharacterFeatureNameById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  return resolveFeatureKey(language, featureId, 'name', fallback);
}

export function localizeCharacterFeatureDescriptionById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  return resolveFeatureKey(language, featureId, 'description', fallback);
}

export function localizeDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  for (const candidate of deriveDataIdCandidates(id)) {
    const localized =
      DATA_LABELS_BY_LANGUAGE[language][candidate] ??
      DATA_LABELS_BY_LANGUAGE.english[candidate];
    if (localized) {
      return localized;
    }
  }

  return fallback ?? toDataId(id);
}

export function localizeCharacterDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  return localizeDataLabelById(language, id, fallback);
}

export function localizeGameFeatureNameById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  if (language === 'russian') {
    const localized = GAME_FEATURES_RU.feature_names_by_id?.[featureId];
    if (localized) {
      return localized;
    }
  }

  return fallback ?? featureId;
}

export function localizeGameFeatureDescriptionById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string | undefined {
  if (language === 'russian') {
    const localized = GAME_FEATURES_RU.feature_descriptions_by_id?.[featureId];
    if (localized) {
      return localized;
    }
  }

  return fallback;
}

export function localizeGender(
  language: InterfaceLanguage,
  genderId: string,
): string {
  const key = GENDER_TEXT_KEY_BY_ID[genderId];
  return key ? translateUi(language, key, genderId) : genderId;
}

export function getPreferencesLocalization(data: unknown) {
  const language = getCharacterPreferencesLanguage(data);

  return {
    language,
    t: (key: string, fallback?: string) => translateUi(language, key, fallback),
    localizeCharacterFeatureNameById: (featureId: string, fallback?: string) =>
      localizeCharacterFeatureNameById(language, featureId, fallback),
    localizeCharacterFeatureDescriptionById: (
      featureId: string,
      fallback?: string,
    ) => localizeCharacterFeatureDescriptionById(language, featureId, fallback),
    localizeCharacterDataLabelById: (id: string, fallback?: string) =>
      localizeCharacterDataLabelById(language, id, fallback),
    localizeGameFeatureNameById: (featureId: string, fallback?: string) =>
      localizeGameFeatureNameById(language, featureId, fallback),
    localizeGameFeatureDescriptionById: (
      featureId: string,
      fallback?: string,
    ) => localizeGameFeatureDescriptionById(language, featureId, fallback),
    localizeGender: (genderId: string) => localizeGender(language, genderId),
    localizeDataLabelById: (id: string, fallback?: string) =>
      localizeDataLabelById(language, id, fallback),
  };
}

export function usePreferencesLocalization(data?: unknown) {
  const { data: backendData } = useBackend<PreferencesMenuData>();
  const sourceData = data ?? backendData;
  const resolved = getPreferencesLocalization(sourceData);
  const { language } = resolved;

  const t = useCallback(
    (key: string, fallback?: string) => resolved.t(key, fallback),
    [language],
  );
  const localizeCharacterFeatureNameByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeCharacterFeatureNameById(featureId, fallback),
    [language],
  );
  const localizeCharacterFeatureDescriptionByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeCharacterFeatureDescriptionById(featureId, fallback),
    [language],
  );
  const localizeCharacterDataLabelByIdForLanguage = useCallback(
    (id: string, fallback?: string) =>
      resolved.localizeCharacterDataLabelById(id, fallback),
    [language],
  );
  const localizeGameFeatureNameByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeGameFeatureNameById(featureId, fallback),
    [language],
  );
  const localizeGameFeatureDescriptionByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeGameFeatureDescriptionById(featureId, fallback),
    [language],
  );
  const localizeGenderForLanguage = useCallback(
    (genderId: string) => resolved.localizeGender(genderId),
    [language],
  );
  const localizeDataLabelByIdForLanguage = useCallback(
    (id: string, fallback?: string) =>
      resolved.localizeDataLabelById(id, fallback),
    [language],
  );

  return {
    language,
    t,
    localizeCharacterFeatureNameById: localizeCharacterFeatureNameByIdForLanguage,
    localizeCharacterFeatureDescriptionById:
      localizeCharacterFeatureDescriptionByIdForLanguage,
    localizeCharacterDataLabelById: localizeCharacterDataLabelByIdForLanguage,
    // Character tab id-first aliases.
    localizeFeatureById: localizeCharacterFeatureNameByIdForLanguage,
    localizeFeatureDescriptionById:
      localizeCharacterFeatureDescriptionByIdForLanguage,
    localizeCharacterDataById: localizeCharacterDataLabelByIdForLanguage,
    localizeGameFeatureNameById: localizeGameFeatureNameByIdForLanguage,
    localizeGameFeatureDescriptionById:
      localizeGameFeatureDescriptionByIdForLanguage,
    localizeGender: localizeGenderForLanguage,
    localizeDataLabelById: localizeDataLabelByIdForLanguage,
  };
}
