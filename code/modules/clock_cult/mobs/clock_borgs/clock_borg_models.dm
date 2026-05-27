/obj/item/robot_model
	var/list/clock_modules = list()
	var/list/clock_module_instances

/obj/item/robot_model/Destroy()
	QDEL_LIST(clock_module_instances)
	return ..()

/obj/item/robot_model/rebuild_modules()
	. = ..()
	var/mob/living/silicon/robot/cyborg = loc
	if(!istype(cyborg))
		return

	if(!cyborg.clockwork)
		QDEL_LIST(clock_module_instances)
		return

	if(!length(clock_modules))
		return

	if(isnull(clock_module_instances))
		clock_module_instances = list()
		for(var/module_path in clock_modules)
			clock_module_instances += new module_path(cyborg)

	for(var/obj/item/module as anything in clock_module_instances)
		add_module(module, FALSE, FALSE)

/obj/item/robot_model/medical
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clock_module/prosperity_prism,
		/obj/item/clock_module/vanguard,
	)

/obj/item/robot_model/engineering
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/tinkerers_cache,
		/obj/item/clock_module/stargazer,
		/obj/item/clockwork/replica_fabricator,
	)

/obj/item/robot_model/security
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clockwork/weapon/brass_spear,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/vanguard,
	)

/obj/item/robot_model/peacekeeper
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sigil_submission,
	)

/obj/item/robot_model/janitor
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/vanguard,
		/obj/item/clockwork/weapon/brass_spear,
	)

/obj/item/robot_model/clown
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clockwork/weapon/brass_battlehammer,
	)

/obj/item/robot_model/service
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clockwork/replica_fabricator,
	)

/obj/item/robot_model/miner
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/sentinels_compromise,
	)

/obj/item/robot_model/cargo
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/gun/ballistic/bow/clockwork,
		/obj/item/clock_module/stargazer,
	)
