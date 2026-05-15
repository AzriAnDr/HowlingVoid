# Howling Void HTML Menu by ALOHADAWN

## Purpose

`code/modules/title_screen/html_menu` contains the custom BYOND lobby HTML menu:

- visual menu variants grouped by chapter;
- separate CSS/JS/audio per variant;
- `menuChapters.js`, which selects the active variant, loads assets, and initializes runtime behavior;
- a top-left menu variant selector;
- persistent storage of the user's last selected menu variant.

## Current Variants

Groups are defined in `MENU_VARIANT_GROUPS` inside `menuChapters.js`.

## BYOND Integration Flow

HTML is generated in `code/modules/title_screen/new_player.dm`, where:

- assets are registered and sent through `/datum/asset/simple/lobby_howling_menu`;
- asset URLs are injected via `SSassets.transport.get_asset_url(...)`;
- globals are prepared:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- the saved `menuChapter` setting is passed into the menu;
- `menuChapters.js` is loaded.

The title screen subsystem lives in `code/modules/title_screen/title_screen_subsystem.dm`.

## Persisting The Selected Chapter

The selected variant is stored in the `menu_chapter` preference:

- file: `code/modules/client/preferences/menu_chapter.dm`;
- savefile key: `menu_chapter`;
- default: `sisterRay`;
- allowed values: `ironHeart`, `sisterRay`, `jesusWept`, `crossToBear`, `molesHamsters`.

When the player selects a variant in the HTML menu, `menuChapters.js` sends this href to BYOND:

```text
byond://?src=<new_player_ref>;set_menu_chapter=<chapter_id>
```

`code/modules/title_screen/new_player.dm` validates the value through the preference, writes it to `client.prefs`, saves preferences, and sends the current value back to the browser through `set_menu_chapter`.

The `localStorage` value in `menuChapters.js` is only a fallback for opening `index.html` directly or before BYOND sends the saved value. In-game, the `menu_chapter` preference is the source of truth.

## DM ↔ JS Contract

JS functions invoked by BYOND (`output(..., "nova_title_browser:<fn>")`):

- `toggle_ready(setReady)`
- `set_round_started()`
- `toggle_antag(setAntag)`
- `update_current_character(name)`
- `stop_menu_audio()`
- `set_menu_music_enabled(enabled)`
- `set_menu_music_volume(volume)`
- `set_interface_language(language)`
- `set_menu_chapter(chapter)`

Input globals:

- `window.__HOWLING_MENU_ASSETS` — map `filename -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `interfaceLanguage: string`
  - `introAccepted: boolean`
  - `menuChapter: string`
  - `byondSrc: string`

## Menu Music Behavior

Menu BGM is controlled by:

- enabled/disabled state (`musicEnabled`);
- volume level (`musicVolume`).

Important behavior:

- if disabled or volume is `0`, audio is paused;
- BGM must not auto-start before disclaimer acceptance (`introAccepted`);
- runtime preference updates apply without reopening the menu;
- when switching variants, the previous chapter runtime should clean itself up through `__menuChapterTeardown`.

## Adding A New Chapter Or Variant

1. Add `newChapter.css`, `newChapter.js`, and optional audio to `code/modules/title_screen/html_menu`.
2. Register the variant in `MENU_CHAPTERS` inside `menuChapters.js`.
3. Add the variant to the right `MENU_VARIANT_GROUPS` group or create a new group.
4. Add assets to `/datum/asset/simple/lobby_howling_menu` in `code/modules/title_screen/new_player.dm`.
5. Add asset URLs to `get_howling_menu_assets()` in `code/modules/title_screen/new_player.dm`.
6. Add the variant id to `init_possible_values()` for the `menu_chapter` preference.
7. If the new variant should become the default, update `create_default_value()` in `menu_chapter.dm` and `DEFAULT_CHAPTER` in `menuChapters.js`.

## Common Issues

- No styles: assets are not sent to the client or are missing from `__HOWLING_MENU_ASSETS`.
- Selection is not saved: check `set_menu_chapter` in `Topic()`, `byondSrc`, and the value list in `menu_chapter.dm`.
- Variant falls back to default: the id is missing from the preference or is not registered in `MENU_CHAPTERS`.
- Duplicate click/effect handlers: chapter initialized twice; verify `__menuChapterTeardown`.
- Music keeps playing after leaving lobby: verify `stop_menu_audio()` from `hide_title_screen()`.
- Flash of unstyled content: use `body.menu-css-ready` gating (already implemented).
