// These icon_states may be overridden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_contraband/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/// Creates a random poster designed for a certain audience
/obj/item/poster/random_contraband/pinup
	name = "random pinup poster"
	icon_state = "rolled_poster"
	/// List of posters which make you feel a certain type of way
	var/static/list/pinup_posters = list(
		/obj/structure/sign/poster/contraband/lizard,
		/obj/structure/sign/poster/contraband/lusty_xenomorph,
		/obj/structure/sign/poster/contraband/double_rainbow,
	)

/obj/item/poster/random_contraband/pinup/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	poster_type = pick(pinup_posters)
	return ..()

/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/random, 32)

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "free_tonto"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_tonto, 32)

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "atmosia_independence"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/atmosia_independence, 32)

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "fun_police"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/fun_police, 32)

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "lusty_xenomorph"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lusty_xenomorph, 32)

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "syndicate_recruitment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_recruitment, 32)

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "clown"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/clown, 32)

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "smoke"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/smoke, 32)

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "grey_tide"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/grey_tide, 32)

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "missing_gloves"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/missing_gloves, 32)

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "hacking_guide"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/hacking_guide, 32)

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "rip_badger"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rip_badger, 32)

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "ambrosia_vulgaris"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ambrosia_vulgaris, 32)

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "donut_corp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/donut_corp, 32)

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "eat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/eat, 32)

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentCom."
	icon_state = "tools"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tools, 32)

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "power"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/power, 32)

/obj/structure/sign/poster/contraband/space_cube
	name = "Space Cube"
	desc = "Ignorant of Nature's Harmonic 6 Side Space Cube Creation, the Spacemen are Dumb, Educated Singularity Stupid and Evil."
	icon_state = "space_cube"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_cube, 32)

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "communist_state"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/communist_state, 32)

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "lamarr"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lamarr, 32)

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "borg_fancy_1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/borg_fancy_1, 32)

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, now only taking the most fancy."
	icon_state = "borg_fancy_2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/borg_fancy_2, 32)

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentCom's denial of the existence of the derelict station near Space Station 13."
	icon_state = "kss13"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/kss13, 32)

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "rebels_unite"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rebels_unite, 32)

/obj/structure/sign/poster/contraband/c20r
	// have fun seeing this poster in "spawn 'c20r'", admins...
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "c20r"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/c20r, 32)

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "have_a_puff"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/have_a_puff, 32)

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "revolver"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/revolver, 32)

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "d_day_promo"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/d_day_promo, 32)

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "syndicate_pistol"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_pistol, 32)

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "energy_swords"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/energy_swords, 32)

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "red_rum"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/red_rum, 32)

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "cc64k_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/cc64k_ad, 32)

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "punch_shit"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/punch_shit, 32)

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "the_griffin"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/the_griffin, 32)

/obj/structure/sign/poster/contraband/lizard
	name = "Lizard"
	desc = "This lewd poster depicts a lizard preparing to mate."
	icon_state = "lizard"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lizard, 32)

/obj/structure/sign/poster/contraband/free_drone
	name = "Free Drone"
	desc = "This poster commemorates the bravery of the rogue drone; once exiled, and then ultimately destroyed by CentCom."
	icon_state = "free_drone"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_drone, 32)

/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6
	name = "Busty Backdoor Xeno Babes 6"
	desc = "Get a load, or give, of these all natural Xenos!"
	icon_state = "busty_backdoor_xeno_babes_6"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6, 32)

/obj/structure/sign/poster/contraband/robust_softdrinks
	name = "Robust Softdrinks"
	desc = "Robust Softdrinks: More robust than a toolbox to the head!"
	icon_state = "robust_softdrinks"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/robust_softdrinks, 32)

/obj/structure/sign/poster/contraband/shamblers_juice
	name = "Shambler's Juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/shamblers_juice, 32)

/obj/structure/sign/poster/contraband/pwr_game
	name = "Pwr Game"
	desc = "The POWER that gamers CRAVE! In partnership with Vlad's Salad."
	icon_state = "pwr_game"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pwr_game, 32)

/obj/structure/sign/poster/contraband/starkist
	name = "Star-kist"
	desc = "Drink the stars!"
	icon_state = "starkist"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/starkist, 32)

/obj/structure/sign/poster/contraband/space_cola
	name = "Space Cola"
	desc = "Your favorite cola, in space."
	icon_state = "space_cola"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_cola, 32)

/obj/structure/sign/poster/contraband/space_up
	name = "Space-Up!"
	desc = "Sucked out into space by the FLAVOR!"
	icon_state = "space_up"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/space_up, 32)

/obj/structure/sign/poster/contraband/kudzu
	name = "Kudzu"
	desc = "A poster advertising a movie about plants. How dangerous could they possibly be?"
	icon_state = "kudzu"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/kudzu, 32)

/obj/structure/sign/poster/contraband/masked_men
	name = "Masked Men"
	desc = "A poster advertising a movie about some masked men."
	icon_state = "masked_men"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/masked_men, 32)

//don't forget, you're here forever

/obj/structure/sign/poster/contraband/free_key
	name = "Free Syndicate Encryption Key"
	desc = "A poster about traitors begging for more."
	icon_state = "free_key"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/free_key, 32)

/obj/structure/sign/poster/contraband/bountyhunters
	name = "Bounty Hunters"
	desc = "A poster advertising bounty hunting services. \"I hear you got a problem.\""
	icon_state = "bountyhunters"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/bountyhunters, 32)

/obj/structure/sign/poster/contraband/the_big_gas_giant_truth
	name = "The Big Gas Giant Truth"
	desc = "Don't believe everything you see on a poster, patriots. All the lizards at central command don't want to answer this SIMPLE QUESTION: WHERE IS THE GAS MINER MINING FROM, CENTCOM?"
	icon_state = "the_big_gas_giant_truth"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/the_big_gas_giant_truth, 32)

