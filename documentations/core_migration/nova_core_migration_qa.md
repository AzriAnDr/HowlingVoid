# Nova Core Migration QA

## Статус переноса

Бывший Nova-модульный слой перенесён в core-директории проекта без сохранения отдельного namespace-дерева. Активные DM-файлы теперь лежат в `code/` и подключаются через `tgstation.dme`; ассеты, карты, GAGS/greyscale JSON и сопутствующие ресурсы перенесены в соответствующие core-пути.

Что уже проверено технически:

- исходная Nova-модульная папка удалена;
- устаревшие folder path literals очищены из кода, карт, tgui, config, build/CI/deploy scripts и документации;
- `tgstation.dme` содержит только build-safe code includes, без старого модульного include-блока;
- ticked file enforcement проходит для `tgstation.dme` и unit test includes;
- `BUILD.cmd` проходит без ошибок DreamMaker;
- повторный `BUILD.cmd` проходит после успешной сборки;
- `bin\tgui-build.cmd` проходит, включая tsc, tests и bundle build;
- DreamDaemon стартует на собранном `tgstation.dmb` без немедленного runtime crash/stack trace.

Известные замечания после автоматических проверок:

- DreamMaker всё ещё выводит предупреждения вида `var_before_def` и `override_before_def` для части перенесённых override-файлов. Они не блокируют сборку, но это первые места для дальнейшей чистки порядка/слияния при точечных рефакторах.
- `bin\tgui-build.cmd` выводит существующие biome warnings/infos и один Rspack warning вокруг `require.context` fallback для Bun tests. Команда завершается успешно.
- DMI state merge не выполнялся автоматически. Для DMI-коллизий нужно отдельно просматривать icon states и при желании консолидировать их через ручной workflow `tools/dmi/merge_driver.py`.

## Общий smoke test

1. Запустить локальный сервер и зайти клиентом.
2. Дождаться конца инициализации карты, проверить отсутствие immediate runtime spam в логах.
3. Создать персонажа с чистыми preferences и персонажа со старым savefile.
4. Открыть основные админ-панели, preferences, loadout, orbit, cargo, vending, research, medical и silicon UI.
5. Проверить roundstart, latejoin, ghost observe/orbit, cryo/return, admin spawn нескольких перенесённых объектов.

## Персонаж и customization

- Species: проверить все Nova/HowlingVoid виды, включая body shape, language defaults, lore/examine, species traits и job restrictions.
- Bodyparts/organs: смена конечностей, внешних органов, taur/mermaid transforms, synthetic variants, liver/tox resistance, external overlays.
- Markings/accessories: body markings, hair, snout, tail, wings, ears, horns, frills, vox/skrell/nabber/custom sprite accessories.
- Genitals/ERP organs: наличие в preferences, корректные overlays, отсутствие missing organ slot errors, сохранение/загрузка.
- GAGS/greyscale: fallback configs, recolor preview, worn/inhand icons, отсутствие missing JSON в runtime.
- Preferences: import/export preferences, old save migration, randomize appearance, preview backgrounds, alternate job titles.
- Quirks/loadout: venomous bite, visitor contract, voice actor/TTS, language quirks, loadout presets and categories.

## Одежда и предметы

- Clothing overlays: digitigrade, taur, snouted, anthro, vox, skrell and custom mutant body overlays.
- Loadout gear: все новые категории, покупка/выбор/экипировка, storage contents, аксессуары.
- Weapons: modular laser rifle/carbine speech JSON, company/faction guns, sec haul, magfed turret items, gun HUD.
- Medical: hyposprays, medipens, implants, cybernetic/neuroware items, surgery tools and organs.
- Storage: bags, belts, boxes, lunchboxes, wallets, resized inventories, strip menu slot icons.
- Chameleon/reskin/GAGS items: radial menus, icon states, inhands, worn icons.

## Silicon и UI

- Borg sprites/models: выбрать модели в preferences/admin tools, проверить wide/clown/medical/security sprites.
- AI/cyborg behavior: login, click behavior, laws, module selection, HUD icons.
- Orbit/job icons: standard job icons, antag icons, custom HUD DMI references.
- Title/menu: title screen HTML, sounds, fonts, buttons, loading screen.
- TGUI consoles: preferences, interaction panel, food preferences, plant/pandemic/processing/supermatter storyteller notices, spawn panels, uplink, integrated circuits.

## Станционные системы

- Cargo: supply packs, company imports, private imports, contraband, department budgets, payroll/economy.
- Vending: imported vendors, prices, stock, custom products, access rules.
- Crafting/research: designs, techweb nodes, lathes, materials, circuit components.
- Chemistry/reagents: reagent definitions, hallucination/string JSON usage, med/food/drink reactions.
- Food/drink: recipes, preferences, vendors, service loadouts.
- Pollution/liquids: liquid machinery, pollution effects, related map objects.

## Карты, машины и руины

- Main maps: roundstart load, map-placed custom icons, areas, shuttles, station traits.
- Machines: airlocks, lights, chargers, cryosleep, colony fabricator, condos, powerator/RBMK, supermatter alerts.
- Random content: random ruins, away missions, faction shuttles, Snowglobe/CentCom/ancientmilsim content.
- Mapping helpers: custom map icon/sound helpers, planet turfs, automapper behavior.
- Map config: rock/planet configs, ruin weights, random ship event names.

## Антагонисты, ивенты и admin tools

- Antags: ashwalkers, clock cult, contractors, opposing force, marauders, deathmatch, cortical borer, xenoarch artifacts.
- ERT/admin: ERT loadouts, smites, event awards, admin tools, mentor tools, preference import verb.
- Objectives/uplinks: uplink bundles, antag opt-in preferences, objective generation, icon/HUD display.
- Events: storyteller modifiers shown in UI, event rewards, random ship events.

## Аудио и визуал

- Sounds: title/menu music, alerts, ambience, radio sounds, emotes, blooper/vox/TTS-related playback.
- Icons: inhands, worn icons, walls/floors/turfs, map-placed icons, stamps, paper assets, HUD icon cache.
- Asset cache: open UI screens that use generated/public assets and verify no missing image placeholders.
- DMI collisions: compare states in any `_additions` DMI files against the intended core target before deleting or merging.

## Особое внимание

- Любая ошибка вида missing icon/sound/json после переноса почти всегда означает старый resource path или DMI state collision, а не проблему typepath.
- Любой startup crash после добавления новых child types стоит проверять через startup caches, `subtypesof()`, `initial(...)` reads и static typepath links.
- Не создавать новые заглушки для починки проверок: если предмет или ассет отсутствует, нужно портировать его полностью или заменить существующим рабочим аналогом.
