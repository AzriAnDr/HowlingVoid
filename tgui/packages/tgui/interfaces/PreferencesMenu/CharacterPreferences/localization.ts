import {
  getInterfaceLanguageUpdatedEvent,
  getLanguageUpdatedEvent,
  getRememberedInterfaceLanguage,
  getRememberedUIElementLanguage,
  rememberInterfaceLanguage,
  rememberUIElementLanguage,
  type UIElementType,
} from 'common/panelLocalization';
import { useCallback, useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { uiEn, uiRu } from '../../locales';
import { features } from '../preferences/features';
import type { PreferencesMenuData } from '../types';

export type InterfaceLanguage = 'english' | 'russian';

const EN_UI_BY_KEY = uiEn as Record<string, string>;
const RU_UI_BY_KEY = uiRu as Record<string, string>;
const UI_BY_LANGUAGE: Record<InterfaceLanguage, Record<string, string>> = {
  english: EN_UI_BY_KEY,
  russian: RU_UI_BY_KEY,
};

const GENDER_TEXT_KEY_BY_ID: Record<string, string> = {
  male: 'ui.character.gender_male_pronouns',
  female: 'ui.character.gender_female_pronouns',
  plural: 'ui.character.gender_plural_pronouns',
  neuter: 'ui.character.gender_neuter_pronouns',
};

// Feature IDs can differ from the normalized label ID.
// Keep explicit aliases for Character tab mismatches so ID lookup stays primary.
const CHARACTER_FEATURE_ID_ALIASES: Record<string, string> = {
  antag_opt_in_status_pref: 'round_removal',
  tts_voice: 'voice',
  tts_voice_pitch: 'voice_pitch_adjustment',
  fallback_to_blooper: 'vocal_bark_fallback',
  blooper_speech: 'vocal_bark',
  blooper_speech_speed: 'vocal_bark_speed',
  blooper_speech_pitch: 'vocal_bark_pitch',
  blooper_pitch_range: 'vocal_bark_range',
  allow_genitals_toggle: 'allow_genital_parts',
  allow_emissives_toggle: 'allow_emissives',
  allow_mismatched_parts_toggle: 'allow_mismatched_parts',
  feature_anus: 'anus_choice',
  feature_belly: 'belly_choice',
  feature_breasts: 'breast_choice',
  feature_butt: 'butt_choice',
  belly_color: 'belly_color',
  belly_emissive: 'belly_emissives',
  belly_size: 'belly_size',
  belly_skin_color: 'belly_use_skin_color',
  belly_skin_tone: 'belly_use_skin_tone',
  breasts_color: 'breast_color',
  breasts_lactation_toggle: 'breast_lactation',
  breasts_size: 'breast_size',
  breasts_skin_color: 'breasts_use_skin_color',
  breasts_skin_tone: 'breasts_use_skin_tone',
  butt_color: 'butt_color',
  butt_emissive: 'butt_emissives',
  butt_size: 'butt_size',
  butt_skin_color: 'butt_use_skin_color',
  butt_skin_tone: 'butt_use_skin_tone',
  caps_toggle: 'cap',
  feature_caps: 'cap_selection',
  caps_color: 'cap_colors',
  caps_emissive: 'caps_emissives',
  ears_toggle: 'ears',
  feature_ears: 'ears_selection',
  ears_color: 'ears_colors',
  ears_emissive: 'ears_emissives',
  feature_tail: 'tail_selection',
  tail_color: 'tail_colors',
  tail_emissive: 'tail_emissives',
  feature_snout: 'snout_selection',
  snout_color: 'snout_colors',
  snout_emissive: 'snout_emissives',
  feature_horns: 'horns_selection',
  horns_color: 'horns_colors',
  horns_emissive: 'horns_emissives',
  feature_frills: 'frills_selection',
  frills_color: 'frills_colors',
  frills_emissive: 'frills_emissives',
  feature_spines: 'spines_selection',
  spines_color: 'spines_colors',
  spines_emissive: 'spines_emissives',
  feature_wings: 'wings_selection',
  wings_color: 'wings_colors',
  wings_emissive: 'wings_emissives',
  pda_ringer: 'pda_ringtone',
  character_ad: 'character_advert',
  attraction: 'character_attraction',
  display_gender: 'character_gender',
  custom_species: 'custom_species_name',
  silicon_flavor_text: 'flavor_text_silicon',
  silicon_flavor_text_nsfw: 'flavor_text_silicon_nsfw',
  general_record: 'records_general',
  security_record: 'records_security',
  medical_record: 'records_medical',
  exploitable_info: 'records_exploitable',
  background_info: 'records_background',
  feature_penis: 'penis_choice',
  feature_testicles: 'testicles_choice',
  feature_vagina: 'vagina_choice',
  feature_womb: 'womb_choice',
  penis_skin_color: 'penis_uses_skin_color',
  penis_skin_tone: 'penis_uses_skin_tone',
  testicles_skin_color: 'testicles_uses_skin_color',
  testicles_skin_tone: 'testicles_uses_skin_tone',
  vagina_skin_color: 'vagina_uses_skin_color',
  vagina_skin_tone: 'vagina_uses_skin_tone',
  breasts_emissive: 'breast_emissives',
  feature_head_acc: 'head_accessory_selection',
  head_acc_toggle: 'head_accessory',
  head_acc_color: 'head_accessory_colors',
  head_acc_emissive: 'head_accessory_emissives',
  feature_neck_acc: 'neck_accessory_selection',
  neck_acc_toggle: 'neck_accessory',
  neck_acc_color: 'neck_accessory_colors',
  neck_acc_emissive: 'neck_accessory_emissives',
  feature_moth_antennae: 'moth_antenna_selection',
  moth_antennae_toggle: 'moth_antenna',
  moth_antennae_color: 'moth_antenna_colors',
  moth_antennae_emissive: 'moth_antenna_emissives',
  feature_moth_markings: 'moth_markings_selection',
  moth_markings_toggle: 'moth_markings',
  moth_markings_color: 'moth_markings_colors',
  moth_markings_emissive: 'moth_markings_emissives',
  feature_ipc_antenna: 'synth_antenna_selection',
  ipc_antenna_toggle: 'synth_antenna',
  ipc_antenna_color: 'synth_antenna_colors',
  ipc_antenna_emissive: 'synth_antenna_emissives',
  feature_ipc_screen: 'ipc_screen_selection',
  ipc_screen_color: 'ipc_screen_greyscale_color',
  ipc_screen_emissive: 'ipc_screen_emissive',
  feature_ipc_chassis: 'synth_chassis_selection',
  ipc_chassis_color: 'synth_chassis_colors',
  feature_ipc_head: 'synth_head_selection',
  ipc_head_color: 'synth_head_colors',
  feature_hair_opacity_toggle: 'hair_opacity_override',
  feature_skrell_hair: 'skrell_hair_selection',
  feature_xenohead: 'xeno_head_selection',
  xenohead_toggle: 'xeno_head',
  xenohead_color: 'xeno_head_colors',
  xenohead_emissive: 'xeno_head_emissives',
  feature_leg_type: 'leg_type',
  feature_mcolor2: 'mutant_color_2',
  feature_mcolor3: 'mutant_color_3',
  allow_mismatched_hair_color_toggle: 'allow_mismatched_hair_color',
  body_markings_toggle: 'body_markings',
  feature_body_markings: 'body_markings_selection',
  body_markings_color: 'body_markings_colors',
  body_markings_emissive: 'body_markings_emissives',
  heterochromia_toggle: 'heterochromia',
  feature_heterochromia: 'heterochromia_selection',
  heterochromia_color: 'heterochromia_colors',
  heterochromia_emissive: 'heterochromia_emissives',
  naga_sole: 'taur_naga_disable_hardened_soles',
  nv_color: 'night_vision_color',
  pod_hair_color: 'floral_hair_color',
  vox_bodycolor: 'vox_bodycolor',
  voice_actor: 'voice_actor',
  voice_actor_color: 'voice_actor_color',
  ic_chat_color: 'chat_message_color',
  blindfold_color: 'blindfold_color',
  paint_color: 'paint_color',
  socks_color: 'socks_color',
  undershirt_color: 'undershirt_color',
  jumpsuit_style: 'jumpsuit',
  hairstyle_name: 'hairstyle',
  facial_style_name: 'facial_hairstyle',
  facial_hair: 'facial_hairstyle',
  facial_hairstyle: 'facial_hairstyle',
};

const DATA_LABEL_ID_ALIASES: Record<string, string> = {
  a_form_of_hybrid_encoded_language_employed_by_the_biomechanical_vox_species_characterized_by_sounding_extremely_annoying_and_irritating_to_those_who_don_t_recognize_it_it_usually_requires_an_implant_to_be_spoken_in_its_entirety:
    'language_desc_vox_hybrid_encoded',
  a_melodic_and_complex_language_spoken_by_slimes_some_of_the_notes_are_inaudible_to_humans:
    'language_desc_slime_melodic',
  a_popular_non_human_language_that_finds_extensive_use_by_various_types_of_anthropomorphic_invertebrates_it_consists_of_complex_flutters_chittering_antenna_movements_and_sparse_guttural_syllables:
    'language_desc_invertebrate_flutters',
  a_primarily_nonverbal_language_comprised_of_body_movements_gesticulation_and_sign_language_with_only_intermittent_warbles_other_vocalizations_it_s_almost_completely_incomprehensible_without_its_somatic_components:
    'language_desc_nonverbal_somatic',
  a_rough_informal_tongue_used_as_a_last_resort_when_attempts_to_establish_dialogue_in_more_proper_languages_fail_and_no_automatic_translators_are_available_it_relies_heavily_on_tone_body_language_signing_and_a_multitude_of_creole_loanwords_while_its_use_has_fallen_severely_over_the_years_it_s_still_practiced_by_a_quantity_of_frontier_crews_and_favored_by_the_free_trade_union:
    'language_desc_frontier_trade_pidgin',
  a_somewhat_simple_language_consisting_of_heavily_articulate_barks_growls_yapping_and_combined_movements_of_the_tail_and_ears_it_s_natively_spoken_by_the_vulpkanin_although_certain_groups_of_gene_modders_have_adopted_it_as_a_secondary_form_of_communication_its_parlance_has_been_loosely_compared_to_the_germanic_language_group:
    'language_desc_vulpkanin_barks',
  also_popularly_known_as_konjin_this_language_group_formally_regarded_as_orbital_sino_tibetan_is_a_result_of_a_genetic_relationship_between_chinese_tibetan_burmese_and_other_human_languages_of_similar_characteristics_that_was_first_proposed_in_the_early_19th_century_and_is_extremely_popular_even_in_the_space_age_originating_from_asia_this_group_of_tongues_is_the_second_most_spoken_by_human_and_human_derived_populations_since_the_birth_of_sol_common_and_was_a_primary_contender_to_be_the_sol_federation_s_official_language_many_loanwords_idioms_and_cultural_relics_of_japanese_ryukyuan_korean_and_other_societies_have_managed_to_persist_within_it_especially_in_the_daily_lives_of_speakers_coming_from_martian_cities:
    'language_desc_orbital_sino_tibetan',
  an_elaborate_mix_of_various_slavic_languages_with_similar_properties_that_has_long_since_become_the_official_language_of_the_hc_with_a_steady_amount_of_relevance_in_solfed_colonies_with_slavic_descendants_and_various_types_of_trading_posts_and_spaceports_across_human_space_it_even_managed_to_find_a_niche_in_communication_with_other_species:
    'language_desc_hc_slavic_mix',
  an_evolved_streamlined_form_of_semitic_tongues_that_come_from_the_middle_east_primarily_arabic_despite_its_ancient_origins_it_s_still_spoken_by_many_cultures_and_colonies_that_came_from_the_arab_league_and_general_middle_eastern_regions:
    'language_desc_streamlined_semitic',
  the_very_structurally_loose_creole_tongue_of_the_teshari_host_to_hundreds_of_dialects_almost_different_enough_to_resemble_their_own_languages_originally_developed_on_sirisai_schechi_has_made_its_way_across_the_teshari_diaspora_as_a_commonly_agreed_upon_way_for_entirely_different_packs_to_communicate:
    'language_desc_teshari_schechi',
  popularly_known_as_skrellian_by_foreigners_this_newly_discovered_language_that_the_skrell_employ_follows_no_traditional_speech_patterns_it_relies_on_various_differently_pitched_warbles_and_low_frequency_sound_to_construct_different_sentences_and_is_nearly_inaudible_to_non_skrell_and_anyone_lacking_an_appropriate_implant:
    'language_desc_skrell_warbles',
  overly_complicated_and_with_a_turbulent_history_this_tongue_comprised_of_short_form_speech_mixed_with_growls_and_meows_is_native_to_the_tajara_due_to_the_size_of_their_empire_countless_dialects_and_different_idioms_exist_making_a_simple_uniform_way_to_teach_this_language_almost_impossible_after_first_contact_humans_describe_this_tongue_as_sounding_somewhat_similar_to_old_scandinavian_languages_in_some_form_or_another_it_s_rarely_seen_spoken_by_those_not_native_to_taj_though_certain_genemodder_groups_have_picked_up_a_form_of_the_tongue:
    'language_desc_tajara_shortform',
  translating_to_the_song_of_the_king_this_language_was_custom_made_in_agurkhral_to_allow_those_with_little_education_including_aliens_to_better_integrate_into_azulean_society_it_s_easy_to_learn_as_a_result_and_is_characterised_by_hard_consonants_followed_by_soft_vowel_strings_an_underwater_element_exists_featuring_great_emphasis_on_close_physical_proximity_variations_in_pitch_high_frequency_sounds_and_clicking_this_part_may_require_genemods_for_non_azulean_speakers:
    'language_desc_azulean_song_of_the_king',
  and_when_contact_was_established_the_admiral_waved_at_the_screen_and_said_mi_parolas_la_lingvon_de_la_homines_i_speak_the_language_of_mankind_a_simplified_mix_of_esperanto_and_modern_latin_and_the_only_recognized_official_language_of_the_sol_federation_this_peculiar_constructed_language_became_popular_during_solfed_s_earliest_days_and_was_almost_entirely_overtaken_by_other_popular_tongues_it_became_widespread_through_heavy_handed_political_maneuvering_with_the_help_of_corporate_bureaucrats_and_other_undesirables_nowadays_it_s_a_near_universal_tongue_and_a_must_know_for_any_sentient_being_that_plans_to_leap_forward_into_space:
    'language_desc_sol_common_esperanto_latin',
  spoken_colloquially_by_the_mothfolk_of_va_lumla_the_early_iteration_of_mothic_emerged_when_fueljacks_relied_on_their_receptors_for_simple_one_worded_pheromones_to_communicate_and_navigate_the_often_fatal_maintenance_tunnels_sprawled_throughout_the_fleet_the_moths_developed_gesticulation_through_antennas_and_wings_to_convey_deeper_intent_with_mandibles_providing_emotional_context_through_clicks_and_trills_after_first_contact_human_speakers_managed_to_achieve_a_similar_effect_from_clicking_their_tongue_to_roof_and_steer_the_tone_with_the_width_of_their_mouth_while_using_their_hands_in_place_of_antennas_it_is_informally_spoken_deploying_many_slangs_and_shorthands_from_common_has_phonetic_resemblance_to_italian:
    'language_desc_mothic_colloquial',
  plutonian_franco_castillian_is_a_constructed_romance_language_that_was_developed_early_on_in_the_sol_federation_s_colonization_history_out_of_necessity_for_communication_between_its_first_plutonian_colonists_it_heavily_borrows_from_spanish_and_french_with_minor_influence_from_other_tongues_the_likes_of_italian_and_portuguese_despite_coming_off_as_elegant_it_carries_a_heavy_amount_of_slang_and_idioms_correlated_to_certain_criminal_groups_today_it_stands_heavily_ingrained_in_the_planet_s_culture_and_almost_every_citizen_will_speak_at_least_some_of_it_on_top_of_sol:
    'language_desc_plutonian_franco_castillian',
  where_shadekin_have_a_language_rooted_in_empathy_there_are_still_subtle_tones_and_syllables_that_are_as_delicate_as_the_emotions_that_shadekin_normally_communicate_with:
    'language_desc_shadekin_empathic_tones',
  shadekin_seem_to_always_know_what_the_others_are_thinking_this_is_probably_why:
    'language_desc_shadekin_shared_thought',
  the_official_language_of_the_spinward_stellar_coalition_as_inherited_from_the_third_soviet_union:
    'language_desc_spinward_official',
};

function toDataId(value: string): string {
  const normalized = (value ?? '')
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[:]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');

  return normalized || 'unknown';
}

function toCasePreservingDataId(value: string): string {
  const normalized = (value ?? '')
    .toString()
    .trim()
    .replace(/[:]/g, '')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');

  return normalized || 'unknown';
}

function extractPanelLanguageValue(
  raw: unknown,
  element: UIElementType,
): InterfaceLanguage | null {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const detected = extractLanguage((raw as Record<string, unknown>)[element]);
  if (detected) {
    rememberUIElementLanguage(element, detected);
  }

  return detected;
}

function inferUIElementType(data: any): UIElementType | null {
  const interfaceName = `${data?.config?.interface?.name || data?.interface?.name || ''}`;

  if (interfaceName === 'InteractionPanel') {
    return 'interaction';
  }

  if (interfaceName === 'Techweb' || interfaceName === 'NtosTechweb') {
    return 'rnd';
  }

  if (interfaceName.startsWith('AntagInfo')) {
    return 'antag_info';
  }

  if (interfaceName === 'PreferencesMenu' || data?.character_preferences) {
    if (data?.window === 1 || data?.window === 2) {
      return 'game_preferences';
    }

    return 'preferences';
  }

  return null;
}

function getPanelLanguage(
  data: any,
  uiElement: UIElementType,
): InterfaceLanguage | null {
  const candidates = [
    data?.panel_languages,
    data?.config?.client?.panel_languages,
    data?.client?.panel_languages,
    data?.preferences?.panel_languages,
  ];

  for (const candidate of candidates) {
    const detected = extractPanelLanguageValue(candidate, uiElement);
    if (detected) {
      return detected;
    }
  }

  return getRememberedUIElementLanguage(uiElement);
}

const DATA_ID_PREFIXES = [
  'job',
  'language',
  'species',
  'quirk',
  'personality',
  'antag',
  'limb',
  'organ',
  'loadout_tab',
  'loadout_category_info',
  'loadout_item',
  'loadout_group',
  'experience_type',
  'preview_option',
  'name_type',
  'background_state',
  'robotic_style',
];

function deriveDataIdCandidates(id: string): string[] {
  const normalized = toDataId(id);
  const casePreserving = toCasePreservingDataId(id);
  const candidates = new Set<string>([normalized]);

  const addWithAlias = (value: string) => {
    if (!value) {
      return;
    }
    candidates.add(value);
    const alias = DATA_LABEL_ID_ALIASES[value];
    if (alias) {
      candidates.add(alias);
    }
  };

  addWithAlias(normalized);
  if (casePreserving !== normalized) {
    addWithAlias(casePreserving);
  }

  const addPatternAlias = (prefix: string, replacement: string) => {
    if (normalized.startsWith(prefix)) {
      addWithAlias(`${replacement}${normalized.slice(prefix.length)}`);
    }
  };

  // Job titles can diverge from their historical datum ids.
  // Keep these bridges so renamed jobs still resolve old translation keys.
  addPatternAlias('job_bridge_officer_', 'job_bridge_assistant_');
  addPatternAlias('job_service_guard_', 'job_bouncer_');
  addPatternAlias('job_medical_doctor_alt_title_', 'job_doctor_alt_title_');

  const stripPrefix = (value: string) => {
    for (const prefix of DATA_ID_PREFIXES) {
      const token = `${prefix}_`;
      if (value.startsWith(token)) {
        return value.slice(token.length);
      }
    }
    return value;
  };

  const withoutPrefix = stripPrefix(normalized);
  if (withoutPrefix && withoutPrefix !== normalized) {
    addWithAlias(withoutPrefix);
  }

  if (normalized.endsWith('_name')) {
    const nameBase = normalized.slice(0, -'_name'.length);
    addWithAlias(nameBase);
    addWithAlias(stripPrefix(nameBase));
  } else if (normalized.endsWith('_choice')) {
    const choiceBase = normalized.slice(0, -'_choice'.length);
    addWithAlias(choiceBase);
    addWithAlias(stripPrefix(choiceBase));
  } else if (normalized.endsWith('_option')) {
    const optionBase = normalized.slice(0, -'_option'.length);
    addWithAlias(optionBase);
    addWithAlias(stripPrefix(optionBase));
  } else if (normalized.endsWith('_preference')) {
    const preferenceBase = normalized.slice(0, -'_preference'.length);
    addWithAlias(preferenceBase);
    addWithAlias(stripPrefix(preferenceBase));
  }

  return [...candidates];
}

function deriveCharacterFeatureIdCandidates(featureId: string): string[] {
  const normalizedId = toDataId(featureId);
  const candidates: string[] = [];
  const pushUnique = (value: string) => {
    if (value && !candidates.includes(value)) {
      candidates.push(value);
    }
  };

  pushUnique(normalizedId);

  const aliased = CHARACTER_FEATURE_ID_ALIASES[normalizedId];
  if (aliased) {
    pushUnique(aliased);
  }

  if (normalizedId.startsWith('feature_')) {
    const base = normalizedId.slice('feature_'.length);
    if (base) {
      pushUnique(`${base}_selection`);
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_toggle')) {
    const base = normalizedId.slice(0, -'_toggle'.length);
    if (base) {
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_emissive')) {
    const base = normalizedId.slice(0, -'_emissive'.length);
    if (base) {
      pushUnique(`${base}_emissives`);
      pushUnique(base);
    }
  }

  if (normalizedId.endsWith('_color')) {
    const base = normalizedId.slice(0, -'_color'.length);
    if (base) {
      pushUnique(`${base}_colors`);
      pushUnique(base);
    }
  }

  // Use the static feature registry as an id bridge for downstream keys:
  // featureId -> feature.name -> normalized id.
  const registryFeature = features[featureId];
  if (registryFeature?.name) {
    pushUnique(toDataId(registryFeature.name));
  }

  return candidates;
}

function resolveCharacterFeatureKey(
  featureId: string,
  suffix: 'name' | 'description',
): string | null {
  let fallbackKey: string | null = null;
  for (const candidate of deriveCharacterFeatureIdCandidates(featureId)) {
    const key = `ui.character.feature.${candidate}.${suffix}`;
    if (!fallbackKey) {
      fallbackKey = key;
    }
    if (key in EN_UI_BY_KEY || key in RU_UI_BY_KEY) {
      return key;
    }
  }

  return fallbackKey;
}

function deriveGameFeatureIdCandidates(featureId: string): string[] {
  const normalizedId = toDataId(featureId);
  const candidates: string[] = [];
  const pushUnique = (value: string) => {
    if (value && !candidates.includes(value)) {
      candidates.push(value);
    }
  };

  pushUnique(normalizedId);

  const registryFeature = features[featureId];
  if (registryFeature?.name) {
    pushUnique(toDataId(registryFeature.name));
  }

  return candidates;
}

function resolveGameFeatureKey(
  featureId: string,
  suffix: 'name' | 'description',
): string {
  let fallback = `ui.game.feature.${toDataId(featureId)}.${suffix}`;
  for (const candidate of deriveGameFeatureIdCandidates(featureId)) {
    const key = `ui.game.feature.${candidate}.${suffix}`;
    fallback = key;
    if (key in EN_UI_BY_KEY || key in RU_UI_BY_KEY) {
      return key;
    }
  }
  return fallback;
}

function translateUi(
  language: InterfaceLanguage,
  key: string,
  fallback?: string,
): string {
  const textKey = (key ?? '').toString();

  return (
    UI_BY_LANGUAGE[language][textKey] ??
    EN_UI_BY_KEY[textKey] ??
    fallback ??
    textKey
  );
}

function normalizeLanguage(raw: unknown): InterfaceLanguage | null {
  if (typeof raw !== 'string') {
    return null;
  }

  const value = raw.trim().toLowerCase();
  if (value === 'russian' || value === 'ru' || value.includes('russ')) {
    return 'russian';
  }
  if (value === 'english' || value === 'en' || value.includes('engl')) {
    return 'english';
  }

  return null;
}

function extractLanguage(raw: unknown, depth = 0): InterfaceLanguage | null {
  if (depth > 3 || raw == null) {
    return null;
  }

  const direct = normalizeLanguage(raw);
  if (direct) {
    return direct;
  }

  if (typeof raw === 'object') {
    const obj = raw as Record<string, unknown>;

    const commonValue = normalizeLanguage(obj.value);
    if (commonValue) {
      return commonValue;
    }

    // Some choiced payloads can carry selected value under alternative keys.
    for (const selectedKey of [
      'selected_value',
      'selectedValue',
      'selected_key',
      'selectedKey',
      'id',
      'key',
      'name',
    ]) {
      const selectedValue = normalizeLanguage(obj[selectedKey]);
      if (selectedValue) {
        return selectedValue;
      }
    }

    // Handle payloads where selected index points into choices list.
    if (Array.isArray(obj.choices) && typeof obj.selected === 'number') {
      const selectedByIndex = normalizeLanguage(obj.choices[obj.selected]);
      if (selectedByIndex) {
        return selectedByIndex;
      }
    }

    for (const key of [
      'interface_language',
      'language',
      'selected',
      'current',
    ]) {
      const nested = extractLanguage(obj[key], depth + 1);
      if (nested) {
        return nested;
      }
    }
  }

  return null;
}

export function getCharacterPreferencesLanguage(
  data: any,
  uiElement?: UIElementType,
): InterfaceLanguage {
  const localizedElement = uiElement ?? inferUIElementType(data);
  if (localizedElement) {
    const panelLanguage = getPanelLanguage(data, localizedElement);
    if (panelLanguage) {
      return panelLanguage;
    }
  }

  // Prefer top-level interface language because it's player-wide and authoritative.
  const candidates = [
    data?.interface_language,
    data?.config?.interface_language,
    data?.game_preferences?.interface_language,
    data?.preferences?.interface_language,
    data?.client?.interface_language,
    data?.config?.client?.interface_language,
    data?.character_preferences?.interface_language,
    data?.character_preferences?.game_preferences?.interface_language,
    data?.character_preferences?.non_contextual?.interface_language,
  ];

  for (const raw of candidates) {
    const detected = extractLanguage(raw);
    if (detected) {
      rememberInterfaceLanguage(detected);
      return detected;
    }
  }

  const rememberedLanguage = getRememberedInterfaceLanguage();
  if (rememberedLanguage) {
    return rememberedLanguage;
  }

  // Localization must be driven by the saved interface language preference.
  return 'english';
}

export function localizeCharacterFeatureNameById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  const key = resolveCharacterFeatureKey(featureId, 'name');
  return key
    ? translateUi(language, key, fallback ?? featureId)
    : (fallback ?? featureId);
}

export function localizeCharacterFeatureDescriptionById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  const key = resolveCharacterFeatureKey(featureId, 'description');
  return key ? translateUi(language, key, fallback ?? '') : (fallback ?? '');
}

export function localizeDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  for (const candidate of deriveDataIdCandidates(id)) {
    const key = `ui.character.data.${candidate}`;
    const localized = UI_BY_LANGUAGE[language][key] ?? EN_UI_BY_KEY[key];
    if (localized) {
      return localized;
    }
  }

  return fallback ?? toDataId(id);
}

