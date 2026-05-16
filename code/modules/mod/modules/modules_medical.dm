//Medical modules for MODsuits

#define HEALTH_SCAN "Health"
#define WOUND_SCAN "Wound"
#define CHEM_SCAN "Chemical"

///Health Analyzer - Gives the user a ranged health analyzer and their health status in the panel.
/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module installed into the glove of the suit. This is a high-tech biological scanning suite, \
		allowing the user indepth information on the vitals and injuries of others even at a distance, \
		all with the flick of the wrist. Data is displayed in a convenient package, but it's up to you to do something with it."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	tgui_id = "health_analyzer"
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Scanning mode, changes how we scan something.
	var/mode = HEALTH_SCAN

	/// List of all scanning modes.
	var/static/list/modes = list(HEALTH_SCAN, WOUND_SCAN, CHEM_SCAN)

/obj/item/mod/module/health_analyzer/add_ui_data()
	. = ..()
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_brute"] = mod.wearer?.get_brute_loss() || 0
	.["loss_fire"] = mod.wearer?.get_fire_loss() || 0
	.["loss_tox"] = mod.wearer?.get_tox_loss() || 0
	.["loss_oxy"] = mod.wearer?.get_oxy_loss() || 0

	return .

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target) || !mod.wearer.can_read(src))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		if(WOUND_SCAN)
			woundscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_energy_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Scan Mode", "list", mode, modes)

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
#undef WOUND_SCAN
#undef CHEM_SCAN

///Quick Carry - Lets the user carry bodies quicker.
/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "A suite of advanced servos, redirecting power from the suit's arms to help carry the wounded; \
		or simply for fun. However, Nanotrasen has locked the module's ability to assist in hand-to-hand combat."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry, /obj/item/mod/module/constructor)
	required_slots = list(ITEM_SLOT_GLOVES)
	var/quick_carry_trait = TRAIT_QUICK_CARRY

/obj/item/mod/module/quick_carry/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_FASTMED, REF(src))
	ADD_TRAIT(mod.wearer, quick_carry_trait, REF(src))

/obj/item/mod/module/quick_carry/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_FASTMED, REF(src))
	REMOVE_TRAIT(mod.wearer, quick_carry_trait, REF(src))

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0
	quick_carry_trait = TRAIT_QUICKER_CARRY

///Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "A self-contained chem-archiving platform installed into the wrist of the suit. \
		Once it has sampled enough of a reagent, it can synthesize fresh doses from the MOD's power reserves, \
		store custom emergency cocktails, and inject through any armor in moments."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/hypospray/mod/injector
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Suit charge consumed for every synthesized unit.
	var/synthesis_charge_cost = DEFAULT_CHARGE_DRAIN * 0.75

/obj/item/mod/module/injector/Initialize(mapload)
	. = ..()
	if(istype(device, /obj/item/reagent_containers/hypospray/mod/injector))
		var/obj/item/reagent_containers/hypospray/mod/injector/injector_device = device
		injector_device.link_module(src)

/obj/item/mod/module/injector/has_required_parts(list/parts, need_active = FALSE)
	// The injector is wrist-mounted and should stay usable on an active MOD even if the suit parts are folded.
	return ..(parts, need_active = FALSE)

/obj/item/reagent_containers/hypospray/mod/injector
	name = "MOD injector syringe"
	desc = "A combat-grade adaptive injector with a built-in synthesis archive. \
		It can memorize sampled reagents, mix reserve cocktails, and punch through any armor or sealed MOD with contemptuous ease."
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	inhand_icon_state = "combat_hypo"
	worn_icon_state = "hypo"
	icon_state = "injector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 5
	volume = 100
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 40, 50)
	resistance_flags = ACID_PROOF
	initial_reagent_flags = OPENCONTAINER | NO_SPLASH
	ignore_flags = TRUE
	/// Parent module that powers synthesis and owns this injector.
	var/obj/item/mod/module/injector/linked_module
	/// Reagent path currently highlighted in the injector UI.
	var/selected_reagent
	/// Default amount synthesized with a single button press.
	var/synthesis_amount = 10
	/// If TRUE, synthesize the missing units for the current dose on demand.
	var/auto_refill = TRUE
	/// Reagent archive sample size needed to learn a new reagent.
	var/sample_volume = 50
	/// Cached reagent archive.
	var/list/known_reagents = list()
	/// Hard cap for archived reagents available to synthesize.
	var/max_known_reagents = 12
	/// Saved cocktail blueprints keyed by profile name.
	var/list/saved_profiles = list()
	/// Hard cap for stored cocktail profiles.
	var/max_saved_profiles = 6

