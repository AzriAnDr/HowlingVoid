// Autodoc medical system - ported from EndlessSpace13 (originally from TerraGov-Marine-Corps, adapted for TG-style).
// An automated surgery machine that can heal patients, treat wounds, replace organs with cybernetics,
// attach prosthetic limbs, and revive dead patients.
// Features: Ore silo connection for material costs, techweb research integration for organ tiers,
// component-based scaling (servos, matter bins, micro lasers), and proximity interference with nearby autodocs.

#define AUTODOC_NOTICE_SUCCESS 1
#define AUTODOC_NOTICE_DEATH 2
#define AUTODOC_NOTICE_NO_POWER 3
#define AUTODOC_NOTICE_FORCED 4

/// How long to waste if someone queues an unneeded surgery.
#define AUTODOC_UNNEEDED_DELAY (10 SECONDS)

/// Maximum distance between two operating autodocs before EM interference kicks in.
#define AUTODOC_INTERFERENCE_RANGE 150
/// Minimum interference range achievable with best scanning modules.
#define AUTODOC_INTERFERENCE_RANGE_MIN 60
/// Duration of malfunction sequence before husking the patient.
#define AUTODOC_MALFUNCTION_DURATION (60 SECONDS)
/// Interval between malfunction warning announcements.
#define AUTODOC_MALFUNCTION_ANNOUNCE_INTERVAL (15 SECONDS)

// Surgery procedure defines
#define AUTODOC_PROCEDURE_BRUTE 1
#define AUTODOC_PROCEDURE_BURN 2
#define AUTODOC_PROCEDURE_TOXIN 3
#define AUTODOC_PROCEDURE_OXY 4
#define AUTODOC_PROCEDURE_DIALYSIS 5
#define AUTODOC_PROCEDURE_BLOOD 6
#define AUTODOC_PROCEDURE_WOUNDS 7
#define AUTODOC_PROCEDURE_ORGAN_DAMAGE 8
#define AUTODOC_PROCEDURE_EMBEDDED 9
#define AUTODOC_PROCEDURE_ORGAN_REPLACE 10
#define AUTODOC_PROCEDURE_LIMB_PROSTHETIC 11
#define AUTODOC_PROCEDURE_REVIVE 12
#define AUTODOC_PROCEDURE_DEHUSK 13
#define AUTODOC_PROCEDURE_LARVA_REMOVAL 14
#define AUTODOC_PROCEDURE_FLESHY_MASS 15
/// Base synthflesh cost to replace one organ in organic mode (units of synthflesh).
#define AUTODOC_SYNTHFLESH_COST_ORGAN 40
/// Base synthflesh cost to restore one limb in organic mode (units of synthflesh).
#define AUTODOC_SYNTHFLESH_COST_LIMB 80
/// Synthflesh cost for husk restoration (units of synthflesh at T1 servo rate).
#define AUTODOC_SYNTHFLESH_COST_DEHUSK 120

/datum/autodoc_surgery
	/// Human-readable name for the procedure.
	var/procedure_name = "Unknown"
	/// The procedure type constant.
	var/procedure_type = 0
	/// Has this procedure been checked if it was needed?
	var/checked_for_necessity = FALSE
	/// Has the operator already been warned about insufficient synthflesh?
	var/warned_no_synthflesh = FALSE

/datum/autodoc_surgery/New(new_procedure_type, new_name)
	procedure_type = new_procedure_type
	procedure_name = new_name

/obj/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A sophisticated automated surgery machine capable of performing medical procedures with minimal human intervention. \
		Can treat wounds, replace organs with cybernetics, attach prosthetic limbs, and revive dead patients. \
		Connects to the station's ore silo for material resources and the research network for cybernetic upgrades."
	icon = 'icons/obj/machines/autodoc.dmi'
	icon_state = "autodoc_open"
	density = TRUE
	anchored = TRUE
	interaction_flags_mouse_drop = NEED_DEXTERITY
	req_one_access = list(ACCESS_MEDICAL, ACCESS_SURGERY)
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 50
	circuit = /obj/item/circuitboard/machine/autodoc

	/// Radio to send discharge messages.
	var/obj/item/radio/headset/radio
	/// Remote materials datum for ore silo connection.
	var/datum/remote_materials/rmat
	/// Techweb reference for research-based organ tier selection.
	var/datum/techweb/stored_research
	/// Are notifications for patient discharges turned on?
	var/release_notice = TRUE
	/// A list of surgeries that should be done in order.
	var/list/datum/autodoc_surgery/surgery_list = list()
	/// The currently active surgery.
	var/datum/autodoc_surgery/active_surgery
	/// Base multiplier for surgery times. Lower = faster. Modified by servo tier in RefreshParts().
	var/surgery_time_multiplier = 1
	/// Amount of each chemical to filter per process tick.
	var/filtering = 0
	/// Units of blood to restore per process tick.
	var/blood_transfer = 0
	/// Brute damage to heal per process tick.
	var/heal_brute = 0
	/// Burn damage to heal per process tick.
	var/heal_burn = 0
	/// Toxin damage to heal per process tick.
	var/heal_toxin = 0
	/// Oxy damage to heal per process tick.
	var/heal_oxy = 0
	/// Should the surgery list be automatically generated and start?
	var/automatic_mode = FALSE
	/// Is the occupant going to be forcibly ejected?
	var/forcibly_ejected = FALSE
	/// Timer ID for surgery operation loop callback.
	var/surgery_timer_id
	/// Timer ID for autostart callback.
	var/autostart_timer_id
	/// Is the autodoc currently in revival mode for a dead patient?
	var/revival_mode = FALSE
	/// Current step within the revival sequence (0 = not started, 1 = charging, 2 = zap)
	var/revival_step = 0
	/// Healing rate modifier from servo components. Higher = more healing per tick.
	var/heal_rate_modifier = 1
	/// Material cost coefficient from matter_bin components. Lower = less materials consumed.
	var/material_efficiency = 1.3
	/// Current interference detection range, modified by scanning module tier.
	var/interference_range = AUTODOC_INTERFERENCE_RANGE
	/// Is the autodoc currently malfunctioning (locked down, burning patient)?
	var/malfunctioning = FALSE
	/// World.time when malfunction started.
	var/malfunction_start_time = 0
	/// World.time of last malfunction announcement.
	var/malfunction_last_announce = 0
	/// Is this autodoc permanently broken from a malfunction? Cannot be repaired, only destroyed and rebuilt.
	var/permanently_broken = FALSE
	/// Amount of universal blood stored and ready for transfusion.
	var/stored_blood = 0
	/// Amount of raw (non-universal) blood currently being transformed.
	var/raw_blood = 0
	/// Maximum blood storage capacity, determined by installed beaker volume.
	var/blood_capacity = 0
	/// Units of raw blood transformed into universal blood per process tick.
	var/blood_transform_rate = 1
	/// Whether the raw blood being processed is already universal (1:1 ratio instead of 1:1.25).
	var/raw_blood_is_universal = FALSE
	/// Amount of synthflesh stored for organic tissue restoration.
	var/stored_synthflesh = 0
	/// Maximum synthflesh capacity, determined by second installed beaker.
	var/synthflesh_capacity = 0
	/// Synthflesh consumption rate modifier. Lower = less synthflesh per organic operation. Modified by servo tier.
	var/synthflesh_use_rate = 1.0
	/// TRUE = use synthflesh to grow organic tissue; FALSE = use silo materials for cybernetics.
	var/organic_mode = FALSE

/obj/machinery/autodoc/Initialize(mapload)
	. = ..()
	radio = new /obj/item/radio/headset/silicon/ai(src)
	rmat = new /datum/remote_materials(src, mapload, allow_standalone = FALSE)
	update_appearance()

/obj/machinery/autodoc/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)

/obj/machinery/autodoc/Destroy()
	malfunctioning = FALSE
	permanently_broken = FALSE
	forcibly_ejected = TRUE
	INVOKE_ASYNC(src, PROC_REF(try_ejecting))
	QDEL_NULL(radio)
	QDEL_NULL(rmat)
	stored_research = null
	return ..()

/obj/machinery/autodoc/RefreshParts()
	. = ..()
	// Servo tier affects healing amount per tick and synthflesh consumption rate
	var/servo_total = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		servo_total += servo.tier
	// 2x tier1 = 1.0, 2x tier2 = 1.5, 2x tier3 = 2.0, 2x tier4 = 2.5
	heal_rate_modifier = 0.5 + (servo_total * 0.25)
	// 2x T1 = 1.0, 2x T2 = 0.8, 2x T3 = 0.6, 2x T4 = 0.4
	synthflesh_use_rate = max(0.4, 1.0 - (servo_total - 2) * 0.1)

	// Matter bin tier affects material efficiency
	var/bin_total = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		bin_total += bin.tier
	// 2x tier1 = 1.3, 2x tier2 = 1.0, 2x tier3 = 0.7, 2x tier4 = 0.6
	material_efficiency = max(0.4, 1.6 - (bin_total * 0.15))

	// Micro laser tier affects surgery speed (time multiplier)
	var/laser_total = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		laser_total += laser.tier
	// 1x tier1 = 1.0, 1x tier2 = 0.8, 1x tier3 = 0.6, 1x tier4 = 0.4
	surgery_time_multiplier = initial(surgery_time_multiplier) * max(0.3, 1.2 - (laser_total * 0.2))

	// Scanning module tier reduces interference detection range
	var/scanner_total = 0
	for(var/datum/stock_part/scanning_module/scanner in component_parts)
		scanner_total += scanner.tier
	// 1x tier1 = 130, 1x tier2 = 110, 1x tier3 = 90, 1x tier4 = 70
	interference_range = max(AUTODOC_INTERFERENCE_RANGE_MIN, AUTODOC_INTERFERENCE_RANGE - (scanner_total * 20))

	// Beakers: large beaker = blood storage, regular beaker = synthflesh storage
	blood_capacity = 0
	synthflesh_capacity = 0
	for(var/obj/item/reagent_containers/cup/beaker/beaker in component_parts)
		if(istype(beaker, /obj/item/reagent_containers/cup/beaker/large))
			blood_capacity = beaker.volume
			// Transform rate scales with volume: 100→2, 200→4, 250→5
			blood_transform_rate = beaker.volume / 50
		else
			synthflesh_capacity = beaker.volume
	// Clamp stored values to new capacities
	stored_blood = min(stored_blood, blood_capacity)
	raw_blood = min(raw_blood, max(0, blood_capacity - stored_blood))
	stored_synthflesh = min(stored_synthflesh, synthflesh_capacity)

