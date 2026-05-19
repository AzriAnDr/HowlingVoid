import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import {
  getInterfaceLanguageUpdatedEvent,
  getLanguageUpdatedEvent,
  type PanelLanguage,
} from 'common/panelLocalization';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import {
  formatMode as storytellerFormatMode,
  formatPercent as storytellerFormatPercent,
  formatTime as storytellerFormatTime,
  resolveStorytellerLanguage as resolveStorytellerLanguageFromFile,
  t as storytellerT,
  translateDepartmentLabel as storytellerTranslateDepartmentLabel,
  translateNeedSummary as storytellerTranslateNeedSummary,
  translateNeedTitle as storytellerTranslateNeedTitle,
  translateFamilyName as storytellerTranslateFamilyName,
  translateProfileName as storytellerTranslateProfileName,
  translateReason as storytellerTranslateReason,
  translateTooltip as storytellerTranslateTooltip,
} from './StorytellerPanel/localization';

type SnapshotData = {
  activePopulation: number;
  aliveCrew: number;
  recentDeaths: number;
  recentExplosions: number;
  activeAlarms: number;
  controlScore: number;
  dangerScore: number;
  livingAntagCount: number;
  livingAntagTypes: Record<string, number>;
  keyJobsOccupied: Record<string, string>;
  keyJobsFilledCount: number;
  totalKeyJobs: number;
  departmentStaffing: Record<string, number>;
  departmentMoney: Record<string, number>;
  cargoBudget: number;
  cookCount: number;
  serviceStaffCount: number;
  engineerCount: number;
  atmosCount: number;
  cargoStaffCount: number;
  minerCount: number;
  kitchenFoodTotal: number;
  serviceFoodTotal: number;
  oreSiloMaterialTotal: number;
  oreSiloMaterials: Record<string, number>;
  looseMaterialTotal: number;
  looseMaterials: Record<string, number>;
  materialGainRecent: number;
  activeRoundEventCount: number;
  activeRoundEvents: Record<string, number>;
  stationIntegrity: number;
  stationBreachTiles: number;
  brokenFloorCount: number;
  damagedWindowCount: number;
  damagedGrilleCount: number;
};

type DecisionEntry = {
  time: string;
  message: string;
};

type CooldownEntry = {
  family: string;
  remaining: number;
};

type ModifierEntry = {
  id: string;
  title: string;
  label: string;
  description?: string;
  value: number;
  remaining: number;
  positive: boolean;
};

type ActionEntry = {
  id: string;
  name: string;
  context: string;
  polarity?: string;
  chancePercent?: number;
  family?: string;
  stage?: number;
  cost?: number;
  weight?: number;
  reason?: string;
  eligible?: boolean;
  isAntag?: boolean;
  discarded?: boolean;
  activeWindow?: boolean;
  needId?: string;
  needTitle?: string;
};

type ProfileOption = {
  id: string;
  name: string;
};

type RoundModeOption = {
  id: string;
  name: string;
};

type QueuedAntagEntry = {
  id: string;
  name: string;
  context: string;
  prefFlag?: string;
  reservedCost?: number;
};

type QueuedActionEntry = {
  id: string;
  name: string;
  label: string;
  tone: 'good' | 'average';
};

type NeedEntry = {
  id: string;
  title: string;
  department: string;
  severity: number;
  priority: number;
  family?: string;
  summary?: string;
  details?: Record<string, string | number>;
};

type Data = {
  enabled: boolean;
  ownsPacing: boolean;
  paused: boolean;
  interfaceLanguage?: string;
  panelLanguages?: Record<string, string>;
  profileName: string;
  profileId: string;
  profileOptions: ProfileOption[];
  manualProfileOverride: boolean;
  roundMode: string;
  roundModeOptions: RoundModeOption[];
  phase: number;
  phaseCap: number;
  manualPhaseOverride: boolean;
  budgetCap: number;
  threatBudget: number;
  aidBudget: number;
  positiveFatigueRemaining: number;
  negativeFatigueRemaining: number;
  latejoinHostileRemaining: number;
  positiveChannelRemaining: number;
  negativeChannelRemaining: number;
  latejoinRoundstartRemaining: number;
  skipNextPulse: boolean;
  roundStarted: boolean;
  currentContext: string;
  queuedPositiveActionId?: string;
  queuedNegativeActionId?: string;
  snapshot: SnapshotData;
  activeModifiers: ModifierEntry[];
  detectedNeeds: NeedEntry[];
  decisionHistory: DecisionEntry[];
  familyCooldowns: CooldownEntry[];
  eligiblePositiveActions: ActionEntry[];
  eligibleNegativeActions: ActionEntry[];
  eligibleAntagActions: ActionEntry[];
  queuedAntagActions: QueuedAntagEntry[];
  eligibleActions: ActionEntry[];
  allActions: ActionEntry[];
};

