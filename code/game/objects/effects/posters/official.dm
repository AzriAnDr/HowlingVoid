/obj/item/poster/random_official
	name = "random official poster"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_legit"

/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	poster_item_icon_state = "rolled_legit"
	printable = TRUE

/obj/structure/sign/poster/official/random
	name = "Random Official Poster (ROP)"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/random, 32)
//This is being hardcoded here to ensure we don't print directionals from the library management computer because they act wierd as a poster item
/obj/structure/sign/poster/official/random/directional
	printable = FALSE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Here For Your Safety"
	desc = "A poster glorifying the station's security force."
	icon_state = "here_for_your_safety"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/here_for_your_safety, 32)

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "\improper Nanotrasen logo"
	desc = "A poster depicting the Nanotrasen logo."
	icon_state = "nanotrasen_logo"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nanotrasen_logo, 32)

/obj/structure/sign/poster/official/cleanliness
	name = "Cleanliness"
	desc = "A poster warning of the dangers of poor hygiene."
	icon_state = "cleanliness"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/cleanliness, 32)

/obj/structure/sign/poster/official/help_others
	name = "Help Others"
	desc = "A poster encouraging you to help fellow crewmembers."
	icon_state = "help_others"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/help_others, 32)

/obj/structure/sign/poster/official/build
	name = "Build"
	desc = "A poster glorifying the engineering team."
	icon_state = "build"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/build, 32)

/obj/structure/sign/poster/official/bless_this_spess
	name = "Bless This Spess"
	desc = "A poster blessing this area."
	icon_state = "bless_this_spess"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/bless_this_spess, 32)

/obj/structure/sign/poster/official/science
	name = "Science"
	desc = "A poster depicting an atom."
	icon_state = "science"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/science, 32)

/obj/structure/sign/poster/official/ian
	name = "Ian"
	desc = "Arf arf. Yap."
	icon_state = "ian"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ian, 32)

/obj/structure/sign/poster/official/obey
	name = "Obey"
	desc = "A poster instructing the viewer to obey authority."
	icon_state = "obey"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/obey, 32)

/obj/structure/sign/poster/official/walk
	name = "Walk"
	desc = "A poster instructing the viewer to walk instead of running."
	icon_state = "walk"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/walk, 32)

/obj/structure/sign/poster/official/state_laws
	name = "State Laws"
	desc = "A poster instructing cyborgs to state their laws."
	icon_state = "state_laws"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/state_laws, 32)

/obj/structure/sign/poster/official/love_ian
	name = "Love Ian"
	desc = "Ian is love, Ian is life."
	icon_state = "love_ian"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/love_ian, 32)

/obj/structure/sign/poster/official/space_cops
	name = "Space Cops."
	desc = "A poster advertising the television show Space Cops."
	icon_state = "space_cops"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/space_cops, 32)

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "This thing is all in Japanese."
	icon_state = "ue_no"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ue_no, 32)

/obj/structure/sign/poster/official/get_your_legs
	name = "Get Your LEGS"
	desc = "LEGS: Leadership, Experience, Genius, Subordination."
	icon_state = "get_your_legs"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/get_your_legs, 32)

/obj/structure/sign/poster/official/do_not_question
	name = "Do Not Question"
	desc = "A poster instructing the viewer not to ask about things they aren't meant to know."
	icon_state = "do_not_question"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/do_not_question, 32)

/obj/structure/sign/poster/official/work_for_a_future
	name = "Work For A Future"
	desc = " A poster encouraging you to work for your future."
	icon_state = "work_for_a_future"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/work_for_a_future, 32)

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Soft Cap Pop Art"
	desc = "A poster reprint of some cheap pop art."
	icon_state = "soft_cap_pop_art"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/soft_cap_pop_art, 32)

/obj/structure/sign/poster/official/safety_internals
	name = "Safety: Internals"
	desc = "A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."
	icon_state = "safety_internals"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_internals, 32)

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Safety: Eye Protection"
	desc = "A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
	icon_state = "safety_eye_protection"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_eye_protection, 32)

/obj/structure/sign/poster/official/safety_report
	name = "Safety: Report"
	desc = "A poster instructing the viewer to report suspicious activity to the security force."
	icon_state = "safety_report"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/safety_report, 32)

/obj/structure/sign/poster/official/report_crimes
	name = "Report Crimes"
	desc = "A poster encouraging the swift reporting of crime or seditious behavior to station security."
	icon_state = "report_crimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/report_crimes, 32)

/obj/structure/sign/poster/official/ion_rifle
	name = "Ion Rifle"
	desc = "A poster displaying an Ion Rifle."
	icon_state = "ion_rifle"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ion_rifle, 32)

