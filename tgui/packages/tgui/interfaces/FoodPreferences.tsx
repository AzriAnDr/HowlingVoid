import '../styles/interfaces/FoodPreferences.scss';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Section,
  Stack,
  StyleableSection,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  food_types: Record<string, number>;
  obscure_food_types: string;
  selection: Record<string, number>;
  enabled: boolean;
  invalid: string;
  race_disabled: boolean;
  limits: Record<string, number>;
  counts: Record<string, number>;
};

const FOOD_TOXIC = 1;
const FOOD_DISLIKED = 2;
const FOOD_NEUTRAL = 3;
const FOOD_LIKED = 4;

const FOOD_NAME_KEY_BY_ID: Record<string, string> = {
  Meat: 'ui.food_preferences.food.meat',
  Vegetables: 'ui.food_preferences.food.vegetables',
  'Raw food': 'ui.food_preferences.food.raw_food',
  'Junk food': 'ui.food_preferences.food.junk_food',
  Grain: 'ui.food_preferences.food.grain',
  Fruits: 'ui.food_preferences.food.fruits',
  'Dairy products': 'ui.food_preferences.food.dairy_products',
  'Fried food': 'ui.food_preferences.food.fried_food',
  Alcohol: 'ui.food_preferences.food.alcohol',
  'Sugary food': 'ui.food_preferences.food.sugary_food',
  'Gross food': 'ui.food_preferences.food.gross_food',
  'Toxic food': 'ui.food_preferences.food.toxic_food',
  Pineapples: 'ui.food_preferences.food.pineapples',
  'Breakfast food': 'ui.food_preferences.food.breakfast_food',
  Clothing: 'ui.food_preferences.food.clothing',
  Nuts: 'ui.food_preferences.food.nuts',
  Seafood: 'ui.food_preferences.food.seafood',
  Oranges: 'ui.food_preferences.food.oranges',
  Bugs: 'ui.food_preferences.food.bugs',
  Gore: 'ui.food_preferences.food.gore',
  Bloody: 'ui.food_preferences.food.bloody',
};

