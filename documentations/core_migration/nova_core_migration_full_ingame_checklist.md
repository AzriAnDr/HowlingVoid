# Полный ingame-чеклист после переноса Nova-кода в core

Этот чеклист нужен именно для ручной проверки в игре после удаления отдельного Nova-слоя. Автоматическая сборка подтверждает, что проект компилируется и сервер стартует, но не доказывает, что все иконки, JSON, DMI states, UI references, loadout items, карты и runtime-пути ведут себя правильно в живом раунде.

## 0. Как проводить проверку

- [ ] Запустить локальный сервер на свежесобранном `tgstation.dmb`.
- [ ] Зайти клиентом обычным игроком.
- [ ] Зайти/перезапустить клиентом с админ-правами.
- [ ] Дождаться полной инициализации раунда.
- [ ] Включить видимость runtime/log spam, смотреть server output и admin runtime panels.
- [ ] Проверить один раунд с чистым savefile.
- [ ] Проверить один раунд со старым preferences savefile.
- [ ] Проверить roundstart spawn.
- [ ] Проверить latejoin spawn.
- [ ] Проверить ghost observe/orbit.
- [ ] Проверить cryosleep и возврат/latejoin flow.
- [ ] Проверить admin spawn перенесенных предметов через spawn tools.
- [ ] Проверить mapload objects: не только admin-spawn, но и уже расставленные на карте объекты.
- [ ] После каждой крупной зоны смотреть runtimes: missing icon, missing icon_state, cannot read file, json_decode, bad typepath, null client, null mind, invalid preference key.

## 1. Startup, round flow, базовая стабильность

- [ ] Сервер стартует без немедленного stack trace.
- [ ] Subsystems инициализируются без зависания.
- [ ] Lobby открывается, title screen виден, кнопки работают.
- [ ] Новый игрок может создать персонажа и попасть в setup.
- [ ] Ready/Unready работает.
- [ ] Start Now/force start работает.
- [ ] Roundstart профессии выдаются.
- [ ] Latejoin профессии выдаются.
- [ ] Ghost roles открываются.
- [ ] Observe/orbit работает.
- [ ] Admin follow/jump to работает.
- [ ] Preferences сохраняются и загружаются после reconnect.
- [ ] Перезапуск раунда не оставляет runtime spam от перенесенных датумов/кэшей.

## 2. Preferences, character setup, save migration

- [ ] Открыть Preferences.
- [ ] Переключить все основные вкладки character setup.
- [ ] Проверить, что CharacterPreview не пустой.
- [ ] Проверить preview backgrounds.
- [ ] Проверить randomize appearance.
- [ ] Проверить import preferences admin verb.
- [ ] Проверить export/import старого preferences JSON.
- [ ] Проверить savefile migration на старом сейве.
- [ ] Проверить dev preferences.
- [ ] Проверить альтернативные job titles.
- [ ] Проверить protected roles/whitelist-gated roles.
- [ ] Проверить player ranks отображение.
- [ ] Проверить voice preference.
- [ ] Проверить TTS/voice actor preference.
- [ ] Проверить blooper voice настройки.
- [ ] Проверить chat colors.
- [ ] Проверить height scaling.
- [ ] Проверить pixel shift.
- [ ] Проверить pixel tilt.
- [ ] Проверить disable worn FOV preference.
- [ ] Проверить language preferences.
- [ ] Проверить antag opt-in preferences.
- [ ] Проверить loadout presets.
- [ ] Проверить, что сохранение не теряет новые fields после reconnect.

## 3. Species и внешний вид персонажа

