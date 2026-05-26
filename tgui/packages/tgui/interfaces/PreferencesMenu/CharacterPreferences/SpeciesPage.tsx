import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import {
  createSetPreference,
  Food,
  type Perk,
  type PreferencesMenuData,
  type ServerData,
  type Species,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { usePreferencesLocalization } from './localization';

const FOOD_ICONS = {
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'bacon',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'bread-slice',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'hamburger',
  [Food.Nuts]: 'seedling',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Stone]: 'gem',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Bugs]: 'ui.character.food_bugs',
  [Food.Cloth]: 'ui.character.food_clothing',
  [Food.Dairy]: 'ui.character.food_dairy',
  [Food.Fried]: 'ui.character.food_fried',
  [Food.Fruit]: 'ui.character.food_fruit',
  [Food.Gore]: 'ui.character.food_gore',
  [Food.Grain]: 'ui.character.food_grain',
  [Food.Gross]: 'ui.character.food_gross',
  [Food.Junkfood]: 'ui.character.food_junk',
  [Food.Meat]: 'ui.character.food_meat',
  [Food.Nuts]: 'ui.character.food_nuts',
  [Food.Raw]: 'ui.character.food_raw',
  [Food.Seafood]: 'ui.character.food_seafood',
  [Food.Stone]: 'ui.character.food_rocks',
  [Food.Sugar]: 'ui.character.food_sugar',
  [Food.Toxic]: 'ui.character.food_toxic',
  [Food.Vegetables]: 'ui.character.food_vegetables',
};

const IGNORE_UNLESS_LIKED: Set<Food> = new Set([
  Food.Bugs,
  Food.Cloth,
  Food.Gross,
  Food.Toxic,
]);

function notIn<T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
}

type FoodListProps = {
  food: Food[];
  icon: string;
  name: string;
  className: string;
};

