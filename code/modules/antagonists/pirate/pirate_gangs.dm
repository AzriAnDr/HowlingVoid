///global lists of all pirate gangs that can show up today. they will be taken out of the global lists as spawned so dupes cannot spawn.
GLOBAL_LIST_INIT(light_pirate_gangs, init_pirate_gangs(is_heavy = FALSE))
GLOBAL_LIST_INIT(heavy_pirate_gangs, init_pirate_gangs(is_heavy = TRUE))

///initializes the pirate gangs glob list, adding all subtypes that can roll today.
/proc/init_pirate_gangs(is_heavy)
	var/list/pirate_gangs = list()

	for(var/type in subtypesof(/datum/pirate_gang))
		var/datum/pirate_gang/possible_gang = new type
		if(!possible_gang.can_roll())
			qdel(possible_gang)
		else if(possible_gang.is_heavy_threat == is_heavy)
			pirate_gangs += possible_gang
	return pirate_gangs

///datum for a pirate team that is spawning to attack the station.
/datum/pirate_gang
	///name of this gang, for spawning feedback
	var/name = "Space Bugs"

	///Whether or not this pirate crew is a heavy-level threat
	var/is_heavy_threat = FALSE
	///the random ship name chosen from pirates.json
	var/ship_name
	///the ship they load in on.
	var/ship_template_id = "ERROR"
	///the key to the json list of pirate names
	var/ship_name_pool = "some_json_key"
	///inbound message title the station receives
	var/threat_title = "Pay away the Space Bugs"
	///the contents of the message sent to the station.
	///%SHIPNAME in the content will be replaced with the pirate ship's name
	///%PAYOFF in the content will be replaced with the requested credits.
	var/threat_content = "This is the %SHIPNAME. Give us %PAYOFF credits or we bug out the universe trying to spawn!"
	///station receives this message upon the ship's spawn
	var/arrival_announcement = "We have come for your Bungopoints!"
	var/arrival_announcement_ru = "Мы пришли за вашими Бунгопоинтами!"
	///what the station can say in response, first item pays the pirates, second item rejects it.
	var/list/possible_answers = list("Please, go away! We'll pay!", "I accept oblivion.")

	///station responds to message and pays the pirates
	var/response_received = "Yum! Bungopoints!"
	var/response_received_ru = "М-м-м! Бунгопоинты!"
	///station responds to message and pays the pirates
	var/response_rejected = "Foo! No Bungopoints!"
	var/response_rejected_ru = "Фу! Никаких Бунгопоинтов!"
	///station pays the pirates, but after the ship spawned
	var/response_too_late = "Your Bungopoints arrived too late, rebooting world..."
	var/response_too_late_ru = "Ваши Бунгопоинты прибыли слишком поздно... Перезагружаем мир..."
	///station pays the pirates... but doesn't have enough cash.
	var/response_not_enough = "Not enough Bungopoints have been added into my bank account, rebooting world..."
	var/response_not_enough_ru = "На мой счёт поступило недостаточно Бунгопоинтов... Перезагружаем мир..."

	/// Have the pirates been paid off?
	var/paid_off = FALSE
	/// The colour of their announcements when sent to players
	var/announcement_color = "red"

/datum/pirate_gang/New()
	. = ..()
	ship_name = pick(strings(PIRATE_NAMES_FILE, ship_name_pool))

///whether this pirate gang can roll today. this is called when the global list initializes, so
///returning FALSE means it cannot show up at all for the entire round.
/datum/pirate_gang/proc/can_roll()
	return TRUE

///returns a new comm_message datum from this pirate gang
/datum/pirate_gang/proc/generate_message(payoff)
	var/built_threat_content = replacetext(threat_content, "%SHIPNAME", ship_name)
	built_threat_content = replacetext(built_threat_content, "%PAYOFF", payoff)
	return new /datum/comm_message(threat_title, built_threat_content, possible_answers)

