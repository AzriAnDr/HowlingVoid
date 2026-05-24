https://github.com/NovaSector/NovaSector/pull/121

## \<Title Antagonist Opt In>

Module ID: ANTAG_OPTIN

### Description:

Adds functionality to let players set whether antagonist objective generation should prefer them for kill or round-removal targets. Round-removal objectives use this setting across antagonist types except heretic, which keeps its own target selection rules. Security jobs set to `No` are treated as `Yes - Kill Without Round Removal` for the current round. Command jobs and enabled antagonist preferences do not force this setting.

### TG Proc/File Changes:

- Changes in several antag files (will list later)
- examine_tgui.dm (Adds opt in info to OOC examine info)
- objective.dm (target selection stuff)

### Modular Overrides:

- N/A

### Defines:

- antag_opt_in - lives in ~nova_defines located in `__DEFINES` folder. Defines named OPT_IN_YES_KILL, OPT_IN_YES_TEMP, OPT_IN_YES_ROUND_REMOVE, and OPT_IN_OPT_IN_NOT_TARGET - used for managing opt in stuff.

### Included files that are not contained in this module:

- tgui\packages\tgui\interfaces\PreferencesMenu\preferences\features\character_preferences\nova\antag_optin.tsx

### Credits:

- niko - for doing stuff and taking over
- plum - the original author
