/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10
	category = EVENT_CATEGORY_ENTITIES
	description = "A horde of mice arrives, and perhaps even the Rat King themselves."

/datum/round_event/mice_migration
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce(fake)
	var/list/cause = pick(
		list("en" = "space-winter", "ru" = "космической зимы"),
		list("en" = "budget-cuts", "ru" = "сокращения бюджета"),
		list("en" = "Ragnarok", "ru" = "Рагнарёка"),
		list("en" = "space being cold", "ru" = "космического холода"),
		list("en" = "\[REDACTED\]", "ru" = "\[УДАЛЕНО\]"),
		list("en" = "climate change", "ru" = "изменения климата"),
		list("en" = "bad luck", "ru" = "невезения"),
	)
	var/list/plural = pick(
		list("en" = "a number of", "ru" = "несколько"),
		list("en" = "a horde of", "ru" = "орда"),
		list("en" = "a pack of", "ru" = "стая"),
		list("en" = "a swarm of", "ru" = "рой"),
		list("en" = "a whoop of", "ru" = "целая толпа"),
		list("en" = "not more than [maximum_mice]", "ru" = "не более [maximum_mice]"),
	)
	var/list/name = pick(
		list("en" = "rodents", "ru" = "грызунов"),
		list("en" = "mice", "ru" = "мышей"),
		list("en" = "squeaking things", "ru" = "пищащих существ"),
		list("en" = "wire eating mammals", "ru" = "млекопитающих, жрущих провода"),
		list("en" = "\[REDACTED\]", "ru" = "\[УДАЛЕНО\]"),
		list("en" = "energy draining parasites", "ru" = "энерговысасывающих паразитов"),
	)
	var/list/movement = pick(
		list("en" = "migrated", "ru" = "переместились"),
		list("en" = "swarmed", "ru" = "нахлынули"),
		list("en" = "stampeded", "ru" = "ломанулись"),
		list("en" = "descended", "ru" = "спустились"),
	)
	var/list/location = pick(
		list("en" = "maintenance tunnels", "ru" = "техтоннели"),
		list("en" = "maintenance areas", "ru" = "технические зоны"),
		list("en" = "\[REDACTED\]", "ru" = "\[УДАЛЕНО\]"),
		list("en" = "place with all those juicy wires", "ru" = "место со всеми этими сочными проводами"),
	)

	priority_announce("Due to [cause["en"]], [plural["en"]] [name["en"]] have [movement["en"]] \
		into the [location["en"]].", "Migration Alert",
		'sound/mobs/non-humanoids/mouse/mousesqueek.ogg',
		text_ru = "Из-за [cause["ru"]] [plural["ru"]] [name["ru"]] [movement["ru"]] \
		в [location["ru"]].",
		title_ru = "Тревога миграции")

/datum/round_event/mice_migration/start()
	SSminor_mapping.trigger_migration(rand(minimum_mice, maximum_mice))