///classic FTL-esque space pirates.
/datum/pirate_gang/rogues
	name = "Rogues"

	ship_template_id = "default"
	ship_name_pool = "rogue_names"

	threat_title = "Sector protection offer"
	threat_content = "Hey, pal, this is the %SHIPNAME. Can't help but notice you're rocking a wild \
		and crazy shuttle there with NO INSURANCE! Crazy. What if something happened to it, huh?! We've \
		done a quick evaluation of your rates in this sector, and we're offering %PAYOFF to cover your \
		shuttle in case of any disaster."
	arrival_announcement = "Do you want to reconsider our offer? Unfortunately, the time for negotiations has passed. Open up; we're coming aboard soon."
	arrival_announcement_ru = "Хотите пересмотреть наше предложение? Увы, время переговоров вышло. Открывайте, мы скоро будем у вас на борту."
	possible_answers = list("Purchase Insurance.","Reject Offer.")

	response_received = "Sweet, free cash. Let's get outta here, boys."
	response_received_ru = "Сладко, дармовые деньги. Валим отсюда, парни."
	response_rejected = "Not paying was a mistake, now you need to take an economics class."
	response_rejected_ru = "Отказ платить был ошибкой. Похоже, вам пора на ускоренный курс экономики."
	response_too_late = "Payment or not, ignoring us was a matter of pride. Now it's time for us to teach some respect."
	response_too_late_ru = "Платёж или нет, но игнорировать нас было вопросом чести. Пора научить вас уважению."
	response_not_enough = "You thought we wouldn't notice if you underpaid? Funny. We'll be seeing you soon."
	response_not_enough_ru = "Думали, мы не заметим недоплату? Забавно. Скоро увидимся."

///aristocrat lizards looking to hunt the serfs
/datum/pirate_gang/silverscales
	name = "Silverscales"

	ship_template_id = "silverscale"
	ship_name_pool = "silverscale_names"

	threat_title = "Tribute request"
	threat_content = "This is the %SHIPNAME. The Silver Scales wish for some tribute \
		from your plebeian lizards. %PAYOFF credits should do the trick."
	arrival_announcement = "Certainly, you don't deserve all of that aboard your vessel. It's going to fit us so much better."
	arrival_announcement_ru = "Разумеется, вы не заслуживаете всего того добра на своём судне. У нас оно будет смотреться куда лучше."
	possible_answers = list("We'll pay.","Tribute? Really? Go away.")

	response_received = "A most generous donation. May the claws of Tizira reach into the furthest points of the cosmos."
	response_received_ru = "Щедрейшее подношение. Да дотянутся когти Тизиры до самых дальних уголков космоса."
	response_rejected = "That's for nothing, the first rule of hunting is don't leave without booty."
	response_rejected_ru = "Тем хуже для вас: первое правило охоты — не уходить без добычи."
	response_too_late = "I see you're trying to pay, but the hunt is already on."
	response_too_late_ru = "Я вижу, вы пытаетесь заплатить, но охота уже началась."
	response_not_enough = "You've sent an insulting \"donation\". The hunt is on for you."
	response_not_enough_ru = "Вы прислали оскорбительное «пожертвование». Теперь охота объявлена на вас."

///undead skeleton crew looking for booty
/datum/pirate_gang/skeletons
	name = "Skeleton Pirates"

	is_heavy_threat = TRUE
	ship_template_id = "dutchman"
	ship_name_pool = "skeleton_names" //just points to THE ONE AND ONLY

	threat_title = "Transfer of goods"
	threat_content = "Ahoy! This be the %SHIPNAME. Cough up %PAYOFF credits or you'll walk the plank."
	arrival_announcement = "The Jolly Roger won't wait forever, maties; we're lying alongside, ready to send you some gifts."
	arrival_announcement_ru = "Весёлый Роджер не будет ждать вечно, братцы. Мы уже рядом и готовы заслать вам пару подарков."
	possible_answers = list("We'll pay.","We will not be extorted.")

	response_received = "Thanks for the credits, landlubbers."
	response_received_ru = "Спасибо за кредиты, сухопутные крысы."
	response_rejected = "Blimey! All hands on deck, we're going to get their riches!"
	response_rejected_ru = "Чёрт возьми! Всем по местам, забираем их богатства!"
	response_too_late = "Too late to beg for mercy!"
	response_too_late_ru = "Слишком поздно молить о пощаде!"
	response_not_enough = "Trying to cheat us? You'll regret this!"
	response_not_enough_ru = "Пытаетесь нас обмануть? Вы об этом пожалеете!"

