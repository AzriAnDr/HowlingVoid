import keybindingsRu from './locales/keybindings.ru.json';

type InterfaceLanguage = 'english' | 'russian';

type Keybinding = {
  name: string;
  description?: string;
};

type KeybindingsRuJson = {
  ui_text: {
    unbound: string;
    setNewOrEsc: string;
    resetToDefaults: string;
    resetAll: string;
  };
  names_by_id: Record<string, string>;
  descriptions_by_id: Record<string, string>;
};

const RU = keybindingsRu as KeybindingsRuJson;

export function getKeybindingsUiText(language: InterfaceLanguage) {
  if (language === 'russian') {
    return RU.ui_text;
  }

  return {
    unbound: 'Unbound',
    setNewOrEsc: 'Set New / ESC to Clear',
    resetToDefaults: 'Reset to Defaults',
    resetAll: 'Reset all keybindings',
  };
}

export function localizeKeybinding(
  keybindingId: string,
  keybinding: Keybinding,
  category: string,
  language: InterfaceLanguage,
): Keybinding {
  if (language !== 'russian' || category === 'EMOTE') {
    return keybinding;
  }

  const name = RU.names_by_id[keybindingId] ?? keybinding.name;
  const description = keybinding.description?.trim();
  const localizedDescription = description
    ? RU.descriptions_by_id[keybindingId] ?? description
    : description;

  return {
    ...keybinding,
    name,
    description: localizedDescription,
  };
}
