# Локализация Preferences (Howling Void)

Этот документ описывает актуальную схему локализации меню `Preferences` в билде Howling Void.

## Источник языка

- DM-преф:
  - `modularhowling_void/modules/client/preferences/interface_language.dm`
  - ключ: `interface_language` (`english` / `russian`)
- Передача в TGUI:
  - `code/modules/client/preferences.dm`
  - в `ui_data()` и `ui_static_data()` передаётся:
    - `data["interface_language"]`

Это сделано специально, чтобы язык был доступен во всех вкладках, а не только в `game_preferences`.

## Единый резолвер языка (TGUI)

- Файл:
  - `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`
- Основные функции:
  - `getCharacterPreferencesLanguage(data)`
  - `localize(language, en, ru)`
  - `localizeCharacterFeatureName(language, englishFeatureName)`

Используй `getCharacterPreferencesLanguage(data)` в любом компоненте Preferences вместо локальных проверок пути `data.character_preferences.game_preferences.interface_language`.

## Где сейчас подключено

- Character:
  - `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/index.tsx`
  - `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/MainPage.tsx`
  - и другие страницы Character, где импортируется `localize`.
- Game:
  - `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/index.tsx`
  - `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/GamePreferencesPage.tsx`
  - `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/KeybindingsPage.tsx`
- Feature inputs:
  - `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/dropdowns.tsx`
  - `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/game_preferences/ghost.tsx`

## Как добавлять перевод

### 1) Обычные UI-строки (кнопки, заголовки)

Используй:

```ts
const lang = getCharacterPreferencesLanguage(data);
const text = localize(lang, "English", "Русский");
```

### 2) Названия полей в Character Visuals

Добавляй пары в словарь:

- `RU_CHARACTER_FEATURE_NAMES_BY_EN` в
  `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`

Потом имя поля переводится автоматически через:

- `localizeCharacterFeatureName(...)`

### 3) Keybindings

Словари и логика находятся в:

- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/keybindingsLocalization.ts`

## Важные правила

1. Не делай новые локальные проверки языка по узкому пути в `data`.
2. Всегда используй общий резолвер `getCharacterPreferencesLanguage(data)`.
3. Любые новые русские строки сохраняй в UTF-8.
4. Если в UI появились «кракозябры», файл уже сохранён в неверной кодировке — пересохрани в UTF-8.

## Быстрая проверка

1. В игре открыть:
   - `Settings -> Interface Language -> Russian`
2. Проверить:
   - `Preferences -> Character`
   - `Preferences -> Game`
   - `Preferences -> Keybindings`
3. Если язык не сменился:
   - пересобрать TGUI
   - перекомпилировать билд
   - полностью перезапустить клиент/сервер
