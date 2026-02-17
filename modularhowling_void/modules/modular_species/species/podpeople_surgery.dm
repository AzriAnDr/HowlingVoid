/proc/hv_is_podweak_human(mob/living/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	var/datum/species/species = human_target.dna?.species
	if(!species)
		return FALSE
	return istype(species, /datum/species/pod) || (species.id in list(SPECIES_PODPERSON_WEAK, SPECIES_PODPERSON))

/proc/hv_get_podweak_from_operation_target(atom/movable/operating_on)
	if(isliving(operating_on) && hv_is_podweak_human(operating_on))
		return operating_on
	if(isbodypart(operating_on))
		var/obj/item/bodypart/limb = operating_on
		if(hv_is_podweak_human(limb.owner))
			return limb.owner
	return null

/proc/hv_get_podweak_operation_typepaths()
	return list(
		/datum/surgery_operation/limb/incise_skin/podweak,
		/datum/surgery_operation/limb/retract_skin/podweak,
		/datum/surgery_operation/limb/drill_bones/podweak,
		/datum/surgery_operation/limb/incise_organs/podweak,
		/datum/surgery_operation/limb/close_skin/podweak,
		/datum/surgery_operation/limb/clamp_bleeders/podweak,
		/datum/surgery_operation/limb/unclamp_bleeders/podweak,
		/datum/surgery_operation/basic/tend_wounds/podweak,
		/datum/surgery_operation/limb/saw_bones/podweak,
		/datum/surgery_operation/limb/repair_dislocation/podweak,
		/datum/surgery_operation/limb/repair_hairline/podweak,
		/datum/surgery_operation/limb/reset_compound/podweak,
		/datum/surgery_operation/limb/repair_compound/podweak,
		/datum/surgery_operation/limb/prepare_cranium_repair/podweak,
		/datum/surgery_operation/limb/repair_cranium/podweak,
		/datum/surgery_operation/limb/repair_puncture/podweak,
		/datum/surgery_operation/limb/seal_veins/podweak,
		/datum/surgery_operation/limb/amputate/podweak,
		/datum/surgery_operation/limb/replace_limb/podweak,
		/datum/surgery_operation/limb/organ_manipulation/internal/podweak,
		/datum/surgery_operation/limb/organ_manipulation/external/podweak,
		/datum/surgery_operation/organ/repair/lobectomy/podweak,
		/datum/surgery_operation/organ/repair/hepatectomy/podweak,
		/datum/surgery_operation/organ/repair/coronary_bypass/podweak,
		/datum/surgery_operation/organ/repair/gastrectomy/podweak,
		/datum/surgery_operation/organ/repair/ears/podweak,
		/datum/surgery_operation/organ/repair/eyes/podweak,
		/datum/surgery_operation/organ/repair/brain/podweak,
	)

/proc/hv_is_podweak_operation(datum/surgery_operation/operation)
	if(!istype(operation))
		return FALSE
	return operation.type in hv_get_podweak_operation_typepaths()

/proc/hv_is_pod_surgery_tool(obj/item/tool)
	if(!tool)
		return FALSE
	return istype(tool, /obj/item/secateurs) \
		|| istype(tool, /obj/item/geneshears) \
		|| istype(tool, /obj/item/cultivator) \
		|| istype(tool, /obj/item/reagent_containers/spray/weedspray) \
		|| istype(tool, /obj/item/reagent_containers/spray/pestspray) \
		|| istype(tool, /obj/item/hatchet) \
		|| istype(tool, /obj/item/stack/medical/bone_gel) \
		|| istype(tool, /obj/item/stack/sticky_tape) \
		|| istype(tool, /obj/item/organ) \
		|| istype(tool, /obj/item/bodypart) \
		|| (tool.tool_behaviour in list(TOOL_DRILL, TOOL_BONESET, TOOL_HEMOSTAT, TOOL_WIRECUTTER, TOOL_SCREWDRIVER, TOOL_CROWBAR))

/datum/species/pod/podweak/proc/adjust_operations_for_podweak_target(atom/movable/operating_on, mob/living/surgeon, list/possible_operations)
	SIGNAL_HANDLER

	if(!hv_get_podweak_from_operation_target(operating_on))
		return

	possible_operations.Cut()
	possible_operations += hv_get_podweak_operation_typepaths()

/datum/surgery_operation/limb/incise_skin/podweak
	name = "split bark"
	rnd_name = "Bark Separation"
	desc = "Open the podperson's bark layers to expose inner plant tissue."
	rnd_desc = "Open the podperson's bark layers to expose inner plant tissue."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
		/obj/item/hatchet = 1.35,
	)

/datum/surgery_operation/limb/incise_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/incise_skin/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/secateurs))
		return TRUE
	if(istype(tool, /obj/item/geneshears))
		return TRUE
	return ..()

