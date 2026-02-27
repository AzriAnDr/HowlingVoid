# Локализация Preferences (Howling Void)

Этот документ описывает, как работает локализация меню `Preferences` в текущем билде и как правильно добавлять/править переводы.

## 1. Что является источником правды

Править нужно **только** файлы в:

- `tgui/packages/tgui/interfaces/PreferencesMenu/...`

Не править вручную:

- `tgui/packages/tgui-panel/node_modules/...`
- `tgui/packages/tgui-say/node_modules/...`
- `tgui/node_modules/.old_modules-.../...`

Это производные/временные копии. После сборки они могут перезаписываться.

---

## 2. Общая архитектура локализации

### 2.1 Язык интерфейса

Язык определяется через общий резолвер:

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/localization.ts`

Основные функции:

- `getCharacterPreferencesLanguage(data)`
- `localize(language, englishText, russianText?)`
- `localizeCharacterFeatureName(language, englishFeatureName)`

### 2.2 Словари

#### Character Preferences

- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/ui.ru.json`
  - общие UI-строки (кнопки, заголовки, модалки, подписи)
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/character_features.ru.json`
  - названия полей Visual/Profile
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/jobs.ru.json`
  - профессии, альтернативные названия, опыт
- `tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/locales/species_food.ru.json`
  - еда/биопредпочтения

#### Game Preferences

- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/features.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/categories.ru.json`
- `tgui/packages/tgui/interfaces/PreferencesMenu/GamePreferences/locales/keybindings.ru.json`

#### Shared dropdowns/features

- `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/locales/dropdowns.ru.json`

---

## 3. Как добавить перевод (практика)

## 3.1 Для обычной строки в TSX

В компоненте:

```tsx
const language = getCharacterPreferencesLanguage(data);
localize(language, "Export Preferences");
```

Добавь ключ в `ui.ru.json`:

```json
{
	"Export Preferences": "Экспорт преференсов"
}
```

## 3.2 Для названия поля в Visual/Profile

Если строка берётся из `feature.name`, добавляй её в:

- `character_features.ru.json`

Пример:

```json
{
	"Allow Emissives": "Разрешить эмиссивы"
}
```

## 3.3 Для профессий

Добавляй переводы в:

- `jobs.ru.json`

(названия ролей, альтернативные тайтлы, опыт и служебные подписи JobsPage)

## 3.4 Для клавиш

Используется отдельный локализатор:

- `GamePreferences/keybindingsLocalization.ts`
- словарь: `GamePreferences/locales/keybindings.ru.json`

---

## 4. Важные правила

1. Не хардкодь русские строки в TSX, если можно взять из JSON.
2. Не добавляй дублирующие «локальные» функции выбора языка по проекту.
   Используй `getCharacterPreferencesLanguage(data)`.
3. Один и тот же английский ключ должен иметь одинаковый перевод везде.
4. Если строка не переводится, сначала проверь точный ключ (регистр, двоеточие, пробелы).

---

## 5. Сборка и проверка

Проверка в игре:

1. Включить русский язык интерфейса.
2. Открыть Preferences и пройти все вкладки:
   - Character
   - Loadout
   - Occupations
   - Augments+
   - Languages
   - Antagonists
   - Quirks and Personality
   - Game Preferences / Keybindings

Если видишь старый текст:

- перезапусти окно Preferences;
- при необходимости перезапусти BYOND-клиент (кэш `tgui.bundle.js`).

---

## 6. Типовые проблемы и решения

## Проблема: перевод «слетел» полностью

Проверь, не пустой ли JSON (например `{}`). Он пиздец как часто любит чиститься во время компиляции.

## Проблема: часть строк на английском

Ключа нет в нужном JSON или он отличается от реального (например `Name:` vs `Name`).

## Проблема: хуета со сломанной кодировкой (`РџСЂ...`)

Файл сохранён в неверной кодировке. Пересохрани в UTF-8. Оно любит ломаться.

## Проблема: изменения есть в коде, но в игре нет

Не была выполнена сборка `tgui:build` или клиент держит старый кэш.

---

## 7. Рекомендуемый workflow для разработчика

1. Найди место, где рендерится строка.
2. Определи словарь (ui/jobs/features/dropdowns/keybindings).
3. Добавь ключ в JSON.
4. Если нужно — оберни строку в `localize(...)`.
5. Собери `tgui`.
6. Проверяй в игре на русском.
7. Не редактируй производные копии в `node_modules`.

---

## 8. Минимальный чек-лист перед коммитом

- [ ] Нет незакрытых кавычек/запятых в JSON
- [ ] Нет дубликатов ключей с разными переводами
- [ ] В игре строка реально перевелась
- [ ] Изменения сделаны в `tgui/packages/tgui/...`, а не в копиях