- [ ] Human baseline: создать обычного человека и убедиться, что перенос не сломал базовую модель.
- [ ] Vox / better vox / alt vox / vox sprites: тело, глаза, маски, одежда, species traits, язык.
- [ ] Teshari: тело, одежда, augment-related visuals, язык.
- [ ] Akula: bodyparts, snout, tail, sprite accessories.
- [ ] Skrell: волосы/щупальца, органы, liver resistance, language/species data.
- [ ] Nabber: organs, GAGS fallback, bodyparts, markings.
- [ ] Ramatae: species data, bodyparts, clothing overlays.
- [ ] Shadekin: органы, иконки, traits, spawn/admin-spawn.
- [ ] Synths: robotic organs, synth bodyparts, synthetic clothing overlays.
- [ ] Plant people / pod: pod organs, color swapped layers.
- [ ] Voxes plural/legacy species variants: убедиться, что старые savefile species keys мигрируют или корректно отказываются.
- [ ] Mutants/custom species features: antag datum icons, body overlays, mutant bodyparts.
- [ ] Species synthesizer: создать/использовать, проверить UI и результат.
- [ ] Проверить species с мужским, женским и neutral body type.
- [ ] Проверить species с digitigrade legs.
- [ ] Проверить species с taur body.
- [ ] Проверить species с snout.
- [ ] Проверить species с wings.
- [ ] Проверить species с tail.
- [ ] Проверить species с ears/horns/frills/spines.

## 4. Bodyparts, organs, markings, GAGS

- [ ] Body markings: выбрать несколько наборов, сохранить, зайти в раунд.
- [ ] Markings layering: body front/back, head, arms, legs, under/over clothing.
- [ ] Hair: все перенесенные волосы в preferences отображаются.
- [ ] Facial hair: отображение и сохранение.
- [ ] Snout: preview, in-game overlay, mask compatibility.
- [ ] Tail: preview, wag/animation если есть, clothing compatibility.
- [ ] Wings: preview, worn suit compatibility, functional wings если применимо.
- [ ] Ears/horns/frills/spines: preview, headgear compatibility.
- [ ] Taur body: preview, spawn, clothing, movement, riding/saddle если доступно.
- [ ] Mermaid/fishlike taur transform: action button, transform to legs, transform back, орган не теряется.
- [ ] Serpentine/spider/tentacle/blob/centipede taur variants.
- [ ] Anthro taur variant and saddled taur riding.
- [ ] Digitigrade overlays: uniform, suit, shoes, blood soles.
- [ ] Digitigrade cybernetics.
- [ ] External organs: insertion/removal, losing limb, surgery replacement.
- [ ] Internal organs: liver, custom tongue, synth organs, cybernetic organs.
- [ ] ERP/genital organs: preferences, spawn, organ slots, overlays, save/load.
- [ ] GAGS JSON configs: recolor works, no missing json_config runtime.
- [ ] GAGS fallback configs: missing/custom values fallback correctly.
- [ ] DMI state conflicts: no invisible/magenta/blank sprites on GAGS items.

## 5. Quirks, traits, languages, roleplay systems

- [ ] Echolocation quirk.
- [ ] Limp leg quirk.
- [ ] Hydrophobia quirk.
- [ ] Masquerade quirk.
- [ ] Heavyset quirk.
- [ ] Body temperature quirk.
- [ ] Custom tongue quirk.
- [ ] Skilled quirk.
- [ ] Shapeshifter quirk.
- [ ] Telepathy quirk.
- [ ] Unsteady quirk.
- [ ] Trauma quirks.
- [ ] Unusual biochemistry.
- [ ] Death consequences perk.
- [ ] Visitor/bad touch/big hands/introvert/extrovert/snob/spiritual/apathetic quirks.
- [ ] Venomous bite quirk: action, cooldown, reagent/effect.
- [ ] Pet owner quirk.
- [ ] Pet size behavior.
- [ ] Languages: выбрать, забыть/выучить, понять/говорить.
- [ ] Roleplay `do` verb.
- [ ] Container emotes.
- [ ] Emote panel.
- [ ] Custom emotes.
- [ ] Dchat/runechat behavior.
- [ ] Records on examine.
- [ ] Character directory.

## 6. Jobs, access, roles, departments

- [ ] Alternative job titles отображаются в setup.
- [ ] Alternative job title применяется в manifest/ID/examine.
- [ ] Bridge Assistant.
- [ ] Blueshield.
- [ ] Nanotrasen Representative.
- [ ] Nanotrasen Naval Command roles/content.
- [ ] Telecomms Specialist.
- [ ] Central Command module roles/content.
- [ ] Departmentization changes.
- [ ] Department budgets.
- [ ] Paycheck/economy changes.
- [ ] Paycheck rations.
- [ ] Time clock.
- [ ] Trim tokens.
- [ ] ID/access helpers.
- [ ] Job locker beacon.
- [ ] Protected roles.
- [ ] Whitelist checks.
- [ ] Player rank display/logic.