/obj/machinery/autodoc/power_change()
	. = ..()
	if(permanently_broken || malfunctioning)
		return
	if(is_operational || !occupant)
		return
	say("ALERT: Power failure detected. Emergency ejection initiated.")
	visible_message("[src] engages the safety override, ejecting the occupant.")
	do_eject(AUTODOC_NOTICE_NO_POWER)

/obj/machinery/autodoc/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "autodoc_off"
		return
	if(permanently_broken)
		icon_state = occupant ? "autodoc_closed" : "autodoc_off"
		return
	if(malfunctioning || is_active())
		icon_state = "autodoc_operate"
		return
	if(occupant)
		icon_state = "autodoc_closed"
		return
	icon_state = "autodoc_open"

/obj/machinery/autodoc/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)

/obj/machinery/autodoc/update_icon()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
		return
	if(occupant || is_active())
		set_light(initial(light_range) + 1)
		return
	set_light(initial(light_range))

/obj/machinery/autodoc/process()
	// Blood transformation runs even without a patient
	if(raw_blood > 0 && blood_capacity > 0)
		var/transform_amount = min(raw_blood, blood_transform_rate)
		var/ratio = raw_blood_is_universal ? 1 : 1.25
		var/output = transform_amount * ratio
		var/space_for_output = blood_capacity - stored_blood
		if(space_for_output > 0)
			output = min(output, space_for_output)
			// Back-calculate how much raw blood we actually consumed
			var/consumed = output / ratio
			raw_blood = max(0, raw_blood - consumed)
			stored_blood = min(blood_capacity, stored_blood + output)
			if(raw_blood <= 0)
				raw_blood = 0
				say("Blood conversion complete. [round(stored_blood)]/[blood_capacity] units of universal blood ready.")

	var/mob/living/carbon/human/patient = occupant
	if(!patient)
		// Nothing else to do without a patient — stop processing if blood is done too
		if(raw_blood <= 0)
			end_processing()
		return

	// Malfunction mode takes priority — burns patient until husked
	if(malfunctioning)
		process_malfunction()
		return

	// Handle patient death - activate revival mode instead of ejecting
	if(patient.stat == DEAD)
		if(!revival_mode)
			revival_mode = TRUE
			say("WARNING: Patient vital signs absent. Initiating emergency revival protocol.")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
			// Boost healing rates for emergency revival
			if(!heal_brute && patient.get_brute_loss() > 0)
				heal_brute = 5 * heal_rate_modifier
			if(!heal_burn && patient.get_fire_loss() > 0)
				heal_burn = 5 * heal_rate_modifier
			if(!heal_toxin && patient.get_tox_loss() > 0)
				heal_toxin = 5 * heal_rate_modifier
			if(!heal_oxy && patient.get_oxy_loss() > 0)
				heal_oxy = 10 * heal_rate_modifier
			if(!blood_transfer && patient.blood_volume < BLOOD_VOLUME_NORMAL)
				blood_transfer = 10
			// Queue revival procedure if not already queued
			var/has_revive = FALSE
			for(var/datum/autodoc_surgery/surgery in surgery_list)
				if(surgery.procedure_type == AUTODOC_PROCEDURE_REVIVE)
					has_revive = TRUE
					break
			if(!has_revive)
				surgery_list += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_REVIVE, "Patient Revival")
			// Ensure processing and surgery loop are running
			if(!(datum_flags & DF_ISPROCESSING))
				begin_processing()
			if(!surgery_timer_id && !active_surgery)
				loop_surgery_operation()
	else if(revival_mode)
		// Patient has been revived
		revival_mode = FALSE

	// Check if all procedures are complete and patient is alive
	if(patient.stat != DEAD && !length(surgery_list) && !is_active())
		say("All procedures complete. Releasing patient.")
		visible_message(span_notice("\The [src] clicks and opens up, having finished all operations."))
		do_eject(AUTODOC_NOTICE_SUCCESS)
		return

	// Passive stabilization while inside (alive patients only)
	if(patient.stat != DEAD)
		patient.adjust_oxy_loss(-1)
		// For toxinlover species (e.g. slimes), negative adjustToxLoss is inverted into damage.
		// Use forced = TRUE to bypass trait inversion and unconditionally heal toxin damage.
		patient.adjust_tox_loss(-0.5, forced = TRUE)

	// Blood filtering
	if(filtering)
		// Don't filter out the patient's own blood reagent (e.g. slimejelly for slime humanoids).
		var/patient_blood_reagent = patient.get_blood_reagent()
		var/something_filtered = FALSE
		for(var/datum/reagent/held_reagent in patient.reagents.reagent_list)
			if(held_reagent.type == patient_blood_reagent)
				continue // Preserve native blood reagent
			if(patient.reagents.remove_reagent(held_reagent.type, filtering))
				something_filtered = TRUE
		if(!something_filtered)
			filtering = 0
			say("Blood filtering complete.")

	// Blood transfusion (draws from stored universal blood)
	if(blood_transfer)
		if(patient.blood_volume < BLOOD_VOLUME_NORMAL)
			var/needed = min(blood_transfer, BLOOD_VOLUME_NORMAL - patient.blood_volume)
			if(stored_blood >= needed)
				patient.blood_volume += needed
				stored_blood -= needed
			else if(stored_blood > 0)
				patient.blood_volume += stored_blood
				stored_blood = 0
			// If no blood available, keep trying (don't reset blood_transfer)
		else
			blood_transfer = 0
			say("Blood transfusion complete.")

	// Continuous damage healing
	var/should_update_health = FALSE
	if(heal_brute)
		if(patient.get_brute_loss() > 0)
			patient.heal_overall_damage(brute = heal_brute)
			should_update_health = TRUE
		else
			heal_brute = 0
			say("Trauma repair complete.")
	if(heal_burn)
		if(patient.get_fire_loss() > 0)
			patient.heal_overall_damage(burn = heal_burn)
			should_update_health = TRUE
		else
			heal_burn = 0
			say("Burn treatment complete.")
	if(heal_toxin)
		if(patient.get_tox_loss() > 0)
			// Use forced = TRUE so toxinlover species (slimes) are healed instead of damaged
			patient.adjust_tox_loss(-heal_toxin, forced = TRUE)
			should_update_health = TRUE
		else
			heal_toxin = 0
			say("Toxin chelation complete.")
	if(heal_oxy)
		if(patient.get_oxy_loss() > 0)
			patient.adjust_oxy_loss(-heal_oxy)
			should_update_health = TRUE
		else
			heal_oxy = 0
			say("Respiratory therapy complete.")
	if(should_update_health)
		patient.updatehealth()

