/datum/scripture/slab/empower_wall
	name = "Empower Wall"
	desc = "Creates or empowers a clockwork wall's stabilization lattice, improving its resilience."
	tip = "Strengthen a clockwork wall."
	button_icon_state = "empower_wall"
	power_cost = STANDARD_CELL_CHARGE * 0.1
	invocation_time = 3 SECONDS
	invocation_text = list("Strengthen our resolve...", "So we may never fall!")
	slab_overlay = "hateful_manacles"
	use_time = 30 SECONDS
	cogs_required = 3
	category = SPELLTYPE_STRUCTURES
	uses = 3

/datum/scripture/slab/empower_wall/apply_effects(atom/applied_to)
	var/obj/structure/destructible/clockwork/wall_lattice/lattice
	if(istype(applied_to, /obj/structure/destructible/clockwork/wall_lattice))
		lattice = applied_to
	else if(istype(applied_to, /turf/closed/wall/mineral/bronze))
		var/turf/closed/wall/mineral/bronze/target_wall = applied_to
		lattice = locate(/obj/structure/destructible/clockwork/wall_lattice) in target_wall
		if(!lattice)
			lattice = new(target_wall, target_wall)

	if(!lattice)
		return FALSE

	if(lattice.is_empowered)
		lattice.balloon_alert(invoker, "already empowered!")
		return FALSE

	lattice.balloon_alert(invoker, "empowering...")
	if(!do_after(invoker, 3 SECONDS, target = lattice) || QDELETED(lattice) || lattice.is_empowered)
		return FALSE

	lattice.empower()
	lattice.balloon_alert(invoker, "empowered")
	return TRUE
