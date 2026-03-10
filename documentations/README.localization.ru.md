# Локализация Preferences (Howling Void)

Схема локализации меню `Preferences`.

## 1. Где править

Править нужно только `tgui/packages/tgui/interfaces/PreferencesMenu/...`.

## 2. Текущая архитектура

Локализация централизована в:

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`

Основной API для UI:

- `usePreferencesLocalization(data?)`
- `t(key, fallback?)`

В компонентах используется только семантический ключ:

```tsx
const { t } = usePreferencesLocalization(data);
<Button>{t("main_rotate")}</Button>;
```

## 3. Файлы локалей

UI (семантические ключи):

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/ui.character.en.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/ui.character.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/ui.game.en.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/ui.game.ru.json`

Данные (ID/справочники):

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/jobs.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/character_features.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/server_labels.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/features.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/categories.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/keybindings.ru.json`

## 4. Разделение UI и server-driven текста

UI-строки:

- только `t('semantic_key')`

Server-driven сущности:

- `localizeJobName(...)`
- `localizeAltJobTitle(...)`
- `localizeCharacterFeatureName(...)`
- `localizeDataLabelById(...)`
- `localizeDataLabel(...)` (fallback для случаев без стабильного ID)

Для языков в `LanguagesMenu` сначала используются `name_id` / `description_id`,
сырые `name` / `description` остаются только как safety fallback.

## 5. Фолбэки

Для UI (`t`):

1. Ключ в выбранной локали.
2. Ключ в английской локали.
3. `fallback` из аргумента (если передан).
4. Сам ключ.

Для data-label helper:

1. ID в выбранной локали.
2. ID в английской таблице.
3. `fallback` (если передан).
4. Нормализованный ID.

## 6. Как добавить новый перевод

1. Придумай семантический ключ (`tab_languages`, `main_rotate`, ...).
2. Добавь ключ в `ui.character.en.json` или `ui.game.en.json`.
3. Добавь тот же ключ в соответствующий `.ru.json`.
4. Используй ключ в TSX через `t('your_key')`.
5. Для server-driven полей добавляй перевод по ID в профильный JSON, а не в UI-словарь.

## 7. Кодировка и формат

- Не использовать авто-конвертацию кодировок через редакторы/скрипты без проверки.
- Все locale JSON: `UTF-8` без BOM. Претиеры любят переводить в этот формат.
- После массовых правок проверять, что файл читается `JSON.parse`.

Дополнительно в UI:

1. Переключить язык интерфейса на русский.
2. Проверить `Character Preferences`, `Game Preferences`, `Keybindings`.
3. Убедиться, что нет английских UI-ярлыков вне server-driven контента.