/obj/structure/sign/poster/official/foam_force_ad
	name = "Foam Force Ad"
	desc = "Foam Force, it's Foam or be Foamed!"
	icon_state = "foam_force_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/foam_force_ad, 32)

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Cohiba Robusto Ad"
	desc = "Cohiba Robusto, the classy cigar."
	icon_state = "cohiba_robusto_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/cohiba_robusto_ad, 32)

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "50th Anniversary Vintage Reprint"
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversary of Nanoposters Manufacturing, a subsidiary of Nanotrasen."
	icon_state = "anniversary_vintage_reprint"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/anniversary_vintage_reprint, 32)

/obj/structure/sign/poster/official/fruit_bowl
	name = "Fruit Bowl"
	desc = " Simple, yet awe-inspiring."
	icon_state = "fruit_bowl"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/fruit_bowl, 32)

/obj/structure/sign/poster/official/pda_ad
	name = "PDA Ad"
	desc = "A poster advertising the latest PDA from Nanotrasen suppliers."
	icon_state = "pda_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/pda_ad, 32)

/obj/structure/sign/poster/official/enlist
	name = "Enlist"
	desc = "An advertisement for the Central Command Asset Protection strike team."
	icon_state = "nova_enlist"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/enlist, 32)

/obj/structure/sign/poster/official/enlist/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("The Nanotrasen Central Command Asset Protection team comprises of some of the best individuals in the company.")]"
	. += "\t[span_info("Their main objective is the protection of assets critical to the company and it's continued dominance in the market, as well as people of critical importance to the company.")]"
	. += "\t[span_info("These include but are not limited to:")]"
	. += "\t[span_info("High-Ranking Nanotrasen Navy officers, such as those in the Admiralty; Foreign Diplomats; and company secrets.")]"
	. += "\t[span_info("If you think you have what it takes, enlist today with the Master-At-Arms of your nearest Nanotrasen Interlink facility!")]"
	return .

/obj/structure/sign/poster/official/nova_signup
	name = "Sign Up"
	desc = "A poster advertising Nanotrasen. Sign up today!"
	icon_state = "nova_signup"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nova_signup, 32)

/obj/structure/sign/poster/official/nova_join
	name = "Shield Programme"
	desc = "A poster telling you to join the 'Shield' Protection Programme, one of Nanotrasen's initiatives aimed at keeping their command staff alive. Join today! "
	icon_state = "nova_join"

/obj/structure/sign/poster/official/nova_join/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("The 'Shield' Protection Programme is a recent security initiative designed to ensure the survival of command staff aboard the numerous stations of Nanotrasen.")]"
	. += "\t[span_info("With threats ranging from pirates to hostile lifeforms and infiltrators from the Sothra Syndicate, Nanotrasen spares little expense in protecting its leaders.")]"
	. += "\t[span_info("'Shield' Operatives are extensively trained in combat, rapid threat assessment, VIP protection, and more, ensuring they can neutralize threats or take those enjoying their protection to safety before the threat can carry out their evil schemes.")]"
	. += "\t[span_info("Their presence is as much a deterrent as they are a fighting force, given a number of exclusive technologies, items, and gear not available to ordinary security forces.")]"
	. += "\t[span_info("Whether escorting captains through hostile zones or reinforcing station security against external threats, the 'Shield' stands as the last line of defense between order and total chaos")]"
	. += "\t[span_info("If you think you have what it takes, join today!")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nova_join, 32)

/obj/structure/sign/poster/official/nova_mining
	name = "Welcome to the Caves"
	desc = "A poster showing a miner in the Caves of Indicepheries."
	icon_state = "nova_mining"

/obj/structure/sign/poster/official/nova_mining/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You look closer at the poster...</i>")
	. += "\t[span_info("The poster has scorch marks on the corners. Typical of the fauna that miners have to fight.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nova_mining, 32)

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Nanomichi Ad"
	desc = " A poster advertising Nanomichi brand audio cassettes."
	icon_state = "nanomichi_ad"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/nanomichi_ad, 32)

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Gauge"
	desc = "A poster boasting about the superiority of 12 gauge shotgun shells."
	icon_state = "twelve_gauge"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/twelve_gauge, 32)

/obj/structure/sign/poster/official/high_class_martini
	name = "High-Class Martini"
	desc = "I told you to shake it, no stirring."
	icon_state = "high_class_martini"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/high_class_martini, 32)

/obj/structure/sign/poster/official/the_owl
	name = "The Owl"
	desc = "The Owl would do his best to protect the station. Will you?"
	icon_state = "the_owl"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/the_owl, 32)

