/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations and trouble expressing your ideas. \
		Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. \
		THIS IS NOT A LICENSE TO GRIEF."
	icon = FA_ICON_GRIN_TONGUE_WINK
	value = -8
	gain_text = span_userdanger("...")
	lose_text = span_notice("You feel in tune with the world again.")
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations, and may have trouble speaking."
	hardcore_value = 6
	mail_goodies = list(/obj/item/storage/pill_bottle/lsdpsych)
	/// Weakref to the trauma we give out
	var/datum/weakref/added_trama_ref

/datum/quirk/insanity/add(client/client_source)
	if(!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	// Setup our special RDS mild hallucination.
	// Not a unique subtype so not to plague subtypesof,
	// also as we inherit the names and values from our quirk.
	var/datum/brain_trauma/mild/hallucinations/added_trauma = new()
	added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	added_trauma.name = name
	added_trauma.desc = medical_record_text
	added_trauma.scan_desc = LOWER_TEXT(name)
	added_trauma.gain_text = null
	added_trauma.lose_text = null
	added_trauma.uncapped = client_source?.prefs?.read_preference(/datum/preference/toggle/rds_limit)

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)

/datum/quirk/insanity/post_add()
	var/rds_policy = get_policy("[type]") || "Please note that your [LOWER_TEXT(name)] does NOT give you any additional right to attack people or cause chaos."
	// I don't /think/ we'll need this, but for newbies who think "roleplay as insane" = "license to kill", it's probably a good thing to have.
	to_chat(quirk_holder, span_big(span_info(rds_policy)))

/datum/quirk/insanity/remove()
	QDEL_NULL(added_trama_ref)

/datum/quirk_constant_data/rds_limit
	associated_typepath = /datum/quirk/insanity
	customization_options = list(/datum/preference/toggle/rds_limit)


// BEGIN NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/insanity.dm
/datum/quirk/insanity
	mob_trait = TRAIT_INSANITY
	mail_goodies = list(/obj/item/storage/pill_bottle/lsdpsych/quirk)
	species_quirks = list(/datum/species/synthetic = /datum/quirk/insanity/synth)
	///The medication given when the quirk is added
	var/insanity_medication = /obj/item/storage/pill_bottle/lsdpsych/quirk

/datum/quirk/insanity/add_unique(client/client_source)
	give_item_to_holder_nova(
		insanity_medication,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "These will keep your brain stable until you can secure a supply of medication.",
		notify_player = TRUE,
	)

// Override of insanity quirk for synthetic humanoids
/datum/quirk/insanity/synth
	name = "Sensory Processing Fault"
	medical_record_text = "Patient is malfunctioning in a manner similar to Reality Dissociation Syndrome and experiences vivid hallucinations, and may have trouble speaking."
	mail_goodies = list(/obj/item/storage/box/flat/neuroware/mindbreaker)
	insanity_medication = /obj/item/storage/box/flat/neuroware/mindbreaker
	abstract_type = /datum/quirk/insanity/synth
// END NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/insanity.dm
