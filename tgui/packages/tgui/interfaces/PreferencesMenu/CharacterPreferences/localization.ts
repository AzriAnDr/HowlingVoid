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

const RU_CHARACTER_FEATURE_NAMES_BY_EN = characterFeaturesRu as Record<
  string,
  string
>;
const EN_UI_BY_KEY = {
  ...(uiCharacterEn as Record<string, string>),
  ...(uiGameEn as Record<string, string>),
} as Record<string, string>;
const RU_UI_BY_EN = uiRu as Record<string, string>;
const RU_UI_BY_KEY = {
  ...(uiCharacterRu as Record<string, string>),
  ...(uiGameRu as Record<string, string>),
} as Record<string, string>;
const UI_BY_LANGUAGE: Record<InterfaceLanguage, Record<string, string>> = {
  english: EN_UI_BY_KEY,
  russian: RU_UI_BY_KEY,
};
const RU_JOBS = jobsRu as {
  job_names?: Record<string, string>;
  alt_job_titles?: Record<string, string>;
};

function normalizeLookupKey(value: string): string {
  return value.replace(/\s+/g, ' ').trim();
}

const RU_UI_BY_EN_NORMALIZED = Object.fromEntries(
  Object.entries(RU_UI_BY_EN).map(([key, value]) => [
    normalizeLookupKey(key),
    value,
  ]),
) as Record<string, string>;

const RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED = Object.fromEntries(
  Object.entries(RU_CHARACTER_FEATURE_NAMES_BY_EN).map(([key, value]) => [
    normalizeLookupKey(key),
    value,
  ]),
) as Record<string, string>;

function getLegacyLookupCandidates(raw: string): string[] {
  const key = (raw ?? '').toString();
  const trimmed = key.trim();
  const noColon = trimmed.endsWith(':') ? trimmed.slice(0, -1) : trimmed;
  const withColon = trimmed.endsWith(':') ? trimmed : `${trimmed}:`;
  const normalizedKey = normalizeLookupKey(key);
  const normalizedTrimmed = normalizeLookupKey(trimmed);
  const normalizedNoColon = normalizeLookupKey(noColon);
  const normalizedWithColon = normalizeLookupKey(withColon);

  return [
    key,
    trimmed,
    noColon,
    withColon,
    normalizedKey,
    normalizedTrimmed,
    normalizedNoColon,
    normalizedWithColon,
  ];
}

function localizeLegacyServerText(
  language: InterfaceLanguage,
  englishText: string,
): string | null {
  if (language !== 'russian') {
    return null;
  }

  const [
    key,
    trimmed,
    noColon,
    withColon,
    normalizedKey,
    normalizedTrimmed,
    normalizedNoColon,
    normalizedWithColon,
  ] = getLegacyLookupCandidates(englishText);

  return (
    RU_UI_BY_EN[key] ??
    RU_UI_BY_EN[trimmed] ??
    RU_UI_BY_EN[noColon] ??
    RU_UI_BY_EN[withColon] ??
    RU_UI_BY_EN_NORMALIZED[normalizedKey] ??
    RU_UI_BY_EN_NORMALIZED[normalizedTrimmed] ??
    RU_UI_BY_EN_NORMALIZED[normalizedNoColon] ??
    RU_UI_BY_EN_NORMALIZED[normalizedWithColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[key] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[trimmed] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[noColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[withColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED[normalizedKey] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED[normalizedTrimmed] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED[normalizedNoColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED[normalizedWithColon] ??
    null
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

    for (const key of ['interface_language', 'language', 'selected', 'current']) {
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
): string {
  if (language !== 'russian') {
    return englishFeatureName;
  }

  const normalized = normalizeLookupKey(englishFeatureName);
  return (
    RU_CHARACTER_FEATURE_NAMES_BY_EN[englishFeatureName] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN_NORMALIZED[normalized] ??
    RU_UI_BY_EN[englishFeatureName] ??
    RU_UI_BY_EN_NORMALIZED[normalized] ??
    englishFeatureName
  );
}

export function localizeServerText(
  language: InterfaceLanguage,
  englishText: string,
): string {
  return localizeLegacyServerText(language, englishText) ?? englishText;
}

export function getPreferencesLocalization(data: unknown) {
  const language = getCharacterPreferencesLanguage(data);

  return {
    language,
    t: (key: string, fallback?: string) => translateUi(language, key, fallback),
    localizeJobName: (englishJobName: string) =>
      localizeJobName(language, englishJobName),
    localizeAltJobTitle: (englishAltTitle: string) =>
      localizeAltJobTitle(language, englishAltTitle),
    localizeCharacterFeatureName: (englishFeatureName: string) =>
      localizeCharacterFeatureName(language, englishFeatureName),
    localizeServerText: (englishText: string) =>
      localizeServerText(language, englishText),
    localizeServerTextById: (id: string | undefined, englishText: string) =>
      id ? translateUi(language, id, englishText) : localizeServerText(language, englishText),
  };
}

export function localizeJobName(
  language: InterfaceLanguage,
  englishJobName: string,
): string {
  if (language !== 'russian') {
    return englishJobName;
  }
  return RU_JOBS.job_names?.[englishJobName] ?? englishJobName;
}

export function localizeAltJobTitle(
  language: InterfaceLanguage,
  englishAltTitle: string,
): string {
  if (language !== 'russian') {
    return englishAltTitle;
  }
  return RU_JOBS.alt_job_titles?.[englishAltTitle] ?? englishAltTitle;
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
    (englishJobName: string) => resolved.localizeJobName(englishJobName),
    [language],
  );
  const localizeAltJobTitleForLanguage = useCallback(
    (englishAltTitle: string) => resolved.localizeAltJobTitle(englishAltTitle),
    [language],
  );
  const localizeCharacterFeatureNameForLanguage = useCallback(
    (englishFeatureName: string) => resolved.localizeCharacterFeatureName(englishFeatureName),
    [language],
  );
  const localizeServerTextForLanguage = useCallback(
    (englishText: string) => resolved.localizeServerText(englishText),
    [language],
  );
  const localizeServerTextByIdForLanguage = useCallback(
    (id: string | undefined, englishText: string) =>
      resolved.localizeServerTextById(id, englishText),
    [language],
  );

  return {
    language,
    t,
    localizeJobName: localizeJobNameForLanguage,
    localizeAltJobTitle: localizeAltJobTitleForLanguage,
    localizeCharacterFeatureName: localizeCharacterFeatureNameForLanguage,
    localizeServerText: localizeServerTextForLanguage,
    localizeServerTextById: localizeServerTextByIdForLanguage,
  };
}
