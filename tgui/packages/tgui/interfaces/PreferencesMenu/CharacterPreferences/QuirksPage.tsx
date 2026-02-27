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

  const [customizationExpanded, setCustomizationExpanded] = useState(false);

  const className = 'PreferencesMenu__Quirks__QuirkList__quirk';

  const child = (
    <Box
      className={className}
      style={{
        opacity: props.quirkActionLocked ? 0.6 : 1,
        pointerEvents: props.quirkActionLocked ? 'none' : 'auto',
      }}
      onClick={() => {
        if (quirkActionLocked) return;
        if (selected) {
          setCustomizationExpanded(false);
        }

        handleClick(quirkKey, quirk);
      }}
    >
      <Stack fill g={0}>
        <Stack.Item
          align="stretch"
          className={`${className}__iconcell ${className}__iconcell--${getColorValueClass(quirk)}`}
          style={{
            minWidth: '15%',
            maxWidth: '15%',
            textAlign: 'center',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Icon color="#f0f3f8" fontSize={3} name={icon} />
        </Stack.Item>

        <Stack.Item
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
                  <b>{name}</b>
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
              {description}
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
            tooltip="Customize"
            style={{
              float: 'right',
            }}
          />
        )}
      </div>
    </Floating>
  );
}

function QuirkPage() {
  const { act, data } = useBackend<PreferencesMenuData>();

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
  quirks.sort(([_, quirkA], [__, quirkB]) => {
    if (quirkA.value === quirkB.value) {
      return quirkA.name > quirkB.name ? 1 : -1;
    } else {
      return quirkA.value - quirkB.value;
    }
  });

  const quirkPoints = data.quirks_balance;
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

  const availableQuirkPoints = Math.max(0, quirkPoints);

  function getReasonToNotAdd(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (quirk.value > 0) {
      if (maxPositiveQuirks !== -1 && positiveQuirks >= maxPositiveQuirks) {
        return "You can't have any more positive quirks!";
      } else if (pointsEnabled && quirkPoints - quirk.value < 0) {
        return 'You need a negative quirk to balance this out!';
      }
    }
    // NOVA EDIT START - Nova star quirks
    if (quirk.nova_stars_only && !data.is_nova_star) {
      return 'You need to be a Nova star to select this quirk, apply today!';
    }
    // NOVA EDIT END
    const selectedQuirkNames = selectedQuirks.map((quirkKey) => {
      return quirkInfo[quirkKey].name;
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
          return `This is incompatible with ${incompatibleQuirk}!`;
        }
      }
    }
    if (data.species_disallowed_quirks.includes(quirk.name)) {
      return 'This quirk is incompatible with your selected species.';
    }
    return;
  }

  function getReasonToNotRemove(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (pointsEnabled && quirkPoints + quirk.value < 0) {
      return 'You need to remove a positive quirk first!';
    }

    return;
  }

  return (
    <Stack fill className="PreferencesMenu__Quirks">
      <Stack.Item basis="50%">
        <Stack
          vertical
          fill
          align="center"
          className="PreferencesMenu__Quirks__Column PreferencesMenu__Quirks__Column--available"
        >
          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <Box
                px={2}
                py={0.4}
                bold
                style={{
                  border: '1px solid #58c98a',
                  borderRadius: '6px',
                  background:
                    'linear-gradient(180deg, rgba(24,60,42,0.85) 0%, rgba(16,38,28,0.95) 100%)',
                  color: '#bdf9d7',
                  textShadow: '0 0 4px rgba(120,255,190,0.35)',
                }}
              >
                Positive Quirks
              </Box>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <Box
                px={3}
                py={0.5}
                bold
                fontSize="1.2em"
                style={{
                  border: '1px solid #58c98a',
                  borderRadius: '4px',
                  backgroundColor: 'rgba(10, 26, 18, 0.95)',
                  color: '#d5ffe8',
                }}
              >
                {positiveQuirks} / {maxPositiveQuirks}
              </Box>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            <Box
              as="b"
              fontSize="1.35em"
              px={2}
              py={0.4}
              style={{
                border: '1px solid #9a9a9a',
                borderRadius: '6px',
                background:
                  'linear-gradient(180deg, rgba(58,58,58,0.85) 0%, rgba(34,34,34,0.95) 100%)',
                color: '#f2f2f2',
                textShadow: '0 0 4px rgba(255,255,255,0.15)',
              }}
            >
              Available Quirks
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Box className="PreferencesMenu__Quirks__SearchInput">
              <Input
                placeholder="Search quirks..."
                width="230px"
                value={searchQuery}
                onChange={setSearchQuery}
              />
            </Box>
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
        <Box
          px={2}
          py={1}
          style={{
            minWidth: '130px',
            border: '1px solid #b08f54',
            borderRadius: '8px',
            background:
              'linear-gradient(180deg, rgba(56,44,26,0.9) 0%, rgba(34,27,16,0.95) 100%)',
            boxShadow: '0 0 8px rgba(176,143,84,0.25)',
            textAlign: 'center',
          }}
        >
          <Box bold color="#f4deb4" style={{ letterSpacing: '0.4px' }}>
            Quirk Points
          </Box>
          <Box
            mt={0.3}
            bold
            fontSize="1.5em"
            color={availableQuirkPoints > 0 ? '#b7ffcf' : '#ffd4d4'}
            style={{
              textShadow:
                availableQuirkPoints > 0
                  ? '0 0 6px rgba(90,255,150,0.45)'
                  : '0 0 6px rgba(255,90,90,0.45)',
            }}
          >
            {availableQuirkPoints}
          </Box>
        </Box>
      </Stack.Item>

      <Stack.Item basis="50%">
        <Stack
          vertical
          fill
          align="center"
          className="PreferencesMenu__Quirks__Column PreferencesMenu__Quirks__Column--current"
        >
          <Stack.Item>
            {pointsEnabled ? (
              <Box
                px={2}
                py={0.4}
                bold
                style={{
                  border: '1px solid #d1a85d',
                  borderRadius: '6px',
                  background:
                    'linear-gradient(180deg, rgba(70,50,22,0.85) 0%, rgba(45,31,13,0.95) 100%)',
                  color: '#ffe2af',
                  textShadow: '0 0 4px rgba(255,220,140,0.3)',
                }}
              >
                Quirk Points
              </Box>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            {pointsEnabled ? (
              <Box
                px={3}
                py={0.5}
                bold
                fontSize="1.2em"
                style={{
                  border: '1px solid #d1a85d',
                  borderRadius: '4px',
                  backgroundColor: 'rgba(30, 20, 8, 0.95)',
                  color: '#ffecc9',
                }}
              >
                {availableQuirkPoints}
              </Box>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            <Box
              as="b"
              fontSize="1.35em"
              px={2}
              py={0.4}
              style={{
                border: '1px solid #9a9a9a',
                borderRadius: '6px',
                background:
                  'linear-gradient(180deg, rgba(58,58,58,0.85) 0%, rgba(34,34,34,0.95) 100%)',
                color: '#f2f2f2',
                textShadow: '0 0 4px rgba(255,255,255,0.15)',
              }}
            >
              Current Quirks
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
                    selectedQuirks.filter(
                      (otherQuirk) => quirkName !== otherQuirk,
                    ),
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
              Quirks
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
              Personality
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
