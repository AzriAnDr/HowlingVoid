// This spell exists mainly for debugging purposes, and also to show how casting works
/datum/action/cooldown/spell/basic_heal
	name = "Lesser Heal"
	desc = "Heals a small amount of brute and burn damage to the caster."

	sound = 'sound/effects/magic/staff_healing.ogg'
	school = SCHOOL_RESTORATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_HUMAN

	invocation = "Victus sano!"
	invocation_type = INVOCATION_WHISPER

	/// Amount of brute to heal to the spell caster on cast
	var/brute_to_heal = 10
	/// Amount of burn to heal to the spell caster on cast
	var/burn_to_heal = 10

/datum/action/cooldown/spell/basic_heal/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/basic_heal/cast(mob/living/cast_on)
	. = ..()
	cast_on.visible_message(
		span_warning("A wreath of gentle light passes over [cast_on]!"),
		span_notice("You wreath yourself in healing light!"),
	)
	var/need_mob_update = FALSE
	need_mob_update += cast_on.adjust_brute_loss(-brute_to_heal, updating_health = FALSE)
	need_mob_update += cast_on.adjust_fire_loss(-burn_to_heal, updating_health = FALSE)
	if(need_mob_update)
		cast_on.updatehealth()

/datum/action/cooldown/spell/stimpack
	name = "Magic Stimpack"
	desc = "This spell magically injects stimulants straight into your blood. Won't work on species with no reagent reactions!"
	school = "transmutation"
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS
	spell_requirements = NONE
	invocation = "STIMULUS CHEQ'US"
	invocation_type = INVOCATION_SHOUT

/datum/action/cooldown/spell/stimpack/cast(mob/living/cast_on)
	. = ..()
	cast_on.balloon_alert(cast_on, "speeding up")
	cast_on.SetKnockdown(0)
	cast_on.set_stamina_loss(0)
	cast_on.set_resting(FALSE)
	cast_on.reagents.add_reagent(/datum/reagent/medicine/stimulants, 3)
	return TRUE
