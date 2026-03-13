// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ChemPress = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    current_volume,
    product_name,
    pill_style,
    pill_styles = [],
    product,
    min_volume,
    max_volume,
    patch_style,
    patch_styles = [],
  } = data;
  return (
    <Window width={300} height={227}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.chem_press.product')}>
              <Button.Checkbox
                content={t('ui.chem_press.pills')}
                checked={product === 'pill'}
                onClick={() =>
                  act('change_product', {
                    product: 'pill',
                  })
                }
              />
              <Button.Checkbox
                content={t('ui.chem_press.patches')}
                checked={product === 'patch'}
                onClick={() =>
                  act('change_product', {
                    product: 'patch',
                  })
                }
              />
              <Button.Checkbox
                content={t('ui.chem_press.bottles')}
                checked={product === 'bottle'}
                onClick={() =>
                  act('change_product', {
                    product: 'bottle',
                  })
                }
              />
              <Button.Checkbox
                content={t('ui.chem_press.vials')}
                checked={product === 'vial'}
                onClick={() =>
                  act('change_product', {
                    product: 'vial',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.volume')}>
              <NumberInput
                value={current_volume}
                unit="u"
                width="43px"
                minValue={min_volume}
                maxValue={max_volume}
                step={1}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_current_volume', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.name')}>
              <Input
                value={product_name}
                placeholder={product_name}
                onChange={(value) =>
                  act('change_product_name', {
                    name: value,
                  })
                }
              />
              <Box as="span">{product}</Box>
            </LabeledList.Item>
            {product === 'pill' && (
              <LabeledList.Item label={t('ui.common.style')}>
                {pill_styles.map((pill) => (
                  <Button
                    key={pill.id}
                    width="30px"
                    selected={pill.id === pill_style}
                    textAlign="center"
                    color="transparent"
                    onClick={() =>
                      act('change_pill_style', {
                        id: pill.id,
                      })
                    }
                  >
                    <Box mx={-1} className={pill.class_name} />
                  </Button>
                ))}
              </LabeledList.Item>
            )}
            {product === 'patch' && (
              <LabeledList.Item label={t('ui.common.style')}>
                {patch_styles.map((patch) => (
                  <Button
                    key={patch.style}
                    selected={patch.style === patch_style}
                    textAlign="center"
                    color="transparent"
                    onClick={() =>
                      act('change_patch_style', {
                        patch_style: patch.style,
                      })
                    }
                  >
                    <Box mb={0} mt={1} className={patch.class_name} />
                  </Button>
                ))}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
