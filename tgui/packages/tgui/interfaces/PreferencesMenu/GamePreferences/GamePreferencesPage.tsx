import { binaryInsertWith } from 'common/collections';
import { sortBy } from 'es-toolkit';
import { type ReactNode, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Flex, Tooltip } from 'tgui-core/components';

import { getCharacterPreferencesLanguage } from '../CharacterPreferences/localization';
import { features } from '../preferences/features';
import { FeatureValueInput } from '../preferences/features/base';
import type { PreferencesMenuData } from '../types';
import featuresRu from './locales/features.ru.json';
import { TabbedMenu } from './TabbedMenu';

type PreferenceChild = {
  name: string;
  children: ReactNode;
};

type FeaturesRuJson = {
  feature_names_by_id: Record<string, string>;
  feature_names_by_en: Record<string, string>;
  feature_descriptions_by_id: Record<string, string>;
  feature_descriptions_by_en: Record<string, string>;
};

const RU_FEATURES = featuresRu as FeaturesRuJson;

function binaryInsertPreference(
  collection: PreferenceChild[],
  value: PreferenceChild,
) {
  return binaryInsertWith(collection, value, (child) => child.name);
}

function sortByName(array: [string, PreferenceChild[]][]) {
  const languageCategory = 'LANGUAGE';
  return sortBy(array, [
    ([name]) => (name === languageCategory ? 0 : 1),
    ([name]) => name,
  ]);
}

export function GamePreferencesPage(props) {
  const { data } = useBackend<PreferencesMenuData>();
  const interfaceLanguage = getCharacterPreferencesLanguage(data);

  const gamePreferences: Record<string, PreferenceChild[]> = {};

  for (const [featureId, value] of Object.entries(
    data.character_preferences?.game_preferences ?? {},
  )) {
    const feature = features[featureId];

    const translatedName =
      interfaceLanguage === 'russian'
        ? RU_FEATURES.feature_names_by_id[featureId] ||
          (feature?.name
            ? RU_FEATURES.feature_names_by_en[feature.name]
            : undefined) ||
          feature?.name ||
          featureId
        : feature?.name || featureId;

    const translatedDescription =
      interfaceLanguage === 'russian'
        ? RU_FEATURES.feature_descriptions_by_id[featureId] ||
          (feature?.description
            ? RU_FEATURES.feature_descriptions_by_en[feature.description.trim()]
            : undefined) ||
          feature?.description
        : feature?.description;

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
              {interfaceLanguage === 'russian'
                ? '...настройка заполнена некорректно!!!'
                : '...is not filled out properly!!!'}
            </Box>
          )}
        </Flex.Item>
      </Flex>
    );

    const entry = {
      name: translatedName,
      children: child,
    };

    const category = feature?.category || 'ERROR';

    gamePreferences[category] = binaryInsertPreference(
      gamePreferences[category] || [],
      entry,
    );
  }

  const [searchText, setSearchText] = useState('');

  const gamePreferenceEntries: [string, ReactNode[]][] = sortByName(
    Object.entries(gamePreferences),
  ).map(([category, preferences]) => {
    return [
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
    ];
  });

  return (
    <TabbedMenu
      categoryEntries={gamePreferenceEntries}
      interfaceLanguage={interfaceLanguage}
      contentProps={{
        fontSize: 1.5,
      }}
      searchText={searchText}
      setSearchText={setSearchText}
    />
  );
}
