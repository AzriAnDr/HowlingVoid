import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Direction } from '../constants';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type AreaData = { name: string; ref: string };

type VisualizationToggleProps = { visualizing: BooleanLike };

type ShuttleConstructionUnieuqData = {
  linkedShuttle: 0;
  tooManyShuttles: BooleanLike;
  onCustomShuttle: BooleanLike;
};

type ShuttleConfigurationUniqueData = {
  linkedShuttle: string;
  onShuttle: BooleanLike;
  inDefaultArea: BooleanLike;
  currentArea: AreaData;
  defaultApc: BooleanLike;
  apcInMergeRegion: BooleanLike;
  apcs: Record<string, BooleanLike>;
  neighboringAreas: Record<string, string>;
  idle: BooleanLike;
};

type ShuttleBlueprintsData = {
  shuttles?: Record<string, string>;
  visualizing: BooleanLike;
  masterExists: BooleanLike;
  isMaster: BooleanLike;
  maxShuttleSize: number;
} & (OnShuttleFrameData | OffShuttleFrameData) &
  (ShuttleConstructionUnieuqData | ShuttleConfigurationUniqueData);

type OnShuttleFrameData = {
  onShuttleFrame: 1;
  size: number;
  problems: number;
};

type OffShuttleFrameData = {
  onShuttleFrame: 0;
  size: undefined;
  problems: undefined;
};

type DirectionPadProps = {
  title: string;
  tooltip?: ReactNode;
  enabledDirections: Direction;
  selectedDirection: Direction;
  onSelect: (direction: Direction) => void;
};

const directionData: [Direction, string][] = [
  [Direction.NORTH, 'up'],
  [Direction.SOUTH, 'down'],
  [Direction.EAST, 'right'],
  [Direction.WEST, 'left'],
];

type ProblemsTooltipProps = {
  description: string;
  problemHeader: string;
  problems: number;
  problemStrings: string[];
};

const DirectionPad = (props: DirectionPadProps) => {
  const { title, tooltip, enabledDirections, selectedDirection, onSelect } =
    props;
  const [north, south, east, west] = directionData.map(
    ([direction, icon_suffix], i) => (
      <Stack.Item key={i}>
        <Button
          fluid
          m={0}
          icon={`arrow-${icon_suffix}`}
          selected={selectedDirection & direction}
          disabled={!(enabledDirections & direction)}
          onClick={() => onSelect(direction)}
        />
      </Stack.Item>
    ),
  );
  const titleNode = (
    <Box width="100%" textAlign="center">
      {title}
    </Box>
  );
  return (
    <Section
      fill
      title={
        tooltip ? <Tooltip content={tooltip}>{titleNode}</Tooltip> : titleNode
      }
    >
      <Stack fill vertical align="center" justify="center">
        {north}
        <Stack.Item>
          <Stack>
            {west}
            <Stack.Item width="1rem" mx={1} />
            {east}
          </Stack>
        </Stack.Item>
        {south}
      </Stack>
    </Section>
  );
};

const VisualizationToggle = (props: VisualizationToggleProps) => {
  const { t } = usePreferencesLocalization();
  const { visualizing } = props;
  const { act } = useBackend<ShuttleBlueprintsData>();
  return (
    <Tooltip
      content={t('ui.shuttle_blueprints.visualization_tooltip')}
    >
      <Box inline>
        {t('ui.shuttle_blueprints.visualization')}:
        <Button
          color="transparent"
          icon={visualizing ? 'toggle-on' : 'toggle-off'}
          onClick={() => act('toggleVisualization')}
        />
      </Box>
    </Tooltip>
  );
};

const ProblemsTooltip = (props: ProblemsTooltipProps) => {
  const { description, problemHeader, problems, problemStrings } = props;

  const problemElements: React.ReactElement[] = [];
  for (let i = 0; i < problemStrings.length; i++) {
    if (problems & (1 << i)) {
      problemElements.push(<Box key={i}>{`● ${problemStrings[i]}`}</Box>);
    }
  }

  return (
    <Box>
      {description}
      {problems ? (
        <>
          <Box>{problemHeader}</Box>
          {problemElements}
        </>
      ) : undefined}
    </Box>
  );
};