export const FoodPreferences = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const {
    counts,
    limits,
    obscure_food_types,
    invalid,
    selection,
    enabled,
    race_disabled,
    food_types,
  } = data;

  return (
    <Window width={1300} height={600}>
      <Window.Content scrollable>
        <Box className="FoodPreferences">
          <StyleableSection
            style={{
              'margin-bottom': '1em',
              'break-inside': 'avoid-column',
            }}
            titleStyle={{
              'justify-content': 'center',
            }}
            title={
              <Box>
                <Tooltip position="bottom" content={t('ui.food_preferences.rules_tooltip')}>
                  <Box inline>
                    <Button icon="circle-question" mr="0.5em" />
                    {invalid ? (
                      <Box as="span" color="#bd2020">
                        {t('ui.food_preferences.invalid_preferences')}{' '}
                        {invalid.charAt(0).toUpperCase() + invalid.slice(1)} |{' '}
                        {counts.disliked < 2
                          ? `${counts.disliked}/2 ${t('ui.food_preferences.disliked_count_label')}`
                          : `${counts.toxic}/1 ${t('ui.food_preferences.toxic_count_label')}`}
                      </Box>
                    ) : (
                      <Box as="span" color="green">
                        {t('ui.food_preferences.valid_preferences')} | <b>{counts.liked}</b>/3{' '}
                        {t('ui.food_preferences.liked_count_label')}
                      </Box>
                    )}
                  </Box>
                </Tooltip>

                <Button
                  className="FoodPreferences__TopButton"
                  style={{ position: 'absolute', right: '20em' }}
                  color="red"
                  onClick={() => act('reset')}
                  tooltip={t('ui.food_preferences.reset_tooltip')}
                >
                  {t('ui.common.reset')}
                </Button>

                <Button
                  className="FoodPreferences__TopButton"
                  style={{ position: 'absolute', right: '0.5em' }}
                  icon={enabled ? 'check-square-o' : 'square-o'}
                  color={enabled ? 'green' : 'red'}
                  onClick={() => act('toggle')}
                  disabled={race_disabled}
                  tooltip={
                    <>
                      {t('ui.food_preferences.toggle_help_primary')}
                      <Divider />
                      {t('ui.food_preferences.toggle_help_secondary')}
                    </>
                  }
                >
                  {t('ui.food_preferences.use_custom_food_preferences')}
                </Button>
              </Box>
            }
          >
            {(race_disabled && <ErrorOverlay>{t('ui.food_preferences.race_disabled')}</ErrorOverlay>) ||
              (!enabled && (
                <ErrorOverlay>{t('ui.food_preferences.preferences_disabled')}</ErrorOverlay>
              ))}
            <Box style={{ columns: '30em' }}>
              {Object.entries(food_types).map((element) => {
                const { 0: foodName, 1: foodPointValues } = element;
                return (
                  <Box key={foodName}>
                    <Section
                      title={
                        <>
                          {t(FOOD_NAME_KEY_BY_ID[foodName] || '', foodName)}
                          {obscure_food_types.includes(foodName) && (
                            <Tooltip content={t('ui.food_preferences.obscure_food_type_tooltip')}>
                              <Box as="span" fontSize={0.75} verticalAlign="top">
                                &nbsp;
                                <Icon name="star" style={{ color: 'orange' }} />
                              </Box>
                            </Tooltip>
                          )}
                        </>
                      }
                    >
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_TOXIC}
                        selected={
                          selection[foodName] === FOOD_TOXIC ||
                          (!selection[foodName] && foodPointValues === FOOD_TOXIC)
                        }
                        content={<>{t('ui.food_preferences.preference_toxic')}</>}
                        color="olive"
                        tooltip={t('ui.food_preferences.preference_toxic_tooltip')}
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_DISLIKED}
                        disabled={
                          !obscure_food_types.includes(foodName) && counts.toxic < limits.min_toxic
                        }
                        selected={
                          selection[foodName] === FOOD_DISLIKED ||
                          (!selection[foodName] && foodPointValues === FOOD_DISLIKED)
                        }
                        content={<>{t('ui.food_preferences.preference_disliked')}</>}
                        color="red"
                        tooltip={t('ui.food_preferences.preference_disliked_tooltip')}
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_NEUTRAL}
                        disabled={
                          (!obscure_food_types.includes(foodName) && counts.toxic < limits.min_toxic) ||
                          (!obscure_food_types.includes(foodName) &&
                            counts.disliked < limits.min_disliked)
                        }
                        selected={
                          selection[foodName] === FOOD_NEUTRAL ||
                          (!selection[foodName] && foodPointValues === FOOD_NEUTRAL)
                        }
                        content={<>{t('ui.food_preferences.preference_neutral')}</>}
                        color="yellow"
                        tooltip={t('ui.food_preferences.preference_neutral_tooltip')}
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_LIKED}
                        disabled={
                          (!obscure_food_types.includes(foodName) &&
                            counts.liked >= limits.max_liked) ||
                          (!obscure_food_types.includes(foodName) &&
                            counts.disliked < limits.min_disliked) ||
                          (!obscure_food_types.includes(foodName) && counts.toxic < limits.min_toxic)
                        }
                        selected={
                          selection[foodName] === FOOD_LIKED ||
                          (!selection[foodName] && foodPointValues === FOOD_LIKED)
                        }
                        content={<>{t('ui.food_preferences.preference_liked')}</>}
                        color="green"
                        tooltip={
                          !obscure_food_types.includes(foodName) && counts.liked >= 3
                            ? t('ui.food_preferences.preference_liked_limit_tooltip')
                            : t('ui.food_preferences.preference_liked_tooltip')
                        }
                      />
                    </Section>
                  </Box>
                );
              })}
            </Box>
          </StyleableSection>
        </Box>
      </Window.Content>
    </Window>
  );
};

const FoodButton = (props) => {
  const { act } = useBackend();
  const { foodName, foodPreference, color, selected, ...rest } = props;
  return (
    <Button
      className="FoodPreferences__ChoiceButton"
      icon={selected ? 'check-square-o' : 'square-o'}
      color={selected ? color : 0x3e6189}
      onClick={() =>
        act('change_food', {
          food_name: foodName,
          food_preference: foodPreference,
        })
      }
      {...rest}
    />
  );
};

const ErrorOverlay = (props) => {
  return (
    <Dimmer>
      <Stack vertical mt="5.2em">
        <Stack.Item color="#bd2020" textAlign="center">
          {props.children}
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
