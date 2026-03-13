# TGUI Unified Localization

This document describes the current localization model for TGUI interfaces.
For non-technical Russian translation editors, see:
`documentation/TGUI_TRANSLATION_EDITORS.ru.md`

## Canonical Architecture

- Visible UI text must use semantic keys: `t("ui.*")`
- Shared locale dictionaries:
  - `tgui/packages/tgui/interfaces/locales/ui.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.ru.json`
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

- any new `ui.*` key added to `ui.en.json` must be added to `ui.ru.json`
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
2. Add missing keys to both locale files.
3. Validate key parity.

4. Re-scan migrated files for remaining real visible literals.

## Troubleshooting

If UI shows raw keys like `ui.some.key`:

1. Check key exists in `ui.en.json` and `ui.ru.json`.
2. Check component uses `usePreferencesLocalization(...)` and `t(...)`.
3. Check runtime language is resolved (payload/config/client path).
4. Rebuild/restart TGUI to clear stale bundle/cache.

## Adding New Languages (DE/PL/etc.)

English (`ui.en.json`) is the canonical meaning source.

Steps:

1. Create a new locale file:

- `tgui/packages/tgui/interfaces/locales/ui.de.json`
- or `tgui/packages/tgui/interfaces/locales/ui.pl.json`

2. Copy the full key set from `ui.en.json` (keys must be 1:1 identical).

3. Translate values only. Do not rename keys.

4. Wire the language into localization runtime:

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`
- extend `InterfaceLanguage`
- add dictionary into `UI_BY_LANGUAGE`
- extend `normalizeLanguage(...)` to detect new codes (`de`, `pl`, etc.)

5. Keep fallback behavior safe:

- missing translation should fall back to EN value, not raw key.
