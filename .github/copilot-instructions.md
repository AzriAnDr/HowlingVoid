# GitHub Copilot Instructions for HowlingVoid

## 1. Project Overview
- **HowlingVoid (HV, ХВ, ВП) — главный репозиторий.** Все изменения, поиск информации и работа с кодом выполняются в нём по умолчанию, если пользователь явно не указывает другой репозиторий. Когда в рабочем пространстве открыто несколько проектов, AI должен работать именно с HowlingVoid, а другие репозитории использовать только как справочные источники или если на это есть прямое указание пользователя.
- This codebase is a BYOND SS13 fork in the **TG/NovaSector** family. HowlingVoid is downstream of NovaSector (`modular_nova/` содержит Nova Sector additions), а HowlingVoid-специфичные дополнения живут в `modularhowling_void/`.
- **Концепция билда:** HowlingVoid — станционный билд на основе NovaSector. Основная геймплейная петля — классическая станционная SS13 с атмосферой, работой, антагонистами и исследованием. Ключевые механики NovaSector (экономика, кастомизация видов, расширенное снаряжение) унаследованы и расширяются.
- Основной игровой код на DM лежит в `code/` (TG-style структура: `__DEFINES/`, `controllers/`, `datums/`, `modules/` и т. д.).
- UIs реализованы через **tgui** в `tgui/` (TypeScript/React, сборка через Node / Juke / Bun).
- **Портирование** — перенос кода с одного билда (репозитория/форка) на другой. При портировании переносится не только DM-код, но и все необходимые ассеты (спрайты `.dmi`, звуки `.ogg`/`.wav`, TGUI-интерфейсы и прочие ресурсы), без которых портируемый контент не будет корректно работать.

## 2. Где писать код (важно)
- **По умолчанию новый DM-код пишем прямо в `code/`**, в подходящий модуль/поддиректорию, следуя уже существующей структуре.
- Папки `modularhowling_void/` и `modular_nova/` можно читать как источник примеров и существующего кода, но **не нужно автоматически помещать туда новые фичи** — прямые изменения в `code/` предпочтительны.
- **Проверка оверрайдов в модульных папках:** перед изменением или расширением кода в `code/` AI **обязан** проверить, нет ли в `modular_nova/master_files/` или `modularhowling_void/master_files/` оверрайдов затрагиваемых процедур, типов или файлов. Если оверрайд найден, его нужно учесть: либо перенести логику в core и убрать оверрайд, либо убедиться, что изменение в core не конфликтует с оверрайдом. Игнорирование оверрайдов приводит к трудноотлавливаемым багам.
- Если логика явно относится к уже существующему модулю (карго, медицина, органы и т. д.), дописываем туда же, где находится текущая реализация (например, в `code/modules/...`).
- Для общих констант и макросов используем `code/__DEFINES/`.

## 3. Build & Run Workflows
- **Main build:** use the provided scripts, not DreamMaker directly.
  - Windows: `BUILD.bat` in repo root (or `tools/build/build.bat`).
  - VS Code: `Ctrl+Shift+B` or the `Build All` task (see `.vscode` tasks).
  - Linux: `tools/build/build.sh`.
- The build script handles DM, tgui, and other assets; do not add separate ad‑hoc compilation steps.
- For tgui:
  - Use `bin/tgui-build.cmd` or `tools/build/build.sh tgui` for production builds.
  - Use `bin/tgui-dev.cmd` or `tools/build/build.sh tgui-dev` while developing interfaces.
- When adding new tgui interfaces, follow the existing patterns in `tgui/packages/tgui/interfaces/` and update routing in `tgui/packages/tgui/routes.ts` if needed.

## 4. Code Conventions & Patterns
- **IMPORTANT: Use ONLY English in all code** (variable names, comments, descriptions, etc.) unless the user explicitly requests a different language.
- Follow TG/Nova DM style from existing files in the same folder:
  - Type paths like `/obj/item/...`, procs with `proc/` syntax, `..()` for supercalls.
  - Use existing macros and constants from `code/__DEFINES/` instead of new magic numbers.
- For species, organs, body markings, and sprite accessories:
  - Актуальные реализации смотрим в `code/modules/surgery`, `code/modules/mob`, `code/modules/client/preferences` и соседних файлах; модульные директории (`modular_nova/modules/`) можно использовать как примеры.
  - Body markings используют `/datum/body_marking` и обрабатываются логикой в `code/modules/surgery/bodyparts/_bodyparts.dm`.
  - Внешние органы/оверлеи используют `/datum/bodypart_overlay/mutant` и битфлаги слоёв в `code/__DEFINES/mobs.dm`.