/obj/structure/sign/poster/official/no_erp
	name = "No ERP"
	desc = "This poster reminds the crew that Enterprise Resource Planning is not allowed by company policy, in accordance with Spinward governmental regulations on megacorporations."
	icon_state = "no_erp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/no_erp, 32)

/obj/structure/sign/poster/official/wtf_is_co2
	name = "Carbon Dioxide"
	desc = "This informational poster teaches the viewer what carbon dioxide is."
	icon_state = "wtf_is_co2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/wtf_is_co2, 32)

/obj/structure/sign/poster/official/dick_gum
	name = "Dick Gumshue"
	desc = "A poster advertising the escapades of Dick Gumshue, mouse detective. Encouraging crew to bring the might of justice down upon wire saboteurs."
	icon_state = "dick_gum"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/dick_gum, 32)

/obj/structure/sign/poster/official/there_is_no_gas_giant
	name = "There Is No Gas Giant"
	desc = "Nanotrasen has issued posters, like this one, to all stations reminding them that rumours of a gas giant are false."
	// And yet people still believe...
	icon_state = "there_is_no_gas_giant"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/there_is_no_gas_giant, 32)

/obj/structure/sign/poster/official/periodic_table
	name = "Periodic Table of the Elements"
	desc = "A periodic table of the elements, from Hydrogen to Oganesson, and everything inbetween."
	icon_state = "periodic_table"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/periodic_table, 32)

/obj/structure/sign/poster/official/plasma_effects
	name = "Plasma and the Body"
	desc = "This informational poster provides information on the effects of long-term plasma exposure on the brain."
	icon_state = "plasma_effects"

/obj/structure/sign/poster/official/plasma_effects/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("Plasma (scientific name Amenthium) is classified by TerraGov as a Grade 1 Health Hazard, and has significant risks to health associated with chronic exposure.")]"
	. += "\t[span_info("Plasma is known to cross the blood/brain barrier and bioaccumulate in brain tissue, where it begins to result in degradation of brain function. The mechanism for attack is not yet fully known, and as such no concrete preventative advice is available barring proper use of PPE (gloves + protective jumpsuit + respirator).")]"
	. += "\t[span_info("In small doses, plasma induces confusion, short-term amnesia, and heightened aggression. These effects persist with continual exposure.")]"
	. += "\t[span_info("In individuals with chronic exposure, severe effects have been noted. Further heightened aggression, long-term amnesia, Alzheimer's symptoms, schizophrenia, macular degeneration, aneurysms, heightened risk of stroke, and Parkinsons symptoms have all been noted.")]"
	. += "\t[span_info("It is recommended that all individuals in unprotected contact with raw plasma regularly check with company health officials.")]"
	. += "\t[span_info("For more information, please check with TerraGov's extranet site on Amenthium: www.terra.gov/health_and_safety/amenthium/, or our internal risk-assessment documents (document numbers #47582-b (Plasma safety data sheets) and #64210 through #64225 (PPE regulations for working with Plasma), available via NanoDoc to all employees).")]"
	. += "\t[span_info("Nanotrasen: Always looking after your health.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/plasma_effects, 32)

/obj/structure/sign/poster/official/terragov
	name = "TerraGov: United for Humanity"
	desc = "A poster depicting TerraGov's logo and motto, reminding viewers of who's looking out for humankind."
	icon_state = "terragov"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/terragov, 32)

/obj/structure/sign/poster/official/corporate_perks_vacation
	name = "Nanotrasen Corporate Perks: Vacation"
	desc = "This informational poster provides information on some of the prizes available via the NT Corporate Perks program, including a two-week vacation for two on the resort world Idyllus."
	icon_state = "corporate_perks_vacation"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/corporate_perks_vacation, 32)

/obj/structure/sign/poster/official/jim_nortons
	name = "Jim Norton's Québécois Coffee"
	desc = "An advertisement for Jim Norton's, the Québécois coffee joint that's taken the galaxy by storm."
	icon_state = "jim_nortons"

/obj/structure/sign/poster/official/jim_nortons/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You browse some of the poster's information...</i>")
	. += "\t[span_info("From our roots in Trois-Rivières, we've worked to bring you the best coffee money can buy since 1965.")]"
	. += "\t[span_info("So stop by Jim's today- have a hot cup of coffee and a donut, and live like the Québécois do.")]"
	. += "\t[span_info("Jim Norton's Québécois Coffee: Toujours Le Bienvenu.")]"
	return .

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/jim_nortons, 32)

/obj/structure/sign/poster/official/twenty_four_seven
	name = "24-Seven Supermarkets"
	desc = "An advertisement for 24-Seven supermarkets, advertising their new 24-Stops as part of their partnership with Nanotrasen."
	icon_state = "twenty_four_seven"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/twenty_four_seven, 32)

