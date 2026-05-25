import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';
import { usePreferencesLocalization } from './localization';

type Material = {
  name: string;
  amount: number;
  category: string;
  icon_state: string;
  icon: string;
  id: string;
  value: number;
};

type User = {
  cash: number;
  name: string;
};

type Data = {
  disconnected: BooleanLike;
  materials: Material[];
  storytellerProcessingDescription?: string | null;
  storytellerProcessingLabel?: string | null;
  storytellerProcessingModifier?: number;
  storytellerProcessingRemaining?: number;
  unclaimedPoints: number;
  user: User;
};

const formatDeciseconds = (deciseconds = 0) => {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return `${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
};

export function OreRedemptionMachine(props) {
  const [compact, setCompact] = useState(false);
  const [searchItem, setSearchItem] = useState('');
  const { t } = usePreferencesLocalization();

  return (
    <Window title={t('ui.ore_redemption_machine.title')} width={435} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <IDSection compact={compact} setCompact={setCompact} />
          </Stack.Item>
          <Stack.Item>
            <PointsSection />
          </Stack.Item>
          <NoticeBox info mb={0}>
            {t('ui.ore_redemption_machine.accepts_only_ore')}
          </NoticeBox>
          <Stack.Item mb={-1}>
            <MaterialSearchHeader
              searchItem={searchItem}
              setSearchItem={setSearchItem}
            />
          </Stack.Item>
          <Stack.Item grow>
            <MaterialSection compact={compact} searchItem={searchItem} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type MaterialRowProps = {
  compact: boolean;
  material: Material;
  onRelease: (amount: string | number) => void;
};

function MaterialRow(props: MaterialRowProps) {
  const { compact, material, onRelease } = props;
  const { t } = usePreferencesLocalization();

  const sheet_amounts = Math.floor(material.amount);
  const print_amount = 5;
  const max_sheets = 50;

  return (
    <Table.Row className="candystripe">
      {!compact && (
        <Table.Cell collapsing>
          <DmIcon
            height="18px"
            width="18px"
            icon={material.icon}
            icon_state={material.icon_state}
            fallback={<Icon name="spinner" size={2} spin />}
          />
        </Table.Cell>
      )}
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">
          {formatSiUnit(sheet_amounts, 0)}{' '}
          {material.amount === 1
            ? t('ui.ore_redemption_machine.sheet')
            : t('ui.ore_redemption_machine.sheets')}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Button
          color="transparent"
          tooltip={
            material.value
              ? `${material.value} ${t('ui.ore_redemption_machine.cr_short')}`
              : t('ui.ore_redemption_machine.no_cost')
          }
          onClick={() => onRelease(1)}
        >
          x1
        </Button>
        <Button
          color="transparent"
          tooltip={
            material.value
              ? `${material.value * print_amount} ${t('ui.ore_redemption_machine.cr_short')}`
              : t('ui.ore_redemption_machine.no_cost')
          }
          onClick={() => onRelease(print_amount)}
        >
          x{print_amount}
        </Button>
        <Button.Input
          buttonText={`${t('ui.ore_redemption_machine.max')}: ${
            sheet_amounts < max_sheets ? sheet_amounts : max_sheets
          }`}
          color="transparent"
          onCommit={onRelease}
        />
      </Table.Cell>
    </Table.Row>
  );
}

type IDSectionProps = {
  compact: boolean;
  setCompact: (compact: boolean) => void;
};

function IDSection(props: IDSectionProps) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { user } = data;

  const { compact, setCompact } = props;

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="id-card" size={3} mr={1} color={user ? 'green' : 'red'} />
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              {user?.name || t('ui.ore_redemption_machine.no_name_detected')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.ore_redemption_machine.point_balance')}>
              {user?.cash || t('ui.ore_redemption_machine.no_balance_detected')}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Button
            color={compact ? 'red' : 'green'}
            onClick={() => setCompact(!compact)}
          >
            {t('ui.ore_redemption_machine.compact')}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function PointsSection(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    disconnected,
    storytellerProcessingDescription,
    storytellerProcessingLabel,
    storytellerProcessingModifier,
    storytellerProcessingRemaining,
    unclaimedPoints,
  } = data;

  return (
    <Section>
      <Stack fill>
        <Stack.Item grow>
          <Icon name="coins" color="gold" />
          <Box inline color="label" ml={1}>
            {t('ui.ore_redemption_machine.unclaimed_points')}:
          </Box>
          {` ${unclaimedPoints}`}
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={2}
            disabled={unclaimedPoints === 0 || disconnected}
            tooltip={disconnected}
            onClick={() => act('Claim')}
          >
            {t('ui.ore_redemption_machine.claim')}
          </Button>
        </Stack.Item>
      </Stack>
      {!!storytellerProcessingLabel && (
        <NoticeBox
          mt={1}
          {...((storytellerProcessingModifier || 1) < 1
            ? { danger: true }
            : { info: true })}
        >
          {storytellerProcessingLabel}
          {!!storytellerProcessingRemaining &&
            ` (${formatDeciseconds(storytellerProcessingRemaining)} left)`}
          {!!storytellerProcessingDescription && (
            <Box mt={0.5}>{storytellerProcessingDescription}</Box>
          )}
        </NoticeBox>
      )}
    </Section>
  );
}

type MaterialSectionProps = {
  compact: boolean;
  searchItem: string;
};

function MaterialSection(props: MaterialSectionProps) {
  const { act, data } = useBackend<Data>();
  const { materials } = data;

  const { compact, searchItem } = props;

  const [tab] = useSharedState('tab', 'material');

  const search = createSearch(
    searchItem,
    (materials: Material) => materials.name,
  );
  const material_filtered =
    searchItem.length > 0
      ? data.materials.filter(search)
      : materials.filter((material) => material && material.category === tab);

  return (
    <Section fill scrollable>
      <Table>
        {material_filtered.map((material) => (
          <MaterialRow
            compact={compact}
            key={material.id}
            material={material}
            onRelease={(amount) => {
              if (material.category === 'material') {
                act('Release', {
                  id: material.id,
                  sheets: amount,
                });
              } else {
                act('Smelt', {
                  id: material.id,
                  sheets: amount,
                });
              }
            }}
          />
        ))}
      </Table>
    </Section>
  );
}

type SearchProps = {
  searchItem: string;
  setSearchItem: (searchItem: string) => void;
};

function MaterialSearchHeader(props: SearchProps) {
  const { searchItem, setSearchItem } = props;
  const { t } = usePreferencesLocalization();

  const [tab, setTab] = useSharedState('tab', 'material');

  return (
    <Section>
      <Stack>
        <Stack.Item grow>
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'material'}
              onClick={() => {
                setTab('material');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              {t('ui.ore_redemption_machine.materials')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'alloy'}
              onClick={() => {
                setTab('alloy');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              {t('ui.ore_redemption_machine.alloys')}
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <SearchBar
            expensive
            style={{ height: '23px' }}
            query={searchItem}
            placeholder={t('ui.ore_redemption_machine.search_material')}
            onSearch={(value) => {
              setSearchItem(value);
              if (value.length > 0) {
                setTab('material');
              }
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
