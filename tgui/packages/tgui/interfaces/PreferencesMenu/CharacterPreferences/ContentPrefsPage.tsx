import { binaryInsertWith } from 'common/collections';
import { sortBy } from 'es-toolkit';
import { type ReactNode, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Flex, Tooltip } from 'tgui-core/components';

import { TabbedMenu } from '../GamePreferences/TabbedMenu';
import { usePreferencesLocalization } from '../localization';
import { features } from '../preferences/features';
import { FeatureValueInput } from '../preferences/features/base';
import type { PreferencesMenuData } from '../types';

type PreferenceChild = {
  name: string;
  children: ReactNode;
};

const CONTENT_PREF_FEATURE_IDS = new Set([
  'bimbofication_pref',
  'aphro_pref',
  'breast_enlargement_pref',
  'breast_shrinkage_pref',
  'breast_removal_pref',
  'penis_enlargement_pref',
  'penis_shrinkage_pref',
  'gender_change_pref',
  'erp_sexuality_pref',
  'genitalia_removal_pref',
  'new_genitalia_growth_pref',
]);

function binaryInsertPreference(
  collection: PreferenceChild[],
  value: PreferenceChild,
) {
  return binaryInsertWith(collection, value, (child) => child.name);
}

function sortByName(array: [string, PreferenceChild[]][]) {
  const erpCategory = 'ERP';
  return sortBy(array, [
    ([name]) => (name === erpCategory ? 0 : 1),
    ([name]) => name,
  ]);
}

export function ContentPrefsPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const {
    language: interfaceLanguage,
    t,
    localizeGameFeatureDescriptionById,
    localizeGameFeatureNameById,
  } = usePreferencesLocalization(data);
  const [searchText, setSearchText] = useState('');

  const contentPreferences: Record<string, PreferenceChild[]> = {};

  for (const [featureId, value] of Object.entries(
    data.character_preferences?.game_preferences ?? {},
  )) {
    if (!CONTENT_PREF_FEATURE_IDS.has(featureId)) {
      continue;
    }

    const feature = features[featureId];
    const translatedName = localizeGameFeatureNameById(
      featureId,
      feature?.name || featureId,
    );
    const translatedDescription = localizeGameFeatureDescriptionById(
      featureId,
      feature?.description,
    );

    let nameInner: ReactNode = translatedName;

    if (translatedDescription) {
      nameInner = (
        <Box
          as="span"
          style={{
            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
          }}
        >
          {nameInner}
        </Box>
      );
    }

    let name: ReactNode = (
      <Flex.Item grow={1} pr={2} basis={0} ml={2}>
        {nameInner}
      </Flex.Item>
    );

    if (translatedDescription) {
      name = (
        <Tooltip content={translatedDescription} position="bottom-start">
          {name}
        </Tooltip>
      );
    }

    const child = (
      <Flex align="center" key={featureId} pb={2}>
        {name}
        <Flex.Item grow={1} basis={0}>
          {feature ? (
            <FeatureValueInput
              feature={feature}
              featureId={featureId}
              value={value}
            />
          ) : (
            <Box as="b" color="red">
              {t('ui.game.game_preference_not_filled_out')}
            </Box>
          )}
        </Flex.Item>
      </Flex>
    );

    const entry = {
      name: translatedName,
      children: child,
    };

    const category = feature?.category || 'ERP';

    contentPreferences[category] = binaryInsertPreference(
      contentPreferences[category] || [],
      entry,
    );
  }

  const contentPreferenceEntries: [string, ReactNode[]][] = sortByName(
    Object.entries(contentPreferences),
  ).map(([category, preferences]) => [
    category,
    preferences
      .filter((entry) => {
        return (
          !searchText ||
          searchText.length < 2 ||
          entry.name.toLowerCase().includes(searchText.toLowerCase())
        );
      })
      .map((entry) => entry.children),
  ]);

  return (
    <TabbedMenu
      categoryEntries={contentPreferenceEntries}
      interfaceLanguage={interfaceLanguage}
      contentProps={{
        fontSize: 1.5,
      }}
      searchText={searchText}
      setSearchText={setSearchText}
    />
  );
}