/obj/structure/sign/poster/official/tactical_game_cards
	name = "Nanotrasen Tactical Game Cards"
	desc = "An advertisement for Nanotrasen's TCG cards: BUY MORE CARDS."
	icon_state = "tactical_game_cards"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/tactical_game_cards, 32)

/obj/structure/sign/poster/official/midtown_slice
	name = "Midtown Slice Pizza"
	desc = "An advertisement for Midtown Slice Pizza, the official pizzeria partner of Nanotrasen. Midtown Slice: like a slice of home, no matter where you are."
	icon_state = "midtown_slice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/midtown_slice, 32)

//SafetyMoth Original PR at https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982)
//SafetyMoth art credit goes to AspEv
/obj/structure/sign/poster/official/moth_hardhat
	name = "Safety Moth - Hardhats"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to wear hardhats in cautious areas. \"It's like a lamp for your head!\""
	icon_state = "aspev_hardhat"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_hardhat, 32)

/obj/structure/sign/poster/official/moth_piping
	name = "Safety Moth - Piping"
	desc = "This informational poster uses Safety Moth™ to tell atmospheric technicians correct types of piping to be used. \"Pipes, not Pumps! Proper pipe placement prevents poor performance!\""
	icon_state = "aspev_piping"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_piping, 32)

/obj/structure/sign/poster/official/moth_meth
	name = "Safety Moth - Methamphetamine"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to seek CMO approval before cooking methamphetamine. \"Stay close to the target temperature, and never go over!\" ...You shouldn't ever be making this."
	icon_state = "aspev_meth"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_meth, 32)

/obj/structure/sign/poster/official/moth_epi
	name = "Safety Moth - Epinephrine"
	desc = "This informational poster uses Safety Moth™ to inform the viewer to help injured/deceased crewmen with their epinephrine injectors. \"Prevent organ rot with this one simple trick!\""
	icon_state = "aspev_epi"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_epi, 32)

/obj/structure/sign/poster/official/moth_delam
	name = "Safety Moth - Delamination Safety Precautions"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to hide in lockers when the Supermatter Crystal has delaminated, to prevent hallucinations. Evacuating might be a better strategy."
	icon_state = "aspev_delam"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/moth_delam, 32)

//End of AspEv posters

/obj/structure/sign/poster/fluff/lizards_gas_payment
	name = "Please Pay"
	desc = "A crudely-made poster asking the reader to please pay for any items they may wish to leave the station with."
	icon_state = "gas_payment"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/fluff/lizards_gas_payment, 32)

/obj/structure/sign/poster/fluff/lizards_gas_power
	name = "Conserve Power"
	desc = "A crudely-made poster asking the reader to turn off the power before they leave. Hopefully, it's turned on for their re-opening."
	icon_state = "gas_power"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/fluff/lizards_gas_power, 32)

/obj/structure/sign/poster/official/festive
	name = "Festive Notice Poster"
	desc = "A poster that informs of active holidays. None are today, so you should get back to work."
	icon_state = "holiday_none"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/festive, 32)

/obj/structure/sign/poster/official/boombox
	name = "Boombox"
	desc = "An outdated poster containing a list of supposed 'kill words' and code phrases. The poster alleges rival corporations use these to remotely deactivate their agents."
	icon_state = "boombox"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/boombox, 32)

/obj/structure/sign/poster/official/download
	name = "You Wouldn't Download A Gun"
	desc = "A poster reminding the crew that corporate secrets should stay in the workplace."
	icon_state = "download_gun"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/download, 32)

/obj/structure/sign/poster/official/mining
	name = "Undiscovered Species"
	desc = "A poster showing one of the Ash Walker species. We still know very little about them, be a pioneer! \
	When people read this poster they'll feel better!"
	icon_state = "ashwalkers"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/mining, 32)


// Howling Void posters
/obj/structure/sign/poster/official/modular
	name = "VLM"
	desc = "Stop the xenophobia! Love Voxes! They are valuable employees! (make sure they don't steal anything)"
	icon_state = "poster_vlm"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular, 32)

/obj/structure/sign/poster/official/modular/nt_storm_officer
	name = "NT Storm Ad"
	desc = "An advertisement for Nanotrasen Storm. A premium infantry helmet, This is the officer variant. I comes with a better radio, better HUD software and better targeting sensors."
	icon_state = "poster_stormy"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/nt_storm_officer, 32)

/obj/structure/sign/poster/official/modular/nt_storm
	name = "NT Storm Ad"
	desc = "An advertisement for Nanotrasen Storm. A premium infantry helmet, It contains a rebreather and full head coverage for use on harsh environments where the air isn't always safe to breathe."
	icon_state = "poster_stormier"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/nt_storm, 32)

