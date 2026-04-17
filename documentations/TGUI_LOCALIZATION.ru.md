# Локализация TGUI: инструкция для разработчиков и переводчиков

Документ для двух ролей:

- разработчик интерфейса (добавляет/меняет ключи в коде)
- переводчик/редактор (правит формулировки в `ui.*.ru.json`)

Английская версия: `documentation/TGUI_LOCALIZATION.md`
Практический гайд для редакторов перевода: `documentation/TGUI_TRANSLATION_EDITORS.ru.md`

## 1) Где что лежит

- Ключи UI:
  - `tgui/packages/tgui/interfaces/locales/ui.common.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.character.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.jobs.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.species.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.loadout.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.game.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.keybindings.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.admin.en.json`
  - `tgui/packages/tgui/interfaces/locales/ui.data.en.json`
  - аналогичный набор файлов для `*.ru.json`
  - агрегируются в `tgui/packages/tgui/interfaces/locales/index.ts`
- Общий вызов локализации в интерфейсах:
  - `tgui/packages/tgui/interfaces/localization.ts`
  - внутри используется `usePreferencesLocalization(...).t(...)`

## 2) Правила для разработчика

1. Любой видимый текст в интерфейсе должен идти через `t("ui.*")`.
2. Не использовать `t("English text")` как ключ.
3. Новый ключ добавляется сразу в соответствующие EN/RU locale-файлы одного домена.
4. Не локализовать backend-значения:

- `act(...)` action names
- payload ids/enum values
- технические константы, не показываемые пользователю

Формат ключа:

- `ui.<модуль>.<смысл>`
- пример: `ui.player_panel.private_message`

## 3) Правила для переводчика/редактора

1. Править только значения в соответствующем `ui.*.ru.json`, ключи не трогать.
2. Сохранять смысл EN-строки, но писать естественно для русскоязычного UI.
3. Избегать англицизмов без необходимости.

- пустые значения
- бессмысленный дословный машинный перевод

Что допустимо оставить на английском:

- устоявшиеся имена брендов/протоколов/продуктов (если это осознанно)

## 4) Как исправлять косяк перевода (пошагово)

1. Найти ключ:

- если в интерфейсе показывается `ui.some.key`, это и есть ключ
- иначе найти строку через `rg`

2. Проверить ключ в EN/RU:

- есть ли ключ в обоих файлах
- адекватна ли RU-формулировка

3. Исправить RU-значение в нужном `ui.*.ru.json`.

## 5) Если в UI показываются сырые ключи (`ui.*`)

Проверить по порядку:

1. Ключ существует в соответствующих EN/RU locale-файлах.
2. Компонент реально вызывает `t('ui...')`, а не выводит строку напрямую.
3. Для конкретного окна корректно определяется язык интерфейса.
4. Перезапущен клиент/пересобран TGUI (исключить старый кэш бандла).

## 6) Мини-чеклист перед коммитом

- нет изменений ключей без причины
- EN/RU key parity = 1:1
- формулировки в RU читаются естественно в интерфейсе

## 7) Как добавить новый язык (например DE/PL)

Английские locale-файлы (`ui.*.en.json`) считаются базовым источником смысла.

Шаги:

1. Создать файл нового языка по образцу:

- `tgui/packages/tgui/interfaces/locales/ui.de.json`
- или `tgui/packages/tgui/interfaces/locales/ui.pl.json`

2. Скопировать в него полный набор ключей из всех EN locale-файлов или из агрегированного словаря (ключи должны совпадать 1:1).

3. Перевести только значения, ключи не менять.

4. Подключить новый словарь в локализационный слой:

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`
- добавить новый язык в `InterfaceLanguage`
- добавить словарь в `UI_BY_LANGUAGE`
- расширить `normalizeLanguage(...)` для нового кода языка (`de`, `pl` и т.д.)

5. Проверить, что fallback остаётся безопасным:

- если перевод отсутствует, берётся EN-значение, а не сырой ключ.