const ShuttleConstruction = () => {
  const { t } = usePreferencesLocalization();
  const [shuttleDirection, setShuttleDirection] = useState<Direction>(
    Direction.NORTH,
  );
  const { act, data } = useBackend<ShuttleBlueprintsData>();
  if (data.linkedShuttle !== 0) {
    throw new Error('type guard failure - linkedShuttle must be 0');
  }
  const {
    onShuttleFrame,
    visualizing,
    tooManyShuttles,
    onCustomShuttle,
    masterExists,
    size,
    maxShuttleSize,
    problems,
  } = data;
  return (
    <Stack justify="space-around">
      <Stack.Item grow>
        <DirectionPad
          title={t('ui.shuttle_blueprints.shuttle_direction')}
          tooltip={t('ui.shuttle_blueprints.shuttle_direction_tooltip')}
          enabledDirections={Direction.ALL}
          selectedDirection={shuttleDirection}
          onSelect={(dir) => setShuttleDirection(dir)}
        />
      </Stack.Item>
      <Stack.Item>
        <Stack fill vertical align="end" justify="space-between">
          <Stack.Item>
            <VisualizationToggle visualizing={visualizing} />
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Button.Confirm
                  disabled={!onShuttleFrame || tooManyShuttles || problems}
                  tooltip={
                    <ProblemsTooltip
                      description="Create a new shuttle using a shuttle frame."
                      problemHeader="The following problems prevent you from creating a shuttle with this frame."
                      problems={problems ?? 0}
                      problemStrings={[
                        'You are not on a shuttle frame.',
                        'There are too many custom shuttles currently.',
                        'This frame is too large.',
                        'This frame includes the APC of a custom area, but does not enclose the entire area.\
                         Remove the APC or add the rest of the area to the frame.',
                        'This frame encroaches on an area custom shuttles may not dock at.',
                        'This frame includes an APC belonging to a non-custom area.',
                      ]}
                    />
                  }
                  onClick={() =>
                    act('tryBuildShuttle', { dir: shuttleDirection })
                  }
                >
                  {t('ui.shuttle_blueprints.build_new_shuttle')}
                </Button.Confirm>
              </Stack.Item>
              {onShuttleFrame ? (
                <Stack.Item>
                  <ProgressBar
                    value={size}
                    maxValue={maxShuttleSize}
                    ranges={{
                      green: [0, maxShuttleSize * 0.5],
                      yellow: [maxShuttleSize * 0.5, maxShuttleSize * 0.75],
                      orange: [maxShuttleSize * 0.75, maxShuttleSize],
                      red: [maxShuttleSize, Infinity],
                    }}
                  >
                    {`${size}/${maxShuttleSize}`}
                  </ProgressBar>
                </Stack.Item>
              ) : undefined}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              disabled={!onCustomShuttle || masterExists}
              tooltip={
                onCustomShuttle
                  ? masterExists
                    ? t('ui.shuttle_blueprints.master_blueprint_exists')
                    : null
                  : t('ui.shuttle_blueprints.must_be_on_custom_shuttle')
              }
              onClick={() => act('tryLinkShuttle')}
            >
              {t('ui.shuttle_blueprints.connect_to_existing_shuttle')}
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const ShuttleConfiguration = () => {
  const { t } = usePreferencesLocalization();
  const [name, setName] = useState('');
  const [mergeArea = { name: '', ref: '' }, setMergeArea] =
    useState<AreaData>();
  const { act, data } = useBackend<ShuttleBlueprintsData>();
  if (data.linkedShuttle === 0) {
    throw new Error('type guard failure - linkedShuttle must be non-zero');
  }
  const {
    visualizing,
    onShuttleFrame,
    onShuttle,
    inDefaultArea,
    currentArea = { name: '', ref: '' },
    neighboringAreas = {},
    apcs = {},
    defaultApc,
    apcInMergeRegion,
    idle,
    isMaster,
    size,
    maxShuttleSize,
    problems,
  } = data;
  const { name: currentAreaName, ref: currentAreaRef } = currentArea;
  const { name: mergeAreaName, ref: mergeAreaRef } = mergeArea;
  const removalApcConflict = defaultApc && apcs[currentAreaRef];
  const mergeApcConflict = apcInMergeRegion && apcs[mergeAreaRef];
  const tooLarge = (size ?? 0) > maxShuttleSize;
  return (
    <Stack fill vertical align="center" justify="space-around">
      <Stack.Item textAlign="center">
        <h2>{t('ui.shuttle_blueprints.current_area')}:</h2>
        <h3>
          {onShuttle
            ? inDefaultArea
              ? t('ui.shuttle_blueprints.default_area')
              : currentAreaName
            : t('ui.shuttle_blueprints.not_on_shuttle')}
        </h3>
      </Stack.Item>
      <Stack.Item>
        <Input fluid placeholder={t('ui.shuttle_blueprints.new_area_name')} onChange={setName} />
        <Stack>
          <Stack.Item>
            <Button.Confirm
              disabled={!(onShuttle && inDefaultArea)}
              tooltip={
                onShuttle
                  ? inDefaultArea
                    ? 'Designate a room within the shuttle as its own area.'
                    : 'You can only designate a new area from the default area.'
                  : 'You must be on the linked shuttle to do this.'
              }
              onClick={() => act('createNewArea', { name: name })}
            >
              {t('ui.shuttle_blueprints.designate_new_area')}
            </Button.Confirm>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              disabled={!onShuttle || inDefaultArea}
              tooltip={
                onShuttle
                  ? inDefaultArea
                    ? 'You cannot rename the default area.'
                    : null
                  : 'You must be on the linked shuttle to do this.'
              }
              onClick={() => act('renameArea', { name: name })}
            >
              {t('ui.shuttle_blueprints.rename_current_area')}
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width="100%">
        <Stack fill justify="center">
          <Stack.Item>
            <Dropdown
              placeholder={t('ui.shuttle_blueprints.select_area')}
              options={Object.entries(neighboringAreas).map(([ref, name]) => {
                return {
                  displayText: name,
                  value: ref,
                };
              })}
              selected={mergeAreaName}
              onSelected={(value) =>
                setMergeArea({ name: neighboringAreas[value], ref: value })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              disabled={
                !(onShuttle && inDefaultArea && mergeArea) || mergeApcConflict
              }
              tooltip={
                'Expand the selected area with the connected section of the default area.' +
                (onShuttle
                  ? mergeArea
                    ? inDefaultArea
                      ? mergeApcConflict
                        ? '\nBoth the selected area and the region that it would expand into have APCs. You must remove one first.'
                        : ''
                      : '\nYou can only expand the selected area into the default area.'
                    : ''
                  : '\nYou must be on the linked shuttle to do this.')
              }
              onClick={() => act('mergeIntoArea', { area: mergeAreaRef })}
            >
              {t('ui.shuttle_blueprints.expand_area')}
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Button.Confirm
                  disabled={!(idle && onShuttleFrame) || problems || tooLarge}
                  tooltip={
                    <ProblemsTooltip
                      description="Expand the linked shuttle with an adjacent shuttle frame."
                      problemHeader="The following problems prevent you from expanding the shuttle."
                      problems={problems ?? 0}
                      problemStrings={[
                        'You must be standing on the shuttle frame you wish to expand the shuttle with.',
                        'This frame is not adjacent to the linked shuttle.',
                        'This frame is too large.',
                        'This frame includes the APC of a custom area, but does not enclose the entire area.\
                         Remove the APC or add the rest of the area to the frame.',
                        'This frame encroaches on an area custom shuttles may not dock at.',
                        'This frame includes an APC belonging to a non-custom area.',
                      ]}
                    />
                  }
                  onClick={() => act('expandWithFrame')}
                >
                  {t('ui.shuttle_blueprints.expand_shuttle_with_connected_frame')}
                </Button.Confirm>
              </Stack.Item>
              <Stack.Item>
                <VisualizationToggle visualizing={visualizing} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {onShuttleFrame ? (
              <Stack.Item>
                <ProgressBar
                  value={size}
                  maxValue={maxShuttleSize}
                  ranges={{
                    green: [0, maxShuttleSize * 0.5],
                    yellow: [maxShuttleSize * 0.5, maxShuttleSize * 0.75],
                    orange: [maxShuttleSize * 0.75, maxShuttleSize],
                    red: [maxShuttleSize, Infinity],
                  }}
                >
                  {`${size}/${maxShuttleSize}`}
                </ProgressBar>
              </Stack.Item>
            ) : undefined}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          disabled={!onShuttle || inDefaultArea || removalApcConflict}
          tooltip={
            'Merge the current area into the default area.' +
            (onShuttle
              ? inDefaultArea
                ? '\nYou are already in the default area.'
                : removalApcConflict
                  ? '\nBoth the current and default areas have APCs. You must remove one first.'
                  : ''
              : '\nYou must be on the linked shuttle to do this.')
          }
          onClick={() => act('releaseArea')}
        >
          {t('ui.shuttle_blueprints.undesignate_area')}
        </Button.Confirm>
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          disabled={!idle || !isMaster}
          tooltip={`Remove all empty space from the shuttle.${
            isMaster
              ? idle
                ? '\nThis will delete any areas left without any space, \
              and will decommission the shuttle entirely if there is nothing left of it.'
                : '\nThe shuttle must be idle to do this.'
              : '\nOnly the master blueprint can do this.'
          }`}
          onClick={() => act('cleanupEmptyTurfs')}
        >
          {t('ui.shuttle_blueprints.clean_up_empty_space')}
        </Button.Confirm>
      </Stack.Item>
    </Stack>
  );
};

export const ShuttleBlueprints = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<ShuttleBlueprintsData>();
  const { linkedShuttle, shuttles, masterExists, isMaster } = data;
  return (
    <Window width={450} height={340}>
      <Window.Content>
        <Section
          fill
          buttons={
            <>
              {shuttles && (
                <Dropdown
                  options={[
                    { displayText: t('ui.common.none'), value: 0 },
                    ...Object.entries(shuttles).map(
                      ([ref, name]: [string, string]) => {
                        return { displayText: name, value: ref };
                      },
                    ),
                  ]}
                  selected={linkedShuttle ? shuttles[linkedShuttle] : t('ui.common.none')}
                  onSelected={(value) => {
                    if (value === 0) {
                      act('unsetShuttle');
                    } else {
                      act('switchShuttle', { ref: value });
                    }
                  }}
                />
              )}
              {!!linkedShuttle && !masterExists && !isMaster && (
                <Button.Confirm onClick={() => act('promoteToMaster')}>
                  {t('ui.shuttle_blueprints.promote_to_master_blueprint')}
                </Button.Confirm>
              )}
            </>
          }
        >
          {linkedShuttle ? <ShuttleConfiguration /> : <ShuttleConstruction />}
        </Section>
      </Window.Content>
    </Window>
  );
};
