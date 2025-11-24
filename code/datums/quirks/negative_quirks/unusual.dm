/datum/quirk/touchy
	name = "Touchy(Ощупывающий)"
	desc = "Вы очень обидчивы и вам необходимо физически прикоснуться к чему-либо, чтобы это осмотреть."
	icon = FA_ICON_HAND
	value = -2
	gain_text = span_danger("У тебя возникает ощущение, что ты не можешь рассматривать вещи на расстоянии.")
	lose_text = span_notice("Возникает ощущение, что ты стал более контактным.")
	medical_record_text = "Пациент не способен различать предметы на расстоянии."
	hardcore_value = 4

/datum/quirk/touchy/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CLICK_SHIFT, PROC_REF(examinate_check))

/datum/quirk/touchy/remove()
	UnregisterSignal(quirk_holder, COMSIG_CLICK_SHIFT)

///Checks if the mob is besides the  thing being examined, if they aren't then we cancel their examinate.
/datum/quirk/touchy/proc/examinate_check(mob/examiner, atom/examined)
	SIGNAL_HANDLER

	if(!examined.Adjacent(examiner))
		return COMSIG_MOB_CANCEL_CLICKON
