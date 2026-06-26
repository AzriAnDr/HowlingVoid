/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "The Allstar Lasers Star Combat 1, or \"Allstar SC-1\", \
		is a basic, energy-based workhorse of a laser carbine that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	inhand_icon_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	shaded_charge = TRUE
	light_color = COLOR_SOFT_RED
	selfcharge = TRUE
	charge_delay = 15

/obj/item/gun/energy/laser/Initialize(mapload)
	. = ..()
	add_deep_lore()

	// Only regular lasguns can be slapcrafted
	if(type != /obj/item/gun/energy/laser)
		return
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/laser/xraylaser, /datum/crafting_recipe/laser/hellgun, /datum/crafting_recipe/laser/ioncarbine)
	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/gun/energy/laser/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 12)

/obj/item/gun/energy/laser/pistol
	name = "laser pistol"
	desc = "The Allstar Lasers Star Combat 1 Compact, or \"Allstar SC-1/C\", \
		is a compact pistol variant of the venerable SC-1 designed with a focus on portability."
	icon_state = "laser_pistol"
	w_class = WEIGHT_CLASS_SMALL
	projectile_damage_multiplier = 1
	cell_type = /obj/item/stock_parts/power_store/cell/laser_pistol
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/pistol)

/obj/item/gun/energy/laser/pistol/add_seclight_point()
	return

/obj/item/gun/energy/laser/assault
	name = "laser assault rifle"
	desc = "The Allstar Lasers Star Combat 1 Assault, or \"Allstar SC-1/A\", \
		is an assault variant of the venerable SC-1 designed with a focus on sustained fire \
		potential and resistance against electromagnetic interference."
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	icon_state = "assault_laser"
	inhand_icon_state = "assault_laser"
	worn_icon_state = "assault_laser"
	slot_flags = ITEM_SLOT_BACK
	burst_size = 2
	fire_delay = 1
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/assault)
	emp_resistance = 2
	weapon_weight = WEAPON_HEAVY
	projectile_speed_multiplier = 1.5
	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/energy/laser/assault/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 30)

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the Allstar SC-1 laser gun. Fires entirely harmless bolts of directed energy. Safe AND entertaining to fire with abandon."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = FALSE
	item_flags = NONE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/laser/practice/add_deep_lore()
	return

/obj/item/gun/energy/laser/retro
	name = "retro laser gun"
	desc = parent_type::desc + " This one's from a much older manufacturing run. The fact that \
		it still runs speaks to Allstar's manufacturing standards."
	icon_state = "retro"
	ammo_x_offset = 3

/obj/item/gun/energy/laser/soul
	name = "classic laser gun"
	desc = parent_type::desc + " This one's from a \"neoclassic\" manufacturing run, using an \
		older manufacturing run's design for the nostalgic laser gunner. \
		They don't make them like they used to."
	icon_state = "laser_soulful"
	inhand_icon_state = "laser_soulful"
	ammo_x_offset = 1

/obj/item/gun/energy/laser/carbine
	name = "laser burst carbine"
	desc = "The Allstar Lasers Star Combat 1-Rapid, or \"Allstar SC-1/R\", \
		is an energy-based laser burst-fire carbine that fires a sustained volley of lasers. \
		It trades the stopping power of each individual beam for a sustained volley of directed energy."
	icon_state = "laser_carbine"
	burst_size = 2
	fire_delay = 2
	projectile_damage_multiplier = 0.75
	projectile_speed_multiplier = 1.5
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/carbine)
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/energy/laser/cybersun
	name = "\improper Cybersun S-120"
	desc = "A laser gun primarily used by syndicate security guards. It fires a rapid spray of low-power plasma beams."
	icon_state = "cybersun_s120"
	inhand_icon_state = "s120"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/cybersun)
	spread = 14
	pin = /obj/item/firing_pin/implant/pindicate
	ammo_x_offset = 1

/obj/item/gun/energy/laser/cybersun/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/energy/laser/cybersun/add_deep_lore()
	return

