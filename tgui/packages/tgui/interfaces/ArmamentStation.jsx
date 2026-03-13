// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Button,
  Divider,
  Image,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ArmamentStation = (props) => {
  const [category, setCategory] = useLocalState('category', '');
  const [weapon, setArmament] = useLocalState('weapon');
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { armaments_list = [], card_inserted, card_points, card_name } = data;
  return (
    <Window
      theme="armament"
      title={t('ui.armament_station.title')}
      width={1000}
      height={600}
    >
      <Window.Content>
        <Section height="100%" title={t('ui.armament_station.title')}>
          {card_inserted ? (
            <Stack>
              <Stack.Item grow fill>
                <Box>
                  <b>{t('ui.armament_station.inserted_card')}:</b> {card_name}
                </Box>
                <Box>
                  <b>{t('ui.armament_station.remaining_points')}:</b>{' '}
                  {card_points}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  fontSize="20px"
                  content={t('ui.armament_station.eject_card')}
                  onClick={() => act('eject_card')}
                />
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox color="bad">
              {t('ui.armament_station.no_card_inserted')}
            </NoticeBox>
          )}
          <Divider />
          <Stack fill grow>
            <Stack.Item mr={1}>
              <Section title={t('ui.armament_station.categories')}>
                <Stack vertical>
                  {armaments_list.map((armament_category) => (
                    <Stack.Item key={armament_category.category}>
                      <Button
                        width="100%"
                        content={
                          armament_category.category +
                          ` (${t('ui.armament_station.pick')} ` +
                          armament_category.category_limit +
                          ')'
                        }
                        selected={category === armament_category.category}
                        onClick={() => setCategory(armament_category.category)}
                      />
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item grow mr={1}>
              <Section title={category} scrollable fill height="480px">
                {armaments_list.map(
                  (armament_category) =>
                    armament_category.category === category &&
                    armament_category.subcategories.map((subcat) => (
                      <Section
                        key={subcat.subcategory}
                        title={subcat.subcategory}
                      >
                        <Stack vertical>
                          {subcat.items.map((item) => (
                            <Stack.Item key={item.ref}>
                              <Button
                                fontSize="15px"
                                textAlign="center"
                                selected={weapon === item.ref}
                                color={
                                  item.purchased >= item.quantity
                                    ? 'bad'
                                    : 'default'
                                }
                                width="100%"
                                key={item.ref}
                                onClick={() => setArmament(item.ref)}
                              >
                                <img
                                  src={`data:image/jpeg;base64,${item.icon}`}
                                  style={{
                                    'vertical-align': 'middle',
                                    'horizontal-align': 'middle',
                                  }}
                                />
                                &nbsp;{item.name}
                              </Button>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Section>
                    )),
                )}
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item width="20%">
              <Section title={t('ui.armament_station.selected_armament')}>
                {armaments_list.map((armament_category) =>
                  armament_category.subcategories.map((subcat) =>
                    subcat.items.map(
                      (item) =>
                        item.ref === weapon && (
                          <Stack vertical key={item.ref}>
                            <Stack.Item>
                              <Image>
                                src=
                                {`data:image/jpeg;base64,${item.icon}`}
                                height={'100%'} width={'100%'} style=
                                {{
                                  'vertical-align': 'middle',
                                  'horizontal-align': 'middle',
                                }}
                              </Image>
                            </Stack.Item>
                            <Stack.Item>{item.description}</Stack.Item>
                            <Stack.Item
                              textColor={
                                item.quantity - item.purchased <= 0
                                  ? 'red'
                                  : 'green'
                              }
                            >
                              {`${t('ui.armament_station.quantity_remaining')}:
                                 ${item.quantity - item.purchased}`}
                            </Stack.Item>
                            <Stack.Item
                              textColor={
                                item.cost > card_points || !card_inserted
                                  ? 'red'
                                  : 'green'
                              }
                            >
                              {`${t('ui.common.cost')}: ${item.cost}`}
                            </Stack.Item>
                            {!!item.buyable_ammo && (
                              <Stack.Item
                                textColor={
                                  item.magazine_cost > card_points ||
                                  !card_inserted
                                    ? 'red'
                                    : 'green'
                                }
                              >
                                {`${t('ui.armament_station.ammo_cost')}: ${item.magazine_cost}`}
                              </Stack.Item>
                            )}
                            <Stack.Item>
                              <Button
                                content={t('ui.common.buy')}
                                textAlign="center"
                                width="100%"
                                disabled={
                                  item.cost > card_points ||
                                  item.purchased >= item.quantity
                                }
                                onClick={() =>
                                  act('equip_item', {
                                    armament_ref: item.ref,
                                  })
                                }
                              />
                            </Stack.Item>
                            {!!item.buyable_ammo && (
                              <Stack.Item>
                                <Button
                                  content={t('ui.armament_station.buy_ammo')}
                                  textAlign="center"
                                  width="100%"
                                  disabled={item.magazine_cost > card_points}
                                  onClick={() =>
                                    act('buy_ammo', {
                                      armament_ref: item.ref,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                          </Stack>
                        ),
                    ),
                  ),
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