## 7. Loadouts, clothing, uniforms, storage

- [ ] Loadout UI opens and all categories render.
- [ ] Loadout points/prices are correct.
- [ ] Loadout items equip on spawn.
- [ ] Loadout presets save/load.
- [ ] Tacti-maid loadout.
- [ ] Blastwave outfits.
- [ ] Hop drip.
- [ ] Dog fashion.
- [ ] Holding fashion port.
- [ ] Emergency spacesuit.
- [ ] Envirosuit kits.
- [ ] SEVA suit.
- [ ] Specialist armor.
- [ ] Jaeger MOD.
- [ ] Modsuit overrides.
- [ ] Modsuit pAI.
- [ ] MOD sprite accessories deploy/retract/seal/control activation.
- [ ] Oversized clothing.
- [ ] Snouted clothing overlays.
- [ ] Digitigrade uniform/suit/shoe overlays.
- [ ] Taur clothing overlays.
- [ ] Vox clothing masks/neck/uniforms.
- [ ] Teshari clothing paths.
- [ ] Storage items: backpacks, satchels, boxes, briefcases, belts.
- [ ] More briefcases.
- [ ] Lunch boxes.
- [ ] Wallet/storage contents.
- [ ] Strip menu inventory icons.
- [ ] Chameleon clothing update look/update item.
- [ ] Reskin menus/radials.
- [ ] Inhand icons left/right.
- [ ] Worn icons for every body shape.

## 8. Weapons, combat, sec gear

- [ ] Armaments vendors/content.
- [ ] Ammo stacks.
- [ ] Ammo workbench.
- [ ] Gun safety.
- [ ] Gunpoint behavior.
- [ ] Gun HUD.
- [ ] Sec haul.
- [ ] Security designs.
- [ ] Cellguns.
- [ ] New cells.
- [ ] Energy axe.
- [ ] Stunsword.
- [ ] Ahab's spear.
- [ ] Knives.
- [ ] Mauling melees.
- [ ] Mounted machine gun.
- [ ] Magfed turret: item, deploy, ammo, UI/sprite, inhands.
- [ ] Turret ID behavior.
- [ ] Shotgun rebalance.
- [ ] Buckshot roulette/blank casing behavior if reachable.
- [ ] Modular weapons.
- [ ] Modular laser rifle/carbine modes.
- [ ] Modular laser speech strings.
- [ ] Modular laser soulcatcher UI.
- [ ] Company/faction weapon sprites.
- [ ] Mining crushers.
- [ ] Mining PKA.
- [ ] Mining vendor additions.
- [ ] More traitor items.
- [ ] Traitor uplinks/bundles.
- [ ] Syndie edits.
- [ ] More wizard stuff.
- [ ] Goofsec content if still present.
- [ ] Combat defines: headsmash/suplex/nut shot/wrestling interactions.

## 9. Medical, surgery, cybernetics

- [ ] Deforest medical items.
- [ ] Hyposprays.
- [ ] Lathe medipens.
- [ ] Medical combitool.
- [ ] Medical designs.
- [ ] Modular implants.
- [ ] Roundstart implants.
- [ ] Digitigrade cybernetics.
- [ ] Robot limb detach.
- [ ] Teshari augments.
- [ ] Neuroware chips.
- [ ] Neuroware reagents.
- [ ] NIF/brain slot behavior if used.
- [ ] Resleeving.
- [ ] Stasis rework.
- [ ] System shock.
- [ ] Surgery UI/actions still list new organs.
- [ ] External organ surgery.
- [ ] Internal organ surgery.
- [ ] Synthetic organs.
- [ ] Liver toxin resistance variants.
- [ ] Custom tongue surgery.
- [ ] Wound/scar text still loads.
- [ ] Medical vendors/lathe designs include new items.

## 10. Cargo, economy, vending, budgets