/obj/item/reagent_containers/hypospray/mod/injector/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/mod/module/injector))
		link_module(loc)

/obj/item/reagent_containers/hypospray/mod/injector/examine(mob/user)
	. = ..()
	. += span_notice("Use in hand to open the injector console, archive reagents, and manage dose profiles.")
	. += span_notice("Any reagent is archived automatically once the injector itself contains [sample_volume] units of it.")
	if(selected_reagent)
		var/datum/reagent/selected_reagent_datum = GLOB.chemical_reagents_list[selected_reagent]
		if(selected_reagent_datum)
			. += span_notice("Selected synthesis target: [selected_reagent_datum.name].")
	. += span_notice("Current dose: [amount_per_transfer_from_this]u. Auto-refill: [auto_refill ? "enabled" : "disabled"].")

/obj/item/reagent_containers/hypospray/mod/injector/proc/link_module(obj/item/mod/module/injector/module)
	linked_module = module

/obj/item/reagent_containers/hypospray/mod/injector/proc/archive_reagent(reagent_type, mob/user, silent = FALSE)
	if(!reagent_type || known_reagents[reagent_type])
		return FALSE
	if(length(known_reagents) >= max_known_reagents)
		if(user && !silent)
			balloon_alert(user, "archive full")
		return FALSE
	known_reagents[reagent_type] = TRUE
	if(!selected_reagent)
		selected_reagent = reagent_type
	if(!silent)
		var/datum/reagent/reagent_datum = GLOB.chemical_reagents_list[reagent_type]
		balloon_alert(user, "archived [reagent_datum?.name || "sample"]")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/proc/auto_archive_contents(mob/user, silent = FALSE)
	var/archived_any = FALSE
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		if(reagent.volume < sample_volume)
			continue
		archived_any = archive_reagent(reagent.type, user, silent) || archived_any
	return archived_any

/obj/item/reagent_containers/hypospray/mod/injector/on_reagent_change(datum/reagents/holder, ...)
	auto_archive_contents(null, TRUE)
	return ..()