/obj/machinery/autodoc/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(item, /obj/item/healthanalyzer) && occupant)
		var/obj/item/healthanalyzer/analyzer = item
		analyzer.attack(occupant, user)
		return TRUE
	if(istype(item, /obj/item/reagent_containers/blood))
		insert_blood_pack(item, user)
		return TRUE
	if(istype(item, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = item
		if(container.reagents?.has_reagent(/datum/reagent/medicine/c2/synthflesh))
			insert_synthflesh(container, user)
			return TRUE

/// Inserts a blood pack into the autodoc's internal blood processing system.
/obj/machinery/autodoc/proc/insert_blood_pack(obj/item/reagent_containers/blood/pack, mob/user)
	if(permanently_broken || malfunctioning)
		to_chat(user, span_warning("[src] is non-functional!"))
		return
	if(blood_capacity <= 0)
		to_chat(user, span_warning("[src] has no blood storage system installed!"))
		return
	var/total_stored = stored_blood + raw_blood
	if(total_stored >= blood_capacity)
		to_chat(user, span_warning("[src]'s blood storage is full! ([total_stored]/[blood_capacity] units)"))
		return
	var/blood_amount = pack.reagents?.total_volume
	if(!blood_amount || blood_amount <= 0)
		to_chat(user, span_warning("The blood pack is empty!"))
		return
	// Calculate how much we can actually accept
	var/space_available = blood_capacity - total_stored
	var/amount_to_add = min(blood_amount, space_available)
	// Check if this blood is already universal type
	var/is_universal = FALSE
	for(var/datum/reagent/blood/blood_reagent in pack.reagents.reagent_list)
		var/list/blood_data = blood_reagent.data
		if(islist(blood_data))
			var/datum/blood_type/bt = blood_data["blood_type"]
			if(istype(bt) && bt.name == BLOOD_TYPE_UNIVERSAL)
				is_universal = TRUE
		break
	if(amount_to_add > 0)
		raw_blood += amount_to_add
		raw_blood_is_universal = is_universal
		pack.reagents.remove_reagent(/datum/reagent/blood, amount_to_add)
		if(!user.transferItemToLoc(pack, src))
			pack.forceMove(src)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		to_chat(user, span_notice("You insert [pack] into [src]'s blood processing system. [amount_to_add] units of blood added for processing."))
		say("Blood pack inserted. [amount_to_add] units queued for universal conversion. Storage: [round(stored_blood)]/[blood_capacity] ready, [round(raw_blood)] processing.")
		// Start processing to transform blood even without a patient
		if(!(datum_flags & DF_ISPROCESSING))
			begin_processing()

/// Ejects all blood packs stored inside the autodoc.
/obj/machinery/autodoc/proc/eject_blood_packs()
	var/ejected = FALSE
	for(var/obj/item/reagent_containers/blood/pack in contents)
		pack.forceMove(loc)
		ejected = TRUE
	if(ejected)
		raw_blood = 0
		raw_blood_is_universal = FALSE
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		say("Blood packs ejected. [round(stored_blood)] units of processed blood remain in storage.")
	else
		say("No blood packs to eject.")

/obj/machinery/autodoc/screwdriver_act(mob/living/user, obj/item/tool)
	if(malfunctioning || permanently_broken)
		to_chat(user, span_warning("[src] is completely non-functional. It cannot be repaired."))
		return ITEM_INTERACT_BLOCKING
	if(occupant)
		to_chat(user, span_warning("You cannot open the maintenance panel while someone is inside!"))
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "autodoc_open", "autodoc_open", tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/autodoc/crowbar_act(mob/living/user, obj/item/tool)
	if(malfunctioning || permanently_broken)
		to_chat(user, span_warning("[src] is completely non-functional. It cannot be repaired."))
		return ITEM_INTERACT_BLOCKING
	if(occupant)
		to_chat(user, span_warning("You cannot deconstruct while someone is inside!"))
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/autodoc/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	automatic_mode = TRUE
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	balloon_alert(user, "safety protocols overridden")
	// If a patient is already inside, trigger malfunction immediately
	if(occupant)
		start_malfunction()
	return TRUE

/obj/machinery/autodoc/mouse_drop_receive(atom/dropped, mob/user, params)
	if(!ishuman(dropped) || !ishuman(user))
		return
	try_entering(user, dropped)

/// Handles a mob trying to eject the occupant.
/obj/machinery/autodoc/proc/try_ejecting(mob/ejector)
	if(!occupant)
		return
	// Malfunction/broken lockdown — only forced ejection (machine destruction) can override
	if((malfunctioning || permanently_broken) && !forcibly_ejected)
		if(ejector)
			to_chat(ejector, span_warning("[src] is unresponsive! The emergency lockdown cannot be overridden. The machine must be physically destroyed to extract the patient."))
		return
	if(forcibly_ejected)
		var/mob/living/living_occupant = occupant
		if(!active_surgery)
			visible_message(span_warning("\The [src] is destroyed, ejecting [occupant] and showering them in debris."))
			living_occupant?.adjust_brute_loss(rand(10, 20))
		else
			visible_message(span_danger("\The [src] malfunctions as it is destroyed mid-surgery, ejecting [occupant] with surgical wounds!"))
			living_occupant?.adjust_brute_loss(rand(30, 50))
		do_eject(AUTODOC_NOTICE_FORCED)
		return
	if(!ishuman(ejector))
		return
	if(ejector == occupant)
		if(active_surgery)
			to_chat(ejector, span_warning("There's no way you're getting out while this thing is operating on you!"))
			return
		visible_message(span_notice("[ejector] engages the internal release mechanism, and climbs out of \the [src]."))
		do_eject()
		return
	do_eject()

/// Ejects the occupant and ends all surgery if applicable.
/obj/machinery/autodoc/proc/do_eject(notice_code)
	for(var/atom/movable/movable_thing as anything in contents)
		if(movable_thing == radio)
			continue
		if(movable_thing in component_parts)
			continue
		// Keep blood packs inside during patient ejection
		if(istype(movable_thing, /obj/item/reagent_containers/blood))
			continue
		movable_thing.forceMove(loc)
	if(release_notice && occupant)
		var/reason = "Reason for discharge: Procedural completion."
		switch(notice_code)
			if(AUTODOC_NOTICE_SUCCESS)
				playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
			if(AUTODOC_NOTICE_DEATH)
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Patient death. Revival failed."
			if(AUTODOC_NOTICE_NO_POWER)
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Power failure."
			if(AUTODOC_NOTICE_FORCED)
				playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Emergency ejection."
		if(radio)
			radio.talk_into(src, "Patient [occupant] has been released from [src] at [get_area(src)]. [reason]", RADIO_CHANNEL_MEDICAL)
	occupant = null
	surgery_list = list()
	active_surgery = null
	filtering = 0
	blood_transfer = 0
	heal_brute = 0
	heal_burn = 0
	heal_toxin = 0
	heal_oxy = 0
	revival_mode = FALSE
	revival_step = 0
	malfunctioning = FALSE
	malfunction_start_time = 0
	malfunction_last_announce = 0
	if(surgery_timer_id)
		deltimer(surgery_timer_id)
		surgery_timer_id = null
	if(autostart_timer_id)
		deltimer(autostart_timer_id)
		autostart_timer_id = null
	if(datum_flags & DF_ISPROCESSING)
		end_processing()
	update_appearance()

/// Checks if a human can enter the machine. Dead patients are accepted for revival.
/obj/machinery/autodoc/proc/can_enter(mob/living/carbon/human/mover, mob/living/carbon/human/future_occupant, silent = FALSE)
	if(permanently_broken)
		if(!silent)
			to_chat(mover, span_warning("[src] is completely non-functional!"))
		return FALSE
	if(malfunctioning)
		if(!silent)
			to_chat(mover, span_warning("[src] is in emergency lockdown!"))
		return FALSE
	if(occupant)
		if(!silent)
			to_chat(mover, span_warning("[src] is already occupied!"))
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		if(!silent)
			to_chat(mover, span_warning("[src] is non-functional!"))
		return FALSE
	if(mover.incapacitated)
		if(!silent)
			to_chat(mover, span_warning("You need to be standing for this!"))
		return FALSE
	return TRUE

/// Tries to move a human into the machine.
/obj/machinery/autodoc/proc/try_entering(mob/living/carbon/human/mover, mob/living/carbon/human/future_occupant)
	if(!can_enter(mover, future_occupant))
		return
	mover.visible_message(span_notice("[mover] starts [mover == future_occupant ? "climbing" : "moving [future_occupant]"] into \the [src]."),
		span_notice("You start [mover == future_occupant ? "climbing" : "moving [future_occupant]"] into \the [src]."))
	if(!do_after(mover, 1 SECONDS, src) || !can_enter(mover, future_occupant))
		return
	future_occupant.forceMove(src)
	occupant = future_occupant
	surgery_list = generate_surgery_list(occupant)
	update_appearance()
	playsound(loc, 'sound/machines/ping.ogg', 25, TRUE)
	say("Patient scan complete. [length(surgery_list)] procedures identified.")
	// Check for EM interference from nearby autodocs or EMAG sabotage
	if((obj_flags & EMAGGED) || check_interference())
		start_malfunction()
		return
	if(future_occupant.stat == DEAD)
		revival_mode = TRUE
		say("WARNING: Patient is deceased. Revival protocol queued.")
	if(automatic_mode)
		say("Automatic mode engaged. Beginning treatment protocol.")
		autostart_timer_id = addtimer(CALLBACK(src, PROC_REF(auto_start)), 2 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/// Callback to start the surgery operation for automatic mode.
/obj/machinery/autodoc/proc/auto_start()
	if(autostart_timer_id)
		deltimer(autostart_timer_id)
		autostart_timer_id = null
	if(active_surgery)
		return
	if(!occupant)
		say("Occupant missing. Procedures canceled.")
		return
	if(!automatic_mode)
		say("Automatic mode disengaged. Awaiting manual input.")
		return
	begin_surgery_operation()

/// Returns TRUE if there is active surgery or ongoing procedures.
/obj/machinery/autodoc/proc/is_active()
	if(active_surgery || surgery_timer_id || filtering || blood_transfer || heal_brute || heal_burn || heal_toxin || heal_oxy || malfunctioning)
		return TRUE
	return FALSE

/// Checks if any other autodoc exists within interference range. Returns TRUE if detected.
/obj/machinery/autodoc/proc/check_interference()
	for(var/obj/machinery/autodoc/other_autodoc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/autodoc))
		if(other_autodoc == src)
			continue
		if(other_autodoc.z != z)
			continue
		if(get_dist(src, other_autodoc) <= interference_range)
			return TRUE
	return FALSE

/// Initiates the malfunction sequence — locks the pod, begins burning the patient.
/obj/machinery/autodoc/proc/start_malfunction()
	malfunctioning = TRUE
	malfunction_start_time = world.time
	malfunction_last_announce = world.time
	// Cancel any pending surgery/auto timers
	if(surgery_timer_id)
		deltimer(surgery_timer_id)
		surgery_timer_id = null
	if(autostart_timer_id)
		deltimer(autostart_timer_id)
		autostart_timer_id = null
	active_surgery = null
	surgery_list = list()
	filtering = 0
	blood_transfer = 0
	heal_brute = 0
	heal_burn = 0
	heal_toxin = 0
	heal_oxy = 0
	say("CRITICAL ERROR: System malfunction detected. Emergency lockdown initiated. All safety protocols disabled.")
	playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, FALSE)
	visible_message(span_danger("\The [src] sparks violently and locks shut with a loud clang! Something has gone terribly wrong!"))
	begin_processing()
	update_appearance()

/// Handles per-tick malfunction processing — deals burn damage and eventually husks the patient.
/obj/machinery/autodoc/proc/process_malfunction()
	var/mob/living/carbon/human/patient = occupant
	if(!patient)
		malfunctioning = FALSE
		permanently_broken = TRUE
		machine_stat |= BROKEN
		update_appearance()
		return

	// Deal burn damage every tick
	patient.adjust_fire_loss(4)
	patient.updatehealth()

	// Periodic malfunction announcements every 15 seconds
	if(world.time >= malfunction_last_announce + AUTODOC_MALFUNCTION_ANNOUNCE_INTERVAL)
		malfunction_last_announce = world.time
		var/list/malfunction_messages = list(
			"ALERT: System integrity compromised. Thermal regulation failure.",
			"WARNING: Emergency protocols non-responsive. Patient extraction required.",
			"ERROR: Surgical laser array misaligned. Uncontrolled energy discharge detected.",
			"CRITICAL: Internal temperature exceeding safe parameters. Manual shutdown impossible.",
		)
		say(pick(malfunction_messages))
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)

	// After 60 seconds, apply husk and permanently break
	if(world.time >= malfunction_start_time + AUTODOC_MALFUNCTION_DURATION)
		patient.become_husk("autodoc_malfunction")
		patient.death()
		say("FATAL ERROR: System failure complete. Unit is non-functional. Patient status: deceased.")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, FALSE)
		if(radio)
			radio.talk_into(src, "ALERT: Autodoc at [get_area(src)] has suffered catastrophic system failure. Patient [patient] requires immediate extraction. Unit is non-functional.", RADIO_CHANNEL_MEDICAL)
		malfunctioning = FALSE
		permanently_broken = TRUE
		machine_stat |= BROKEN
		update_appearance()

