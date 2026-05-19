## Storyteller Needs Rework

### Goals

- Keep the storyteller as a separate subsystem.
- Add a lobby-selected round mode:
  - `Dynamic`: full storyteller pacing.
  - `Extended`: mostly positive pacing with rare, non-catastrophic negative content.
- Split positive and negative pacing into independent channels.
- Replace fixed positive aid actions with needs-driven department support.
- Make the admin panel explain storyteller state with clearer labels and tooltips.

### Round Modes

- `Dynamic`
  - Roundstart antagonist selection enabled.
  - Latejoin hostile selection enabled.
  - Midround negative and positive channels both active.
- `Extended`
  - No storyteller roundstart antagonists.
  - No storyteller latejoin hostiles.
  - Positive channel active.
  - Negative channel limited to mild local events and slower budget growth.

### Independent Channels

- Add separate pacing state for:
  - `threat_budget`
  - `aid_budget`
  - `negative_fatigue_locked_until`
  - `positive_fatigue_locked_until`
- Family cooldowns remain shared per family, but positive and negative fatigue do not block each other.
- Midround pulses attempt:
  - one positive action if an actionable need exists;
  - one negative action if the current mode allows it.

### Needs-Driven Positive Aid

- Add a `need` layer between snapshot and positive actions.
- First needs:
  - `food_shortage`
  - `engineering_repair_crisis`
  - `material_shortage`
- Needs produce structured reports with:
  - `id`
  - `department_id`
  - `title`
  - `severity`
  - `priority`
  - `recommended_action_family`
  - `details`
- Positive actions consume a selected need report and build a custom payload from it.

### Snapshot Expansion

- Staffing:
  - cooks / service
  - engineers / atmos
  - cargo / quartermaster / miners
- Food:
  - food items in kitchen, cafeteria, and bar service areas
- Damage:
  - station-space breaches in station areas
  - broken floors
  - damaged windows
  - damaged grilles
- Resources:
  - ore silo totals
  - loose station materials
  - material income delta since the previous heavy scan

### Positive Aid Rules

- Kitchen relief:
  - scales with alive crew;
  - prefers ready food if kitchen staffing is weak;
  - prefers ingredients if cooks are available.
- Engineering relief:
  - scales with alive crew and station damage;
  - can include iron, glass, cable, extinguishers, oxygen, metalfoam, and basic RCD gear.
- Cargo/mining relief:
  - reacts to low material reserves and poor recent intake;
  - scales base materials more aggressively than rare materials;
  - rare materials use lower caps and scarcity multipliers.

### UI Changes

- Rename `Context` to `Trigger Window`.
- Rename `Phase` to `Content Stage`.
- Show both channel locks separately.
- Show current round mode.
- Show detected needs and top priorities.
- Add tooltips for the main storyteller fields.

### Delivery Order

1. Round mode vote and storyteller mode state.
2. Independent positive and negative channels.
3. Need/report framework and snapshot expansion.
4. Adaptive positive aid actions.
5. Admin panel terminology and tooltips.