/obj/item/reagent_containers/hypospray/mod/injector/attack_self(mob/user)
	if(user.can_perform_action(src, FORBID_TELEKINESIS_REACH|ALLOW_RESTING))
		ui_interact(user)
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!attacking_item?.reagents || !attacking_item.is_drainable())
		return ..()
	var/obj/item/reagent_containers/source_container = attacking_item
	if(reagents.holder_full())
		balloon_alert(user, "reservoir full")
		return TRUE
	var/list/sample_choices = list()
	for(var/datum/reagent/reagent as anything in attacking_item.reagents.reagent_list)
		sample_choices["[reagent.name] ([round(reagent.volume, CHEMICAL_VOLUME_ROUNDING)]u)"] = reagent.type
	if(!length(sample_choices))
		return ..()
	var/chosen_label
	if(length(sample_choices) == 1)
		for(var/sample_label in sample_choices)
			chosen_label = sample_label
			break
	else
		chosen_label = tgui_input_list(user, "Select a reagent to load into the injector.", "MOD Injector", sample_choices)
	if(!chosen_label)
		return TRUE
	var/reagent_type = sample_choices[chosen_label]
	if(!reagent_type)
		return TRUE
	var/free_volume = reagents.maximum_volume - reagents.total_volume
	if(free_volume <= 0)
		balloon_alert(user, "reservoir full")
		return TRUE
	var/was_known = !!known_reagents[reagent_type]
	var/current_amount = reagents.get_reagent_amount(reagent_type)
	var/transfer_amount = source_container.amount_per_transfer_from_this
	if(!known_reagents[reagent_type] && current_amount < sample_volume)
		transfer_amount = max(transfer_amount, sample_volume - current_amount)
	transfer_amount = min(
		transfer_amount,
		source_container.reagents.get_reagent_amount(reagent_type),
		free_volume,
	)
	transfer_amount = round(transfer_amount, CHEMICAL_VOLUME_ROUNDING)
	if(transfer_amount <= 0)
		balloon_alert(user, "sample transfer failed")
		return TRUE
	var/datum/reagent/reagent_datum = GLOB.chemical_reagents_list[reagent_type]
	var/transferred = round(
		source_container.reagents.trans_to(
			src,
			transfer_amount,
			transferred_by = user,
			target_id = reagent_type,
			no_react = TRUE,
		),
		CHEMICAL_VOLUME_ROUNDING,
	)
	if(!transferred)
		balloon_alert(user, "sample transfer failed")
		return TRUE
	to_chat(user, span_notice("You load [transferred] unit\s of [reagent_datum?.name || "reagents"] into [src]."))
	var/reagent_meets_archive_threshold = reagents.get_reagent_amount(reagent_type) >= sample_volume
	if(!was_known && known_reagents[reagent_type])
		balloon_alert(user, "archived [reagent_datum?.name || "sample"]")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	else if(!was_known && reagent_meets_archive_threshold && length(known_reagents) >= max_known_reagents)
		balloon_alert(user, "archive full")
	else if(!known_reagents[reagent_type])
		var/current_sample = round(reagents.get_reagent_amount(reagent_type), CHEMICAL_VOLUME_ROUNDING)
		balloon_alert(user, "sample [current_sample]/[sample_volume]u")
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/proc/get_mod_charge()
	return linked_module?.mod?.get_charge() || 0

/obj/item/reagent_containers/hypospray/mod/injector/proc/get_mod_max_charge()
	return linked_module?.mod?.get_max_charge() || 0

/obj/item/reagent_containers/hypospray/mod/injector/proc/get_synthesis_cost_per_unit()
	return linked_module?.synthesis_charge_cost || 0

/obj/item/reagent_containers/hypospray/mod/injector/proc/synthesize_reagent(reagent_type, amount, mob/user, silent = FALSE)
	if(!reagent_type || !known_reagents[reagent_type] || amount <= 0)
		return 0
	if(!linked_module?.mod)
		if(user && !silent)
			balloon_alert(user, "no MOD link")
		return 0
	var/free_volume = max(0, reagents.maximum_volume - reagents.total_volume)
	if(free_volume <= 0)
		if(user && !silent)
			balloon_alert(user, "reservoir full")
		return 0
	var/to_create = min(amount, free_volume)
	var/synthesis_cost = get_synthesis_cost_per_unit()
	if(synthesis_cost <= 0)
		return 0
	var/max_affordable = floor(get_mod_charge() / synthesis_cost)
	to_create = min(to_create, max_affordable)
	if(to_create <= 0)
		if(user && !silent)
			balloon_alert(user, "not enough charge")
		return 0
	if(!linked_module.drain_power(to_create * synthesis_cost))
		if(user && !silent)
			balloon_alert(user, "not enough charge")
		return 0
	reagents.add_reagent(reagent_type, to_create, added_purity = 1, no_react = TRUE)
	update_appearance()
	return to_create

/obj/item/reagent_containers/hypospray/mod/injector/proc/ensure_payload(mob/user)
	if(reagents.total_volume >= amount_per_transfer_from_this)
		return TRUE
	if(!auto_refill || !selected_reagent)
		return FALSE
	var/missing_amount = amount_per_transfer_from_this - reagents.total_volume
	synthesize_reagent(selected_reagent, missing_amount, user, silent = TRUE)
	return reagents.total_volume >= amount_per_transfer_from_this

