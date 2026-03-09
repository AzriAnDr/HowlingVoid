// THIS IS A NOVA SECTOR UI FILE
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

const FOOD_NAMES_RU: Record<string, string> = {
  Meat: 'Мясо',
  Vegetables: 'Овощи',
  'Raw food': 'Сырая еда',
  'Junk food': 'Фастфуд',
  Grain: 'Зерновые',
  Fruits: 'Фрукты',
  'Dairy products': 'Молочные продукты',
  'Fried food': 'Жареная еда',
  Alcohol: 'Алкоголь',
  'Sugary food': 'Сладкая еда',
  'Gross food': 'Отвратительная еда',
  'Toxic food': 'Токсичная еда',
  Pineapples: 'Ананасы',
  'Breakfast food': 'Еда для завтрака',
  Clothing: 'Одежда',
  Nuts: 'Орехи',
  Seafood: 'Морепродукты',
  Oranges: 'Апельсины',
  Bugs: 'Насекомые',
  Gore: 'Плоть',
  Bloody: 'Кровавая еда',
};

const foodNameRu = (name: string) => FOOD_NAMES_RU[name] || name;

export const FoodPreferences = (props) => {
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
          {
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
                <Tooltip
                  position="bottom"
                  content={
                    'Нужно выбрать минимум ОДНУ токсичную еду и ДВЕ нелюбимые. Максимум — ТРИ любимых типа еды.'
                  }
                >
                  <Box inline>
                    <Button icon="circle-question" mr="0.5em" />
                    {invalid ? (
                      <Box as="span" color="#bd2020">
                        Предпочтения некорректны!{' '}
                        {invalid.charAt(0).toUpperCase() + invalid.slice(1)} |{' '}
                        {counts.disliked < 2
                          ? `${counts.disliked}/2 Нелюбимые`
                          : `${counts.toxic}/1 Токсичная`}
                      </Box>
                    ) : (
                      <Box as="span" color="green">
                        Предпочтения валидны! | <b>{counts.liked}</b>/3 Любимые
                      </Box>
                    )}
                  </Box>
                </Tooltip>

                <Button
                  className="FoodPreferences__TopButton"
                  style={{ position: 'absolute', right: '20em' }}
                  color={'red'}
                  onClick={() => act('reset')}
                  tooltip="Сбросить к значениям по умолчанию"
                >
                  Сброс
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
                      Переключает применение этих предпочтений при спавне персонажа.
                      <Divider />
                      Это в основном рекомендации — можно отыгрывать вкусы
                      персонажа, даже если тип еды здесь не отмечен как любимый.
                    </>
                  }
                >
                  Использовать кастомные пищевые предпочтения
                </Button>
              </Box>
            }
          >
            {(race_disabled && (
                <ErrorOverlay>
                Вы используете расу, на которую пищевые предпочтения не влияют!
              </ErrorOverlay>
            )) ||
              (!enabled && (
                <ErrorOverlay>Ваши пищевые предпочтения отключены!</ErrorOverlay>
              ))}
            <Box style={{ columns: '30em' }}>
              {Object.entries(food_types).map((element) => {
                const { 0: foodName, 1: foodPointValues } = element;
                return (
                  <Box key={foodName}>
                    <Section
                      title={
                        <>
                          {foodNameRu(foodName)}
                          {obscure_food_types.includes(foodName) && (
                            <Tooltip content="Этот тип еды не учитывается в лимите любимых и даётся бесплатно!">
                              <Box
                                as="span"
                                fontSize={0.75}
                                verticalAlign={'top'}
                              >
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
                          (!selection[foodName] &&
                            foodPointValues === FOOD_TOXIC)
                        }
                        content={<>Токсичная</>}
                        color="olive"
                        tooltip="Персонажа почти сразу вырвет от любой токсичной еды."
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_DISLIKED}
                        disabled={
                          !obscure_food_types.includes(foodName) &&
                          counts.toxic < limits.min_toxic
                        }
                        selected={
                          selection[foodName] === FOOD_DISLIKED ||
                          (!selection[foodName] &&
                            foodPointValues === FOOD_DISLIKED)
                        }
                        content={<>Нелюбимая</>}
                        color="red"
                        tooltip="Персонажу станет плохо, а затем он может вырвать после достаточного количества нелюбимой еды."
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_NEUTRAL}
                        disabled={
                          (!obscure_food_types.includes(foodName) &&
                            counts.toxic < limits.min_toxic) ||
                          (!obscure_food_types.includes(foodName) &&
                            counts.disliked < limits.min_disliked)
                        }
                        selected={
                          selection[foodName] === FOOD_NEUTRAL ||
                          (!selection[foodName] &&
                            foodPointValues === FOOD_NEUTRAL)
                        }
                        content={<>Нейтральная</>}
                        color="yellow"
                        tooltip="Персонаж нейтрально относится к этой еде."
                      />
                      <FoodButton
                        foodName={foodName}
                        foodPreference={FOOD_LIKED}
                        disabled={
                          (!obscure_food_types.includes(foodName) &&
                            counts.liked >= limits.max_liked) ||
                          (!obscure_food_types.includes(foodName) &&
                            counts.disliked < limits.min_disliked) ||
                          (!obscure_food_types.includes(foodName) &&
                            counts.toxic < limits.min_toxic)
                        }
                        selected={
                          selection[foodName] === FOOD_LIKED ||
                          (!selection[foodName] &&
                            foodPointValues === FOOD_LIKED)
                        }
                        content={<>Любимая</>}
                        color="green"
                        tooltip={
                          !obscure_food_types.includes(foodName) &&
                          counts.liked >= 3
                            ? 'Сейчас у вас слишком много любимых типов еды. Нельзя выбрать больше трёх не-особых.'
                            : 'Персонажу нравится эта еда.'
                        }
                      />
                    </Section>
                  </Box>
                );
              })}
            </Box>
          </StyleableSection>
          }
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