/* Legacy inline localization table left from the pre-localization refactor.
 * The active source of truth lives in ./StorytellerPanel/localization.
 * This block is intentionally disabled to prevent mojibake Russian strings
 * from leaking back into the UI.
const UI_TEXT: Record<PanelLanguage, Record<string, string>> = {
  english: {
    window_title: 'Storyteller Panel',
    header_title: 'Storyteller Control',
    header_subtitle: 'Adaptive pacing director for pressure, aid, antagonists, and round diagnostics.',
    pause: 'Pause',
    resume: 'Resume',
    skip_next_pulse: 'Skip Next Pulse',
    disabled_notice:
      'Storyteller is disabled in config. The panel is read-only until STORYTELLER_ENABLED is enabled.',
    extended_notice:
      'Extended mode keeps adaptive relief and support active. Storyteller antagonists are suppressed, while only rare low-impact negative pressure remains available.',
    dynamic_notice:
      'Dynamic mode enables full storyteller pacing: adaptive aid, antagonists, and hostile pressure all remain in rotation.',
    round_mode: 'Round Mode',
    profile: 'Profile',
    content_stage: 'Content Stage',
    trigger_window: 'Trigger Window',
    overview_tab: 'Overview',
    operations_tab: 'Operations',
    snapshot_tab: 'Snapshot',
    logs_tab: 'Logs & Diagnostics',
    round_overview: 'Round Overview',
    enabled: 'Enabled',
    full_owner: 'Full Owner',
    paused: 'Paused',
    population: 'Population',
    alive_crew: 'Alive Crew',
    living_antags: 'Living Antags',
    station_integrity: 'Station Integrity',
    stage_one_notice: 'Current config only exposes stage-1 storyteller content.',
    manual_stage_notice: 'Content stage is currently pinned by an admin override.',
    auto_stage_notice: 'Content stage is currently escalating automatically.',
    budgets_pressure: 'Budgets & Pressure',
    control_score: 'Control Score',
    danger_score: 'Danger Score',
    threat_budget: 'Threat Budget',
    aid_budget: 'Aid Budget',
    cadence: 'Cadence',
    positive_lock: 'Positive Lock',
    positive_window: 'Positive Window',
    negative_lock: 'Negative Lock',
    negative_window: 'Negative Window',
    latejoin_lock: 'Latejoin Lock',
    latejoin_warmup: 'Latejoin Warmup',
    current_snapshot: 'Current Snapshot',
    cargo_budget: 'Cargo Budget',
    active_alarms: 'Active Alarms',
    recent_deaths: 'Recent Deaths',
    recent_explosions: 'Recent Explosions',
    kitchen_service_food: 'Kitchen / Service Food',
    cargo_miners: 'Cargo / Miners',
    breaches_floors: 'Breaches / Floors',
    windows_grilles: 'Windows / Grilles',
    controls: 'Controls',
    profile_override: 'Profile Override',
    set_profile: 'Set Profile',
    auto: 'Auto',
    set_content_stage: 'Set Content Stage',
    set_stage: 'Set Stage',
    force_action: 'Force Action',
    force_next: 'Force Next',
    force_now: 'Force NOW',
    force_now_confirm: 'Force Now?',
    action_search: 'Action Search',
    search_storyteller_actions: 'Search storyteller actions',
    search_all_actions: 'Search positive, negative, and antagonist actions',
    detected_needs: 'Detected Needs',
    no_detected_needs: 'No actionable department needs detected.',
    queued_next_actions: 'Queued Next Actions',
    no_queued_next: 'No storyteller pulse overrides are currently queued.',
    positive_channel: 'Positive Channel',
    negative_channel: 'Negative Channel',
    queued_antagonists: 'Queued Antagonists',
    no_queued_antags: 'No queued roundstart or latejoin antagonist rulesets.',
    active_modifiers: 'Active Modifiers',
    no_active_modifiers: 'No timed storyteller modifiers are active.',
    positive_actions: 'Positive Actions',
    negative_actions: 'Negative Actions',
    antagonist_actions: 'Antagonist Actions',
    no_positive_filtered: 'No positive storyteller actions matched the current filter.',
    no_negative_filtered: 'No negative storyteller actions matched the current filter.',
    no_antag_filtered: 'No storyteller antagonist actions matched the current filter.',
    crew_staffing: 'Crew & Staffing',
    key_jobs_filled: 'Key Jobs Filled',
    cooks_service: 'Cooks / Service',
    engineers_atmos: 'Engineers / Atmos',
    threats_events: 'Threats & Events',
    active_round_events: 'Active Round Events',
    resources_economy: 'Resources & Economy',
    silo_materials: 'Silo Materials',
    loose_materials: 'Loose Materials',
    recent_material_gain: 'Recent Material Gain',
    structural_condition: 'Structural Condition',
    key_jobs: 'Key Jobs',
    department_staffing: 'Department Staffing',
    living_antag_types: 'Living Antag Types',
    active_event_breakdown: 'Active Event Breakdown',
    department_money: 'Department Money',
    silo_breakdown: 'Silo Material Breakdown',
    loose_breakdown: 'Loose Material Breakdown',
    recent_decisions: 'Recent Decisions',
    no_decisions: 'No storyteller decisions have been recorded yet.',
    active_cooldowns: 'Active Cooldowns',
    no_cooldowns: 'No family cooldowns active.',
    advanced_notes: 'Advanced Notes',
    advanced_notes_body:
      'Profiles change the storyteller temperament. They retune pressure scoring, budget growth, cadence delays, escalation speed, and how aggressively the subsystem leans into hostile or supportive pacing.',
    advanced_notes_footer:
      'Content stages are global unlock bands. Stage 1 keeps lighter content, while higher stages unlock heavier actions and antagonists as the round matures or intensifies.',
    yes: 'Yes',
    no: 'No',
    ready: 'Ready',
    expired: 'Expired',
    none: 'None',
    chance: 'Chance',
    cost: 'Cost',
    weight: 'Weight',
    stage: 'Stage',
    active_window: 'Active Window',
    targets_need: 'Targets need',
    discard: 'Discard',
    discarded: 'Discarded',
    cancel: 'Cancel',
    cancel_queue_confirm: 'Cancel queue?',
    refund_threat: 'Refund',
    pref: 'Pref',
    unknown: 'Unknown',
    dynamic: 'Dynamic',
    extended: 'Extended',
    positive: 'Positive',
    negative: 'Negative',
    roundstart: 'Roundstart',
    midround: 'Midround',
    latejoin: 'Latejoin',
    balanced: 'Balanced Drama',
    passive: 'Patient Custodian',
    aggressive: 'Aggressive Escalation',
  },
  russian: {
    window_title: 'РџР°РЅРµР»СЊ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°',
    header_title: 'РЈРїСЂР°РІР»РµРЅРёРµ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂРѕРј',
    header_subtitle: 'РђРґР°РїС‚РёРІРЅС‹Р№ СЂРµР¶РёСЃСЃС‘СЂ С‚РµРјРїР° СЂР°СѓРЅРґР°: РґР°РІР»РµРЅРёРµ, РїРѕРјРѕС‰СЊ, Р°РЅС‚Р°РіРѕРЅРёСЃС‚С‹ Рё РґРёР°РіРЅРѕСЃС‚РёРєР°.',
    pause: 'РџР°СѓР·Р°',
    resume: 'РџСЂРѕРґРѕР»Р¶РёС‚СЊ',
    skip_next_pulse: 'РџСЂРѕРїСѓСЃС‚РёС‚СЊ СЃР»РµРґСѓСЋС‰РёР№ С‚РёРє',
    disabled_notice:
      'РЎС‚РѕСЂРёС‚РµР»Р»РµСЂ РѕС‚РєР»СЋС‡С‘РЅ РІ РєРѕРЅС„РёРіРµ. РџР°РЅРµР»СЊ СЂР°Р±РѕС‚Р°РµС‚ С‚РѕР»СЊРєРѕ РЅР° С‡С‚РµРЅРёРµ, РїРѕРєР° РЅРµ РІРєР»СЋС‡С‘РЅ STORYTELLER_ENABLED.',
    extended_notice:
      'Р РµР¶РёРј Extended СЃРѕС…СЂР°РЅСЏРµС‚ Р°РґР°РїС‚РёРІРЅСѓСЋ РїРѕРјРѕС‰СЊ Рё РїРѕРґРґРµСЂР¶РєСѓ. РђРЅС‚Р°РіРѕРЅРёСЃС‚С‹ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° РїРѕРґР°РІР»РµРЅС‹, Р° РЅРµРіР°С‚РёРІРЅРѕРµ РґР°РІР»РµРЅРёРµ РѕРіСЂР°РЅРёС‡РµРЅРѕ СЂРµРґРєРёРјРё РјСЏРіРєРёРјРё СЃРѕР±С‹С‚РёСЏРјРё.',
    dynamic_notice:
      'Р РµР¶РёРј Dynamic РІРєР»СЋС‡Р°РµС‚ РїРѕР»РЅС‹Р№ С‚РµРјРї СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°: РїРѕРјРѕС‰СЊ, Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ Рё РІСЂР°Р¶РґРµР±РЅРѕРµ РґР°РІР»РµРЅРёРµ.',
    round_mode: 'Р РµР¶РёРј СЂР°СѓРЅРґР°',
    profile: 'РџСЂРѕС„РёР»СЊ',
    content_stage: 'Р­С‚Р°Рї РєРѕРЅС‚РµРЅС‚Р°',
    trigger_window: 'РћРєРЅРѕ СЃСЂР°Р±Р°С‚С‹РІР°РЅРёСЏ',
    overview_tab: 'РћР±Р·РѕСЂ',
    operations_tab: 'РћРїРµСЂР°С†РёРё',
    snapshot_tab: 'РЎРЅРёРјРѕРє',
    logs_tab: 'Р›РѕРіРё Рё РґРёР°РіРЅРѕСЃС‚РёРєР°',
    round_overview: 'РћР±Р·РѕСЂ СЂР°СѓРЅРґР°',
    enabled: 'Р’РєР»СЋС‡С‘РЅ',
    full_owner: 'РџРѕР»РЅС‹Р№ РєРѕРЅС‚СЂРѕР»СЊ',
    paused: 'РќР° РїР°СѓР·Рµ',
    population: 'РћРЅР»Р°Р№РЅ',
    alive_crew: 'Р–РёРІРѕР№ СЌРєРёРїР°Р¶',
    living_antags: 'Р–РёРІС‹Рµ Р°РЅС‚Р°РіРё',
    station_integrity: 'Р¦РµР»РѕСЃС‚РЅРѕСЃС‚СЊ СЃС‚Р°РЅС†РёРё',
    stage_one_notice: 'РўРµРєСѓС‰Р°СЏ РєРѕРЅС„РёРіСѓСЂР°С†РёСЏ РѕС‚РєСЂС‹РІР°РµС‚ С‚РѕР»СЊРєРѕ РєРѕРЅС‚РµРЅС‚ 1-РіРѕ СЌС‚Р°РїР°.',
    manual_stage_notice: 'Р­С‚Р°Рї РєРѕРЅС‚РµРЅС‚Р° СЃРµР№С‡Р°СЃ Р·Р°С„РёРєСЃРёСЂРѕРІР°РЅ Р°РґРјРёРЅСЃРєРёРј РѕРІРµСЂСЂР°Р№РґРѕРј.',
    auto_stage_notice: 'Р­С‚Р°Рї РєРѕРЅС‚РµРЅС‚Р° СЃРµР№С‡Р°СЃ РїРѕРІС‹С€Р°РµС‚СЃСЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё.',
    budgets_pressure: 'Р‘СЋРґР¶РµС‚С‹ Рё РґР°РІР»РµРЅРёРµ',
    control_score: 'РљРѕРЅС‚СЂРѕР»СЊ',
    danger_score: 'РћРїР°СЃРЅРѕСЃС‚СЊ',
    threat_budget: 'Р‘СЋРґР¶РµС‚ СѓРіСЂРѕР·С‹',
    aid_budget: 'Р‘СЋРґР¶РµС‚ РїРѕРјРѕС‰Рё',
    cadence: 'РўРµРјРї',
    positive_lock: 'РџРѕР·РёС‚РёРІРЅС‹Р№ Р»РѕРє',
    positive_window: 'РџРѕР·РёС‚РёРІРЅРѕРµ РѕРєРЅРѕ',
    negative_lock: 'РќРµРіР°С‚РёРІРЅС‹Р№ Р»РѕРє',
    negative_window: 'РќРµРіР°С‚РёРІРЅРѕРµ РѕРєРЅРѕ',
    latejoin_lock: 'Р›РѕРє Р»РµР№С‚РґР¶РѕРёРЅР°',
    latejoin_warmup: 'РЎС‚Р°СЂС‚РѕРІС‹Р№ Р»РѕРє Р»РµР№С‚РґР¶РѕРёРЅР°',
    current_snapshot: 'РўРµРєСѓС‰РёР№ СЃРЅРёРјРѕРє',
    cargo_budget: 'Р‘СЋРґР¶РµС‚ РєР°СЂРіРѕ',
    active_alarms: 'РђРєС‚РёРІРЅС‹Рµ С‚СЂРµРІРѕРіРё',
    recent_deaths: 'РќРµРґР°РІРЅРёРµ СЃРјРµСЂС‚Рё',
    recent_explosions: 'РќРµРґР°РІРЅРёРµ РІР·СЂС‹РІС‹',
    kitchen_service_food: 'Р•РґР° РєСѓС…РЅРё / СЃРµСЂРІРёСЃР°',
    cargo_miners: 'РљР°СЂРіРѕ / С€Р°С…С‚С‘СЂС‹',
    breaches_floors: 'Р Р°Р·РіРµСЂРјР° / РїРѕР»С‹',
    windows_grilles: 'РћРєРЅР° / СЂРµС€С‘С‚РєРё',
    controls: 'РЈРїСЂР°РІР»РµРЅРёРµ',
    profile_override: 'РћРІРµСЂСЂР°Р№Рґ РїСЂРѕС„РёР»СЏ',
    set_profile: 'Р’С‹Р±СЂР°С‚СЊ РїСЂРѕС„РёР»СЊ',
    auto: 'РђРІС‚Рѕ',
    set_content_stage: 'Р—Р°РґР°С‚СЊ СЌС‚Р°Рї РєРѕРЅС‚РµРЅС‚Р°',
    set_stage: 'РџСЂРёРјРµРЅРёС‚СЊ СЌС‚Р°Рї',
    force_action: 'Р¤РѕСЂСЃ РґРµР№СЃС‚РІРёСЏ',
    force_next: 'Р¤РѕСЂСЃ СЃР»РµРґСѓСЋС‰РёРј',
    force_now: 'Р¤РѕСЂСЃ СЃРµР№С‡Р°СЃ',
    force_now_confirm: 'Р¤РѕСЂСЃРЅСѓС‚СЊ СЃРµР№С‡Р°СЃ?',
    action_search: 'РџРѕРёСЃРє РґРµР№СЃС‚РІРёР№',
    search_storyteller_actions: 'РџРѕРёСЃРє РґРµР№СЃС‚РІРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°',
    search_all_actions: 'РџРѕРёСЃРє РїРѕ РїРѕР·РёС‚РёРІРЅС‹Рј, РЅРµРіР°С‚РёРІРЅС‹Рј Рё Р°РЅС‚Р°РіРѕРЅРёСЃС‚РёС‡РµСЃРєРёРј РґРµР№СЃС‚РІРёСЏРј',
    detected_needs: 'РћР±РЅР°СЂСѓР¶РµРЅРЅС‹Рµ РїРѕС‚СЂРµР±РЅРѕСЃС‚Рё',
    no_detected_needs: 'РЎРµР№С‡Р°СЃ РЅРµ РѕР±РЅР°СЂСѓР¶РµРЅРѕ Р°РєС‚СѓР°Р»СЊРЅС‹С… РїРѕС‚СЂРµР±РЅРѕСЃС‚РµР№ РѕС‚РґРµР»РѕРІ.',
    queued_next_actions: 'РћС‡РµСЂРµРґСЊ СЃР»РµРґСѓСЋС‰РёС… РґРµР№СЃС‚РІРёР№',
    no_queued_next: 'РЎРµР№С‡Р°СЃ РЅРµС‚ РґРµР№СЃС‚РІРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°, РїРѕСЃС‚Р°РІР»РµРЅРЅС‹С… РІ РѕС‡РµСЂРµРґСЊ.',
    positive_channel: 'РџРѕР·РёС‚РёРІРЅС‹Р№ РєР°РЅР°Р»',
    negative_channel: 'РќРµРіР°С‚РёРІРЅС‹Р№ РєР°РЅР°Р»',
    queued_antagonists: 'РћС‡РµСЂРµРґСЊ Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ',
    no_queued_antags: 'РЎРµР№С‡Р°СЃ РЅРµС‚ РїРѕРґРіРѕС‚РѕРІР»РµРЅРЅС‹С… roundstart РёР»Рё latejoin Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ.',
    active_modifiers: 'РђРєС‚РёРІРЅС‹Рµ РјРѕРґРёС„РёРєР°С‚РѕСЂС‹',
    no_active_modifiers: 'РЎРµР№С‡Р°СЃ РЅРµС‚ Р°РєС‚РёРІРЅС‹С… РІСЂРµРјРµРЅРЅС‹С… РјРѕРґРёС„РёРєР°С‚РѕСЂРѕРІ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
    positive_actions: 'РџРѕР·РёС‚РёРІРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ',
    negative_actions: 'РќРµРіР°С‚РёРІРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ',
    antagonist_actions: 'Р”РµР№СЃС‚РІРёСЏ Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ',
    no_positive_filtered: 'РџРѕ С‚РµРєСѓС‰РµРјСѓ С„РёР»СЊС‚СЂСѓ РЅРµ РЅР°Р№РґРµРЅРѕ РїРѕР·РёС‚РёРІРЅС‹С… РґРµР№СЃС‚РІРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
    no_negative_filtered: 'РџРѕ С‚РµРєСѓС‰РµРјСѓ С„РёР»СЊС‚СЂСѓ РЅРµ РЅР°Р№РґРµРЅРѕ РЅРµРіР°С‚РёРІРЅС‹С… РґРµР№СЃС‚РІРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
    no_antag_filtered: 'РџРѕ С‚РµРєСѓС‰РµРјСѓ С„РёР»СЊС‚СЂСѓ РЅРµ РЅР°Р№РґРµРЅРѕ РґРµР№СЃС‚РІРёР№ Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
    crew_staffing: 'Р­РєРёРїР°Р¶ Рё СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚СЊ',
    key_jobs_filled: 'РљР»СЋС‡РµРІС‹Рµ РґРѕР»Р¶РЅРѕСЃС‚Рё',
    cooks_service: 'РџРѕРІР°СЂР° / СЃРµСЂРІРёСЃ',
    engineers_atmos: 'РРЅР¶РµРЅРµСЂС‹ / Р°С‚РјРѕСЃ',
    threats_events: 'РЈРіСЂРѕР·С‹ Рё СЃРѕР±С‹С‚РёСЏ',
    active_round_events: 'РђРєС‚РёРІРЅС‹Рµ РёРІРµРЅС‚С‹',
    resources_economy: 'Р РµСЃСѓСЂСЃС‹ Рё СЌРєРѕРЅРѕРјРёРєР°',
    silo_materials: 'РњР°С‚РµСЂРёР°Р»С‹ РІ СЃРёР»РѕСЃРµ',
    loose_materials: 'РњР°С‚РµСЂРёР°Р»С‹ РЅР° СЃС‚Р°РЅС†РёРё',
    recent_material_gain: 'РќРµРґР°РІРЅРёР№ РїСЂРёСЂРѕСЃС‚ РјР°С‚РµСЂРёР°Р»РѕРІ',
    structural_condition: 'РЎРѕСЃС‚РѕСЏРЅРёРµ СЃС‚Р°РЅС†РёРё',
    key_jobs: 'РљР»СЋС‡РµРІС‹Рµ РїСЂРѕС„РµСЃСЃРёРё',
    department_staffing: 'РЁС‚Р°С‚ РѕС‚РґРµР»РѕРІ',
    living_antag_types: 'РўРёРїС‹ Р¶РёРІС‹С… Р°РЅС‚Р°РіРѕРІ',
    active_event_breakdown: 'Р Р°Р·Р±РёРІРєР° Р°РєС‚РёРІРЅС‹С… РёРІРµРЅС‚РѕРІ',
    department_money: 'Р”РµРЅСЊРіРё РѕС‚РґРµР»РѕРІ',
    silo_breakdown: 'Р Р°Р·Р±РёРІРєР° РјР°С‚РµСЂРёР°Р»РѕРІ СЃРёР»РѕСЃР°',
    loose_breakdown: 'Р Р°Р·Р±РёРІРєР° РјР°С‚РµСЂРёР°Р»РѕРІ РЅР° СЃС‚Р°РЅС†РёРё',
    recent_decisions: 'РќРµРґР°РІРЅРёРµ СЂРµС€РµРЅРёСЏ',
    no_decisions: 'Р РµС€РµРЅРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° РїРѕРєР° РЅРµ Р·Р°С„РёРєСЃРёСЂРѕРІР°РЅС‹.',
    active_cooldowns: 'РђРєС‚РёРІРЅС‹Рµ РєСѓР»РґР°СѓРЅС‹',
    no_cooldowns: 'РЎРµР№С‡Р°СЃ РЅРµС‚ Р°РєС‚РёРІРЅС‹С… РєСѓР»РґР°СѓРЅРѕРІ СЃРµРјРµР№.',
    advanced_notes: 'РџСЂРёРјРµС‡Р°РЅРёСЏ',
    advanced_notes_body:
      'РџСЂРѕС„РёР»Рё РјРµРЅСЏСЋС‚ С‚РµРјРїРµСЂР°РјРµРЅС‚ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РћРЅРё РїРµСЂРµРЅР°СЃС‚СЂР°РёРІР°СЋС‚ РґР°РІР»РµРЅРёРµ, СЂРѕСЃС‚ Р±СЋРґР¶РµС‚РѕРІ, Р·Р°РґРµСЂР¶РєРё РјРµР¶РґСѓ СЃРѕР±С‹С‚РёСЏРјРё, СЃРєРѕСЂРѕСЃС‚СЊ СЌСЃРєР°Р»Р°С†РёРё Рё РѕР±С‰РёР№ СЃС‚РёР»СЊ РїРѕРІРµРґРµРЅРёСЏ РїРѕРґСЃРёСЃС‚РµРјС‹.',
    advanced_notes_footer:
      'Р­С‚Р°РїС‹ РєРѕРЅС‚РµРЅС‚Р° вЂ” СЌС‚Рѕ РіР»РѕР±Р°Р»СЊРЅС‹Рµ СѓСЂРѕРІРЅРё СЂР°Р·Р±Р»РѕРєРёСЂРѕРІРєРё. 1-Р№ СЌС‚Р°Рї РґРµСЂР¶РёС‚ РєРѕРЅС‚РµРЅС‚ РјСЏРіС‡Рµ, Р° Р±РѕР»РµРµ РІС‹СЃРѕРєРёРµ СЌС‚Р°РїС‹ РѕС‚РєСЂС‹РІР°СЋС‚ С‚СЏР¶С‘Р»С‹Рµ РґРµР№СЃС‚РІРёСЏ Рё Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ РїРѕ РјРµСЂРµ СЂР°Р·РІРёС‚РёСЏ СЂР°СѓРЅРґР°.',
    yes: 'Р”Р°',
    no: 'РќРµС‚',
    ready: 'Р“РѕС‚РѕРІРѕ',
    expired: 'РСЃС‚РµРєР»Рѕ',
    none: 'РќРµС‚',
    chance: 'РЁР°РЅСЃ',
    cost: 'Р¦РµРЅР°',
    weight: 'Р’РµСЃ',
    stage: 'Р­С‚Р°Рї',
    active_window: 'РђРєС‚РёРІРЅРѕРµ РѕРєРЅРѕ',
    targets_need: 'Р¦РµР»РёС‚СЃСЏ РІ РїРѕС‚СЂРµР±РЅРѕСЃС‚СЊ',
    discard: 'РћС‚РєР»СЋС‡РёС‚СЊ',
    discarded: 'РћС‚РєР»СЋС‡РµРЅРѕ',
    cancel: 'РћС‚РјРµРЅРёС‚СЊ',
    cancel_queue_confirm: 'РћС‚РјРµРЅРёС‚СЊ РѕС‡РµСЂРµРґСЊ?',
    refund_threat: 'Р’РѕР·РІСЂР°С‚',
    pref: 'РџСЂРµС„',
    unknown: 'РќРµРёР·РІРµСЃС‚РЅРѕ',
    dynamic: 'Dynamic',
    extended: 'Extended',
    positive: 'РџРѕР·РёС‚РёРІ',
    negative: 'РќРµРіР°С‚РёРІ',
    roundstart: 'Р Р°СѓРЅРґСЃС‚Р°СЂС‚',
    midround: 'РњРёРґСЂР°СѓРЅРґ',
    latejoin: 'Р›РµР№С‚РґР¶РѕРёРЅ',
    balanced: 'РЎР±Р°Р»Р°РЅСЃРёСЂРѕРІР°РЅРЅР°СЏ РґСЂР°РјР°',
    passive: 'РўРµСЂРїРµР»РёРІС‹Р№ РєСѓСЂР°С‚РѕСЂ',
    aggressive: 'РђРіСЂРµСЃСЃРёРІРЅР°СЏ СЌСЃРєР°Р»Р°С†РёСЏ',
  },
};

const UI_TEXT_OVERRIDES: Partial<Record<PanelLanguage, Record<string, string>>> = {
  english: {
    positive_channel: 'Positive Event',
    negative_channel: 'Negative Event',
    return_action: 'Return',
    antagonist_tag: 'antag',
  },
  russian: {
    positive_actions: 'РџРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Рµ СЃРѕР±С‹С‚РёСЏ',
    negative_actions: 'РћС‚СЂРёС†Р°С‚РµР»СЊРЅС‹Рµ СЃРѕР±С‹С‚РёСЏ',
    antagonist_actions: 'РЎРѕР±С‹С‚РёСЏ СЃ Р°РЅС‚Р°РіРѕРЅРёСЃС‚Р°РјРё',
    positive_channel: 'РџРѕР»РѕР¶РёС‚РµР»СЊРЅРѕРµ СЃРѕР±С‹С‚РёРµ',
    negative_channel: 'РћС‚СЂРёС†Р°С‚РµР»СЊРЅРѕРµ СЃРѕР±С‹С‚РёРµ',
    positive: 'РџРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Р№',
    negative: 'РћС‚СЂРёС†Р°С‚РµР»СЊРЅС‹Р№',
    return_action: 'Р’РµСЂРЅСѓС‚СЊ',
    antagonist_tag: 'антаг',
    severity: 'РЎРµСЂСЊС‘Р·РЅРѕСЃС‚СЊ',
    priority: 'РџСЂРёРѕСЂРёС‚РµС‚',
    left: 'РѕСЃС‚Р°Р»РѕСЃСЊ',
  },
};

*/
const t = (language: PanelLanguage, key: string) =>
  storytellerT(language, key);