/obj/item/reagent_containers/hypospray/mod/injector/inject(mob/living/affected_mob, mob/user)
	if(used_up)
		to_chat(user, span_warning("[src] tip is broken and is now unusable!"))
		return FALSE
	if(!isliving(affected_mob) || !affected_mob.reagents)
		return FALSE
	if(!ensure_payload(user) && (!reagents || reagents.total_volume <= 0))
		to_chat(user, span_warning("[src] reservoir is empty!"))
		return FALSE
	if(!reagents || reagents.total_volume <= 0)
		to_chat(user, span_warning("[src] reservoir is empty!"))
		return FALSE
	var/transfer_amount = min(amount_per_transfer_from_this, reagents.total_volume)
	if(transfer_amount <= 0)
		return FALSE
	var/contained = reagents.get_reagent_log_string()
	log_combat(user, affected_mob, "attempted to inject", src, "([contained])")
	to_chat(affected_mob, span_warning("You feel a sharp puncture!"))
	if(affected_mob == user)
		to_chat(user, span_notice("You inject yourself with [src]."))
	else
		affected_mob.visible_message(
			span_danger("[user] punctures [affected_mob] with [src]!"),
			span_userdanger("[user] punctures you with [src]!"),
		)
		to_chat(user, span_notice("You inject [affected_mob] with [src]."))
	playsound(affected_mob, 'sound/items/hypospray.ogg', 50, TRUE)
	var/transferred = reagents.trans_to(affected_mob, transfer_amount, transferred_by = user, methods = INJECT)
	if(transferred)
		to_chat(user, span_notice("[transferred] unit\s injected. [round(reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)] unit\s remain in [src]."))
		log_combat(user, affected_mob, "injected", src, "([contained])")
		update_appearance()
		return TRUE
	return FALSE

/obj/item/reagent_containers/hypospray/mod/injector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODInjector", name)
		ui.open()