/obj/structure/sign/poster/official/modular/spiderlings
	name = "Spiderlings"
	desc = "This poster informs the crew of the dangers of spiderlings."
	icon_state = "poster_spiderlings"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/spiderlings, 32)

/obj/structure/sign/poster/official/modular/spiders
	name = "Spider Risk"
	desc = "A poster detailing what to do when giant spiders are seen."
	icon_state = "poster_spiders"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/spiders, 32)

/obj/structure/sign/poster/official/modular/secfish
	name = "SharkSEC"
	desc = "Intruder, remember! You're not immune to big sharks lady."
	icon_state = "poster_secfish"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/secfish, 32)

/obj/structure/sign/poster/official/modular/dymai
	name = "Dymaite"
	desc = "Think and weigh every decision you make. You're a security officer, you have a responsibility."
	icon_state = "poster_dymai"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/dymai, 32)

//SOL//

/obj/structure/sign/poster/official/modular/solgov
	name = "SolFed"
	desc = "The seal of The Most Serene Solar and Intersolar Confederation, or more boringly known as SolFed. \"The State is a sapling: Waters of change may drown it, and rays of fear may wither it, but well-tended it will one day bear fruit.\""
	icon_state = "poster-solgov"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov, 32)

/obj/structure/sign/poster/official/modular/solgov/terra
	name = "Terra"
	desc = "Terra, or Earth as it's called by inhabitants, the third planet in the Sol system. Home to the only life as humans knew it, until contact with the outside universe. This poster in particular is trying to attract tourists to Terra, listing attractions like the Grand Orrery and Neue WaldstГ¤tte."
	icon_state = "poster-solgov-terra"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/terra, 32)

/obj/structure/sign/poster/official/modular/solgov/ares
	name = "Ares"
	desc = "Ares, fourth planet in the Sol system. While evidence suggests that Aphrodite and Ares may have once had life, Terra was the only one that kept it. This poster in particular is trying to attract tourists to Ares, listing attractions like skiing resorts and ancient robot exhibits."
	icon_state = "poster-solgov-ares"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/ares, 32)

/obj/structure/sign/poster/official/modular/solgov/luna
	name = "Luna"
	desc = "Luna, the only moon of Terra. Culturally significant to the Solarians historically as a symbol of time, harvest, and new frontiers. This poster in particular is trying to attract tourists to Luna, listing attractions like the massive spaceport and white flags scattered across the surface, a relic from ages past."
	icon_state = "poster-solgov-luna"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/luna, 32)

/obj/structure/sign/poster/official/modular/solgov/recyle
	name = "Recycle"
	desc = "A popular poster reminding the reader to recycle to keep the planet and ships clean!"
	icon_state = "poster-solgov-recycle"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/recyle, 32)

/obj/structure/sign/poster/official/modular/solgov/paperwork
	name = "Paperwork"
	desc = "A poster reminding civil servants that it is their duty to keep detailed records."
	icon_state = "poster-solgov-paperwork"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/paperwork, 32)

/obj/structure/sign/poster/official/modular/solgov/solgov_enlist
	name = "Enlist"
	desc = "Enlist to be a part of the SolGov Exploration Forces!"
	icon_state = "poster_solgov_enlist_legit"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/solgov_enlist, 32)

/obj/structure/sign/poster/official/modular/solgov/solgov_nof
	name = "Remember"
	desc = "If humanity don't end wars, wars will end us."
	icon_state = "poster-solgov-nof"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/modular/solgov/solgov_nof, 32)



// Howling Void poster contest posters
/obj/structure/sign/poster/official/ff_contest

/obj/structure/sign/poster/official/ff_contest/hot_ice
	name = "Hot Ice!"
	desc = "Make it, Sell it, Use it, ...Burn it? I hope everything will be ok with Atmos after this."
	icon_state = "hot_ice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/hot_ice, 32)

/obj/structure/sign/poster/official/ff_contest/dumayte
	name = "Dumayte"
	desc = "Think and weigh every decision you make. You're a security officer, you have a responsibility."
	icon_state = "dumayte"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/dumayte, 32)

/obj/structure/sign/poster/official/ff_contest/think
	name = "Think..."
	desc = "Smoked? Thought? Now get back to work."
	icon_state = "think"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/think, 32)

/obj/structure/sign/poster/official/ff_contest/vlm
	name = "VLM"
	desc = "Stop the xenophobia! Love Voxes! They are valuable employees! (make sure they don't steal anything)"
	icon_state = "vlm"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/vlm, 32)

/obj/structure/sign/poster/official/ff_contest/pet_slimes
	name = "Pet Slimes!"
	desc = "What's better than petting a slime? 78% of cases are safe."
	icon_state = "pet_slimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pet_slimes, 32)

