// Defines for objective target preference checking.
// Objectives check for players with a value equal to or greater than the target risk level, then pick from that list.

/// Legacy value for old save data. Do not expose as a selectable preference.
#define OPT_IN_YES_TEMP 1
/// Cool with being killed or otherwise occupied but not removed from the round
#define OPT_IN_YES_KILL 2
/// Fine with being round removed.
#define OPT_IN_YES_ROUND_REMOVE 3

/// Security jobs are always at least kill-target eligible for the current round.
#define SECURITY_OPT_IN_LEVEL OPT_IN_YES_KILL

#define OPT_IN_YES_TEMP_STRING "Yes - Temporary/Inconvenience"
#define OPT_IN_YES_KILL_STRING "Yes - Kill Without Round Removal"
#define OPT_IN_YES_ROUND_REMOVE_STRING "Yes - Round Removal"
#define OPT_IN_NOT_TARGET_STRING "No"

/// Assoc list of stringified opt_in_## define to the front-end string to show users as a representation of the setting.
GLOBAL_LIST_INIT(antag_opt_in_strings, list(
	"0" = OPT_IN_NOT_TARGET_STRING,
	"1" = OPT_IN_YES_TEMP_STRING,
	"2" = OPT_IN_YES_KILL_STRING,
	"3" = OPT_IN_YES_ROUND_REMOVE_STRING,
))

/// Assoc list of stringified opt_in_## define to the color associated with it.
GLOBAL_LIST_INIT(antag_opt_in_colors, list(
	OPT_IN_NOT_TARGET_STRING = COLOR_GRAY,
	OPT_IN_YES_TEMP_STRING = COLOR_EMERALD,
	OPT_IN_YES_KILL_STRING = COLOR_ORANGE,
	OPT_IN_YES_ROUND_REMOVE_STRING = COLOR_RED
))

/// Prefers not to be a target. Target generation can still fall back to this if nobody opts in.
#define OPT_IN_NOT_TARGET 0

/// The default opt in level for preferences and mindless mobs.
#define OPT_IN_DEFAULT_LEVEL OPT_IN_NOT_TARGET