/// Returns the best available cybernetic organ tier based on station research.
/// 1 = basic augmentation, 2 = standard cybernetics, 3 = upgraded cybernetics
/obj/machinery/autodoc/proc/get_organ_tier()
	if(!stored_research)
		return 1
	// Check tier 3 first (upgraded cybernetic organs)
	if(stored_research.researched_designs["cybernetic_heart_tier3"])
		return 3
	// Check tier 2 (standard cybernetic organs)
	if(stored_research.researched_designs["cybernetic_heart_tier2"])
		return 2
	// Default to tier 1 (basic augmentation)
	return 1

/// Returns the correct organ type path for a given slot and research tier.
/obj/machinery/autodoc/proc/get_organ_for_slot(slot, tier)
	var/static/list/organ_tiers
	if(!organ_tiers)
		organ_tiers = list()
		// Tier 1 — basic cybernetics
		organ_tiers["1"] = list()
		organ_tiers["1"][ORGAN_SLOT_HEART] = /obj/item/organ/heart/cybernetic
		organ_tiers["1"][ORGAN_SLOT_LUNGS] = /obj/item/organ/lungs/cybernetic
		organ_tiers["1"][ORGAN_SLOT_LIVER] = /obj/item/organ/liver/cybernetic
		organ_tiers["1"][ORGAN_SLOT_STOMACH] = /obj/item/organ/stomach/cybernetic
		organ_tiers["1"][ORGAN_SLOT_EYES] = /obj/item/organ/eyes/robotic/basic
		organ_tiers["1"][ORGAN_SLOT_EARS] = /obj/item/organ/ears/cybernetic
		organ_tiers["1"][ORGAN_SLOT_TONGUE] = /obj/item/organ/tongue/robot
		// Tier 2 — standard cybernetics
		organ_tiers["2"] = list()
		organ_tiers["2"][ORGAN_SLOT_HEART] = /obj/item/organ/heart/cybernetic/tier2
		organ_tiers["2"][ORGAN_SLOT_LUNGS] = /obj/item/organ/lungs/cybernetic/tier2
		organ_tiers["2"][ORGAN_SLOT_LIVER] = /obj/item/organ/liver/cybernetic/tier2
		organ_tiers["2"][ORGAN_SLOT_STOMACH] = /obj/item/organ/stomach/cybernetic/tier2
		organ_tiers["2"][ORGAN_SLOT_EYES] = /obj/item/organ/eyes/robotic/basic
		organ_tiers["2"][ORGAN_SLOT_EARS] = /obj/item/organ/ears/cybernetic/upgraded
		organ_tiers["2"][ORGAN_SLOT_TONGUE] = /obj/item/organ/tongue/robot
		// Tier 3 — upgraded cybernetics
		organ_tiers["3"] = list()
		organ_tiers["3"][ORGAN_SLOT_HEART] = /obj/item/organ/heart/cybernetic/tier3
		organ_tiers["3"][ORGAN_SLOT_LUNGS] = /obj/item/organ/lungs/cybernetic/tier3
		organ_tiers["3"][ORGAN_SLOT_LIVER] = /obj/item/organ/liver/cybernetic/tier3
		organ_tiers["3"][ORGAN_SLOT_STOMACH] = /obj/item/organ/stomach/cybernetic/tier3
		organ_tiers["3"][ORGAN_SLOT_EYES] = /obj/item/organ/eyes/robotic/basic
		organ_tiers["3"][ORGAN_SLOT_EARS] = /obj/item/organ/ears/cybernetic/upgraded
		organ_tiers["3"][ORGAN_SLOT_TONGUE] = /obj/item/organ/tongue/robot

	var/tier_key = "[tier]"
	if(!organ_tiers[tier_key] || !organ_tiers[tier_key][slot])
		return null
	return organ_tiers[tier_key][slot]

/// Returns the material cost list for creating a cybernetic organ at the given tier.
/obj/machinery/autodoc/proc/get_organ_material_cost(tier)
	switch(tier)
		if(3)
			return list(
				/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
				/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
				/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
			)
		else
			return list(
				/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
				/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
			)

/// Returns the material cost list for creating a prosthetic limb.
/obj/machinery/autodoc/proc/get_limb_material_cost()
	return list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)

/// Checks if the connected silo has enough materials for the given cost.
/// Returns TRUE if materials are available, or if no silo is connected (operates without materials).
/obj/machinery/autodoc/proc/check_materials(list/cost)
	if(!rmat)
		return TRUE
	if(!rmat.mat_container)
		return FALSE
	if(rmat.on_hold())
		return FALSE
	return rmat.mat_container.has_materials(cost, material_efficiency)

/// Consumes materials from the connected silo. Returns TRUE if successful.
/obj/machinery/autodoc/proc/consume_materials(list/cost, item_name = "component")
	if(!rmat)
		return TRUE
	if(!rmat.mat_container)
		return FALSE
	if(rmat.on_hold())
		return FALSE
	if(!rmat.mat_container.has_materials(cost, material_efficiency))
		return FALSE
	rmat.use_materials(cost, material_efficiency, 1, "built", item_name)
	return TRUE

/// Returns TRUE if a silo is connected and accessible.
/obj/machinery/autodoc/proc/has_silo_connection()
	if(!rmat)
		return FALSE
	if(!rmat.mat_container)
		return FALSE
	if(!rmat.silo)
		return FALSE
	if(rmat.on_hold())
		return FALSE
	return TRUE

/// Inserts synthflesh from a reagent container into the machine's internal storage.
/obj/machinery/autodoc/proc/insert_synthflesh(obj/item/reagent_containers/container, mob/user)
	if(permanently_broken || malfunctioning)
		to_chat(user, span_warning("[src] is non-functional!"))
		return
	if(synthflesh_capacity <= 0)
		to_chat(user, span_warning("[src] has no synthflesh storage installed!"))
		return
	if(stored_synthflesh >= synthflesh_capacity)
		to_chat(user, span_warning("[src]'s synthflesh tank is full! ([round(stored_synthflesh)]/[synthflesh_capacity] u)"))
		return
	var/amount = container.reagents.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh)
	var/space = synthflesh_capacity - stored_synthflesh
	var/to_add = min(amount, space)
	if(to_add <= 0)
		return
	container.reagents.remove_reagent(/datum/reagent/medicine/c2/synthflesh, to_add)
	stored_synthflesh += to_add
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	to_chat(user, span_notice("You add [to_add] units of synthflesh to [src]. Tank: [round(stored_synthflesh)]/[synthflesh_capacity] u."))
	say("Synthflesh replenished. [round(stored_synthflesh)]/[synthflesh_capacity] units available.")

/// Returns TRUE if the machine has enough synthflesh stored for the given operation.
/obj/machinery/autodoc/proc/check_synthflesh(amount)
	return stored_synthflesh >= amount

/// Consumes synthflesh from internal storage.
/obj/machinery/autodoc/proc/consume_synthflesh(amount)
	stored_synthflesh = max(0, stored_synthflesh - amount)

/// Returns the organic (non-cybernetic) organ typepath for the given organ slot.
/obj/machinery/autodoc/proc/get_organic_organ_for_slot(slot)
	var/static/list/organic_organs
	if(!organic_organs)
		organic_organs = list(
			ORGAN_SLOT_HEART = /obj/item/organ/heart,
			ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
			ORGAN_SLOT_EYES = /obj/item/organ/eyes,
			ORGAN_SLOT_EARS = /obj/item/organ/ears,
			ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		)
	return organic_organs[slot]

/// Returns a species-appropriate organic bodypart typepath for a given zone, based on the patient's species.
/obj/machinery/autodoc/proc/get_organic_limb_for_zone(zone, mob/living/carbon/human/patient)
	var/part_type
	switch(zone)
		if(BODY_ZONE_L_ARM)
			part_type = "arm/left"
		if(BODY_ZONE_R_ARM)
			part_type = "arm/right"
		if(BODY_ZONE_L_LEG)
			part_type = "leg/left"
		if(BODY_ZONE_R_LEG)
			part_type = "leg/right"
		else
			return null
	var/species_id = patient.dna?.species?.id || SPECIES_HUMAN
	var/path
	if(species_id == SPECIES_HUMAN)
		path = text2path("/obj/item/bodypart/[part_type]")
	else
		path = text2path("/obj/item/bodypart/[part_type]/[species_id]")
		if(!path) // Fallback: species uses human bodypart types
			path = text2path("/obj/item/bodypart/[part_type]")
	return path

/// Verb to move yourself into the autodoc.
/obj/machinery/autodoc/verb/move_inside()
	set name = "Enter Autodoc Pod"
	set category = "IC.Object"
	set src in oview(1)

	if(ishuman(usr))
		try_entering(usr, usr)

/// Verb to eject whoever is in the autodoc.
/obj/machinery/autodoc/verb/eject()
	set name = "Eject Autodoc"
	set category = "IC.Object"
	set src in oview(1)

	if(usr.incapacitated)
		return
	try_ejecting(usr)