- [ ] Cargo console opens.
- [ ] Supply packs list loads without missing typepaths.
- [ ] Company imports.
- [ ] Private/company cargo categories.
- [ ] Cargo items.
- [ ] Cargo pack prices.
- [ ] Corporate economy.
- [ ] Department budgets UI.
- [ ] Payroll/payday modifiers.
- [ ] Paycheck rations.
- [ ] Command vendor.
- [ ] Imported vendors.
- [ ] Modular vending stock.
- [ ] Plexagon self-serve.
- [ ] Pizza voucher.
- [ ] Vendor prices and access restrictions.
- [ ] Cargo shuttle order/approve/deliver loop.
- [ ] Contraband/emagged vendor states.
- [ ] Economy account creation and transfers.
- [ ] Budget cards/department accounts.

## 11. Research, crafting, science, circuits

- [ ] Research console opens.
- [ ] Techweb nodes from transferred content appear.
- [ ] Research designs unlock correctly.
- [ ] Security designs.
- [ ] Medical designs.
- [ ] Additional circuit components.
- [ ] Cell component.
- [ ] Integrated circuits component menu.
- [ ] Circuit JSON/component assets.
- [ ] Crafting recipes.
- [ ] Primitive structures.
- [ ] Primitive production.
- [ ] Primitive cooking additions.
- [ ] Tribal extended recipes.
- [ ] Science tools.
- [ ] Xenoarch artifacts.
- [ ] Artifact spawn, scan, activate.
- [ ] Anomaly grenades.
- [ ] Reagent forging.
- [ ] Bluespace miner.
- [ ] BSA overhaul.
- [ ] BSRPD.
- [ ] Wargame projectors.

## 12. Chemistry, food, drinks, botany

- [ ] Modular reagents.
- [ ] Fauna reagent.
- [ ] Chemistry love content.
- [ ] Alcohol processing.
- [ ] More ferment plants.
- [ ] More narcotics.
- [ ] Food replicator.
- [ ] Cook console recipes.
- [ ] Supersoups.
- [ ] Food preferences UI.
- [ ] Food preference effects on mood/toxicity if present.
- [ ] New food/drink icons.
- [ ] Vending food/drink stock.
- [ ] Reagent effects and metabolism.
- [ ] Hallucination/string JSON references.
- [ ] Plant analyzer anomaly notice.
- [ ] Plant people interactions.
- [ ] Space vines.
- [ ] Mold/biohazard blob content.

## 13. Engineering, power, machines, atmos

- [ ] Advanced engineering content.
- [ ] Machinery fine tuning.
- [ ] APC arcing.
- [ ] Delamination emergency stop.
- [ ] Supermatter alert UI/storyteller power notice.
- [ ] RBMK2 machine/UI.
- [ ] Powerator machine/UI.
- [ ] Multicell charger.
- [ ] Cell chargers and new cells.
- [ ] Electric welder.
- [ ] Airlocks with transferred icons/access.
- [ ] Lights/aesthetics changes.
- [ ] Polarized windows.
- [ ] Window airbags.
- [ ] Barricades.
- [ ] Inflatables.
- [ ] Trash compactor.
- [ ] Rod-stopper.
- [ ] Pod locking.
- [ ] Hurtsposals/disposal pipes.
- [ ] Liquids machinery.
- [ ] Pollution subsystem/effects.
- [ ] Fireproof spray.
- [ ] Telecomms specialist tools.

## 14. Silicon, AI, borgs, robotics

- [ ] Cyborg model selection.
- [ ] Borg sprites: standard, wide, clown, security, medical, engineering, service.
- [ ] Borg buffs.
- [ ] Silicon QoL features.
- [ ] AI login.
- [ ] Cyborg login.
- [ ] AI/cyborg click behavior.
- [ ] AI uplink upload.
- [ ] Positronic alert console.
- [ ] Borg module selection.
- [ ] Borg HUD icons.
- [ ] AI HUD icons.
- [ ] Robot limb detach.
- [ ] Synth body/organs integration.
- [ ] Modsuit pAI behavior.
- [ ] Silicon laws display.
- [ ] Silicon UI panels.
- [ ] Poly commands.

## 15. TGUI, browser, HTML, asset cache