///Expirienced formed employes of Interdyne Pharmaceutics now in a path of thievery and reckoning
/datum/pirate_gang/interdyne
	name = "Restless Ex-Pharmacists"

	is_heavy_threat = TRUE
	ship_template_id = "ex_interdyne"
	ship_name_pool = "interdyne_names"

	threat_title = "Funding for Research"
	threat_content = "Greetings, this is the %SHIPNAME. We require some funding for our pharmaceutical operations. \
		%PAYOFF credits should suffice."
	arrival_announcement = "We humbly ask for a substantial amount of income for the future research of our cause. It sure would be a shame if you got sick, but we can fix that."
	arrival_announcement_ru = "Мы смиренно просим значительную сумму на будущие исследования нашего дела. Было бы очень жаль, если бы вы внезапно заболели... хотя мы могли бы это исправить."
	possible_answers = list("Very well.","Get a job!")

	response_received = "Thank you for your generosity. Your money will not be wasted."
	response_received_ru = "Благодарим за щедрость. Ваши деньги не будут потрачены зря."
	response_rejected = "Oh, you're not a station, you're a tumor. Well, we're gonna have to cut it out."
	response_rejected_ru = "О, да вы не станция, а опухоль. Похоже, придётся её вырезать."
	response_too_late = "We hope you like skin cancer!"
	response_too_late_ru = "Надеемся, вам понравится рак кожи!"
	response_not_enough = "This is not nearly enough for our operations. I'm afraid we'll have to borrow some."
	response_not_enough_ru = "Этого и близко не хватит на наши операции. Боюсь, нам придётся занять остальное у вас силой."
	announcement_color = "purple"

///Previous Nanotrasen Assitant workers fired for many reasons now looking for revenge and your bank account.
/datum/pirate_gang/grey
	name = "The Grey Tide"

	ship_template_id = "grey"
	ship_name_pool = "grey_names"

	threat_title = "This is a Robbery"
	threat_content = "Hey it's %SHIPNAME. Give us money. \
		%PAYOFF might be enough."
	arrival_announcement = "Nice stuff you got there, it's ours now."
	arrival_announcement_ru = "Неплохие у вас тут вещички. Теперь они наши."
	possible_answers = list("Please don't hurt me.","YOU WILL ANSWER TO THE LAW!!")

	response_received = "Wait, you ACTUALLY gave us the money? Thanks, but we're coming for the rest anyways!"
	response_received_ru = "Погодите, вы и ПРАВДА отдали деньги? Спасибо, но за остальным мы всё равно придём!"
	response_rejected = "The answer to the law? We are the law! And you will be held responsible!"
	response_rejected_ru = "Отвечать перед законом? Мы и есть закон! И вы понесёте ответственность!"
	response_too_late = "Nothing, huh? Looks like the Tide's coming aboard!"
	response_too_late_ru = "Ничего, значит? Похоже, Серый Прилив уже идёт к вам на борт!"
	response_not_enough = "You trying to cheat us? That's fine, we'll take your station as collateral."
	response_not_enough_ru = "Пытаетесь нас надуть? Ничего, возьмём вашу станцию в залог."
	announcement_color = "yellow"


///Agents from the space I.R.S. heavily armed to stea- I mean, collect the station's tax dues
/datum/pirate_gang/irs
	name = "Space IRS Agents"

	is_heavy_threat = TRUE
	ship_template_id = "irs"
	ship_name_pool = "irs_names"

	threat_title = "Missing Tax Dues"
	threat_content = "%SHIPNAME Here, We noticed that your station hasn't been paying your taxes.. \
		Let's rectify that, Your missing tax dues amounts to %PAYOFF \
		We highly recommend paying your taxes stat, \
		we don't need to send a team to your station to resolve the situation do we?"
	arrival_announcement = "This is the tax conflict resolution team, prepare for your assets to be liquidated and be charged with tax fraud, \
		if you fail to pay your taxes in time."
	arrival_announcement_ru = "Это группа урегулирования налоговых конфликтов. Если вы не оплатите налоги вовремя, готовьтесь к ликвидации активов и обвинению в налоговом мошенничестве."
	possible_answers = list("You know, I was just about to pay that. Thanks for the reminder!","I don't care WHO the IRS sends, I'm not paying for my taxes!")

	response_received = "Payment received, We salute you for being law-abiding tax-paying citizens"
	response_received_ru = "Платёж получен. Мы приветствуем вас как законопослушных налогоплательщиков."
	response_rejected = "We understand, I'm sending a team to your station to resolve the matter."
	response_rejected_ru = "Понимаем. Отправляем к вам команду для урегулирования вопроса."
	response_too_late = "Too late, A team has already been sent out resolve this matter directly."
	response_too_late_ru = "Слишком поздно: команда уже отправлена для непосредственного урегулирования."
	response_not_enough = "You filed your taxes incorrectly, A team has been sent to assist in liquidating assets and arrest you for tax fraud. \
		Nothing personel kid."
	response_not_enough_ru = "Вы неверно заполнили налоговую отчётность. Команда уже направлена, чтобы помочь с ликвидацией активов и арестовать вас за налоговое мошенничество. Ничего личного."
	announcement_color = "yellow"

