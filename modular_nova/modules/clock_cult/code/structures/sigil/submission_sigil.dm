/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "A pulsing sigil that etches Ratvar's truth into the minds of those forced to stand upon it."
	clockwork_desc = "Converts a living prisoner to Ratvar after they remain on the sigil."
	icon_state = "sigilsubmission"
	effect_stand_time = 8 SECONDS
	idle_color = "#c4a85e"
	invocation_color = "#e7c983"
	pulse_color = "#f0e6a0"
	fail_color = "#806a30"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return FALSE
	if(affected_mob.stat == DEAD)
		return FALSE
	if(IS_CLOCK(affected_mob))
		return FALSE
	if(affected_mob.can_block_magic(MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_SYNTHETIC_ALLOWED))
		return FALSE
	if(!affected_mob.mind)
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/submission/apply_effects(mob/living/affected_mob)
	. = ..()
	if(!.)
		return FALSE

	var/datum/antagonist/clock_cultist/new_servant = new
	new_servant.give_slab = ishuman(affected_mob)
	affected_mob.mind.add_antag_datum(new_servant, GLOB.main_clock_cult)
	affected_mob.visible_message(span_brass("[affected_mob] stills as the ticking of hidden cogs fills the air."), span_bigbrass("The engine opens your eyes. You now serve Ratvar."))
	send_clock_message(null, span_bigbrass("[affected_mob] has submitted to Ratvar."), msg_ghosts = FALSE)
	dispel()
	return TRUE
