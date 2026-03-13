import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  ColorBox,
  Divider,
  Icon,
  ImageButton,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Beaker, BeakerReagent } from './common/BeakerDisplay';
import { usePreferencesLocalization } from './localization';

type Container = {
  icon: string;
  icon_state: string;
  ref: string;
  name: string;
  volume: number;
};

type Category = {
  name: string;
  containers: Container[];
};

type AnalyzableReagent = BeakerReagent & {
  ref: string;
  pH: number;
  color: string;
  description: string;
  purity: number;
  metaRate: number;
  overdose: number;
  addictionTypes: string[];
};

type AnalyzableBeaker = {
  contents: AnalyzableReagent[];
} & Beaker;

type Data = {
  categories: Category[];
  isPrinting: BooleanLike;
  printingProgress: number;
  printingTotal: number;
  selectedPillDuration: number;
  maxPrintable: number;
  maxPillDuration: number;
  beaker: AnalyzableBeaker;
  buffer: AnalyzableBeaker;
  isTransfering: BooleanLike;
  suggestedContainerRef: string;
  selectedContainerRef: string;
  selectedContainerVolume: number;
  selectedContainerCategory?: string;
  hasBeakerInHand: BooleanLike;
};

export const ChemMaster = (props) => {
  const [analyzedReagent, setAnalyzedReagent] = useState<AnalyzableReagent>();

  return (
    <Window width={450} height={620}>
      <Window.Content scrollable>
        {analyzedReagent ? (
          <AnalysisResults
            analysisData={analyzedReagent}
            onExit={() => setAnalyzedReagent(undefined)}
          />
        ) : (
          <ChemMasterContent
            analyze={(chemical: AnalyzableReagent) =>
              setAnalyzedReagent(chemical)
            }
          />
        )}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props: {
  analyze: (chemical: AnalyzableReagent) => void;
}) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    isPrinting,
    printingProgress,
    printingTotal,
    selectedPillDuration,
    maxPrintable,
    maxPillDuration,
    isTransfering,
    beaker,
    buffer,
    categories,
    selectedContainerVolume,
    selectedContainerCategory,
    hasBeakerInHand,
  } = data;

  const [itemCount, setItemCount] = useState<number>(1);
  const [showPreferredContainer, setShowPreferredContainer] =
    useState<BooleanLike>(false);
  const buffer_contents = buffer.contents;

  return (
    <Box>
      <Section
        title={t('ui.chem_master.beaker')}
        buttons={
          beaker ? (
            <Box>
              <Box inline color="label" mr={2}>
                <AnimatedNumber value={beaker.currentVolume} initial={0} />
                {` / ${beaker.maxVolume} units`}
              </Box>
              <Button icon="eject" onClick={() => act('eject')}>
                {t('ui.common.eject')}
              </Button>
            </Box>
          ) : (
            <Button
              icon="eject"
              onClick={() => act('insert')}
              style={{
                opacity: hasBeakerInHand ? 1 : 0.5,
              }}
                tooltip={!hasBeakerInHand && t('ui.common.need_container_in_hand')}
              tooltipPosition="bottom-start"
            >
                {t('ui.common.insert')}
              </Button>
          )
        }
      >
        {!beaker ? (
          <Box color="label" my={'4px'}>
            {t('ui.common.no_beaker_loaded')}
          </Box>
        ) : beaker.currentVolume === 0 ? (
          <Box color="label" my={'4px'}>
            {t('ui.common.beaker_is_empty')}
          </Box>
        ) : (
          <Table>
            {beaker.contents.map((chemical) => (
              <ReagentEntry
                key={chemical.ref}
                chemical={chemical}
                transferTo="buffer"
                analyze={props.analyze}
              />
            ))}
          </Table>
        )}
      </Section>
      <Section
        title={t('ui.chem_master.buffer')}
        buttons={
          <>
            <Box inline color="label" mr={1}>
              <AnimatedNumber value={buffer.currentVolume} initial={0} />
              {` / ${buffer.maxVolume} units`}
            </Box>
            <Button
              color={isTransfering ? 'good' : 'bad'}
              icon={isTransfering ? 'exchange-alt' : 'trash'}
              onClick={() => act('toggleTransferMode')}
            >
              {isTransfering
                ? t('ui.chem_master.moving_reagents')
                : t('ui.chem_master.destroying_reagents')}
            </Button>
          </>
        }
      >
        {buffer_contents.length === 0 ? (
          <Box color="label" my={'4px'}>
            Buffer is empty.
          </Box>
        ) : (
          <Table>
            {buffer_contents.map((chemical) => (
              <ReagentEntry
                key={chemical.ref}
                chemical={chemical}
                transferTo="beaker"
                analyze={props.analyze}
              />
            ))}
          </Table>
        )}
      </Section>
      {!isPrinting && (
        <Section
          title={t('ui.chem_master.packaging')}
          buttons={
            buffer_contents.length !== 0 && (
              <Box>
                <Button.Checkbox
                  checked={showPreferredContainer}
                  onClick={() =>
                    setShowPreferredContainer((currentValue) => !currentValue)
                  }
                >
                  {t('ui.chem_master.suggest')}
                </Button.Checkbox>
                <NumberInput
                  unit={'items'}
                  step={1}
                  value={itemCount}
                  minValue={1}
                  maxValue={maxPrintable}
                  onChange={(value) => {
                    setItemCount(value);
                  }}
                />
                {selectedContainerCategory === 'pills' && (
                  <NumberInput
                    unit="s"
                    step={1}
                    value={selectedPillDuration}
                    minValue={0}
                    maxValue={maxPillDuration}
                    onChange={(value) => {
                      act('setPillDuration', {
                        duration: value,
                      });
                    }}
                  />
                )}
                <Box inline mx={1}>
                  {`${
                    Math.round(
                      Math.min(
                        selectedContainerVolume,
                        buffer.currentVolume / itemCount,
                      ) * 100,
                    ) / 100
                  } u. each`}
                </Box>
                <Button
                  icon="flask"
                  onClick={() =>
                    act('create', {
                      itemCount: itemCount,
                    })
                  }
                >
                  {t('ui.common.print')}
                </Button>
              </Box>
            )
          }
        >
          {categories.map((category) => (
            <Box key={category.name}>
              <GroupTitle title={category.name} />
              {category.containers.map((container) => (
                <ContainerButton
                  key={container.ref}
                  category={category}
                  container={container}
                  showPreferredContainer={showPreferredContainer}
                />
              ))}
            </Box>
          ))}
        </Section>
      )}
      {!!isPrinting && (
        <Section
          title={t('ui.chem_master.printing')}
          buttons={
            <Button
              color="bad"
              icon="times"
              onClick={() => act('stopPrinting')}
            >
              {t('ui.common.stop')}
            </Button>
          }
        >
          <ProgressBar
            value={printingProgress}
            minValue={0}
            maxValue={printingTotal}
            color="good"
          >
            <Box
              lineHeight={1.9}
              style={{
                textShadow: '1px 1px 0 black',
              }}
            >
              {`${t('ui.chem_master.printing')} ${printingProgress} ${t('ui.common.of')} ${printingTotal}`}
            </Box>
          </ProgressBar>
        </Section>
      )}
    </Box>
  );
};