/datum/surgery_operation/limb/retract_skin/podweak
	name = "separate bark layers"
	rnd_name = "Bark Retraction"
	desc = "Separate plant tissue layers to access inner structures."
	rnd_desc = "Separate plant tissue layers to access inner structures."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
		/obj/item/hatchet = 1.35,
	)

/datum/surgery_operation/limb/retract_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/retract_skin/podweak/get_default_radial_image()
	return image(/obj/item/secateurs)

/datum/surgery_operation/limb/close_skin/podweak
	name = "bind bark seam"
	rnd_name = "Bark Binding"
	desc = "Seal and bind damaged bark after plant-tissue work."
	rnd_desc = "Seal and bind damaged bark after plant-tissue work."
	implements = list(
		/obj/item/reagent_containers/spray/weedspray = 0.9,
		/obj/item/reagent_containers/spray/pestspray = 1,
	)

/datum/surgery_operation/limb/close_skin/podweak/get_any_tool()
	return "Botanical spray"

/datum/surgery_operation/limb/close_skin/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/reagent_containers/spray/weedspray))
		return TRUE
	if(istype(tool, /obj/item/reagent_containers/spray/pestspray))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/close_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/close_skin/podweak/get_default_radial_image()
	return image(/obj/item/reagent_containers/spray/weedspray)

/datum/surgery_operation/limb/clamp_bleeders/podweak
	name = "stabilize sap channels"
	rnd_name = "Sap Channel Stabilization"
	desc = "Stabilize leaking sap channels in exposed pod tissue."
	rnd_desc = "Stabilize leaking sap channels in exposed pod tissue."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/clamp_bleeders/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/unclamp_bleeders/podweak
	name = "restore sap flow"
	rnd_name = "Sap Flow Recovery"
	desc = "Restore circulation through stabilized sap channels."
	rnd_desc = "Restore circulation through stabilized sap channels."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/unclamp_bleeders/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/basic/tend_wounds/podweak
	name = "tend plant tissue"
	rnd_name = "Plant Tissue Tending"
	desc = "Treat bruised and burned plant tissue using botanical instruments."
	rnd_desc = "Treat bruised and burned plant tissue using botanical instruments."
	implements = list(
		/obj/item/reagent_containers/spray/weedspray = 0.9,
		/obj/item/reagent_containers/spray/pestspray = 1,
	)

/datum/surgery_operation/basic/tend_wounds/podweak/snowflake_check_availability(mob/living/patient, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(patient)

/datum/surgery_operation/limb/saw_bones/podweak
	name = "prune hardened stem"
	rnd_name = "Stem Pruning"
	desc = "Cut through hardened pod tissue to access deeper structures."
	rnd_desc = "Cut through hardened pod tissue to access deeper structures."
	implements = list(
		/obj/item/hatchet = 1,
		/obj/item/secateurs = 2.85,
	)

/datum/surgery_operation/limb/saw_bones/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/drill_bones/podweak
	name = "auger stem core"
	rnd_name = "Stem Core Augering"
	desc = "Create a controlled opening through dense stem core tissue."
	rnd_desc = "Create a controlled opening through dense stem core tissue."
	implements = list(
		TOOL_DRILL = 1,
		TOOL_SCREWDRIVER = 4,
	)

/datum/surgery_operation/limb/drill_bones/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/incise_organs/podweak
	name = "split inner cambium"
	rnd_name = "Cambium Separation"
	desc = "Open inner cambium layers to access internal pod organs."
	rnd_desc = "Open inner cambium layers to access internal pod organs."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/incise_organs/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_dislocation/podweak
	name = "reset twisted stem"
	rnd_name = "Stem Realignment"
	desc = "Realign a twisted pod stem structure."
	rnd_desc = "Realign a twisted pod stem structure."
	implements = list(
		TOOL_BONESET = 1,
		TOOL_CROWBAR = 2,
	)

/datum/surgery_operation/limb/repair_dislocation/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_hairline/podweak
	name = "mend fine stem crack"
	rnd_name = "Fine Fiber Repair"
	desc = "Repair a minor crack in structural plant fibers."
	rnd_desc = "Repair a minor crack in structural plant fibers."
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_hairline/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/reset_compound/podweak
	name = "set shattered branch"
	rnd_name = "Branch Reset"
	desc = "Reset a severe branch fracture before final repair."
	rnd_desc = "Reset a severe branch fracture before final repair."
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/sticky_tape/surgical = 1.66,
		/obj/item/stack/sticky_tape/super = 2.5,
		/obj/item/stack/sticky_tape = 5,
	)

