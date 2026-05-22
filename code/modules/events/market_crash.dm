/**
 * An event which decreases the station target temporarily, causing the inflation var to increase heavily.
 *
 * Done by decreasing the station_target by a high value per crew member, resulting in the station total being much higher than the target, and causing artificial inflation.
 */
/datum/round_event_control/market_crash
	name = "Market Crash"
	typepath = /datum/round_event/market_crash
	weight = 10
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Temporarily increases the prices of vending machines."

/datum/round_event/market_crash
	/// This counts the number of ticks that the market crash event has been processing, so that we don't call vendor price updates every tick, but we still iterate for other mechanics that use inflation.
	var/tick_counter = 1

/datum/round_event/market_crash/setup()
	start_when = 1
	end_when = rand(100, 50)
	announce_when = 2

/datum/round_event/market_crash/announce(fake)
	var/list/poss_reasons = list(list("en" = "the alignment of the moon and the sun", "ru" = "выравнивания луны и солнца"),\
		list("en" = "some risky housing market outcomes", "ru" = "неудачных колебаний рынка жилья"),\
		list("en" = "the B.E.P.I.S. team's untimely downfall", "ru" = "безвременного краха команды B.E.P.I.S."),\
		list("en" = "speculative SolFed grants backfiring", "ru" = "неудачных спекулятивных грантов СолФеда"),  /*NOVA EDIT CHANGE; original was "speculative Terragov grants backfiring"*/\
		list("en" = "greatly exaggerated reports of Nanotrasen accountancy personnel being \"laid off\"", "ru" = "сильно преувеличенных сообщений об \"увольнении\" сотрудников бухгалтерии Nanotrasen"),\
		list("en" = "a \"great investment\" into \"non-fungible tokens\" by a \"moron\"", "ru" = "\"гениального вложения\" одного \"идиота\" в \"невзаимозаменяемые токены\""),\
		list("en" = "a number of raids from Tiger Cooperative agents", "ru" = "серии налётов агентов Tiger Cooperative"),\
		list("en" = "supply chain shortages", "ru" = "сбоев в цепочках поставок"),\
		list("en" = "the \"Nanotrasen+\" social media network's untimely downfall", "ru" = "безвременного краха социальной сети \"Nanotrasen+\""),\
		list("en" = "the \"Nanotrasen+\" social media network's unfortunate success", "ru" = "неожиданного успеха социальной сети \"Nanotrasen+\""),\
		list("en" = "uhh, bad luck, we guess", "ru" = "ну... просто не повезло, наверное")
	)
	var/list/reason = pick(poss_reasons)
	priority_announce("Due to [reason["en"]], prices for on-station vendors will be increased for a short period.", "Nanotrasen Accounting Division", text_ru = "Из-за [reason["ru"]] цены в торговых автоматах на станции будут ненадолго повышены.", title_ru = "Бухгалтерский департамент Nanotrasen")

/datum/round_event/market_crash/start()
	. = ..()
	ADD_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)
	SSeconomy.market_crash_price_index = max(SSeconomy.economic_price_index, 2.5)
	SSeconomy.update_vending_prices()
	SSeconomy.price_update()

/datum/round_event/market_crash/end()
	. = ..()
	REMOVE_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)
	SSeconomy.market_crash_price_index = 1
	SSeconomy.price_update()
	SSeconomy.update_vending_prices()
	priority_announce("Prices for on-station vendors have now stabilized.", "Nanotrasen Accounting Division", text_ru = "Цены в торговых автоматах на станции стабилизировались.", title_ru = "Бухгалтерский департамент Nanotrasen")

/datum/round_event/market_crash/tick()
	. = ..()
	tick_counter++
	SSeconomy.market_crash_price_index = max(2.5, 5.5 * log(activeFor + 1))
	if(tick_counter >= 5)
		tick_counter = 1
		SSeconomy.update_vending_prices()
