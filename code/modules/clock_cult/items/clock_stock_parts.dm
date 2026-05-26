/obj/item/stock_parts/power_store/cell/clock
	name = "Wound Power Cell"
	desc = "A bronze colored power cell. Is that a winding crank on the side?"
	color = rgb(190, 135, 0)

/obj/item/stock_parts/power_store/cell/clock/Initialize(mapload, override_maxcharge)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	UnregisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED)
	START_PROCESSING(SSfastprocess, src)

/obj/item/stock_parts/power_store/cell/clock/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/stock_parts/power_store/cell/clock/process(seconds_per_tick)
	charge = GLOB.clock_power
	maxcharge = GLOB.max_clock_power

/obj/item/stock_parts/power_store/cell/clock/use(used, force)
	if(!..() || istype(loc, /obj/machinery/power/apc) || GLOB.clock_power < used)
		return FALSE
	SSblackbox.record_feedback("tally", "cell_used", 1, type)
	GLOB.clock_power = max(GLOB.clock_power - used, 0)
	return TRUE

/obj/item/stock_parts/power_store/cell/clock/percent()
	if(!GLOB.max_clock_power)
		return 0
	return 100 * GLOB.clock_power / GLOB.max_clock_power

/obj/item/stock_parts/power_store/cell/clock/give(amount)
	return FALSE

/obj/item/stock_parts/scanning_module/triphasic/clock
	name = "Ticking Scanning Module"
	desc = "A bronze colored scanning module, you hear a faint ticking from inside."
	color = rgb(190, 135, 0)

/datum/stock_part/scanning_module/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/scanning_module/triphasic/clock

/obj/item/stock_parts/capacitor/quadratic/clock
	name = "Clicking Capacitor"
	desc = "A bronze colored capacitor with a slow clicking within."
	color = rgb(190, 135, 0)

/datum/stock_part/capacitor/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/capacitor/quadratic/clock

/obj/item/stock_parts/matter_bin/bluespace/clock
	name = "Glowing Matter Bin"
	desc = "It has a faint glow emitting from within."
	color = rgb(190, 135, 0)

/datum/stock_part/matter_bin/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/matter_bin/bluespace/clock

/obj/item/stock_parts/servo/femto/clock
	name = "Powered Manipulator"
	desc = "Changes the energy flow around an object to manipulate it."
	color = rgb(190, 135, 0)

/datum/stock_part/servo/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/servo/femto/clock

/obj/item/storage/box/clockwork_stock_parts
	name = "clockwork stock parts pack"
	desc = "A small cache of bronze machinery components."

/obj/item/storage/box/clockwork_stock_parts/PopulateContents()
	new /obj/item/stock_parts/scanning_module/triphasic/clock(src)
	new /obj/item/stock_parts/capacitor/quadratic/clock(src)
	new /obj/item/stock_parts/matter_bin/bluespace/clock(src)
	new /obj/item/stock_parts/servo/femto/clock(src)
