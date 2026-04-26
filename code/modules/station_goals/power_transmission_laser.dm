/**
 * # Power Transmission Laser Station Goal
 *
 * Station goal requiring the crew to build a PTL and sell a certain amount of power.
 */

/datum/station_goal/transmission_laser
	name = "Power Transmission Laser"
	var/credits_target = 5000

/datum/station_goal/transmission_laser/get_report()
	return {"<b>Construction of a Power Transmission Laser</b><br>
	Central Command requires additional revenue from power sales in your sector.
	You are hereby instructed to construct a Power Transmission Laser and earn at least [credits_target] credits by selling electrical power.
	<br><br>
	PTL and Laser Terminal components are now available for cargo delivery.
	<br>
	-Nanotrasen Energy Division"}

/datum/station_goal/transmission_laser/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/power/transmission_laser/ptl in GLOB.ptl_lasers)
		if(ptl.total_earnings >= credits_target && is_station_level(ptl.z))
			return TRUE
	return FALSE

/datum/station_goal/transmission_laser/on_report()
	var/datum/supply_pack/engineering/transmission_laser/laser_pack = SSshuttle.supply_packs[/datum/supply_pack/engineering/transmission_laser]
	laser_pack.order_flags |= ORDER_SPECIAL_ENABLED
	var/datum/supply_pack/engineering/laser_terminal/terminal_pack = SSshuttle.supply_packs[/datum/supply_pack/engineering/laser_terminal]
	terminal_pack.order_flags |= ORDER_SPECIAL_ENABLED