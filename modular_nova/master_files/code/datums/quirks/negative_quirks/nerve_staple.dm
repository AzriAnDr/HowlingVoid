/datum/quirk/equipping/nerve_staple
	name = "Nerve Stapled(Нервный степлер)"
	desc = "Ты пацифист. Не потому, что хочешь им быть, а из-за устройства, вживлённого тебе в глаз."
	value = -10 // pacifism = -8, losing eye slots = -2
	gain_text = span_danger("Вы вдруг не можете поднять руку, чтобы причинить боль другим!")
	lose_text = span_notice("Ты думаешь, что снова сможешь защитить себя.")
	medical_record_text = "Пациенту закрепили нервы скобами, и он не способен причинить вред другим."
	icon = FA_ICON_FACE_ANGRY
	forced_items = list(/obj/item/clothing/glasses/nerve_staple = list(ITEM_SLOT_EYES))
	/// The nerve staple attached to the quirk
	var/obj/item/clothing/glasses/nerve_staple/staple

/datum/quirk/equipping/nerve_staple/on_equip_item(obj/item/equipped, successful)
	if (!istype(equipped, /obj/item/clothing/glasses/nerve_staple))
		return
	staple = equipped

/datum/quirk/equipping/nerve_staple/remove()
	. = ..()
	if (!staple || staple != quirk_holder.get_item_by_slot(ITEM_SLOT_EYES))
		return
	to_chat(quirk_holder, span_warning("Скрепка нерва внезапно отваливается от вашего лица и тает[istype(quirk_holder.loc, /turf/open/floor) ? " на полу" : ""]!"))
	qdel(staple)
