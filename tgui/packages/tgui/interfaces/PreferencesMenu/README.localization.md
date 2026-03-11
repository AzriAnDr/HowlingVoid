# PreferencesMenu Localization Architecture

This directory uses one localization model:

- UI text: semantic keys only (`ui.*`).
- Data labels: stable id keys only (`feature.*`, `job.*`, `species.*`, `language.*`, etc.).
- English display text must not be used as a translation key.

## Entry Point

- Shared localization API: `tgui/packages/tgui/interfaces/PreferencesMenu/localization.ts`
- It re-exports the active implementation used by Character/Game Preferences.

## Key Conventions

- UI keys:
  - `ui.character.*`
  - `ui.game.*`
  - `ui.keybindings.*` (for future expansion)
  - `ui.common.*` (shared controls)
- Data keys:
  - `feature.<id>.name`
  - `feature.<id>.description`
  - `job.<id>.name`
  - `species.<id>.name`
  - `language.<id>.name`
  - `language.<id>.description`

## Required Usage

- UI components: `t('ui.some_key')`
- Data entities: id-based helpers (for example `localizeFeatureById(id)`)

## Forbidden Patterns

- `t('English Text')`
- Localization maps keyed by display text as the primary path.
- New code that treats English source strings as canonical translation ids.

## Compatibility Policy

Legacy display-text lookup may exist only as a narrow fallback bridge when ids are not yet available in payloads.
It must never be the first lookup path.
