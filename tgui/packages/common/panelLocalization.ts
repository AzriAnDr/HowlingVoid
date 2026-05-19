import { storage } from './storage';

export type PanelLanguage = 'english' | 'russian';

export type UIElementType =
  | 'preferences'
  | 'game_preferences'
  | 'interaction'
  | 'antag_info'
  | 'rnd'
  | 'announce'
  | 'storyteller';

const PANEL_LANGUAGE_PREFIX = 'howling_void.panel_language.';
const PANEL_LANGUAGE_GLOBAL = '__HOWLING_PANEL_LANGUAGES';
const INTERFACE_LANGUAGE_STORAGE_KEY = 'howling_void.interface_language';
const INTERFACE_LANGUAGE_GLOBAL = '__HOWLING_INTERFACE_LANGUAGE';
const INTERFACE_LANGUAGE_UPDATED_EVENT =
  'howling_void.interface_language.updated';

export const isPanelLanguage = (value: unknown): value is PanelLanguage =>
  value === 'english' || value === 'russian';

export const getLanguageStorageKey = (element: UIElementType) =>
  `${PANEL_LANGUAGE_PREFIX}${element}`;

export const getLanguageUpdatedEvent = (element: UIElementType) =>
  `${PANEL_LANGUAGE_PREFIX}${element}.updated`;

export const getInterfaceLanguageUpdatedEvent = () =>
  INTERFACE_LANGUAGE_UPDATED_EVENT;

function dispatchLanguageUpdatedEvent(
  eventName: string,
  language: PanelLanguage,
) {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(
      new CustomEvent(eventName, {
        detail: { language },
      }),
    );
  }
}

function getPanelLanguageCache(): Record<string, PanelLanguage> {
  const remembered = (globalThis as any)?.[PANEL_LANGUAGE_GLOBAL];
  return remembered && typeof remembered === 'object' ? remembered : {};
}

export function rememberUIElementLanguage(
  element: UIElementType,
  language: PanelLanguage,
) {
  if (!isPanelLanguage(language)) {
    return;
  }

  try {
    (globalThis as any)[PANEL_LANGUAGE_GLOBAL] = {
      ...getPanelLanguageCache(),
      [element]: language,
    };
  } catch {
    // Ignore write failures in restricted environments.
  }

  try {
    globalThis?.localStorage?.setItem(getLanguageStorageKey(element), language);
  } catch {
    // Ignore storage failures such as disabled localStorage.
  }
}

export function rememberInterfaceLanguage(language: PanelLanguage) {
  if (!isPanelLanguage(language)) {
    return;
  }

  try {
    (globalThis as any)[INTERFACE_LANGUAGE_GLOBAL] = language;
  } catch {
    // Ignore write failures in restricted environments.
  }

  try {
    globalThis?.localStorage?.setItem(INTERFACE_LANGUAGE_STORAGE_KEY, language);
  } catch {
    // Ignore storage failures such as disabled localStorage.
  }
}

export function getRememberedUIElementLanguage(
  element: UIElementType,
): PanelLanguage | null {
  const cached = getPanelLanguageCache()[element];
  if (isPanelLanguage(cached)) {
    return cached;
  }

  try {
    const stored = globalThis?.localStorage?.getItem(
      getLanguageStorageKey(element),
    );
    if (isPanelLanguage(stored)) {
      rememberUIElementLanguage(element, stored);
      return stored;
    }
  } catch {
    // Ignore storage failures such as disabled localStorage.
  }

  return null;
}

export function getRememberedInterfaceLanguage(): PanelLanguage | null {
  const cached = (globalThis as any)?.[INTERFACE_LANGUAGE_GLOBAL];
  if (isPanelLanguage(cached)) {
    return cached;
  }

  try {
    const stored = globalThis?.localStorage?.getItem(
      INTERFACE_LANGUAGE_STORAGE_KEY,
    );
    if (isPanelLanguage(stored)) {
      rememberInterfaceLanguage(stored);
      return stored;
    }
  } catch {
    // Ignore storage failures such as disabled localStorage.
  }

  return null;
}

export async function setUIElementLanguage(
  element: UIElementType,
  language: PanelLanguage,
) {
  rememberUIElementLanguage(element, language);
  dispatchLanguageUpdatedEvent(getLanguageUpdatedEvent(element), language);
  await storage.set(getLanguageStorageKey(element), language);
}

export async function setInterfaceLanguage(language: PanelLanguage) {
  rememberInterfaceLanguage(language);
  dispatchLanguageUpdatedEvent(getInterfaceLanguageUpdatedEvent(), language);
  await storage.set(INTERFACE_LANGUAGE_STORAGE_KEY, language);
}