let activeStorytellerLanguage: PanelLanguage = 'english';

/* Legacy inline tooltip translations are disabled for the same reason as the
 * inline UI text above. Tooltip localization is handled in localization.ts.
const TOOLTIP_TRANSLATIONS: Record<string, string> = {
  'The current storyteller ruleset. Dynamic enables full pacing, while Extended suppresses roundstart and latejoin hostile storyteller picks and keeps only softer pressure in circulation.':
    'РўРµРєСѓС‰РёР№ СЂРµР¶РёРј СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Dynamic РІРєР»СЋС‡Р°РµС‚ РїРѕР»РЅС‹Р№ С‚РµРјРї СЃРѕР±С‹С‚РёР№, Р° Extended РїРѕРґР°РІР»СЏРµС‚ roundstart Рё latejoin РІСЂР°Р¶РґРµР±РЅС‹Рµ РІС‹Р±РѕСЂС‹ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° Рё РѕСЃС‚Р°РІР»СЏРµС‚ С‚РѕР»СЊРєРѕ Р±РѕР»РµРµ РјСЏРіРєРѕРµ РґР°РІР»РµРЅРёРµ.',
  'The active storyteller temperament. Profiles retune cadence delays, budget pressure, escalation pace, and how aggressively the subsystem pushes the round.':
    'РђРєС‚РёРІРЅС‹Р№ С‚РµРјРїРµСЂР°РјРµРЅС‚ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РџСЂРѕС„РёР»Рё РїРµСЂРµРЅР°СЃС‚СЂР°РёРІР°СЋС‚ Р·Р°РґРµСЂР¶РєРё РјРµР¶РґСѓ СЃРѕР±С‹С‚РёСЏРјРё, РґР°РІР»РµРЅРёРµ Р±СЋРґР¶РµС‚РѕРІ, С‚РµРјРї СЌСЃРєР°Р»Р°С†РёРё Рё РѕР±С‰СѓСЋ Р°РіСЂРµСЃСЃРёРІРЅРѕСЃС‚СЊ РїРѕРґСЃРёСЃС‚РµРјС‹.',
  'The current content gate. Higher stages unlock heavier events and antagonists. By default it escalates automatically unless an admin pins it.':
    'РўРµРєСѓС‰РёР№ РїСЂРµРґРµР» РєРѕРЅС‚РµРЅС‚Р°. Р‘РѕР»РµРµ РІС‹СЃРѕРєРёРµ СЌС‚Р°РїС‹ РѕС‚РєСЂС‹РІР°СЋС‚ Р±РѕР»РµРµ С‚СЏР¶С‘Р»С‹Рµ СЃРѕР±С‹С‚РёСЏ Рё Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ. РџРѕ СѓРјРѕР»С‡Р°РЅРёСЋ СЌС‚Р°Рї РїРѕРІС‹С€Р°РµС‚СЃСЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё, РµСЃР»Рё Р°РґРјРёРЅ РµРіРѕ РЅРµ Р·Р°С„РёРєСЃРёСЂРѕРІР°Р».',
  'The scheduling window the storyteller currently treats as active. During the round this is normally Midround; before setup it is Roundstart.':
    'РўРµРєСѓС‰РµРµ Р°РєС‚РёРІРЅРѕРµ РѕРєРЅРѕ РїР»Р°РЅРёСЂРѕРІР°РЅРёСЏ. Р’Рѕ РІСЂРµРјСЏ СЂР°СѓРЅРґР° СЌС‚Рѕ РѕР±С‹С‡РЅРѕ Midround, Р° РґРѕ СЃС‚Р°СЂС‚Р° РЅР°СЃС‚СЂРѕР№РєРё вЂ” Roundstart.',
  'Whether the storyteller subsystem is turned on by config at all. If this is off, the panel becomes informational only.':
    'РџРѕРєР°Р·С‹РІР°РµС‚, РІРєР»СЋС‡РµРЅР° Р»Рё РїРѕРґСЃРёСЃС‚РµРјР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° РІ РєРѕРЅС„РёРіРµ РІРѕРѕР±С‰Рµ. Р•СЃР»Рё РЅРµС‚, РїР°РЅРµР»СЊ СЃС‚Р°РЅРѕРІРёС‚СЃСЏ С‚РѕР»СЊРєРѕ РёРЅС„РѕСЂРјР°С†РёРѕРЅРЅРѕР№.',
  'When enabled, storyteller suppresses the natural autonomous pacing from SSdynamic and SSevents and becomes the round pacing owner.':
    'Р•СЃР»Рё РІРєР»СЋС‡РµРЅРѕ, СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ РїРѕРґР°РІР»СЏРµС‚ РµСЃС‚РµСЃС‚РІРµРЅРЅРѕРµ Р°РІС‚РѕРЅРѕРјРЅРѕРµ СЂР°СЃРїРёСЃР°РЅРёРµ SSdynamic Рё SSevents Рё СЃР°Рј СЃС‚Р°РЅРѕРІРёС‚СЃСЏ РіР»Р°РІРЅС‹Рј СЂРµР¶РёСЃСЃС‘СЂРѕРј С‚РµРјРїР° СЂР°СѓРЅРґР°.',
  'Pausing stops storyteller from scheduling new actions, but does not remove already running modifiers or already queued deliveries.':
    'РџР°СѓР·Р° РѕСЃС‚Р°РЅР°РІР»РёРІР°РµС‚ РїР»Р°РЅРёСЂРѕРІР°РЅРёРµ РЅРѕРІС‹С… РґРµР№СЃС‚РІРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°, РЅРѕ РЅРµ СѓР±РёСЂР°РµС‚ СѓР¶Рµ Р°РєС‚РёРІРЅС‹Рµ РјРѕРґРёС„РёРєР°С‚РѕСЂС‹ РёР»Рё СѓР¶Рµ РїРѕСЃС‚Р°РІР»РµРЅРЅС‹Рµ РІ РѕС‡РµСЂРµРґСЊ РґРѕСЃС‚Р°РІРєРё.',
  'Balanced Drama is the baseline. Patient Custodian leans toward relief and slower escalation, while Aggressive Escalation shortens hostile cadence and unlocks heavier pressure faster.':
    'Balanced Drama вЂ” Р±Р°Р·РѕРІС‹Р№ РїСЂРѕС„РёР»СЊ. Patient Custodian С‡Р°С‰Рµ СЃРєР»РѕРЅСЏРµС‚СЃСЏ Рє РїРѕРјРѕС‰Рё Рё Р±РѕР»РµРµ РјРµРґР»РµРЅРЅРѕР№ СЌСЃРєР°Р»Р°С†РёРё, Р° Aggressive Escalation СѓСЃРєРѕСЂСЏРµС‚ РІСЂР°Р¶РґРµР±РЅС‹Р№ С‚РµРјРї Рё Р±С‹СЃС‚СЂРµРµ РѕС‚РєСЂС‹РІР°РµС‚ С‚СЏР¶С‘Р»РѕРµ РґР°РІР»РµРЅРёРµ.',
  'Extended keeps relief and mild pressure. Dynamic enables the full storyteller pacing model, including hostile round pressure.':
    'Extended СЃРѕС…СЂР°РЅСЏРµС‚ РїРѕРјРѕС‰СЊ Рё РјСЏРіРєРѕРµ РґР°РІР»РµРЅРёРµ. Dynamic РІРєР»СЋС‡Р°РµС‚ РїРѕР»РЅСѓСЋ РјРѕРґРµР»СЊ С‚РµРјРїР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°, РІРєР»СЋС‡Р°СЏ РІСЂР°Р¶РґРµР±РЅРѕРµ РґР°РІР»РµРЅРёРµ РЅР° СЂР°СѓРЅРґ.',
  'This is the active content gate. Higher stages unlock heavier storyteller actions. By default it escalates automatically with round time, population, casualties, and pressure unless an admin overrides it.':
    'Р­С‚Рѕ Р°РєС‚РёРІРЅС‹Р№ РїСЂРµРґРµР» РєРѕРЅС‚РµРЅС‚Р°. Р‘РѕР»РµРµ РІС‹СЃРѕРєРёРµ СЌС‚Р°РїС‹ РѕС‚РєСЂС‹РІР°СЋС‚ Р±РѕР»РµРµ С‚СЏР¶С‘Р»С‹Рµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РџРѕ СѓРјРѕР»С‡Р°РЅРёСЋ СЌС‚Р°Рї СЂР°СЃС‚С‘С‚ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё РїРѕ РІСЂРµРјРµРЅРё СЂР°СѓРЅРґР°, РѕРЅР»Р°Р№РЅСѓ, РїРѕС‚РµСЂСЏРј Рё РѕР±С‰РµРјСѓ РґР°РІР»РµРЅРёСЋ, РµСЃР»Рё Р°РґРјРёРЅ РµРіРѕ РЅРµ РїРµСЂРµРѕРїСЂРµРґРµР»РёС‚.',
  'The active connected player count the storyteller is currently reading for scaling population-sensitive timing and action weights.':
    'РўРµРєСѓС‰РµРµ С‡РёСЃР»Рѕ Р°РєС‚РёРІРЅС‹С… РёРіСЂРѕРєРѕРІ, РєРѕС‚РѕСЂРѕРµ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ РёСЃРїРѕР»СЊР·СѓРµС‚ РґР»СЏ РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ С‚Р°Р№РјРёРЅРіРѕРІ Рё РІРµСЃРѕРІ СЃРѕР±С‹С‚РёР№, Р·Р°РІРёСЃСЏС‰РёС… РѕС‚ РѕРЅР»Р°Р№РЅР°.',
  'Living station crew detected by the storyteller snapshot. This strongly affects staffing checks, aid scaling, and cadence.':
    'РљРѕР»РёС‡РµСЃС‚РІРѕ Р¶РёРІРѕРіРѕ СЌРєРёРїР°Р¶Р°, РѕР±РЅР°СЂСѓР¶РµРЅРЅРѕРіРѕ СЃРЅРёРјРєРѕРј СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р­С‚Рѕ СЃРёР»СЊРЅРѕ РІР»РёСЏРµС‚ РЅР° РїСЂРѕРІРµСЂРєРё СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚Рё, РјР°СЃС€С‚Р°Р± РїРѕРјРѕС‰Рё Рё РѕР±С‰РёР№ С‚РµРјРї.',
  'Count of living antagonists currently detected on station. This feeds danger scoring and slows or blocks some extra hostile pressure.':
    'РљРѕР»РёС‡РµСЃС‚РІРѕ Р¶РёРІС‹С… Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ РѕР±РЅР°СЂСѓР¶РµРЅС‹ РЅР° СЃС‚Р°РЅС†РёРё. Р­С‚Рѕ РІР»РёСЏРµС‚ РЅР° РѕС†РµРЅРєСѓ РѕРїР°СЃРЅРѕСЃС‚Рё Рё РјРѕР¶РµС‚ Р·Р°РјРµРґР»СЏС‚СЊ РёР»Рё Р±Р»РѕРєРёСЂРѕРІР°С‚СЊ Р»РёС€РЅРµРµ РІСЂР°Р¶РґРµР±РЅРѕРµ РґР°РІР»РµРЅРёРµ.',
  'A structural health estimate versus the storyteller baseline snapshot. Lower integrity increases danger and pushes engineering-focused relief.':
    'РћС†РµРЅРєР° СЃС‚СЂСѓРєС‚СѓСЂРЅРѕРіРѕ СЃРѕСЃС‚РѕСЏРЅРёСЏ СЃС‚Р°РЅС†РёРё РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ Р±Р°Р·РѕРІРѕРіРѕ СЃРЅРёРјРєР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р§РµРј РЅРёР¶Рµ С†РµР»РѕСЃС‚РЅРѕСЃС‚СЊ, С‚РµРј РІС‹С€Рµ РѕРїР°СЃРЅРѕСЃС‚СЊ Рё С‚РµРј СЃРёР»СЊРЅРµРµ СѓРїРѕСЂ РЅР° РёРЅР¶РµРЅРµСЂРЅСѓСЋ РїРѕРјРѕС‰СЊ.',
  'A stability score built from staffing, intact structure, resources, and general station control. Higher control supports more negative pressure.':
    'РџРѕРєР°Р·Р°С‚РµР»СЊ СЃС‚Р°Р±РёР»СЊРЅРѕСЃС‚Рё, СЃРѕР±СЂР°РЅРЅС‹Р№ РёР· СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚Рё, С†РµР»РѕСЃС‚РЅРѕСЃС‚Рё СЃС‚Р°РЅС†РёРё, СЂРµСЃСѓСЂСЃРѕРІ Рё РѕР±С‰РµРіРѕ СѓСЂРѕРІРЅСЏ РєРѕРЅС‚СЂРѕР»СЏ. Р‘РѕР»РµРµ РІС‹СЃРѕРєРёР№ РєРѕРЅС‚СЂРѕР»СЊ РїРѕРґРґРµСЂР¶РёРІР°РµС‚ Р±РѕР»СЊС€РµРµ РѕС‚СЂРёС†Р°С‚РµР»СЊРЅРѕРµ РґР°РІР»РµРЅРёРµ.',
  'A crisis score built from deaths, explosions, alarms, station damage, active threats, and weak staffing. Higher danger pushes relief and slows extra punishment.':
    'РџРѕРєР°Р·Р°С‚РµР»СЊ РєСЂРёР·РёСЃР°, СЃРѕР±СЂР°РЅРЅС‹Р№ РёР· СЃРјРµСЂС‚РµР№, РІР·СЂС‹РІРѕРІ, С‚СЂРµРІРѕРі, РїРѕРІСЂРµР¶РґРµРЅРёР№ СЃС‚Р°РЅС†РёРё, Р°РєС‚РёРІРЅС‹С… СѓРіСЂРѕР· Рё СЃР»Р°Р±РѕР№ СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚Рё. Р‘РѕР»РµРµ РІС‹СЃРѕРєР°СЏ РѕРїР°СЃРЅРѕСЃС‚СЊ СѓСЃРёР»РёРІР°РµС‚ РїРѕРјРѕС‰СЊ Рё Р·Р°РјРµРґР»СЏРµС‚ Р»РёС€РЅРµРµ РЅР°РєР°Р·Р°РЅРёРµ.',
  'Negative storyteller actions spend from this pool. It generally grows when the station is stable enough to withstand more pressure.':
    'РћС‚СЂРёС†Р°С‚РµР»СЊРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° С‚СЂР°С‚СЏС‚ РѕС‡РєРё РёР· СЌС‚РѕРіРѕ РїСѓР»Р°. РћР±С‹С‡РЅРѕ РѕРЅ СЂР°СЃС‚С‘С‚, РєРѕРіРґР° СЃС‚Р°РЅС†РёСЏ РґРѕСЃС‚Р°С‚РѕС‡РЅРѕ СЃС‚Р°Р±РёР»СЊРЅР°, С‡С‚РѕР±С‹ РІС‹РґРµСЂР¶Р°С‚СЊ Р±РѕР»СЊС€РµРµ РґР°РІР»РµРЅРёРµ.',
  'Positive storyteller actions spend from this pool. It generally grows when the station is struggling and needs intervention.':
    'РџРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° С‚СЂР°С‚СЏС‚ РѕС‡РєРё РёР· СЌС‚РѕРіРѕ РїСѓР»Р°. РћР±С‹С‡РЅРѕ РѕРЅ СЂР°СЃС‚С‘С‚, РєРѕРіРґР° СЃС‚Р°РЅС†РёСЏ РёСЃРїС‹С‚С‹РІР°РµС‚ С‚СЂСѓРґРЅРѕСЃС‚Рё Рё РЅСѓР¶РґР°РµС‚СЃСЏ РІРѕ РІРјРµС€Р°С‚РµР»СЊСЃС‚РІРµ.',
  'A short fatigue lock after a positive action fires. While this is active, the aid channel cannot immediately fire again.':
    'РљРѕСЂРѕС‚РєРёР№ Р»РѕРє СѓСЃС‚Р°Р»РѕСЃС‚Рё РїРѕСЃР»Рµ СЃСЂР°Р±Р°С‚С‹РІР°РЅРёСЏ РїРѕР»РѕР¶РёС‚РµР»СЊРЅРѕРіРѕ РґРµР№СЃС‚РІРёСЏ. РџРѕРєР° РѕРЅ Р°РєС‚РёРІРµРЅ, РєР°РЅР°Р» РїРѕРјРѕС‰Рё РЅРµ РјРѕР¶РµС‚ СЃСЂР°Р·Сѓ СЃСЂР°Р±РѕС‚Р°С‚СЊ СЃРЅРѕРІР°.',
  'Time until the positive channel is allowed to roll again. This scales with round state, population, and prior action impact.':
    'Р’СЂРµРјСЏ РґРѕ СЃР»РµРґСѓСЋС‰РµРіРѕ СЂР°Р·СЂРµС€С‘РЅРЅРѕРіРѕ Р±СЂРѕСЃРєР° РїРѕР»РѕР¶РёС‚РµР»СЊРЅРѕРіРѕ РєР°РЅР°Р»Р°. РћРЅРѕ РјР°СЃС€С‚Р°Р±РёСЂСѓРµС‚СЃСЏ РѕС‚ СЃРѕСЃС‚РѕСЏРЅРёСЏ СЂР°СѓРЅРґР°, РѕРЅР»Р°Р№РЅР° Рё СЃРёР»С‹ РїСЂРµРґС‹РґСѓС‰РµРіРѕ РґРµР№СЃС‚РІРёСЏ.',
  'A short fatigue lock after a negative action fires. While this is active, the hostile channel cannot immediately fire again.':
    'РљРѕСЂРѕС‚РєРёР№ Р»РѕРє СѓСЃС‚Р°Р»РѕСЃС‚Рё РїРѕСЃР»Рµ СЃСЂР°Р±Р°С‚С‹РІР°РЅРёСЏ РѕС‚СЂРёС†Р°С‚РµР»СЊРЅРѕРіРѕ РґРµР№СЃС‚РІРёСЏ. РџРѕРєР° РѕРЅ Р°РєС‚РёРІРµРЅ, РІСЂР°Р¶РґРµР±РЅС‹Р№ РєР°РЅР°Р» РЅРµ РјРѕР¶РµС‚ СЃСЂР°Р·Сѓ СЃСЂР°Р±РѕС‚Р°С‚СЊ СЃРЅРѕРІР°.',
  'Time until the negative channel is allowed to roll again. This is dynamically scaled by population, damage, casualties, and previous impact.':
    'Р’СЂРµРјСЏ РґРѕ СЃР»РµРґСѓСЋС‰РµРіРѕ СЂР°Р·СЂРµС€С‘РЅРЅРѕРіРѕ Р±СЂРѕСЃРєР° РѕС‚СЂРёС†Р°С‚РµР»СЊРЅРѕРіРѕ РєР°РЅР°Р»Р°. РћРЅРѕ РґРёРЅР°РјРёС‡РµСЃРєРё РјР°СЃС€С‚Р°Р±РёСЂСѓРµС‚СЃСЏ РїРѕ РѕРЅР»Р°Р№РЅСѓ, СѓСЂРѕРЅСѓ, РїРѕС‚РµСЂСЏРј Рё СЃРёР»Рµ РїСЂРµРґС‹РґСѓС‰РµРіРѕ РґРµР№СЃС‚РІРёСЏ.',
  'Cooldown before another hostile latejoin storyteller antagonist can be assigned.':
    'РљСѓР»РґР°СѓРЅ РїРµСЂРµРґ С‚РµРј, РєР°Рє СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ СЃРјРѕР¶РµС‚ СЃРЅРѕРІР° РІС‹РґР°С‚СЊ РІСЂР°Р¶РґРµР±РЅРѕРіРѕ latejoin-Р°РЅС‚Р°РіРѕРЅРёСЃС‚Р°.',
  'The initial start-of-round lock that prevents storyteller latejoin antagonists from firing too early.':
    'РЎС‚Р°СЂС‚РѕРІС‹Р№ Р»РѕРє РЅР°С‡Р°Р»Р° СЂР°СѓРЅРґР°, РєРѕС‚РѕСЂС‹Р№ РЅРµ РґР°С‘С‚ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂСѓ СЃР»РёС€РєРѕРј СЂР°РЅРѕ РІС‹РґР°РІР°С‚СЊ latejoin-Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ.',
  'Current cargo department budget. Low cargo funds can increase cargo-focused aid or economic support actions.':
    'РўРµРєСѓС‰РёР№ Р±СЋРґР¶РµС‚ РѕС‚РґРµР»Р° РєР°СЂРіРѕ. РќРёР·РєРёРµ СЃСЂРµРґСЃС‚РІР° РєР°СЂРіРѕ РјРѕРіСѓС‚ РїРѕРІС‹С€Р°С‚СЊ С€Р°РЅСЃ РїРѕРјРѕС‰Рё РєР°СЂРіРѕ РёР»Рё СЌРєРѕРЅРѕРјРёС‡РµСЃРєРѕР№ РїРѕРґРґРµСЂР¶РєРё.',
  'Active alarms detected across the station. This contributes to danger and several department crisis analyzers.':
    'РђРєС‚РёРІРЅС‹Рµ С‚СЂРµРІРѕРіРё, РѕР±РЅР°СЂСѓР¶РµРЅРЅС‹Рµ РїРѕ СЃС‚Р°РЅС†РёРё. РћРЅРё РїРѕРІС‹С€Р°СЋС‚ РѕРїР°СЃРЅРѕСЃС‚СЊ Рё РІР»РёСЏСЋС‚ РЅР° РЅРµСЃРєРѕР»СЊРєРѕ Р°РЅР°Р»РёР·Р°С‚РѕСЂРѕРІ РєСЂРёР·РёСЃРѕРІ РѕС‚РґРµР»РѕРІ.',
  "Crew deaths seen within the storyteller's recent tracking window. This strongly increases danger and medical/security response pressure.":
    'РЎРјРµСЂС‚Рё СЌРєРёРїР°Р¶Р°, Р·Р°РјРµС‡РµРЅРЅС‹Рµ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂРѕРј РІ РЅРµРґР°РІРЅРµРј РѕРєРЅРµ РѕС‚СЃР»РµР¶РёРІР°РЅРёСЏ. Р­С‚Рѕ СЃРёР»СЊРЅРѕ РїРѕРІС‹С€Р°РµС‚ РѕРїР°СЃРЅРѕСЃС‚СЊ Рё РґР°РІР»РµРЅРёРµ РЅР° РјРµРґРёС†РёРЅСѓ Рё СЃР»СѓР¶Р±Сѓ Р±РµР·РѕРїР°СЃРЅРѕСЃС‚Рё.',
  'Recent on-station explosions seen within the storyteller tracking window. This boosts danger and several engineering-focused reactions.':
    'РќРµРґР°РІРЅРёРµ РІР·СЂС‹РІС‹ РЅР° СЃС‚Р°РЅС†РёРё, Р·Р°РјРµС‡РµРЅРЅС‹Рµ РІ РѕРєРЅРµ РѕС‚СЃР»РµР¶РёРІР°РЅРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р­С‚Рѕ РїРѕРІС‹С€Р°РµС‚ РѕРїР°СЃРЅРѕСЃС‚СЊ Рё СѓСЃРёР»РёРІР°РµС‚ РЅРµСЃРєРѕР»СЊРєРѕ РёРЅР¶РµРЅРµСЂРЅС‹С… СЂРµР°РєС†РёР№.',
  'Approximate food stock the storyteller sees in kitchen and service areas. Low values drive food-shortage relief.':
    'РџСЂРёРјРµСЂРЅС‹Р№ Р·Р°РїР°СЃ РµРґС‹, РєРѕС‚РѕСЂС‹Р№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ РІРёРґРёС‚ РІ Р·РѕРЅР°С… РєСѓС…РЅРё Рё СЃРµСЂРІРёСЃР°. РќРёР·РєРёРµ Р·РЅР°С‡РµРЅРёСЏ РїРѕРґС‚Р°Р»РєРёРІР°СЋС‚ Рє РїРѕРјРѕС‰Рё РїСЂРё РЅРµС…РІР°С‚РєРµ РµРґС‹.',
  'Current staffing snapshot for cargo technicians and miners. This affects cargo relief and several mining/material pressure calculations.':
    'РўРµРєСѓС‰РёР№ СЃРЅРёРјРѕРє СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚Рё РєР°СЂРіРѕС‚РµС…РѕРІ Рё С€Р°С…С‚С‘СЂРѕРІ. Р­С‚Рѕ РІР»РёСЏРµС‚ РЅР° РїРѕРјРѕС‰СЊ РєР°СЂРіРѕ Рё РЅРµСЃРєРѕР»СЊРєРѕ СЂР°СЃС‡С‘С‚РѕРІ РґР°РІР»РµРЅРёСЏ РїРѕ РґРѕР±С‹С‡Рµ Рё РјР°С‚РµСЂРёР°Р»Р°Рј.',
  'Approximate breached space exposure versus broken floor tiles. Both feed structural damage estimates, but breaches are treated as more urgent.':
    'РџСЂРёРјРµСЂРЅРѕРµ СЃРѕРѕС‚РЅРѕС€РµРЅРёРµ СЂР°Р·РіРµСЂРјРµС‚РёР·РёСЂРѕРІР°РЅРЅС‹С… СѓС‡Р°СЃС‚РєРѕРІ Рё СЃР»РѕРјР°РЅРЅС‹С… РїРѕР»РѕРІ. РћР±Р° Р·РЅР°С‡РµРЅРёСЏ РІР»РёСЏСЋС‚ РЅР° РѕС†РµРЅРєСѓ СЃС‚СЂСѓРєС‚СѓСЂРЅРѕРіРѕ СѓСЂРѕРЅР°, РЅРѕ СЂР°Р·РіРµСЂРјР° СЃС‡РёС‚Р°РµС‚СЃСЏ Р±РѕР»РµРµ СЃСЂРѕС‡РЅРѕР№.',
  'Damaged windows and grilles detected by the structural scan. These help measure engineering backlog beyond raw integrity.':
    'РџРѕРІСЂРµР¶РґС‘РЅРЅС‹Рµ РѕРєРЅР° Рё СЂРµС€С‘С‚РєРё, РѕР±РЅР°СЂСѓР¶РµРЅРЅС‹Рµ СЃС‚СЂСѓРєС‚СѓСЂРЅС‹Рј СЃРєР°РЅРѕРј. РћРЅРё РїРѕРјРѕРіР°СЋС‚ РѕС†РµРЅРёРІР°С‚СЊ РёРЅР¶РµРЅРµСЂРЅС‹Р№ Р·Р°РІР°Р» РїРѕРјРёРјРѕ РїСЂРѕСЃС‚РѕР№ С†РµР»РѕСЃС‚РЅРѕСЃС‚Рё СЃС‚Р°РЅС†РёРё.',
  'Set a specific storyteller temperament manually. Auto returns control to population-weighted random profile selection.':
    'Р’СЂСѓС‡РЅСѓСЋ Р·Р°РґР°С‘С‚ РєРѕРЅРєСЂРµС‚РЅС‹Р№ С‚РµРјРїРµСЂР°РјРµРЅС‚ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РљРЅРѕРїРєР° Auto РІРѕР·РІСЂР°С‰Р°РµС‚ СѓРїСЂР°РІР»РµРЅРёРµ Рє СЃР»СѓС‡Р°Р№РЅРѕРјСѓ РІС‹Р±РѕСЂСѓ РїСЂРѕС„РёР»СЏ СЃ СѓС‡С‘С‚РѕРј РѕРЅР»Р°Р№РЅР°.',
  'Pins the maximum unlocked storyteller stage manually. Auto hands control back to the automatic escalation model.':
    'Р’СЂСѓС‡РЅСѓСЋ С„РёРєСЃРёСЂСѓРµС‚ РјР°РєСЃРёРјР°Р»СЊРЅС‹Р№ РѕС‚РєСЂС‹С‚С‹Р№ СЌС‚Р°Рї СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РљРЅРѕРїРєР° Auto РІРѕР·РІСЂР°С‰Р°РµС‚ СѓРїСЂР°РІР»РµРЅРёРµ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕР№ РјРѕРґРµР»Рё СЌСЃРєР°Р»Р°С†РёРё.',
  'Search the storyteller catalog and arm or immediately force an action. Force NOW bypasses normal availability checks.':
    'РџРѕР·РІРѕР»СЏРµС‚ РёСЃРєР°С‚СЊ РїРѕ РєР°С‚Р°Р»РѕРіСѓ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° Рё СЃС‚Р°РІРёС‚СЊ РґРµР№СЃС‚РІРёРµ РІ РѕС‡РµСЂРµРґСЊ РёР»Рё С„РѕСЂСЃРёС‚СЊ РµРіРѕ СЃСЂР°Р·Сѓ. Force NOW РѕР±С…РѕРґРёС‚ РѕР±С‹С‡РЅС‹Рµ РїСЂРѕРІРµСЂРєРё РґРѕСЃС‚СѓРїРЅРѕСЃС‚Рё.',
  'Antagonists already armed for roundstart, latejoin, or the next storyteller hostile window. Canceling a queued storyteller antag refunds any reserved threat budget.':
    'РђРЅС‚Р°РіРѕРЅРёСЃС‚С‹, СѓР¶Рµ РїРѕРґРіРѕС‚РѕРІР»РµРЅРЅС‹Рµ РґР»СЏ roundstart, latejoin РёР»Рё СЃР»РµРґСѓСЋС‰РµРіРѕ РІСЂР°Р¶РґРµР±РЅРѕРіРѕ РѕРєРЅР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. РћС‚РјРµРЅР° РїРѕРґРіРѕС‚РѕРІР»РµРЅРЅРѕРіРѕ Р°РЅС‚Р°РіРѕРЅРёСЃС‚Р° РІРѕР·РІСЂР°С‰Р°РµС‚ Р·Р°СЂРµР·РµСЂРІРёСЂРѕРІР°РЅРЅС‹Р№ Р±СЋРґР¶РµС‚ СѓРіСЂРѕР·С‹.',
  'Currently running temporary storyteller buffs and debuffs. These are live round effects with their own timers and department-specific behavior.':
    'Р’СЂРµРјРµРЅРЅРѕ Р°РєС‚РёРІРЅС‹Рµ Р±Р°С„С„С‹ Рё РґРµР±Р°С„С„С‹ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р­С‚Рѕ Р¶РёРІС‹Рµ СЌС„С„РµРєС‚С‹ СЂР°СѓРЅРґР° СЃРѕ СЃРІРѕРёРјРё С‚Р°Р№РјРµСЂР°РјРё Рё РїРѕРІРµРґРµРЅРёРµРј, Р·Р°РІСЏР·Р°РЅРЅС‹Рј РЅР° РѕС‚РґРµР»С‹.',
  'Filters the positive, negative, and antagonist action lists below by name, context, polarity, family, need target, and availability reason.':
    'Р¤РёР»СЊС‚СЂСѓРµС‚ СЃРїРёСЃРєРё РїРѕР»РѕР¶РёС‚РµР»СЊРЅС‹С…, РѕС‚СЂРёС†Р°С‚РµР»СЊРЅС‹С… Рё Р°РЅС‚Р°РіРѕРЅРёСЃС‚РёС‡РµСЃРєРёС… РґРµР№СЃС‚РІРёР№ РЅРёР¶Рµ РїРѕ РЅР°Р·РІР°РЅРёСЋ, РєРѕРЅС‚РµРєСЃС‚Сѓ, РїРѕР»СЏСЂРЅРѕСЃС‚Рё, СЃРµРјРµР№СЃС‚РІСѓ, С†РµР»РµРІРѕР№ РїРѕС‚СЂРµР±РЅРѕСЃС‚Рё Рё РїСЂРёС‡РёРЅРµ РЅРµРґРѕСЃС‚СѓРїРЅРѕСЃС‚Рё.',
  'All positive storyteller actions currently in the catalog. Chance reflects the current positive candidate pool; unavailable actions remain visible with their blocking reason.':
    'Р’СЃРµ РїРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ РµСЃС‚СЊ РІ РєР°С‚Р°Р»РѕРіРµ. РЁР°РЅСЃ РѕС‚СЂР°Р¶Р°РµС‚ С‚РµРєСѓС‰РёР№ РїСѓР» РїРѕР»РѕР¶РёС‚РµР»СЊРЅС‹С… РєР°РЅРґРёРґР°С‚РѕРІ; РЅРµРґРѕСЃС‚СѓРїРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ РІСЃС‘ СЂР°РІРЅРѕ РІРёРґРЅС‹ РІРјРµСЃС‚Рµ СЃ РїСЂРёС‡РёРЅРѕР№ Р±Р»РѕРєРёСЂРѕРІРєРё.',
  'All non-antagonist negative storyteller actions currently in the catalog. Chance reflects the current negative candidate pool; unavailable actions remain visible with their blocking reason.':
    'Р’СЃРµ РѕС‚СЂРёС†Р°С‚РµР»СЊРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° Р±РµР· Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ РµСЃС‚СЊ РІ РєР°С‚Р°Р»РѕРіРµ. РЁР°РЅСЃ РѕС‚СЂР°Р¶Р°РµС‚ С‚РµРєСѓС‰РёР№ РїСѓР» РѕС‚СЂРёС†Р°С‚РµР»СЊРЅС‹С… РєР°РЅРґРёРґР°С‚РѕРІ; РЅРµРґРѕСЃС‚СѓРїРЅС‹Рµ РґРµР№СЃС‚РІРёСЏ РІСЃС‘ СЂР°РІРЅРѕ РІРёРґРЅС‹ РІРјРµСЃС‚Рµ СЃ РїСЂРёС‡РёРЅРѕР№ Р±Р»РѕРєРёСЂРѕРІРєРё.',
  'All storyteller antagonist actions across roundstart, midround, and latejoin contexts. Discard marks an antag as disabled for the rest of the round without removing it from the list.':
    'Р’СЃРµ Р°РЅС‚Р°РіРѕРЅРёСЃС‚РёС‡РµСЃРєРёРµ РґРµР№СЃС‚РІРёСЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° РґР»СЏ roundstart, midround Рё latejoin. Discard РѕС‚РєР»СЋС‡Р°РµС‚ Р°РЅС‚Р°РіРѕРЅРёСЃС‚Р° РґРѕ РєРѕРЅС†Р° СЂР°СѓРЅРґР°, РЅРѕ РЅРµ СѓР±РёСЂР°РµС‚ РµРіРѕ РёР· СЃРїРёСЃРєР°.',
  'The staffing half of the storyteller snapshot. These values feed job coverage checks, department aid routing, and several event weight modifiers.':
    'РљР°РґСЂРѕРІР°СЏ РїРѕР»РѕРІРёРЅР° СЃРЅРёРјРєР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р­С‚Рё Р·РЅР°С‡РµРЅРёСЏ СѓС‡Р°СЃС‚РІСѓСЋС‚ РІ РїСЂРѕРІРµСЂРєР°С… РїРѕРєСЂС‹С‚РёСЏ РїСЂРѕС„РµСЃСЃРёР№, РјР°СЂС€СЂСѓС‚РёР·Р°С†РёРё РїРѕРјРѕС‰Рё РѕС‚РґРµР»Р°Рј Рё РЅРµСЃРєРѕР»СЊРєРёС… РјРѕРґРёС„РёРєР°С‚РѕСЂР°С… РІРµСЃР° СЃРѕР±С‹С‚РёР№.',
  'How many critical command and department anchor jobs are currently occupied out of the storyteller key-job list.':
    'РЎРєРѕР»СЊРєРѕ РєСЂРёС‚РёС‡РµСЃРєРё РІР°Р¶РЅС‹С… РєРѕРјР°РЅРґРЅС‹С… Рё РѕРїРѕСЂРЅС‹С… РґРѕР»Р¶РЅРѕСЃС‚РµР№ РѕС‚РґРµР»РѕРІ СЃРµР№С‡Р°СЃ Р·Р°РЅСЏС‚Рѕ РёР· СЃРїРёСЃРєР° РєР»СЋС‡РµРІС‹С… РїСЂРѕС„РµСЃСЃРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
  'Service staffing focus numbers used for food, janitorial, and hospitality-related needs.':
    'РџРѕРєР°Р·Р°С‚РµР»Рё СЃРµСЂРІРёСЃРЅРѕР№ СѓРєРѕРјРїР»РµРєС‚РѕРІР°РЅРЅРѕСЃС‚Рё, РёСЃРїРѕР»СЊР·СѓРµРјС‹Рµ РґР»СЏ РїРѕС‚СЂРµР±РЅРѕСЃС‚РµР№, СЃРІСЏР·Р°РЅРЅС‹С… СЃ РµРґРѕР№, СѓР±РѕСЂРєРѕР№ Рё РіРѕСЃС‚РµРїСЂРёРёРјСЃС‚РІРѕРј.',
  'Engineering and atmospherics staffing counts used for repair, power, and environmental pressure calculations.':
    'Р§РёСЃР»РµРЅРЅРѕСЃС‚СЊ РёРЅР¶РµРЅРµСЂРЅРѕРіРѕ Рё Р°С‚РјРѕСЃС„РµСЂРЅРѕРіРѕ РїРµСЂСЃРѕРЅР°Р»Р°, РёСЃРїРѕР»СЊР·СѓРµРјР°СЏ РґР»СЏ СЂР°СЃС‡С‘С‚РѕРІ СЂРµРјРѕРЅС‚Р°, СЌРЅРµСЂРіРёРё Рё СЌРєРѕР»РѕРіРёС‡РµСЃРєРѕРіРѕ РґР°РІР»РµРЅРёСЏ.',
  'Cargo office and mining staffing counts used for ore, logistics, and budget relief calculations.':
    'Р§РёСЃР»РµРЅРЅРѕСЃС‚СЊ РєР°СЂРіРѕ Рё С€Р°С…С‚С‘СЂРѕРІ, РёСЃРїРѕР»СЊР·СѓРµРјР°СЏ РґР»СЏ СЂР°СЃС‡С‘С‚РѕРІ РїРѕ СЂСѓРґРµ, Р»РѕРіРёСЃС‚РёРєРµ Рё Р±СЋРґР¶РµС‚РЅРѕР№ РїРѕРјРѕС‰Рё.',
  'A per-role occupancy breakdown for storyteller-critical jobs such as command, engineering, medical, and other round anchors.':
    'Р Р°Р·Р±РёРІРєР° Р·Р°РЅСЏС‚РѕСЃС‚Рё РїРѕ СЂРѕР»СЏРј РґР»СЏ РєСЂРёС‚РёС‡РЅС‹С… РґР»СЏ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР° РїСЂРѕС„РµСЃСЃРёР№: РєРѕРјР°РЅРґРѕРІР°РЅРёРµ, РёРЅР¶РµРЅРµСЂРёСЏ, РјРµРґРёС†РёРЅР° Рё РґСЂСѓРіРёРµ РѕРїРѕСЂРЅС‹Рµ СЂРѕР»Рё СЂР°СѓРЅРґР°.',
  'A department-level headcount breakdown the storyteller uses for staffing-aware relief and pressure.':
    'Р Р°Р·Р±РёРІРєР° С‡РёСЃР»РµРЅРЅРѕСЃС‚Рё РїРѕ РѕС‚РґРµР»Р°Рј, РєРѕС‚РѕСЂСѓСЋ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ РёСЃРїРѕР»СЊР·СѓРµС‚ РґР»СЏ РїРѕРјРѕС‰Рё Рё РґР°РІР»РµРЅРёСЏ СЃ СѓС‡С‘С‚РѕРј С€С‚Р°С‚Р°.',
  'The danger-facing half of the storyteller snapshot. These values show live hostile presence and currently running event pressure.':
    'РћРїР°СЃРЅР°СЏ РїРѕР»РѕРІРёРЅР° СЃРЅРёРјРєР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°. Р­С‚Рё Р·РЅР°С‡РµРЅРёСЏ РїРѕРєР°Р·С‹РІР°СЋС‚ Р¶РёРІРѕРµ РІСЂР°Р¶РґРµР±РЅРѕРµ РїСЂРёСЃСѓС‚СЃС‚РІРёРµ Рё С‚РµРєСѓС‰РµРµ РґР°РІР»РµРЅРёРµ Р°РєС‚РёРІРЅС‹С… СЃРѕР±С‹С‚РёР№.',
  'Total living antagonists currently detected by the storyteller snapshot.':
    'РћР±С‰РµРµ РєРѕР»РёС‡РµСЃС‚РІРѕ Р¶РёРІС‹С… Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ, РєРѕС‚РѕСЂРѕРµ СЃРµР№С‡Р°СЃ РѕР±РЅР°СЂСѓР¶РµРЅРѕ СЃРЅРёРјРєРѕРј СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
  'The number of currently active round-event instances the storyteller can see right now.':
    'РљРѕР»РёС‡РµСЃС‚РІРѕ СЌРєР·РµРјРїР»СЏСЂРѕРІ Р°РєС‚РёРІРЅС‹С… РёРІРµРЅС‚РѕРІ СЂР°СѓРЅРґР°, РєРѕС‚РѕСЂС‹Рµ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ СЃРµР№С‡Р°СЃ РІРёРґРёС‚.',
  'The number of active alarms currently contributing to the danger picture.':
    'РљРѕР»РёС‡РµСЃС‚РІРѕ Р°РєС‚РёРІРЅС‹С… С‚СЂРµРІРѕРі, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ СѓС‡Р°СЃС‚РІСѓСЋС‚ РІ РѕР±С‰РµР№ РєР°СЂС‚РёРЅРµ РѕРїР°СЃРЅРѕСЃС‚Рё.',
  'A live type breakdown of antagonists the storyteller sees in the current round snapshot.':
    'Р–РёРІР°СЏ СЂР°Р·Р±РёРІРєР° РїРѕ С‚РёРїР°Рј Р°РЅС‚Р°РіРѕРЅРёСЃС‚РѕРІ, РєРѕС‚РѕСЂС‹С… СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ РІРёРґРёС‚ РІ С‚РµРєСѓС‰РµРј СЃРЅРёРјРєРµ СЂР°СѓРЅРґР°.',
  'A live breakdown of currently running round events grouped by event type. This is not a history log; entries disappear once those events end.':
    'Р–РёРІР°СЏ СЂР°Р·Р±РёРІРєР° РїРѕ С‚РёРїР°Рј С‚РµРєСѓС‰РёС… Р°РєС‚РёРІРЅС‹С… РёРІРµРЅС‚РѕРІ СЂР°СѓРЅРґР°. Р­С‚Рѕ РЅРµ Р¶СѓСЂРЅР°Р» РёСЃС‚РѕСЂРёРё: Р·Р°РїРёСЃРё РёСЃС‡РµР·Р°СЋС‚ РїРѕСЃР»Рµ Р·Р°РІРµСЂС€РµРЅРёСЏ СЃРѕРѕС‚РІРµС‚СЃС‚РІСѓСЋС‰РёС… СЃРѕР±С‹С‚РёР№.',
  'The supply side of the storyteller snapshot: money, food, ore-silo stock, loose materials, and recent material intake.':
    'РЎРЅР°Р±Р¶РµРЅС‡РµСЃРєР°СЏ СЃС‚РѕСЂРѕРЅР° СЃРЅРёРјРєР° СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°: РґРµРЅСЊРіРё, РµРґР°, Р·Р°РїР°СЃС‹ РІ СЃРёР»РѕСЃРµ, СЃРІРѕР±РѕРґРЅС‹Рµ РјР°С‚РµСЂРёР°Р»С‹ Рё РЅРµРґР°РІРЅРёР№ РїСЂРёС‚РѕРє СЂРµСЃСѓСЂСЃРѕРІ.',
  'Current cargo budget available to the station economy.':
    'РўРµРєСѓС‰РёР№ Р±СЋРґР¶РµС‚ РєР°СЂРіРѕ, РґРѕСЃС‚СѓРїРЅС‹Р№ СЌРєРѕРЅРѕРјРёРєРµ СЃС‚Р°РЅС†РёРё.',
  'Food stock the storyteller counts in kitchen and service spaces.':
    'Р—Р°РїР°СЃ РµРґС‹, РєРѕС‚РѕСЂС‹Р№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂ СѓС‡РёС‚С‹РІР°РµС‚ РІ РєСѓС…РѕРЅРЅС‹С… Рё СЃРµСЂРІРёСЃРЅС‹С… Р·РѕРЅР°С….',
  'Total raw materials currently accessible in the ore silo.':
    'РћР±С‰РµРµ РєРѕР»РёС‡РµСЃС‚РІРѕ СЃС‹СЂС‹С… РјР°С‚РµСЂРёР°Р»РѕРІ, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ РґРѕСЃС‚СѓРїРЅС‹ РІ СЂСѓРґРЅРѕРј СЃРёР»РѕСЃРµ.',
  'Total loose material stacks found around the station during the heavy scan.':
    'РћР±С‰РµРµ РєРѕР»РёС‡РµСЃС‚РІРѕ СЃРІРѕР±РѕРґРЅС‹С… СЃС‚РѕРїРѕРє РјР°С‚РµСЂРёР°Р»РѕРІ, РЅР°Р№РґРµРЅРЅС‹С… РїРѕ СЃС‚Р°РЅС†РёРё РІРѕ РІСЂРµРјСЏ С‚СЏР¶С‘Р»РѕРіРѕ СЃРєР°РЅР°.',
  'Change in total known material stock since the previous heavy snapshot. Useful for detecting whether mining is keeping up.':
    'РР·РјРµРЅРµРЅРёРµ РѕР±С‰РµРіРѕ РёР·РІРµСЃС‚РЅРѕРіРѕ Р·Р°РїР°СЃР° РјР°С‚РµСЂРёР°Р»РѕРІ СЃ РјРѕРјРµРЅС‚Р° РїСЂРѕС€Р»РѕРіРѕ С‚СЏР¶С‘Р»РѕРіРѕ СЃРЅРёРјРєР°. РџРѕР»РµР·РЅРѕ РґР»СЏ РѕС†РµРЅРєРё, СѓСЃРїРµРІР°РµС‚ Р»Рё С€Р°С…С‚Р°.',
  'Per-department account balances available to the storyteller for budget-aware actions and needs.':
    'Р‘Р°Р»Р°РЅСЃ СЃС‡РµС‚РѕРІ РїРѕ РѕС‚РґРµР»Р°Рј, РґРѕСЃС‚СѓРїРЅС‹Р№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂСѓ РґР»СЏ РґРµР№СЃС‚РІРёР№ Рё РїРѕС‚СЂРµР±РЅРѕСЃС‚РµР№, Р·Р°РІСЏР·Р°РЅРЅС‹С… РЅР° Р±СЋРґР¶РµС‚.',
  'Raw material stock currently detected in the ore silo, grouped by material type.':
    'Р—Р°РїР°СЃ СЃС‹СЂСЊСЏ, РєРѕС‚РѕСЂС‹Р№ СЃРµР№С‡Р°СЃ РѕР±РЅР°СЂСѓР¶РµРЅ РІ СЂСѓРґРЅРѕРј СЃРёР»РѕСЃРµ, СЃРіСЂСѓРїРїРёСЂРѕРІР°РЅРЅС‹Р№ РїРѕ С‚РёРїР°Рј РјР°С‚РµСЂРёР°Р»РѕРІ.',
  'Loose station-side material stacks grouped by material type.':
    'РЎРІРѕР±РѕРґРЅС‹Рµ СЃС‚РѕРїРєРё РјР°С‚РµСЂРёР°Р»РѕРІ РЅР° СЃС‚Р°РЅС†РёРё, СЃРіСЂСѓРїРїРёСЂРѕРІР°РЅРЅС‹Рµ РїРѕ С‚РёРїР°Рј РјР°С‚РµСЂРёР°Р»РѕРІ.',
  'Structural health metrics used to estimate station integrity and the engineering repair backlog.':
    'РџРѕРєР°Р·Р°С‚РµР»Рё СЃС‚СЂСѓРєС‚СѓСЂРЅРѕРіРѕ СЃРѕСЃС‚РѕСЏРЅРёСЏ, РёСЃРїРѕР»СЊР·СѓРµРјС‹Рµ РґР»СЏ РѕС†РµРЅРєРё С†РµР»РѕСЃС‚РЅРѕСЃС‚Рё СЃС‚Р°РЅС†РёРё Рё РёРЅР¶РµРЅРµСЂРЅРѕРіРѕ СЂРµРјРѕРЅС‚РЅРѕРіРѕ Р·Р°РІР°Р»Р°.',
  'A high-level estimate of current station integrity compared to the storyteller baseline snapshot.':
    'РћР±С‰Р°СЏ РѕС†РµРЅРєР° С‚РµРєСѓС‰РµР№ С†РµР»РѕСЃС‚РЅРѕСЃС‚Рё СЃС‚Р°РЅС†РёРё РїРѕ СЃСЂР°РІРЅРµРЅРёСЋ СЃ Р±Р°Р·РѕРІС‹Рј СЃРЅРёРјРєРѕРј СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°.',
  'Station breach tiles versus broken floors currently detected by the heavy scan.':
    'РљРѕР»РёС‡РµСЃС‚РІРѕ С‚Р°Р№Р»РѕРІ СЂР°Р·РіРµСЂРјС‹ Рё СЃР»РѕРјР°РЅРЅС‹С… РїРѕР»РѕРІ, РєРѕС‚РѕСЂРѕРµ СЃРµР№С‡Р°СЃ РѕР±РЅР°СЂСѓР¶РµРЅРѕ С‚СЏР¶С‘Р»С‹Рј СЃРєР°РЅРѕРј.',
  'Damaged windows and grilles currently detected by the heavy structural scan.':
    'РџРѕРІСЂРµР¶РґС‘РЅРЅС‹Рµ РѕРєРЅР° Рё СЂРµС€С‘С‚РєРё, РєРѕС‚РѕСЂС‹Рµ СЃРµР№С‡Р°СЃ РѕР±РЅР°СЂСѓР¶РµРЅС‹ С‚СЏР¶С‘Р»С‹Рј СЃС‚СЂСѓРєС‚СѓСЂРЅС‹Рј СЃРєР°РЅРѕРј.',
  'A rolling log of storyteller decisions, scheduling outcomes, forced actions, and major subsystem state changes.':
    'РџСЂРѕРєСЂСѓС‡РёРІР°РµРјС‹Р№ Р¶СѓСЂРЅР°Р» СЂРµС€РµРЅРёР№ СЃС‚РѕСЂРёС‚РµР»Р»РµСЂР°, СЂРµР·СѓР»СЊС‚Р°С‚РѕРІ РїР»Р°РЅРёСЂРѕРІР°РЅРёСЏ, С„РѕСЂСЃ-РґРµР№СЃС‚РІРёР№ Рё РєСЂСѓРїРЅС‹С… РёР·РјРµРЅРµРЅРёР№ СЃРѕСЃС‚РѕСЏРЅРёСЏ РїРѕРґСЃРёСЃС‚РµРјС‹.',
  'Family cooldowns that temporarily block repeated actions from the same storyteller family, to prevent immediate repetition.':
    'РљСѓР»РґР°СѓРЅС‹ СЃРµРјРµР№СЃС‚РІ, РєРѕС‚РѕСЂС‹Рµ РІСЂРµРјРµРЅРЅРѕ Р±Р»РѕРєРёСЂСѓСЋС‚ РїРѕРІС‚РѕСЂРµРЅРёРµ РґРµР№СЃС‚РІРёР№ РёР· РѕРґРЅРѕРіРѕ Рё С‚РѕРіРѕ Р¶Рµ СЃРµРјРµР№СЃС‚РІР°, С‡С‚РѕР±С‹ РЅРµ Р±С‹Р»Рѕ РјРіРЅРѕРІРµРЅРЅС‹С… РїРѕРІС‚РѕСЂРѕРІ.',
};

*/
const translateTooltip = (
  _label: string | React.JSX.Element,
  tooltip: string,
) => {
  return storytellerTranslateTooltip(activeStorytellerLanguage, tooltip);
};

