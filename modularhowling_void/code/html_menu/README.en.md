# Howling Void HTML Menu by ALOHADAWN

## Purpose

This folder contains the custom BYOND lobby HTML menu:

- chapter-based presentation (`jesusWept` and `ironHeart`);
- chapter-specific CSS/JS/audio;
- `menuChapters.js` loader that selects assets and initializes runtime behavior.

## File layout

- `index.html` — local standalone markup/test template.
- `menuChapters.js` — chapter loader, BYOND-safe integration (including legacy fallback).
- `jesusWept.css`, `jesusWept.js` — Jesus Wept chapter style/logic.
- `ironHeart.css`, `ironHeart.js` — Iron Heart chapter style/logic.
- `buttonclickrelease.ogg` — click/select sound.
- `jesus_wept.ogg`, `iron_heart.ogg` — chapter BGM tracks.

## BYOND integration flow

HTML is generated in `modular_nova/modules/title_screen/code/title_screen_html.dm`, where:

- asset URLs are injected via `SSassets.transport.get_asset_url(...)`;
- globals are prepared:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- `menuChapters.js` is loaded.

Client assets are sent through:

- `/datum/asset/simple/lobby_howling_menu`
- `show_title_screen()` in `modular_nova/modules/title_screen/code/new_player.dm`.

## DM ↔ JS contract

JS functions invoked by BYOND (`output(..., "nova_title_browser:<fn>")`):

- `toggle_ready(setReady)`
- `set_round_started()`
- `toggle_antag(setAntag)`
- `update_current_character(name)`
- `stop_menu_audio()`
- `set_menu_music_enabled(enabled)`
- `set_menu_music_volume(volume)`

Input globals:

- `window.__HOWLING_MENU_ASSETS` — map `filename -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `introAccepted: boolean`

## Menu music behavior

Menu BGM is controlled by:

- enabled/disabled state (`musicEnabled`);
- volume level (`musicVolume`).

Important behavior:

- if disabled or volume is `0`, audio is paused;
- BGM must not auto-start before disclaimer acceptance (`introAccepted`);
- runtime preference updates apply without reopening the menu.

## Adding a new chapter

1. Add `newChapter.css`, `newChapter.js`, `new_chapter.ogg` to this folder.
2. Register it in `MENU_CHAPTERS` inside `menuChapters.js`.
3. Add assets to:
   - `/datum/asset/simple/lobby_howling_menu` (`new_player.dm`);
   - `window.__HOWLING_MENU_ASSETS` (`title_screen_html.dm`).
4. Switch `CURRENT_CHAPTER` in `menuChapters.js` if needed.

## Common issues (fixed)

- No styles: assets are not sent to client or missing in `__HOWLING_MENU_ASSETS`.
- Duplicate click/effect handlers: chapter initialized twice; verify `__menuChapterTeardown`.
- Music keeps playing after leaving lobby: verify `stop_menu_audio()` from `hide_title_screen()`.
- Flash of unstyled content: use `body.menu-css-ready` gating (already implemented).