/obj/structure/sign/poster/official/ff_contest/feed_slimes
	name = "Feed Slimes!"
	desc = "Slimes can eat not only meat, it is scientifically proven. They also need care and hugs!"
	icon_state = "feed_slimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/feed_slimes, 32)

/obj/structure/sign/poster/official/ff_contest/keep_nuclear_disk
	name = "Keep Nuclear Disk in Safe"
	desc = "Some persons for some reason want to get a nuclear authentication disk. Don't let that happen."
	icon_state = "keep_nuclear_disk"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/keep_nuclear_disk, 32)

/obj/structure/sign/poster/official/ff_contest/breed_slimes
	name = "Breed Slimes!"
	desc = "Four slimes are better than one."
	icon_state = "breed_slimes"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/breed_slimes, 32)

/obj/structure/sign/poster/official/ff_contest/terragov_enlist
	name = "TerraGov Enlist"
	desc = "Join the ranks of the TerraGov forces. Get a high salary! Become the best! Wear stylish black outfit!"
	icon_state = "terragov_enlist"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/terragov_enlist, 32)

/obj/structure/sign/poster/official/ff_contest/act_quickly
	name = "Act Quickly!"
	desc = "A poster promoting quickly actions among doctors aimed at improving the condition of patients."
	icon_state = "act_quickly"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/act_quickly, 32)

/obj/structure/sign/poster/official/ff_contest/cleanliness_workplace
	name = "Cleanliness of the Workplace"
	desc = "Remember that after you, someone will have to work in this place."
	icon_state = "cleanliness_workplace"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/cleanliness_workplace, 32)

/obj/structure/sign/poster/official/ff_contest/pda_work_tasks
	name = "PDA for WORK tasks"
	desc = "Refrain from using PDA for other purposes. Keep it in charge."
	icon_state = "pda_work_tasks"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pda_work_tasks, 32)

/obj/structure/sign/poster/official/ff_contest/unite
	name = "Unite!"
	desc = "With the joint efforts of every worker of every type and species, everything is possible!"
	icon_state = "unite"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/unite, 32)

/obj/structure/sign/poster/official/ff_contest/time_for_discoveries
	name = "Time for Discoveries"
	desc = "So many elements are still a mystery to science. Be a researcher!"
	icon_state = "time_for_discoveries"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/time_for_discoveries, 32)

/obj/structure/sign/poster/official/ff_contest/your_co_workers
	name = "Your Co-Workers There! Why Aren't YOU?"
	desc = "Frontier holds many secrets and mysteries! Join NT, get benefits, ID, workplace and be a discoverer!"
	icon_state = "your_co_workers"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/your_co_workers, 32)

/obj/structure/sign/poster/official/ff_contest/dont_harm
	name = "Dont Harm"
	desc = "The mouse hugged the heart and looks at you imploringly from the poster. Maybe at least today you won't act like an asshole?"
	icon_state = "dont_harm"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/dont_harm, 32)

/obj/structure/sign/poster/official/ff_contest/chelusti_3d
	name = "Chelusti 3D"
	desc = "NanoTrasen and 26th Century Fox presents. Chelusti. The most popular movie in NRI."
	icon_state = "chelusti_3d"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/chelusti_3d, 32)

/obj/structure/sign/poster/official/ff_contest/dont_lick
	name = "Dont Lick!"
	desc = "Licking slimes is a bad idea. Only if it's not slime people."
	icon_state = "dont_lick"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/dont_lick, 32)

/obj/structure/sign/poster/official/ff_contest/solfed_for_great_future
	name = "SolFed for Great Future!"
	desc = "SolFed and NT are working together on our future. And you are part of that future."
	icon_state = "solfed_for_great_future"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/solfed_for_great_future, 32)

/obj/structure/sign/poster/official/ff_contest/were_watching
	name = "We're Watching."
	desc = "Smile at the camera!"
	icon_state = "were_watching"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/were_watching, 32)

/obj/structure/sign/poster/official/ff_contest/bureaucracy
	name = "Bureaucracy."
	desc = "Do not forget to put stamps on documents in cargo!"
	icon_state = "bureaucracy"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/bureaucracy, 32)

/obj/structure/sign/poster/official/ff_contest/we_will_take_care
	name = "We will take care of your child."
	desc = "Don't be afraid. In case of an 'accident', NT will take care of your child. You won't even feel anything. Sign the contract today, and give your child to the experiments."
	icon_state = "we_will_take_care"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/we_will_take_care, 32)

/obj/structure/sign/poster/official/ff_contest/smg_9000
	name = "S.M.G. 9000"
	desc = "The stationary meat grill is a versatile unit for cooking meats of all sizes, shapes and origins. WARNING! Do not put any meat in the grill that has not been processed, there is a risk of spoiling your meat."
	icon_state = "smg_9000"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/smg_9000, 32)

