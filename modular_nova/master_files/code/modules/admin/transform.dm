// Stuff that helps the TGUI player panel transform section to work

GLOBAL_LIST_INIT(pp_transformables, list(
	list(
	name = "Common",
	color = "",
	types = list(
		list(
			name = "Human",
			key = /mob/living/carbon/human
			),
		list(
			name = "Monkey",
			key = /mob/living/carbon/human/species/monkey
			),
		list(
			name = "Cyborg",
			key = /mob/living/silicon/robot
			)
		)
	),
	list(
	name = "Xenomorph",
	color = "purple",
	types = list(
		list(
			name = "Larva",
			key = /mob/living/carbon/alien/larva/tgmc
			),
		list(
			name = "Runner",
			key = /mob/living/carbon/alien/adult/tgmc/runner
			),
		list(
			name = "Sentinel",
			key = /mob/living/carbon/alien/adult/tgmc/sentinel
			),
		list(
			name = "Defender",
			key = /mob/living/carbon/alien/adult/tgmc/defender
			),
		list(
			name = "Drone",
			key = /mob/living/carbon/alien/adult/tgmc/drone
			),
		list(
			name = "Spitter",
			key = /mob/living/carbon/alien/adult/tgmc/spitter
			),
		list(
			name = "Ravager",
			key = /mob/living/carbon/alien/adult/tgmc/ravager
			),
		list(
			name = "Crusher",
			key = /mob/living/carbon/alien/adult/tgmc/crusher
			),
		list(
			name = "Praetorian",
			key = /mob/living/carbon/alien/adult/tgmc/praetorian
			),
		list(
			name = "Queen",
			key = /mob/living/carbon/alien/adult/tgmc/queen
			)
		)
	),
	list(
	name = "Lavaland",
	color = "orange",
	types = list(
		list(
			name = "Goliath",
			key = /mob/living/basic/mining/goliath
			),
		list(
			name = "Legion",
			key = /mob/living/simple_animal/hostile/megafauna/legion/small
			),
		list(
			name = "Blood-Drunk Miner",
			key = /mob/living/basic/boss/blood_drunk_miner
			),
		list(
			name = "Gladiator",
			key = /mob/living/simple_animal/hostile/megafauna/gladiator
			),
		list(
			name = "Dragon",
			key = /mob/living/simple_animal/hostile/megafauna/dragon
			),
		list(
			name = "Legion Hivelord",
			key = /mob/living/simple_animal/hostile/asteroid/elite/legionnaire
			)
		)
	),
	list(
	name = "Cultist",
	color = "violet",
	types = list(
		list(
			name = "Shade",
			key = /mob/living/basic/shade
			),
		list(
			name = "Artificer",
			key = /mob/living/basic/construct/artificer
			),
		list(
			name = "Wraith",
			key = /mob/living/basic/construct/wraith
			),
		list(
			name = "Juggernaut",
			key = /mob/living/basic/construct/juggernaut
			)
		)
	)
))

// selected_mob: Mob to change
// newType: Path of new type e.g: /mob/living/carbon/alien/humanoid/drone
// newTypeName (optional): Name of the new type (used in logging): e.g: "Drone"
/datum/admins/proc/transformMob(mob/selected_mob, mob/adminMob, newType, newTypeName)
	if(!check_rights(R_SPAWN))
		return

	if(!ismob(selected_mob))
		to_chat(usr, "This can only be used on instances of type /mob.")
		return

	if (!newTypeName)
		newTypeName = newType

	log_admin("[key_name(usr)] transformed [key_name(selected_mob)] into a [newTypeName].")
	message_admins(span_adminnotice("[key_name_admin(usr)] transformed [key_name_admin(selected_mob)] into a [newTypeName]."))

	var/mob/newMob = selected_mob.change_mob_type(newType, delete_old_mob = TRUE)

	if (selected_mob == adminMob)
		adminMob = newMob
	addtimer(CALLBACK(newMob.mob_panel, PROC_REF(ui_interact), adminMob), 0.1 SECONDS)
