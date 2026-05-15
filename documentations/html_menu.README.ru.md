# Howling Void HTML Menu by ALOHADAWN

## Назначение

Папка `code/modules/title_screen/html_menu` содержит кастомное HTML-меню лобби для BYOND:

- визуальные варианты меню, объединенные по главам;
- отдельные CSS/JS/аудио для каждого варианта;
- загрузчик `menuChapters.js`, который выбирает нужный вариант, подключает ассеты и инициализирует сцену;
- UI-переключатель варианта меню в левом верхнем углу;
- сохранение последнего выбранного варианта в пользовательских preferences.

## Текущие варианты

Группы выводятся в `MENU_VARIANT_GROUPS` внутри `menuChapters.js`.

## Как это работает в BYOND

HTML генерируется в `code/modules/title_screen/new_player.dm`, где:

- регистрируются и отправляются ассеты через `/datum/asset/simple/lobby_howling_menu`;
- URL ассетов подставляются через `SSassets.transport.get_asset_url(...)`;
- выставляются глобалы:
  - `window.__HOWLING_MENU_ASSETS`
  - `window.__HOWLING_MENU_SETTINGS`
- в настройки меню передается сохраненный `menuChapter`;
- подключается `menuChapters.js`.

Подсистема титульного экрана находится в `code/modules/title_screen/title_screen_subsystem.dm`.

## Сохранение выбранной главы

Выбранный вариант хранится в preference `menu_chapter`:

- файл: `code/modules/client/preferences/menu_chapter.dm`;
- savefile key: `menu_chapter`;
- дефолт: `sisterRay`;
- допустимые значения: `ironHeart`, `sisterRay`, `jesusWept`, `crossToBear`, `molesHamsters`.

Когда игрок выбирает вариант в HTML-меню, `menuChapters.js` отправляет в BYOND href:

```text
byond://?src=<new_player_ref>;set_menu_chapter=<chapter_id>
```

`code/modules/title_screen/new_player.dm` валидирует значение через preference, записывает его в `client.prefs`, сохраняет preferences и отправляет актуальное значение обратно в браузер через `set_menu_chapter`.

Локальный `localStorage` в `menuChapters.js` нужен только как fallback для открытия `index.html` напрямую или до получения значения от BYOND. Основным источником правды в игре является preference `menu_chapter`.

## Контакт между DM и JS

JS-функции, которые вызывает BYOND (`output(..., "nova_title_browser:<fn>")`):

- `toggle_ready(setReady)`
- `set_round_started()`
- `toggle_antag(setAntag)`
- `update_current_character(name)`
- `stop_menu_audio()`
- `set_menu_music_enabled(enabled)`
- `set_menu_music_volume(volume)`
- `set_interface_language(language)`
- `set_menu_chapter(chapter)`

Глобальные входные данные:

- `window.__HOWLING_MENU_ASSETS` — словарь `имя_файла -> asset_url`.
- `window.__HOWLING_MENU_SETTINGS`:
  - `musicEnabled: boolean`
  - `musicVolume: 0..1`
  - `interfaceLanguage: string`
  - `introAccepted: boolean`
  - `menuChapter: string`
  - `byondSrc: string`

## Настройка музыки меню

Музыка учитывает два параметра:

- включена/выключена (`musicEnabled`);
- громкость (`musicVolume`).

Важное поведение:

- если музыка выключена или громкость `0`, аудио останавливается;
- музыка не стартует сама до подтверждения дисклеймера (`introAccepted`);
- при изменении настроек в рантайме значения применяются без перезагрузки меню;
- при смене варианта меню старый chapter-runtime должен очиститься через `__menuChapterTeardown`.

## Добавление новой главы или варианта

1. Добавить `newChapter.css`, `newChapter.js` и, если нужно, аудиофайл в `code/modules/title_screen/html_menu`.
2. Зарегистрировать вариант в `MENU_CHAPTERS` внутри `menuChapters.js`.
3. Добавить вариант в подходящую группу `MENU_VARIANT_GROUPS` или создать новую группу.
4. Добавить ассеты в `/datum/asset/simple/lobby_howling_menu` в `code/modules/title_screen/new_player.dm`.
5. Добавить URL ассетов в `get_howling_menu_assets()` в `code/modules/title_screen/new_player.dm`.
6. Добавить id варианта в `init_possible_values()` preference `menu_chapter`.
7. Если новый вариант должен стать дефолтом, изменить `create_default_value()` в `menu_chapter.dm` и `DEFAULT_CHAPTER` в `menuChapters.js`.

## Частые проблемы

- Нет стилей: ассеты не отправлены клиенту или не добавлены в `__HOWLING_MENU_ASSETS`.
- Выбор не сохраняется: проверить `set_menu_chapter` в `Topic()`, наличие `byondSrc` и значение в `menu_chapter.dm`.
- Вариант сбрасывается на дефолт: id отсутствует в preference или не зарегистрирован в `MENU_CHAPTERS`.
- Дубли кликов/эффектов: глава инициализирована дважды; проверять `__menuChapterTeardown`.
- Музыка продолжает играть после выхода из меню: проверять вызов `stop_menu_audio()` при `hide_title_screen()`.
- Моргание без стилей при открытии: использовать `body.menu-css-ready` (уже включено).