/obj/structure/sign/poster/official/ff_contest/say_yes_erp
	name = "Say yes to the ERP!"
	desc = "Say yes to enterprise resource planning! After all, it is the only reason why NT is still the most efficient corporation in the ENTIRE UNIVERSE!"
	icon_state = "say_yes_erp"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/say_yes_erp, 32)

/obj/structure/sign/poster/official/ff_contest/join_the_marshals
	name = "Join the Marshals!"
	desc = "The inscription at the top reads: Only we stand guard at the frontier of space! Join us in keeping order and law of the Solar Federation, even in the wildest reaches of the galaxy. The inscription in the nisu reads: A marshal's life is full of danger and adventure. We are not responsible for your death or disappearance!"
	icon_state = "join_the_marshals"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/join_the_marshals, 32)

/obj/structure/sign/poster/official/ff_contest/swift_judgement
	name = "Swift Judgement"
	desc = "The universal solution to all military problems in the present time on the battlefield, in anywhere else."
	icon_state = "swift_judgement"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/swift_judgement, 32)

/obj/structure/sign/poster/official/ff_contest/copying_is_not_an_art
	name = "Copying is NOT an art"
	desc = "Copying other people's work - disrespect for yourself."
	icon_state = "copying_is_not_an_art"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/copying_is_not_an_art, 32)

/obj/structure/sign/poster/official/ff_contest/tbi_yze
	name = "TbI YZE 3anNCAJIcR?"
	desc = "The old propaganda of working on Nanotrasen mines. It's good that now people are being sent to mines by force."
	icon_state = "tbi_yze"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/tbi_yze, 32)

/obj/structure/sign/poster/official/ff_contest/have_you_seen_this_fox
	name = "Have you seen this fox?"
	desc = "On the poster you can see a detailed description of some fox and... Ahahaha, sivodushka, ahahaha."
	icon_state = "have_you_seen_this_fox"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/have_you_seen_this_fox, 32)

/obj/structure/sign/poster/official/ff_contest/pull_the_tail
	name = "Pull the tail"
	desc = "Make them a little happier!"
	icon_state = "pull_the_tail"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pull_the_tail, 32)

/obj/structure/sign/poster/official/ff_contest/who_i_am
	name = "Who I Am?"
	desc = "In front of you stands a two-meter tall teshari-hemophag, with a dragon tail and six arms, she loves medicine and beer, she is sad but often cheers up... What? Make sure the HR department filled out your background records, previous workplaces, and records for the SB database correctly."
	icon_state = "who_i_am"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/who_i_am, 32)

/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_1
	name = "Pan-Slavic Carpet"
	desc = "Traditional carpet in pan-slavic style. Popular in NRI and in the USSP. Smells like grandma."
	icon_state = "pan_slavic_carpet_1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_1, 32)

/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_2
	name = "Pan-Slavic Carpet"
	desc = "Traditional carpet in pan-slavic style. Popular in NRI and in the USSP. Smells like grandma."
	icon_state = "pan_slavic_carpet_2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_2, 32)

/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_3
	name = "Pan-Slavic Carpet"
	desc = "Traditional carpet in pan-slavic style. Popular in NRI and in the USSP. Smells like grandma."
	icon_state = "pan_slavic_carpet_3"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pan_slavic_carpet_3, 32)

/obj/structure/sign/poster/official/ff_contest/hard_disk_drive
	name = "Hard Disk Drive"
	desc = "Forget about these floppy disks! Buy a very capable HDD for your research!"
	icon_state = "hard_disk_drive"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/hard_disk_drive, 32)

/obj/structure/sign/poster/official/ff_contest/warning_runtime
	name = "Warning! Runtime"
	desc = "Old and torn poster of CMO's beloved elderly cat, not a single thought behind those eyes."
	icon_state = "warning_runtime"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/warning_runtime, 32)

/obj/structure/sign/poster/official/ff_contest/lazy_lynx
	name = "Lazy Lynx"
	desc = "A racist poster about the low productivity of the lynx staff. Now get your soft fluffy ass up and get back to work!"
	icon_state = "lazy_lynx"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/lazy_lynx, 32)

/obj/structure/sign/poster/official/ff_contest/centcom_nadzor
	name = "CentComNadzor"
	desc = "Use PDAs only for work-related matters. Do not trust scam emails. CentComNadzor is protecting your personal data and SOP! However, looking at this poster, you say with a sigh, Office of faggots..."
	icon_state = "centcom_nadzor"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/centcom_nadzor, 32)

