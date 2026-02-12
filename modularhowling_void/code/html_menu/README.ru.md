# Howling Void HTML Menu by ALOHADAWN

## Назначение

Папка содержит кастомное HTML-меню лобби для BYOND:

- визуальные главы (сейчас `jesusWept` и `ironHeart`);
- отдельные CSS/JS/аудио на главу;
- загрузчик `menuChapters.js`, который подбирает нужные ассеты и инициализирует сцену.

## Состав файлов

- `index.html` — локальный стенд/шаблон разметки меню.
- `menuChapters.js` — главный загрузчик глав, совместимость с BYOND (включая legacy-режим).
- `jesusWept.css`, `jesusWept.js` — стили/логика главы Jesus Wept.
- `ironHeart.css`, `ironHeart.js` — стили/логика главы Iron Heart.
- `buttonclickrelease.ogg` — звук нажатия.
- `jesus_wept.ogg`, `iron_heart.ogg` — фоновая музыка глав.

## Как это работает в BYOND

HTML генерируется в `modular_nova/modules/title_screen/code/title_screen_html.dm`, где:

- подставляются URL ассетов через `SSassets.transport.get_asset_url(...)`;
- выставляются глобалы:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- подключается `menuChapters.js`.

Ассеты отправляются клиенту через:

- `/datum/asset/simple/lobby_howling_menu`
- `show_title_screen()` в `modular_nova/modules/title_screen/code/new_player.dm`.

## Контакт между DM и JS

JS-функции, которые вызывает BYOND (`output(..., "nova_title_browser:<fn>")`):

- `toggle_ready(setReady)`
- `set_round_started()`
- `toggle_antag(setAntag)`
- `update_current_character(name)`
- `stop_menu_audio()`
- `set_menu_music_enabled(enabled)`
- `set_menu_music_volume(volume)`

Глобальные входные данные:

- `window.__HOWLING_MENU_ASSETS` — словарь `имя_файла -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `introAccepted: boolean`

## Настройка музыки меню

Музыка учитывает два параметра:

- включена/выключена (`musicEnabled`);
- громкость (`musicVolume`).

Важное поведение:

- если музыка выключена или громкость `0`, аудио останавливается;
- музыка не стартует сама до подтверждения дисклеймера (`introAccepted`);
- при изменении настроек в рантайме значения применяются без перезагрузки меню.

## Добавление новой главы

1. Добавить `newChapter.css`, `newChapter.js`, `new_chapter.ogg` в эту папку.
2. Зарегистрировать главу в `MENU_CHAPTERS` внутри `menuChapters.js`.
3. Добавить новые ассеты в:
   - `/datum/asset/simple/lobby_howling_menu` (`new_player.dm`);
   - `window.__HOWLING_MENU_ASSETS` (`title_screen_html.dm`).
4. При необходимости сменить `CURRENT_CHAPTER` в `menuChapters.js`.

## Частые проблемы (Пофикшено, нужно смотреть как делал я!)

- Нет стилей: ассеты не отправлены клиенту или не добавлены в `__HOWLING_MENU_ASSETS`.
- Дубли кликов/эффектов: глава инициализирована дважды; проверять `__menuChapterTeardown`.
- Музыка продолжает играть после выхода из меню: проверять вызов `stop_menu_audio()` при `hide_title_screen()`.
- Моргание без стилей при открытии: использовать `body.menu-css-ready` (уже включено).
