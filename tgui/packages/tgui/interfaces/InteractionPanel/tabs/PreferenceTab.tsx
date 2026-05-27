// THIS IS A NOVA SECTOR UI FILE
import { useMemo } from 'react';
import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { usePreferencesLocalization } from '../../localization';

type InteractionPreference = {
  id: string;
  name: string;
  description?: string;
  type: 'toggle' | 'choice';
  category?: string;
  value: BooleanLike | string;
  choices?: string[];
};

type PreferenceTabProps = {
  preferences: InteractionPreference[];
  searchText: string;
  onSetPreference: (preferenceId: string, value: boolean | string) => void;
};

type PreferenceGroupDefinition = {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  preferenceIds: string[];
};

const PREFERENCE_GROUPS: PreferenceGroupDefinition[] = [
  {
    id: 'statuses',
    title: 'ERP Statuses',
    description: 'Character-facing ERP boundaries and scene preference statuses.',
    icon: 'id-card',
    color: 'pink',
    preferenceIds: [
      'erp_status_pref',
      'erp_status_mechanical_pref',
      'erp_status_noncon_pref',
      'erp_status_hypnosis_pref',
      'erp_status_vore_pref',
    ],
  },
  {
    id: 'access',
    title: 'ERP Access',
    description: 'Core ERP availability, visibility, and sound behaviour.',
    icon: 'sliders-h',
    color: 'purple',
    preferenceIds: [
      'master_erp_pref',
      'erp_pref',
      'erp_hide_interactions_from_ghosts_pref',
      'erp_sounds_pref',
      'sextoy_sounds_pref',
    ],
  },
  {
    id: 'automation',
    title: 'Automation',
    description: 'Automatic ERP reactions and system-driven behaviour.',
    icon: 'bolt',
    color: 'pink',
    preferenceIds: [
      'autoemote_pref',
      'autocum_pref',
      'aphro_pref',
    ],
  },
  {
    id: 'content',
    title: 'Content Rules',
    description: 'Boundaries, toys, and allowed ERP body/content changes.',
    icon: 'shield-alt',
    color: 'blue',
    preferenceIds: [
      'erp_sexuality_pref',
      'gender_change_pref',
      'new_genitalia_growth_pref',
      'sextoy_pref',
      'penis_enlargement_pref',
      'genitalia_removal_pref',
      'penis_shrinkage_pref',
    ],
  },
];

