import { useCallback } from 'react';
import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../types';
import characterFeaturesRu from './locales/character_features.ru.json';
import dataLabelsEn from './locales/data_labels.en.json';
import dataLabelsRu from './locales/data_labels.ru.json';
import featureLabelsEn from './locales/feature_labels.en.json';
import featureLabelsRu from './locales/feature_labels.ru.json';
import jobsRu from './locales/jobs.ru.json';
import uiCharacterEn from './locales/ui.character.en.json';
import uiCharacterRu from './locales/ui.character.ru.json';
import uiGameEn from './locales/ui.game.en.json';
import uiGameRu from './locales/ui.game.ru.json';
import serverLabelsRu from './locales/server_labels.ru.json';

export type InterfaceLanguage = 'english' | 'russian';

type DataTable = {
  english: Record<string, string>;
  russian: Record<string, string>;
};

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

const RU_CHARACTER_FEATURE_NAMES_BY_EN = characterFeaturesRu as Record<
  string,
  string
>;

const RU_JOBS = jobsRu as {
  job_names?: Record<string, string>;
  alt_job_titles?: Record<string, string>;
};

const RU_SERVER_LABELS_BY_EN = serverLabelsRu as Record<string, string>;
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

function buildEnglishIdMap(
  source: Record<string, string>,
): Record<string, string> {
  const result: Record<string, string> = {};

  for (const key of Object.keys(source)) {
    const id = toDataId(key);
    if (result[id] === undefined) {
      result[id] = key;
    }
  }

  return result;
}

function buildLocalizedIdMap(
  source: Record<string, string>,
): Record<string, string> {
  const result: Record<string, string> = {};

  for (const [key, value] of Object.entries(source)) {
    const id = toDataId(key);
    if (result[id] === undefined) {
      result[id] = value;
    }
  }

  return result;
}

function createDataTable(source: Record<string, string>): DataTable {
  return {
    english: buildEnglishIdMap(source),
    russian: buildLocalizedIdMap(source),
  };
}

const CHARACTER_FEATURE_NAMES_BY_ID = createDataTable(
  RU_CHARACTER_FEATURE_NAMES_BY_EN,
);
const JOB_NAMES_BY_ID = createDataTable(RU_JOBS.job_names ?? {});
const ALT_JOB_TITLES_BY_ID = createDataTable(RU_JOBS.alt_job_titles ?? {});
const SERVER_LABELS_BY_ID = createDataTable(RU_SERVER_LABELS_BY_EN);

function resolveDataId(
  language: InterfaceLanguage,
  table: DataTable,
  id: string,
  fallback?: string,
): string {
  const normalizedId = toDataId(id);

  return (
    table[language][normalizedId] ??
    table.english[normalizedId] ??
    fallback ??
    normalizedId
  );
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
  const candidates = [
    data?.character_preferences?.game_preferences?.interface_language,
    data?.character_preferences?.non_contextual?.interface_language,
    data?.game_preferences?.interface_language,
    data?.interface_language,
  ];

  for (const raw of candidates) {
    const detected = extractLanguage(raw);
    if (detected) {
      return detected;
    }
  }

  return 'english';
}

export function localizeCharacterFeatureName(
  language: InterfaceLanguage,
  englishFeatureName: string,
  featureId?: string,
): string {
  if (featureId) {
    return resolveFeatureKey(
      language,
      featureId,
      'name',
      englishFeatureName,
    );
  }

  // Compatibility fallback for payloads without stable feature IDs.
  return resolveDataId(
    language,
    CHARACTER_FEATURE_NAMES_BY_ID,
    englishFeatureName,
    englishFeatureName,
  );
}

