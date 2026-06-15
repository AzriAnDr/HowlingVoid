/datum/scripture/create_structure/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "Summons an Anchoring Crystal to the station. Protect enough charged crystals to open the Ark."
	tip = "Anchor Reebe to this realm."
	button_icon_state = "Clockwork Obelisk"
	power_cost = 500
	invocation_time = 20 SECONDS
	invocation_text = list("Space shall fold...", "Time shall mold...", "Anchor us here...", "Engine is near!")
	summoned_structure = /obj/structure/destructible/clockwork/anchoring_crystal
	cogs_required = 5
	category = SPELLTYPE_STRUCTURES
	var/static/next_invocation_at = 0

/datum/scripture/create_structure/anchoring_crystal/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(world.time < next_invocation_at)
		to_chat(invoker, span_warning("The Ark will be stable enough to summon another crystal in [DisplayTimeText(next_invocation_at - world.time)]."))
		return FALSE

	if(GLOB.charged_anchoring_crystals >= ANCHORING_CRYSTALS_TO_SUMMON)
		to_chat(invoker, span_brass("Enough Anchoring Crystals are already charged. Focus on the Ark."))
		return FALSE

	var/area/checked_area = get_area(invoker)
	if(!(checked_area?.area_flags & VALID_TERRITORY) || !is_station_level(invoker.z))
		to_chat(invoker, span_warning("You cannot summon an Anchoring Crystal here!"))
		return FALSE

	return TRUE

/datum/scripture/create_structure/anchoring_crystal/invoke_success()
	. = ..()
	next_invocation_at = world.time + ANCHORING_CRYSTAL_COOLDOWN