/// Generates a full list of surgeries for a given patient, respecting the machine's current operating mode.
/obj/machinery/autodoc/proc/generate_surgery_list(mob/living/carbon/human/patient)
	var/list/datum/autodoc_surgery/result = list()

	// Xenomorph larva extraction — highest priority, prevents fatal chestbursting
	for(var/obj/item/organ/organ as anything in patient.organs)
		if(istype(organ, /obj/item/organ/body_egg))
			result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_LARVA_REMOVAL, "Xenomorph Larva Extraction")
			break

	// Anomalous heart removal — nightmare hearts and other corrupted cardiac organs
	var/obj/item/organ/existing_heart = patient.get_organ_slot(ORGAN_SLOT_HEART)
	if(existing_heart && !(existing_heart.organ_flags & ORGAN_ROBOTIC) && istype(existing_heart, /obj/item/organ/heart/nightmare))
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_FLESHY_MASS, "Anomalous Heart Removal")

	// Husk treatment — must be cured before other procedures can be effective
	if(HAS_TRAIT(patient, TRAIT_HUSK))
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_DEHUSK, "Husk Restoration")

	// Wound treatment (bleeding, fractures, burns, etc.)
	if(length(patient.all_wounds))
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_WOUNDS, "Wound Treatment ([length(patient.all_wounds)] wounds)")

	// Organ damage repair
	var/has_organ_damage = FALSE
	for(var/obj/item/organ/organ as anything in patient.organs)
		if(organ.damage > 0 && !(organ.organ_flags & ORGAN_ROBOTIC))
			has_organ_damage = TRUE
			break
	if(has_organ_damage)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_ORGAN_DAMAGE, "Organ Restoration")

	// Missing or failing organ replacement with cybernetics
	var/static/list/organ_slots_to_check
	if(!organ_slots_to_check)
		organ_slots_to_check = list(
			ORGAN_SLOT_HEART,
			ORGAN_SLOT_LUNGS,
			ORGAN_SLOT_LIVER,
			ORGAN_SLOT_STOMACH,
			ORGAN_SLOT_EYES,
			ORGAN_SLOT_EARS,
			ORGAN_SLOT_TONGUE,
		)
	var/missing_organs = 0
	var/failing_organs = 0
	for(var/slot in organ_slots_to_check)
		var/obj/item/organ/existing = patient.get_organ_slot(slot)
		if(!existing)
			missing_organs++
		else if((existing.organ_flags & ORGAN_FAILING) && !(existing.organ_flags & ORGAN_ROBOTIC))
			failing_organs++
	var/total_organ_issues = missing_organs + failing_organs
	if(total_organ_issues)
		var/organ_desc = ""
		if(missing_organs && failing_organs)
			organ_desc = "([missing_organs] missing, [failing_organs] failing)"
		else if(missing_organs)
			organ_desc = "([missing_organs] missing)"
		else
			organ_desc = "([failing_organs] failing)"
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_ORGAN_REPLACE, "[organic_mode ? "Organic Organ Restoration" : "Cybernetic Organ Replacement"] [organ_desc]")

	// Missing limb replacement with prosthetics
	var/static/list/limb_zones_to_check
	if(!limb_zones_to_check)
		limb_zones_to_check = list(
			BODY_ZONE_L_ARM,
			BODY_ZONE_R_ARM,
			BODY_ZONE_L_LEG,
			BODY_ZONE_R_LEG,
		)
	var/missing_limbs = 0
	for(var/zone in limb_zones_to_check)
		if(!patient.get_bodypart(zone))
			missing_limbs++
	if(missing_limbs)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_LIMB_PROSTHETIC, "[organic_mode ? "Organic Limb Regeneration" : "Prosthetic Limb Attachment"] ([missing_limbs] limbs)")

	// Embedded objects
	if(patient.has_embedded_objects())
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_EMBEDDED, "Foreign Body Removal")

	// Brute damage
	if(patient.get_brute_loss() > 0)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_BRUTE, "Trauma Repair")

	// Burn damage
	if(patient.get_fire_loss() > 0)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_BURN, "Burn Treatment")

	// Toxin damage
	if(patient.get_tox_loss() > 0)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_TOXIN, "Toxin Chelation")

	// Oxygen damage
	if(patient.get_oxy_loss() > 15)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_OXY, "Respiratory Therapy")

	// Blood loss
	if(patient.blood_volume < BLOOD_VOLUME_NORMAL)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_BLOOD, "Blood Transfusion")

	// Toxins in blood / overdose
	// Don't count the patient's own blood reagent as a toxin (e.g. slimejelly for slime humanoids).
	var/blood_reagent_type = patient.get_blood_reagent()
	var/needs_dialysis = FALSE
	for(var/datum/reagent/held_reagent in patient.reagents?.reagent_list)
		if(held_reagent.type == blood_reagent_type)
			continue // Skip native blood reagent — filtering it would harm the patient
		if(istype(held_reagent, /datum/reagent/toxin) || (held_reagent.overdose_threshold && patient.reagents.get_reagent_amount(held_reagent.type) > held_reagent.overdose_threshold))
			needs_dialysis = TRUE
			break
	if(needs_dialysis)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_DIALYSIS, "Blood Dialysis")

	// Revival for dead patients - always last in the queue
	if(patient.stat == DEAD)
		result += new /datum/autodoc_surgery(AUTODOC_PROCEDURE_REVIVE, "Patient Revival")

	return result

/// Begins the surgery operation.
/obj/machinery/autodoc/proc/begin_surgery_operation()
	if(is_active())
		return
	var/mob/living/carbon/human/patient = occupant
	if(QDELETED(patient))
		visible_message(span_warning("[src] buzzes."))
		return

	if(!length(surgery_list))
		visible_message(span_warning("[src] buzzes. No procedures queued."))
		return

	begin_processing()
	say("Commencing surgical procedures.")
	playsound(loc, 'sound/machines/ping.ogg', 50, TRUE)

	// Activate continuous procedures (damage healing, blood, filtering)
	var/rate_multiplier = (revival_mode ? 1.5 : 1) * heal_rate_modifier
	for(var/datum/autodoc_surgery/surgery in surgery_list)
		switch(surgery.procedure_type)
			if(AUTODOC_PROCEDURE_BRUTE)
				heal_brute = 3 * rate_multiplier
				say("Initiating trauma repair system.")
				surgery_list -= surgery
			if(AUTODOC_PROCEDURE_BURN)
				heal_burn = 3 * rate_multiplier
				say("Initiating burn treatment system.")
				surgery_list -= surgery
			if(AUTODOC_PROCEDURE_TOXIN)
				heal_toxin = 3 * rate_multiplier
				say("Initiating toxin chelation system.")
				surgery_list -= surgery
			if(AUTODOC_PROCEDURE_OXY)
				heal_oxy = 5 * rate_multiplier
				say("Initiating respiratory therapy system.")
				surgery_list -= surgery
			if(AUTODOC_PROCEDURE_DIALYSIS)
				filtering = 10
				say("Initiating blood dialysis system.")
				surgery_list -= surgery
			if(AUTODOC_PROCEDURE_BLOOD)
				blood_transfer = 8 * rate_multiplier
				say("Initiating blood transfusion system.")
				surgery_list -= surgery

	visible_message(span_notice("[src] begins to operate, the pod locking shut with a loud click."))
	loop_surgery_operation()
	update_appearance()