/obj/item/reagent_containers/hypospray/mod/injector/ui_data(mob/user)
	. = list()
	.["currentVolume"] = round(reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
	.["maxVolume"] = reagents.maximum_volume
	.["dose"] = amount_per_transfer_from_this
	.["synthesisAmount"] = synthesis_amount
	.["autoRefill"] = auto_refill
	.["sampleVolume"] = sample_volume
	.["knownReagentCount"] = length(known_reagents)
	.["maxKnownReagents"] = max_known_reagents
	.["power"] = get_mod_charge()
	.["maxPower"] = get_mod_max_charge()
	.["synthesisCostPerUnit"] = get_synthesis_cost_per_unit()
	.["selectedReagent"] = selected_reagent ? "[selected_reagent]" : null
	var/list/known_reagent_data = list()
	for(var/reagent_type in known_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
		if(!reagent)
			continue
		known_reagent_data += list(list(
			"id" = "[reagent_type]",
			"name" = reagent.name,
			"description" = reagent.description,
			"color" = reagent.color,
			"selected" = reagent_type == selected_reagent,
		))
	.["knownReagents"] = known_reagent_data
	var/list/reservoir_contents = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reservoir_contents += list(list(
			"id" = "[reagent.type]",
			"name" = reagent.name,
			"volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING),
			"color" = reagent.color,
		))
	.["reservoirContents"] = reservoir_contents
	var/list/profile_data = list()
	for(var/profile_name in saved_profiles)
		var/list/profile = saved_profiles[profile_name]
		var/list/profile_lines = list()
		for(var/reagent_type in profile)
			var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
			if(!reagent)
				continue
			profile_lines += "[reagent.name] [round(profile[reagent_type], CHEMICAL_VOLUME_ROUNDING)]u"
		profile_data += list(list(
			"name" = profile_name,
			"summary" = english_list(profile_lines, and_text = ", "),
		))
	.["profiles"] = profile_data

/obj/item/reagent_containers/hypospray/mod/injector/proc/save_current_profile(mob/user)
	if(!reagents?.total_volume)
		balloon_alert(user, "reservoir empty")
		return FALSE
	var/suggested_name
	if(selected_reagent)
		var/datum/reagent/selected_reagent_datum = GLOB.chemical_reagents_list[selected_reagent]
		suggested_name = selected_reagent_datum?.name
	var/profile_name = trim(tgui_input_text(user, "Name this injector profile.", "MOD Injector Profile", suggested_name, max_length = 32))
	if(!profile_name)
		return FALSE
	if(length(saved_profiles) >= max_saved_profiles && !saved_profiles[profile_name])
		balloon_alert(user, "profile bank full")
		return FALSE
	var/list/profile = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		profile[reagent.type] = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING)
	saved_profiles[profile_name] = profile
	balloon_alert(user, "profile saved")
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/proc/load_profile(profile_name, mob/user)
	var/list/profile = saved_profiles[profile_name]
	if(!profile)
		return FALSE
	reagents.clear_reagents()
	update_appearance()
	var/fully_loaded = TRUE
	var/first_reagent
	for(var/reagent_type in profile)
		first_reagent ||= reagent_type
		var/desired_amount = profile[reagent_type]
		var/synthesized_amount = synthesize_reagent(reagent_type, desired_amount, user, silent = TRUE)
		if(synthesized_amount < desired_amount)
			fully_loaded = FALSE
	selected_reagent = first_reagent
	if(fully_loaded)
		balloon_alert(user, "profile synthesized")
	else
		balloon_alert(user, "profile partially synthesized")
	update_appearance()
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/proc/delete_profile(profile_name, mob/user)
	if(!saved_profiles[profile_name])
		return FALSE
	saved_profiles -= profile_name
	balloon_alert(user, "profile deleted")
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/proc/delete_known_reagent(reagent_type, mob/user)
	if(!known_reagents[reagent_type])
		return FALSE
	known_reagents -= reagent_type
	var/datum/reagent/reagent = reagents.has_reagent(reagent_type)
	if(reagent)
		reagents.remove_reagent(reagent_type, reagent.volume)
	if(selected_reagent == reagent_type)
		selected_reagent = null
		for(var/next_reagent in known_reagents)
			selected_reagent = next_reagent
			break
	update_appearance()
	balloon_alert(user, "reagent deleted")
	return TRUE

/obj/item/reagent_containers/hypospray/mod/injector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_dose")
			var/new_dose = clamp(round(text2num(params["value"])), 1, 50)
			if(!new_dose)
				return
			amount_per_transfer_from_this = new_dose
			return TRUE
		if("set_synthesis_amount")
			var/new_amount = clamp(round(text2num(params["value"])), 1, 50)
			if(!new_amount)
				return
			synthesis_amount = new_amount
			return TRUE
		if("toggle_auto_refill")
			auto_refill = !auto_refill
			return TRUE
		if("select_reagent")
			var/reagent_type = text2path(params["id"])
			if(!reagent_type || !known_reagents[reagent_type])
				return
			selected_reagent = reagent_type
			return TRUE
		if("delete_known_reagent")
			var/reagent_type = text2path(params["id"])
			if(!reagent_type)
				return
			return delete_known_reagent(reagent_type, ui.user)
		if("synthesize")
			var/reagent_type = text2path(params["id"])
			if(!reagent_type)
				return
			var/requested_amount = round(text2num(params["amount"]))
			if(!requested_amount)
				requested_amount = synthesis_amount
			requested_amount = clamp(requested_amount, 1, 50)
			synthesize_reagent(reagent_type, requested_amount, ui.user)
			return TRUE
		if("prime_selected")
			if(!selected_reagent)
				balloon_alert(ui.user, "no reagent selected")
				return
			reagents.clear_reagents()
			update_appearance()
			synthesize_reagent(selected_reagent, reagents.maximum_volume, ui.user)
			return TRUE
		if("flush")
			reagents.clear_reagents()
			update_appearance()
			balloon_alert(ui.user, "reservoir flushed")
			return TRUE
		if("purge_reagent")
			var/reagent_type = text2path(params["id"])
			if(!reagent_type)
				return
			var/datum/reagent/reagent = reagents.has_reagent(reagent_type)
			if(!reagent)
				return
			reagents.remove_reagent(reagent_type, reagent.volume)
			update_appearance()
			return TRUE
		if("self_inject")
			if(loc != ui.user)
				balloon_alert(ui.user, "hold injector")
				return
			return inject(ui.user, ui.user)
		if("save_profile")
			return save_current_profile(ui.user)
		if("load_profile")
			return load_profile(params["name"], ui.user)
		if("delete_profile")
			return delete_profile(params["name"], ui.user)

///Organizer - Lets you shoot organs, immediately replacing them if the target has the organ manipulation surgery.
/obj/item/mod/module/organizer
	name = "MOD organizer module"
	desc = "A device recovered from a crashed Interdyne Pharmaceuticals vessel, \
		this module has been unearthed for better or for worse. \
		It's an arm-mounted device utilizing technology similar to modern rapid part exchange devices, \
		capable of instantly replacing up to 5 organs at once in surgery without the need to remove them first, even from range. \
		It's recommended by the DeForest Medical Corporation to not inform patients it has been used."
	icon_state = "organizer"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organizer, /obj/item/mod/module/microwave_beam)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// How many organs the module can hold.
	var/max_organs = 5
	/// A list of all our organs.
	var/organ_list = list()

