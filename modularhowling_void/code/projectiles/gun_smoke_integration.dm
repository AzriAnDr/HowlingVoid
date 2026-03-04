/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FIRE_CASING, PROC_REF(register_powder_impact_smoke))

/obj/item/ammo_casing/Destroy()
	UnregisterSignal(src, COMSIG_FIRE_CASING)
	return ..()

/obj/item/ammo_casing/proc/register_powder_impact_smoke(
	datum/source,
	atom/target,
	mob/living/user,
	atom/fired_from,
	randomspread,
	spread,
	zone_override,
	params,
	distro,
	obj/projectile/thrown_proj,
)
	SIGNAL_HANDLER

	if(QDELETED(thrown_proj))
		return
	if(istype(thrown_proj, /obj/projectile/beam) || istype(thrown_proj, /obj/projectile/energy))
		return

	// Howling Void: disable powder puff on impact.
	// Keep the integration file loaded, but do not attach on-hit smoke behavior.
	return

/obj/item/ammo_casing/proc/on_powder_projectile_hit(
	obj/projectile/source,
	atom/movable/firer,
	atom/target,
	hit_angle,
	hit_limb,
	blocked,
	pierce_hit,
)
	SIGNAL_HANDLER

	// Only one puff per projectile from this integration.
	UnregisterSignal(source, COMSIG_PROJECTILE_SELF_ON_HIT)

	if(QDELETED(target))
		return
	if(pierce_hit)
		return
	// Do not spawn powder impact smoke on living targets.
	if(isliving(target))
		return

	var/turf/impact_turf = get_turf(target)
	if(!impact_turf)
		return

	var/obj/effect/abstract/particle_holder/impact_holder = new(impact_turf, /particles/firing_smoke/impact)
	if(!impact_holder?.particles)
		return

	if(!isnull(hit_angle))
		impact_holder.particles.velocity = list(sin(hit_angle) * 3, cos(hit_angle) * 3)

	QDEL_IN(impact_holder, 1.3 SECONDS)