/// Continues the surgery operation loop. Processes one step at a time.
/obj/machinery/autodoc/proc/loop_surgery_operation()
	if(surgery_timer_id)
		deltimer(surgery_timer_id)
		surgery_timer_id = null
	if(!length(surgery_list))
		active_surgery = null
		return
	if(!active_surgery)
		active_surgery = surgery_list[1]

	var/mob/living/carbon/human/patient = occupant
	if(!patient)
		return

	switch(active_surgery.procedure_type)
		if(AUTODOC_PROCEDURE_WOUNDS)
			if(!active_surgery.checked_for_necessity)
				say("Beginning wound treatment. [length(patient.all_wounds)] wounds detected.")
				active_surgery.checked_for_necessity = TRUE
			if(!length(patient.all_wounds))
				say("All wounds treated successfully.")
				handle_completed_surgery()
				return
			// Treat wounds one at a time with announcements
			var/datum/wound/target_wound = patient.all_wounds[1]
			var/wound_name = target_wound.name
			var/wound_location = "body"
			if(target_wound.limb)
				wound_location = target_wound.limb.plaintext_zone
			say("Treating [wound_name] on [wound_location].")
			target_wound.remove_wound()
			loop_in_time(4 SECONDS)
			return

		if(AUTODOC_PROCEDURE_ORGAN_DAMAGE)
			if(!active_surgery.checked_for_necessity)
				say("Beginning organ restoration procedure.")
				active_surgery.checked_for_necessity = TRUE
			var/healed_any = FALSE
			for(var/obj/item/organ/organ as anything in patient.organs)
				if(organ.damage > 0 && !(organ.organ_flags & ORGAN_ROBOTIC))
					say("Repairing damage to [organ.name].")
					organ.apply_organ_damage(-organ.damage)
					healed_any = TRUE
			if(!healed_any)
				handle_unnecessary_surgery()
				return
			say("Organ restoration complete.")
			handle_completed_surgery(6 SECONDS)
			return

		if(AUTODOC_PROCEDURE_ORGAN_REPLACE)
			if(!active_surgery.checked_for_necessity)
				if(organic_mode)
					say("Beginning organic tissue restoration procedure.")
				else
					var/tier = get_organ_tier()
					say("Beginning cybernetic organ replacement procedure. Research tier: [tier].")
				active_surgery.checked_for_necessity = TRUE

			// Check organ slots for missing or failing organs
			var/static/list/organ_slots_for_replace
			if(!organ_slots_for_replace)
				organ_slots_for_replace = list(
					ORGAN_SLOT_HEART,
					ORGAN_SLOT_LUNGS,
					ORGAN_SLOT_LIVER,
					ORGAN_SLOT_STOMACH,
					ORGAN_SLOT_EYES,
					ORGAN_SLOT_EARS,
					ORGAN_SLOT_TONGUE,
				)

			for(var/slot in organ_slots_for_replace)
				var/obj/item/organ/existing = patient.get_organ_slot(slot)
				var/needs_replacement = FALSE
				if(!existing)
					needs_replacement = TRUE
				else if((existing.organ_flags & ORGAN_FAILING) && !(existing.organ_flags & ORGAN_ROBOTIC))
					needs_replacement = TRUE
				if(!needs_replacement)
					continue

				if(organic_mode)
					var/organ_type = get_organic_organ_for_slot(slot)
					if(!organ_type)
						continue
					var/needed = AUTODOC_SYNTHFLESH_COST_ORGAN * synthflesh_use_rate
					if(!check_synthflesh(needed))
						say("WARNING: Insufficient synthflesh for organic restoration. Skipping [slot].")
						continue
					if(existing)
						say("Removing failing [existing.name].")
						existing.Remove(patient)
						qdel(existing)
					consume_synthflesh(needed)
					var/obj/item/organ/new_organ = new organ_type()
					say("Implanting organic [new_organ.name].")
					new_organ.Insert(patient, TRUE)
				else
					var/organ_tier = get_organ_tier()
					var/organ_type = get_organ_for_slot(slot, organ_tier)
					if(!organ_type)
						continue
					var/list/cost = get_organ_material_cost(organ_tier)
					if(!check_materials(cost))
						say("WARNING: Insufficient materials for cybernetic organ fabrication. Skipping [slot].")
						continue
					if(existing)
						say("Removing failing [existing.name].")
						existing.Remove(patient)
						qdel(existing)
					var/obj/item/organ/new_organ = new organ_type()
					consume_materials(cost, new_organ.name)
					say("Implanting [new_organ.name].")
					new_organ.Insert(patient, TRUE)

				loop_in_time(6 SECONDS)
				return

			// All organs processed
			if(organic_mode)
				say("Organic tissue restoration complete.")
			else
				say("Cybernetic organ replacement complete.")
			handle_completed_surgery()
			return

		if(AUTODOC_PROCEDURE_LIMB_PROSTHETIC)
			if(!active_surgery.checked_for_necessity)
				if(organic_mode)
					say("Beginning organic limb regeneration procedure.")
				else
					say("Beginning prosthetic limb attachment procedure.")
				active_surgery.checked_for_necessity = TRUE
			// Lazy-init prosthetic limb map
			var/static/list/limb_map
			if(!limb_map)
				limb_map = list()
				limb_map[BODY_ZONE_L_ARM] = /obj/item/bodypart/arm/left/robot
				limb_map[BODY_ZONE_R_ARM] = /obj/item/bodypart/arm/right/robot
				limb_map[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/robot
				limb_map[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/robot
			// Replace missing limbs one at a time
			for(var/zone in limb_map)
				if(!patient.get_bodypart(zone))
					if(organic_mode)
						var/needed = AUTODOC_SYNTHFLESH_COST_LIMB * synthflesh_use_rate
						if(!check_synthflesh(needed))
							say("WARNING: Insufficient synthflesh for organic limb regeneration. Skipping [zone].")
							continue
						var/limb_type = get_organic_limb_for_zone(zone, patient)
						if(!limb_type)
							say("WARNING: No organic limb template available for [zone]. Skipping.")
							continue
						consume_synthflesh(needed)
						var/obj/item/bodypart/new_limb = new limb_type()
						say("Regenerating [new_limb.name].")
						new_limb.try_attach_limb(patient, TRUE)
					else
						// Check material costs
						var/list/cost = get_limb_material_cost()
						if(!check_materials(cost))
							say("WARNING: Insufficient materials for prosthetic limb fabrication. Skipping [zone].")
							continue
						var/limb_type = limb_map[zone]
						var/obj/item/bodypart/new_limb = new limb_type()
						consume_materials(cost, new_limb.name)
						say("Attaching [new_limb.name].")
						new_limb.try_attach_limb(patient, TRUE)
					loop_in_time(8 SECONDS)
					return
			// All limbs processed
			if(organic_mode)
				say("Organic limb regeneration complete.")
			else
				say("Prosthetic limb attachment complete.")
			patient.update_body()
			patient.updatehealth()
			handle_completed_surgery()
			return

		if(AUTODOC_PROCEDURE_EMBEDDED)
			if(!active_surgery.checked_for_necessity)
				say("Beginning foreign body removal procedure.")
				active_surgery.checked_for_necessity = TRUE
			if(!patient.has_embedded_objects())
				say("No foreign bodies detected.")
				handle_completed_surgery()
				return
			// Remove embedded objects one at a time
			for(var/obj/item/bodypart/bodypart as anything in patient.bodyparts)
				for(var/obj/item/embedded as anything in bodypart.embedded_objects)
					say("Extracting foreign object from [bodypart.plaintext_zone].")
					patient.remove_embedded_object(embedded)
					loop_in_time(5 SECONDS)
					return
			say("Foreign body removal complete.")
			handle_completed_surgery()
			return

		if(AUTODOC_PROCEDURE_DEHUSK)
			var/needed_synthflesh = AUTODOC_SYNTHFLESH_COST_DEHUSK * synthflesh_use_rate
			if(!check_synthflesh(needed_synthflesh))
				if(!active_surgery.warned_no_synthflesh)
					active_surgery.warned_no_synthflesh = TRUE
					say("WARNING: Husk restoration requires [round(needed_synthflesh)] units of synthflesh for tissue regeneration. \
						Currently [synthflesh_capacity > 0 ? "[round(stored_synthflesh)] units available" : "no synthflesh storage installed"]. Awaiting resupply.")
				loop_in_time(10 SECONDS)
				return
			if(!active_surgery.checked_for_necessity)
				say("Beginning husk restoration procedure. Regenerating damaged tissue.")
				active_surgery.checked_for_necessity = TRUE
			if(!HAS_TRAIT(patient, TRAIT_HUSK))
				handle_unnecessary_surgery()
				return
			say("Applying regenerative compound to restore tissue integrity.")
			consume_synthflesh(needed_synthflesh)
			patient.cure_husk("autodoc_malfunction")
			patient.cure_husk(BURN)
			patient.cure_husk(CHANGELING_DRAIN)
			// Fallback: remove all remaining husk sources
			if(HAS_TRAIT(patient, TRAIT_HUSK))
				for(var/source in GET_TRAIT_SOURCES(patient, TRAIT_HUSK))
					patient.cure_husk(source)
			say("Husk restoration complete. Tissue integrity restored.")
			handle_completed_surgery(8 SECONDS)
			return

		if(AUTODOC_PROCEDURE_REVIVE)
			attempt_revival()
			return

		if(AUTODOC_PROCEDURE_LARVA_REMOVAL)
			if(!active_surgery.checked_for_necessity)
				var/count = 0
				for(var/obj/item/organ/organ as anything in patient.organs)
					if(istype(organ, /obj/item/organ/body_egg))
						count++
				if(!count)
					handle_unnecessary_surgery()
					return
				say("Xenobiological organism detected. Initiating containment protocol. [count] parasite(s) found.")
				active_surgery.checked_for_necessity = TRUE
			// Find and remove one larva at a time
			var/obj/item/organ/body_egg/target_larva
			for(var/obj/item/organ/organ as anything in patient.organs)
				if(istype(organ, /obj/item/organ/body_egg))
					target_larva = organ
					break
			if(!target_larva)
				say("All xenobiological organisms extracted. Patient is clear.")
				handle_completed_surgery()
				return
			say("Extracting xenobiological organism.")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 30, FALSE)
			target_larva.Remove(patient)
			qdel(target_larva)
			loop_in_time(10 SECONDS)
			return

		if(AUTODOC_PROCEDURE_FLESHY_MASS)
			if(!active_surgery.checked_for_necessity)
				say("Anomalous cardiac organ detected. Initiating surgical removal.")
				active_surgery.checked_for_necessity = TRUE
			var/obj/item/organ/bad_heart = patient.get_organ_slot(ORGAN_SLOT_HEART)
			// Check if still anomalous
			var/still_bad = bad_heart && !(bad_heart.organ_flags & ORGAN_ROBOTIC) && istype(bad_heart, /obj/item/organ/heart/nightmare)
			if(!still_bad)
				handle_unnecessary_surgery()
				return
			say("Excising anomalous cardiac mass.")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 30, FALSE)
			bad_heart.Remove(patient)
			qdel(bad_heart)
			// Install replacement based on current mode
			if(organic_mode)
				var/needed = AUTODOC_SYNTHFLESH_COST_ORGAN * synthflesh_use_rate
				if(check_synthflesh(needed))
					consume_synthflesh(needed)
					var/obj/item/organ/new_heart = new /obj/item/organ/heart()
					new_heart.Insert(patient, TRUE)
					say("Organic heart implanted successfully.")
				else
					say("WARNING: Insufficient synthflesh for organic cardiac replacement. Anomalous mass removed but no replacement installed.")
			else
				var/organ_tier = get_organ_tier()
				var/heart_type = get_organ_for_slot(ORGAN_SLOT_HEART, organ_tier)
				if(heart_type && consume_materials(get_organ_material_cost(organ_tier), "cybernetic heart"))
					var/obj/item/organ/new_heart = new heart_type()
					new_heart.Insert(patient, TRUE)
					say("Implanting [new_heart.name].")
				else
					say("WARNING: Insufficient materials for cardiac replacement. Anomalous mass removed but no replacement installed.")
			say("Anomalous cardiac removal procedure complete.")
			handle_completed_surgery(8 SECONDS)
			return

	// Unknown procedure type
	handle_unnecessary_surgery()

