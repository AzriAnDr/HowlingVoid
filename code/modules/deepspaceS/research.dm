///// First we enstate a techweb so we can add the node. /////
//DS-2
/datum/techweb/deepspace
	id = "SYNDICATE"
	organization = "Conglomerate Syndicate"
	should_generate_points = TRUE

/datum/techweb/deepspace/New()
	. = ..()
	research_node_id(TECHWEB_NODE_OLDSTATION_SURGERY, TRUE, TRUE, FALSE)
	research_node_id(TECHWEB_NODE_DEEPSPACE, TRUE, TRUE, FALSE)
	SSresearch.techwebs += src

/datum/techweb_node/deepspace
	id = TECHWEB_NODE_DEEPSPACE
	display_name = "Syndicate Technology"
	description = "Tools used by Syndicate Employees."
	required_items_to_unlock = list(
		/obj/item/circuitboard/machine/ghostpad/syndicate,
		/obj/item/circuitboard/computer/ghostpad/syndicate,
		/obj/item/circuitboard/machine/powerator/syndicate
	)
	prereq_ids = list(TECHWEB_NODE_CONSTRUCTION)
	design_ids = list(
		"bountypad_syndicate",
		"bountyconsole_syndicate",
		"powerator_syndicate",
		"syndicate_firing_pin",
		"syndicate_headset",
		"expressconsole_syndicate",
		"protolathe_cybersun",
		"cybersun_encryption",
		"interdyne_encryption"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	hidden = TRUE


//production

/datum/design/deepspace_protolathe
	name = "Cybersun Branded Protolathe"
	desc = "The circuit board for a machine that can produce equipment in exchange for materials."
	id = "protolathe_cybersun"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/protolathe/deepspace
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/syndicate_expressconsole
	name = "Syndicate Supply Console"
	desc = "A specialized console, allowing for deepspace communication with a specialized gorlex drop pod railgun for precise and accurate \
		deliveries, no matter how remote they are located"
	id = "expressconsole_syndicate"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/computer/cargo/express/ghost/syndicate
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO


/datum/design/syndicate_bounty_pad
	name = "Syndicate Bounty Pad"
	desc = "The circuit board for a machine used to sell goods on a black market."
	id = "bountypad_syndicate"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/ghostpad/syndicate
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/syndicate_bounty_pad_console
	name = "Syndicate Bounty Pad Console"
	desc = "The circuit board for the computer used to control a bounty pad to sell goods on a black market."
	id = "bountyconsole_syndicate"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/computer/ghostpad/syndicate
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/syndicate_powerator
	name = "Syndicate Powerator"
	desc = "The circuit board for a machine that can sell power."
	id = "powerator_syndicate"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/powerator/syndicate
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO


/datum/design/syndicate_firing_pin
	name = "Syndicate Firing Pin"
	desc = "A Syndicate Implant restricted firing pin."
	id = "syndicate_firing_pin"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = SMALL_MATERIAL_AMOUNT * 6, /datum/material/diamond = SMALL_MATERIAL_AMOUNT * 6, /datum/material/uranium =SMALL_MATERIAL_AMOUNT * 2)
	build_path =/obj/item/firing_pin/implant/pindicate
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_FIRING_PINS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/syndicateciv_headset
	name = "Syndicate Headset"
	desc = "Standard issue headset for Syndicate employee."
	id = "syndicate_headset"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*1)
	build_path = /obj/item/radio/headset/syndicateciv
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/interdyne_key
	name = "Interdyne Encryption Key"
	desc = "Standard issue headset for Syndicate employees."
	id = "interdyne_encryption"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*1)
	build_path = /obj/item/encryptionkey/headset_syndicate/interdyne
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/cybersun_key
	name = "Cybersun Encryption Key"
	desc = "Standard issue key for syndicate covert operations."
	id = "cybersun_encryption"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*1)
	build_path = /obj/item/encryptionkey/headset_syndicate/cybersun
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

	//Making physical Server

/obj/item/circuitboard/machine/rdserver/deepspace
	name = "Suspicous R&D Server"
	build_path = /obj/machinery/rnd/server/deepspace

/obj/machinery/rnd/server/deepspace
	name = "\improper Suspicous R&D Server"
	circuit = /obj/item/circuitboard/machine/rdserver/deepspace
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/rnd/server/deepspace/Initialize(mapload)
	var/datum/techweb/deepspace_techweb = locate(/datum/techweb/deepspace) in SSresearch.techwebs
	stored_research = deepspace_techweb
	return ..()

/obj/machinery/rnd/server/deepspace/examine(mob/user)
	. = ..()
	. += span_notice("You can use <b>research notes</b> on this to generate research points.")

