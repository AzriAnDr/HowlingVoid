/// Bonks the target.
/datum/smite/bonk
	name = "Bonk"

/datum/smite/bonk/effect(client/user, mob/living/target)
	. = ..()
	playsound(target, 'sound/effects/smites/bonk.ogg', 100, TRUE)
	target.AddElement(/datum/element/squish, 60 SECONDS)
	to_chat(target, span_class("warning big", "Bonk."))