/// Attempts to revive a dead patient via defibrillation and medication.
/// Step 0: Initial check and heal remaining damage
/// Step 1: Charge (defib_charge.ogg) -> 3s delay
/// Step 2: Zap (defib_zap.ogg) -> 2s delay
/// Step 3: Result (success/fail sound)
/obj/machinery/autodoc/proc/attempt_revival()
	var/mob/living/carbon/human/patient = occupant
	if(!patient)
		return

	if(!active_surgery.checked_for_necessity)
		say("Initiating patient revival protocol.")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
		active_surgery.checked_for_necessity = TRUE
		revival_step = 0

	// If patient is already alive, revival is unnecessary
	if(patient.stat != DEAD)
		say("Patient vital signs detected. Revival unnecessary.")
		revival_mode = FALSE
		revival_step = 0
		handle_completed_surgery()
		return

	switch(revival_step)
		// Step 0: Wait for all damage to be fully healed
		if(0)
			if(patient.get_brute_loss() > 0 || patient.get_fire_loss() > 0 || patient.get_tox_loss() > 0 || patient.get_oxy_loss() > 0)
				// Ensure continuous healers are active and boosted
				if(!heal_brute && patient.get_brute_loss() > 0)
					heal_brute = 5
				if(!heal_burn && patient.get_fire_loss() > 0)
					heal_burn = 5
				if(!heal_toxin && patient.get_tox_loss() > 0)
					heal_toxin = 5
				if(!heal_oxy && patient.get_oxy_loss() > 0)
					heal_oxy = 10
				loop_in_time(3 SECONDS)
				return
			// All damage healed, proceed to charging
			say("All damage healed. Charging defibrillator.")
			playsound(loc, 'sound/machines/defib/defib_charge.ogg', 75, FALSE)
			revival_step = 1
			loop_in_time(3 SECONDS)
			return

		// Step 1: Charge complete, deliver shock
		if(1)
			say("Defibrillator charged. Delivering shock.")
			playsound(loc, 'sound/machines/defib/defib_zap.ogg', 75, TRUE, -1)
			revival_step = 2
			loop_in_time(2 SECONDS)
			return

		// Step 2: Evaluate result
		if(2)
			var/defib_result = patient.can_defib()

			if(defib_result & DEFIB_POSSIBLE)
				// Successful defibrillation
				patient.set_heartattack(FALSE)
				patient.grab_ghost(TRUE)
				patient.revive(NONE, 1, TRUE)
				patient.emote("gasp")
				playsound(loc, 'sound/machines/defib/defib_success.ogg', 50, FALSE)
				say("Defibrillation successful. Patient revived.")

				// Inject post-revival medication
				say("Administering post-revival medication: 10u Salbutamol, 5u Epinephrine.")
				patient.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10)
				patient.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)

				revival_mode = FALSE
				revival_step = 0
				handle_completed_surgery(5 SECONDS)
				return

			// Defibrillation failed - report reason
			var/fail_reason = "Unknown cause"
			if(defib_result & DEFIB_FAIL_SUICIDE)
				fail_reason = "Patient has committed suicide"
			else if(defib_result & DEFIB_FAIL_HUSK)
				fail_reason = "Patient body is husked"
			else if(defib_result & DEFIB_FAIL_TISSUE_DAMAGE)
				fail_reason = "Tissue damage exceeds revival threshold"
			else if(defib_result & DEFIB_FAIL_NO_HEART)
				fail_reason = "No heart detected"
			else if(defib_result & DEFIB_FAIL_FAILING_HEART)
				fail_reason = "Heart organ failure"
			else if(defib_result & DEFIB_FAIL_NO_BRAIN)
				fail_reason = "No brain detected"
			else if(defib_result & DEFIB_FAIL_FAILING_BRAIN)
				fail_reason = "Brain organ failure"
			else if(defib_result & DEFIB_FAIL_NO_INTELLIGENCE)
				fail_reason = "No neural activity detected"
			else if(defib_result & DEFIB_FAIL_BLACKLISTED)
				fail_reason = "Patient physiology incompatible with defibrillation"

			playsound(loc, 'sound/machines/defib/defib_failed.ogg', 50, FALSE)
			say("ALERT: Defibrillation failed. [fail_reason].")
			revival_mode = FALSE
			revival_step = 0
			surgery_list -= active_surgery
			active_surgery = null
			// Eject since revival failed
			do_eject(AUTODOC_NOTICE_DEATH)

/// Reports and ends the active surgery as unnecessary.
/obj/machinery/autodoc/proc/handle_unnecessary_surgery()
	say("Procedure deemed unnecessary. Skipping.")
	surgery_list -= active_surgery
	active_surgery = null
	loop_in_time(AUTODOC_UNNEEDED_DELAY)

/// Reports and ends the active surgery as completed.
/obj/machinery/autodoc/proc/handle_completed_surgery(time = 1 SECONDS)
	surgery_list -= active_surgery
	active_surgery = null
	loop_in_time(time)

/// Schedules the next surgery operation loop iteration.
/obj/machinery/autodoc/proc/loop_in_time(delay)
	if(!delay)
		CRASH("No delay provided for autodoc surgery step.")
	var/effective_multiplier = surgery_time_multiplier
	surgery_timer_id = addtimer(CALLBACK(src, PROC_REF(loop_surgery_operation)), delay * effective_multiplier, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/machinery/autodoc/examine(mob/living/user)
	. = ..()
	if(permanently_broken)
		. += span_danger("The machine is completely non-functional. It must be destroyed and replaced.")
		if(occupant)
			. += span_danger("Someone is trapped inside!")
		return
	if(malfunctioning)
		. += span_danger("CRITICAL MALFUNCTION! The machine is sparking and smoking violently!")
		if(occupant)
			. += span_danger("[occupant] is trapped inside and being burned alive!")
		return
	if(!occupant)
		return
	if(!ishuman(occupant))
		return
	if(active_surgery)
		. += span_warning("Surgical procedures are in progress.")
	if(revival_mode)
		. += span_danger("Emergency revival protocol is active!")
	. += span_notice("It contains: [occupant].")
	if(release_notice)
		. += span_notice("Release notifications are turned on.")
	else
		. += span_notice("Release notifications are turned off.")
	var/tier = get_organ_tier()
	. += span_notice("Cybernetic organ tier: [tier] ([tier == 3 ? "upgraded" : (tier == 2 ? "standard" : "basic")]).")
	if(has_silo_connection())
		. += span_notice("Connected to ore silo for material resources.")
	else
		. += span_warning("No ore silo connection — organ and limb fabrication unavailable.")
	. += span_notice("Interference detection range: [interference_range] tiles.")
	if(blood_capacity > 0 && blood_capacity < INFINITY)
		. += span_notice("Blood storage: [round(stored_blood)]/[blood_capacity] units ready.[raw_blood > 0 ? " [round(raw_blood)] units processing." : ""]")
	else if(blood_capacity <= 0)
		. += span_warning("No blood storage system — blood transfusion unavailable. Install a large beaker.")
	. += span_notice("Operating mode: [organic_mode ? "Organic tissue restoration (synthflesh)" : "Cybernetic augmentation (silo materials)"].")
	if(synthflesh_capacity > 0 && synthflesh_capacity < INFINITY)
		. += span_notice("Synthflesh storage: [round(stored_synthflesh)]/[synthflesh_capacity] units.")
	else if(synthflesh_capacity <= 0)
		. += span_warning("No synthflesh storage — organic restoration unavailable. Install a second beaker.")

/// Advanced autodoc variant — sealed military-grade unit.
/// Always installs T3 cybernetic organs. Has no internal components and cannot be disassembled.
/// When destroyed, simply breaks without dropping parts. Faster and more efficient than a fully upgraded standard autodoc.
/obj/machinery/autodoc/fast
	name = "\improper advanced autodoc medical system"
	desc = "A state-of-the-art automated surgery machine with integrated military-grade components. \
		Significantly faster and more efficient than standard models, with built-in Tier 3 cybernetic fabrication. \
		Its sealed casing cannot be opened or disassembled."
	surgery_time_multiplier = 0.25
	heal_rate_modifier = 3
	material_efficiency = 0.3
	circuit = null
	obj_flags = parent_type::obj_flags | NO_DEBRIS_AFTER_DECONSTRUCTION

/obj/machinery/autodoc/fast/Initialize(mapload)
	. = ..()
	// Advanced variant has no internal components — clear any defaults
	component_parts = null
	// Since circuit = null, apply_default_parts is never called, so RefreshParts() never runs.
	// We must set component-dependent values explicitly here.
	surgery_time_multiplier = 0.25
	heal_rate_modifier = 3
	material_efficiency = 0.3
	blood_capacity = INFINITY
	stored_blood = INFINITY
	blood_transform_rate = INFINITY
	// Advanced variant has unlimited synthflesh
	synthflesh_capacity = INFINITY
	stored_synthflesh = INFINITY
	synthflesh_use_rate = 0.4

/obj/machinery/autodoc/fast/RefreshParts()
	. = ..() // Must call parent
	// Override all stats back to fixed values — no component scaling
	surgery_time_multiplier = 0.25
	heal_rate_modifier = 3
	material_efficiency = 0.3
	// Advanced autodoc has unlimited blood and synthflesh supply
	blood_capacity = INFINITY
	stored_blood = INFINITY
	blood_transform_rate = INFINITY
	synthflesh_capacity = INFINITY
	stored_synthflesh = INFINITY
	synthflesh_use_rate = 0.4

/obj/machinery/autodoc/fast/get_organ_tier()
	return 3 // Always T3 cybernetics regardless of research

/obj/machinery/autodoc/fast/check_materials(list/cost)
	return TRUE // Advanced autodoc requires no materials from silo

/obj/machinery/autodoc/fast/consume_materials(list/cost, item_name = "component")
	return TRUE // Advanced autodoc requires no materials from silo

/obj/machinery/autodoc/fast/insert_blood_pack(obj/item/reagent_containers/blood/pack, mob/user)
	to_chat(user, span_warning("The advanced autodoc has its own internal blood synthesis system and does not accept external blood packs."))
	return

/obj/machinery/autodoc/fast/screwdriver_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("The advanced autodoc's casing is hermetically sealed and cannot be opened."))
	return ITEM_INTERACT_BLOCKING

/obj/machinery/autodoc/fast/crowbar_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("The advanced autodoc's casing is hermetically sealed and cannot be pried open."))
	return ITEM_INTERACT_BLOCKING

/obj/machinery/autodoc/fast/insert_synthflesh(obj/item/reagent_containers/container, mob/user)
	to_chat(user, span_warning("The advanced autodoc has its own internal synthflesh synthesis system and does not require external replenishment."))
	return

/////////////////////////////////////////////////////////////
// TGUI Interface
/////////////////////////////////////////////////////////////

/obj/machinery/autodoc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Autodoc", name)
		ui.open()