/obj/machinery/rnd/server/deepspace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/research_notes) && stored_research)
		var/obj/item/research_notes/research_notes = tool
		stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_notes.value))
		playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
		qdel(research_notes)
		return ITEM_INTERACT_SUCCESS

	return ..()


/obj/machinery/rnd/production/protolathe/deepspace
	name = "Cybersun Industries Protolathe"
	desc = "Converts raw materials into useful objects."
	circuit = /obj/item/circuitboard/machine/protolathe/deepspace
	stripe_color = "#a82a07"

/obj/item/circuitboard/machine/protolathe/deepspace
	name = "Cybersun Industries Protolathe"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/rnd/production/protolathe/deepspace




//Interdyne
/datum/techweb/dyne
	id = "INTERDYNE"
	organization = "Interdyne Pharmaceuticals"
	should_generate_points = TRUE

/datum/techweb/dyne/New()
	. = ..()
	research_node_id(TECHWEB_NODE_OLDSTATION_SURGERY, TRUE, TRUE, FALSE)
	research_node_id(TECHWEB_NODE_DYNE, TRUE, TRUE, FALSE)
	SSresearch.techwebs += src

/datum/techweb_node/dyne
	id = TECHWEB_NODE_DYNE
	display_name = "Interdyne Technology"
	description = "Tools used by Interdyne Employees."
	required_items_to_unlock = list(
		/obj/item/circuitboard/machine/ghostpad/interdyne,
		/obj/item/circuitboard/computer/ghostpad/interdyne,
		/obj/machinery/powerator/interdyne
	)
	prereq_ids = list(TECHWEB_NODE_CONSTRUCTION)
	design_ids = list(
		"bountypad_interdyne",
		"bountyconsole_interdyne",
		"powerator_interdyne",
		"protolathe_interdyne",
		"interdyne_encryption"

	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	hidden = TRUE

//production

/datum/design/dyne_protolathe
	name = "Interdyne Branded Protolathe"
	desc = "The circuit board for a machine that can produce equipment in exchange for materials."
	id = "protolathe_interdyne"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/protolathe/dyne
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/dyne_expressconsole
	name = "Interdyne Supply Console"
	desc = "A specialized console, allowing for deepspace communication with a specialized drop pod railgun for precise and accurate \
		deliveries, no matter how remote they are located"
	id = "expressconsole_interdyne"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/computer/cargo/express/ghost/interdyne
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO


/datum/design/dyne_bounty_pad
	name = "Interdyne Bounty Pad"
	desc = "The circuit board for a machine used to sell goods on a local sector market."
	id = "bountypad_interdyne"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/ghostpad/interdyne
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/dyne_bounty_pad_console
	name = "Interdyne Bounty Pad Console"
	desc = "The circuit board for the computer used to control a bounty pad to sell goods on a local sector market."
	id = "bountyconsole_interdyne"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/computer/ghostpad/interdyne
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/dyne_powerator
	name = "Interdyne Powerator"
	desc = "The circuit board for a machine that can sell power to massive interdyne drug manufactories."
	id = "powerator_interdyne"
	build_type = AWAY_IMPRINTER
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1)
	build_path = /obj/item/circuitboard/machine/powerator/interdyne
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_CONSTRUCTION_MACHINERY
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO


	//Interdyne physical Server

/obj/item/circuitboard/machine/rdserver/dyne
	name = "Interdyne R&D Server"
	build_path = /obj/machinery/rnd/server/dyne

/obj/machinery/rnd/server/dyne
	name = "\improper Interdyne R&D Server"
	circuit = /obj/item/circuitboard/machine/rdserver/dyne
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/rnd/server/dyne/Initialize(mapload)
	var/datum/techweb/dyne_techweb = locate(/datum/techweb/dyne) in SSresearch.techwebs
	stored_research = dyne_techweb
	return ..()

/obj/machinery/rnd/server/dyne/examine(mob/user)
	. = ..()
	. += span_notice("You can use <b>research notes</b> on this to generate research points.")

/obj/machinery/rnd/server/dyne/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/research_notes) && stored_research)
		var/obj/item/research_notes/research_notes = tool
		stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_notes.value))
		playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
		qdel(research_notes)
		return ITEM_INTERACT_SUCCESS

	return ..()


/obj/machinery/rnd/production/protolathe/dyne
	name = "Interdyne Branded Protolathe"
	desc = "Converts raw materials into useful objects."
	circuit = /obj/item/circuitboard/machine/protolathe/dyne
	stripe_color = "#00fc2e"

/obj/item/circuitboard/machine/protolathe/dyne
	name = "Interdyne Branded Protolathe"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/rnd/production/protolathe/dyne
