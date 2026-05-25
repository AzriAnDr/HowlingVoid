import {
  Box,
  Button,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Material } from './Fabrication/Types';
import { usePreferencesLocalization } from './localization';

type IconData = {
  id: string;
  icon: string;
};

type Alloy = {
  name: string;
  id: string;
};

type Data = {
  materials: Material[];
  materialIcons: IconData[];
  selectedMaterial: string | null;
  alloys: Alloy[];
  alloyIcons: IconData[];
  selectedAlloy: string | null;
  state: boolean;
  SHEET_MATERIAL_AMOUNT: number;
  storytellerProcessingDescription?: string | null;
  storytellerProcessingLabel?: string | null;
  storytellerProcessingModifier?: number;
  storytellerProcessingRemaining?: number;
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

export const ProcessingConsole = (props: any) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const {
    state,
    storytellerProcessingDescription,
    storytellerProcessingLabel,
    storytellerProcessingModifier,
    storytellerProcessingRemaining,
  } = data;

  return (
    <Window title={t('ui.processing_console.title')} width={580} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!storytellerProcessingLabel && (
            <Stack.Item>
              <NoticeBox
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
            </Stack.Item>
          )}
          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item grow={1.2} basis={0}>
                <Section fill textAlign="center" title={t('ui.common.materials')}>
                  <MaterialSelection />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section fill title={t('ui.processing_console.alloys')} textAlign="center">
                  <AlloySelection />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrows-spin"
              iconSpin={state}
              color={state ? 'bad' : 'good'}
              textAlign="center"
              fontSize={1.25}
              py={1}
              fluid
              bold
              onClick={() => act('toggle')}
            >
              {state ? t('ui.common.deactivate') : t('ui.common.activate')}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialSelection = (props: any) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { materials, materialIcons, selectedMaterial, SHEET_MATERIAL_AMOUNT } =
    data;

  return materials.length > 0 ? (
    <Table>
      {materials.map((material) => (
        <DisplayRow
          key={material.name}
          name={material.name}
          icon={materialIcons.find((icon) => icon.id === material.ref)?.icon}
          amount={Math.floor(material.amount / SHEET_MATERIAL_AMOUNT)}
          selected={selectedMaterial === material.name}
          onSelect={() => act('setMaterial', { value: material.ref })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>{t('ui.processing_console.no_material_recipes_found')}</NoticeBox>
  );
};

const AlloySelection = (props: any) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { alloys, alloyIcons, selectedAlloy } = data;

  return alloys.length > 0 ? (
    <Table>
      {alloys.map((alloy) => (
        <DisplayRow
          key={alloy.id}
          name={alloy.name}
          icon={alloyIcons.find((icon) => icon.id === alloy.id)?.icon}
          selected={selectedAlloy === alloy.id}
          onSelect={() => act('setAlloy', { value: alloy.id })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>{t('ui.processing_console.no_alloy_recipes_found')}</NoticeBox>
  );
};

type DisplayRowProps = {
  name: string;
  icon?: string;
  amount?: number;
  selected: boolean;
  onSelect: () => void;
};

const DisplayRow = (props: DisplayRowProps) => {
  const { t } = usePreferencesLocalization();
  const { name, icon, amount, selected, onSelect } = props;

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing pl={1}>
        {icon ? (
          <Image
            m={1}
            width="24px"
            height="24px"
            verticalAlign="middle"
            src={`data:image/jpeg;base64,${icon}`}
          />
        ) : (
          <Icon name="circle-question" verticalAlign="middle" />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        {toTitleCase(name)}
      </Table.Cell>
      {amount !== undefined ? (
        <Box color="label">
          {`${formatSiUnit(amount, 0)} ${amount === 1 ? t('ui.processing_console.sheet') : t('ui.processing_console.sheets')}`}
        </Box>
      ) : null}
      <Table.Cell collapsing pr={1} textAlign="right">
        <Button.Checkbox
          color="transparent"
          checked={selected}
          onClick={() => onSelect()}
        />
      </Table.Cell>
    </Table.Row>
  );
};
