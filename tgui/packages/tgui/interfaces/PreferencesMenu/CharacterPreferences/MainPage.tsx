import { sortBy } from 'es-toolkit';
import { filter, map } from 'es-toolkit/compat';
import { type ReactNode, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { sendAct } from 'tgui/events/act';
import {
  Box,
  Button,
  Collapsible,
  Floating,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive'; // NOVA EDIT ADDITION
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';
import { CharacterPreview } from '../../common/CharacterPreview';
import { PageButton } from '../components/PageButton'; // NOVA EDIT ADDITION
import { RandomizationButton } from '../components/RandomizationButton';
import { SideDropdown } from '../components/SideDropdown'; // NOVA EDIT ADDITION
import { features } from '../preferences/features';
import {
  type FeatureChoicedServerData,
  FeatureValueInput,
} from '../preferences/features/base';
import { GENDERS, Gender } from '../preferences/gender';
import {
  createSetPreference,
  type PreferencesMenuData,
  RandomSetting,
  type ServerData,
} from '../types';
import { useRandomToggleState } from '../useRandomToggleState';
import { useServerPrefs } from '../useServerPrefs';
import { DeleteCharacterPopup } from './DeleteCharacterPopup';
import { usePreferencesLocalization } from './localization';
import { MultiNameInput, NameInput } from './names';
import { VocalsInput, VoiceInput } from './vocals'; // NOVA EDIT ADDITION

const CLOTHING_CELL_SIZE = 48;
const CLOTHING_SIDEBAR_ROWS = 13.4; // NOVA EDIT CHANGE - ORIGINAL:  9

const CLOTHING_SELECTION_CELL_SIZE = 48;
const CLOTHING_SELECTION_WIDTH = 5.4;
const CLOTHING_SELECTION_MULTIPLIER = 5.2;
const HIDDEN_FEATURE_IDS = new Set(['allow_genitals_toggle']);
const GENITAL_FEATURE_IDS = new Set([
  'feature_anus',
  'feature_belly',
  'belly_size',
  'belly_skin_tone',
  'belly_skin_color',
  'belly_color',
  'belly_emissive',
  'feature_breasts',
  'feature_butt',
  'butt_size',
  'butt_skin_tone',
  'butt_skin_color',
  'butt_color',
  'butt_emissive',
  'feature_penis',
  'feature_testicles',
  'feature_vagina',
  'feature_womb',
  'balls_size',
]);

const GENITAL_FEATURE_PREFIXES = [
  'penis_',
  'testicles_',
  'vagina_',
  'breasts_',
];

const NON_HUMAN_FEATURE_IDS = new Set([
  'caps_toggle',
  'feature_caps',
  'ears_toggle',
  'feature_ears',
  'fluff_toggle',
  'feature_fluff',
  'frills_toggle',
  'feature_frills',
  'horns_toggle',
  'feature_horns',
  'digitigrade_legs',
  'feature_leg_type',
  'moth_antennae_toggle',
  'feature_moth_antennae',
  'neck_acc_toggle',
  'feature_neck_acc',
  'skrell_hair_toggle',
  'feature_skrell_hair',
  'snout_toggle',
  'feature_snout',
  'spines_toggle',
  'feature_spines',
  'ipc_antenna_toggle',
  'feature_ipc_antenna',
  'tail_toggle',
  'feature_tail',
  'taur_toggle',
  'feature_taur',
  'naga_sole',
  'wings_toggle',
  'feature_wings',
  'xenohead_toggle',
  'feature_xenohead',
  'xenodorsal_toggle',
  'feature_xenodorsal',
]);

const NON_HUMAN_FEATURE_PREFIXES = [
  'caps_',
  'ears_',
  'fluff_',
  'frills_',
  'horns_',
  'moth_antennae_',
  'neck_acc_',
  'skrell_hair_',
  'snout_',
  'spines_',
  'ipc_antenna_',
  'tail_',
  'taur_',
  'xenohead_',
  'xenodorsal_',
  'feature_caps',
  'feature_ears',
  'feature_fluff',
  'feature_frills',
  'feature_horns',
  'feature_leg_type',
  'feature_moth_antennae',
  'feature_neck_acc',
  'feature_skrell_hair',
  'feature_snout',
  'feature_spines',
  'feature_ipc_antenna',
  'feature_tail',
  'feature_taur',
  'feature_wings',
  'feature_xenohead',
  'feature_xenodorsal',
];

function isGenitalFeature(featureId: string) {
  return (
    GENITAL_FEATURE_IDS.has(featureId) ||
    GENITAL_FEATURE_PREFIXES.some((prefix) => featureId.startsWith(prefix))
  );
}

function isHiddenFeature(featureId: string) {
  return HIDDEN_FEATURE_IDS.has(featureId);
}

function isNonHumanFeature(featureId: string) {
  return (
    NON_HUMAN_FEATURE_IDS.has(featureId) ||
    NON_HUMAN_FEATURE_PREFIXES.some((prefix) => featureId.startsWith(prefix))
  );
}

type CharacterControlsProps = {
  t: (key: string, fallback?: string) => string;
  handleRotate: (backwards: boolean) => void; // NOVA EDIT CHANGE - Original: handleRotate: () => void;
  handleOpenSpecies: () => void;
  handleFood: () => void; // NOVA EDIT ADDITION
  gender: Gender;
  setGender: (gender: Gender) => void;
  showGender: boolean;
  canDeleteCharacter: boolean;
  handleDeleteCharacter: () => void;
};

function CharacterControls(props: CharacterControlsProps) {
  return (
    <Stack>
      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__IconButton"
          onClick={() => props.handleRotate(false)} // NOVA EDIT CHANGE - Original: onClick={props.handleRotate}
          fontSize="22px"
          icon="undo"
          tooltip={props.t('ui.character.rotate')}
          tooltipPosition="top"
        />
      </Stack.Item>

      {/* NOVA EDIT ADDITION START */}
      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__IconButton"
          onClick={() => props.handleRotate(true)}
          fontSize="22px"
          icon="redo"
          tooltip={props.t('ui.character.rotate')}
          tooltipPosition="top"
        />
      </Stack.Item>
      {/* NOVA EDIT ADDITION END */}

      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__IconButton"
          onClick={props.handleOpenSpecies}
          fontSize="22px"
          icon="paw"
          tooltip={props.t('ui.character.species')}
          tooltipPosition="top"
        />
      </Stack.Item>

      {props.showGender && (
        <Stack.Item>
          <GenderButton
            gender={props.gender}
            handleSetGender={props.setGender}
          />
        </Stack.Item>
      )}
      {/* NOVA EDIT ADDITION START */}
      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__IconButton"
          onClick={props.handleFood}
          fontSize="22px"
          icon="drumstick-bite"
          tooltip={props.t('ui.character.edit_food_preferences')}
          tooltipPosition="top"
        />
        {/* NOVA EDIT ADDITION END */}
      </Stack.Item>
      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__IconButton PreferencesMenu__Character__IconButton--delete"
          onClick={props.handleDeleteCharacter}
          fontSize="22px"
          icon="trash"
          color="red"
          tooltip={props.t('ui.character.delete_character')}
          tooltipPosition="top"
          disabled={!props.canDeleteCharacter}
        />
      </Stack.Item>
    </Stack>
  );
}

type ChoicedSelectionProps = {
  featureId: string;
  name: string;
  catalog: FeatureChoicedServerData;
  selected: string;
  supplementalFeature?: string;
  supplementalValue?: unknown;
  onSelect: (value: string) => void;
};

function ChoicedSelection(props: ChoicedSelectionProps) {
  const { t, localizeFeatureById, localizeCharacterDataById } =
    usePreferencesLocalization();
  const { catalog, supplementalFeature, supplementalValue } = props;
  const [searchText, setSearchText] = useState('');

  if (!catalog.icons) {
    return <Box color="red">{t('ui.character.catalog_missing_icons')}</Box>;
  }

  return (
    <Box
      className="ChoicedSelection"
      style={{
        height: `${
          CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_MULTIPLIER
        }px`,
        width: `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_WIDTH}px`,
      }}
    >
      <Stack fill vertical g={0}>
        <Stack.Item>
          <Section
            fill
            title={t('ui.character.select_catalog_item').replace(
              '{item}',
              localizeFeatureById(props.featureId, props.name),
            )}
            buttons={
              supplementalFeature && (
                <FeatureValueInput
                  shrink
                  feature={features[supplementalFeature]}
                  featureId={supplementalFeature}
                  value={supplementalValue}
                />
              )
            }
          >
            <Input
              autoFocus
              fluid
              placeholder={t('ui.character.search_placeholder')}
              onChange={setSearchText}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable noTopPadding>
            <Stack wrap>
              {searchInCatalog(searchText, catalog.icons).map(
                ([name, image], index) => {
                  return (
                    <Button
                      key={index}
                      onClick={() => {
                        props.onSelect(name);
                      }}
                      selected={name === props.selected}
                      tooltip={localizeCharacterDataById(
                        `${props.featureId}_choice_${name}`,
                        name,
                      )}
                      tooltipPosition="right"
                      style={{
                        height: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                        width: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                      }}
                    >
                      <Box
                        className={classes([
                          'preferences32x32',
                          image,
                          'centered-image',
                        ])}
                        style={{
                          transform:
                            'translateX(-50%) translateY(-50%) scale(0.8)',
                        }}
                      />
                    </Button>
                  );
                },
              )}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Box>
  );
}

function searchInCatalog(searchText = '', catalog: Record<string, string>) {
  let items = Object.entries(catalog);
  if (searchText) {
    items = filter(
      items,
      createSearch(searchText, ([name, _icon]) => name),
    );
  }
  return items;
}

type GenderButtonProps = {
  handleSetGender: (gender: Gender) => void;
  gender: Gender;
};

function GenderButton(props: GenderButtonProps) {
  const { t, localizeGender } = usePreferencesLocalization();
  return (
    <Floating
      placement="right"
      contentClasses="PreferencesMenu__Character__GenderPopover"
      content={
        <Stack p={0.3}>
          {[Gender.Male, Gender.Female, Gender.Other, Gender.Other2].map(
            (gender) => {
              return (
                <Stack.Item key={gender}>
                  <Button
                    className="PreferencesMenu__Character__IconButton"
                    selected={gender === props.gender}
                    onClick={() => {
                      props.handleSetGender(gender);
                    }}
                    fontSize="22px"
                    icon={GENDERS[gender].icon}
                    tooltip={localizeGender(gender)}
                    tooltipPosition="top"
                  />
                </Stack.Item>
              );
            },
          )}
        </Stack>
      }
    >
      <div>
        <Button
          className="PreferencesMenu__Character__IconButton"
          fontSize="22px"
          icon={GENDERS[props.gender].icon}
          tooltip={t('ui.character.gender')}
          tooltipPosition="top"
        />
      </div>
    </Floating>
  );
}

type CatalogItem = {
  name: string;
  supplemental_feature?: string;
};

type MainFeatureProps = {
  featureId: string;
  catalog: FeatureChoicedServerData & CatalogItem;
  currentValue: string;
  handleSelect: (newClothing: string) => void;
  randomization?: RandomSetting;
  setRandomization: (newSetting: RandomSetting) => void;
};

function MainFeature(props: MainFeatureProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const {
    featureId,
    catalog,
    currentValue,
    handleSelect,
    randomization,
    setRandomization,
  } = props;

  const supplementalFeature = catalog.supplemental_feature;

  return (
    <Floating
      stopChildPropagation
      placement="right-start"
      content={
        <ChoicedSelection
          featureId={featureId}
          name={catalog.name}
          catalog={catalog}
          selected={currentValue}
          supplementalFeature={supplementalFeature}
          supplementalValue={
            supplementalFeature &&
            data.character_preferences.supplemental_features[
              supplementalFeature
            ]
          }
          onSelect={handleSelect}
        />
      }
    >
      <Button
        style={{
          height: `${CLOTHING_CELL_SIZE}px`,
          width: `${CLOTHING_CELL_SIZE}px`,
        }}
        position="relative"
      >
        <Box
          className={classes([
            'preferences32x32',
            catalog.icons![currentValue],
            'centered-image',
          ])}
          style={{
            transform: randomization
              ? 'translateX(-70%) translateY(-70%) scale(1.1)'
              : 'translateX(-50%) translateY(-50%) scale(1.3)',
          }}
        />

        {randomization && (
          <RandomizationButton
            dropdownProps={{
              dropdownStyle: {
                bottom: 0,
                position: 'absolute',
                right: '1px',
              },

              onOpen: (event) => {
                // We're a button inside a button.
                // Did you know that's against the W3C standard? :)
                // FIXME: Button unclickable!
                event.cancelBubble = true;
                event.stopPropagation();
              },
            }}
            value={randomization}
            setValue={setRandomization}
          />
        )}
      </Button>
    </Floating>
  );
}

const createSetRandomization =
  (preference: string) => (newSetting: RandomSetting) => {
    sendAct('set_random_preference', {
      preference,
      value: newSetting,
    });
  };

function sortPreferences(array: [string, unknown][]) {
  return sortBy(array, [([featureId]) => features[featureId]?.name]);
}

type PreferenceListProps = {
  preferences: Record<string, unknown>;
  randomizations: Record<string, RandomSetting>;
  maxHeight: string;
  children?: ReactNode;
};

export function PreferenceList(props: PreferenceListProps) {
  const { localizeFeatureById, localizeFeatureDescriptionById, t } =
    usePreferencesLocalization();
  const { preferences, randomizations, maxHeight, children } = props;

  return (
    <Stack.Item
      basis="50%"
      grow
      style={{
        background: 'rgba(0, 0, 0, 0.5)',
        padding: '4px',
      }}
      overflowX="hidden"
      overflowY="auto"
      maxHeight={maxHeight}
    >
      <LabeledList>
        {sortPreferences(Object.entries(preferences)).map(
          ([featureId, value]) => {
            const feature = features[featureId];
            const randomSetting = randomizations[featureId];

            if (feature === undefined) {
              return (
                <Stack.Item key={featureId}>
                  <b>
                    {t('ui.character.feature_not_recognized').replace(
                      '{feature}',
                      featureId,
                    )}
                  </b>
                </Stack.Item>
              );
            }

            return (
              <LabeledList.Item
                key={featureId}
                // NOVA EDIT CHANGE - ORIGINAL: label={feature.name}
                label={
                  <Box mt={0.5}>
                    {localizeFeatureById(featureId, feature.name)}
                  </Box>
                } // replicate middle align
                tooltip={
                  feature.description
                    ? localizeFeatureDescriptionById(
                        featureId,
                        feature.description,
                      )
                    : undefined
                }
                verticalAlign="top" // NOVA EDIT CHANGE - Original: middle
              >
                <Stack fill>
                  {randomSetting && (
                    <Stack.Item>
                      <RandomizationButton
                        setValue={createSetRandomization(featureId)}
                        value={randomSetting}
                      />
                    </Stack.Item>
                  )}

                  <Stack.Item grow>
                    <FeatureValueInput
                      feature={feature}
                      featureId={featureId}
                      value={value}
                    />
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
            );
          },
        )}
      </LabeledList>

      {children}
    </Stack.Item>
  );
}

export function getRandomization(
  preferences: Record<string, unknown>,
  serverData: ServerData | undefined,
  randomBodyEnabled: boolean,
): Record<string, RandomSetting> {
  const { data } = useBackend<PreferencesMenuData>();

  if (!randomBodyEnabled || !serverData) {
    return {};
  }

  return Object.fromEntries(
    map(
      filter(Object.keys(preferences), (key) =>
        serverData.random.randomizable.includes(key),
      ),
      (key) => [
        key,
        data.character_preferences.randomization[key] || RandomSetting.Disabled,
      ],
    ),
  );
}

type MainPageProps = {
  openSpecies: () => void;
};

export function MainPage(props: MainPageProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeCharacterDataById } = usePreferencesLocalization(data);

  const [deleteCharacterPopupOpen, setDeleteCharacterPopupOpen] =
    useState(false);
  const [multiNameInputOpen, setMultiNameInputOpen] = useState(false);
  const [vocalsInputOpen, setVocalsInputOpen] = useState(false); // NOVA EDIT ADDITION
  const [randomToggleEnabled] = useRandomToggleState();

  const serverData = useServerPrefs();

  const currentSpeciesData =
    serverData?.species[data.character_preferences.misc.species];

  const contextualPreferences =
    data.character_preferences.secondary_features || [];

  const generalAppearancePreferences = Object.fromEntries(
    Object.entries(contextualPreferences).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) &&
        !isGenitalFeature(featureId) && !isNonHumanFeature(featureId),
    ),
  );
  const nonHumanAppearancePreferences = Object.fromEntries(
    Object.entries(contextualPreferences).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) && isNonHumanFeature(featureId),
    ),
  );
  const genitalAppearancePreferences = Object.fromEntries(
    Object.entries(contextualPreferences).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) && isGenitalFeature(featureId),
    ),
  );

  const mainFeatures = [
    ...Object.entries(data.character_preferences.clothing ?? {}),
    ...Object.entries(data.character_preferences.features ?? {}),
  ];

  const randomBodyEnabled =
    data.character_preferences.non_contextual.random_body !==
      RandomSetting.Disabled || randomToggleEnabled;

  const randomizationOfMainFeatures = getRandomization(
    Object.fromEntries(mainFeatures),
    serverData,
    randomBodyEnabled,
  );

  const contextualRandomizations = getRandomization(
    contextualPreferences,
    serverData,
    randomBodyEnabled,
  );
  const generalAppearanceRandomizations = Object.fromEntries(
    Object.entries(contextualRandomizations).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) &&
        !isGenitalFeature(featureId) && !isNonHumanFeature(featureId),
    ),
  );
  const nonHumanAppearanceRandomizations = Object.fromEntries(
    Object.entries(contextualRandomizations).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) && isNonHumanFeature(featureId),
    ),
  );
  const genitalAppearanceRandomizations = Object.fromEntries(
    Object.entries(contextualRandomizations).filter(
      ([featureId]) =>
        !isHiddenFeature(featureId) && isGenitalFeature(featureId),
    ),
  );

  const nonContextualPreferences = {
    ...data.character_preferences.non_contextual,
  };

  if (randomBodyEnabled) {
    nonContextualPreferences.random_species =
      data.character_preferences.randomization.species;
  } else {
    // We can't use random_name/is_accessible because the
    // server doesn't know whether the random toggle is on.
    delete nonContextualPreferences.random_name;
  }
  // NOVA EDIT ADDITION BEGIN: SWAPPABLE PREF MENUS
  enum PrefPage {
    Visual, // The visual parts
    Profile, // Flavor Text, Age, Records, PDA ringtone, etc
  }

  const [currentPrefPage, setCurrentPrefPage] = useState(PrefPage.Visual);

  let prefPageContents;
  switch (currentPrefPage) {
    case PrefPage.Visual:
      prefPageContents = (
        <Stack vertical fill>
          <Stack.Item>
            <Collapsible open title={t('ui.character.general_appearance')}>
              <PreferenceList
                randomizations={generalAppearanceRandomizations}
                preferences={generalAppearancePreferences}
                maxHeight="auto"
              />
            </Collapsible>
          </Stack.Item>
          {!!Object.keys(nonHumanAppearancePreferences).length && (
            <Stack.Item>
              <Collapsible open title={t('ui.character.non_human_parts')}>
                <PreferenceList
                  randomizations={nonHumanAppearanceRandomizations}
                  preferences={nonHumanAppearancePreferences}
                  maxHeight="auto"
                />
              </Collapsible>
            </Stack.Item>
          )}
          {!!Object.keys(genitalAppearancePreferences).length && (
            <Stack.Item>
              <Collapsible open title={t('ui.character.sexual_characteristics')}>
                <PreferenceList
                  randomizations={genitalAppearanceRandomizations}
                  preferences={genitalAppearancePreferences}
                  maxHeight="auto"
                />
              </Collapsible>
            </Stack.Item>
          )}
        </Stack>
      );
      break;
    case PrefPage.Profile:
      prefPageContents = (
        <PreferenceList
          randomizations={getRandomization(
            nonContextualPreferences,
            serverData,
            randomBodyEnabled,
          )}
          preferences={nonContextualPreferences}
          maxHeight="auto"
        />
      );
      break;
    default:
      exhaustiveCheck(currentPrefPage);
  }
  // NOVA EDIT ADDITION END

  return (
    <>
      <Stack className="PreferencesMenu__Character__TransferRow" mb={0.5}>
        <Stack.Item grow>
          <Button
            className="PreferencesMenu__Character__ActionButton"
            align="center"
            fluid
            icon="file-import"
            onClick={() => act('import_character')}
          >
            {t('ui.character.import_preferences', 'IMPORT PREFERENCES')}
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            className="PreferencesMenu__Character__ActionButton"
            align="center"
            fluid
            icon="file-export"
            onClick={() => act('export_preferences')}
          >
            {t('ui.character.export_preferences', 'EXPORT PREFERENCES')}
          </Button>
        </Stack.Item>
      </Stack>

      {multiNameInputOpen && (
        <MultiNameInput
          handleClose={() => setMultiNameInputOpen(false)}
          handleRandomizeName={(preference) =>
            act('randomize_name', {
              preference,
            })
          }
          handleUpdateName={(nameType, value) =>
            act('set_preference', {
              preference: nameType,
              value,
            })
          }
          names={data.character_preferences.names}
        />
      )}
      {/* NOVA EDIT ADDITION START */}
      {vocalsInputOpen && (
        <VocalsInput
          handleClose={() => setVocalsInputOpen(false)}
          vocals={data.character_preferences.vocals}
        />
      )}
      {/* NOVA EDIT ADDITION END */}

      {deleteCharacterPopupOpen && (
        <DeleteCharacterPopup
          close={() => setDeleteCharacterPopupOpen(false)}
        />
      )}

      <Stack
        className="PreferencesMenu__Character__MainLayout"
        height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}
      >
        <Stack.Item className="PreferencesMenu__Character__Sidebar">
          <Stack vertical fill>
            <Stack.Item>
              <CharacterControls
                t={t}
                gender={data.character_preferences.misc.gender}
                handleOpenSpecies={props.openSpecies}
                handleRotate={(value) => {
                  act('rotate', { backwards: value });
                }}
                setGender={createSetPreference(act, 'gender')}
                showGender={
                  currentSpeciesData ? !!currentSpeciesData.sexes : true
                }
                // NOVA EDIT ADDITION START
                handleFood={() => {
                  act('open_food');
                }}
                // NOVA EDIT ADDITION END
                canDeleteCharacter={
                  Object.values(data.character_profiles).filter(
                    (name) => !!name,
                  ).length > 1
                }
                handleDeleteCharacter={() => setDeleteCharacterPopupOpen(true)}
              />
            </Stack.Item>

            <Stack.Item grow>
              <CharacterPreview
                height="100%"
                id={data.character_preview_view}
              />
            </Stack.Item>

            {/* NOVA EDIT ADDITION START */}
            <Stack.Item position="relative">
              <SideDropdown
                className="PreferencesMenu__Character__FieldDropdown"
                width="100%"
                selected={data.preview_selection}
                displayText={
                  data.preview_option_ids?.[data.preview_selection]
                    ? localizeCharacterDataById(
                        data.preview_option_ids[data.preview_selection],
                        data.preview_selection,
                      )
                    : localizeCharacterDataById(
                        `preview_option_${data.preview_selection}`,
                        data.preview_selection,
                      )
                }
                options={data.preview_options.map((option) => ({
                  value: option,
                  displayText: data.preview_option_ids?.[option]
                    ? localizeCharacterDataById(
                        data.preview_option_ids[option],
                        option,
                      )
                    : localizeCharacterDataById(
                        `preview_option_${option}`,
                        option,
                      ),
                }))}
                onSelected={(value) =>
                  act('update_preview', {
                    updated_preview: value,
                  })
                }
              />
            </Stack.Item>
            {/* NOVA EDIT ADDITION START: Background Selection */}
            <Stack.Item position="relative">
              <SideDropdown
                className="PreferencesMenu__Character__FieldDropdown"
                width="100%"
                selected={data.character_preferences.misc.background_state}
                displayText={
                  (serverData?.background_state.choice_ids?.[
                    data.character_preferences.misc.background_state
                  ] ??
                  serverData?.background_state_ids?.[
                    data.character_preferences.misc.background_state
                  ])
                    ? localizeCharacterDataById(
                        (serverData?.background_state.choice_ids?.[
                          data.character_preferences.misc.background_state
                        ] ??
                          serverData?.background_state_ids?.[
                            data.character_preferences.misc.background_state
                          ])!,
                        data.character_preferences.misc.background_state,
                      )
                    : localizeCharacterDataById(
                        `background_state_${data.character_preferences.misc.background_state}`,
                        data.character_preferences.misc.background_state,
                      )
                }
                options={(serverData?.background_state.choices || []).map(
                  (option) => ({
                    value: option,
                    displayText:
                      (serverData?.background_state.choice_ids?.[option] ??
                      serverData?.background_state_ids?.[option])
                        ? localizeCharacterDataById(
                            (serverData?.background_state.choice_ids?.[
                              option
                            ] ?? serverData?.background_state_ids?.[option])!,
                            option,
                          )
                        : localizeCharacterDataById(
                            `background_state_${option}`,
                            option,
                          ),
                  }),
                )}
                onSelected={(value) =>
                  act('update_background', {
                    new_background: value,
                  })
                }
              />
            </Stack.Item>
            {/* NOVA EDIT ADDITION END: Background Selection */}
            {/* NOVA EDIT ADDITION END */}
            <Stack.Item position="relative">
              <NameInput
                name={data.character_preferences.names[data.name_to_use]}
                handleUpdateName={createSetPreference(act, data.name_to_use)}
                openMultiNameInput={() => {
                  setMultiNameInputOpen(true);
                }}
              />
            </Stack.Item>
            {/* NOVA EDIT ADDITION START */}
            <Stack.Item position="relative">
              <VoiceInput
                openVocalsInput={() => {
                  setVocalsInputOpen(true);
                }}
              />
            </Stack.Item>
            {/* NOVA EDIT ADDITION END */}
          </Stack>
        </Stack.Item>

        <Stack.Item className="PreferencesMenu__Character__VisualSlots">
          <Stack fill vertical wrap>
            {mainFeatures.map(([clothingKey, clothing]) => {
              const catalog = serverData?.[
                clothingKey
              ] as FeatureChoicedServerData & {
                name: string;
              };

              return (
                <Stack.Item key={clothingKey}>
                  {!catalog ? (
                    // Skeleton button
                    <Button height={4} width={4} disabled />
                  ) : (
                    <MainFeature
                      featureId={clothingKey}
                      catalog={catalog}
                      currentValue={clothing}
                      handleSelect={createSetPreference(act, clothingKey)}
                      randomization={randomizationOfMainFeatures[clothingKey]}
                      setRandomization={createSetRandomization(clothingKey)}
                    />
                  )}
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>

        {/* NOVA EDIT CHANGE: Swappable pref menus */}
        {/* ORIGINAL: <Stack.Item grow basis={0}> */}
        <Stack.Item
          className="PreferencesMenu__Character__ProfilePanel"
          grow
          basis={0}
          ml="4px"
        >
          <Stack vertical fill>
            {/* // NOVA EDIT REMOVAL START
             <PreferenceList
              randomizations={getRandomization(
                contextualPreferences,
                serverData,
                randomBodyEnabled,
              )}
              preferences={contextualPreferences}
              maxHeight="auto"
            />

            <PreferenceList
              randomizations={getRandomization(
                nonContextualPreferences,
                serverData,
                randomBodyEnabled,
              )}
              preferences={nonContextualPreferences}
              maxHeight="auto"
            />
            // NOVA EDIT REMOVAL END */}
            {/* NOVA EDIT ADDITION BEGIN: Swappable pref menus */}
            <Stack className="PreferencesMenu__Character__PrefTabs">
              <Stack.Item grow={2}>
                <PageButton
                  className="PreferencesMenu__Character__PrefTabButton"
                  currentPage={currentPrefPage}
                  page={PrefPage.Visual}
                  setPage={setCurrentPrefPage}
                >
                  {t('ui.character.character_visuals')}
                </PageButton>
              </Stack.Item>
              <Stack.Item grow={2}>
                <PageButton
                  className="PreferencesMenu__Character__PrefTabButton"
                  currentPage={currentPrefPage}
                  page={PrefPage.Profile}
                  setPage={setCurrentPrefPage}
                >
                  {t('ui.character.character_profile')}
                </PageButton>
              </Stack.Item>
            </Stack>
            <Stack.Item
              grow
              style={{
                minHeight: 0,
                overflowY: 'auto',
                overflowX: 'hidden',
              }}
            >
              {prefPageContents}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {/* NOVA EDIT ADDITION END: Swappable pref menus */}
      </Stack>
    </>
  );
}
