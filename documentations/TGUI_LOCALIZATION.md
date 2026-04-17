# TGUI Unified Localization

This document describes the current localization model for TGUI interfaces.
For non-technical Russian translation editors, see:
`documentation/TGUI_TRANSLATION_EDITORS.ru.md`

## Canonical Architecture

- Visible UI text must use semantic keys: `t("ui.*")`
- Shared locale dictionaries:
  - `tgui/packages/tgui/interfaces/locales/ui.common.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.character.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.jobs.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.species.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.loadout.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.game.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.keybindings.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.admin.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.data.en.json`
  - same file set for `*.ru.json`
  - aggregated in `tgui/packages/tgui/interfaces/locales/index.ts`
- Shared localization entrypoint:
  - `tgui/packages/tgui/interfaces/localization.ts`
  - re-exporting `tgui/packages/tgui/interfaces/PreferencesMenu/localization.ts`

## Required Rules

1. Localize only visible UI text:

- JSX text nodes
- button labels
- section headers and titles
- placeholders
- tooltips
- notices/warnings
- modal text
- empty states
- status text

2. Do not localize backend/runtime values:

- `act(...)` action names
- payload field values and ids
- enums/status codes used as logic values
- internal constants not shown as UI text

3. Keep key naming semantic and stable:

- `ui.<module_name>.<meaningful_name>`
- reuse existing keys before adding new ones

4. Keep strict EN/RU parity:

- any new `ui.*` key added to an EN locale file must be added to the matching RU locale file
- key sets must stay identical

## Runtime Language Resolution

`usePreferencesLocalization(...)` resolves interface language from backend data first, then falls back to browser language if payload language is absent.

Expected sources include:

- `data.interface_language`
- `data.game_preferences.interface_language`
- `data.preferences.interface_language`
- `data.client.interface_language`
- backend config/client mirrors when present

## Forbidden Patterns

- `t("English display text")`
- display-text-as-key localization
- separate ad hoc localization systems per interface
- one-sided locale additions (EN-only or RU-only)

## Migration Checklist (Per Batch/Cluster)

1. Replace visible literals with `t("ui.*")`.
2. Add missing keys to both matching locale files.
3. Validate key parity.

4. Re-scan migrated files for remaining real visible literals.

## Troubleshooting

If UI shows raw keys like `ui.some.key`:

1. Check which domain file owns the key and verify it exists in both EN and RU variants.
2. Check component uses `usePreferencesLocalization(...)` and `t(...)`.
3. Check runtime language is resolved (payload/config/client path).
4. Rebuild/restart TGUI to clear stale bundle/cache.

## Adding New Languages (DE/PL/etc.)

English locale files (`ui.*.en.json`) are the canonical meaning source.

Steps:

1. Create a new locale file:

- `tgui/packages/tgui/interfaces/locales/ui.de.json`
- or `tgui/packages/tgui/interfaces/locales/ui.pl.json`

2. Copy the full key set from all EN locale files or from the aggregated locale output (keys must be 1:1 identical).

3. Translate values only. Do not rename keys.

4. Wire the language into localization runtime:

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`
- extend `InterfaceLanguage`
- add dictionary into `UI_BY_LANGUAGE`
- extend `normalizeLanguage(...)` to detect new codes (`de`, `pl`, etc.)

5. Keep fallback behavior safe:

- missing translation should fall back to EN value, not raw key.