/obj/item/mod/module/organizer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(isorgan(target))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "too many organs!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "picked up [organ]")
		playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_energy_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/projectile/organ/projectile = new /obj/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.aim_projectile(target, mod.wearer)
	projectile.firer = mod.wearer
	playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/projectile/organ
	name = "organ"
	damage = 0
	hitsound = 'sound/effects/blob/attackblob.ogg'
	hitsound_wall = 'sound/effects/blob/attackblob.ogg'
	/// A reference to the organ we "are".
	var/obj/item/organ/organ

/obj/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ

/obj/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/projectile/organ/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == organ)
		organ = null

/obj/projectile/organ/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target) || (organ.organ_flags & ORGAN_UNUSABLE))
		organ.forceMove(drop_location())
		return
	var/mob/living/organ_receiver = target
	// bodyparts actually *do* hit a specific bodypart, but random variance would make this projectile unusable
	// so we just fake it, and assume the organ always hits the place it needs to go
	var/obj/item/bodypart/fake_hit_part = organ_receiver.get_bodypart(length(organ.valid_zones) ? pick(organ.valid_zones) : deprecise_zone(organ.zone))
	if(!LIMB_HAS_SURGERY_STATE(fake_hit_part, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED))
		organ.forceMove(drop_location())
		return

	// handles swapping any existing organ out for us
	organ.Insert(target)

///Patrient Transport - Generates hardlight bags you can put people in.
/obj/item/mod/module/criminalcapture/patienttransport
	name = "MOD patient transport module"
	desc = "A module built into the forearm of the suit. Countless waves of mostly-lost mining teams being sent to \
		Indecipheries and other hazardous locations have taught the DeForest Medical Company many lessons. \
		Physical bodybags are difficult to store, hard to deploy, and even worse to keep intact in tough scenarios. \
		Enter the hardlight transport bag. Summonable with merely a gesture, weightless, and immunized against \
		any extreme scenario the wearer could think of, this bag is perfectly designed for \
		transport of any body in any environment, any time."
	icon_state = "patient_transport"
	bodybag_type = /obj/structure/closet/body_bag/environmental/hardlight
	capture_time = 1.5 SECONDS
	packup_time = 0.5 SECONDS

///Defibrillator - Gives the suit an extendable pair of shock paddles.
/obj/item/mod/module/defibrillator
	name = "MOD defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. Don't you even think about using it as a weapon; \
		regulations on manufacture and software locks expressly forbid it."
	icon_state = "defibrillator"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 25
	device = /obj/item/shockpaddles/mod
	overlay_state_inactive = "module_defibrillator"
	overlay_state_active = "module_defibrillator_active"
	incompatible_modules = list(/obj/item/mod/module/defibrillator)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	var/defib_cooldown = 5 SECONDS

/obj/item/mod/module/defibrillator/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_DEFIBRILLATOR_SUCCESS, PROC_REF(on_defib_success))