//Mutated Ethereals who have adopted bluespace technology in all the wrong ways.
/datum/pirate_gang/lustrous
	name = "Geode Scavengers"

	ship_template_id = "geode"
	ship_name_pool = "geode_names"

	threat_title = "Unusual transmission"
	threat_content = "The crystal of mother-void cracks, and forth comes the %SHIPNAME. We are the Lustrous, the hands of the crystal king.\
		Our coffers of bluespace dust are low, ergo, our synthesis ceases. %PAYOFF credits shall remedy this!"
	arrival_announcement = "We have arrived, we have always been here, and we have already left."
	arrival_announcement_ru = "Мы прибыли. Мы всегда были здесь. И мы уже ушли."
	possible_answers = list("Uh, ok? Sure."," We don't have time for crazy-talk, go away.")


	response_received = "An excellent haul, the synthesis shall resume."
	response_received_ru = "Великолепная добыча. Синтез продолжится."
	response_rejected = "The rudeness in your speech needs to be neutralized. And we can help you with that right now."
	response_rejected_ru = "Грубость в ваших словах нуждается в нейтрализации. И мы можем заняться этим прямо сейчас."
	response_too_late = "You were not ready then, and now that time has passed. We can only go forward, never back."
	response_too_late_ru = "Тогда вы не были готовы, а теперь время ушло. Мы можем двигаться только вперёд, никогда назад."
	response_not_enough = "You have insulted us, but there shall be no feud, only swift justice!"
	response_not_enough_ru = "Вы оскорбили нас. Не будет никакой вражды — только быстрая справедливость!"
	announcement_color = "purple"

//medieval militia, from OUTER SPACE!
/datum/pirate_gang/medieval
	name = "Medieval Warmongers"

	is_heavy_threat = TRUE
	ship_template_id = "medieval"
	ship_name_pool = "medieval_names"

	threat_title = "HOMAGE PAYMENT REQUEST"
	threat_content = "SALUTATIONS, THIS IS %SHIPNAME AND WE ARE COLLECTING MONEY \
		FROM THE VASSALS IN OUR TERRITORY, YOU JUST SO HAPPEN TO BE IN IT TOO!! NORMALLY \
		WE SLAUGHTER WEAKLINGS LIKE YOU FOR TRESPASING ON OUR LAND, BUT WE ARE WILLING \
		TO WELCOME YOU INTO OUR SPACE IF YOU PAY %PAYOFF AS HOMAGE TO OUR LAW. BE WISE ON YOUR CHOICE!! \
		(send message. send message. why message not sent?)."
	arrival_announcement = "I FIGURED OUT HOW TO FLY MY SHIP, WE WILL BE DOCKING NEXT TO YOU IN A MINUTE!!"
	arrival_announcement_ru = "Я РАЗОБРАЛСЯ, КАК ЛЕТАТЬ НА ЭТОЙ ПОСУДИНЕ! ЧЕРЕЗ МИНУТУ ПРИШВАРТУЕМСЯ РЯДОМ С ВАМИ!!"
	possible_answers = list("Alright, i like my skull intact.","You are dumb, go larp somewhere else.")

	response_received = "THIS WILL SUFFICE, REMEMBER WHO OWNS YOU!!"
	response_received_ru = "ЭТОГО ХВАТИТ, ПОМНИТЕ, КТО ВАМИ ВЛАДЕЕТ!!"
	response_rejected = "FOOLISH DECISION, I'LL MAKE AN EXAMPLE OUT OF YOUR CARCASS!! (does anyone remember how to pilot our ship?)"
	response_rejected_ru = "ГЛУПОЕ РЕШЕНИЕ, Я СДЕЛАЮ ИЗ ВАШИХ ТУШ ПРИМЕР!! (кто-нибудь помнит, как управлять кораблём?)"
	response_too_late = "YOU ARE ALREADY UNDER SIEGE YOU BUFFON, ARE YOU BRAINSICK OR IGNORANT?!!"
	response_too_late_ru = "ВЫ УЖЕ В ОСАДЕ, БОЛВАН! ВЫ БЕЗУМНЫ ИЛИ ПРОСТО НЕВЕЖДЫ?!!"
	response_not_enough = "DO THINK OF ME AS A JESTER? YOU ARE DEAD MEAT!! (i forgot how to fly the ship, tarnation.)"
	response_not_enough_ru = "ВЫ ЧТО, ЗА ШУТА МЕНЯ ДЕРЖИТЕ? ВЫ ТРУПЫ!! (опять забыл, как летать на корабле, чёрт побери.)"