export function localizeCharacterDataLabelById(
  language: InterfaceLanguage,
  id: string,
  fallback?: string,
): string {
  return localizeDataLabelById(language, id, fallback);
}

export function localizeGameFeatureNameById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string {
  return translateUi(
    language,
    resolveGameFeatureKey(featureId, 'name'),
    fallback ?? featureId,
  );
}

export function localizeGameFeatureDescriptionById(
  language: InterfaceLanguage,
  featureId: string,
  fallback?: string,
): string | undefined {
  return translateUi(
    language,
    resolveGameFeatureKey(featureId, 'description'),
    fallback,
  );
}

export function localizeGender(
  language: InterfaceLanguage,
  genderId: string,
): string {
  const key = GENDER_TEXT_KEY_BY_ID[genderId];
  return key ? translateUi(language, key, genderId) : genderId;
}

export function getPreferencesLocalization(
  data: unknown,
  uiElement?: UIElementType,
) {
  const language = getCharacterPreferencesLanguage(data, uiElement);

  return {
    language,
    t: (key: string, fallback?: string) => translateUi(language, key, fallback),
    localizeCharacterFeatureNameById: (featureId: string, fallback?: string) =>
      localizeCharacterFeatureNameById(language, featureId, fallback),
    localizeCharacterFeatureDescriptionById: (
      featureId: string,
      fallback?: string,
    ) => localizeCharacterFeatureDescriptionById(language, featureId, fallback),
    localizeCharacterDataLabelById: (id: string, fallback?: string) =>
      localizeCharacterDataLabelById(language, id, fallback),
    localizeGameFeatureNameById: (featureId: string, fallback?: string) =>
      localizeGameFeatureNameById(language, featureId, fallback),
    localizeGameFeatureDescriptionById: (
      featureId: string,
      fallback?: string,
    ) => localizeGameFeatureDescriptionById(language, featureId, fallback),
    localizeGender: (genderId: string) => localizeGender(language, genderId),
    localizeDataLabelById: (id: string, fallback?: string) =>
      localizeDataLabelById(language, id, fallback),
  };
}

