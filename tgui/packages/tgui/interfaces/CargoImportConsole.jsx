// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const CargoImportConsole = (props) => {
  const [category, setCategory] = useState('');
  const [weapon, setArmament] = useState('weapon');
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    armaments_list = [],
    budget_points,
    budget_name,
    self_paid,
    cant_buy_restricted,
  } = data;
  return (
    <Window
      theme="armament"
      title={t('ui.cargo_import_console.title')}
      width={1000}
      height={600}
    >
      <Window.Content>
        <Section height="100%" title={t('ui.cargo_import_console.title')}>
          <Stack>
            <Stack.Item grow fill>
              <Button.Checkbox
                content={t('ui.cargo_import_console.buy_privately')}
                checked={self_paid}
                onClick={() => act('toggleprivate')}
              />
              <Box>
                <b>{t('ui.cargo_import_console.current_budget')}:</b>{' '}
                {budget_name}
              </Box>
              <Box>
                <b>{t('ui.cargo_import_console.budget_remaining')}:</b>{' '}
                {budget_points}
              </Box>
            </Stack.Item>
          </Stack>
          <Divider />
          <Stack fill grow>
            <Stack.Item mr={1}>
              <Section title={t('ui.cargo_import_console.companies')}>
                <Stack vertical>
                  {armaments_list.map((armament_category) => (
                    <Stack.Item key={armament_category.category}>
                      <Button
                        width="100%"
                        content={armament_category.category}
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
                                color={item.cant_purchase ? 'bad' : 'default'}
                                width="100%"
                                key={item.ref}
                                onClick={() => setArmament(item.ref)}
                              >
                                <Image
                                  src={`data:image/jpeg;base64,${item.icon}`}
                                  height="32px"
                                  width="32px"
                                  style={{
                                    objectFit: 'contain',
                                    verticalAlign: 'middle',
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
              <Section title={t('ui.cargo_import_console.selected_item')}>
                {armaments_list.map((armament_category) =>
                  armament_category.subcategories.map((subcat) =>
                    subcat.items.map(
                      (item) =>
                        item.ref === weapon && (
                          <Stack vertical key={item.ref}>
                            <Stack.Item>
                              <Image
                                src={`data:image/jpeg;base64,${item.icon}`}
                                height="96px"
                                width="96px"
                                style={{
                                  objectFit: 'contain',
                                  verticalAlign: 'middle',
                                }}
                              />
                            </Stack.Item>
                            <Stack.Item>{item.description}</Stack.Item>
                            {!!cant_buy_restricted && !!item.restricted && (
                              <Stack.Item textColor={'red'}>
                                {t(
                                  'ui.cargo_import_console.weapon_permit_required',
                                )}
                              </Stack.Item>
                            )}
                            <Stack.Item
                              textColor={
                                item.cost > budget_points ? 'red' : 'green'
                              }
                            >
                              {`${t('ui.common.cost')}: ${item.cost}`}
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                content={t('ui.common.buy')}
                                textAlign="center"
                                width="100%"
                                disabled={
                                  item.cost > budget_points ||
                                  (!!cant_buy_restricted && !!item.restricted)
                                }
                                onClick={() =>
                                  act('equip_item', {
                                    armament_ref: item.ref,
                                  })
                                }
                              />
                            </Stack.Item>
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