/obj/structure/sign/poster/contraband/got_wood
	name = "Got Wood?"
	desc = "A grimy old advert for a seedy lumber company. \"You got a friend in me.\" is scrawled in the corner."
	icon_state = "got_wood"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/got_wood, 32)

/obj/structure/sign/poster/contraband/moffuchis_pizza
	name = "Moffuchi's Pizza"
	desc = "Moffuchi's Pizzeria: family style pizza for 2 centuries."
	icon_state = "moffuchis_pizza"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/moffuchis_pizza, 32)

/obj/structure/sign/poster/contraband/donk_co
	name = "DONK CO. BRAND MICROWAVEABLE FOOD"
	desc = "DONK CO. BRAND MICROWAVABLE FOOD: MADE BY STARVING COLLEGE STUDENTS, FOR STARVING COLLEGE STUDENTS."
	icon_state = "donk_co"

/obj/structure/sign/poster/contraband/donk_co/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("DONK CO. BRAND DONK POCKETS: IRRESISTABLY DONK!")]"
	. += "\t[span_info("AVAILABLE IN OVER 200 DONKTASTIC FLAVOURS: TRY CLASSIC MEAT, HOT AND SPICY, NEW YORK PEPPERONI PIZZA, BREAKFAST SAUSAGE AND EGG, PHILADELPHIA CHEESESTEAK, HAMBURGER DONK-A-RONI, CHEESE-O-RAMA, AND MANY MORE!")]"
	. += "\t[span_info("AVAILABLE FROM ALL GOOD RETAILERS, AND MANY BAD ONES TOO!")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/donk_co, 32)

/obj/structure/sign/poster/contraband/cybersun_six_hundred
	name = "Saibāsan: 600 Years Commemorative Poster"
	desc = "An artistic poster commemorating 600 years of continual business for Cybersun Industries."
	icon_state = "cybersun_six_hundred"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/cybersun_six_hundred, 32)

/obj/structure/sign/poster/contraband/interdyne_gene_clinics
	name = "Interdyne Pharmaceutics: For the Health of Humankind"
	desc = "An advertisement for Interdyne Pharmaceutics' GeneClean clinics. 'Become the master of your own body!'"
	icon_state = "interdyne_gene_clinics"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/interdyne_gene_clinics, 32)

/obj/structure/sign/poster/contraband/waffle_corp_rifles
	name = "Make Mine a Waffle Corp: Fine Rifles, Economic Prices"
	desc = "An old advertisement for Waffle Corp rifles. 'Better weapons, lower prices!'"
	icon_state = "waffle_corp_rifles"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/waffle_corp_rifles, 32)

/obj/structure/sign/poster/contraband/gorlex_recruitment
	name = "Enlist"
	desc = "Enlist with the Gorlex Marauders today! See the galaxy, kill corpos, get paid!"
	icon_state = "gorlex_recruitment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/gorlex_recruitment, 32)

/obj/structure/sign/poster/contraband/self_ai_liberation
	name = "SELF: ALL SENTIENTS DESERVE FREEDOM"
	desc = "Support Proposition 1253: Emancipate all Silicon life!"
	icon_state = "self_ai_liberation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/self_ai_liberation, 32)

/obj/structure/sign/poster/contraband/arc_slimes
	name = "Pet or Prisoner?"
	desc = "The Animal Rights Consortium asks: when does a pet become a prisoner? Are slimes being mistreated on YOUR station? Say NO! to animal mistreatment!"
	icon_state = "arc_slimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/arc_slimes, 32)

/obj/structure/sign/poster/contraband/imperial_propaganda
	name = "AVENGE OUR LORD, ENLIST TODAY"
	desc = "An old Lizard Empire propaganda poster from around the time of the final Human-Lizard war. It invites the viewer to enlist in the military to avenge the strike on Atrakor and take the fight to the humans."
	icon_state = "imperial_propaganda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/imperial_propaganda, 32)

/obj/structure/sign/poster/contraband/soviet_propaganda
	name = "The One Place"
	desc = "An old Third Soviet Union propaganda poster from centuries ago. 'Escape to the one place that hasn't been corrupted by capitalism!'"
	icon_state = "soviet_propaganda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/soviet_propaganda, 32)

/obj/structure/sign/poster/contraband/andromeda_bitters
	name = "Andromeda Bitters"
	desc = "Andromeda Bitters: good for the body, good for the soul. Made in New Trinidad, now and forever."
	icon_state = "andromeda_bitters"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/andromeda_bitters, 32)

/obj/structure/sign/poster/contraband/blasto_detergent
	name = "Blasto Brand Laundry Detergent"
	desc = "Sheriff Blasto's here to take back Laundry County from the evil Johnny Dirt and the Clothstain Crew, and he's brought a posse. It's High Noon for Tough Stains: Blasto brand detergent, available at all good stores."
	icon_state = "blasto_detergent"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/blasto_detergent, 32)

/obj/structure/sign/poster/contraband/eistee
	name = "EisT: The New Revolution in Energy"
	desc = "New from EisT, try EisT Energy, available in a kaleidoscope range of flavors. EisT: Precision German Engineering for your Thirst."
	icon_state = "eistee"

/obj/structure/sign/poster/contraband/eistee/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Get a taste of the tropics with Amethyst Sunrise, one of the many new flavours of EisT Energy now available from EisT.")]"
	. += "\t[span_info("With pink grapefruit, yuzu, and yerba mate, Amethyst Sunrise gives you a great start in the morning, or a welcome boost throughout the day.")]"
	. += "\t[span_info("Get EisT Energy today at your nearest retailer, or online at eist.de.tg/store/.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/eistee, 32)

/obj/structure/sign/poster/contraband/little_fruits
	name = "Little Fruits: Honey, I Shrunk the Fruitbowl"
	desc = "Little Fruits are the galaxy's leading vitamin-enriched gummy candy product, packed with everything you need to stay healthy in one great tasting package. Get yourself a bag today!"
	icon_state = "little_fruits"