- When changing layering/appearance:
  - Use the existing layer constants (`BODY_FRONT_LAYER`, `ABOVE_BODY_FRONT_HEAD_LAYER`, `HEAD_LAYER`, `HAIR_LAYER`, `EXTERNAL_FRONT_*` bitflags) instead of raw numbers.
  - Respect existing helpers like `bitflag_to_layer()` and `mutant_bodyparts_layertext()`.
- При добавлении кода, связанного с Nova-фичами (экономика, виды, снаряжение и т.д.), в первую очередь смотреть в `modular_nova/modules/` — там может уже быть реализация, которую нужно расширить.

## 5. Maps, Assets, and Tools

### Карты
- Базовые карты лежат в `_maps/` и связанных поддиректориях.
- При изменении существующих карт предпочтительно минимально трогать `.dmm` и по возможности использовать имеющиеся инструменты/автомапперы; при правках основного `.dmm` следить, чтобы они хорошо мержились.

### Ассеты (иконки, звуки)
- Новые иконки и звуки по умолчанию добавляем в основные `icons/` и `sound/`, следуя структуре TG.
- При правках бинарных ассетов (`.dmi`, `.ogg`) использовать хуки из `tools/hooks/`, если это требуется workflow'ом.

### 5.1 DMI Merge Driver — инструмент для работы со спрайтами
Расположение: `tools/dmi/merge_driver.py`

**Назначение:** Универсальный инструмент для работы с DMI файлами (иконками BYOND). Поддерживает:
- Просмотр содержимого DMI файлов
- Копирование icon states между файлами
- Переименование и удаление states
- Трёхстороннее слияние при Git-конфликтах
- Портирование спрайтов из других репозиториев

**Запуск (через bootstrap Python):**
```bash
# Windows
tools\bootstrap\python.bat -m dmi.merge_driver [options]

# Или через bat-файл для post-hoc
tools\dmi\Resolve Icon Conflicts.bat
```

**Режимы работы:**

1. **Список состояний DMI:**
   ```bash
   tools\bootstrap\python.bat -m dmi.merge_driver --list icons/mob/human.dmi
   ```

2. **Копирование states из одного DMI в другой:**
   ```bash
   # Скопировать все states
   tools\bootstrap\python.bat -m dmi.merge_driver --copy-states source.dmi target.dmi

   # Скопировать конкретные states
   tools\bootstrap\python.bat -m dmi.merge_driver --copy-states source.dmi target.dmi --states "state1,state2"

   # Не перезаписывать существующие
   tools\bootstrap\python.bat -m dmi.merge_driver --copy-states source.dmi target.dmi --no-overwrite
   ```

3. **Переименование states:**
   ```bash
   # Переименовать один state
   tools\bootstrap\python.bat -m dmi.merge_driver --rename file.dmi "old_name:new_name"

   # Массовая замена паттерна в именах
   tools\bootstrap\python.bat -m dmi.merge_driver --rename-pattern file.dmi "_old" "_new"
   ```

4. **Удаление states:**
   ```bash
   tools\bootstrap\python.bat -m dmi.merge_driver --delete file.dmi "state1,state2,state3"
   ```

5. **Three-way merge (слияние трёх версий):**
   ```bash
   tools\bootstrap\python.bat -m dmi.merge_driver --merge base.dmi ours.dmi theirs.dmi output.dmi
   ```

6. **Post-hoc разрешение конфликтов Git:**
   ```bash
   tools\bootstrap\python.bat -m dmi.merge_driver --posthoc
   ```

**Как AI должен использовать:**
- При портировании спрайтов из другого репозитория — использовать `--copy-states`
- При переименовании states — использовать `--rename` или `--rename-pattern`
- При удалении устаревших states — использовать `--delete`
- При конфликтах в DMI после git merge — предложить запустить `--posthoc` или `Resolve Icon Conflicts.bat`
- Для просмотра содержимого DMI — использовать `--list`
- **НЕ запускать автоматически** — предлагать команду пользователю для ручного запуска

## 6. Testing Expectations
- Contributors are expected to test locally before changes are considered complete:
  - Compile via the build script and run a local server (`RUN_SERVER.bat` / `RUN_SERVER.cmd` or equivalent guide in `.github/guides/`).