/obj/item/gun/energy/laser/cybersun/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/energy/laser/carbine/practice
	name = "practice laser carbine"
	desc = "A modified version of the Allstar SC-1R laser carbine. Fires entirely harmless bolts of directed energy. Safe AND entertaining to fire with abandon."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/carbine/practice)
	clumsy_check = FALSE
	item_flags = NONE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/laser/carbine/practice/add_deep_lore()
	return

/obj/item/gun/energy/laser/retro/old
	desc = parent_type::desc + " On second thought, perhaps not - how long has this one been in use?"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)

/obj/item/gun/energy/laser/retro/old/add_deep_lore()
	return

/obj/item/gun/energy/laser/hellgun
	name = "hellfire laser gun"
	desc = "The Allstar Lasers Star Combat Heavy, or \"Allstar SC-H\", \
		is a relic of a weapon, built before Allstar began installing regulators on their laser weaponry. \
		This pattern of laser gun became infamous for the gruesome burn wounds it caused, \
		and was quietly pushed to the sidelines once it began to affect Allstar's reputation."
	icon_state = "hellgun"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire)
	ammo_x_offset = 1
	light_color = COLOR_AMMO_HELLFIRE

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. \
		The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	icon_state = "caplaser"
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = null
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	charge_delay = 8
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire/blueshield)
	light_color = COLOR_AMMO_HELLFIRE

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lens to scatter its shot into multiple smaller lasers. \
		The inner-core can self-charge for theoretically infinite use."
	icon_state = "lasercannon"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "laser"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	shaded_charge = FALSE
	ammo_x_offset = 1


/obj/item/gun/energy/laser/captain/scattershot/add_deep_lore()
	return

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	use_cyborg_cell = TRUE
	ammo_x_offset = 1

/obj/item/gun/energy/laser/cyborg/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/gun/energy/laser/cyborg/add_deep_lore()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	ammo_x_offset = 1

/obj/item/gun/energy/laser/scatter/add_deep_lore()
	return

/obj/item/gun/energy/laser/scatter/shotty
	name = "energy shotgun"
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "cshotgun"
	inhand_icon_state = "shotgun"
	desc = "A combat shotgun gutted and refitted with an internal energy emission system. Can switch between scattered disabler shots and taser electrodes."
	shaded_charge = FALSE
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler, /obj/item/ammo_casing/energy/electrode)
	automatic_charge_overlays = FALSE
	ammo_x_offset = 1

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	inhand_icon_state = "laser"
	worn_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3
	selfcharge = TRUE
	charge_delay = 15

///X-ray gun

/obj/item/gun/energy/laser/xray
	name = "\improper Type 6 X-ray laser gun"
	desc = "The Type 6 Heat Delivery System, developed by Nanotrasen. \
		Capable of expelling concentrated 'X-ray' blasts that pass through multiple soft targets and heavier materials."
	icon_state = "xray"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	ammo_x_offset = 3
	fire_sound_volume = 100
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3.5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/uranium = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	shaded_charge = TRUE
	light_color = LIGHT_COLOR_GREEN

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless blue beams of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/bluetag/add_deep_lore()
	return

/obj/item/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams red of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/laser/redtag/add_deep_lore()
	return

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)

// luxury shuttle funnies
/obj/item/firing_pin/paywall/luxury
	multi_payment = TRUE
	payment_amount = 20

/obj/item/gun/energy/laser/luxurypaywall
	name = "luxurious laser gun"
	desc = "A laser gun modified to cost 20 credits to fire. Point towards poor people."
	pin = /obj/item/firing_pin/paywall/luxury

// The Deep Lore //

// Laser Gun