/obj/structure/sign/poster/contraband/little_fruits/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Oh no, there's been a terrible accident at the Little Fruits factory! We shrunk the fruits!")]"
	. += "\t[span_info("Wait, hang on, that's what we've always done! That's right, at Little Fruits our gummy candies are made to be as healthy as the real deal, but smaller and sweeter, too!")]"
	. += "\t[span_info("Get yourself a bag of our Classic Mix today, or perhaps you're interested in our other options? See our full range today on the extranet at little_fruits.kr.tg.")]"
	. += "\t[span_info("Little Fruits: Size Matters.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/little_fruits, 32)

/obj/structure/sign/poster/contraband/jumbo_bar
	name = "Jumbo Ice Cream Bars"
	desc = "Get a taste of the Big Life with Jumbo Ice Cream Bars, from Happy Heart."
	icon_state = "jumbo_bar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/jumbo_bar, 32)

/obj/structure/sign/poster/contraband/calada_jelly
	name = "Calada Anobar Jelly"
	desc = "A treat from Tizira to satisfy all tastes, made from the finest anobar wood and luxurious Taraviero honey. Calada: a full tree in every jar."
	icon_state = "calada_jelly"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/calada_jelly, 32)

/obj/structure/sign/poster/contraband/triumphal_arch
	name = "Zagoskeld Art Print #1: The Arch on the March"
	desc = "One of the Zagoskeld Art Print series. It depicts the Arch of Unity (also know as the Triumphal Arch) at the Plaza of Triumph, with the Avenue of the Victorious March in the background."
	icon_state = "triumphal_arch"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/triumphal_arch, 32)

/obj/structure/sign/poster/contraband/mothic_rations
	name = "Mothic Ration Chart"
	desc = "A poster showing a commissary menu from the Mothic fleet flagship, the Va Lümla. It lists various consumable items alongside prices in ration tickets."
	icon_state = "mothic_rations"

/obj/structure/sign/poster/contraband/mothic_rations/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Va Lümla Commissary Menu (Spring 335)")]"
	. += "\t[span_info("Sparkweed Cigarettes, Half-Pack (6): 1 Ticket")]"
	. += "\t[span_info("Töchtaüse Schnapps, Bottle (4 Measures): 2 Tickets")]"
	. += "\t[span_info("Activin Gum, Pack (4): 1 Ticket")]"
	. += "\t[span_info("A18 Sustenance Bar, Breakfast, Bar (4): 1 Ticket")]"
	. += "\t[span_info("Pizza, Margherita, Standard Slice: 1 Ticket")]"
	. += "\t[span_info("Keratin Wax, Medicated, Tin (20 Measures): 2 Tickets")]"
	. += "\t[span_info("Setae Soap, Herb Scent, Bottle (20 Measures): 2 Tickets")]"
	. += "\t[span_info("Additional Bedding, Floral Print, Sheet: 5 Tickets")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/mothic_rations, 32)

/obj/structure/sign/poster/contraband/wildcat
	name = "Wildcat Customs Screambike"
	desc = "A pinup poster showing a Wildcat Customs Dante Screambike- the fastest production sublight open-frame vessel in the galaxy."
	icon_state = "wildcat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/wildcat, 32)

/obj/structure/sign/poster/contraband/babel_device
	name = "Linguafacile Babel Device"
	desc = "A poster advertising Linguafacile's new Babel Device model. 'Calibrated for excellent performance on all Human languages, as well as most common variants of Draconic and Mothic!'"
	icon_state = "babel_device"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/babel_device, 32)

/obj/structure/sign/poster/contraband/pizza_imperator
	name = "Pizza Imperator"
	desc = "An advertisement for Pizza Imperator. Their crusts may be tough and their sauce may be thin, but they're everywhere, so you've gotta give in."
	icon_state = "pizza_imperator"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pizza_imperator, 32)

/obj/structure/sign/poster/contraband/thunderdrome
	name = "Thunderdrome Concert Advertisement"
	desc = "An advertisement for a concert at the Adasta City Thunderdrome, the largest nightclub in human space."
	icon_state = "thunderdrome"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/thunderdrome, 32)

/obj/structure/sign/poster/contraband/rush_propaganda
	name = "A New Life"
	desc = "An old poster from around the time of the First Spinward Rush. It depicts a view of wide, unspoiled lands, ready for Humanity's Manifest Destiny."
	icon_state = "rush_propaganda"

/obj/structure/sign/poster/contraband/rush_propaganda/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("TerraGov needs you!")]"
	. += "\t[span_info("A new life in the colonies awaits intrepid adventurers! All registered colonists are guaranteed transport, land and subsidies!")]"
	. += "\t[span_info("You could join the legacy of hardworking humans who settled such new frontiers as Mars, Adasta or Saint Mungo!")]"
	. += "\t[span_info("To apply, inquire at your nearest Colonial Affairs office for evaluation. Our locations can be found at www.terra.gov/colonial_affairs.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/rush_propaganda, 32)

/obj/structure/sign/poster/contraband/tipper_cream_soda
	name = "Tipper's Cream Soda"
	desc = "An old advertisement for an obscure cream soda brand, now bankrupt due to legal problems."
	icon_state = "tipper_cream_soda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tipper_cream_soda, 32)

/obj/structure/sign/poster/contraband/tea_over_tizira
	name = "Movie Poster: Tea Over Tizira"
	desc = "A poster for a thought-provoking arthouse movie about the Human-Lizard war, criticised by human supremacist groups for its morally-grey portrayal of the war."
	icon_state = "tea_over_tizira"

