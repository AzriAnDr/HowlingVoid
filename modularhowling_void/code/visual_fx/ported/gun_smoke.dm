/particles/firing_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 24
	spawning = 24
	lifespan = 1.1 SECONDS
	fade = 1.3 SECONDS
	grow = 0.1
	drift = generator(GEN_CIRCLE, 1.4, 1.4)
	scale = 0.22
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(0, 0)
	friction = generator(GEN_NUM, 0.12, 0.22)

/particles/firing_smoke/impact
	count = 30
	spawning = 30
	lifespan = 0.6 SECONDS
	fade = 0.85 SECONDS
	grow = 0.08
	scale = 0.24
	drift = generator(GEN_CIRCLE, 2.6, 2.6)
	velocity = list(0, 0)

/particles/firing_smoke/muzzle
	count = 12
	spawning = 12
	lifespan = 0.35 SECONDS
	fade = 0.5 SECONDS
	grow = 0.05
	scale = 0.14
	drift = generator(GEN_CIRCLE, 1.4, 1.4)
	velocity = list(0, 0)