const formatTime = (deciseconds: number, language: PanelLanguage) => {
  return storytellerFormatTime(deciseconds, language);
};

const formatMode = (value: string | undefined, language: PanelLanguage) => {
  return storytellerFormatMode(value, language);
};

const formatPercent = (value?: number) => {
  return storytellerFormatPercent(value);
};

const translateNeedTitle = (language: PanelLanguage, needId: string, fallback: string) => {
  return storytellerTranslateNeedTitle(language, needId, fallback);
};

const translateNeedSummary = (
  language: PanelLanguage,
  needId: string,
  fallback?: string,
) => {
  return storytellerTranslateNeedSummary(language, needId, fallback);
};

const translateDepartmentLabel = (
  language: PanelLanguage,
  department: string,
) => {
  return storytellerTranslateDepartmentLabel(language, department);
};

const translateProfileName = (
  language: PanelLanguage,
  profileId: string,
  fallback: string,
) => storytellerTranslateProfileName(language, profileId, fallback);

const translateFamilyName = (
  language: PanelLanguage,
  family: string,
) => storytellerTranslateFamilyName(language, family);

const translateReason = (language: PanelLanguage, reason?: string) => {
  return storytellerTranslateReason(language, reason);
};

const renderAssoc = (
  data: Record<string, string | number> | undefined,
  language: PanelLanguage,
) => {
  if (!data || !Object.keys(data).length) {
    return <Box color="label">{t(language, 'none')}</Box>;
  }

  return Object.entries(data)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => (
      <Box key={key}>
        {key}: {String(value)}
      </Box>
    ));
};

