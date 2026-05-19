import {
  Box,
  Button,
  Dimmer,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialIcon } from './Fabrication/MaterialIcon';
import type { Material } from './Fabrication/Types';
import { usePreferencesLocalization } from './localization';

type Data = {
  SHEET_MATERIAL_AMOUNT: number;
  materials: Material[];
  design?: Design;
  busy: BooleanLike;
};

type Design = {
  name: string;
  icon: string;
  requiredMaterials: Material[];
  disableReason?: string;
  selectedPartTier: number;
  maxPartTier: number;
  selectedDirection: Direction;
  supportsPartTierSelection: BooleanLike;
  supportsDirectionSelection: BooleanLike;
};

type Direction = 'north' | 'east' | 'south' | 'west';

const directionOrder: Direction[] = ['north', 'east', 'south', 'west'];

const directionIcons: Record<Direction, string> = {
  north: 'arrow-up',
  east: 'arrow-right',
  south: 'arrow-down',
  west: 'arrow-left',
};

export const Flatpacker = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { SHEET_MATERIAL_AMOUNT, materials, design, busy } = data;

  return (
    <Window width={670} height={500} title={t('ui.flatpacker.title')}>
      <Window.Content>
        {!!busy && (
          <Dimmer
            style={{
              fontSize: '2em',
              textAlign: 'center',
            }}
          >
            <Icon name="cog" spin />
            {` ${t('ui.flatpacker.flatpacking')}`}
          </Dimmer>
        )}
        <Stack fill vertical align="stretch">
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Section>
                  <Box
                    className="FabricatorRecipe__Label"
                    style={{
                      fontFamily: 'Helvetica',
                      fontSize: '18px',
                    }}
                  >
                    {design
                      ? toTitleCase(design.name)
                      : t('ui.flatpacker.no_board')}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Button
                  tooltip={t('ui.flatpacker.eject_board')}
                  tooltipPosition="left"
                  height="37px"
                  width="37px"
                  disabled={!design}
                  onClick={() => act('ejectBoard')}
                >
                  <Icon name="eject" size={1.5} mt="0.8rem" ml="0rem" />
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {design ? (
              <Stack fill>
                <Stack.Item width={15}>
                  <BoardPreview
                    design={design}
                    onPrint={() => act('build')}
                    onSelectTier={(tier) => act('setPartTier', { tier })}
                    onSelectDirection={(direction) =>
                      act('setDirection', { direction })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <CostPreview
                    SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                    materials={design.requiredMaterials}
                  />
                </Stack.Item>
              </Stack>
            ) : (
              <NoticeBox>{t('ui.flatpacker.no_circuit_present')}</NoticeBox>
            )}
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              <MaterialAccessBar
                availableMaterials={materials}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                onEjectRequested={(material, amount) =>
                  act('eject', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type BoardPreviewProps = {
  design: Design;
  onPrint: () => void;
  onSelectTier: (tier: number) => void;
  onSelectDirection: (direction: Direction) => void;
};

const BoardPreview = (props: BoardPreviewProps) => {
  const { design, onPrint, onSelectTier, onSelectDirection } = props;
  const { t } = usePreferencesLocalization();
  const tiers = Array.from(
    { length: design.maxPartTier },
    (_, index) => index + 1,
  );

  return (
    <Section fill>
      <Stack fill vertical justify="space-between">
        <Stack.Item>
          <Stack vertical align="center">
            <Stack.Item>
              <Image
                width="128px"
                height="128px"
                src={`data:image/jpeg;base64,${design.icon}`}
              />
            </Stack.Item>
            <Stack.Item width="100%">
              {!!design.supportsPartTierSelection && (
                <Section title="Component tier">
                  <Stack>
                    {tiers.map((tier) => (
                      <Stack.Item key={tier} grow>
                        <Button
                          fluid
                          selected={design.selectedPartTier === tier}
                          onClick={() => onSelectTier(tier)}
                        >
                          {`T${tier}`}
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              )}
              {!!design.supportsDirectionSelection && (
                <Section title={t('ui.common.direction')}>
                  <Stack vertical>
                    {directionOrder.map((direction) => (
                      <Stack.Item key={direction}>
                        <Button
                          fluid
                          icon={directionIcons[direction]}
                          selected={design.selectedDirection === direction}
                          onClick={() => onSelectDirection(direction)}
                        >
                          {t(`ui.common.direction_${direction}`)}
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            bold
            fluid
            p={1}
            icon="cog"
            fontSize={1.2}
            textAlign="center"
            disabled={!design || design.disableReason !== ''}
            tooltip={design.disableReason}
            tooltipPosition="bottom"
            onClick={() => onPrint()}
          >
            {t('ui.common.print')}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type CostPreviewProps = {
  SHEET_MATERIAL_AMOUNT: number;
  materials?: Material[];
};

const CostPreview = (props: CostPreviewProps) => {
  const { materials, SHEET_MATERIAL_AMOUNT } = props;
  const { t } = usePreferencesLocalization();

  return (
    <Section fill scrollable>
      {materials ? (
        <Table>
          {materials.map((material) => (
            <Table.Row key={material.name} className="candystripe">
              <Table.Cell verticalAlign="middle">
                <div style={{ width: '200px' }}>
                  <MaterialIcon
                    materialName={material.name}
                    sheets={material.amount / SHEET_MATERIAL_AMOUNT}
                  />
                </div>
              </Table.Cell>
              <Table.Cell verticalAlign="middle">
                <div style={{ width: '200px' }}>
                  {toTitleCase(material.name)}
                </div>
              </Table.Cell>
              <Table.Cell verticalAlign="middle">
                <div style={{ width: '200px' }}>
                  x{(material.amount / SHEET_MATERIAL_AMOUNT).toFixed(2)}
                </div>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <NoticeBox>{t('ui.flatpacker.no_materials_required')}</NoticeBox>
      )}
    </Section>
  );
};
