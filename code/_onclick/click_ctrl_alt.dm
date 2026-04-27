/**
 * Ctrl + Alt + Left click base proc.
 *
 * Default behavior: opens traitor panel on a human target if the clicking mob is an admin.
 * Override per mob type for additional behavior; call ..() to retain admin functionality.
 */
/mob/proc/CtrlAltClickOn(atom/A)
	// Admin: open traitor panel when ctrl+alt clicking a human
	if(!ishuman(A))
		return
	if(!check_rights_for(client, R_ADMIN))
		return
	if(!SSticker.HasRoundStarted())
		to_chat(src, span_warning("The round hasn't started yet!"), confidential = TRUE)
		return
	var/mob/target = A
	if(!target.mind)
		to_chat(src, span_warning("[target] has no mind."), confidential = TRUE)
		return
	SSadmin_verbs.dynamic_invoke_verb(src, /datum/admin_verb/show_traitor_panel, target)