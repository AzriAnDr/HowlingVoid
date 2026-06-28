# Карта перенесённого контента Howling Void

Этот документ показывает, что было вынесено из старого `former_howling_void_module_tree/` и где это теперь искать и править в активном дереве проекта.

## Общее правило

Бывшие `former_howling_void_module_tree/` и `former_nova_module_tree/` больше не являются активными рабочими деревьями. Не добавляйте туда новый код и не используйте эти пути как место для правок. Новые изменения Howling Void должны жить в подходящем файле активного дерева:

- TG-style системы кладём в `code/`.
- Nova-кастомизацию и Nova-owned системы ищем и правим там, куда они уже вмёржены: обычно в `code/modules/`, `code/datums/`, `code/__DEFINES/~nova_defines/`, `icons/` или `sound/`.
- Иконки кладём в `icons/` или уже существующую активную папку иконок для этой системы.
- Звуки кладём в `sound/`.
- Каждый новый `.dm` файл должен быть добавлен в `tgstation.dme`.

Перед изменением перенесённой системы сначала ищите существующий тип в активном дереве `code/` и связанных ассетах/конфигах. Большая часть старых модульных файлов была влита в уже существующие файлы типов.

## Экономика

Старые источники:

- `former_howling_void_module_tree/code/economy/job_pay_rebalance.dm`
- `former_howling_void_module_tree/code/economy/vending_price_rebalance.dm`

Новые места:

- таблица зарплат: `code/modules/economy/howling_void_job_pay.dm`
- таблица цен торговых автоматов: `code/modules/economy/howling_void_vending_prices.dm`

Эти файлы специально подключены поздно в `tgstation.dme`, после TG и Nova объявлений работ и автоматов. Так их var overrides применяются последними.

## Виды и нюх

Старый источник:

- `former_howling_void_module_tree/modules/modular_species/`

Новые места:

- общие species-define’ы: `code/__DEFINES/~nova_defines/species_howling_void.dm`
- действия нюха: `code/datums/actions/mobs/scent.dm`
- вид Nabber: `code/modules/mob/living/carbon/human/species_types/nabber/`
- species-иконки Nabber: `icons/mob/species/nabber/`
- clothing-иконки Nabber: `icons/mob/clothing/species/nabber/`
- item-иконки Nabber: `icons/obj/species/nabber/`
- звуки Nabber: `sound/mobs/humanoids/nabber/`
- GAGS fallback-конфиги Nabber: `code/datums/greyscale/json_configs/gags/nabber_fallbacks/`
- иконка aquatic organs: `icons/organs/aquatic_organs.dmi`
- Shadekin-иконки и органы: `code/modules/customization/mob/living/carbon/human/species/shadekin.dm`, `code/modules/bodyparts/shadekin_bodyparts.dm`, `code/modules/shadekin/organs.dm`, `icons/bodyparts/` и `icons/shadekin/`.

Plural-файлы видов вроде `aquatics.dm`, `dullahans.dm` и `vulpkanins.dm` не оставлялись отдельными файлами. Их содержимое влито в соответствующие существующие species-файлы в `code/`.

## Карго рядом с экономикой

Старые источники:

- `former_howling_void_module_tree/modules/cargo/supply_packs/`
- armory/surplus cargo packs из старого ported content

Новые места:

- company cargo packs: `code/modules/cargo/packs/companies/`
- surplus/company weapon crate entries: `code/modules/cargo/packs/companies/` and related cargo pack files

Используйте существующие company pack-файлы вместо создания нового cargo-модуля.

## Оружие и projectiles

Старые источники включали projectile speed код и surplus weapon content.

Новые места:

- интеграция projectile speed multiplier: `code/modules/projectiles/gun.dm`
- realistic ballistic ammo: `code/modules/projectiles/ammunition/ballistic/realistic.dm`
- surplus guns: `code/modules/projectiles/guns/ballistic/surplus/`
- surplus gun icons: `icons/obj/weapons/guns/surplus/`
- surplus gun sounds: `sound/items/weapons/gun/surplus/`

Если добавляете связанное surplus-оружие, держите код оружия в surplus gun-папке, а доступность через карго добавляйте в существующие cargo crate-файлы.

## Visual FX

Старый источник:

- `former_howling_void_module_tree/code/visual_fx/ported/`

Новые места:

- debris element: `code/datums/elements/debris.dm`
- debris particles: `code/game/objects/effects/particles/debris.dm`
- explosion visuals: `code/game/objects/effects/temporary_visuals/explosion_visuals.dm`

Для будущих visual-портов используйте существующие папки effects и temporary visuals.

