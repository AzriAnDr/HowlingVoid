import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Floating,
  Icon,
  Input,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import {
  type PreferencesMenuData,
  type Quirk,
  RandomSetting,
  type ServerData,
} from '../types';
import { useRandomToggleState } from '../useRandomToggleState';
import { useServerPrefs } from '../useServerPrefs';
import { getRandomization, PreferenceList } from './MainPage';
import { PersonalityPage } from './PersonalityPage';
import { usePreferencesLocalization } from './localization';
import { getCombinedQuirkAugmentBalance } from './quirkBalance';

function getColorValueClass(quirk: Quirk) {
  if (quirk.value > 0) {
    return 'positive';
  } else if (quirk.value < 0) {
    return 'negative';
    // NOVA EDIT ADDITION BEGIN - Purple ERP quirks
  } else if (quirk.erp_quirk) {
    return 'erp_quirk';
    // NOVA EDIT ADDITION END
  } else {
    return 'neutral';
  }
}

function getCorrespondingPreferences(
  customization_options: string[],
  relevant_preferences: Record<string, string> = {},
) {
  return Object.fromEntries(
    filter(Object.entries(relevant_preferences), ([key, value]) =>
      customization_options.includes(key),
    ),
  );
}

type QuirkEntry = [string, Quirk & { failTooltip?: string }];

type QuirkListProps = {
  quirks: QuirkEntry[];
};

type QuirkProps = {
  handleClick: (quirkName: string, quirk: Quirk) => void;
  randomBodyEnabled: boolean;
  selected: boolean;
  serverData: ServerData;
  quirkActionLocked: boolean;
};

function sanitizeQuirkLocalizationId(value: string) {
  return (value ?? '').replace(/[^a-zA-Z0-9]/g, '');
}

function looksLikeRawQuirkKey(value?: string) {
  return !!value && /^quirk_[a-z0-9_]+_(name|description)$/i.test(value);
}

