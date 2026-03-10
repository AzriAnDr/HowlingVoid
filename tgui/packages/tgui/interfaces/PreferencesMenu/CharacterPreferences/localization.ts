import { useCallback } from 'react';
import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../types';
import dataLabelsEn from './locales/data_labels.en.json';
import dataLabelsRu from './locales/data_labels.ru.json';
import featureLabelsEn from './locales/feature_labels.en.json';
import featureLabelsRu from './locales/feature_labels.ru.json';
import uiCharacterEn from './locales/ui.character.en.json';
import uiCharacterRu from './locales/ui.character.ru.json';
import uiGameEn from './locales/ui.game.en.json';
import uiGameRu from './locales/ui.game.ru.json';

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

function resolveCharacterFeatureId(featureId: string): string {
  const normalizedId = toDataId(featureId);
  return CHARACTER_FEATURE_ID_ALIASES[normalizedId] ?? normalizedId;
}

function toFeatureLocaleKey(featureId: string, suffix: 'name' | 'description') {
  return `feature.${resolveCharacterFeatureId(featureId)}.${suffix}`;
}

function resolveFeatureKey(
  language: InterfaceLanguage,
  featureId: string,
  suffix: 'name' | 'description',
  fallback?: string,
): string {
  const key = toFeatureLocaleKey(featureId, suffix);

  return (
    FEATURE_LABELS_BY_LANGUAGE[language][key] ??
    FEATURE_LABELS_BY_LANGUAGE.english[key] ??
    fallback ??
    key
  );
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
    localizeGender: localizeGenderForLanguage,
    localizeDataLabelById: localizeDataLabelByIdForLanguage,
  };
}