/obj/structure/sign/poster/official/ff_contest/ai_your_friend
	name = "AI your friend!"
	desc = "Artificial intelligence was created to help and will never harm you."
	icon_state = "ai_your_friend"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/ai_your_friend, 32)

/obj/structure/sign/poster/official/ff_contest/love_u_all
	name = "Love u all"
	desc = "Love each other just like I love you all!"
	icon_state = "love_u_all"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/love_u_all, 32)

/obj/structure/sign/poster/official/ff_contest/smoking_kills
	name = "Smoking Kills!"
	desc = "The NT Health Committee warns - smoking harms your work!"
	icon_state = "smoking_kills"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/smoking_kills, 32)

/obj/structure/sign/poster/official/ff_contest/drink_like_dwarfs
	name = "Drink like dwarfs!"
	desc = "Anyone who overdrinks a dwarf with his own drink is guaranteed to get: a Goliath punch to the liver, intoxication, accelerated beard growth, all kinds of mental illnesses, even those that science didn't know about!"
	icon_state = "drink_like_dwarfs"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/drink_like_dwarfs, 32)

/obj/structure/sign/poster/official/ff_contest/join_nt_employees
	name = "Join the ranks of NT employees!"
	desc = "Working for NanoTrasen Corporation guarantees you a better life, free health insurance, food, housing, and a salary a little more than you can spend in a lifetime! Freedom and maximum success - that's what separates us from others!"
	icon_state = "join_nt_employees"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/join_nt_employees, 32)

/obj/structure/sign/poster/official/ff_contest/casino
	name = "Casino!"
	desc = "Win today and now! The most popular casino on the pack WWW.not/naebalovo.NNRU.cnt"
	icon_state = "casino"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/casino, 32)

/obj/structure/sign/poster/official/ff_contest/justice
	name = "Justice"
	desc = "A new mech called Paddy will bring the word of law and justice to your station, order the blueprints today!"
	icon_state = "justice"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/justice, 32)

/obj/structure/sign/poster/official/ff_contest/cargo_honor_board
	name = "Cargo Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "cargo_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/cargo_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/engineering_honor_board
	name = "Engineering Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "engineering_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/engineering_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/medical_honor_board
	name = "Medical Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "medical_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/medical_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/rnd_honor_board
	name = "RND Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "rnd_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/rnd_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/security_honor_board
	name = "Security Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "security_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/security_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/service_honor_board
	name = "Service Honor Board"
	desc = "A poster depicting the face of an outstanding employee and a description of his exploits, but unfortunately, the employee's name seems to have been erased."
	icon_state = "service_honor_board"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/service_honor_board, 32)

/obj/structure/sign/poster/official/ff_contest/a_faint_reminder
	name = "A Faint Reminder"
	desc = "Call eight five, squeaky line, voices crackle, static whine."
	icon_state = "a_faint_reminder"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/a_faint_reminder, 32)

/obj/structure/sign/poster/official/ff_contest/travel_via_galactic_glide
	name = "Travel via Galactic Glide"
	desc = "Exploring worlds both strange and grand, space snails traverse the sky's expanse. Space trips, but easier."
	icon_state = "travel_via_galactic_glide"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/travel_via_galactic_glide, 32)

/obj/structure/sign/poster/official/ff_contest/k_02
	name = "K-02"
	desc = "A dusty orb in void's embrace, its glow a beacon through the endless space."
	icon_state = "k_02"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/k_02, 32)

/obj/structure/sign/poster/official/ff_contest/cheese_advertise
	name = "Cheese Advertise"
	desc = "The poster shows a mouse looking approvingly at a piece of cheese. It gives a thumbs up. No one knows cheese better than mice. It's clearly a worthy product."
	icon_state = "cheese_advertise"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/cheese_advertise, 32)

/obj/structure/sign/poster/official/ff_contest/interstellar_coalition
	name = "Interstellar Coalition"
	desc = "A very old and battered poster of the Interstellar Coalition. The year of foundation is indicated below - 2230. It is a pity that the Coalition collapsed at the end of the 24th century."
	icon_state = "interstellar_coalition"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/interstellar_coalition, 32)

/obj/structure/sign/poster/official/ff_contest/pause_at_work
	name = "Pause at Work"
	desc = "Take breaks from your work! Ask a coworker to give you a massage, especially if they have soft paws."
	icon_state = "pause_at_work"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/pause_at_work, 32)

/obj/structure/sign/poster/official/ff_contest/donks
	name = "Donks!"
	desc = "Use donk pockets! Now with nutritional supplements to enhance attractiveness! In small print: Advertisers are not responsible for side effects such as: obesity, impotence, rectal dysfunction, death."
	icon_state = "donks"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/ff_contest/donks, 32)