function humanizeQuirkKey(quirkKey: string) {
  return (quirkKey ?? '')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

function getQuirkLocalizationCandidates(
  quirkKey: string,
  quirkName: string,
  suffix: 'name' | 'description',
) {
  const candidates: string[] = [];
  const pushUnique = (value: string) => {
    if (value && !candidates.includes(value)) {
      candidates.push(value);
    }
  };

  pushUnique(`quirk_${quirkKey}_${suffix}`);
  pushUnique(`quirk_${quirkKey.toLowerCase()}_${suffix}`);

  const sanitizedName = sanitizeQuirkLocalizationId(quirkName);
  if (sanitizedName) {
    pushUnique(`quirk_${sanitizedName}_${suffix}`);
    pushUnique(`quirk_${sanitizedName.toLowerCase()}_${suffix}`);
  }

  return candidates;
}

function translateQuirkField(
  t: (key: string) => string,
  localizeDataLabelById: (id: string, fallback?: string) => string,
  quirkKey: string,
  quirkName: string,
  suffix: 'name' | 'description',
  fallback?: string,
) {
  const safeFallback =
    suffix === 'name'
      ? looksLikeRawQuirkKey(fallback)
        ? humanizeQuirkKey(quirkKey)
        : fallback || humanizeQuirkKey(quirkKey)
      : looksLikeRawQuirkKey(fallback)
        ? ''
        : fallback;

  if (fallback && looksLikeRawQuirkKey(fallback)) {
    const localizedFallback = localizeDataLabelById(fallback);
    if (localizedFallback !== fallback) {
      return localizedFallback;
    }
  }

  for (const candidate of getQuirkLocalizationCandidates(
    quirkKey,
    quirkName,
    suffix,
  )) {
    const uiKey = `ui.character.data.${candidate}`;
    const translated = t(uiKey);
    if (translated !== uiKey) {
      return translated;
    }

    const localized = localizeDataLabelById(candidate);
    if (localized !== candidate) {
      return localized;
    }
  }

  return localizeDataLabelById(`quirk_${quirkKey}_${suffix}`, safeFallback);
}

function QuirkList(props: QuirkProps & QuirkListProps) {
  const {
    quirks = [],
    selected,
    handleClick,
    serverData,
    randomBodyEnabled,
    quirkActionLocked,
  } = props;

  return (
    <Stack vertical g={0}>
      {quirks.map(([quirkKey, quirk]) => (
        <Stack.Item key={quirkKey} m={0}>
          <QuirkDisplay
            handleClick={handleClick}
            quirk={quirk}
            quirkKey={quirkKey}
            randomBodyEnabled={randomBodyEnabled}
            selected={selected}
            serverData={serverData}
            quirkActionLocked={quirkActionLocked}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
}

type QuirkDisplayProps = {
  quirk: Quirk & { failTooltip?: string };
  // bugged
  quirkKey: string;
} & QuirkProps;

function QuirkDisplay(props: QuirkDisplayProps) {
  const { quirk, quirkKey, handleClick, selected, quirkActionLocked } = props;
  const { icon, value, name, description, customizable, failTooltip } = quirk;
  const { t, localizeDataLabelById } = usePreferencesLocalization();

  const [customizationExpanded, setCustomizationExpanded] = useState(false);

  const className = 'PreferencesMenu__Quirks__QuirkList__quirk';
  const iconCellClass = `${className}__iconcell`;
  const iconCellQualityClass = `${iconCellClass}--${getColorValueClass(quirk)}`;

  const child = (
    <Box
      className={className}
      style={{
        opacity: props.quirkActionLocked ? 0.6 : 1,
        pointerEvents: props.quirkActionLocked ? 'none' : 'auto',
      }}
      onClick={() => {
        if (quirkActionLocked)
          return;
        if (selected) {
          setCustomizationExpanded(false);
        }

        handleClick(quirkKey, quirk);
      }}
    >
      <Stack fill g={0}>
        <Stack.Item
          className={`${iconCellClass} ${iconCellQualityClass}`}
          align="stretch"
          style={{
            minWidth: '15%',
            maxWidth: '15%',
            textAlign: 'center',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Icon color="#333" fontSize={3} name={icon} />
        </Stack.Item>

        <Stack.Item
          className={`${iconCellClass} ${iconCellQualityClass}`}
          align="stretch"
          ml={0}
          style={{
            borderRight: '1px solid black',
          }}
        />

        <Stack.Item
          grow
          ml={0}
          style={{
            // Fixes an IE bug for text overflowing in Flex boxes
            minWidth: '0%',
          }}
        >
          <Stack vertical fill>
            <Stack.Item
              className={`${className}--${getColorValueClass(quirk)}`}
              style={{
                borderBottom: '1px solid black',
                padding: '2px',
              }}
            >
              <Stack
                fill
                style={{
                  fontSize: '1.2em',
                }}
              >
                <Stack.Item grow basis="content">
                  <b>
                    {translateQuirkField(
                      t,
                      localizeDataLabelById,
                      quirkKey,
                      name,
                      'name',
                      name,
                    )}
                  </b>
                </Stack.Item>

                <Stack.Item>
                  <b>{value}</b>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item
              grow
              basis="content"
              mt={0}
              style={{
                padding: '3px',
              }}
            >
              {translateQuirkField(
                t,
                localizeDataLabelById,
                quirkKey,
                name,
                'description',
                description,
              )}
              {!!customizable && (
                <QuirkPopper
                  {...props}
                  customizationExpanded={customizationExpanded}
                  setCustomizationExpanded={setCustomizationExpanded}
                />
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );

  if (failTooltip) {
    return <Tooltip content={failTooltip}>{child}</Tooltip>;
  } else {
    return child;
  }
}

type QuirkPopperProps = {
  customizationExpanded: boolean;
  setCustomizationExpanded: (expanded: boolean) => void;
} & QuirkDisplayProps;

function QuirkPopper(props: QuirkPopperProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const {
    customizationExpanded,
    quirk,
    randomBodyEnabled,
    selected,
    serverData,
    setCustomizationExpanded,
  } = props;

  const { customizable, customization_options } = quirk;

  const { character_preferences } = data;

  const hasExpandableCustomization =
    customizable &&
    selected &&
    customization_options &&
    Object.entries(customization_options).length > 0;

  return (
    <Floating
      stopChildPropagation
      placement="bottom-end"
      onOpenChange={setCustomizationExpanded}
      content={
        hasExpandableCustomization && (
          <Box
            onClick={(e) => {
              e.stopPropagation();
            }}
            style={{
              boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            }}
          >
            {/* NOVA EDIT CHANGE - ORIGINAL: <Stack maxWidth="325px" backgroundColor="black" px="5px" py="3px"> */}
            <Stack maxWidth="400px" backgroundColor="black" px="5px" py="3px">
              <Stack.Item>
                <PreferenceList
                  preferences={getCorrespondingPreferences(
                    customization_options,
                    character_preferences.manually_rendered_features,
                  )}
                  randomizations={getRandomization(
                    getCorrespondingPreferences(
                      customization_options,
                      character_preferences.manually_rendered_features,
                    ),
                    serverData,
                    randomBodyEnabled,
                  )}
                  maxHeight="250px" // NOVA EDIT CHANGE - ORIGINAL: 100px
                />
              </Stack.Item>
            </Stack>
          </Box>
        )
      }
    >
      <div style={{ display: 'flow-root' }}>
        {selected && (
          <Button
            selected={customizationExpanded}
            icon="cog"
            tooltip={t('ui.character.quirks_customize')}
            style={{
              float: 'right',
            }}
          />
        )}
      </div>
    </Floating>
  );
}

function StatDisplay(props) {
  const { children, className } = props;

  return (
    <Box
      className={className}
      bold
      fontSize="1.2em"
      px={3}
      py={0.5}
    >
      {children}
    </Box>
  );
}

function QuirkPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabelById } = usePreferencesLocalization(data);

  // this is mainly just here to copy from MainPage.tsx
  const [randomToggleEnabled] = useRandomToggleState();
  const randomBodyEnabled =
    data.character_preferences.non_contextual.random_body !==
      RandomSetting.Disabled || randomToggleEnabled;

  const selectedQuirks = data.selected_quirks;
  function setSelectedQuirks(selected_quirks) {
    data.selected_quirks = selected_quirks;
  }

  const [quirkActionLocked, setQuirkActionLocked] = useState(false);

  function withQuirkDebounce(debounce: () => void, delay = 200) {
    if (quirkActionLocked) return;

    setQuirkActionLocked(true);
    debounce();

    setTimeout(() => {
      setQuirkActionLocked(false);
    }, delay);
  }

  const [searchQuery, setSearchQuery] = useState('');
  const server_data = useServerPrefs();
  if (!server_data) return;
  const quirkSearch = createSearch(searchQuery, (quirk: Quirk) => quirk.name);
  const {
    max_positive_quirks: maxPositiveQuirks,
    quirk_blacklist: quirkBlacklist,
    quirk_info: quirkInfo,
    points_enabled: pointsEnabled,
  } = server_data.quirks;

  const quirks = Object.entries(quirkInfo);
  const quirkKeyByName = Object.fromEntries(
    quirks.map(([quirkKey, quirk]) => [quirk.name, quirkKey]),
  ) as Record<string, string>;
  quirks.sort(([_, quirkA], [__, quirkB]) => {
    if (quirkA.value === quirkB.value) {
      return quirkA.name > quirkB.name ? 1 : -1;
    } else {
      return quirkA.value - quirkB.value;
    }
  });

  const balance = getCombinedQuirkAugmentBalance(data, server_data, selectedQuirks);
  let positiveQuirks = 0;

  for (const selectedQuirkName of selectedQuirks) {
    const selectedQuirk = quirkInfo[selectedQuirkName];
    if (!selectedQuirk) {
      continue;
    }

    if (selectedQuirk.value > 0) {
      positiveQuirks += 1;
    }
  }

  function getReasonToNotAdd(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (quirk.value > 0) {
      if (maxPositiveQuirks !== -1 && positiveQuirks >= maxPositiveQuirks) {
        return t('ui.character.quirks_no_more_positive');
      } else if (pointsEnabled && balance - quirk.value < 0) {
        return t('ui.character.quirks_need_negative_balance');
      }
    }
    // NOVA EDIT START - Nova star quirks
    if (quirk.nova_stars_only && !data.is_nova_star) {
      return t('ui.character.quirks_need_nova_star');
    }
    // NOVA EDIT END
    const selectedQuirkNames = selectedQuirks.map((quirkKey) => {
      return quirkInfo[quirkKey]?.name;
    });

    for (const blacklist of quirkBlacklist) {
      if (blacklist.indexOf(quirk.name) === -1) {
        continue;
      }

      for (const incompatibleQuirk of blacklist) {
        if (
          incompatibleQuirk !== quirk.name &&
          selectedQuirkNames.indexOf(incompatibleQuirk) !== -1
        ) {
          return t('ui.character.quirks_incompatible_with').replace(
            '{quirk}',
            localizeDataLabelById(
              `quirk_${quirkKeyByName[incompatibleQuirk]}_name`,
              incompatibleQuirk,
            ),
          );
        }
      }
    }
    if (data.species_disallowed_quirks.includes(quirk.name)) {
      return t('ui.character.quirks_incompatible_with_species');
    }
    return;
  }

  function getReasonToNotRemove(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (pointsEnabled && balance + quirk.value < 0) {
      return t('ui.character.quirks_remove_positive_first');
    }

    return;
  }

  return (
    <Stack fill>
      <Stack.Item basis="50%">
        <Stack vertical fill align="center">
          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <Box
                className="PreferencesMenu__Quirks__StatTitle PreferencesMenu__Quirks__AugmentsPointsTitle"
                fontSize="1.3em"
              >
                {t('ui.character.quirks_positive')}
              </Box>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <StatDisplay className="PreferencesMenu__Quirks__StatValue PreferencesMenu__Quirks__AugmentsPointsValue">
                {positiveQuirks} / {maxPositiveQuirks}
              </StatDisplay>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            <Box as="b" fontSize="1.6em">
              {t('ui.character.quirks_available')}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Input
              className="PreferencesMenu__Quirks__SearchInput"
              placeholder={t('ui.character.quirks_search_placeholder')}
              width="200px"
              value={searchQuery}
              onChange={setSearchQuery}
            />
          </Stack.Item>
          <Stack.Item
            grow
            className="PreferencesMenu__Quirks__QuirkList PreferencesMenu__Quirks__QuirkList--available"
          >
            <QuirkList
              selected={false}
              quirkActionLocked={quirkActionLocked}
              handleClick={(quirkName, quirk) => {
                if (getReasonToNotAdd(quirkName) !== undefined) {
                  return;
                }

                withQuirkDebounce(() => {
                  setSelectedQuirks(selectedQuirks.concat(quirkName));
                  act('give_quirk', { quirk: quirk.name });
                });
              }}
              quirks={quirks
                .filter(([quirkName, _]) => {
                  return (
                    selectedQuirks.indexOf(quirkName) === -1 &&
                    quirkSearch(quirkInfo[quirkName])
                  );
                })
                .map(([quirkName, quirk]) => {
                  return [
                    quirkName,
                    {
                      ...quirk,
                      failTooltip: getReasonToNotAdd(quirkName),
                    },
                  ];
                })}
              serverData={server_data}
              randomBodyEnabled={randomBodyEnabled}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item align="center">
        { /* <Icon name="exchange-alt" size={1.5} ml={2} mr={2} /> // NOVA EDIT REMOVAL - moved down */ }
        {/* NOVA EDIT ADDITION START */}
        <Stack vertical fill align="center">
          <Icon name="exchange-alt" size={1.5} ml={2} mr={2} />
        </Stack>
        {/* NOVA EDIT ADDITION END */}
      </Stack.Item>

      <Stack.Item basis="50%">
        <Stack vertical fill align="center">
          <Stack.Item>
            {pointsEnabled ? (
              <Box
                className="PreferencesMenu__Quirks__StatTitle PreferencesMenu__Quirks__AugmentsPointsTitle"
                fontSize="1.3em"
              >
                {t('ui.character.quirks_balance')}
              </Box>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            {pointsEnabled ? (
              <StatDisplay className="PreferencesMenu__Quirks__StatValue PreferencesMenu__Quirks__AugmentsPointsValue">
                {balance}
              </StatDisplay>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            <Box as="b" fontSize="1.6em">
              {t('ui.character.quirks_current')}
            </Box>
          </Stack.Item>
          <Stack.Item p={1.5} /> {/* Filler to better align the menu*/}
          <Stack.Item
            grow
            className="PreferencesMenu__Quirks__QuirkList PreferencesMenu__Quirks__QuirkList--current"
          >
            <QuirkList
              selected
              quirkActionLocked={quirkActionLocked}
              handleClick={(quirkName, quirk) => {
                if (getReasonToNotRemove(quirkName) !== undefined) {
                  return;
                }

                withQuirkDebounce(() => {
                  setSelectedQuirks(
                    selectedQuirks.filter((otherQuirk) => quirkName !== otherQuirk),
                  );

                  act('remove_quirk', { quirk: quirk.name });
                });
              }}
              quirks={quirks
                .filter(([quirkName, _]) => {
                  return selectedQuirks.indexOf(quirkName) !== -1;
                })
                .map(([quirkName, quirk]) => {
                  return [
                    quirkName,
                    {
                      ...quirk,
                      failTooltip: getReasonToNotRemove(quirkName),
                    },
                  ];
                })}
              serverData={server_data}
              randomBodyEnabled={randomBodyEnabled}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

export function QuirkPersonalityPage() {
  const [contentPage, setContentPage] = useState<'quirks' | 'personality'>(
    'quirks',
  );
  const { t } = usePreferencesLocalization();

  return (
    <Stack fill vertical>
      <Stack.Item className="PreferencesMenu__Quirks__TopTabsContainer">
        <Stack className="PreferencesMenu__Quirks__TopTabs">
          <Stack.Item grow>
            <Button
              className="PreferencesMenu__Quirks__TopTabButton"
              selected={contentPage === 'quirks'}
              onClick={() => setContentPage('quirks')}
              fluid
              align="center"
              fontSize="14px"
            >
              {t('ui.character.tab_quirks')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              className="PreferencesMenu__Quirks__TopTabButton"
              selected={contentPage === 'personality'}
              onClick={() => setContentPage('personality')}
              fluid
              align="center"
              fontSize="14px"
            >
              {t('ui.character.tab_personality')}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {contentPage === 'personality' ? <PersonalityPage /> : <QuirkPage />}
      </Stack.Item>
    </Stack>
  );
}