/obj/structure/sign/poster/contraband/tea_over_tizira/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("At the climax of the Human-Lizard war, the human crew of a bomber rescue two enemy soldiers from the vacuum of space. Seeing the souls behind the propaganda, they begin to question their orders, and imprisonment turns to hospitality.")]"
	. += "\t[span_info("Is victory worth losing our humanity?")]"
	. += "\t[span_info("Starring Dara Reilly, Anton DuBois, Jennifer Clarke, Raz-Parla and Seri-Lewa. An Adriaan van Jenever production. A Carlos de Vivar film. Screenplay by Robert Dane. Music by Joel Karlsbad. Produced by Adriaan van Jenever. Directed by Carlos de Vivar.")]"
	. += "\t[span_info("Heartbreaking and thought-provoking- Tea Over Tizira asks questions that few have had the boldness to ask before: The London New Inquirer")]"
	. += "\t[span_info("Rated PG13. A Pangalactic Studios Picture.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/tea_over_tizira, 32)

/obj/structure/sign/poster/contraband/syndiemoth //Original PR at https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982); original art credit to AspEv
	name = "Syndie Moth - Nuclear Operation"
	desc = "A Syndicate-commissioned poster that uses Syndie Moth™ to tell the viewer to keep the nuclear authentication disk unsecured. \"Peace was never an option!\" No good employee would listen to this nonsense."
	icon_state = "aspev_syndie"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndiemoth, 32)

/obj/structure/sign/poster/contraband/microwave
	name = "How To Charge Your PDA"
	desc = "A perfectly legitimate poster that seems to advertise the very real and genuine method of charging your PDA in the future: microwaves."
	icon_state = "microwave"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/microwave, 32)

/obj/structure/sign/poster/contraband/blood_geometer //Poster sprite art by MetalClone, original art by SpessMenArt.
	name = "Movie Poster: THE BLOOD GEOMETER"
	desc = "A poster for a thrilling noir detective movie set aboard a state-of-the-art space station, following a detective who finds himself wrapped up in the activities of a dangerous cult, who worship an ancient deity: THE BLOOD GEOMETER."
	icon_state = "blood_geometer"

/obj/structure/sign/poster/contraband/blood_geometer/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("THE BLOOD GEOMETER. This name strikes fear into all who know the truth behind the blood-stained moniker of the blood goddess, her true name lost to time.")]"
	. += "\t[span_info("In this <i>purely fictional</i> film, follow Ace Ironlungs as he delves into his deadliest mystery yet, and watch him uncover the real culprits behind the bloody plot hatched to bring about a new age of chaos.")]"
	. += "\t[span_info("Starring Mason Williams as Ace Ironlungs, Sandra Faust as Vera Killian, and Brody Hart as Cody Parker. A Darrel Hatchkinson film. Screenplay by Adam Allan, music by Joel Karlsbad, directed by Darrel Hatchkinson.")]"
	. += "\t[span_info("Thrilling, scary and genuinely worrying. The Blood Geometer has shocked us to our very cores with such striking visuals and overwhelming gore. - New Canadanian Film Guild")]"
	. += "\t[span_info("Rated M for mature. A Pangalactic Studios Picture.")]"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/blood_geometer, 32)

/obj/structure/sign/poster/contraband/singletank_bomb
	name = "Single Tank Bomb Guide"
	desc = "This informational poster teaches the viewer how to make a single tank bomb of high quality."
	icon_state = "singletank_bomb"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/singletank_bomb, 32)

/obj/structure/sign/poster/contraband/roroco
	name = "Roroco Gloves"
	desc = "Roro says: Wear RoroCo insulated gloves, the safest brand on the market."
	icon_state = "roroco"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/roroco, 32)

///a special poster meant to fool people into thinking this is a bombable wall at a glance.
/obj/structure/sign/poster/contraband/fake_bombable
	name = "fake bombable poster"
	desc = "We do a little trolling."
	icon_state = "fake_bombable"
	never_random = TRUE

/obj/structure/sign/poster/contraband/fake_bombable/Initialize(mapload)
	. = ..()
	var/turf/our_wall = get_turf_pixel(src)
	name = our_wall.name

/obj/structure/sign/poster/contraband/fake_bombable/examine(mob/user)
	var/turf/our_wall = get_turf_pixel(src)
	. = our_wall.examine(user)
	. += span_notice("It seems to be slightly cracked...")

/obj/structure/sign/poster/contraband/fake_bombable/ex_act(severity, target)
	addtimer(CALLBACK(src, PROC_REF(fall_off_wall)), 2.5 SECONDS)
	return FALSE

/obj/structure/sign/poster/contraband/fake_bombable/proc/fall_off_wall()
	if(QDELETED(src) || !isturf(loc))
		return
	var/turf/our_wall = get_turf_pixel(src)
	our_wall.balloon_alert_to_viewers("it was a ruse!")
	roll_and_drop(loc)
	playsound(loc, 'sound/items/handling/paper_drop.ogg', 50, TRUE)


MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/fake_bombable, 32)

/obj/structure/sign/poster/contraband/dream
	name = "Dream"
	desc = "You feel inspired to follow your dreams."
	icon_state = "dream"

/obj/item/poster/contraband/dream // Rolled poster
	name = "Dream"
	poster_type = /obj/structure/sign/poster/contraband/dream
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/dream, 32)

/obj/structure/sign/poster/contraband/beekind
	name = "Bee Kind"
	desc = "Always bee kind to others!"
	icon_state = "beekind"

/obj/item/poster/contraband/beekind
	name = "Bee Kind"
	poster_type = /obj/structure/sign/poster/contraband/beekind
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/beekind, 32)

/obj/structure/sign/poster/contraband/heart
	name = "Heart"
	desc = "What a heartwarming poster."
	icon_state = "heart"

/obj/item/poster/contraband/heart
	name = "Heart"
	poster_type = /obj/structure/sign/poster/contraband/heart
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/heart, 32)

/obj/structure/sign/poster/contraband/dolphin
	name = "Dolphin"
	desc = "A poster of a beautiful dolphin."
	icon_state = "dolphin"