function FoodList(props: FoodListProps) {
  const { t } = usePreferencesLocalization();
  const { food = [], icon, name, className } = props;

  if (food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={icon} /> <b>{name}</b>
          <Divider />
          <Box>
            {food
              .reduce<string[]>((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(t(foodName)) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }
    >
      <Stack ml={2}>
        {food.map((food) => {
          return (
            FOOD_ICONS[food] && (
              <Stack.Item>
                <Icon
                  className={className}
                  size={1.4}
                  key={food}
                  name={FOOD_ICONS[food]}
                />
              </Stack.Item>
            )
          );
        })}
      </Stack>
    </Tooltip>
  );
}

type DietProps = {
  diet: Species['diet'];
};

function Diet(props: DietProps) {
  const { t } = usePreferencesLocalization();
  const { diet } = props;
  if (!diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = diet;

  return (
    <Stack>
      <Stack.Item>
        <FoodList
          food={liked_food}
          icon="heart"
          name={t('ui.character.species_liked_food')}
          className="color-pink"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="thumbs-down"
          name={t('ui.character.species_disliked_food')}
          className="color-red"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="biohazard"
          name={t('ui.character.species_toxic_food')}
          className="color-olive"
        />
      </Stack.Item>
    </Stack>
  );
}

type SpeciesPerkProps = {
  className: string;
  perk: Perk;
};

function SpeciesPerk(props: SpeciesPerkProps) {
  const { className, perk } = props;
  const { localizeDataLabelById } = usePreferencesLocalization();

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Box as="b">
            {localizeDataLabelById(
              `perk_${perk.ui_icon}_name`,
              perk.name,
            )}
          </Box>
          <Divider />
          <Box>
            {localizeDataLabelById(
              `perk_${perk.ui_icon}_description`,
              perk.description,
            )}
          </Box>
        </Box>
      }
    >
      <Box className={className} width="32px" height="32px">
        <Icon
          name={perk.ui_icon}
          size={1.5}
          ml={0}
          mt={1}
          style={{
            textAlign: 'center',
            height: '100%',
            width: '100%',
          }}
        />
      </Box>
    </Tooltip>
  );
}

type SpeciesPerksProps = {
  perks: Species['perks'];
};

function SpeciesPerks(props: SpeciesPerksProps) {
  const { positive, negative, neutral } = props.perks;

  return (
    <Stack fill justify="space-between">
      <Stack.Item>
        <Stack>
          {positive.map((perk) => {
            return (
              <Stack.Item key={perk.name}>
                <SpeciesPerk className="color-bg-green" perk={perk} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack>
        {neutral.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-grey" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>

      <Stack>
        {negative.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-red" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
}

type SpeciesPageInnerProps = {
  handleClose: () => void;
  species: ServerData['species'];
};

function SpeciesPageInner(props: SpeciesPageInnerProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabelById } =
    usePreferencesLocalization(data);
  const setSpecies = createSetPreference(act, 'species');

  const species: [string, Species][] = Object.entries(props.species).map(
    ([species, data]) => {
      return [species, data];
    },
  );

  // Humans are always the top of the list
  const humanIndex = species.findIndex(([species]) => species === 'human');
  const swapWith = species[0];
  species[0] = species[humanIndex];
  species[humanIndex] = swapWith;

  const currentSpecies = species.filter(([speciesKey]) => {
    return speciesKey === data.character_preferences.misc.species;
  })[0][1];

  return (
    <Stack vertical fill className="PreferencesMenu__Character__Species">
      <Stack.Item>
        <Button
          className="PreferencesMenu__Character__SpeciesBackButton"
          icon="arrow-left"
          onClick={props.handleClose}
        >
          {t('ui.character.species_go_back')}
        </Button>
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <Box
              className="PreferencesMenu__Character__SpeciesList"
              height="calc(100vh - 170px)"
              overflowY="auto"
              pr={3}
            >
              {species.map(([speciesKey, species]) => {
                // NOVA EDIT START - Nova star-only species
                let speciesPage = (
                  <Button
                    className="PreferencesMenu__Character__SpeciesCard"
                    key={speciesKey}
                    onClick={() => {
                      if (species.nova_stars_only && !data.is_nova_star) {
                        return;
                      }
                      setSpecies(speciesKey);
                    }}
                    selected={
                      data.character_preferences.misc.species === speciesKey
                    }
                    tooltip={localizeDataLabelById(
                      `species_${speciesKey}_name`,
                      species.name,
                    )}
                    style={{
                      display: 'block',
                      height: '64px',
                      width: '64px',
                    }}
                  >
                    <Box
                      className={classes(['species64x64', species.icon])}
                      ml={-1}
                    />
                  </Button>
                );
                if (species.nova_stars_only && !data.is_nova_star) {
                  const tooltipContent =
                    localizeDataLabelById(
                      `species_${speciesKey}_name`,
                      species.name,
                    ) +
                    ` - ${t('ui.character.species_nova_only_tooltip')}`;
                  speciesPage = (
                    <Tooltip content={tooltipContent}>{speciesPage}</Tooltip>
                  );
                }
                return speciesPage;
                // NOVA EDIT END
              })}
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Box>
              <Box>
                <Stack fill>
                  <Stack.Item width="70%">
                    <Section
                      className="PreferencesMenu__Character__SpeciesInfo"
                      title={localizeDataLabelById(
                        `species_${data.character_preferences.misc.species}_name`,
                        currentSpecies.name,
                      )}
                      buttons={
                        // NOHUNGER species have no diet (diet = null),
                        // so we have nothing to show
                        currentSpecies.diet && (
                          <Diet diet={currentSpecies.diet} />
                        )
                      }
                    >
                      {/* NOVA EDIT CHANGE START - Adds maxHeight, scrollable*/}
                      <Section
                        className="PreferencesMenu__Character__SpeciesSubsection"
                        title={t('ui.character.species_description')}
                        maxHeight="14vh"
                        scrollable
                      >
                        {/* NOVA EDIT CHANGE END */}
                        {localizeDataLabelById(
                          `species_${data.character_preferences.misc.species}_description`,
                          currentSpecies.desc,
                        )}
                      </Section>

                      <Section
                        className="PreferencesMenu__Character__SpeciesSubsection"
                        title={t('ui.character.species_features')}
                      >
                        <SpeciesPerks perks={currentSpecies.perks} />
                      </Section>
                    </Section>
                  </Stack.Item>

                  <Stack.Item width="30%">
                    <Box height="352px" width="272px" mx="auto">
                      <CharacterPreview
                        height="100%"
                        width="100%"
                        id={data.character_preview_view}
                      />
                    </Box>
                  </Stack.Item>
                </Stack>
              </Box>

              <Box mt={1}>
                <Section
                  className="PreferencesMenu__Character__SpeciesLore"
                  title={t('ui.character.species_lore')}
                >
                  <BlockQuote /* NOVA EDIT START - scrollable lore */
                    overflowY="auto"
                    maxHeight="45vh"
                    mr={-1} /* NOVA EDIT END */
                  >
                    {currentSpecies.lore.map((text, index) => (
                      <Box key={index} maxWidth="100%">
                        {localizeDataLabelById(
                          `species_${data.character_preferences.misc.species}_lore_${index}`,
                          text,
                        )}
                        {index !== currentSpecies.lore.length - 1 && (
                          <>
                            <br />
                            <br />
                          </>
                        )}
                      </Box>
                    ))}
                  </BlockQuote>
                </Section>
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

type SpeciesPageProps = {
  closeSpecies: () => void;
};

export function SpeciesPage(props: SpeciesPageProps) {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <SpeciesPageInner
      handleClose={props.closeSpecies}
      species={serverData.species}
    />
  );
}