export function localizeCharacterFeatureDescription(
  language: InterfaceLanguage,
  englishFeatureDescription: string,
  featureId?: string,
): string {
  if (featureId) {
    return resolveFeatureKey(
      language,
      featureId,
      'description',
      englishFeatureDescription,
    );
  }

  // Compatibility fallback for payloads without stable feature IDs.
  return resolveDataId(
    language,
    SERVER_LABELS_BY_ID,
    englishFeatureDescription,
    englishFeatureDescription,
  );
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

export function localizeJobName(
  language: InterfaceLanguage,
  englishJobName: string,
  jobId?: string,
): string {
  return resolveDataId(
    language,
    JOB_NAMES_BY_ID,
    jobId ?? englishJobName,
    englishJobName,
  );
}

export function localizeAltJobTitle(
  language: InterfaceLanguage,
  englishAltTitle: string,
  altId?: string,
): string {
  return resolveDataId(
    language,
    ALT_JOB_TITLES_BY_ID,
    altId ?? englishAltTitle,
    englishAltTitle,
  );
}

export function localizeDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  const normalizedId = toDataId(id);
  const idFirst =
    DATA_LABELS_BY_LANGUAGE[language][normalizedId] ??
    DATA_LABELS_BY_LANGUAGE.english[normalizedId];
  if (idFirst) {
    return idFirst;
  }

  return resolveDataId(language, SERVER_LABELS_BY_ID, id, fallback);
}

export function localizeDataLabel(
  language: InterfaceLanguage,
  text: string,
): string {
  return resolveDataId(language, SERVER_LABELS_BY_ID, text, text);
}

export function localizeCharacterDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  const normalizedId = toDataId(id);
  return (
    DATA_LABELS_BY_LANGUAGE[language][normalizedId] ??
    DATA_LABELS_BY_LANGUAGE.english[normalizedId] ??
    fallback ??
    normalizedId
  );
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
    localizeJobName: (englishJobName: string, jobId?: string) =>
      localizeJobName(language, englishJobName, jobId),
    localizeAltJobTitle: (englishAltTitle: string, altId?: string) =>
      localizeAltJobTitle(language, englishAltTitle, altId),
    localizeCharacterFeatureName: (
      englishFeatureName: string,
      featureId?: string,
    ) => localizeCharacterFeatureName(language, englishFeatureName, featureId),
    localizeCharacterFeatureDescription: (
      englishFeatureDescription: string,
      featureId?: string,
    ) =>
      localizeCharacterFeatureDescription(
        language,
        englishFeatureDescription,
        featureId,
      ),
    localizeCharacterFeatureNameById: (featureId: string, fallback?: string) =>
      localizeCharacterFeatureNameById(language, featureId, fallback),
    localizeCharacterFeatureDescriptionById: (
      featureId: string,
      fallback?: string,
    ) => localizeCharacterFeatureDescriptionById(language, featureId, fallback),
    localizeCharacterDataLabelById: (id: string, fallback?: string) =>
      localizeCharacterDataLabelById(language, id, fallback),
    localizeGender: (genderId: string) => localizeGender(language, genderId),
    localizeDataLabel: (text: string) => localizeDataLabel(language, text),
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
  const localizeJobNameForLanguage = useCallback(
    (englishJobName: string, jobId?: string) =>
      resolved.localizeJobName(englishJobName, jobId),
    [language],
  );
  const localizeAltJobTitleForLanguage = useCallback(
    (englishAltTitle: string, altId?: string) =>
      resolved.localizeAltJobTitle(englishAltTitle, altId),
    [language],
  );
  const localizeCharacterFeatureNameForLanguage = useCallback(
    (englishFeatureName: string, featureId?: string) =>
      resolved.localizeCharacterFeatureName(englishFeatureName, featureId),
    [language],
  );
  const localizeCharacterFeatureDescriptionForLanguage = useCallback(
    (englishFeatureDescription: string, featureId?: string) =>
      resolved.localizeCharacterFeatureDescription(
        englishFeatureDescription,
        featureId,
      ),
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
  const localizeDataLabelForLanguage = useCallback(
    (text: string) => resolved.localizeDataLabel(text),
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
    localizeJobName: localizeJobNameForLanguage,
    localizeAltJobTitle: localizeAltJobTitleForLanguage,
    localizeCharacterFeatureName: localizeCharacterFeatureNameForLanguage,
    localizeCharacterFeatureDescription:
      localizeCharacterFeatureDescriptionForLanguage,
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
    localizeDataLabel: localizeDataLabelForLanguage,
    localizeDataLabelById: localizeDataLabelByIdForLanguage,
  };
}
