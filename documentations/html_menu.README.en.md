# Howling Void HTML Menu by ALOHADAWN

## Purpose

This folder contains the custom BYOND lobby HTML menu:

- chapter-based presentation (`ironHeart`, `jesusWept`, `crossToBear`, `sisterRay`, `molesHamsters`);
- chapter-specific CSS, JS, and background music;
- `menuChapters.js`, which selects the active chapter and initializes runtime behavior.

## File Layout

- `index.html` - local standalone markup/test template.
- `menuChapters.js` - chapter loader and BYOND integration.
- `*Heart.css`, `*Heart.js`, etc. - chapter-specific style/logic files.
- `buttonclickrelease.ogg` - shared click/select sound.
- `*_heart.ogg`, `*_wept.ogg`, `*.mp3` - chapter BGM tracks.

## BYOND Integration

HTML is generated in `code/modules/title_screen/code/title_screen_html.dm`, where:

- asset URLs are injected through `SSassets.transport.get_asset_url(...)`;
- globals are prepared:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- `menuChapters.js` is loaded.

Client assets are managed in `code/modules/title_screen/code/new_player.dm`:

- `/datum/asset/simple/lobby_howling_menu` sends the base menu JS/CSS and shared click sound.
- `/datum/asset/simple/lobby_howling_menu_audio` registers chapter BGM tracks.
- `send_menu_chapter_audio()` sends only the currently needed BGM track to the client.

## DM/JS Contract

JS functions invoked by BYOND use the `howling_title_browser` browser id:

- `toggle_ready(setReady)`
- `set_round_started()`
- `toggle_antag(setAntag)`
- `update_current_character(name)`
- `append_terminal_text(text)`
- `update_loading_progress(current_time, total_time)`
- `stop_menu_audio()`
- `set_menu_music_enabled(enabled)`
- `set_menu_music_volume(volume)`
- `set_menu_language(language)`
- `set_menu_chapter(chapter)`

Input globals:

- `window.__HOWLING_MENU_SRC` - BYOND `src` ref for menu href calls.
- `window.__HOWLING_MENU_ASSETS` - map of `filename -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `interfaceLanguage: "english" | "russian"`
  - `menuChapter: string`
  - `introAccepted: boolean`

## Menu Music

Menu BGM is controlled by:

- enabled/disabled state (`musicEnabled`);
- volume level (`musicVolume`);
- selected chapter (`menuChapter`).

Important behavior:

- `index.html` uses `preload="none"` for BGM.
- BYOND sends only the selected chapter's BGM track initially.
- When a chapter changes, BYOND sends that chapter's track before telling JS to switch.
- BGM must not auto-start before disclaimer acceptance (`introAccepted`).
- Runtime preference updates apply without reopening the menu.

## Adding A New Chapter

1. Add `newChapter.css`, `newChapter.js`, and `new_chapter.ogg` or `.mp3` to `code/html_menu`.
2. Register the chapter in `MENU_CHAPTERS` inside `menuChapters.js`.
3. Add CSS/JS and shared non-BGM assets to `/datum/asset/simple/lobby_howling_menu`.
4. Add the BGM file to `/datum/asset/simple/lobby_howling_menu_audio`.
5. Add the chapter-to-BGM mapping in `get_menu_chapter_audio_asset()`.
6. Add the BGM asset URL to `get_howling_menu_assets()`.

## Common Issues

- No styles: CSS/JS asset is missing from `lobby_howling_menu` or `__HOWLING_MENU_ASSETS`.
- No music after selecting a chapter: BGM is missing from `lobby_howling_menu_audio`, `get_menu_chapter_audio_asset()`, or `__HOWLING_MENU_ASSETS`.
- Duplicate click/effect handlers: chapter initialized twice; verify `__menuChapterTeardown`.
- Music keeps playing after leaving lobby: verify `stop_menu_audio()` from `hide_title_screen()`.
- Flash of unstyled content: use `body.menu-css-ready` gating.
