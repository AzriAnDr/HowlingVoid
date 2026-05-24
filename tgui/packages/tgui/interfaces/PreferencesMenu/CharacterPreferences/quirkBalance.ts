import type { PreferencesMenuData, ServerData } from '../types';

export const getQuirkBalance = (
  data: PreferencesMenuData,
  serverData: ServerData | null | undefined,
  selectedQuirks = data.selected_quirks,
) => {
  const fallbackBalance = data.quirks_balance;

  if (
    !serverData?.quirks?.quirk_info ||
    !selectedQuirks ||
    typeof data.default_quirk_balance !== 'number'
  ) {
    return fallbackBalance;
  }

  const quirkInfo = serverData.quirks.quirk_info;
  let balance = data.default_quirk_balance;

  for (const quirkKey of selectedQuirks) {
    const selectedQuirk = quirkInfo[quirkKey];
    if (!selectedQuirk) continue;
    balance -= selectedQuirk.value || 0;
  }

  return balance;
};

export const getAugmentCostBalance = (
  data: PreferencesMenuData,
  serverData: ServerData | null | undefined,
) => {
  const costByPath: Record<string, number> = {};

  for (const slot of serverData?.limbs_and_markings?.augment_items ?? []) {
    for (const aug of slot.aug_options ?? []) {
      if (aug.path) costByPath[aug.path] = aug.cost || 0;
    }
    for (const aug of slot.implant_options ?? []) {
      if (aug.path) costByPath[aug.path] = aug.cost || 0;
    }
  }

  let balance = 0;
  for (const augmentPath of Object.values(data.augments ?? {})) {
    if (augmentPath) balance += costByPath[augmentPath] || 0;
  }

  return balance;
};

export const getCombinedQuirkAugmentBalance = (
  data: PreferencesMenuData,
  serverData: ServerData | null | undefined,
  selectedQuirks = data.selected_quirks,
) => {
  return (
    getQuirkBalance(data, serverData, selectedQuirks) -
    getAugmentCostBalance(data, serverData)
  );
};
