/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask Mothblocks if they're around
*/

/// How much stored radiation to check for hair loss
#define RAD_MOB_HAIRLOSS (1 MINUTES)
/// Chance of you hair starting to fall out every second when over threshold
#define RAD_MOB_HAIRLOSS_PROB 7.5

/// How much stored radiation to check for mutation
#define RAD_MOB_MUTATE (2 MINUTES)
/// Chance of randomly mutating every second when over threshold
#define RAD_MOB_MUTATE_PROB 0.5

/// The time since irradiated before checking for vomitting
#define RAD_MOB_VOMIT (2 MINUTES)
/// Chance per second of vomitting
#define RAD_MOB_VOMIT_PROB 0.5

/// How much stored radiation to check for stunning
#define RAD_MOB_KNOCKDOWN (2 MINUTES)
/// Chance of knockdown per second when over threshold
#define RAD_MOB_KNOCKDOWN_PROB 0.5
/// Amount of knockdown when it occurs
#define RAD_MOB_KNOCKDOWN_AMOUNT 3

#define RAD_NO_INSULATION 1.0 // For things that shouldn't become irradiated for whatever reason
#define RAD_VERY_LIGHT_INSULATION 0.9 // What girders have
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION 0.7 // What common walls have
#define RAD_HEAVY_INSULATION 0.6 // What reinforced walls have
#define RAD_EXTREME_INSULATION 0.5 // What rad collectors have
#define RAD_FULL_INSULATION 0 // Completely stops radiation from coming through
/// The strongest effective shielding allowed for windows and airlocks, even if their material is better.
#define RAD_TRANSPARENT_STRUCTURE_MIN_PASS_THROUGH RAD_HEAVY_INSULATION
/// Directional windows only provide a fraction of a fulltile window's shielding when facing the radiation source.
#define RAD_DIRECTIONAL_WINDOW_SHIELDING_DIVISOR 4

/// The default chance something can be irradiated
#define DEFAULT_RADIATION_CHANCE 10

/// Singularity radiation pulse tuning. Keep the range bounded: radiation_pulse() expands this into turfs.
#define SINGULARITY_RADIATION_BASE_RANGE 4
#define SINGULARITY_RADIATION_RANGE_PER_STAGE 2
#define SINGULARITY_RADIATION_ENERGY_DIVISOR 250
#define SINGULARITY_RADIATION_MAX_RANGE 18
#define SINGULARITY_RADIATION_CHANCE 100
#define SINGULARITY_RADIATION_THRESHOLD RAD_EXTREME_INSULATION
#define SINGULARITY_RADIATION_CONTAMINATION_MULTIPLIER 1.2

/// The default chance for uranium structures to irradiate
#define URANIUM_IRRADIATION_CHANCE DEFAULT_RADIATION_CHANCE

/// The minimum exposure time before uranium structures can irradiate
#define URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME (3 SECONDS)
/// The minimum exposure time before the radioactive nebula can irradiate
#define NEBULA_RADIATION_MINIMUM_EXPOSURE_TIME (6 SECONDS)

// Surface contamination params

/// Surface contamination below this amount is treated as background and removed.
#define RAD_CONTAMINATION_MIN_ACTIVITY 1
/// Maximum surface contamination activity a single component can hold.
#define RAD_CONTAMINATION_MAX_ACTIVITY 100
/// Default surface contamination applied by direct irradiation calls.
#define RAD_CONTAMINATION_DIRECT_EXPOSURE 10
/// Multiplier converting a successful radiation pulse chance into surface contamination.
#define RAD_CONTAMINATION_PULSE_MULTIPLIER 0.8
/// Additional multiplier for contamination applied to the radiation source itself.
#define RAD_CONTAMINATION_SOURCE_SELF_MULTIPLIER 0.2
/// Multiplier for contamination deposited on worn or held items when their wearer is hit by radiation.
#define RAD_CONTAMINATION_WORN_ITEM_MULTIPLIER 1
/// Surface contamination multiplier for weak passive radioactive material sources.
#define RAD_CONTAMINATION_WEAK_SOURCE_MULTIPLIER 0.1
/// Maximum surface contamination that weak passive radioactive material sources can apply to other atoms.
#define RAD_CONTAMINATION_WEAK_SOURCE_CAP 12
/// Stable low surface activity shown on naturally radioactive material sources.
#define RAD_CONTAMINATION_NATURAL_SOURCE_ACTIVITY 8
/// Amount of contamination required before meson scanners can outline the atom.
#define RAD_CONTAMINATION_MESON_VISIBILITY 5
/// Amount of primary contamination required before it can rub off onto nearby atoms.
#define RAD_CONTAMINATION_SPREAD_THRESHOLD 45
/// Maximum number of nearby atoms dirtied by one spread tick.
#define RAD_CONTAMINATION_SPREAD_TARGETS 4
/// Fraction of current activity transferred to each secondary contamination target.
#define RAD_CONTAMINATION_TRANSFER_FRACTION 0.12
/// Highest generation allowed to spread contamination further.
#define RAD_CONTAMINATION_MAX_SPREAD_GENERATION 0
/// Delay between contamination spread attempts.
#define RAD_CONTAMINATION_SPREAD_COOLDOWN (4 SECONDS)
/// Amount of contamination required before it emits weak radiation pulses.
#define RAD_CONTAMINATION_EMIT_THRESHOLD 70
/// Delay between weak radiation pulses from highly contaminated primary atoms.
#define RAD_CONTAMINATION_EMIT_COOLDOWN (8 SECONDS)
/// Maximum range of weak radiation pulses from contaminated atoms.
#define RAD_CONTAMINATION_EMIT_RANGE 1
/// Contamination activity lost per second.
#define RAD_CONTAMINATION_DECAY_PER_SECOND 0.12
/// Surface contamination activity removed by a partial radiation clean.
#define RAD_CONTAMINATION_PARTIAL_CLEAN_ACTIVITY 10

/// Return values of [proc/get_perceived_radiation_danger]
// If you change these, update /datum/looping_sound/geiger as well.
#define PERCEIVED_RADIATION_DANGER_LOW 1
#define PERCEIVED_RADIATION_DANGER_MEDIUM 2
#define PERCEIVED_RADIATION_DANGER_HIGH 3
#define PERCEIVED_RADIATION_DANGER_EXTREME 4

/// The time before geiger counters reset back to normal without any radiation pulses
#define TIME_WITHOUT_RADIATION_BEFORE_RESET (5 SECONDS)

// Radiation exposure params

// For the radioactive nebula outside
/// Base chance the nebula has of applying irradiation
#define RADIATION_EXPOSURE_NEBULA_BASE_CHANCE 20
/// The chance we add to the base chance every time we fail to irradiate
#define RADIATION_EXPOSURE_NEBULA_CHANCE_INCREMENT 10
/// Time it takes for the next irradiation check
#define RADIATION_EXPOSURE_NEBULA_CHECK_INTERVAL 5 SECONDS