## Морды и кастомизация

Старый источник:

- `former_howling_void_module_tree/modules/snouts/`

Новые места:

- snout accessory datums: `code/modules/customization/mob/dead/new_player/sprite_accessories/snout.dm`
- связанные define’ы: `code/__DEFINES/~nova_defines/DNA.dm`
- DMI states морд влиты в существующие customization icon-файлы.

Не создавайте отдельный snout-модуль для новых морд. Добавляйте новые entries рядом с уже существующими snout accessory definitions.

## Постеры

Старые источники:

- `former_howling_void_module_tree/modules/posters/`
- `former_howling_void_module_tree/modules/ported_content/poster_contest/posters/`

Новые места:

- official posters: `code/game/objects/effects/posters/official.dm`
- contraband posters: `code/game/objects/effects/posters/contraband.dm`
- общая poster-логика остаётся в `code/game/objects/effects/posters/poster.dm`
- poster sprites влиты в существующие poster DMI-файлы.

Новые постеры добавляйте в official или contraband файл в зависимости от игровой категории постера.

## MOD suits

Старые источники:

- `former_howling_void_module_tree/modules/police_modsuit/`
- MOD suit content из старого ported content

Новые места:

- policing MOD suit: `code/modules/mod/mod_theme_policing.dm`
- frontline MOD suit: `code/modules/mod/mod_theme_frontline.dm`
- customization entries MOD suits: `code/modules/customization/mob/living/carbon/human/MOD_sprite_accessories/mod_themes.dm`
- MOD suit icons: `icons/obj/clothing/modsuit/policing/` и `icons/obj/clothing/modsuit/frontline/`
- звуки policing MOD suit: `sound/items/modsuit/policing/`

Новые MOD suit themes держите в `code/modules/mod/`, если они определяют реальное поведение костюма.

## Маппинг и зоны

Старый источник:

- `former_howling_void_module_tree/modules/mapping/`

Новое место:

- away и special area definitions: `code/game/area/areas/away_content.dm`

Связанные area types добавляйте рядом с существующими away-content или map-specific area definitions.

## Storage items

Старый источник:

- `former_howling_void_module_tree/modules/items/storages/`

Новое место:

- storage item definitions: `code/modules/items/bags.dm` and nearby storage files under `code/modules/items/`

Для небольших семейств предметов используйте существующие active item/storage-файлы вместо восстановления отдельного storage-модуля.

## Interaction menu

Старый источник:

- `former_howling_void_module_tree/modules/interaction_menu/code/`

Новые места:

- `code/modules/interaction_menu/additional_interactions.dm`
- `code/modules/interaction_menu/item_interactions.dm`

Будущие interaction additions группируйте по смыслу: общие mob interactions отдельно, item-driven interactions отдельно.

## Одежда

Старый источник:

- `former_howling_void_module_tree/modules/clothing/`

Новые места:

- код обуви: `code/modules/clothing/shoes/boots.dm`
- skirts and dresses: `code/modules/clothing/under/skirts_dresses.dm`
- loadout и item additions влиты в существующие clothing/loadout-файлы.
- иконки обуви: `icons/mob/clothing/feet.dmi`, `icons/obj/clothing/shoes.dmi` и Nova digi-footwear icons.
- иконки skirts and dresses: существующие Nova skirt/dress DMI-файлы.

Когда добавляете новую одежду, сначала проверьте существующий clothing category file и соответствующие object, worn и digitigrade icon-файлы.

## Прыжки и клики

Старый источник:

- ported jump click content из `ported_content`.

Новые места:

- основной click handling: `code/_onclick/click.dm`
- alt/middle click handling: `code/_onclick/click_alt_middle.dm`
- звуки прыжка: `sound/effects/jump_female.ogg` и `sound/effects/jump_male.ogg`

Изменения click behavior держите в `_onclick` файлах. Не меняйте дальность прыжка, если это не было явно запрошено.

## Чеклист поддержки

Перед тем как считать порт завершённым:

1. Найдите старые `former_howling_void_module_tree` / `former_nova_module_tree` пути в `tgstation.dme`, `code/`, `_maps/` и config-файлах; в активных include/reference путях их быть не должно.
2. Убедитесь, что каждый новый `.dm` файл добавлен в `tgstation.dme`.
3. Проверьте, что все referenced `.dmi`, `.ogg` и `.wav` файлы существуют.
4. Data-only rebalance держите читаемыми таблицами, если разброс значений по файлам усложнит поддержку.
5. Запустите `.\BUILD.cmd`.
6. Запустите DreamDaemon и убедитесь, что сервер не падает сразу на старте.