/datum/surgery_operation/limb/reset_compound/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_compound/podweak
	name = "repair shattered branch"
	rnd_name = "Branch Reconstruction"
	desc = "Reconstruct a reset branch fracture using graft-safe methods."
	rnd_desc = "Reconstruct a reset branch fracture using graft-safe methods."
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_compound/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/prepare_cranium_repair/podweak
	name = "clear crown debris"
	rnd_name = "Crown Debridement"
	desc = "Remove debris from cranial plant tissue before repair."
	rnd_desc = "Remove debris from cranial plant tissue before repair."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 2.5,
		TOOL_SCREWDRIVER = 2.5,
	)

/datum/surgery_operation/limb/prepare_cranium_repair/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_cranium/podweak
	name = "repair crown structure"
	rnd_name = "Crown Reconstruction"
	desc = "Repair severe structural damage in the pod crown."
	rnd_desc = "Repair severe structural damage in the pod crown."
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_cranium/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_puncture/podweak
	name = "realign sap channels"
	rnd_name = "Sap Channel Realignment"
	desc = "Realign ruptured sap channels prior to sealing."
	rnd_desc = "Realign ruptured sap channels prior to sealing."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/repair_puncture/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/seal_veins/podweak
	name = "seal sap channels"
	rnd_name = "Sap Channel Sealing"
	desc = "Seal stabilized sap channels to stop fluid loss."
	rnd_desc = "Seal stabilized sap channels to stop fluid loss."

/datum/surgery_operation/limb/seal_veins/podweak/get_any_tool()
	return "Botanical spray"

/datum/surgery_operation/limb/seal_veins/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/reagent_containers/spray/weedspray))
		return TRUE
	if(istype(tool, /obj/item/reagent_containers/spray/pestspray))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/seal_veins/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/amputate/podweak
	name = "prune limb"
	rnd_name = "Limb Pruning"
	desc = "Remove an irreparably damaged pod limb."
	rnd_desc = "Remove an irreparably damaged pod limb."
	implements = list(
		/obj/item/hatchet = 0.9,
		/obj/item/secateurs = 1.2,
	)

/datum/surgery_operation/limb/amputate/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/replace_limb/podweak
	name = "graft prosthetic limb"
	rnd_name = "Limb Grafting"
	desc = "Attach a replacement limb as a grafted prosthetic."
	rnd_desc = "Attach a replacement limb as a grafted prosthetic."

/datum/surgery_operation/limb/replace_limb/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/organ_manipulation/internal/podweak
	name = "internal tissue manipulation"
	rnd_name = "Internal Tissue Manipulation"
	desc = "Manipulate internal pod organs and tissue modules."
	rnd_desc = "Manipulate internal pod organs and tissue modules."
	remove_implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/limb/organ_manipulation/internal/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/organ_manipulation/external/podweak
	name = "external tissue manipulation"
	rnd_name = "External Tissue Manipulation"
	desc = "Manipulate external pod features such as tails and frills."
	rnd_desc = "Manipulate external pod features such as tails and frills."
	remove_implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/limb/organ_manipulation/external/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/organ/repair/lobectomy/podweak
	name = "trim damaged respiratory frond"
	rnd_name = "Respiratory Frond Trimming"
	desc = "Repair damaged respiratory tissue by trimming a bad frond."
	rnd_desc = "Repair damaged respiratory tissue by trimming a bad frond."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/lobectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/hepatectomy/podweak
	name = "remove damaged filtration tissue"
	rnd_name = "Filtration Tissue Excision"
	desc = "Excise badly damaged filtration tissue from the organ."
	rnd_desc = "Excise badly damaged filtration tissue from the organ."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/hepatectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/coronary_bypass/podweak
	name = "graft sap bypass"
	rnd_name = "Sap Bypass Graft"
	desc = "Create a bypass to restore flow around damaged heart tissue."
	rnd_desc = "Create a bypass to restore flow around damaged heart tissue."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/coronary_bypass/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/gastrectomy/podweak
	name = "prune damaged digestion tissue"
	rnd_name = "Digestive Tissue Pruning"
	desc = "Remove damaged digestive tissue to restore function."
	rnd_desc = "Remove damaged digestive tissue to restore function."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/gastrectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/ears/podweak
	name = "sensory frond surgery"
	rnd_name = "Sensory Frond Repair"
	desc = "Repair pod auditory/sensory frond structures."
	rnd_desc = "Repair pod auditory/sensory frond structures."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/ears/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/eyes/podweak
	name = "oculus bloom surgery"
	rnd_name = "Oculus Bloom Repair"
	desc = "Repair visual bloom tissue to restore sight."
	rnd_desc = "Repair visual bloom tissue to restore sight."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/eyes/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/brain/podweak
	name = "crown core surgery"
	rnd_name = "Crown Core Repair"
	desc = "Repair high-level cognition tissue in the crown core."
	rnd_desc = "Repair high-level cognition tissue in the crown core."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/brain/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)