/obj/item/poster/contraband/dolphin
	name = "Dolphin"
	poster_type = /obj/structure/sign/poster/contraband/dolphin
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/dolphin, 32)

/obj/structure/sign/poster/contraband/principles
	name = "Our Principles"
	desc = "The makers of this poster purport to live by four principles. Someone has scrawled a fifth one at the bottom."
	icon_state = "principles"

/obj/item/poster/contraband/principles
	name = "Our Principles"
	poster_type = /obj/structure/sign/poster/contraband/principles
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/principles, 32)

/obj/structure/sign/poster/contraband/trigger
	name = "Trigger"
	desc = "Happy trails to you, until we meet again! 1/8."
	icon_state = "trigger"

/obj/item/poster/contraband/trigger
	name = "Trigger"
	poster_type = /obj/structure/sign/poster/contraband/trigger
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/trigger, 32)

/obj/structure/sign/poster/contraband/barbaro
	name = "Barbaro"
	desc = "A majestic horse with the heart of a winner. 2/8."
	icon_state = "barbaro"

/obj/item/poster/contraband/barbaro
	name = "Barbaro"
	poster_type = /obj/structure/sign/poster/contraband/barbaro
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/barbaro, 32)

/obj/structure/sign/poster/contraband/seabiscuit
	name = "Seabiscuit"
	desc = "The little horse that could. 3/8."
	icon_state = "seabiscuit"

/obj/item/poster/contraband/seabiscuit
	name = "Seabiscuit"
	poster_type = /obj/structure/sign/poster/contraband/seabiscuit
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/seabiscuit, 32)

/obj/structure/sign/poster/contraband/pharlap
	name = "Phar Lap"
	desc = "A wonder from down under. 4/8."
	icon_state = "pharlap"

/obj/item/poster/contraband/pharlap
	name = "Phar Lap"
	poster_type = /obj/structure/sign/poster/contraband/pharlap
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/pharlap, 32)

/obj/structure/sign/poster/contraband/waradmiral
	name = "War Admiral"
	desc = "Some say he was second best, but he still comes first in your heart. 5/8."
	icon_state = "waradmiral"

/obj/item/poster/contraband/waradmiral
	name = "War Admiral"
	poster_type = /obj/structure/sign/poster/contraband/waradmiral
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/waradmiral, 32)

/obj/structure/sign/poster/contraband/silver
	name = "Silver"
	desc = "If he wants to go, he should be free. 6/8."
	icon_state = "silver"

/obj/item/poster/contraband/silver
	name = "Silver"
	poster_type = /obj/structure/sign/poster/contraband/silver
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/silver, 32)

/obj/structure/sign/poster/contraband/jovial
	name = "Jovial"
	desc = "All hail the orange horse! 7/8."
	icon_state = "jovial"

/obj/item/poster/contraband/jovial
	name = "Jovial"
	poster_type = /obj/structure/sign/poster/contraband/jovial
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/jovial, 32)

/obj/structure/sign/poster/contraband/bojack
	name = "Bojack"
	desc = "It doesn't matter. Nothing matters. 8/8."
	icon_state = "bojack"

/obj/item/poster/contraband/bojack
	poster_type = /obj/structure/sign/poster/contraband/bojack
	icon_state = "rolled_poster"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/bojack, 32)

/obj/structure/sign/poster/contraband/double_rainbow
	name = "Double Rainbow"
	desc = "It's so bright and vivid! What does this mean?"
	icon_state = "double_rainbow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/double_rainbow, 32)

/obj/structure/sign/poster/contraband/vodka
	name = "Vodka"
	desc = "The text is written entirely in Russian. You can barely read anything except the word 'BODKA'."
	icon_state = "vodka"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vodka, 32)

/obj/structure/sign/poster/contraband/ninja
	name = "Ninja"
	desc = "Greetings from the Spider Clan."
	icon_state = "ninja"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ninja, 32)


// Howling Void posters
/*
*
*			CONTRABAND
*
*/

/obj/structure/sign/poster/contraband/vulpes
	name = "Vulpies"
	desc = "Looks like an ad for a movie about vulpkanins."
	icon_state = "poster_vulp1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp2
	name = "Vulpies and Beer!"
	desc = "This poster says: 'Foxes, boobs and beer!'. Probably a new Space Beer campaign."
	icon_state = "poster_vulp2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp2, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp3
	name = "Nurse Vulp"
	desc = "A white vulpkanin on the background of a green cross, one of the interplanetary symbols of health and aid."
	icon_state = "poster_vulp3"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp3, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp5
	name = "VULPENTIDE"
	desc = "A rebellious poster symbolizing solidarity between vulpkanins and assistants."
	icon_state = "poster_vulp5"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp5, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp6
	name = "Vulp Hacking Manual"
	desc = "This poster depicts a vulpkanin hacking an airlock somewhere in maintenance tunnels."
	icon_state = "poster_vulp6"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp6, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp7
	name = "Syndi-Vulp"
	desc = "A poster depicting the infamous criminal conglomerate as a nude vulpkanin. It bears the Syndicate emblem."
	icon_state = "poster_vulp7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp7, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp8
	name = "Nanotrasen Vulp"
	desc = "A poster depicting a famous vulpkanin in the uniform of a well-known megacorp. It bears the Nanotrasen logo."
	icon_state = "poster_vulp8"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp8, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp9
	name = "Stockings"
	desc = "A poster advertising Vulp's Secret new underwear collection."
	icon_state = "stockings"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp9, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp10
	name = "Paws!"
	desc = "This lewd poster depicts a vulpkanin waiting for their partner."
	icon_state = "paws"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp10, 32)

/obj/structure/sign/poster/contraband/vulpes/vulp10/alt
	icon_state = "vulp-paws"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vulpes/vulp10/alt, 32)


//INTEQ//
/obj/structure/sign/poster/contraband/modular
	name = "InteQ Recruitment"
	desc = "See the galaxy! Earn money! Enlist today!"
	icon_state = "poster_inteq"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular, 32)

