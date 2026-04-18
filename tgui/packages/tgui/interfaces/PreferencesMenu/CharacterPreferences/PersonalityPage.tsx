import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';
import type { Personality, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { usePreferencesLocalization } from './localization';

type ButtonData = {
  backgroundColor: string;
  borderColor: string;
  tooltip: string | null;
};

function sanitizePersonalityPath(path: string): string {
  return (path ?? '')
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[:]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function translatePersonalityField(
  t: (key: string, fallback?: string) => string,
  personalityPath: string,
  suffix:
    | 'name'
    | 'description'
    | 'pos_gameplay_description'
    | 'neg_gameplay_description'
    | 'neut_gameplay_description',
  fallback?: string,
): string {
  const pathId = sanitizePersonalityPath(personalityPath);
  return t(`ui.character.data.personality_${pathId}_${suffix}`, fallback);
}

function getButtonColors(
  selected: boolean | undefined,
  invalid: boolean | string | null | undefined,
  disabled: boolean | undefined,
  t: (key: string, fallback?: string) => string,
): ButtonData {
  if (invalid) {
    return {
      backgroundColor: 'rgba(64, 34, 34, 0.5)',
      borderColor: 'darkred',
      tooltip: t('ui.character.personality_cannot_select_with').replace(
        '{personality}',
        String(invalid),
      ),
    };
  }
  if (disabled) {
    return {
      backgroundColor: 'rgba(64, 64, 64, 0.5)',
      borderColor: '#666666',
      tooltip: t('ui.character.personality_maximum_reached'),
    };
  }
  if (selected) {
    return {
      backgroundColor: 'rgba(34, 64, 34, 0.5)',
      borderColor: 'green',
      tooltip: null,
    };
  }
  return {
    backgroundColor: 'rgba(34, 34, 34, 0.5)',
    borderColor: '#444444',
    tooltip: null,
  };
}

type ButtonProps = {
  personality: Personality;
  selected?: boolean;
  invalid?: string | null;
  disabled?: boolean;
  onClick: () => void;
};

function PersonalityButton(props: ButtonProps) {
  const { personality, selected, invalid, disabled, onClick } = props;
  const { t } = usePreferencesLocalization();

  const { backgroundColor, borderColor, tooltip } = getButtonColors(
    selected,
    invalid,
    disabled,
    t,
  );
  const isDisabled = disabled || invalid || false;
  return (
    <Button
      className={`PreferencesMenu__Personality__Card${selected ? ' PreferencesMenu__Personality__Card--selected' : ''}`}
      onClick={isDisabled ? undefined : onClick}
      p={1}
      pt={0.2}
      style={{
        cursor: isDisabled ? undefined : 'pointer',
        borderColor: borderColor,
        borderStyle: 'solid',
        borderWidth: '0.2em',
        borderRadius: '0.33em',
      }}
      fluid
      height="180px"
      backgroundColor={backgroundColor}
      tooltip={tooltip}
    >
      <Stack vertical wrap justify="center">
        <Stack.Item
          className="PreferencesMenu__Personality__CardTitle"
          textAlign="center"
          bold
          fontSize="16px"
          inline
          p={0.5}
          style={{
            whiteSpace: 'normal',
            wordBreak: 'break-word',
            paddingLeft: '0.5em',
          }}
        >
          {translatePersonalityField(
            t,
            personality.path,
            'name',
            personality.name,
          )}
        </Stack.Item>
        <Stack.Item
          className="PreferencesMenu__Personality__CardDescription"
          color="#999999"
          mt={-1}
          pt={0.2}
          style={{
            whiteSpace: 'normal',
            wordBreak: 'break-word',
            borderTop: '0.2em solid #444444',
            borderLeft: '0.2em solid #444444',
            paddingLeft: '0.5em',
          }}
        >
          {translatePersonalityField(
            t,
            personality.path,
            'description',
            personality.description,
          )}
        </Stack.Item>
        {personality.pos_gameplay_description && (
          <Stack.Item
            className="PreferencesMenu__Personality__CardPos"
            mt={-0.8}
            color="green"
            style={{ whiteSpace: 'normal', wordBreak: 'break-word' }}
          >
            +{' '}
            {translatePersonalityField(
              t,
              personality.path,
              'pos_gameplay_description',
              personality.pos_gameplay_description,
            )}
          </Stack.Item>
        )}
        {personality.neg_gameplay_description && (
          <Stack.Item
            className="PreferencesMenu__Personality__CardNeg"
            mt={-0.8}
            color="red"
            style={{
              whiteSpace: 'normal',
              wordBreak: 'break-word',
            }}
          >
            -{' '}
            {translatePersonalityField(
              t,
              personality.path,
              'neg_gameplay_description',
              personality.neg_gameplay_description,
            )}
          </Stack.Item>
        )}
        {personality.neut_gameplay_description && (
          <Stack.Item
            className="PreferencesMenu__Personality__CardNeut"
            mt={-0.8}
            color="yellow"
            style={{
              whiteSpace: 'normal',
              wordBreak: 'break-word',
            }}
          >
            +/-{' '}
            {translatePersonalityField(
              t,
              personality.path,
              'neut_gameplay_description',
              personality.neut_gameplay_description,
            )}
          </Stack.Item>
        )}
      </Stack>
    </Button>
  );
}

// Sort by selected first, then by name
function sortPersonalities(
  a: Personality,
  b: Personality,
  selectedPersonalities: string[] | null,
) {
  const aSelected = selectedPersonalities?.includes(a.path);
  const bSelected = selectedPersonalities?.includes(b.path);

  if (aSelected && !bSelected) return -1;
  if (!aSelected && bSelected) return 1;

  return a.name < b.name ? -1 : 1;
}

// Checks if the passed personality is incompatible with the selected personalities
// Returns the name of the incompatible personality or null if there is no incompatibility
function isIncompatible(
  personality: Personality,
  allPersonalities: Personality[],
  selectedPersonalities: string[] | null,
  personalityIncompatibilities: Record<string, string[]>,
  t: (key: string, fallback?: string) => string,
): string | null {
  if (!selectedPersonalities || !personality.groups) return null;
  // personalityIncompatibilities is keyed by group -
  // where value is a list of incompatible personality typePaths
  for (const group of personality.groups) {
    for (const selectedTypePath of selectedPersonalities) {
      if (selectedTypePath === personality.path) continue;
      if (personalityIncompatibilities[group].includes(selectedTypePath)) {
        return (
          (getPersonalityName(allPersonalities, selectedTypePath) &&
            translatePersonalityField(
              t,
              selectedTypePath,
              'name',
              getPersonalityName(allPersonalities, selectedTypePath),
            )) ||
          t('ui.character.personality_unknown')
        );
      }
    }
  }

  return null;
}

// Checks if the passed personality is disabled
function isDisabled(
  selectedPersonalities: string[] | null,
  personality: Personality,
  maxPersonalities: number,
): boolean {
  if (!selectedPersonalities) {
    return false;
  }
  if (
    maxPersonalities !== -1 &&
    selectedPersonalities.length < maxPersonalities
  ) {
    return false;
  }
  return !selectedPersonalities.includes(personality.path);
}

// Takes a typePath, returns the name of the personality
function getPersonalityName(
  allPersonalities: Personality[],
  personalityPath: string,
): string | undefined {
  for (const personality of allPersonalities) {
    if (personality.path === personalityPath) {
      return personality.name;
    }
  }
  return undefined;
}

// Returns a string of all selected personalities formatted in a readable way
function getAllSelectedPersonalitiesString(
  allPersonalities: Personality[],
  selectedPersonalities: string[] | null,
  t: (key: string, fallback?: string) => string,
) {
  const personalityNames: string[] = [];
  for (const personality of allPersonalities) {
    if (selectedPersonalities?.includes(personality.path)) {
      personalityNames.push(personality.name);
      personalityNames[personalityNames.length - 1] = translatePersonalityField(
        t,
        personality.path,
        'name',
        personality.name,
      );
    }
  }
  if (personalityNames.length === 0) {
    return t('ui.character.personality_none_selected');
  }
  personalityNames.sort((a, b) => (a < b ? -1 : 1));
  let finalString = '';
  for (let i = 0; i < personalityNames.length; i++) {
    finalString += personalityNames[i];
    if (i < personalityNames.length - 1) {
      if (personalityNames.length > 2) {
        finalString += ', ';
      }
    }
    if (i === personalityNames.length - 2) {
      if (finalString[finalString.length - 1] !== ' ') {
        finalString += ' ';
      }
      finalString += `${t('ui.character.personality_and')} `;
    }
  }
  return t('ui.character.personality_you_are').replace(
    '{personality}',
    finalString,
  );
}

export function PersonalityPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  const server_data = useServerPrefs();
  if (!server_data) return;

  const personalities = server_data.personality.personalities;
  const personalityIncompatibilities =
    server_data.personality.personality_incompatibilities;

  const [searchQuery, setSearchQuery] = useState('');
  const personalitySearch = createSearch(
    searchQuery,
    (personality: Personality) =>
      personality.name +
      personality.description +
      personality.pos_gameplay_description +
      personality.neg_gameplay_description +
      personality.neut_gameplay_description,
  );
  const selectedPersonalities = data.selected_personalities;
  const filteredPersonalities = personalities
    .filter(personalitySearch)
    .sort((a, b) => sortPersonalities(a, b, selectedPersonalities));

  return (
    <Section className="PreferencesMenu__Personality" fill>
      <Stack vertical fill>
        <Stack.Item
          className="PreferencesMenu__Personality__Summary"
          align="center"
          textAlign="center"
          fontSize="20px"
          bold
          width="100%"
          maxHeight="50px"
          style={{
            whiteSpace: 'normal',
            wordBreak: 'break-word',
          }}
        >
          <Flex height="100%" align="center">
            <Flex.Item grow>
              {getAllSelectedPersonalitiesString(
                personalities,
                selectedPersonalities,
                t,
              )}
            </Flex.Item>
            <Flex.Item width="120px">
              <Box className="PreferencesMenu__Personality__Counter" p={0.5}>
                {selectedPersonalities?.length || 0} /{' '}
                {data.max_personalities === -1
                  ? t('ui.character.personality_infinity')
                  : data.max_personalities}
              </Box>
            </Flex.Item>
            <Flex.Item ml={1}>
              <Button
                className="PreferencesMenu__Personality__ClearButton"
                color="red"
                icon="trash"
                disabled={!selectedPersonalities?.length}
                style={{
                  cursor: selectedPersonalities?.length ? 'pointer' : undefined,
                }}
                onClick={() => {
                  act('clear_personalities');
                }}
              />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        {!data.mood_enabled && (
          <Stack.Item>
            <NoticeBox danger align="center" fontSize="14px">
              <Flex>
                <Flex.Item>
                  <Icon name="exclamation-triangle" mr={1} />
                </Flex.Item>
                <Flex.Item>{t('ui.character.personality_mood_disabled')}</Flex.Item>
              </Flex>
            </NoticeBox>
          </Stack.Item>
        )}
        <Stack.Item mb={1}>
          <Input
            className="PreferencesMenu__Personality__Search"
            fluid
            placeholder={t('ui.character.personality_search_placeholder')}
            value={searchQuery}
            onChange={(v) => setSearchQuery(v)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Section className="PreferencesMenu__Personality__GridSection" fill scrollable>
            <Flex wrap width="100%">
              {filteredPersonalities.map((personality) => (
                <Flex.Item
                  key={personality.name}
                  mr={0.5}
                  mb={0.5}
                  width="32.9%"
                >
                  <PersonalityButton
                    personality={personality}
                    selected={selectedPersonalities?.includes(personality.path)}
                    invalid={isIncompatible(
                      personality,
                      personalities,
                      selectedPersonalities,
                      personalityIncompatibilities,
                      t,
                    )}
                    disabled={isDisabled(
                      selectedPersonalities,
                      personality,
                      data.max_personalities,
                    )}
                    onClick={() => {
                      act('handle_personality', {
                        personality_type: personality.path,
                      });
                    }}
                  />
                </Flex.Item>
              ))}
            </Flex>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