type ReagentProps = {
  chemical: AnalyzableReagent;
  transferTo: string;
  analyze: (chemical: AnalyzableReagent) => void;
};

const ReagentEntry = (props: ReagentProps) => {
  const { data, act } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { chemical, transferTo, analyze } = props;
  const { isPrinting } = data;
  return (
    <Table.Row key={chemical.ref}>
      <Table.Cell color="label">
        {`${chemical.name} `}
        <AnimatedNumber value={chemical.volume} initial={0} />
        {'u'}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          disabled={isPrinting}
          onClick={() => {
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1,
              target: transferTo,
            });
          }}
        >
          1
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 5,
              target: transferTo,
            })
          }
        >
          5
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 10,
              target: transferTo,
            })
          }
        >
          10
        </Button>
        <Button
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: 1000,
              target: transferTo,
            })
          }
        >
          {t('ui.common.all')}
        </Button>
        <Button
          icon="ellipsis-h"
          tooltip={t('ui.common.custom_amount')}
          disabled={isPrinting}
          onClick={() =>
            act('transfer', {
              reagentRef: chemical.ref,
              amount: -1,
              target: transferTo,
            })
          }
        />
        <Button
          icon="question"
          tooltip={t('ui.common.analyze')}
          onClick={() => analyze(chemical)}
        />
      </Table.Cell>
    </Table.Row>
  );
};