/obj/item/mod/module/defibrillator/proc/on_defib_success(obj/item/shockpaddles/source)
	drain_power(use_energy_cost)
	source.recharge(defib_cooldown)
	return COMPONENT_DEFIB_STOP

/obj/item/shockpaddles/mod
	name = "MOD defibrillator gauntlets"
	req_defib = FALSE
	icon_state = "defibgauntlets0"
	inhand_icon_state = "defibgauntlets0"
	base_icon_state = "defibgauntlets"

/obj/item/mod/module/defibrillator/combat
	name = "MOD combat defibrillator module"
	desc = "A module built into the gauntlets of the suit; commonly known as the 'Healing Hands' by medical professionals. \
		The user places their palms above the patient. Onboard computers in the suit calculate the necessary voltage, \
		and a modded targeting computer determines the best position for the user to push. \
		Twenty five pounds of force are applied to the patient's skin. Shocks travel from the suit's gloves \
		and counter-shock the heart, and the wearer returns to Medical a hero. \
		Interdyne Pharmaceutics marketed the domestic version of the Healing Hands as foolproof and unusable as a weapon. \
		But when it came time to provide their operatives with usable medical equipment, they didn't hesitate to remove \
		those in-built safeties. Operatives in the field can benefit from what they dub as 'Stun Gloves', able to apply shocks \
		straight to a victims heart to disable them, or maybe even outright stop their heart with enough power."
	complexity = 1
	module_type = MODULE_ACTIVE
	overlay_state_inactive = "module_defibrillator_combat"
	overlay_state_active = "module_defibrillator_combat_active"
	device = /obj/item/shockpaddles/syndicate/mod
	defib_cooldown = 2.5 SECONDS

/obj/item/shockpaddles/syndicate/mod
	name = "MOD combat defibrillator gauntlets"
	req_defib = FALSE
	icon_state = "syndiegauntlets0"
	inhand_icon_state = "syndiegauntlets0"
	base_icon_state = "syndiegauntlets"

///Thread Ripper - Temporarily rips apart clothing to make it not cover the body.
/obj/item/mod/module/thread_ripper
	name = "MOD thread ripper module"
	desc = "A custom-built module integrated with the suit's wrist. The thread ripper is built from \
		recent technology dating back to the start of 2562, after an attempt by a well-known Nanotrasen researcher to \
		expand on the rapid-tailoring technology found in Autodrobes. Rather than being capable of creating \
		any fabric pattern under the suns, the thread ripper is capable of rapid disassembly of them. \
		Anything from kevlar-weave, to leather, to durathread can be quickly pulled open to the wearer's specification \
		and sewn back together, a development commonly utilized by Medical workers to obtain easy access for \
		surgery, defibrillation, or injection of chemicals to ease patients into not worrying about their \
		brand-name fashion being marred."
	icon_state = "thread_ripper"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/thread_ripper)
	cooldown_time = 1.5 SECONDS
	overlay_state_inactive = "module_threadripper"
	required_slots = list(ITEM_SLOT_GLOVES)
	/// An associated list of ripped clothing and the body part covering slots they covered before
	var/list/ripped_clothing = list()

/obj/item/mod/module/thread_ripper/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target) || !iscarbon(target) || target == mod.wearer)
		balloon_alert(mod.wearer, "invalid target!")
		return
	var/mob/living/carbon/carbon_target = target
	if(length(ripped_clothing))
		balloon_alert(mod.wearer, "already ripped!")
		return
	balloon_alert(mod.wearer, "ripping clothing...")
	playsound(src, 'sound/items/zip/zip.ogg', 25, TRUE, frequency = -1)
	if(!do_after(mod.wearer, 1.5 SECONDS, target = carbon_target))
		balloon_alert(mod.wearer, "interrupted!")
		return
	var/target_zones = body_zone2cover_flags(mod.wearer.zone_selected)
	for(var/obj/item/clothing as anything in carbon_target.get_equipped_items())
		if(!clothing)
			continue
		var/shared_flags = target_zones & clothing.body_parts_covered
		if(shared_flags)
			ripped_clothing[clothing] = shared_flags
			clothing.body_parts_covered &= ~shared_flags