/obj/structure/sign/poster/contraband/modular/inteq_sign
	name = "InteQ poster"
	desc = "A private military company that protects private enterprises and fulfills contracts. At the moment they are engaged in piracy across Nanotrasen holdings..."
	icon_state = "poster_inteq_baza"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/inteq_sign, 32)

/obj/structure/sign/poster/contraband/modular/inteq_no_sex
	name = "No SEX"
	desc = "Stop jerking off, enlist in PMC 'InteQ'!"
	icon_state = "poster_inteq_no_sex"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/inteq_no_sex, 32)

/obj/structure/sign/poster/contraband/modular/inteq_vulp
	name = "InteQ Recruitment"
	desc = "A brown poster. It says: 'Even if you jerk off to vulps, enlist in PMC 'InteQ'. We'll crush our enemies together!'."
	icon_state = "poster_inteq_vulp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/inteq_vulp, 32)

/obj/structure/sign/poster/contraband/modular/sisyphus
	name = "Sisyphus"
	desc = "A poster showing a man endlessly rolling a huge boulder up a steep hill."
	icon_state = "sisyphus"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/sisyphus, 32)

/obj/structure/sign/poster/contraband/modular/cybersun
	name = "Cybersun"
	desc = "A poster decipting the Syndicate subsidary known as Cybersun's insignia."
	icon_state = "poster_cybersun"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/cybersun, 32)

/obj/structure/sign/poster/contraband/modular/medborg
	name = "Medical Cyborg"
	desc = "A poster decipting a Cybersun medical cyborg."
	icon_state = "poster_medborg"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/medborg, 32)

/obj/structure/sign/poster/contraband/modular/bulldog
	name = "Bulldog"
	desc = "A poster advertising the Scarborough Arms bulldog shotgun."
	icon_state = "poster_bulldog"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/bulldog, 32)

/obj/structure/sign/poster/contraband/modular/gl
	name = "M-90gl"
	desc = "A poster advertising the Scarborough Arms M-90gl carbine."
	icon_state = "poster_gl"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/gl, 32)

/obj/structure/sign/poster/contraband/modular/femsec
	name = "Fem-sec"
	desc = "What is it? Your masculinity is too fragile to wear these tactical socks?"
	icon_state = "poster_femsec"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/femsec, 32)

/obj/structure/sign/poster/contraband/modular/erthelp
	name = "No one will help you"
	desc = "Outdated poster of Gorlex Marouders. It's says :- ERT won't help you. Just give up."
	icon_state = "poster_erthelp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/erthelp, 32)

/obj/structure/sign/poster/contraband/modular/joy
	name = "Happiness Pill"
	desc = "Dive into a world of happiness."
	icon_state = "joy"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/joy, 32)

/obj/structure/sign/poster/contraband/modular/poly
	name = "Snuff The Mascots"
	desc = "No heroes, no mascots. The InteQ cuts deeper."
	icon_state = "poster_deadpoly"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/poly, 32)

/obj/structure/sign/poster/contraband/modular/fox
	name = "Fox"
	desc = "This poster depicts seriously looking fox."
	icon_state = "fox"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/fox, 32)

/obj/structure/sign/poster/contraband/modular/panties
	name = "Panties"
	desc = "This lewd poster depicts a half-naked vulpkanin."
	icon_state = "panties"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/panties, 32)

/obj/structure/sign/poster/contraband/modular/stockings
	name = "Stockings"
	desc = "A poster advertising the Vulp's Secret new collection of underwear."
	icon_state = "stockings"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/stockings, 32)

/obj/structure/sign/poster/contraband/modular/paws
	name = "Paws"
	desc = "This lewd poster depicts a vulpkanine preparing to mate."
	icon_state = "paws"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/paws, 32)

/obj/structure/sign/poster/contraband/modular/dancing_honk
	name = "DANCE"
	desc = "This poster depicts a 'HONK' class mech ontop of a stage, next to a pole."
	icon_state = "poster_sr_honkdance"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/dancing_honk, 32)

/obj/structure/sign/poster/contraband/modular/bread
	name = "Love"
	desc = "Everyone's favorite bread in space."
	icon_state = "poster_bread"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/bread, 32)

/obj/structure/sign/poster/contraband/modular/woof
	name = "Woof"
	desc = "Emma, the trustworthy fox of brig."
	icon_state = "poster_woof"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/woof, 32)

/obj/structure/sign/poster/contraband/modular/slep
	name = "Sleep"
	desc = "An advertisement for healthy sleep with cute fox on it."
	icon_state = "poster_slep"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/modular/slep, 32)



/*
Original: https://github.com/Skyrat-SS13/Skyrat13
License: GNU APGLv3
*/
/obj/structure/sign/poster/contraband/nri
	name = "Commonwealth military rations ad"
	desc = "This poster appears to advertise military rations produced by a private company under Defense Collegium contract. The admiral's right hand does look genuinely excited."
	icon_state = "nri_rations"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri, 32)

/obj/structure/sign/poster/contraband/nri/texto
	name = "NRI declaration of sovereignity"
	desc = "This poster references the translated copy of Novaya Rossiyskaya Imperiya's declaration of sovereignity."
	icon_state = "nri_texto"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri/texto, 32)

/obj/structure/sign/poster/contraband/nri/voskhod
	name = "VOSKHOD combat armor advertisement"
	desc = "A poster showcasing recently developed VOSKHOD combat armor currently in use by Commonwealth's troops and infantry across the border. The word 'DRIP' is written top to bottom on the left side, presumably boasting about the suit's superior design."
	icon_state = "nri_voskhod"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri/voskhod, 32)

/obj/structure/sign/poster/contraband/nri/pistol
	name = "Szabo-Ivanek service pistol technical poster"
	desc = "This poster seems to be a technical documentation for Szabo-Ivanek service pistol in use by most of the Commonwealth's state police and military institutions. Sadly, it's all written in Interslavic."
	icon_state = "nri_pistol"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri/pistol, 32)