const tooltipLabel = (label: string, tooltip: string) => (
  <Tooltip content={translateTooltip(label, tooltip)}>
    <span>{label}</span>
  </Tooltip>
);

const Meter = (props: {
  label: string | React.JSX.Element;
  value: number;
  maxValue?: number;
  inverse?: boolean;
}) => {
  const { label, value, maxValue = 100, inverse } = props;
  const clampedValue = Math.max(0, Math.min(maxValue, value));
  const ranges = inverse
    ? {
        good: [0, Math.round(maxValue * 0.33)],
        average: [Math.round(maxValue * 0.33), Math.round(maxValue * 0.66)],
        bad: [Math.round(maxValue * 0.66), Infinity],
      }
    : {
        bad: [0, Math.round(maxValue * 0.33)],
        average: [Math.round(maxValue * 0.33), Math.round(maxValue * 0.66)],
        good: [Math.round(maxValue * 0.66), Infinity],
      };

  return (
    <LabeledList.Item label={label}>
      <ProgressBar value={clampedValue} maxValue={maxValue} ranges={ranges}>
        {Math.round(value)}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const MiniStat = (props: {
  label: string | React.JSX.Element;
  value: string | number;
  color?: string;
  tooltip?: string;
}) => (
  <Box
    backgroundColor="#20262d"
    p={1}
    style={{ border: '1px solid rgba(255,255,255,0.06)' }}
  >
    <Box color="label">
      {props.tooltip ? tooltipLabel(String(props.label), props.tooltip) : props.label}
    </Box>
    <Box bold color={props.color}>
      {props.value}
    </Box>
  </Box>
);

const cardChromeStyle = {
  borderRadius: '6px',
  boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.05)',
};

const NeedCard = (props: { entry: NeedEntry; language: PanelLanguage }) => {
  const { entry, language } = props;
  const color =
    entry.severity >= 75 ? 'bad' : entry.severity >= 45 ? 'average' : 'good';
  return (
    <Box
      key={`${entry.id}_${entry.title}`}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${color})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Box bold>
        {translateNeedTitle(language, entry.id, entry.title)} [{translateDepartmentLabel(language, entry.department)}]
      </Box>
      <Box color="label">
        {t(language, 'severity')} {entry.severity} | {t(language, 'priority')}{' '}
        {entry.priority}
      </Box>
      {!!entry.summary && (
        <Box mt={0.5}>{translateNeedSummary(language, entry.id, entry.summary)}</Box>
      )}
    </Box>
  );
};