/obj/machinery/autodoc/ui_data()
	var/list/data = list()
	data["hasOccupant"] = !!occupant
	data["isOperating"] = is_active()
	data["automaticMode"] = automatic_mode
	data["releaseNotice"] = release_notice
	data["revivalMode"] = revival_mode

	// Machine status
	data["siloConnected"] = has_silo_connection()
	data["researchTier"] = get_organ_tier()
	data["malfunctioning"] = malfunctioning
	data["permanentlyBroken"] = permanently_broken
	data["interferenceRange"] = interference_range
	data["healRateModifier"] = heal_rate_modifier
	data["materialEfficiency"] = material_efficiency
	data["surgerySpeed"] = surgery_time_multiplier
	// Blood storage
	data["storedBlood"] = round(stored_blood)
	data["rawBlood"] = round(raw_blood)
	data["bloodCapacity"] = blood_capacity
	// Synthflesh storage
	data["storedSynthflesh"] = round(stored_synthflesh)
	data["synthfleshCapacity"] = synthflesh_capacity
	data["organicMode"] = organic_mode
	data["synthfleshUseRate"] = synthflesh_use_rate

	if(occupant)
		var/mob/living/carbon/human/patient = occupant

		// Compile wound details
		var/list/wound_list = list()
		for(var/datum/wound/wound in patient.all_wounds)
			var/wound_location = "Unknown"
			if(wound.limb)
				wound_location = wound.limb.plaintext_zone
			wound_list += list(list(
				"name" = wound.name,
				"location" = wound_location,
			))

		// Check for missing or failing organs
		var/list/missing_organs_list = list()
		var/list/failing_organs_list = list()
		var/static/list/organ_slot_names
		if(!organ_slot_names)
			organ_slot_names = list()
			organ_slot_names[ORGAN_SLOT_HEART] = "Heart"
			organ_slot_names[ORGAN_SLOT_LUNGS] = "Lungs"
			organ_slot_names[ORGAN_SLOT_LIVER] = "Liver"
			organ_slot_names[ORGAN_SLOT_STOMACH] = "Stomach"
			organ_slot_names[ORGAN_SLOT_EYES] = "Eyes"
			organ_slot_names[ORGAN_SLOT_EARS] = "Ears"
			organ_slot_names[ORGAN_SLOT_TONGUE] = "Tongue"
		for(var/slot in organ_slot_names)
			var/obj/item/organ/existing = patient.get_organ_slot(slot)
			if(!existing)
				missing_organs_list += organ_slot_names[slot]
			else if((existing.organ_flags & ORGAN_FAILING) && !(existing.organ_flags & ORGAN_ROBOTIC))
				failing_organs_list += organ_slot_names[slot]

		// Check for missing limbs
		var/list/missing_limbs_list = list()
		var/static/list/limb_zone_names
		if(!limb_zone_names)
			limb_zone_names = list()
			limb_zone_names[BODY_ZONE_L_ARM] = "Left Arm"
			limb_zone_names[BODY_ZONE_R_ARM] = "Right Arm"
			limb_zone_names[BODY_ZONE_L_LEG] = "Left Leg"
			limb_zone_names[BODY_ZONE_R_LEG] = "Right Leg"
		for(var/zone in limb_zone_names)
			if(!patient.get_bodypart(zone))
				missing_limbs_list += limb_zone_names[zone]

		data["occupant"] = list(
			"name" = patient.name,
			"stat" = patient.stat,
			"health" = patient.health,
			"maxHealth" = patient.maxHealth,
			"bruteLoss" = patient.get_brute_loss(),
			"fireLoss" = patient.get_fire_loss(),
			"toxLoss" = patient.get_tox_loss(),
			"oxyLoss" = patient.get_oxy_loss(),
			"bloodVolume" = patient.blood_volume,
			"bloodVolumeNormal" = BLOOD_VOLUME_NORMAL,
			"hasWounds" = length(patient.all_wounds) > 0,
			"woundCount" = length(patient.all_wounds),
			"wounds" = wound_list,
			"hasEmbedded" = patient.has_embedded_objects(),
			"missingOrgans" = missing_organs_list,
			"failingOrgans" = failing_organs_list,
			"missingLimbs" = missing_limbs_list,
		)

	// Surgery queue
	var/list/queue = list()
	for(var/datum/autodoc_surgery/surgery in surgery_list)
		queue += list(list(
			"name" = surgery.procedure_name,
			"type" = surgery.procedure_type,
		))
	data["surgeryQueue"] = queue

	// Active continuous procedures
	data["activeProcs"] = list()
	if(heal_brute)
		data["activeProcs"] += list(list("name" = "Trauma Repair", "type" = AUTODOC_PROCEDURE_BRUTE))
	if(heal_burn)
		data["activeProcs"] += list(list("name" = "Burn Treatment", "type" = AUTODOC_PROCEDURE_BURN))
	if(heal_toxin)
		data["activeProcs"] += list(list("name" = "Toxin Chelation", "type" = AUTODOC_PROCEDURE_TOXIN))
	if(heal_oxy)
		data["activeProcs"] += list(list("name" = "Respiratory Therapy", "type" = AUTODOC_PROCEDURE_OXY))
	if(filtering)
		data["activeProcs"] += list(list("name" = "Blood Dialysis", "type" = AUTODOC_PROCEDURE_DIALYSIS))
	if(blood_transfer)
		data["activeProcs"] += list(list("name" = "Blood Transfusion", "type" = AUTODOC_PROCEDURE_BLOOD))
	if(active_surgery)
		data["activeSurgery"] = active_surgery.procedure_name

	// Available manual procedures
	var/list/available = list()
	if(occupant && !is_active() && !automatic_mode)
		var/list/existing_types = list()
		for(var/datum/autodoc_surgery/surgery in surgery_list)
			existing_types += surgery.procedure_type
		var/static/list/all_procedure_defs
		if(!all_procedure_defs)
			all_procedure_defs = list()
			all_procedure_defs += list(list("name" = "Trauma Repair", "type" = AUTODOC_PROCEDURE_BRUTE))
			all_procedure_defs += list(list("name" = "Burn Treatment", "type" = AUTODOC_PROCEDURE_BURN))
			all_procedure_defs += list(list("name" = "Toxin Chelation", "type" = AUTODOC_PROCEDURE_TOXIN))
			all_procedure_defs += list(list("name" = "Respiratory Therapy", "type" = AUTODOC_PROCEDURE_OXY))
			all_procedure_defs += list(list("name" = "Blood Dialysis", "type" = AUTODOC_PROCEDURE_DIALYSIS))
			all_procedure_defs += list(list("name" = "Blood Transfusion", "type" = AUTODOC_PROCEDURE_BLOOD))
			all_procedure_defs += list(list("name" = "Wound Treatment", "type" = AUTODOC_PROCEDURE_WOUNDS))
			all_procedure_defs += list(list("name" = "Organ Restoration", "type" = AUTODOC_PROCEDURE_ORGAN_DAMAGE))
			all_procedure_defs += list(list("name" = "Foreign Body Removal", "type" = AUTODOC_PROCEDURE_EMBEDDED))
			all_procedure_defs += list(list("name" = "Cybernetic Organ Implantation", "type" = AUTODOC_PROCEDURE_ORGAN_REPLACE))
			all_procedure_defs += list(list("name" = "Prosthetic Limb Attachment", "type" = AUTODOC_PROCEDURE_LIMB_PROSTHETIC))
			all_procedure_defs += list(list("name" = "Husk Restoration", "type" = AUTODOC_PROCEDURE_DEHUSK))
			all_procedure_defs += list(list("name" = "Patient Revival", "type" = AUTODOC_PROCEDURE_REVIVE))
			all_procedure_defs += list(list("name" = "Xenomorph Larva Extraction", "type" = AUTODOC_PROCEDURE_LARVA_REMOVAL))
			all_procedure_defs += list(list("name" = "Anomalous Heart Removal", "type" = AUTODOC_PROCEDURE_FLESHY_MASS))
		for(var/list/proc_data in all_procedure_defs)
			if(!(proc_data["type"] in existing_types))
				available += list(proc_data)
	data["availableProcedures"] = available
	data["isFastUnit"] = istype(src, /obj/machinery/autodoc/fast)

	return data

/obj/machinery/autodoc/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_mode")
			if(is_active() || malfunctioning || permanently_broken)
				return
			automatic_mode = !automatic_mode
			if(!automatic_mode && autostart_timer_id)
				deltimer(autostart_timer_id)
				autostart_timer_id = null
				say("Automatic mode disengaged. Awaiting manual input.")
			if(automatic_mode && occupant)
				say("Automatic mode engaged. Initializing procedures.")
				surgery_list = generate_surgery_list(occupant)
				autostart_timer_id = addtimer(CALLBACK(src, PROC_REF(auto_start)), 2 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
			. = TRUE

		if("toggle_notice")
			release_notice = !release_notice
			. = TRUE

		if("start_surgery")
			if(occupant && !malfunctioning && !permanently_broken)
				begin_surgery_operation()
			. = TRUE

		if("eject")
			try_ejecting(usr)
			. = TRUE

		if("clear_queue")
			if(!is_active())
				surgery_list = list()
			. = TRUE

		if("add_procedure")
			if(is_active() || automatic_mode)
				return
			var/procedure_type = text2num(params["type"])
			if(!procedure_type)
				return
			for(var/datum/autodoc_surgery/existing in surgery_list)
				if(existing.procedure_type == procedure_type)
					return
			var/procedure_name = params["name"] || "Unknown"
			surgery_list += new /datum/autodoc_surgery(procedure_type, procedure_name)
			. = TRUE

		if("remove_procedure")
			if(is_active())
				return
			var/procedure_type = text2num(params["type"])
			if(!procedure_type)
				return
			for(var/datum/autodoc_surgery/existing in surgery_list)
				if(existing.procedure_type == procedure_type)
					surgery_list -= existing
					break
			. = TRUE

		if("rescan")
			if(occupant && !is_active())
				surgery_list = generate_surgery_list(occupant)
				playsound(loc, 'sound/machines/ping.ogg', 25, TRUE)
				say("Re-scanning patient. [length(surgery_list)] procedures identified.")
			. = TRUE

		if("eject_blood")
			eject_blood_packs()
			. = TRUE

		if("toggle_organic_mode")
			if(malfunctioning || permanently_broken)
				return
			organic_mode = !organic_mode
			if(organic_mode)
				say("Switching to organic tissue restoration mode. Synthflesh required for organ and limb procedures.")
			else
				say("Switching to cybernetic augmentation mode. Ore silo required for organ and limb procedures.")
			if(occupant && !is_active())
				surgery_list = generate_surgery_list(occupant)
				say("Surgery list updated for new operation mode.")
			. = TRUE
