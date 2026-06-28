# Codex Instructions for HowlingVoid

## 1. Project Overview

- **HowlingVoid (HV, ХВ, ВП) — главный репозиторий.** Все изменения, поиск информации и работа с кодом выполняются в нём по умолчанию, если пользователь явно не указывает другой репозиторий. Когда в рабочем пространстве открыто несколько проектов, AI должен работать именно с HowlingVoid, а другие репозитории использовать только как справочные источники или если на это есть прямое указание пользователя.
- This codebase is a BYOND SS13 fork in the **TG/NovaSector** family. HowlingVoid is downstream of NovaSector (`code/` содержит Nova Sector additions), а HowlingVoid-специфичные дополнения живут в `code/`.
- **Концепция билда:** HowlingVoid — станционный билд на основе NovaSector. Основная геймплейная петля — классическая станционная SS13 с атмосферой, работой, антагонистами и исследованием. Ключевые механики NovaSector (экономика, кастомизация видов, расширенное снаряжение) унаследованы и расширяются.
- Основной игровой код на DM лежит в `code/` (TG-style структура: `__DEFINES/`, `controllers/`, `datums/`, `modules/` и т. д.).
- Отдельных активных модульных папок/оверрайд-слоёв больше нет: старые Nova/HowlingVoid module trees были вмёржены в основную структуру. Legacy/migration-документацию и старые module-tree пути можно использовать только как историческую справку, а новые изменения нужно вносить в актуальные пути проекта.
- UIs реализованы через **tgui** в `tgui/` (TypeScript/React, сборка через Node / Juke / Bun).
- **Портирование** — перенос кода с одного билда (репозитория/форка) на другой. При портировании переносится не только DM-код, но и все необходимые ассеты (спрайты `.dmi`, звуки `.ogg`/`.wav`, TGUI-интерфейсы и прочие ресурсы), без которых портируемый контент не будет корректно работать.

## 2. Где писать код (важно)

- **По умолчанию новый DM-код пишем прямо в `code/`**, в подходящий модуль/поддиректорию, следуя уже существующей структуре.
- Исторические модульные папки (`modular_*`, `master_files`, `former_*_module_tree` и похожие legacy-деревья) не являются активным местом разработки. Не добавлять туда новые фичи и не восстанавливать отдельный legacy override layer без прямого указания пользователя.
- Перед изменением или расширением логики AI должен искать актуальную реализацию по активному дереву `code/` и учитывать уже вмёрженные HowlingVoid/Nova изменения в тех же файлах или соседних subsystem-файлах.
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
  - Актуальные реализации смотрим в `code/modules/surgery`, `code/modules/mob`, `code/modules/client/preferences` и соседних файлах; `code/modules/` здесь является частью основного TG-style дерева, а не отдельным legacy modular layer.
  - Body markings используют `/datum/body_marking` и обрабатываются логикой в `code/modules/surgery/bodyparts/_bodyparts.dm`.
  - Внешние органы/оверлеи используют `/datum/bodypart_overlay/mutant` и битфлаги слоёв в `code/__DEFINES/mobs.dm`.
- When changing layering/appearance:
  - Use the existing layer constants (`BODY_FRONT_LAYER`, `ABOVE_BODY_FRONT_HEAD_LAYER`, `HEAD_LAYER`, `HAIR_LAYER`, `EXTERNAL_FRONT_*` bitflags) instead of raw numbers.
  - Respect existing helpers like `bitflag_to_layer()` and `mutant_bodyparts_layertext()`.
- При добавлении кода, связанного с Nova-фичами (экономика, виды, снаряжение и т.д.), в первую очередь искать в активных путях (`code/modules/`, `code/datums/`, `code/controllers/` и соседних директориях) — там может уже быть вмёрженная реализация, которую нужно расширить.

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
  - Compile via the build script and run a local DreamDaemon server (`RUN_SERVER.bat` / `RUN_SERVER.cmd`, VS Code `Launch DreamDaemon`, or equivalent guide in `.github/guides/`).