- AI agents should:
  - When they make runnable changes, suggest running the existing build tasks instead of inventing new commands.
  - Avoid committing or creating branches; leave that to humans.
  - Никогда не запускать полную сборку проекта автоматически; **Копилот не должен запускать `BUILD.bat`, `tools/build/*`, `bin/tgui-build.cmd` и другие широкие сборочные скрипты** — запуск полной сборки выполняет человек.
  - **Исключение для диагностики:** после любых правок кода AI **обязан** запускать task `dm: refresh diagnostics` как обязательный post-edit шаг. Эту же задачу нужно повторно запускать после починки ошибок перед очередным `get_errors`, чтобы обновить DM diagnostics.
  - Task `dm: refresh diagnostics` запускает узкую DM-компиляцию через уже существующий `dm: build - tgstation.dme`, обновляет DM diagnostics и подходит для случаев, когда ошибки проявляются только после компиляции или `Problems` не синхронизируются после обычных live diagnostics. Этот task сам по себе не запускает DreamSeeker или DreamDaemon; запуск игры/сервера остаётся только у launch-конфигураций.
  - **Важно про «застрявшие» diagnostics:** записи в `Problems`, пришедшие от build task / `$dreammaker` problem matcher, могут отставать от текущего содержимого файла. Если `get_errors` продолжает ссылаться на код, которого уже нет в файле, AI должен считать такие diagnostics потенциально устаревшими, сверять их с текущим содержимым файла и при необходимости просить новый прогон `dm: refresh diagnostics` или перезагрузку окна VS Code.
  - **Важно про «ошибки только после компиляции»:** при расхождении между live diagnostics и результатом `dm: refresh diagnostics` приоритет всегда у результата компиляции.
  - Для TGUI-правок `dm: refresh diagnostics` не заменяет TGUI-проверку: при изменениях в TGUI AI всё так же должен инициировать проверку/билд TGUI через пользователя.
  - При изменениях в TGUI обязательно инициировать проверку/билд TGUI (через пользователя): при наличии ошибок/предупреждений — исправлять их и затем сообщать об окончании работы после устранения проблем.

## 7. How AI Should Operate Here
- Делать небольшие, точечные изменения и уважать существующую структуру `code/` вместо принудительной модульности.
- При добавлении фичи:
  - Найти, где уже реализован похожий функционал в `code/`, и расширить его тем же стилем.
  - Проверить, нет ли уже похожей реализации в `modular_nova/modules/` или `modularhowling_void/modules/` — если есть, работать с ней или перенести в core.
  - Не создавать новые модульные слои без необходимости; предпочитать прямые изменения в core.
- При сомнениях по архитектуре просматривать соседние файлы/подсистемы (`code/modules/`) и копировать принятые там паттерны; `modular_nova/modules/` также можно использовать как источник примеров.
- Не менять лицензии, юридические тексты и глобальные политики проекта.
- **ВАЖНО: При создании новых .dm файлов ВСЕГДА добавлять их в `tgstation.dme` в алфавитном порядке в соответствующей секции.** BYOND требует явного указания всех файлов в .dme для компиляции.

## 8. Configuration Flags — проверка перед реализацией
Многие фичи в проекте управляются флагами конфигурации (`CONFIG_GET(flag/...)`). **Перед реализацией фичи, которая зависит от конфига, AI должен:**

1. **Найти определение флага** — искать `/datum/config_entry/flag/имя_флага` в `code/controllers/configuration/entries/` или `modular_nova/master_files/code/controllers/configuration/entries/`.

2. **Проверить, включён ли флаг** — конфигурационные файлы:
   - `config/config.txt`
   - `config/game_options.txt`
   - Флаг включён, если строка с его именем (в UPPER_CASE) присутствует и не закомментирована.

3. **Предупредить пользователя**, если:
   - Фича использует `CONFIG_GET(flag/...)` и флаг НЕ включён в конфиге — фича не будет работать!
   - Нужно либо добавить флаг в конфиг, либо убрать зависимость от конфига.

4. **При создании новых фич** — предпочитать решения, которые работают "из коробки" без дополнительных флагов конфигурации, если только флаг не нужен для опциональности фичи.

## 9. No Stubs or Placeholders — только реальные предметы
- **В билде не должно быть заглушек (stubs), плейсхолдеров и «временных» предметов.** Все объекты, типы и предметы в коде должны быть полноценными, рабочими реализациями с настоящими спрайтами, описаниями и механиками.
- При портировании контента из другого репозитория: если портируемый предмет зависит от типа, которого нет в HowlingVoid, AI должен **либо портировать этот тип целиком** (со всеми ассетами), **либо заменить его на ближайший актуальный аналог**, уже существующий в HowlingVoid. Создавать пустые заглушки (`/obj/item/placeholder`, stub-типы без спрайтов и т. д.) — **запрещено**.
- Если для реализации фичи требуется предмет, которого нет в проекте, AI должен сообщить об этом пользователю и предложить варианты: портировать недостающий предмет целиком или использовать существующую замену.
- Это правило распространяется на все аспекты: DM-типы, иконки, звуки, TGUI-интерфейсы — всё должно быть рабочим, а не заглушкой.