- [ ] Preferences menu.
- [ ] Character preview.
- [ ] Character directory.
- [ ] Loadout UI.
- [ ] Interaction panel.
- [ ] ERP/custom subtle panel.
- [ ] Food preferences.
- [ ] Orbit job icons.
- [ ] Spawn panel.
- [ ] Spawn search.
- [ ] Strip menu.
- [ ] Uplink.
- [ ] Cargo UI.
- [ ] Ore redemption machine.
- [ ] Processing console.
- [ ] Pandemic.
- [ ] Plant analyzer.
- [ ] Supermatter monitor.
- [ ] RBMK2 UI.
- [ ] Powerator UI.
- [ ] Integrated circuits UI.
- [ ] Autodoc.
- [ ] Emote panel.
- [ ] Escape menu.
- [ ] Lorecaster.
- [ ] Mentor tools UI.
- [ ] Admin tools UI.
- [ ] Title screen HTML.
- [ ] Title buttons.
- [ ] Title font.
- [ ] Title/menu sounds.
- [ ] Asset cache sends icon_ref_map.
- [ ] TGUI DMI references resolve.
- [ ] No blank image placeholders in UI.

## 16. Maps, ruins, shuttles, mapload objects

- [ ] Main station map starts.
- [ ] CentCom map loads.
- [ ] Snowglobe/holiday/special maps if configured.
- [ ] SerenityStation content/areas/ambience.
- [ ] Jungle content.
- [ ] Icemoon additions.
- [ ] Charlie/DS2 fluff areas.
- [ ] Away missions.
- [ ] Random ruins.
- [ ] Ghost cafe.
- [ ] Ghost mining.
- [ ] Drones derelict.
- [ ] Underworld connections.
- [ ] Faction shuttles.
- [ ] Advanced shuttles.
- [ ] Prison transport.
- [ ] SolFed/marine/marauder shuttle content.
- [ ] Ancient/milsim-style ruins if present.
- [ ] Colony fabricator map objects.
- [ ] Condos.
- [ ] Office stuff.
- [ ] Salon.
- [ ] Wrestling ring.
- [ ] Barsigns.
- [ ] Posters/stamps/paper visuals.
- [ ] Turf icons: walls, floors, windows, planet turfs.
- [ ] Map-placed custom icons.
- [ ] Map-placed custom sounds.
- [ ] Automapper behavior.
- [ ] Lazy templates.
- [ ] Station traits.
- [ ] Rock/planet configs.
- [ ] Random ship event ship names.

## 17. Antagonists, events, ghost roles

- [ ] Antag opt-in UI and assignment.
- [ ] Traitor uplink additions.
- [ ] Ashwalkers.
- [ ] Clock cult.
- [ ] Contractor.
- [ ] Cortical borer.
- [ ] Deathmatch.
- [ ] Marauders.
- [ ] Opposing force.
- [ ] Xenoarch artifacts as event/content.
- [ ] Primitive catgirls/hearthkin content if reachable.
- [ ] Hydra.
- [ ] Spider content.
- [ ] New legion types.
- [ ] More gold slime monsters.
- [ ] Mold/biohazard blob.
- [ ] Horrorform.
- [ ] Underworld connections.
- [ ] Event awards.
- [ ] Event props.
- [ ] Ices events.
- [ ] Random ship event.
- [ ] Alerts.
- [ ] Admin-triggered events.
- [ ] Ghost role spawn, outfit, equipment, objectives.
- [ ] Antag HUD icons.
- [ ] Antag objective generation.
- [ ] Antag memories/flavor.

## 18. Admin, mentor, moderation, server ops

- [ ] Admin verbs category opens.
- [ ] Admin spawn transferred objects.
- [ ] Admin smites.
- [ ] Bluespace admin tools.
- [ ] Extra VV.
- [ ] Preference import verb.
- [ ] Banning changes.
- [ ] Panic bunker.
- [ ] Mentor tools.
- [ ] Mentoring UI.
- [ ] Event award tools.
- [ ] Autotransfer.
- [ ] Player ranks.
- [ ] Protected role admin checks.
- [ ] Logs show transferred actions with correct categories.
- [ ] No broken icons in admin spawn list.

## 19. Audio, ambience, alerts, emotes

