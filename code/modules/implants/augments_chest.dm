// for readability's sake, define here to match the healthscan() proc's use of it
// if someone updates that upstream, fix that here too, wouldja?

/obj/item/organ/cyberimp/chest/scanner
	name = "internal health analyzer"
	desc = "An advanced health analyzer implant, designed to directly interface with a host's body and relay scan information to the brain on command."
	slot = ORGAN_SLOT_SCANNER
	icon = 'icons/implants/chest.dmi'
	icon_state = "internal_HA"
	actions_types = list(/datum/action/item_action/organ_action/use/internal_analyzer)
	w_class = WEIGHT_CLASS_SMALL
	/// Whether or not we have the chemical scan feature
	var/has_chem_scan = TRUE
	var/advanced_scan_allowed = TRUE
	/// TGUI health analyzer interface used by the implant.
	var/obj/item/healthanalyzer/internal/ui_scanner

/obj/item/organ/cyberimp/chest/scanner/Initialize(mapload)
	. = ..()
	ui_scanner = new(src)
	ui_scanner.internal_analyzer = WEAKREF(src)

/obj/item/organ/cyberimp/chest/scanner/Destroy()
	QDEL_NULL(ui_scanner)
	return ..()

/obj/item/organ/cyberimp/chest/scanner/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	ui_scanner?.clear_current_scan()
	return ..()

/datum/action/item_action/organ_action/use/internal_analyzer
	desc = "LMB: Health scan. RMB: Chemical scan. Ctrl-LMB: Toggle chat/window output. Requires implanted analyzer to not be failing due to EMPs or other causes. Does not provide treatment assistance."

/datum/action/item_action/organ_action/use/internal_analyzer/do_effect(trigger_flags)
	var/obj/item/organ/cyberimp/chest/scanner/our_scanner = target
	if(!our_scanner || !isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	if(our_scanner.organ_flags & ORGAN_FAILING)
		to_chat(living_owner, span_warning("Your health analyzer relays an error! It can't interface with your body in its current condition!"))
		return FALSE
	if(!our_scanner.ui_scanner)
		our_scanner.ui_scanner = new(our_scanner)
		our_scanner.ui_scanner.internal_analyzer = WEAKREF(our_scanner)

	our_scanner.ui_scanner.mode = our_scanner.advanced_scan_allowed ? SCANNER_VERBOSE : SCANNER_CONDENSED
	our_scanner.ui_scanner.advanced = our_scanner.advanced_scan_allowed
	if(trigger_flags & TRIGGER_CTRL_ACTION)
		our_scanner.ui_scanner.use_scan_window = !our_scanner.ui_scanner.use_scan_window
		if(!our_scanner.ui_scanner.use_scan_window)
			our_scanner.ui_scanner.clear_current_scan()
		to_chat(living_owner, span_notice("Your internal health analyzer now sends readouts to [our_scanner.ui_scanner.use_scan_window ? "a scan window" : "chat"]."))
		return TRUE

	if(our_scanner.has_chem_scan && (trigger_flags & TRIGGER_SECONDARY_ACTION))
		our_scanner.ui_scanner.show_scan_results(living_owner, living_owner, "chemicals")
		return TRUE

	our_scanner.ui_scanner.show_scan_results(living_owner, living_owner, "health")
	return TRUE


/obj/item/organ/cyberimp/chest/scanner/lite
	actions_types = list(/datum/action/item_action/organ_action/use/internal_analyzer/lite)
	has_chem_scan = FALSE
	advanced_scan_allowed = FALSE

/datum/action/item_action/organ_action/use/internal_analyzer/lite
	desc = "LMB: Health scan. Ctrl-LMB: Toggle chat/window output. Requires implanted analyzer to not be failing due to EMPs or other causes. Does not provide treatment assistance."

/obj/item/organ/cyberimp/chest/opticalcamo
	name = "optical camo implant"
	desc = "An implant that bends light around the host's body, rendering them nearly invisible when activated."
	icon = 'icons/implants/chest.dmi'
	icon_state = "opticalcamo"
	slot = ORGAN_SLOT_SPINE
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/on = FALSE /// Whether the implant is active or not
	var/bumpoff = TRUE /// Controls if getting 'bumped' or doing disallowed actions (shooting, hitting, etc) disables the implant
	var/stealth_alpha = 45 /// Controls the alpha of the use
	var/poison_amount = 3 /// The amount of poison you get from each emp_act

/obj/item/organ/cyberimp/chest/opticalcamo/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/opticalcamo/on_mob_remove(mob/living/carbon/organ_owner)
	if(on)
		deactivate(silent = TRUE)
	return ..()

/// Activates or deactivates the implant
/obj/item/organ/cyberimp/chest/opticalcamo/proc/toggle(silent = FALSE)
	if(on)
		deactivate()
	else
		activate()

/obj/item/organ/cyberimp/chest/opticalcamo/proc/activate(silent = FALSE)
	if(on)
		return
	if(organ_flags & ORGAN_FAILING)
		if(!silent)
			to_chat(owner, span_warning("Your optical camo seems to be broken!"))
		return
	if(bumpoff)
		RegisterSignal(owner, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(owner, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(owner, 
		list(
			COMSIG_MOB_ITEM_ATTACK,
			COMSIG_ATOM_ATTACKBY,
			COMSIG_ATOM_ATTACK_HAND,
			COMSIG_ATOM_HITBY,
			COMSIG_ATOM_HULK_ATTACK,
			COMSIG_ATOM_ATTACK_PAW,
			COMSIG_CARBON_CUFF_ATTEMPTED,
			COMSIG_MOB_FIRED_GUN
		), PROC_REF(unstealth)
	)
	animate(owner, alpha = stealth_alpha, time = 15 SECONDS)
	on = TRUE
	if(!silent)
		to_chat(owner, span_notice("You turn your optical camo on."))

/obj/item/organ/cyberimp/chest/opticalcamo/proc/deactivate(silent = FALSE)
	if(!on)
		return
	if(bumpoff)
		UnregisterSignal(owner, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_CARBON_CUFF_ATTEMPTED,
		COMSIG_MOB_FIRED_GUN
	))
	animate(owner, alpha = 255, time = 1.5 SECONDS)
	on = FALSE
	if(!silent)
		to_chat(owner, span_notice("You turn your optical camo off."))

/// Handles removing their stealth when bump-off is triggered
/obj/item/organ/cyberimp/chest/opticalcamo/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(owner, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	deactivate()

/obj/item/organ/cyberimp/chest/opticalcamo/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/organ/cyberimp/chest/opticalcamo/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(!projectile.is_hostile_projectile())
		return
	unstealth(source)

/obj/item/organ/cyberimp/chest/opticalcamo/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.reagents.add_reagent(/datum/reagent/drug/saturnx, poison_amount / severity)
	owner.adjust_confusion(rand(8 SECONDS, 11 SECONDS))
	to_chat(owner, span_warning("Your skin tingles, and the room feels like it's spinning!"))
	unstealth()
