import characterFeaturesRu from './locales/character_features.ru.json';
import jobsRu from './locales/jobs.ru.json';
import uiRu from './locales/ui.ru.json';

type InterfaceLanguage = 'english' | 'russian';

const RU_CHARACTER_FEATURE_NAMES_BY_EN = characterFeaturesRu as Record<
  string,
  string
>;
const RU_UI_BY_EN = uiRu as Record<string, string>;
const RU_JOBS = jobsRu as {
  job_names?: Record<string, string>;
  alt_job_titles?: Record<string, string>;
};

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

export function localize(
  language: InterfaceLanguage,
  englishText: string,
  russianText?: string,
): string {
  if (language !== 'russian') {
    return englishText;
  }

  const key = (englishText ?? '').toString();
  const trimmed = key.trim();
  const noColon = trimmed.endsWith(':') ? trimmed.slice(0, -1) : trimmed;
  const withColon = trimmed.endsWith(':') ? trimmed : `${trimmed}:`;

  return (
    RU_UI_BY_EN[key] ??
    RU_UI_BY_EN[trimmed] ??
    RU_UI_BY_EN[noColon] ??
    RU_UI_BY_EN[withColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[key] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[trimmed] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[noColon] ??
    RU_CHARACTER_FEATURE_NAMES_BY_EN[withColon] ??
    russianText ??
    key
  );
}

export function localizeCharacterFeatureName(
  language: InterfaceLanguage,
  englishFeatureName: string,
): string {
  if (language !== 'russian') {
    return englishFeatureName;
  }

  return (
    RU_CHARACTER_FEATURE_NAMES_BY_EN[englishFeatureName] ??
    RU_UI_BY_EN[englishFeatureName] ??
    englishFeatureName
  );
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
