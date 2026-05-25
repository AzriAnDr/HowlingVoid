/obj/item/knife/hotknife
	name = "thousand degree knife"
	icon = 'icons/modular_ert/pizza/hotknife.dmi'
	icon_state = "hotknife"
	inhand_icon_state = "hotknife"
	desc = "Once known as Lightbringer, this sword has been demoted to a simple pizza cutting knife... It may still have its fire attack powers."
	righthand_file = 'icons/modular_ert/pizza/righthand.dmi'
	lefthand_file = 'icons/modular_ert/pizza/lefthand.dmi'

	/// How many fire stacks to apply on attack
	var/fire_stacks = 4

/obj/item/knife/hotknife/attack(mob/living/victim, mob/living/attacker, params)
	victim.adjust_fire_stacks(fire_stacks)
	victim.ignite_mob()
	return ..()