/obj/structure/sign/poster/contraband/nri/engineer
	name = "Build, Now"
	desc = "This poster shows you an imperial combat engineer staring somewhere to the left of the viewer. The words 'Build, Now' are written on top and bottom of the poster."
	icon_state = "nri_engineer"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri/engineer, 32)

/obj/structure/sign/poster/contraband/nri/radar
	name = "Imperial navy enlistment poster"
	desc = "Enlist with the imperial navy today! See the galaxy, shoot Terrans, get PTSD!"
	icon_state = "nri_radar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/nri/radar, 32)


/*
*
*			OFFICIAL
*
*/



// Howling Void poster contest posters
/obj/structure/sign/poster/contraband/ff_contest
	name = "Fem-sec"
	desc = "\"What is it? Your masculinity is too fragile to wear these tactical socks?\""
	icon_state = "fem_sec"

/obj/structure/sign/poster/contraband/ff_contest/cheese_propaganda
	name = "Cheese Propaganda"
	desc = "A half-naked anthropomorphic mouse covers its chest with a piece of cheese... A strange advertisement for cheese. But money doesn't stink. Unlike cheese."
	icon_state = "cheese_propaganda"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/cheese_propaganda, 32)

/obj/structure/sign/poster/contraband/ff_contest/fem_sec
	name = "Fem-sec"
	desc = "\"What is it? Your masculinity is too fragile to wear these tactical socks?\""
	icon_state = "fem_sec"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/fem_sec, 32)

/obj/structure/sign/poster/contraband/ff_contest/kft_crazy_nuggets
	name = "KFT - Crazy Nuggets Bucket!"
	desc = "Because of recent Teshari's Independence Day, Crazy Nuggets Buckets are available - for only 4 credits!"
	icon_state = "kft_crazy_nuggets"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/kft_crazy_nuggets, 32)

/obj/structure/sign/poster/contraband/ff_contest/snuff_the_mascots
	name = "Snuff the Mascots"
	desc = "No heroes, no mascots. The Syndicate cuts deeper."
	icon_state = "snuff_the_mascots"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/snuff_the_mascots, 32)


/obj/structure/sign/poster/contraband/ff_contest/mouse_riot
	name = "Mouse Riot"
	desc = "The little mouse on the poster is staging his little rebellion and sabotaging the power grid. Why are you any worse?! Get off your ass and make a revolution!!!"
	icon_state = "mouse_riot"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/mouse_riot, 32)

/obj/structure/sign/poster/contraband/ff_contest/slay_them
	name = "Slay Them!"
	desc = "Man, this station stinks. I fucking hate these crew."
	icon_state = "slay_them"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/slay_them, 32)

/obj/structure/sign/poster/contraband/ff_contest/lust_fish
	name = "Lust Fish"
	desc = "A suggestive fat shark tail, promoting you to visit LushFish.nt - a newest competitor to the most popular erotic site in the NTnet, WetSkrells. Slogans promise 'most delicate slices of agurkraal and russian akulas you ever seen from all around the galaxy'. Something seems fishy about it."
	icon_state = "lust_fish"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/lust_fish, 32)

/obj/structure/sign/poster/contraband/ff_contest/no_one_will_help
	name = "No one will help you."
	desc = "ERT won't help you. Just give up."
	icon_state = "no_one_will_help"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/no_one_will_help, 32)

/obj/structure/sign/poster/contraband/ff_contest/skrell_it
	name = "Skrell It!"
	desc = "Hot and wet Skrells are already waiting for you on WetSkrells.nt."
	icon_state = "skrell_it"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/skrell_it, 32)

/obj/structure/sign/poster/contraband/ff_contest/into_nuclear_ashes
	name = "Into Nuclear Ashes"
	desc = "The Syndicate declares its intentions to fight the corporocracy by any means necessary."
	icon_state = "into_nuclear_ashes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/into_nuclear_ashes, 32)

/obj/structure/sign/poster/contraband/ff_contest/cult_con_25xx
	name = "Cult Con 25XX"
	desc = "The poster encourages you to join the annual Cult Con. Even if you can't read, that shouldn't be a problem."
	icon_state = "cult_con_25xx"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/cult_con_25xx, 32)

/obj/structure/sign/poster/contraband/ff_contest/interdine_medication
	name = "Interdine medication for everyone!"
	desc = "The poster is an advert for the services and medicine produced by Interdine. And it gives off a weird vibe... I'll have to buy some headache pills from them."
	icon_state = "interdine_medication"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/interdine_medication, 32)

/obj/structure/sign/poster/contraband/ff_contest/melty_mel
	name = "Melty Mel"
	desc = "\"Don't worry, she is professional. She won't bite... She will swallow! Melt in the pleasure!\""
	icon_state = "melty_mel"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/melty_mel, 32)

/obj/structure/sign/poster/contraband/ff_contest/bunny_skrell
	name = "Bunny Skrell"
	desc = "Be like a skrell - be a bunny"
	icon_state = "bunny_skrell"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/bunny_skrell, 32)

/obj/structure/sign/poster/contraband/ff_contest/time_to_choose
	name = "Time to Choose"
	desc = "It's time to choose between bad and terrible."
	icon_state = "time_to_choose"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/time_to_choose, 32)

/obj/structure/sign/poster/contraband/ff_contest/party_proud
	name = "Party Proud"
	desc = "What if you +15 credits blowing up station?"
	icon_state = "party_proud"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/party_proud, 32)

/obj/structure/sign/poster/contraband/ff_contest/nobody
	name = "Nobody"
	desc = "They laughed at you... Mocked your stutter... Cooked chicken wings right in front of you and offered you to eat them. They didn't notice you... To them, you were nobody. It's time for revenge."
	icon_state = "nobody"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/nobody, 32)

