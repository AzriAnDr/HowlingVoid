/datum/quirk/settler
	name = "Settler(Поселенец)"
	desc = "Вы принадлежите к роду первых космических поселенцев! В то время как ваша семья на протяжении поколений подвергалась воздействию различных гравитационных условий, \
		привело к ... меньшему росту, чем типично для вашего вида, вы компенсируете это тем, что гораздо лучше приспособлены к жизни на природе и \
		Переносите тяжёлое оборудование. Вы также отлично ладите с животными. Однако из-за маленьких ног вы немного медлительны."
	gain_text = span_bold("Вы почувствуете, что весь мир у ваших ног!")
	lose_text = span_danger("Вы думаете, что сегодня вам стоит остаться дома.")
	icon = FA_ICON_HOUSE
	value = 4
	mob_trait = TRAIT_SETTLER
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	medical_record_text = "Пациент длительное время подвергался воздействию планетарных условий, что привело к чрезмерному полноте."
	mail_goodies = list(
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/gps,
	)
	/// Most of the behavior of settler is from these traits, rather than exclusively the quirk
	var/list/settler_traits = list(
		TRAIT_EXPERT_FISHER,
		TRAIT_ROUGHRIDER,
		TRAIT_STUBBY_BODY,
		TRAIT_BEAST_EMPATHY,
		TRAIT_STURDY_FRAME,
	)

/datum/quirk/settler/add(client/client_source)
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	//NOVA EDIT BEGIN - This is so Teshari don't get the height decrease.
	if(!isteshari(human_quirkholder))
		human_quirkholder.set_mob_height(HUMAN_HEIGHT_SHORTEST)
	//NOVA EDIT END
	human_quirkholder.add_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.add_traits(settler_traits, QUIRK_TRAIT)

/datum/quirk/settler/remove()
	if(QDELING(quirk_holder))
		return
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	human_quirkholder.set_mob_height(HUMAN_HEIGHT_MEDIUM)
	human_quirkholder.remove_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.remove_traits(settler_traits, QUIRK_TRAIT)