/obj/item/gun/energy/laser/proc/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The Allstar SC-1 laser gun, typically referred to as the SC-1, laser gun, or \"ol' reliable\", \
		is one of Allstar's greatest successes in energy weapon development, proving itself as a workhorse.<br>\
		<br>\
		Typically regarded as a solid benchmark by which all other energy firearms can be held against, \
		the SC-1 typically features a respectable cell and solid stopping power per shot. \
		Being an energy-based firearms means that, logistics-wise, the only thing required to support its use other \
		than maintenance equipment and spare parts is a steady supply of power in lieu of ammunition, \
		making it quite popular for people with a surplus of the former and not so much the latter." \
	)

// Retro Laser Gun

/obj/item/gun/energy/laser/retro/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The Allstar SC-1 laser gun, typically referred to as the SC-1, laser gun, or \"ol' reliable\", \
		is one of Allstar's greatest successes in energy weapon development, proving itself as a workhorse. \
		Especially this one, which uses a casing pattern that hasn't been in active use for... who knows how long.<br>\
		<br>\
		Typically regarded as a solid benchmark by which all other energy firearms can be held against, \
		the SC-1 typically features a respectable cell and solid stopping power per shot. \
		Being an energy-based firearms means that, logistics-wise, the only thing required to support its use other \
		than maintenance equipment and spare parts is a steady supply of power in lieu of ammunition, \
		making it quite popular for people with a surplus of the former and not so much the latter. \
		The fact that this particular example still runs fine, despite its visible age, is remarkable." \
	)

// Soulful Laser Gun

/obj/item/gun/energy/laser/soul/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The Allstar SC-1 laser gun, typically referred to as the SC-1, laser gun, or \"ol' reliable\", \
		is one of Allstar's greatest successes in energy weapon development, proving itself as a workhorse.<br>\
		<br>\
		This specific variant is from a \"neoclassical\" manufacturing run, using an old chassis as a base. \
		While many would argue that the neoclassical runs are gimmick runs to squeeze out more money, \
		others swear by the old-fashioned style, citing anecdotal evidence. Either way, a laser gun is a laser gun.<br>\
		<br>\
		Typically regarded as a solid benchmark by which all other energy firearms can be held against, \
		the SC-1 typically features a respectable cell and solid stopping power per shot. \
		Being an energy-based firearms means that, logistics-wise, the only thing required to support its use other \
		than maintenance equipment and spare parts is a steady supply of power in lieu of ammunition, \
		making it quite popular for people with a surplus of the former and not so much the latter." \
	)

// hellfire laser gun

/obj/item/gun/energy/laser/hellgun/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The Allstar SC-H heavy laser gun, typically referred to as the SC-H, hellfire laser gun, or \"ol' inhumane\", \
		is one of Allstar's less-great successes in energy weapon development, proving itself to be a little too effective. \
		It's considered a notable example of Allstar flying too close to the sun for its own good.<br>\
		<br>\
		The success of the SC-1 resulted in shareholders pushing for a follow-up to ride the wave of its success. Despite insistence \
		from Allstar that it was not ready for a full rollout, continued pushes from shareholders forced the prototype SC-H into production \
		and rollout in the next quarter, even before most of its safety systems had been properly tested and implemented. \
		Reports immediately began flooding in of horrific accidental discharges, battlefield atrocities and unexpected spontaneous combustion \
		from excessive exposure to the untested experimental heat distribution systems 'taking its pound of flesh' for the 'hell it unleashed'.<br>\
		<br>\
		In response, many legal bodies rushed to ban or heavily restrict the firearm from sales within their region of space, \
		and the weapon became infamous for its unethical means of ending sentient life. \
		Laws were passed to ensure power regulators were installed in future energy-based weaponry. \
		Allstar quickly downturned manufacturing of the SC-H in response, returning to focusing on manufacturing the SC-1 to \
		regain lost ground in affected markets. \
		While, legally, the SC-H is still restricted if not banned in many polities, Nanotrasen itself does not regulate possession \
		of the firearm aboard their stations, nor does any legal body intend on preventing them from utilizing it in defense \
		of its own assets." \
	)

// Antique Laser Gun

