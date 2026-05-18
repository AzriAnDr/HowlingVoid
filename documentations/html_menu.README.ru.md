# Howling Void HTML Menu by ALOHADAWN

## Назначение

Эта папка содержит кастомное HTML-меню лобби для BYOND:

- главы меню (`ironHeart`, `jesusWept`, `crossToBear`, `sisterRay`, `molesHamsters`);
- отдельные CSS, JS и фоновую музыку для глав;
- загрузчик `menuChapters.js`, который выбирает активную главу и запускает runtime-логику.

## Состав Файлов

- `index.html` - локальный шаблон разметки и стенд для проверки.
- `menuChapters.js` - загрузчик глав и интеграция с BYOND.
- `*Heart.css`, `*Heart.js` и похожие файлы - стили и логика конкретных глав.
- `buttonclickrelease.ogg` - общий звук клика/выбора.
- `*_heart.ogg`, `*_wept.ogg`, `*.mp3` - фоновая музыка глав.

## Интеграция С BYOND

HTML генерируется в `code/modules/title_screen/code/title_screen_html.dm`, где:

- подставляются URL ассетов через `SSassets.transport.get_asset_url(...)`;
- выставляются глобальные переменные:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- подключается `menuChapters.js`.

Ассеты клиента управляются в `code/modules/title_screen/code/new_player.dm`:

- `/datum/asset/simple/lobby_howling_menu` отправляет базовые JS/CSS меню и общий звук клика.
- `/datum/asset/simple/lobby_howling_menu_audio` регистрирует фоновые треки глав.
- `send_menu_chapter_audio()` отправляет клиенту только нужный сейчас трек главы.

## Контракт DM/JS

BYOND вызывает JS-функции через browser id `howling_title_browser`:

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

Входные глобальные данные:

- `window.__HOWLING_MENU_SRC` - BYOND `src` ref для href-вызовов меню.
- `window.__HOWLING_MENU_ASSETS` - словарь `имя_файла -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `interfaceLanguage: "english" | "russian"`
  - `menuChapter: string`
  - `introAccepted: boolean`

## Музыка Меню

Фоновая музыка меню зависит от:

- включения/выключения (`musicEnabled`);
- громкости (`musicVolume`);
- выбранной главы (`menuChapter`).

Важное поведение:

- `index.html` использует `preload="none"` для фоновой музыки.
- BYOND при открытии отправляет только трек выбранной главы.
- При смене главы BYOND сначала досылает трек этой главы, потом сообщает JS переключиться.
- Музыка не должна стартовать до принятия дисклеймера (`introAccepted`).
- Изменения настроек применяются без переоткрытия меню.

## Добавление Новой Главы

1. Добавить `newChapter.css`, `newChapter.js` и `new_chapter.ogg` или `.mp3` в `code/html_menu`.
2. Зарегистрировать главу в `MENU_CHAPTERS` внутри `menuChapters.js`.
3. Добавить CSS/JS и общие не-BGM ассеты в `/datum/asset/simple/lobby_howling_menu`.
4. Добавить BGM-файл в `/datum/asset/simple/lobby_howling_menu_audio`.
5. Добавить соответствие главы и BGM в `get_menu_chapter_audio_asset()`.
6. Добавить URL BGM-ассета в `get_howling_menu_assets()`.

## Частые Проблемы

- Нет стилей: CSS/JS ассет не добавлен в `lobby_howling_menu` или `__HOWLING_MENU_ASSETS`.
- Нет музыки после выбора главы: BGM отсутствует в `lobby_howling_menu_audio`, `get_menu_chapter_audio_asset()` или `__HOWLING_MENU_ASSETS`.
- Дубли кликов/эффектов: глава инициализирована дважды; проверить `__menuChapterTeardown`.
- Музыка играет после выхода из лобби: проверить вызов `stop_menu_audio()` из `hide_title_screen()`.
- Моргание без стилей: использовать гейт `body.menu-css-ready`.