- [ ] Title music.
- [ ] Menu click sounds.
- [ ] Alerts sounds.
- [ ] Radio sounds.
- [ ] Ambience tracks.
- [ ] Serenity/mushroom/forest ambience if relevant.
- [ ] Emote sounds.
- [ ] Container emote sounds.
- [ ] Blooper sounds.
- [ ] Vox/voice/TTS related playback.
- [ ] Weapon sounds.
- [ ] Machine sounds.
- [ ] Colony fabricator sounds.
- [ ] Kahraman equipment sounds.
- [ ] Manual door/thumper/furnace sounds.
- [ ] No `file not found` sound runtimes.

## 20. Visual assets, DMI states, inhands

- [ ] Human worn icons unchanged.
- [ ] Vox worn icons.
- [ ] Teshari worn icons.
- [ ] Digitigrade worn icons.
- [ ] Taur worn icons.
- [ ] Snouted masks.
- [ ] Suit storage overlays.
- [ ] Belt/back/neck/mask/gloves/shoes overlays.
- [ ] Left inhand icons.
- [ ] Right inhand icons.
- [ ] Object icons.
- [ ] 32x32, 64x64, wide and large mob icons.
- [ ] HUD icons.
- [ ] Antag HUD icons.
- [ ] Job icons.
- [ ] Borg icons.
- [ ] AI icons.
- [ ] Projectile/beam/effect icons.
- [ ] Turf icons.
- [ ] Wall/floor/window icons.
- [ ] Paper/stamp/cache assets.
- [ ] Any `_additions` DMI files: compare intended states with core target.
- [ ] No missing icon_state runtimes.
- [ ] No invisible equipped items.
- [ ] No wrong-direction inhands.

## 21. Persistence, records, save data

- [ ] Preferences save/load.
- [ ] Character records.
- [ ] Records on examine.
- [ ] Character directory records.
- [ ] Photocopier module.
- [ ] Paperwork filing cabinet.
- [ ] Employment contract.
- [ ] Modular persistence data.
- [ ] NPC saves: Runtime, Poly, Punpun if touched.
- [ ] Cached TTS voices.
- [ ] Paintings/photos temp files.
- [ ] Bunker passthrough data.
- [ ] Future station traits data.
- [ ] Engravings/tattoos data.

## 22. Admin-spawn matrix

Для каждой перенесенной feature-зоны сделать минимум такой smoke test:

- [ ] Spawn object.
- [ ] Examine object.
- [ ] Pick up/drop.
- [ ] Equip if wearable.
- [ ] Use in hand.
- [ ] Alt-click/Ctrl-click/Shift-click если есть.
- [ ] Attack self если есть.
- [ ] Attack target если weapon/tool.
- [ ] Put in storage.
- [ ] Delete/qdel.
- [ ] Mapload equivalent если объект обычно стоит на карте.
- [ ] Проверить icon, worn_icon, lefthand/righthand icon.
- [ ] Проверить sounds.
- [ ] Проверить UI если объект открывает TGUI/browser.
- [ ] Проверить отсутствие runtime после delete.

## 23. Минимальное покрытие по бывшим feature-зонам

Эти зоны должны получить хотя бы smoke-проверку или осознанный skip с причиной:

- [ ] access helpers, admin, banning, panicbunker, protected roles, whitelist, player ranks.
- [ ] advanced engineering, APC arcing, delam emergency stop, powerator, RBMK2, BSA overhaul, BSRPD, multicell charger.
- [ ] advanced shuttles, automapper, mapping, lazy templates, random ruins, away missions, faction shuttles.
- [ ] aesthetics, alerts, huds, indicators, layer shift, item visuals, title/tagline/menu visuals.
- [ ] akula, better vox, alt vox, vox sprites, voxes, teshari, ramatae, shadekin, synths, mutants, plant people.
- [ ] customization, bodyparts, organs, taur mechanics, digitigrade cybernetics, digi bloodsole.
- [ ] GAGS, greyscale JSON, loadouts, alternate job titles, character preview background, character directory.
- [ ] blooper, voice actor quirk, emotes, emote panel, container emotes, radiosound, dchat/runechat.
- [ ] quirks: echolocation, limp leg, hydrophobia, masquerade, heavyset, bodytemp, custom tongue, skilled, shapeshifter, telepathy, trauma, unusual biochemistry.
- [ ] armaments, ammo stacks, ammo workbench, cellguns, gun safety, gunpoint, gunhud, magfed turret, mounted machine gun.
- [ ] energy axe, stunsword, knives, sec haul, security designs, shotgun rebalance, modular weapons, traitor uplinks.
- [ ] cargo, cargo items, company imports, command vendor, corporate economy, department budgets, economy, imported vendors, modular vending.
- [ ] chemistry love, alcohol processing, modular reagents, reagent forging, fauna reagent, more ferment plants, more narcotics.
- [ ] cook console recipes, food replicator, supersoups, primitive cooking, primitive production, primitive structures.
- [ ] medical, Deforest medical items, hyposprays, lathe medipens, medical combitool, medical designs, implants, modular implants, neuroware, resleeving, stasis rework.
- [ ] borgs, borg buffs, Silicon QoL, AI uplink upload, positronic alert console, robot limb detach, modsuit pAI.
- [ ] ashwalkers, clock cult, contractor, cortical borer, deathmatch, marauders, opposing force, xenoarch, xenoarch artifacts.
- [ ] event awards, event props, events, ices events, random ship event, station traits.
- [ ] colony fabricator, condos, cryosleep, ghost cafe, ghost mining, drones, drones derelict, underworld connections.
- [ ] fishing, ghost mining, mining crushers, mining PKA, mining vendor additions, bluespace miner.
- [ ] barsigns, dog fashion, blastwave outfits, emergency spacesuit, envirosuit kits, SEVA suit, specialist armor, tacti-maid loadout, hop drip.
- [ ] photocopier module, paperwork/contracts, lorecaster, records on examine, roleplay do, verbs.
- [ ] liquids, pollution, mold, space vines, spider, hydra, new legion types, more gold slime monsters.
- [ ] salon, shelves, office stuff, wrestling ring, medieval crate, primitive/tribal content.
- [ ] solfed mechs, marines, nanotrasen naval command, Nanotrasen representative, blueshield, bridge assistant, telecomms specialist.

## 24. Симптомы, которые считаются провалом проверки

- [ ] Runtime `cannot read file`.
- [ ] Runtime `json_decode`/missing JSON.
- [ ] Runtime missing `icon`/`icon_state`.
- [ ] Blank или magenta sprite.
- [ ] Невидимая одежда на одном из body shapes.
- [ ] Предмет есть в loadout/vendor/cargo, но не спавнится.
- [ ] Предмет спавнится, но не имеет inhand/worn icon.
- [ ] UI открывается пустым.
- [ ] UI открывается, но картинки не грузятся.
- [ ] Preferences option сохраняется, но не применяется.
- [ ] Preferences option применяется, но теряется после reconnect.
- [ ] Species создается, но ломает bodyparts/organs.
- [ ] Карта грузится, но map-placed объект заменен на missing type.
- [ ] Cargo pack виден, но заказ ломается.
- [ ] Research design виден, но lathe не печатает.
- [ ] Reagent существует, но effect/metabolize runtime.
- [ ] Antag назначается, но нет objectives/HUD/uplink.
- [ ] Cyborg/AI появляется, но sprite/HUD/module broken.
- [ ] Startup проходит, но первый игрок вызывает crash.
- [ ] Restart round вызывает повторяющийся runtime от static caches.

## 25. Что фиксить первым, если что-то сломано

- [ ] Старый resource path в DM/DMM/TGUI/JSON/config.
- [ ] DMI state был в collision file и не попал в нужный target.
- [ ] JSON перенесен в core, но строковый ключ все еще смотрит в старую директорию.
- [ ] `.dm` файл перенесен, но порядок include изменил область видимости `#define`.
- [ ] Override-файл теперь компилируется раньше parent definition.
- [ ] `#undef` теперь срабатывает раньше позднего потребителя define.
- [ ] Asset существует, но путь отличается по `sound/` vs `sounds/`, `icons/` nesting или имени feature-dir.
- [ ] Map file содержит старый path literal.
- [ ] TGUI source обновлен, но generated public bundle старый.
- [ ] Runtime registry/cache строится до перенесенного subtype.