/obj/item/gun/energy/laser/captain/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "For a brief period, Allstar produced a series of custom-made SC-H laser guns for a select group of \
		clients, mainly consisting of various wealthy starship captains, politicians and military leaders looking to demonstrate prestige before \
		the common folk.<br>\
		<br>\
		The SC-H was a commercial failure, but this particular variant earned its own infamy, linked to narratives of crazed \
		despots using it to put down political rivals and dissidents, as well as tales of mad generals marching ahead of their \
		forces, this weapon brandished, running hot in an outstretched arm towards any moving target they could find on the \
		battlefield. <br>\
		<br>\
		Usage of this firearm is now heavily scrutinized within SolFed space because of its reputation. \
		This is largely why Nanotrasen insists that any examples held by ranking officers be kept under lock and key. \
		All records of the schematics surrounding this variant of the Type 4 were seized and destroyed, and the creator behind \
		it detained in a maximum security SolFed sanitorium. During a routine check-up, she appeared to have smeared the walls in her \
		own blood, claiming that 'She' was coming, and that she had paid dearly for the knowledge of how to make the weapon.<br>\
		<br>\
		Even the microfusion breeder cell housed inside the weapon is practically a lost technology. Nanotrasen have remained unable \
		to reverse engineer the device's exact means of functionality. The Syndicate are, obviously, just as interested \
		in exactly how this weapon's cell remains capable of self-perpetuation, hence why the collective \
		seem hell-bent on capturing them whenever possible.<br>\
		<br>\
		Maybe keep this somewhere safe. Or don't." \
	)

// X-ray Laser Gun

/obj/item/gun/energy/laser/xray/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The NT Type 6 Heat Delivery System (sometimes referred to as the HDS6 in research notes) is a breakthrough in the \
		development of directed energy weaponry, using modified Allstar SC-1s as a base.<br>\
		<br>\
		Very little is known about the Type 6, as it is a relatively new experimental weapon only accessible to Nanotrasen security forces.\
		Somehow, Nanotrasen has found a means to 'slip' the energy beams produced by the Type 6 through unintended targets, only impacting \
		once it has made contact with a pre-designated target by the weapon's user. It appears to be unable to slip past organic matter reliably, \
		which hampers its potential for eliminating friendly-fire. However, inorganic targets are left unscathed unless the weapon is directed towards \
		firing upon the object. This makes the weapon exceptional for asset recovery, defensive entrenchment, and assaults on defensive structures. <br>\
		<br>\
		Nanotrasen claims that this phenomenon is achieved 'through the power of X-rays'. Most critics have highlighted that this is total nonsense. Some claim \
		that Nanotrasen has discovered a yet-unknown state of matter that the company is exploiting for weapons development and manufacturing. The most \
		conspiratorially minded of Nanotrasen's critics have even gone as far as to claim it is 'proof of ectoplasm as the sixth element', \
		and that, perhaps, the weapon may be operating through supernatural means; perhaps even powered by the 'spirits of the damned'.<br>\
		<br>\
		Whatever the truth may be, the weapon seems to function as advertised, and matches the energy efficiency of the SC-1. Nanotrasen \
		expects full commercial rollout sometime in the next quarter." \
	)

// Laser Carbine

/obj/item/gun/energy/laser/carbine/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The Allstar SC-1R is a modification of the venerable SC-1, and a shaky first step into \
		automatic directed energy weaponry, eventually leading to settling on a burst-fire system.<br>\
		<br>\
		While less popular than the standard laser gun, the SC-1R's burst-fire system and accelerated \
		agitation chamber allows for a good rate of sustained fire with reduced risk of searing ones' hands off, \
		in return for sacrificing stopping power per shot. \
		Being an energy-based firearms means that, logistics-wise, the only thing required to support its use other \
		than maintenance equipment and spare parts is a steady supply of power in lieu of ammunition, \
		making it quite popular for people with a surplus of the former and not so much the latter." \
	)
