import { useCallback } from 'react';
import { useBackend } from 'tgui/backend';

import type { PreferencesMenuData } from '../types';
import characterFeaturesRu from './locales/character_features.ru.json';
import jobsRu from './locales/jobs.ru.json';
import uiCharacterEn from './locales/ui.character.en.json';
import uiCharacterRu from './locales/ui.character.ru.json';
import uiGameEn from './locales/ui.game.en.json';
import uiGameRu from './locales/ui.game.ru.json';
import uiRu from './locales/ui.ru.json';

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

const RU_CHARACTER_FEATURE_NAMES_BY_EN = characterFeaturesRu as Record<
  string,
  string
>;

const RU_JOBS = jobsRu as {
  job_names?: Record<string, string>;
  alt_job_titles?: Record<string, string>;
};

const RU_SERVER_LABELS_BY_EN = uiRu as Record<string, string>;

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
  return resolveDataId(
    language,
    CHARACTER_FEATURE_NAMES_BY_ID,
    featureId ?? englishFeatureName,
    englishFeatureName,
  );
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
  return resolveDataId(language, SERVER_LABELS_BY_ID, id, fallback);
}

export function localizeDataLabel(
  language: InterfaceLanguage,
  text: string,
): string {
  return resolveDataId(language, SERVER_LABELS_BY_ID, text, text);
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
    localizeDataLabel: localizeDataLabelForLanguage,
    localizeDataLabelById: localizeDataLabelByIdForLanguage,
  };
}