/obj/item/mod/module/thread_ripper/on_process(seconds_per_tick)
	. = ..()
	if(!.)
		return
	if(!length(ripped_clothing))
		return
	var/zipped = FALSE
	for(var/obj/item/clothing as anything in ripped_clothing)
		if(QDELETED(clothing))
			ripped_clothing -= clothing
			continue
		var/mob/living/carbon/clothing_wearer = clothing.loc
		if(istype(clothing_wearer) && mod.wearer.Adjacent(clothing_wearer) && !clothing_wearer.is_holding(clothing))
			continue
		zipped = TRUE
		clothing.body_parts_covered |= ripped_clothing[clothing]
		ripped_clothing -= clothing
	if(zipped)
		playsound(src, 'sound/items/zip/zip.ogg', 25, TRUE)
		balloon_alert(mod.wearer, "clothing mended")

/obj/item/mod/module/thread_ripper/on_part_deactivation(deleting = FALSE)
	if(!length(ripped_clothing))
		return
	for(var/obj/item/clothing as anything in ripped_clothing)
		if(QDELETED(clothing))
			ripped_clothing -= clothing
			continue
		clothing.body_parts_covered |= ripped_clothing[clothing]
	ripped_clothing = list()
	if(!deleting)
		playsound(src, 'sound/items/zip/zip.ogg', 25, TRUE)

///Surgical Processor - Lets you do advanced surgeries portably.
/obj/item/mod/module/surgical_processor
	name = "MOD surgical processor module"
	desc = "A module using an onboard surgical computer which can be connected to other computers to download and \
		perform advanced surgeries on the go."
	icon_state = "surgical_processor"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/surgical_processor/mod
	incompatible_modules = list(/obj/item/mod/module/surgical_processor)
	cooldown_time = 0.5 SECONDS

/obj/item/surgical_processor/mod
	name = "MOD surgical processor"

/obj/item/mod/module/surgical_processor/preloaded
	desc = "A module using an onboard surgical computer which can be connected to other computers to download and \
		perform advanced surgeries on the go. This one came pre-loaded with some advanced surgeries."
	device = /obj/item/surgical_processor/mod/preloaded

/obj/item/surgical_processor/mod/preloaded
	loaded_surgeries = list(
		/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master,
		/datum/surgery_operation/limb/bioware/cortex_folding,
		/datum/surgery_operation/limb/bioware/cortex_folding/mechanic,
		/datum/surgery_operation/limb/bioware/cortex_imprint,
		/datum/surgery_operation/limb/bioware/cortex_imprint/mechanic,
		/datum/surgery_operation/limb/bioware/ligament_hook,
		/datum/surgery_operation/limb/bioware/ligament_hook/mechanic,
		/datum/surgery_operation/limb/bioware/ligament_reinforcement,
		/datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic,
		/datum/surgery_operation/limb/bioware/muscled_veins,
		/datum/surgery_operation/limb/bioware/muscled_veins/mechanic,
		/datum/surgery_operation/limb/bioware/nerve_grounding,
		/datum/surgery_operation/limb/bioware/nerve_grounding/mechanic,
		/datum/surgery_operation/limb/bioware/nerve_splicing,
		/datum/surgery_operation/limb/bioware/nerve_splicing/mechanic,
		/datum/surgery_operation/limb/bioware/vein_threading,
		/datum/surgery_operation/limb/bioware/vein_threading/mechanic,
		/datum/surgery_operation/organ/brainwash,
		/datum/surgery_operation/organ/brainwash/mechanic,
		/datum/surgery_operation/organ/pacify,
		/datum/surgery_operation/organ/pacify/mechanic,
	)

/obj/item/mod/module/surgical_processor/emergency
	desc = "A module using an onboard surgical computer which can be connected to other computers to download and \
		perform advanced surgeries on the go. This one came pre-loaded with some emergency surgeries."
	device = /obj/item/surgical_processor/mod/emergency

/obj/item/surgical_processor/mod/emergency
	loaded_surgeries = list(
		/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master,
		/datum/surgery_operation/organ/fix_wings,
	)
