/datum/species/proc/howling_get_unarmed_damage_profile(mob/living/carbon/human/user, obj/item/bodypart/attacking_bodypart)
	if(!istype(user) || !istype(attacking_bodypart, /obj/item/bodypart/arm))
		return null

	var/static/list/roundstart_unarmed_damage_profiles = list(
		"human" = list("male" = list(5, 10), "female" = list(4, 8), "neuter" = list(3, 7), "plural" = list(3, 7)),
		"lizard" = list("male" = list(8, 14), "female" = list(7, 12), "neuter" = list(3, 9), "plural" = list(3, 9)),
		"felinid" = list("male" = list(4, 9), "female" = list(3, 7), "neuter" = list(1, 3), "plural" = list(1, 3)),
		"fly" = list("male" = list(4, 9), "female" = list(4, 8), "neuter" = list(2, 6), "plural" = list(2, 6)),
		"moth" = list("male" = list(4, 9), "female" = list(5, 9), "neuter" = list(3, 7), "plural" = list(3, 7)),
		"plasmaman" = list("male" = list(4, 8), "female" = list(4, 7), "neuter" = list(2, 5), "plural" = list(2, 5)),
		"ethereal" = list("male" = list(5, 11), "female" = list(5, 10), "neuter" = list(3, 8), "plural" = list(3, 8)),
		"snail" = list("male" = list(2, 6), "female" = list(2, 5), "neuter" = list(1, 3), "plural" = list(1, 3)),
		"mammal" = list("male" = list(6, 11), "female" = list(6, 10), "neuter" = list(4, 8), "plural" = list(4, 8)),
		"vulpkanin" = list("male" = list(6, 11), "female" = list(4, 9), "neuter" = list(1, 5), "plural" = list(1, 4)),
		"tajaran" = list("male" = list(6, 11), "female" = list(5, 9), "neuter" = list(1, 5), "plural" = list(1, 4)),
		"akula" = list("male" = list(7, 12), "female" = list(7, 11), "neuter" = list(5, 10), "plural" = list(5, 10)),
		"unathi" = list("male" = list(8, 14), "female" = list(7, 14), "neuter" = list(5, 12), "plural" = list(5, 12)),
		"skrell" = list("male" = list(4, 9), "female" = list(5, 9), "neuter" = list(3, 7), "plural" = list(3, 7)),
		"humanoid" = list("male" = list(5, 10), "female" = list(5, 10), "neuter" = list(3, 8), "plural" = list(3, 8)),
		"xeno" = list("male" = list(8, 13), "female" = list(8, 13), "neuter" = list(6, 11), "plural" = list(6, 11)),
		"slimeperson" = list("male" = list(4, 8), "female" = list(4, 7), "neuter" = list(2, 5), "plural" = list(2, 5)),
		"podweak" = list("male" = list(4, 9), "female" = list(4, 8), "neuter" = list(2, 6), "plural" = list(2, 6)),
		"dwarf" = list("male" = list(7, 12), "female" = list(7, 11), "neuter" = list(5, 10), "plural" = list(5, 10)),
		"synth" = list("male" = list(6, 12), "female" = list(6, 12), "neuter" = list(6, 12), "plural" = list(6, 12)),
		"vox" = list("male" = list(4, 9), "female" = list(3, 7), "neuter" = list(1, 5), "plural" = list(1, 4)),
		"aquatic" = list("male" = list(6, 12), "female" = list(6, 11), "neuter" = list(4, 9), "plural" = list(4, 9)),
		"insect" = list("male" = list(5, 10), "female" = list(5, 9), "neuter" = list(3, 7), "plural" = list(3, 7)),
		"insectoid" = list("male" = list(6, 12), "female" = list(6, 11), "neuter" = list(4, 9), "plural" = list(4, 9)),
		"ghoul" = list("male" = list(5, 11), "female" = list(5, 10), "neuter" = list(3, 8), "plural" = list(3, 8)),
		"teshari" = list("male" = list(3, 8), "female" = list(4, 8), "neuter" = list(2, 6), "plural" = list(2, 6)),
		"hemophage" = list("male" = list(8, 15), "female" = list(8, 15), "neuter" = list(5, 10), "plural" = list(5, 10)),
		"vox_primalis" = list("male" = list(6, 12), "female" = list(6, 11), "neuter" = list(4, 9), "plural" = list(4, 9)),
		"abductorweak" = list("male" = list(4, 9), "female" = list(4, 8), "neuter" = list(2, 6), "plural" = list(2, 6)),
		"golemweak" = list("male" = list(7, 12), "female" = list(7, 11), "neuter" = list(4, 9), "plural" = list(4, 9)),
		"dullahan" = list("male" = list(5, 10), "female" = list(5, 9), "neuter" = list(3, 7), "plural" = list(3, 7)),
		"kobold" = list("male" = list(3, 8), "female" = list(3, 7), "neuter" = list(1, 5), "plural" = list(1, 5)),
		"shadekin" = list("male" = list(6, 10), "female" = list(6, 10), "neuter" = list(4, 9), "plural" = list(4, 9)),
		"nabber" = list("male" = list(8, 15), "female" = list(8, 14), "neuter" = list(6, 12), "plural" = list(6, 12)),
	)

	var/list/gendered_profile = roundstart_unarmed_damage_profiles[id]
	if(!islist(gendered_profile))
		return null

	var/list/damage_profile = gendered_profile[user.gender]
	if(!islist(damage_profile))
		damage_profile = gendered_profile["neuter"]
	if(!islist(damage_profile))
		return null

	return damage_profile
