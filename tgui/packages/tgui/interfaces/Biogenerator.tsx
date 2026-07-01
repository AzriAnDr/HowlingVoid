import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  beaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  biomass: number;
  can_process: BooleanLike;
  categories: Category[];
  efficiency: number;
  max_output: number;
  max_visual_biomass: number;
  processing: BooleanLike;
  reagent_color: string;
};

type Category = {
  items: Design[];
  name: string;
};

type Design = {
  amount: number;
  cost: number;
  disable: BooleanLike;
  id: string;
  is_reagent: BooleanLike;
  name: string;
};

export function Biogenerator(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { beaker, beakerCurrentVolume, beakerMaxVolume, categories } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    data.categories[0]?.name,
  );

  const items =
    categories.find((category) => category.name === selectedCategory)?.items ||
    [];

  const space = beaker ? beakerMaxVolume - beakerCurrentVolume : 1;

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Controls />
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              {categories.map(({ name }) => (
                <Tabs.Tab
                  align="center"
                  key={name}
                  selected={name === selectedCategory}
                  onClick={() => setSelectedCategory(name)}
                >
                  {name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                {items.map((item) => (
                  <Item key={item.id} item={item} space={space} />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function Controls() {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    beaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    biomass,
    can_process,
    max_visual_biomass,
    processing,
    reagent_color,
  } = data;

  return (
    <Section fill>
      <LabeledList>
        <LabeledList.Item
          label={t('ui.biogenerator.biomass')}
          buttons={
            <Button
              width={7}
              lineHeight={2}
              icon="cog"
              iconSpin={processing}
              disabled={!can_process || processing}
              onClick={() => act('activate')}
            >
              {t('ui.biogenerator.generate')}
            </Button>
          }
        >
          <ProgressBar
            value={biomass}
            minValue={0}
            maxValue={max_visual_biomass}
            color="good"
          >
            <Box
              lineHeight={1.9}
              style={{
                textShadow: '1px 1px 0 black',
              }}
            >
              {`${parseFloat(biomass.toFixed(2))} ${t('ui.common.units')}`}
            </Box>
          </ProgressBar>
        </LabeledList.Item>
        {!!beaker && (
          <LabeledList.Item
            label={t('ui.biogenerator.container')}
            buttons={
              <Button
                width={7}
                lineHeight={2}
                align="center"
                icon="eject"
                onClick={() => act('eject')}
              >
                {t('ui.common.eject')}
              </Button>
            }
          >
            <ProgressBar
              value={beakerCurrentVolume}
              minValue={0}
              height={2}
              maxValue={beakerMaxVolume}
              color={reagent_color}
            >
              <Box
                lineHeight={1.9}
                style={{
                  textShadow: '1px 1px 0 black',
                }}
              >
                {`${beakerCurrentVolume} ${t('ui.common.of')} ${beakerMaxVolume} ${t('ui.common.units')}`}
              </Box>
            </ProgressBar>
          </LabeledList.Item>
        )}
        {!beaker && (
          <LabeledList.Item label={t('ui.biogenerator.container')}>
            <NoticeBox m={0} height={2}>
              {t('ui.biogenerator.no_liquid_container')}
            </NoticeBox>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

type Props = {
  item: Design;
  space: number;
};

function Item(props: Props) {
  const { item, space } = props;
  const { cost, id, is_reagent, name } = item;

  const { act, data } = useBackend<Data>();
  const { biomass, beaker, max_output, processing } = data;

  const minAmount = is_reagent ? Math.min(Math.max(space, 1), 10) : 1;

  const [amount, setAmount] = useState(minAmount);

  const disabled =
    processing ||
    (is_reagent && !beaker) ||
    (is_reagent && space < amount) ||
    biomass < cost * amount;

  const maxPossible = Math.floor(biomass / cost);

  const maxCapacity = is_reagent ? space : max_output;
  const maxAmount = Math.max(1, Math.min(maxCapacity, maxPossible));

  return (
    <Table.Row>
      <Table.Cell>
        <span
          className={classes(['design32x32', id])}
          style={{
            verticalAlign: 'middle',
          }}
        />{' '}
        <b>{name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          value={amount}
          step={1}
          width="40px"
          minValue={1}
          maxValue={maxAmount}
          onChange={(value) => setAmount(value)}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          width={5}
          icon="leaf"
          iconPosition="right"
          textAlign="right"
          disabled={disabled}
          onClick={() =>
            act('create', {
              id,
              amount,
            })
          }
        >
          {parseFloat((cost * amount).toFixed(2))}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
}
