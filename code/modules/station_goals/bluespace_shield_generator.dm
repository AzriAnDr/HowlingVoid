/// Bluespace Shield Generator Goal
/// Objective: Accumulate 30% energy reserve in the bluespace shield generator

/datum/station_goal/bluespace_shield_generator
	name = "Bluespace Shield Generator"
	weight = 1
	required_crew = 10
	requires_space = FALSE

/datum/station_goal/bluespace_shield_generator/get_report()
	return list(
		"<blockquote>Central Command has detected unstable bluespace fluctuations within your sector.",
		"These anomalies pose a potential threat to station hull integrity and nearby infrastructure.",
		"",
		"To stabilize the region, you are ordered to deploy an experimental bluespace shield field generator and bring it online.",
		"",
		"<b>TECHNICAL REQUIREMENTS:</b>",
		"",
		"- The generator must reach at least thirty (30) percent of its total energy capacity.",
		"- Once charged to that threshold, the device will enter active bluespace stabilization mode.",
		"- While operational, the shield will improve station protection against external and anomalous threats.",
		"",
		"Minor spatial distortions may occur while charging. Personnel should avoid unnecessary proximity to the active unit.",
		"",
		"<b>MATERIAL SUPPORT:</b>",
		"",
		"- The circuit board and all required components are available through Cargo.",
		"- Additional materials may be requested through standard Central Command channels.",
		"",
		"Failure to meet these parameters may allow the local bluespace instability to worsen.</blockquote>",
	).Join("\n")

/datum/station_goal/bluespace_shield_generator/on_report()
	var/datum/supply_pack/engineering/bluespace_shield_generator/parts = SSshuttle.supply_packs[/datum/supply_pack/engineering/bluespace_shield_generator]
	parts.order_flags |= ORDER_SPECIAL_ENABLED

/datum/station_goal/bluespace_shield_generator/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/power/bluespace_shield_generator/gen as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/bluespace_shield_generator))
		if(gen.max_energy && (gen.current_energy / gen.max_energy >= 0.30))
			return TRUE
	return FALSE