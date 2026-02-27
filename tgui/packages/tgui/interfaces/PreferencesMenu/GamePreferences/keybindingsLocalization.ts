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
  names_by_en: Record<string, string>;
  descriptions_by_en: Record<string, string>;
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
  keybinding: Keybinding,
  category: string,
  language: InterfaceLanguage,
): Keybinding {
  if (language !== 'russian' || category === 'EMOTE') {
    return keybinding;
  }

  const name = RU.names_by_en[keybinding.name] || keybinding.name;
  const description = keybinding.description?.trim();
  const localizedDescription = description
    ? RU.descriptions_by_en[description] || description
    : description;

  return {
    ...keybinding,
    name,
    description: localizedDescription,
  };
}
