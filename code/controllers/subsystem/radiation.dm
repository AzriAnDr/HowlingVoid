SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	ss_flags = SS_BACKGROUND | SS_NO_INIT

	wait = 0.5 SECONDS

	/// A list of radiation sources (/datum/radiation_pulse_information) that have yet to process.
	/// Do not interact with this directly, use `radiation_pulse` instead.
	var/list/datum/radiation_pulse_information/processing = list()

/datum/controller/subsystem/radiation/fire(resumed)
	while (processing.len)
		var/datum/radiation_pulse_information/pulse_information = processing[1]

		var/datum/weakref/source_ref = pulse_information.source_ref
		var/atom/source = source_ref.resolve()
		if (isnull(source))
			processing.Cut(1, 2)
			continue

		pulse(source, pulse_information)

		if (MC_TICK_CHECK)
			return

		processing.Cut(1, 2)

/datum/controller/subsystem/radiation/stat_entry(msg)
	msg = "Pulses:[processing.len]"
	return ..()

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	var/list/cached_rad_insulations = list()
	var/list/cached_turfs_to_process = pulse_information.turfs_to_process
	var/turfs_iterated = 0
	for (var/turf/turf_to_irradiate as anything in cached_turfs_to_process)
		turfs_iterated += 1
		var/list/atom/targets_to_process = list(turf_to_irradiate)
		for(var/atom/movable/movable_target in turf_to_irradiate)
			targets_to_process += movable_target

		for (var/atom/target as anything in targets_to_process)
			var/can_receive_irradiation = can_irradiate_basic(target)
			var/can_receive_surface_contamination = pulse_information.apply_surface_contamination && target.can_receive_radioactive_contamination()
			if (!can_receive_irradiation && !can_receive_surface_contamination)
				continue

			var/current_insulation = 1
			var/turf/target_turf = get_turf(target)

			for (var/turf/turf_in_between in get_line(source, target) - get_turf(source))
				var/insulation = cached_rad_insulations[turf_in_between]
				if(turf_in_between == target_turf)
					insulation = turf_in_between.rad_insulation
					for (var/atom/on_turf as anything in turf_in_between.contents)
						if(on_turf == target)
							continue
						insulation *= on_turf.get_effective_rad_insulation(source, target, turf_in_between)
				else if (isnull(insulation))
					insulation = turf_in_between.rad_insulation
					for (var/atom/on_turf as anything in turf_in_between.contents)
						insulation *= on_turf.get_effective_rad_insulation(source, target, turf_in_between)
					cached_rad_insulations[turf_in_between] = insulation

				current_insulation *= insulation

				if (current_insulation <= pulse_information.threshold)
					break

			SEND_SIGNAL(target, COMSIG_IN_RANGE_OF_IRRADIATION, pulse_information, current_insulation)

			// Check a second time, because of TRAIT_BYPASS_EARLY_IRRADIATED_CHECK
			if (can_receive_irradiation && HAS_TRAIT(target, TRAIT_IRRADIATED))
				can_receive_irradiation = FALSE

			if (!can_receive_irradiation && !can_receive_surface_contamination)
				continue

			if (current_insulation <= pulse_information.threshold)
				continue

			/// Perceived chance of target getting irradiated.
			var/perceived_chance
			/// Intensity variable which will describe the radiation pulse.
			/// It is used by perceived intensity, which diminishes over range. The chance of the target getting irradiated is determined by perceived_intensity.
			/// Intensity is calculated so that the chance of getting irradiated at half of the max range is the same as the chance parameter.
			var/intensity
			/// Diminishes over range. Used by perceived chance, which is the actual chance to get irradiated.
			var/perceived_intensity

			if(pulse_information.chance < 100) // Prevents log(0) runtime if chance is 100%
				intensity = -log(1 - pulse_information.chance / 100) * (1 + pulse_information.max_range / 2) ** 2
				perceived_intensity = intensity * INVERSE((1 + get_dist_euclidean(source, target)) ** 2) // Diminishes over range.
				perceived_intensity *= (current_insulation - pulse_information.threshold) * INVERSE(1 - pulse_information.threshold) // Perceived intensity decreases as objects that absorb radiation block its trajectory.
				perceived_chance = 100 * (1 - NUM_E ** -perceived_intensity)
			else
				perceived_chance = 100

			if(can_receive_irradiation)
				var/irradiation_result = SEND_SIGNAL(target, COMSIG_IN_THRESHOLD_OF_IRRADIATION, pulse_information)
				if (irradiation_result & CANCEL_IRRADIATION)
					can_receive_irradiation = FALSE

				if (can_receive_irradiation && pulse_information.minimum_exposure_time && !(irradiation_result & SKIP_MINIMUM_EXPOSURE_TIME_CHECK))
					target.AddComponent(/datum/component/radiation_countdown, pulse_information.minimum_exposure_time)
					can_receive_irradiation = FALSE

			if (!prob(perceived_chance))
				continue

			var/surface_contamination = 0
			if(pulse_information.apply_surface_contamination)
				surface_contamination = get_surface_contamination_from_pulse(pulse_information, perceived_chance, current_insulation, source, target)

			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				if(surface_contamination > 0)
					contaminate_worn_items(human_target, surface_contamination, source)

				var/radiation_exposure_factor = get_radiation_exposure_factor(human_target)
				if(can_receive_irradiation && !prob(radiation_exposure_factor * 100))
					can_receive_irradiation = FALSE

				if(can_receive_surface_contamination)
					surface_contamination = round(surface_contamination * radiation_exposure_factor, 0.1)
					if(surface_contamination < RAD_CONTAMINATION_MIN_ACTIVITY)
						can_receive_surface_contamination = FALSE

			var/applied_radiation = FALSE
			if(can_receive_irradiation)
				applied_radiation = irradiate_after_basic_checks(target, surface_contamination, source, TRUE)
			else if(can_receive_surface_contamination && surface_contamination > 0)
				applied_radiation = target.add_radioactive_contamination(surface_contamination, source)

			if (applied_radiation)
				target.investigate_log("was irradiated by [source].", INVESTIGATE_RADIATION)

		if(MC_TICK_CHECK)
			break

	cached_turfs_to_process.Cut(1, turfs_iterated + 1)

