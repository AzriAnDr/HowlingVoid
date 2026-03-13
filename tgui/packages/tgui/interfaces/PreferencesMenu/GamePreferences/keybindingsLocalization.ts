import type { InterfaceLanguage } from '../localization';

type Keybinding = {
  name: string;
  description?: string;
};

type TranslateFn = (key: string, fallback?: string) => string;

export function getKeybindingsUiText(t: TranslateFn) {
  return {
    unbound: t('ui.game.keybindings.ui.unbound', 'Unbound'),
    setNewOrEsc: t('ui.game.keybindings.ui.setNewOrEsc', 'Set New / ESC to Clear'),
    resetToDefaults: t('ui.game.keybindings.ui.resetToDefaults', 'Reset to Defaults'),
    resetAll: t('ui.game.keybindings.ui.resetAll', 'Reset all keybindings'),
  };
}

export function localizeKeybinding(
  keybindingId: string,
  keybinding: Keybinding,
  category: string,
  language: InterfaceLanguage,
  t: TranslateFn,
): Keybinding {
  if (language !== 'russian' || category === 'EMOTE') {
    return keybinding;
  }

  const name = t(`ui.game.keybinding.${keybindingId}.name`, keybinding.name);
  const description = keybinding.description?.trim();
  const localizedDescription = description
    ? t(`ui.game.keybinding.${keybindingId}.description`, description)
    : description;

  return {
    ...keybinding,
    name,
    description: localizedDescription,
  };
}