const ActionCard = (props: {
  entry: ActionEntry;
  language: PanelLanguage;
  onDiscard?: (id: string) => void;
  onForceNext?: (id: string) => void;
  onForceNow?: (id: string) => void;
}) => {
  const { entry, language, onDiscard, onForceNext, onForceNow } = props;
  const color =
    entry.polarity === 'positive' ? 'good' : entry.polarity === 'negative' ? 'average' : undefined;
  return (
    <Box
      key={entry.id}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${color || 'label'})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>{entry.name}</Box>
          <Box color="label">
            {formatMode(entry.polarity, language)} |{' '}
            {formatMode(entry.context, language)} | {t(language, 'chance')}{' '}
            {formatPercent(entry.chancePercent)} | {t(language, 'cost')} {entry.cost}{' '}
            | {t(language, 'weight')} {entry.weight}
            {!!entry.stage && ` | ${t(language, 'stage')} ${entry.stage}`}
            {entry.activeWindow ? ` | ${t(language, 'active_window')}` : ''}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            color={entry.discarded ? 'bad' : 'transparent'}
            icon={entry.discarded ? 'undo' : 'minus-circle'}
            onClick={() => onDiscard?.(entry.id)}
          >
            {entry.discarded ? t(language, 'return_action') : t(language, 'discard')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="clock"
            onClick={() => onForceNext?.(entry.id)}
          >
            {t(language, 'force_next')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            color="bad"
            icon="bolt"
            confirmContent={t(language, 'force_now_confirm')}
            onClick={() => onForceNow?.(entry.id)}
          >
            {t(language, 'force_now')}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
      {!!entry.needTitle && (
        <Box mt={0.5}>
          {t(language, 'targets_need')}:{' '}
          {translateNeedTitle(language, entry.needId || entry.needTitle, entry.needTitle)}
        </Box>
      )}
      {!!entry.reason && entry.reason !== 'Ready' && entry.reason !== t(language, 'ready') && (
        <Box mt={0.5} color="label">
          {translateReason(language, entry.reason)}
        </Box>
      )}
    </Box>
  );
};

const QueuedAntagCard = (props: {
  entry: QueuedAntagEntry;
  language: PanelLanguage;
  onCancel?: (id: string) => void;
}) => (
  <Box
    key={`${props.entry.id}_${props.entry.name}`}
    backgroundColor="#1f2731"
    p={1}
    mb={1}
    style={{
      ...cardChromeStyle,
      borderLeft: '4px solid var(--color-average)',
      background:
        'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
    }}
  >
    <Stack align="center">
      <Stack.Item grow>
        <Box bold>{props.entry.name}</Box>
        <Box color="label">
          {formatMode(props.entry.context, props.language)}
          {!!props.entry.prefFlag && ` | ${t(props.language, 'pref')} ${props.entry.prefFlag}`}
          {!!props.entry.reservedCost &&
            ` | ${t(props.language, 'refund_threat')} ${props.entry.reservedCost}`}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          color="bad"
          icon="times"
          confirmContent={t(props.language, 'cancel_queue_confirm')}
          onClick={() => props.onCancel?.(props.entry.id)}
        >
          {t(props.language, 'cancel')}
        </Button.Confirm>
      </Stack.Item>
    </Stack>
  </Box>
);

const QueuedActionCard = (props: {
  entry: QueuedActionEntry;
}) => (
  <Box
    key={`${props.entry.label}_${props.entry.id}`}
    backgroundColor="#1f2731"
    p={1}
    mb={1}
    style={{
      ...cardChromeStyle,
      borderLeft: `4px solid var(--color-${props.entry.tone})`,
      background:
        'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
    }}
  >
    <Box bold>{props.entry.name}</Box>
    <Box color="label">{props.entry.label}</Box>
  </Box>
);

const ModifierCard = (props: { entry: ModifierEntry; language: PanelLanguage }) => {
  const { entry, language } = props;
  return (
    <Box
      key={entry.id}
      backgroundColor="#1f2731"
      p={1}
      mb={1}
      style={{
        ...cardChromeStyle,
        borderLeft: `4px solid var(--color-${entry.positive ? 'good' : 'average'})`,
        background:
          'linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01))',
      }}
    >
      <Box bold>{entry.title}</Box>
      <Box color="label">
        {entry.label} | {formatTime(entry.remaining, language)}{' '}
        {t(language, 'left')}
      </Box>
      {!!entry.description && <Box mt={0.5}>{entry.description}</Box>}
    </Box>
  );
};

const DecisionLine = (props: { entry: DecisionEntry; index: number }) => (
  <Box key={`${props.entry.time}_${props.index}`} mb={0.5}>
    <Box as="span" color="label">
      [{props.entry.time}]
    </Box>{' '}
    {props.entry.message}
  </Box>
);

const ModeNotice = (props: { data: Data; language: PanelLanguage }) => {
  const { data, language } = props;
  if (!data.enabled) {
    return (
      <NoticeBox danger>
        {t(language, 'disabled_notice')}
      </NoticeBox>
    );
  }

  if (data.roundMode === 'extended') {
    return (
      <NoticeBox warning>
        {t(language, 'extended_notice')}
      </NoticeBox>
    );
  }

  return (
    <NoticeBox info>
      {t(language, 'dynamic_notice')}
    </NoticeBox>
  );
};

export const StorytellerPanel = () => {
  const { act, data } = useBackend<Data>();
  const [, setLanguageRevision] = useState(0);
  const language = resolveStorytellerLanguageFromFile(data);
  activeStorytellerLanguage = language;
  const [selectedAction, setSelectedAction] = useLocalState(
    'storytellerAction',
    data.allActions[0]?.id || '',
  );
  const [actionSearch, setActionSearch] = useLocalState('storytellerActionSearch', '');
  const [selectedPhase, setSelectedPhase] = useLocalState(
    'storytellerPhase',
    String(data.phase),
  );
  const [selectedProfile, setSelectedProfile] = useLocalState(
    'storytellerProfile',
    data.profileId,
  );
  const [selectedRoundMode, setSelectedRoundMode] = useLocalState(
    'storytellerRoundMode',
    data.roundMode,
  );
  const [listSearch, setListSearch] = useLocalState('storytellerListSearch', '');
  const [tab, setTab] = useLocalState(
    'storytellerTab',
    'overview',
  );

  useEffect(() => {
    if (data.profileId && selectedProfile !== data.profileId) {
      setSelectedProfile(data.profileId);
    }
  }, [data.profileId]);

  useEffect(() => {
    if (data.roundMode && selectedRoundMode !== data.roundMode) {
      setSelectedRoundMode(data.roundMode);
    }
  }, [data.roundMode]);

  useEffect(() => {
    const refreshLanguage = () => setLanguageRevision((value) => value + 1);
    window.addEventListener(getLanguageUpdatedEvent('storyteller'), refreshLanguage);
    window.addEventListener(getInterfaceLanguageUpdatedEvent(), refreshLanguage);
    return () => {
      window.removeEventListener(
        getLanguageUpdatedEvent('storyteller'),
        refreshLanguage,
      );
      window.removeEventListener(
        getInterfaceLanguageUpdatedEvent(),
        refreshLanguage,
      );
    };
  }, []);

  const phaseOptions =
    data.phaseCap > 1
      ? Array.from({ length: data.phaseCap }, (_, index) => ({
          displayText:
            language === 'russian'
              ? `Этап ${index + 1}`
              : `Stage ${index + 1}`,
          value: String(index + 1),
        }))
      : [
          {
            displayText:
              language === 'russian' ? 'Только 1-й этап' : 'Stage 1 only',
            value: '1',
          },
        ];
  const profileOptions = data.profileOptions
    .slice()
    .sort((left, right) => left.name.localeCompare(right.name))
    .map((entry) => ({
      displayText: translateProfileName(language, entry.id, entry.name),
      value: entry.id,
    }));
  const roundModeOptions = data.roundModeOptions.map((entry) => ({
    displayText: formatMode(entry.id, language),
    value: entry.id,
  }));

  const actionOptions = data.allActions
    .filter((entry) => {
      if (!actionSearch.trim()) {
        return true;
      }
      const search = actionSearch.toLowerCase();
      return (
        entry.name.toLowerCase().includes(search) ||
        entry.context.toLowerCase().includes(search) ||
        (entry.polarity || '').toLowerCase().includes(search)
      );
    })
    .slice()
    .sort((left, right) => left.name.localeCompare(right.name))
    .map((entry) => ({
      displayText: `${entry.name} (${formatMode(entry.context, language)}${
        entry.isAntag ? `, ${t(language, 'antagonist_tag')}` : ''
      })`,
      value: entry.id,
    }));

  const filterListedAction = (entry: ActionEntry) => {
    if (!listSearch.trim()) {
      return true;
    }
    const search = listSearch.toLowerCase();
    return (
      entry.name.toLowerCase().includes(search) ||
      entry.context.toLowerCase().includes(search) ||
      (entry.polarity || '').toLowerCase().includes(search) ||
      (entry.family || '').toLowerCase().includes(search) ||
      (entry.needTitle || '').toLowerCase().includes(search) ||
      (entry.reason || '').toLowerCase().includes(search)
    );
  };

  const sortActionEntries = (left: ActionEntry, right: ActionEntry) =>
    (right.chancePercent || 0) - (left.chancePercent || 0) ||
    Number(!!left.discarded) - Number(!!right.discarded) ||
    left.name.localeCompare(right.name);

  const sortedNeeds = data.detectedNeeds
    .slice()
    .sort((left, right) => right.priority - left.priority);
  const positiveActions = data.eligiblePositiveActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const negativeActions = data.eligibleNegativeActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const antagActions = data.eligibleAntagActions
    .slice()
    .filter(filterListedAction)
    .sort(sortActionEntries);
  const queuedPositiveName = data.allActions.find(
    (entry) => entry.id === data.queuedPositiveActionId,
  )?.name;
  const queuedNegativeName = data.allActions.find(
    (entry) => entry.id === data.queuedNegativeActionId,
  )?.name;
  const queuedNextActions: QueuedActionEntry[] = [
    ...(queuedPositiveName
      ? [
          {
            id: data.queuedPositiveActionId || 'queued_positive',
            name: queuedPositiveName,
            label: t(language, 'positive_channel'),
            tone: 'good',
          },
        ]
      : []),
    ...(queuedNegativeName
      ? [
          {
            id: data.queuedNegativeActionId || 'queued_negative',
            name: queuedNegativeName,
            label: t(language, 'negative_channel'),
            tone: 'average',
          },
        ]
      : []),
  ];

  const doDiscard = (actionId: string) => act('discard_action', { action_id: actionId });
  const doForceNext = (actionId: string) => act('force_action_next', { action_id: actionId });
  const doForceNow = (actionId: string) => act('force_action', { action_id: actionId });
  const doCancelQueuedAntag = (queueId: string) =>
    act('cancel_queued_antag', { queue_id: queueId });

  return (
    <Window width={1080} height={800} title={t(language, 'window_title')} theme="admin">
      <Window.Content
        scrollable
        style={{
          background:
            'radial-gradient(circle at top left, rgba(67,119,184,0.14), transparent 26%), radial-gradient(circle at top right, rgba(214,139,53,0.12), transparent 24%), linear-gradient(180deg, rgba(16,20,26,0.98), rgba(12,15,20,0.98)), repeating-linear-gradient(135deg, rgba(255,255,255,0.015) 0 2px, transparent 2px 14px)',
        }}
      >
        <Section
          title={t(language, 'header_title')}
          buttons={
            <>
              <Button disabled={data.paused} onClick={() => act('pause')}>
                {t(language, 'pause')}
              </Button>
              <Button disabled={!data.paused} onClick={() => act('resume')}>
                {t(language, 'resume')}
              </Button>
              <Button onClick={() => act('skip_next_pulse')}>
                {t(language, 'skip_next_pulse')}
              </Button>
            </>
          }
        >
          <Box
            mb={1}
            p={1}
            style={{
              borderRadius: '6px',
              background:
                'linear-gradient(90deg, rgba(53,93,145,0.55), rgba(28,44,67,0.4))',
              border: '1px solid rgba(132,179,255,0.18)',
            }}
          >
            <Box color="#d8e9ff" italic bold>
              {t(language, 'header_subtitle')}
            </Box>
          </Box>
          <ModeNotice data={data} language={language} />
          <Stack mt={1}>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'round_mode')}
                value={formatMode(data.roundMode, language)}
                tooltip="The current storyteller ruleset. Dynamic enables full pacing, while Extended suppresses roundstart and latejoin hostile storyteller picks and keeps only softer pressure in circulation."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'profile')}
                value={translateProfileName(language, data.profileId, data.profileName)}
                tooltip="The active storyteller temperament. Profiles retune cadence delays, budget pressure, escalation pace, and how aggressively the subsystem pushes the round."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'content_stage')}
                value={`${data.phase} / ${data.phaseCap}`}
                tooltip="The current content gate. Higher stages unlock heavier events and antagonists. By default it escalates automatically unless an admin pins it."
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <MiniStat
                label={t(language, 'trigger_window')}
                value={formatMode(data.currentContext, language)}
                tooltip="The scheduling window the storyteller currently treats as active. During the round this is normally Midround; before setup it is Roundstart."
              />
            </Stack.Item>
          </Stack>
        </Section>

        <Tabs fluid mt={1}>
          <Tabs.Tab selected={tab === 'overview'} onClick={() => setTab('overview')}>
            {t(language, 'overview_tab')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 'operations'} onClick={() => setTab('operations')}>
            {t(language, 'operations_tab')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 'snapshot'} onClick={() => setTab('snapshot')}>
            {t(language, 'snapshot_tab')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 'logs'} onClick={() => setTab('logs')}>
            {t(language, 'logs_tab')}
          </Tabs.Tab>
        </Tabs>

        {tab === 'overview' && (
          <Stack mt={1}>
            <Stack.Item grow basis="50%">
              <Section title={t(language, 'round_overview')}>
                <LabeledList>
                  <LabeledList.Item label={tooltipLabel(t(language, 'enabled'), 'Whether the storyteller subsystem is turned on by config at all. If this is off, the panel becomes informational only.')}>
                    {data.enabled ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'full_owner'), 'When enabled, storyteller suppresses the natural autonomous pacing from SSdynamic and SSevents and becomes the round pacing owner.')}>
                    {data.ownsPacing ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'paused'), 'Pausing stops storyteller from scheduling new actions, but does not remove already running modifiers or already queued deliveries.')}>
                    {data.paused ? t(language, 'yes') : t(language, 'no')}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'profile'),
                      'Balanced Drama is the baseline. Patient Custodian leans toward relief and slower escalation, while Aggressive Escalation shortens hostile cadence and unlocks heavier pressure faster.',
                    )}
                  >
                    {translateProfileName(language, data.profileId, data.profileName)}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'round_mode'),
                      'Extended keeps relief and mild pressure. Dynamic enables the full storyteller pacing model, including hostile round pressure.',
                    )}
                  >
                    {formatMode(data.roundMode, language)}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'content_stage'),
                      'This is the active content gate. Higher stages unlock heavier storyteller actions. By default it escalates automatically with round time, population, casualties, and pressure unless an admin overrides it.',
                    )}
                  >
                    {data.phase} / {data.phaseCap}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'population'), 'The active connected player count the storyteller is currently reading for scaling population-sensitive timing and action weights.')}>
                    {data.snapshot.activePopulation}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'alive_crew'), 'Living station crew detected by the storyteller snapshot. This strongly affects staffing checks, aid scaling, and cadence.')}>
                    {data.snapshot.aliveCrew}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'living_antags'), 'Count of living antagonists currently detected on station. This feeds danger scoring and slows or blocks some extra hostile pressure.')}>
                    {data.snapshot.livingAntagCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'station_integrity'), 'A structural health estimate versus the storyteller baseline snapshot. Lower integrity increases danger and pushes engineering-focused relief.')}>
                    {Math.round(data.snapshot.stationIntegrity * 100)}%
                  </LabeledList.Item>
                </LabeledList>
                {data.phaseCap <= 1 && (
                  <NoticeBox mt={1}>
                    {t(language, 'stage_one_notice')}
                  </NoticeBox>
                )}
                {data.phaseCap > 1 && (
                  <NoticeBox mt={1} info={!data.manualPhaseOverride} warning={data.manualPhaseOverride}>
                    {data.manualPhaseOverride
                      ? t(language, 'manual_stage_notice')
                      : t(language, 'auto_stage_notice')}
                  </NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'budgets_pressure')} mt={1}>
                <LabeledList>
                  <Meter
                    label={tooltipLabel(
                      t(language, 'control_score'),
                      'A stability score built from staffing, intact structure, resources, and general station control. Higher control supports more negative pressure.',
                    )}
                    value={data.snapshot.controlScore}
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'danger_score'),
                      'A crisis score built from deaths, explosions, alarms, station damage, active threats, and weak staffing. Higher danger pushes relief and slows extra punishment.',
                    )}
                    value={data.snapshot.dangerScore}
                    inverse
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'threat_budget'),
                      'Negative storyteller actions spend from this pool. It generally grows when the station is stable enough to withstand more pressure.',
                    )}
                    value={data.threatBudget}
                    maxValue={data.budgetCap}
                  />
                  <Meter
                    label={tooltipLabel(
                      t(language, 'aid_budget'),
                      'Positive storyteller actions spend from this pool. It generally grows when the station is struggling and needs intervention.',
                    )}
                    value={data.aidBudget}
                    maxValue={data.budgetCap}
                  />
                </LabeledList>
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="50%">
              <Section title={t(language, 'cadence')}>
                <LabeledList>
                  <LabeledList.Item label={tooltipLabel(t(language, 'positive_lock'), 'A short fatigue lock after a positive action fires. While this is active, the aid channel cannot immediately fire again.')}>
                    {data.positiveFatigueRemaining > 0
                      ? formatTime(data.positiveFatigueRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'positive_window'), 'Time until the positive channel is allowed to roll again. This scales with round state, population, and prior action impact.')}>
                    {data.positiveChannelRemaining > 0
                      ? formatTime(data.positiveChannelRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'negative_lock'), 'A short fatigue lock after a negative action fires. While this is active, the hostile channel cannot immediately fire again.')}>
                    {data.negativeFatigueRemaining > 0
                      ? formatTime(data.negativeFatigueRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'negative_window'), 'Time until the negative channel is allowed to roll again. This is dynamically scaled by population, damage, casualties, and previous impact.')}>
                    {data.negativeChannelRemaining > 0
                      ? formatTime(data.negativeChannelRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'latejoin_lock'), 'Cooldown before another hostile latejoin storyteller antagonist can be assigned.')}>
                    {data.latejoinHostileRemaining > 0
                      ? formatTime(data.latejoinHostileRemaining, language)
                      : t(language, 'ready')}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'latejoin_warmup'), 'The initial start-of-round lock that prevents storyteller latejoin antagonists from firing too early.')}>
                    {data.latejoinRoundstartRemaining > 0
                      ? formatTime(data.latejoinRoundstartRemaining, language)
                      : t(language, 'expired')}
                  </LabeledList.Item>
                </LabeledList>
              </Section>

              <Section title={t(language, 'current_snapshot')} mt={1}>
                <Stack>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'cargo_budget')}
                      value={data.snapshot.cargoBudget}
                      tooltip="Current cargo department budget. Low cargo funds can increase cargo-focused aid or economic support actions."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'active_alarms')}
                      value={data.snapshot.activeAlarms}
                      tooltip="Active alarms detected across the station. This contributes to danger and several department crisis analyzers."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'recent_deaths')}
                      value={data.snapshot.recentDeaths}
                      tooltip="Crew deaths seen within the storyteller's recent tracking window. This strongly increases danger and medical/security response pressure."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'recent_explosions')}
                      value={data.snapshot.recentExplosions}
                      tooltip="Recent on-station explosions seen within the storyteller tracking window. This boosts danger and several engineering-focused reactions."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'kitchen_service_food')}
                      value={`${data.snapshot.kitchenFoodTotal} / ${data.snapshot.serviceFoodTotal}`}
                      tooltip="Approximate food stock the storyteller sees in kitchen and service areas. Low values drive food-shortage relief."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'cargo_miners')}
                      value={`${data.snapshot.cargoStaffCount} / ${data.snapshot.minerCount}`}
                      tooltip="Current staffing snapshot for cargo technicians and miners. This affects cargo relief and several mining/material pressure calculations."
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'breaches_floors')}
                      value={`${data.snapshot.stationBreachTiles} / ${data.snapshot.brokenFloorCount}`}
                      tooltip="Approximate breached space exposure versus broken floor tiles. Both feed structural damage estimates, but breaches are treated as more urgent."
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <MiniStat
                      label={t(language, 'windows_grilles')}
                      value={`${data.snapshot.damagedWindowCount} / ${data.snapshot.damagedGrilleCount}`}
                      tooltip="Damaged windows and grilles detected by the structural scan. These help measure engineering backlog beyond raw integrity."
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'operations' && (
          <Stack mt={1}>
            <Stack.Item grow basis="42%">
              <Section title={t(language, 'controls')}>
                <LabeledList>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'round_mode_override'),
                      'Switch the storyteller between Dynamic and Extended for the current round. Extended suppresses storyteller antagonists and keeps only support plus softer pressure.',
                    )}
                  >
                    <Box ml={1}>
                    <Stack>
                      <Stack.Item grow>
                        <Dropdown
                          options={roundModeOptions}
                          selected={selectedRoundMode}
                          onSelected={(value) => setSelectedRoundMode(String(value))}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={!selectedRoundMode}
                          onClick={() => act('set_round_mode', { round_mode: selectedRoundMode })}
                        >
                          {t(language, 'set_mode')}
                        </Button>
                      </Stack.Item>
                    </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'profile_override'),
                      'Set a specific storyteller temperament manually. Auto returns control to population-weighted random profile selection.',
                    )}
                  >
                    <Box ml={1}>
                    <Stack>
                      <Stack.Item grow>
                        <Dropdown
                          options={profileOptions}
                          selected={selectedProfile}
                          onSelected={(value) => setSelectedProfile(String(value))}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={!selectedProfile}
                          onClick={() => act('set_profile', { profile_id: selectedProfile })}
                        >
                          {t(language, 'set_profile')}
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button onClick={() => act('auto_profile')}>
                          {t(language, 'auto')}
                        </Button>
                      </Stack.Item>
                    </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'set_content_stage'),
                      'Pins the maximum unlocked storyteller stage manually. Auto hands control back to the automatic escalation model.',
                    )}
                  >
                    <Box ml={1}>
                    <Stack>
                      <Stack.Item grow>
                        <Dropdown
                          options={phaseOptions}
                          selected={selectedPhase}
                          onSelected={(value) => setSelectedPhase(String(value))}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={data.phaseCap <= 1}
                          onClick={() => act('set_phase', { phase: selectedPhase })}
                        >
                          {t(language, 'set_stage')}
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={data.phaseCap <= 1}
                          onClick={() => act('auto_phase')}
                        >
                          {t(language, 'auto')}
                        </Button>
                      </Stack.Item>
                    </Stack>
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={tooltipLabel(
                      t(language, 'force_action'),
                      'Search the storyteller catalog and arm or immediately force an action. Force NOW bypasses normal availability checks.',
                    )}
                  >
                    <Box ml={1}>
                    <Stack vertical fill>
                      <Stack.Item>
                        <Input
                          fluid
                          value={actionSearch}
                          placeholder={t(language, 'search_storyteller_actions')}
                          onChange={(value) => setActionSearch(String(value))}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Stack>
                          <Stack.Item grow>
                            <Dropdown
                              options={actionOptions}
                              selected={selectedAction}
                              onSelected={(value) => setSelectedAction(String(value))}
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              disabled={!selectedAction}
                              onClick={() => doForceNext(selectedAction)}
                            >
                              {t(language, 'force_next')}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button.Confirm
                              color="bad"
                              disabled={!selectedAction}
                              confirmContent={t(language, 'force_now_confirm')}
                              onClick={() => doForceNow(selectedAction)}
                            >
                              {t(language, 'force_now')}
                            </Button.Confirm>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
              </Section>

              <Section title={t(language, 'detected_needs')} mt={1}>
                {sortedNeeds.length ? (
                  sortedNeeds.map((entry) => (
                    <NeedCard
                      key={`${entry.id}_${entry.title}`}
                      entry={entry}
                      language={language}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_detected_needs')}</NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'queued_next_actions')} mt={1}>
                {!queuedNextActions.length ? (
                  <NoticeBox>{t(language, 'no_queued_next')}</NoticeBox>
                ) : (
                  queuedNextActions.map((entry) => (
                    <QueuedActionCard
                      key={`${entry.id}_${entry.label}`}
                      entry={entry}
                    />
                  ))
                )}
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'queued_antagonists'),
                  'Antagonists already armed for roundstart, latejoin, or the next storyteller hostile window. Canceling a queued storyteller antag refunds any reserved threat budget.',
                )}
                mt={1}
              >
                {data.queuedAntagActions.length ? (
                  data.queuedAntagActions.map((entry) => (
                    <QueuedAntagCard
                      key={`${entry.id}_${entry.name}`}
                      entry={entry}
                      language={language}
                      onCancel={doCancelQueuedAntag}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_queued_antags')}</NoticeBox>
                )}
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="58%">
              <Section
                title={tooltipLabel(
                  t(language, 'active_modifiers'),
                  'Currently running temporary storyteller buffs and debuffs. These are live round effects with their own timers and department-specific behavior.',
                )}
              >
                {data.activeModifiers.length ? (
                  data.activeModifiers.map((entry) => (
                    <ModifierCard key={entry.id} entry={entry} language={language} />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_active_modifiers')}</NoticeBox>
                )}
              </Section>

              <Section
                title={tooltipLabel(
                  t(language, 'action_search'),
                  'Filters the positive, negative, and antagonist action lists below by name, context, polarity, family, need target, and availability reason.',
                )}
                mt={1}
              >
                <Input
                  fluid
                  value={listSearch}
                  placeholder={t(language, 'search_all_actions')}
                  onChange={(value) => setListSearch(String(value))}
                />
              </Section>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'positive_actions'),
                  'All positive storyteller actions currently in the catalog. Chance reflects the current positive candidate pool; unavailable actions remain visible with their blocking reason.',
                )}
                mt={1}
              >
                {positiveActions.length ? (
                  positiveActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      onDiscard={doDiscard}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_positive_filtered')}</NoticeBox>
                )}
              </Collapsible>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'negative_actions'),
                  'All non-antagonist negative storyteller actions currently in the catalog. Chance reflects the current negative candidate pool; unavailable actions remain visible with their blocking reason.',
                )}
                mt={1}
              >
                {negativeActions.length ? (
                  negativeActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      onDiscard={doDiscard}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_negative_filtered')}</NoticeBox>
                )}
              </Collapsible>

              <Collapsible
                title={tooltipLabel(
                  t(language, 'antagonist_actions'),
                  'All storyteller antagonist actions across roundstart, midround, and latejoin contexts. Discard marks an antag as disabled for the rest of the round without removing it from the list.',
                )}
                mt={1}
              >
                {antagActions.length ? (
                  antagActions.map((entry) => (
                    <ActionCard
                      key={entry.id}
                      entry={entry}
                      language={language}
                      onDiscard={doDiscard}
                      onForceNext={doForceNext}
                      onForceNow={doForceNow}
                    />
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_antag_filtered')}</NoticeBox>
                )}
              </Collapsible>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'snapshot' && (
          <Stack mt={1}>
            <Stack.Item grow basis="50%">
              <Section title={tooltipLabel(t(language, 'crew_staffing'), 'The staffing half of the storyteller snapshot. These values feed job coverage checks, department aid routing, and several event weight modifiers.')}>
                <LabeledList>
                  <LabeledList.Item label={tooltipLabel(t(language, 'key_jobs_filled'), 'How many critical command and department anchor jobs are currently occupied out of the storyteller key-job list.')}>
                    {data.snapshot.keyJobsFilledCount} / {data.snapshot.totalKeyJobs}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'cooks_service'), 'Service staffing focus numbers used for food, janitorial, and hospitality-related needs.')}>
                    {data.snapshot.cookCount} / {data.snapshot.serviceStaffCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'engineers_atmos'), 'Engineering and atmospherics staffing counts used for repair, power, and environmental pressure calculations.')}>
                    {data.snapshot.engineerCount} / {data.snapshot.atmosCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'cargo_miners'), 'Cargo office and mining staffing counts used for ore, logistics, and budget relief calculations.')}>
                    {data.snapshot.cargoStaffCount} / {data.snapshot.minerCount}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(t(language, 'key_jobs'), 'A per-role occupancy breakdown for storyteller-critical jobs such as command, engineering, medical, and other round anchors.')}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.keyJobsOccupied, language)}
                </Collapsible>
                <Collapsible title={tooltipLabel(t(language, 'department_staffing'), 'A department-level headcount breakdown the storyteller uses for staffing-aware relief and pressure.')} mt={1}>
                  {renderAssoc(data.snapshot.departmentStaffing, language)}
                </Collapsible>
              </Section>

              <Section title={tooltipLabel(t(language, 'threats_events'), 'The danger-facing half of the storyteller snapshot. These values show live hostile presence and currently running event pressure.')} mt={1}>
                <LabeledList>
                  <LabeledList.Item label={tooltipLabel(t(language, 'living_antags'), 'Total living antagonists currently detected by the storyteller snapshot.')}>
                    {data.snapshot.livingAntagCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'active_round_events'), 'The number of currently active round-event instances the storyteller can see right now.')}>
                    {data.snapshot.activeRoundEventCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'active_alarms'), 'The number of active alarms currently contributing to the danger picture.')}>
                    {data.snapshot.activeAlarms}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(t(language, 'living_antag_types'), 'A live type breakdown of antagonists the storyteller sees in the current round snapshot.')}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.livingAntagTypes, language)}
                </Collapsible>
                <Collapsible
                  title={tooltipLabel(
                    t(language, 'active_event_breakdown'),
                    'A live breakdown of currently running round events grouped by event type. This is not a history log; entries disappear once those events end.',
                  )}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.activeRoundEvents, language)}
                </Collapsible>
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="50%">
              <Section title={tooltipLabel(t(language, 'resources_economy'), 'The supply side of the storyteller snapshot: money, food, ore-silo stock, loose materials, and recent material intake.')}>
                <LabeledList>
                  <LabeledList.Item label={tooltipLabel(t(language, 'cargo_budget'), 'Current cargo budget available to the station economy.')}>
                    {data.snapshot.cargoBudget}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'kitchen_service_food'), 'Food stock the storyteller counts in kitchen and service spaces.')}>
                    {data.snapshot.kitchenFoodTotal} / {data.snapshot.serviceFoodTotal}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'silo_materials'), 'Total raw materials currently accessible in the ore silo.')}>
                    {data.snapshot.oreSiloMaterialTotal}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'loose_materials'), 'Total loose material stacks found around the station during the heavy scan.')}>
                    {data.snapshot.looseMaterialTotal}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'recent_material_gain'), 'Change in total known material stock since the previous heavy snapshot. Useful for detecting whether mining is keeping up.')}>
                    {data.snapshot.materialGainRecent}
                  </LabeledList.Item>
                </LabeledList>
                <Collapsible
                  title={tooltipLabel(t(language, 'department_money'), 'Per-department account balances available to the storyteller for budget-aware actions and needs.')}
                  mt={1}
                >
                  {renderAssoc(data.snapshot.departmentMoney, language)}
                </Collapsible>
                <Collapsible title={tooltipLabel(t(language, 'silo_breakdown'), 'Raw material stock currently detected in the ore silo, grouped by material type.')} mt={1}>
                  {renderAssoc(data.snapshot.oreSiloMaterials, language)}
                </Collapsible>
                <Collapsible title={tooltipLabel(t(language, 'loose_breakdown'), 'Loose station-side material stacks grouped by material type.')} mt={1}>
                  {renderAssoc(data.snapshot.looseMaterials, language)}
                </Collapsible>
              </Section>

              <Section title={tooltipLabel(t(language, 'structural_condition'), 'Structural health metrics used to estimate station integrity and the engineering repair backlog.')} mt={1}>
                <LabeledList>
                  <Meter
                    label={tooltipLabel(
                      t(language, 'station_integrity'),
                      'A high-level estimate of current station integrity compared to the storyteller baseline snapshot.',
                    )}
                    value={Math.round(data.snapshot.stationIntegrity * 100)}
                  />
                  <LabeledList.Item label={tooltipLabel(t(language, 'breaches_floors'), 'Station breach tiles versus broken floors currently detected by the heavy scan.')}>
                    {data.snapshot.stationBreachTiles} / {data.snapshot.brokenFloorCount}
                  </LabeledList.Item>
                  <LabeledList.Item label={tooltipLabel(t(language, 'windows_grilles'), 'Damaged windows and grilles currently detected by the heavy structural scan.')}>
                    {data.snapshot.damagedWindowCount} / {data.snapshot.damagedGrilleCount}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        )}

        {tab === 'logs' && (
          <Stack mt={1}>
            <Stack.Item grow basis="60%">
              <Section title={tooltipLabel(t(language, 'recent_decisions'), 'A rolling log of storyteller decisions, scheduling outcomes, forced actions, and major subsystem state changes.')}>
                {data.decisionHistory.length ? (
                  data.decisionHistory
                    .slice()
                    .reverse()
                    .map((entry, index) => (
                      <DecisionLine key={`${entry.time}_${index}`} entry={entry} index={index} />
                    ))
                ) : (
                  <NoticeBox>{t(language, 'no_decisions')}</NoticeBox>
                )}
              </Section>
            </Stack.Item>

            <Stack.Item grow basis="40%">
              <Section title={tooltipLabel(t(language, 'active_cooldowns'), 'Family cooldowns that temporarily block repeated actions from the same storyteller family, to prevent immediate repetition.')}>
                {data.familyCooldowns.length ? (
                  data.familyCooldowns.map((entry) => (
                    <Box key={entry.family} mb={0.5}>
                      {translateFamilyName(language, entry.family)}:{' '}
                      {formatTime(entry.remaining, language)}
                    </Box>
                  ))
                ) : (
                  <NoticeBox>{t(language, 'no_cooldowns')}</NoticeBox>
                )}
              </Section>

              <Section title={t(language, 'advanced_notes')} mt={1}>
                <Box mb={1}>
                  {t(language, 'advanced_notes_body')}
                </Box>
                <Box color="label">
                  {t(language, 'advanced_notes_footer')}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};


