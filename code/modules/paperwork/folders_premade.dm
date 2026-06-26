/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"
	bg_color = "#355e9f"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"
	bg_color = "#b5002e"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"
	bg_color = "#b88f3d"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"
	bg_color = "#d9d9d9"

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/Initialize(mapload)
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_appearance()

/obj/item/folder/syndicate
	icon_state = "folder_syndie"
	bg_color = "#3f3f3f"
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/red(src)
	update_appearance()

/obj/item/folder/syndicate/red/secretformula
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/secretformula/Initialize(mapload)
	. = ..()
	new /obj/item/paper/secretrecipe/secretformula(src)
	update_appearance()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/blue(src)
	update_appearance()

/obj/item/folder/syndicate/mining/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_appearance()

/obj/item/folder/ancient_paperwork/Initialize(mapload)
	. = ..()
	new /obj/item/paperwork/ancient(src)
	update_appearance()


// BEGIN NOVA CORE MIGRATION: code/modules/paperwork/folders_premade.dm
/obj/item/folder/ancient_paperwork/five
	name = "packed dusty folder"
	desc = "You're pretty sure folders shouldn't be packed this full, especially if they look this old."

/obj/item/folder/ancient_paperwork/five/Initialize(mapload)
	. = ..()
	// as we inherit the previous init, which generates one ancient paperwork, we initialize 4 more for 5 total
	new /obj/item/paperwork/ancient(src)
	new /obj/item/paperwork/ancient(src)
	new /obj/item/paperwork/ancient(src)
	new /obj/item/paperwork/ancient(src)
	update_appearance()
// END NOVA CORE MIGRATION: code/modules/paperwork/folders_premade.dm