export const PreferenceTab = (props: PreferenceTabProps) => {
  const { preferences, searchText, onSetPreference } = props;
  const { data } = useBackend<any>();
  const { t } = usePreferencesLocalization(data);

  const localizeGroupText = (
    groupId: string,
    field: 'title' | 'description',
    fallback: string,
  ) => {
    const key = `ui.interaction_panel.pref_group.${groupId}.${field}`;
    const localized = t(key);
    return localized !== key ? localized : fallback;
  };

  const localizePreferenceText = (
    preference: InteractionPreference,
    field: 'name' | 'description',
  ) => {
    const key = `ui.interaction_panel.preference.${preference.id}.${field}`;
    const localized = t(key);
    return localized !== key ? localized : preference[field];
  };

  const normalizeChoiceKey = (choice: string) =>
    choice
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '_')
      .replace(/^_+|_+$/g, '');

  const localizeChoiceText = (
    preferenceId: string,
    choice: string,
  ) => {
    const key = `ui.interaction_panel.choice.${preferenceId}.${normalizeChoiceKey(choice)}`;
    const localized = t(key);
    return localized !== key ? localized : choice;
  };

  const filteredPreferences = useMemo(() => {
    const normalizedSearch = searchText.trim().toLowerCase();
    if (!normalizedSearch || normalizedSearch.length < 2) {
      return preferences;
    }

    return preferences.filter((preference) => {
      const localizedName = String(
        localizePreferenceText(preference, 'name') || '',
      );
      const localizedDescription = String(
        localizePreferenceText(preference, 'description') || '',
      );
      return (
        localizedName.toLowerCase().includes(normalizedSearch) ||
        localizedDescription.toLowerCase().includes(normalizedSearch)
      );
    });
  }, [preferences, searchText]);

  const groupedPreferences = useMemo(() => {
    const orderedGroups = PREFERENCE_GROUPS.map((group) => ({
      ...group,
      preferences: filteredPreferences.filter((preference) =>
        group.preferenceIds.includes(preference.id),
      ),
    })).filter((group) => group.preferences.length > 0);

    const groupedIds = new Set(
      orderedGroups.flatMap((group) => group.preferences.map((preference) => preference.id)),
    );

    const miscellaneous = filteredPreferences.filter(
      (preference) => !groupedIds.has(preference.id),
    );

    if (miscellaneous.length) {
      orderedGroups.push({
        id: 'miscellaneous',
        title: 'Other',
        description: 'Additional ERP preferences.',
        icon: 'cog',
        color: 'grey',
        preferenceIds: [],
        preferences: miscellaneous,
      });
    }

    return orderedGroups;
  }, [filteredPreferences]);

  if (!groupedPreferences.length) {
    return (
      <Section fill>
        <Box color="label" textAlign="center">
          {t('ui.interaction_panel.no_preferences_found')}
        </Box>
      </Section>
    );
  }

  return (
    <Stack vertical fill>
      {groupedPreferences.map((group) => (
        <Stack.Item key={group.id}>
          <Section
            title={(
              <Box>
                <Icon name={group.icon} color={group.color} mr={0.5} />
                {localizeGroupText(group.id, 'title', group.title)}
              </Box>
            )}
          >
            <Box color="label" mb={1}>
              {localizeGroupText(group.id, 'description', group.description)}
            </Box>
            <Stack vertical>
              {group.preferences.map((preference) => {
                const localizedName = localizePreferenceText(preference, 'name');
                const localizedDescription = localizePreferenceText(
                  preference,
                  'description',
                );

                return (
                  <Stack.Item key={preference.id}>
                    <Flex
                      align="center"
                      justify="space-between"
                      g={1}
                      style={{
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '6px',
                        padding: '8px 10px',
                        background: 'rgba(255, 255, 255, 0.03)',
                      }}
                    >
                      <Flex.Item grow basis={0} style={{ minWidth: 0 }}>
                        {localizedDescription ? (
                          <Tooltip
                            content={localizedDescription}
                            position="bottom-start"
                          >
                            <Box
                              style={{
                                cursor: 'help',
                                minWidth: 0,
                              }}
                            >
                              <Box
                                bold
                                style={{
                                  overflow: 'hidden',
                                  textOverflow: 'ellipsis',
                                  whiteSpace: 'nowrap',
                                }}
                              >
                                {localizedName}
                              </Box>
                              <Box
                                color="label"
                                fontSize={0.9}
                                mt={0.25}
                                style={{
                                  overflow: 'hidden',
                                  textOverflow: 'ellipsis',
                                  whiteSpace: 'nowrap',
                                }}
                              >
                                {localizedDescription}
                              </Box>
                            </Box>
                          </Tooltip>
                        ) : (
                          <Box
                            bold
                            style={{
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              whiteSpace: 'nowrap',
                            }}
                          >
                            {localizedName}
                          </Box>
                        )}
                      </Flex.Item>
                      <Flex.Item width="44%">
                        {preference.type === 'choice' ? (
                          <Dropdown
                            width="100%"
                            selected={String(preference.value ?? '')}
                            displayText={localizeChoiceText(
                              preference.id,
                              String(preference.value ?? ''),
                            )}
                            options={(preference.choices || []).map((choice) => ({
                              displayText: localizeChoiceText(preference.id, choice),
                              value: choice,
                            }))}
                            onSelected={(value) =>
                              onSetPreference(preference.id, String(value))
                            }
                          />
                        ) : (
                          <Button.Checkbox
                            checked={!!preference.value}
                            fluid
                            color={preference.value ? 'green' : 'grey'}
                            onClick={() =>
                              onSetPreference(preference.id, !preference.value)
                            }
                          >
                            {preference.value
                              ? t('ui.interaction_panel.enabled')
                              : t('ui.interaction_panel.disabled')}
                          </Button.Checkbox>
                        )}
                      </Flex.Item>
                    </Flex>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};
