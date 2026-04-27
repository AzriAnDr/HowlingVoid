/**
 * Bluespace Harvester Station Goal
 *
 * Requires the crew to construct and operate a bluespace harvester to gather a certain amount of points.
 */

/datum/station_goal/bluespace_harvester
	name = "Bluespace Harvester"

/datum/station_goal/bluespace_harvester/get_report()
	return list(
		"<blockquote>Central Command has approved a field test for an experimental Bluespace Harvester.",
		"This machine reaches through bluespace into other dimensions and retrieves objects of scientific interest.",
		"",
		"Full-scale testing on the original research site is no longer possible, so your station has been selected as the replacement test platform.",
		"Construct the device over a wire node, bring it online, and push its harvest depth to forty-five thousand (45,000) total points.",
		"",
		"Be advised: the machine is highly experimental. At sufficient power levels it may behave unpredictably and require unscheduled maintenance.",
		"",
		"- Nanotrasen Science Directorate</blockquote>",
	).Join("\n")

/datum/station_goal/bluespace_harvester/on_report()
	var/datum/supply_pack/engineering/bluespace_harvester/parts = SSshuttle.supply_packs[/datum/supply_pack/engineering/bluespace_harvester]
	parts.order_flags |= ORDER_SPECIAL_ENABLED

/datum/station_goal/bluespace_harvester/check_completion()
	if(..())
		return TRUE
	var/goal = 45000
	var/highscore = 0
	for(var/obj/machinery/power/bluespace_tap/harvester as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/bluespace_tap))
		highscore = max(highscore, harvester.total_points)
	to_chat(world, "<b>Bluespace Harvester Highscore</b>: [highscore >= goal ? span_green("[highscore]") : span_red("[highscore]")]")
	if(highscore >= goal)
		return TRUE
	return FALSE