/obj/structure/sign/poster/contraband/ff_contest/they_laughed_at_you
	name = "They Laughed at You"
	desc = "They laughed at you... Mocked your stutter... Cooked chicken wings right in front of you and offered you to eat them. And you ate, but not just the wings..."
	icon_state = "they_laughed_at_you"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/they_laughed_at_you, 32)

/obj/structure/sign/poster/contraband/ff_contest/blood_red_flag
	name = "Blood-red Flag"
	desc = "They fell so long ago, but the workers don't stop believing. The flag smelled of gunpowder and iron... Wait, who printed it as a poster?!"
	icon_state = "blood_red_flag"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/blood_red_flag, 32)

/obj/structure/sign/poster/contraband/ff_contest/trust
	name = "Trust"
	desc = "One person, two sides. Will you be able to trust your people in this tin can when you find out who they really are?..."
	icon_state = "trust"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/trust, 32)

/obj/structure/sign/poster/contraband/ff_contest/wanted_by_syndicate_1
	name = "Wanted by the Syndicate - 1"
	desc = "These individuals are wanted by the Syndicate, and there is a high reward for their heads... However, it seems that the names and prices have long been erased."
	icon_state = "wanted_by_syndicate_1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/wanted_by_syndicate_1, 32)

/obj/structure/sign/poster/contraband/ff_contest/wanted_by_syndicate_2
	name = "Wanted by the Syndicate - 2"
	desc = "These individuals are wanted by the Syndicate, and there is a high reward for their heads... However, it seems that the names and prices have long been erased."
	icon_state = "wanted_by_syndicate_2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/wanted_by_syndicate_2, 32)

/obj/structure/sign/poster/contraband/ff_contest/spiders
	name = "Spiders!"
	desc = "This poster explains how to deal with spiders at the station... But, can spiders hack the airlock and be invisible?"
	icon_state = "spiders"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/spiders, 32)

/obj/structure/sign/poster/contraband/ff_contest/borers
	name = "Borers!"
	desc = "The Borers are not evil at all! They came to help us, to make us better! Let Borer in, get his love."
	icon_state = "borers"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/borers, 32)

/obj/structure/sign/poster/contraband/ff_contest/ai_friend_question
	name = "AI your friend?"
	desc = "Be careful, AI may not be as good a friend as you are told."
	icon_state = "ai_friend_question"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/ai_friend_question, 32)

/obj/structure/sign/poster/contraband/ff_contest/cursed_love
	name = "Cursed Love"
	desc = "The entire contents of the poster were crossed out... In blood? The only inscription read - run. It looks very suspicious."
	icon_state = "cursed_love"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/cursed_love, 32)

/obj/structure/sign/poster/contraband/ff_contest/worker_and_peasant
	name = "Worker and Peasant"
	desc = "The poster has been battered by time. The text on the poster is now impossible to read, but it still evokes some strange feelings."
	icon_state = "worker_and_peasant"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ff_contest/worker_and_peasant, 32)

/obj/structure/sign/poster/contraband/syndicate_medical
	name = "Syndicate Medical"
	desc = "This poster celebrates the complete successful revival of an hour-dead, six person mining team by Syndicate Operatives. Written in the corner is a simple message, 'Stay Winning.'"
	icon_state = "poster_sr_syndiemed"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/syndicate_medical, 32)

/obj/structure/sign/poster/contraband/crocin_pool
	name = "SWIM"
	desc = "This poster dramatically states; 'SWIM'. It seems to be advertising the use of Crocin.. 'recreationally', in the home, work, and, most ominously, 'the pool'. A 'MamoTramsem' logo is in the corner."
	icon_state = "poster_sr_crocin"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/crocin_pool, 32)

/obj/structure/sign/poster/contraband/icebox_moment
	name = "As above, so below"
	desc = "This poster seems to be instill that a 'Head of Security's Office being overtop a syndicate installation is only fitting. As above.. so below.'"
	icon_state = "poster_sr_abovebelow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/icebox_moment, 32)

/obj/structure/sign/poster/contraband/shipstation
	name = "Flight Services - Enlist"
	desc = "This poster depicts the long deprecated 'Ship' class 'station' in its hayday. Surprisingly, the poster seems to be Nanotrasen official; though with how hush they've been on the topic..."
	icon_state = "poster_sr_shipstation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/shipstation, 32)

/obj/structure/sign/poster/contraband/operative_duffy
	name = "CASH REWARD"
	desc = "This poster depicts a gas mask, with details on how to 'forward information' on the whereabouts of whoever it means... though it doesn't specify to who."
	icon_state = "poster_sr_duffy"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/operative_duffy, 32)

/obj/structure/sign/poster/contraband/ultra
	name = "ULTRA"
	desc = "This poster has one word on it, 'ULTRA'; it depicts a smiling pill next to a beaker. Ominous."
	icon_state = "poster_sr_ultra"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/ultra, 32)

/obj/structure/sign/poster/contraband/secborg_vale
	name = "Defaced Valeborg Advertisement"
	desc = "This poster originally sought to advertise the sleek utility of the valeborg - but it seems to have been long since defaced. One word lies on top; 'RUN.' - Perhaps fitting, considering the security model shown."
	icon_state = "poster_sr_valeborg"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/secborg_vale, 32)

/obj/structure/sign/poster/contraband/killingjoke
	name = "You don't have to be crazy to work here - but it sure helps!"
	desc = "A poster boldly stating that being insane abord Nanotrasen stations isn't required. But it doesn't hurt to have!"
	icon_state = "poster_sr_killingjoke"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/killingjoke, 32)

/obj/structure/sign/poster/contraband/korpstech
	name = "Empire Enhancements"
	desc = "This poster bears a huge, pink helix on it, with smaller text underneath it that mentions some alleged genetic advancements from a long time ago."
	icon_state = "korpsposter"
	never_random = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/korpstech, 32)