export function usePreferencesLocalization(
  data?: unknown,
  uiElement?: UIElementType,
) {
  const backend = useBackend<PreferencesMenuData>();
  const [, setRefreshVersion] = useState(0);
  const mergedSource = {
    ...(backend.data as Record<string, unknown>),
    ...((data as Record<string, unknown>) ?? {}),
    config: backend.config,
    client: backend.config?.client,
  };
  const localizedElement = uiElement ?? inferUIElementType(mergedSource);

  useEffect(() => {
    const rerender = () => {
      setRefreshVersion((version) => version + 1);
    };

    if (typeof window === 'undefined') {
      return;
    }

    window.addEventListener(
      getInterfaceLanguageUpdatedEvent(),
      rerender as EventListener,
    );

    if (localizedElement) {
      window.addEventListener(
        getLanguageUpdatedEvent(localizedElement),
        rerender as EventListener,
      );
    }

    window.addEventListener('storage', rerender);

    return () => {
      window.removeEventListener(
        getInterfaceLanguageUpdatedEvent(),
        rerender as EventListener,
      );

      if (localizedElement) {
        window.removeEventListener(
          getLanguageUpdatedEvent(localizedElement),
          rerender as EventListener,
        );
      }

      window.removeEventListener('storage', rerender);
    };
  }, [localizedElement]);

  const resolved = getPreferencesLocalization(mergedSource, uiElement);
  const { language } = resolved;

  const t = useCallback(
    (key: string, fallback?: string) => resolved.t(key, fallback),
    [language],
  );
  const localizeCharacterFeatureNameByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeCharacterFeatureNameById(featureId, fallback),
    [language],
  );
  const localizeCharacterFeatureDescriptionByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeCharacterFeatureDescriptionById(featureId, fallback),
    [language],
  );
  const localizeCharacterDataLabelByIdForLanguage = useCallback(
    (id: string, fallback?: string) =>
      resolved.localizeCharacterDataLabelById(id, fallback),
    [language],
  );
  const localizeGameFeatureNameByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeGameFeatureNameById(featureId, fallback),
    [language],
  );
  const localizeGameFeatureDescriptionByIdForLanguage = useCallback(
    (featureId: string, fallback?: string) =>
      resolved.localizeGameFeatureDescriptionById(featureId, fallback),
    [language],
  );
  const localizeGenderForLanguage = useCallback(
    (genderId: string) => resolved.localizeGender(genderId),
    [language],
  );
  const localizeDataLabelByIdForLanguage = useCallback(
    (id: string, fallback?: string) =>
      resolved.localizeDataLabelById(id, fallback),
    [language],
  );

  return {
    language,
    t,
    localizeCharacterFeatureNameById:
      localizeCharacterFeatureNameByIdForLanguage,
    localizeCharacterFeatureDescriptionById:
      localizeCharacterFeatureDescriptionByIdForLanguage,
    localizeCharacterDataLabelById: localizeCharacterDataLabelByIdForLanguage,
    // Character tab id-first aliases.
    localizeFeatureById: localizeCharacterFeatureNameByIdForLanguage,
    localizeFeatureDescriptionById:
      localizeCharacterFeatureDescriptionByIdForLanguage,
    localizeCharacterDataById: localizeCharacterDataLabelByIdForLanguage,
    localizeGameFeatureNameById: localizeGameFeatureNameByIdForLanguage,
    localizeGameFeatureDescriptionById:
      localizeGameFeatureDescriptionByIdForLanguage,
    localizeGender: localizeGenderForLanguage,
    localizeDataLabelById: localizeDataLabelByIdForLanguage,
  };
}