- AI agents should:
  - Code carefully and keep changes narrow: this build is unstable, and a bad change can produce a hanging `STACK TRACE` that crashes the local server immediately after compilation.
  - After making code changes, run an appropriate compile/error-check step and then launch the DreamDaemon version to verify the local server does not crash on startup before reporting completion.
  - Avoid committing or creating branches; leave that to humans.
  - **Post-edit verification loop:** write the code, run compilation/error checking, fix any reported errors, rerun the same check, launch DreamDaemon, confirm the local server reaches startup without an immediate crash, and only then report the result to the user.
  - **Preferred shell check for Codex/local agents:** run `.\BUILD.cmd` from the repository root, then run DreamDaemon against the produced `.dmb`. Use `BUILD.cmd` instead of `BUILD.bat` because `BUILD.bat` ends with `pause` and can hang unattended automation.
  - Preferred Windows DreamDaemon command after a successful build:
    ```powershell
    & "C:\Program Files (x86)\BYOND\bin\dreamdaemon.exe" "C:\All\HowlingVoid\tgstation.dmb" -trusted
    ```
  - If the build reports errors, fix them and rerun `.\BUILD.cmd` until it completes successfully or a real blocker must be reported to the user. If DreamDaemon starts and then crashes, inspect the runtime output/stack trace, fix the cause, rebuild, and rerun DreamDaemon.
  - **VS Code diagnostics path:** when available, also run task `dm: refresh diagnostics` after DM code changes to refresh the Problems panel. This task depends on `dm: build - tgstation.dme`, updates DM diagnostics, and is useful when errors only appear after compilation or live diagnostics are stale.
  - If `dm: refresh diagnostics` is not accessible from the agent environment, use `.\BUILD.cmd` as the authoritative shell check and tell the user that VS Code Problems may still need a manual diagnostics refresh.
  - **Важно про «застрявшие» diagnostics:** записи в `Problems`, пришедшие от build task / `$dreammaker` problem matcher, могут отставать от текущего содержимого файла. Если `get_errors` продолжает ссылаться на код, которого уже нет в файле, AI должен считать такие diagnostics потенциально устаревшими, сверять их с текущим содержимым файла и при необходимости просить новый прогон `dm: refresh diagnostics` или перезагрузку окна VS Code.
  - **Важно про «ошибки только после компиляции»:** при расхождении между live diagnostics и результатом `dm: refresh diagnostics` приоритет всегда у результата компиляции.
  - Для TGUI-правок `dm: refresh diagnostics` не заменяет TGUI-проверку: при изменениях в TGUI AI должен запускать соответствующую TGUI-проверку/билд через существующие project commands, исправлять ошибки/предупреждения и повторять проверку перед финальным ответом.

## 7. How AI Should Operate Here

### Adding New Types Safely

- The guidance in this section applies to **all new child types**, not only circuit boards or black market content.
- A new subtype is preferred when it adds **behaviour, lifecycle differences, or clear type identity**. If the change is mostly a bundle of var overrides or content data, prefer a datum, preset, config object, registry entry, or runtime setup proc.
- Before extending an existing type family in `code/`, search the active implementation and nearby included files for existing HowlingVoid/Nova changes that may already change initialization, related type vars, or startup behavior.
- Before adding a subtype, check whether the parent family or adjacent systems use `subtypesof()`, `typesof()`, broad `initial(...)` reads, startup caches, auto-generated assets, admin spawn menus, mapping helpers, design registries, or similar reflective startup logic. New child types are risky in those systems.
- Avoid creating static bidirectional type references. If type `A` stores a typepath to `B`, and `B` stores a typepath back to `A`, that pair is considered unsafe unless there is a strong reason and the startup path has been reviewed carefully.
- Sensitive families should keep static type metadata shallow. If a new variant in such a family only needs different data, configure it in `Initialize()`, a dedicated setup proc, or a preset datum instead of closing another typepath cycle in declarations.
- Treat the following as a review checklist before adding a child type:
  1. Does the subtype need its own type identity, or only variant data?
  2. Can a reverse relationship be resolved at runtime instead of another declared typepath?
  3. Is the family scanned at startup or used by reflective caches?
  4. Can the variant be represented as a preset, datum, registry entry, or instance configuration instead?
  5. After the change, does `.\BUILD.cmd` succeed and does DreamDaemon start without an immediate crash?
- If a problem appears only after compilation, during DreamDaemon startup, suspect a type-tree or startup-reflection issue first. Audit recent child types and new typepath links before adding narrow workarounds.
- When in doubt, keep inheritance focused on behavior and move variation into data.

- Делать небольшие, точечные изменения и уважать существующую структуру `code/` вместо восстановления старых модульных слоёв.
- При добавлении фичи:
  - Найти, где уже реализован похожий функционал в `code/`, и расширить его тем же стилем.
  - Проверить, нет ли уже похожей реализации в активном дереве `code/` — если есть, работать с ней на месте.
  - Не создавать новые legacy-модульные слои; предпочитать прямые изменения в актуальных путях проекта.
- При сомнениях по архитектуре просматривать соседние файлы/подсистемы (`code/modules/`, `code/datums/`, `code/controllers/`) и копировать принятые там паттерны.
- Не менять лицензии, юридические тексты и глобальные политики проекта.
- **ВАЖНО: При создании новых .dm файлов ВСЕГДА добавлять их в `tgstation.dme` в алфавитном порядке в соответствующей секции.** BYOND требует явного указания всех файлов в .dme для компиляции.

## 8. Configuration Flags — проверка перед реализацией

Многие фичи в проекте управляются флагами конфигурации (`CONFIG_GET(flag/...)`). **Перед реализацией фичи, которая зависит от конфига, AI должен:**

1. **Найти определение флага** — искать `/datum/config_entry/flag/имя_флага` в `code/controllers/configuration/entries/`.

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