/// Will attempt to irradiate the given target, limited through IC means, such as radiation protected clothing.
/datum/controller/subsystem/radiation/proc/irradiate(atom/target, surface_contamination = RAD_CONTAMINATION_DIRECT_EXPOSURE, atom/source = null)
	if (!can_irradiate_basic(target))
		return FALSE

	return irradiate_after_basic_checks(target, surface_contamination, source)

/datum/controller/subsystem/radiation/proc/irradiate_after_basic_checks(atom/target, surface_contamination = RAD_CONTAMINATION_DIRECT_EXPOSURE, atom/source = null, human_protection_checked = FALSE)
	PRIVATE_PROC(TRUE)

	if(ishuman(target) && !human_protection_checked)
		var/mob/living/carbon/human/human_target = target
		if(surface_contamination > 0)
			contaminate_worn_items(human_target, surface_contamination, source)

		var/radiation_exposure_factor = get_radiation_exposure_factor(human_target)
		if(radiation_exposure_factor <= 0)
			return FALSE

		surface_contamination = round(surface_contamination * radiation_exposure_factor, 0.1)

	if(surface_contamination > 0)
		target.add_radioactive_contamination(surface_contamination, source ? source : target)

	target.AddComponent(/datum/component/irradiated)
	return TRUE

/datum/controller/subsystem/radiation/proc/contaminate_worn_items(mob/living/carbon/human/human, surface_contamination, atom/source = null)
	if(surface_contamination < RAD_CONTAMINATION_MIN_ACTIVITY)
		return

	var/item_contamination = surface_contamination * RAD_CONTAMINATION_WORN_ITEM_MULTIPLIER
	if(item_contamination < RAD_CONTAMINATION_MIN_ACTIVITY)
		return

	for(var/obj/item/carried_item as anything in human.get_equipped_items(INCLUDE_HELD|INCLUDE_ABSTRACT))
		carried_item.add_radioactive_contamination(item_contamination, source ? source : human)

/datum/controller/subsystem/radiation/proc/get_radiation_exposure_factor(mob/living/carbon/human/human)
	if(wearing_rad_protected_clothing(human))
		return 0

	return clamp((100 - human.getarmor(null, RAD)) * 0.01, 0, 1)

/datum/controller/subsystem/radiation/proc/get_surface_contamination_from_pulse(datum/radiation_pulse_information/pulse_information, perceived_chance, current_insulation, atom/source, atom/target)
	var/insulation_factor = 1
	if(pulse_information.threshold < 1)
		insulation_factor = clamp((current_insulation - pulse_information.threshold) / (1 - pulse_information.threshold), 0, 1)

	var/contamination_multiplier = isnull(pulse_information.surface_contamination_multiplier) ? 1 : pulse_information.surface_contamination_multiplier
	if(source == target)
		contamination_multiplier *= RAD_CONTAMINATION_SOURCE_SELF_MULTIPLIER

	var/contamination = round(perceived_chance * RAD_CONTAMINATION_PULSE_MULTIPLIER * insulation_factor * contamination_multiplier, 0.1)
	if(pulse_information.surface_contamination_multiplier == RAD_CONTAMINATION_WEAK_SOURCE_MULTIPLIER)
		var/datum/component/radioactive_contamination/current_contamination = target.GetComponent(/datum/component/radioactive_contamination)
		var/current_activity = current_contamination ? current_contamination.activity : 0
		if(current_activity >= RAD_CONTAMINATION_WEAK_SOURCE_CAP)
			return 0
		contamination = min(contamination, RAD_CONTAMINATION_WEAK_SOURCE_CAP - current_activity)

	return clamp(contamination, 0, RAD_CONTAMINATION_MAX_ACTIVITY)

/// Returns whether or not the target can be irradiated by any means.
/// Does not check for clothing.
/datum/controller/subsystem/radiation/proc/can_irradiate_basic(atom/target)
	if (!CAN_IRRADIATE(target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_IRRADIATED) && !HAS_TRAIT(target, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_RADIMMUNE))
		return FALSE

	return TRUE

/// Returns whether or not the human is covered head to toe in rad-protected clothing.
/datum/controller/subsystem/radiation/proc/wearing_rad_protected_clothing(mob/living/carbon/human/human)
	for (var/obj/item/bodypart/limb as anything in human.get_bodyparts())
		var/protected = FALSE

		for (var/obj/item/clothing as anything in human.get_clothing_on_part(limb))
			if (HAS_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING))
				protected = TRUE
				break

		if (!protected)
			return FALSE

	return TRUE