type CategoryButtonProps = {
  category: Category;
  container: Container;
  showPreferredContainer: BooleanLike;
};

const ContainerButton = (props: CategoryButtonProps) => {
  const { act, data } = useBackend<Data>();
  const { isPrinting, selectedContainerRef, suggestedContainerRef } = data;
  const { category, container, showPreferredContainer } = props;
  const isPillPatch = ['pills', 'patches'].includes(category.name);
  const fallback = <Icon m="18px" name="spinner" spin />;
  const fallbackPillPatch = <Icon m="10px" name="spinner" spin />;

  return (
    <Tooltip
      key={container.ref}
      content={`${capitalize(container.name)}\xa0(${container.volume}u)`}
    >
      <ImageButton
        dmIcon={container.icon}
        dmIconState={container.icon_state}
        dmFallback={isPillPatch ? fallbackPillPatch : fallback}
        imageSize={isPillPatch ? 48 : 64}
        color={
          showPreferredContainer &&
          selectedContainerRef !== suggestedContainerRef && // if we selected the same container as the suggested then don't override color
          container.ref === suggestedContainerRef
            ? 'blue'
            : 'transparent'
        }
        selected={container.ref === selectedContainerRef}
        disabled={isPrinting}
        m={isPillPatch ? '4px' : '2px'}
        p={0}
        onClick={() => {
          act('selectContainer', {
            ref: container.ref,
          });
        }}
      />
    </Tooltip>
  );
};

const AnalysisResults = (props: {
  analysisData: AnalyzableReagent;
  onExit: () => void;
}) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    name,
    pH,
    color,
    description,
    purity,
    metaRate,
    overdose,
    addictionTypes,
  } = props.analysisData;

  const purityLevel =
    purity <= 0.5 ? 'bad' : purity <= 0.75 ? 'average' : 'good'; // Color names

  return (
    <Section
      title={t('ui.chem_master.analysis_results')}
      buttons={
        <Button icon="arrow-left" onClick={() => props.onExit()}>
          {t('ui.common.back')}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.common.name')}>{name}</LabeledList.Item>
        <LabeledList.Item label={t('ui.chem_master.purity')}>
          <Box
            style={{
              textTransform: 'capitalize',
            }}
            color={purityLevel}
          >
            {purityLevel}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.chem_master.ph')}>{pH}</LabeledList.Item>
        <LabeledList.Item label={t('ui.common.color')}>
          <ColorBox color={color} mr={1} />
          {color}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.description')}>
          {description}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.chem_master.metabolization_rate')}>
          {metaRate} {t('ui.chem_master.units_per_second')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.chem_master.overdose_threshold')}>
          {overdose > 0
            ? `${overdose} ${t('ui.common.units')}`
            : t('ui.common.not_available')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.chem_master.addiction_types')}>
          {addictionTypes.length
            ? addictionTypes.toString()
            : t('ui.common.not_available')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item
        style={{
          textTransform: 'capitalize',
        }}
        color={'gray'}
      >
        {title}
      </Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  );
};
