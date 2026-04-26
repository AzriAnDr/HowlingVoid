// Bluespace Shield Field Generator - Shield Modes
// Each mode is a datum that describes a shield capability and its energy cost multiplier.

/datum/bluespace_shield_mode
	/// English name
	var/mode_name = "Unknown Mode"
	/// English description
	var/mode_desc = ""
	/// Bitflag for this mode
	var/mode_flag = 0
	/// Energy upkeep multiplier when enabled
	var/multiplier = 1
	/// Only available on hacked generators
	var/hacked_only = FALSE

/datum/bluespace_shield_mode/hyperkinetic
	mode_name = "Hyperkinetic Projectiles"
	mode_desc = "Blocks fast-moving physical objects: bullets, meteors, thrown items."
	mode_flag = BSHIELD_MODE_HYPERKINETIC
	multiplier = 1.2

/datum/bluespace_shield_mode/photonic
	mode_name = "Photonic Dispersion"
	mode_desc = "Blocks beam weapons and most visible light, making the field opaque."
	mode_flag = BSHIELD_MODE_PHOTONIC
	multiplier = 1.3

/datum/bluespace_shield_mode/em
	mode_name = "Electro-Magnetic Shielding"
	mode_desc = "Blocks high-power electromagnetic emissions and ion storms."
	mode_flag = BSHIELD_MODE_EM
	multiplier = 1.3

/datum/bluespace_shield_mode/humanoids
	mode_name = "Humanoid Lifeforms"
	mode_desc = "Blocks humanoid lifeforms. Does not affect fully synthetic humanoids."
	mode_flag = BSHIELD_MODE_HUMANOIDS
	multiplier = 1.5

/datum/bluespace_shield_mode/silicon
	mode_name = "Silicon Lifeforms"
	mode_desc = "Blocks silicon-based lifeforms: cyborgs, drones, IPCs."
	mode_flag = BSHIELD_MODE_SILICON
	multiplier = 1.5

/datum/bluespace_shield_mode/mobs
	mode_name = "Unknown Lifeforms"
	mode_desc = "Blocks non-humanoid and non-silicon creatures such as space carp."
	mode_flag = BSHIELD_MODE_NONHUMANS
	multiplier = 1.5

/datum/bluespace_shield_mode/atmosphere
	mode_name = "Atmospheric Containment"
	mode_desc = "Blocks air flow, acting as atmospheric containment."
	mode_flag = BSHIELD_MODE_ATMOSPHERIC
	multiplier = 1.3

/datum/bluespace_shield_mode/adaptive
	mode_name = "Adaptive Field Harmonics"
	mode_desc = "Modulates shield frequencies to adapt against repeated damage types. Increases mitigation over time."
	mode_flag = BSHIELD_MODE_MODULATE
	multiplier = 2

/datum/bluespace_shield_mode/bypass
	mode_name = "Diffuser Bypass"
	mode_desc = "Counters shield diffusers at the cost of massive EM strain. Requires hacked safeties."
	mode_flag = BSHIELD_MODE_BYPASS
	multiplier = 3
	hacked_only = TRUE

/datum/bluespace_shield_mode/dampen
	mode_name = "Explosion Dampening"
	mode_desc = "Reinforces the field to absorb and attenuate explosive shockwaves, protecting anything behind the barrier."
	mode_flag = BSHIELD_MODE_DAMPEN
	multiplier = 1.5

/datum/bluespace_shield_mode/overcharge
	mode_name = "Field Overcharge"
	mode_desc = "Polarizes the field, causing electrical damage on contact. Requires hacked safeties."
	mode_flag = BSHIELD_MODE_OVERCHARGE
	multiplier = 3
	hacked_only = TRUE