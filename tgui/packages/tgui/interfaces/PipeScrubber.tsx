import {
  Box,
  Button,
  Icon,
  LabeledControls,
  RoundGauge,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  on: BooleanLike;
  direction: BooleanLike;
  connected: BooleanLike;
  pressureTank: number;
  pressureLimitTank: number;
  pressurePump: number;
  pressureLimitPump: number;
  pumpMaxPressure: number;
  hasHypernobCrystal: BooleanLike;
  reactionSuppressionEnabled: BooleanLike;
  filterTypes: Filter[];
};

type Filter = {
  id: string;
  enabled: BooleanLike;
  gasId: string;
  gasName: string;
};

const formatPressure = (value) => {
  if (value < 10000) {
    return `${toFixed(value)} kPa`;
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

export const PipeScrubber = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    on,
    connected,
    direction,
    pressureTank,
    pressureLimitTank,
    pressurePump,
    pressureLimitPump,
    hasHypernobCrystal,
    reactionSuppressionEnabled,
    filterTypes = [],
  } = data;

  return (
    <Window width={400} height={350}>
      <Window.Content>
        <Section
          title={t('ui.pipe_scrubber.status')}
          buttons={
            !!hasHypernobCrystal && (
              <Button
                icon={reactionSuppressionEnabled ? 'snowflake' : 'times'}
                selected={reactionSuppressionEnabled}
                onClick={() => act('reaction_suppression')}
              >
                {reactionSuppressionEnabled
                  ? t('ui.pipe_scrubber.reaction_suppression_enabled')
                  : t('ui.pipe_scrubber.reaction_suppression_disabled')}
              </Button>
            )
          }
        >
          <LabeledControls p={1}>
            <LabeledControls.Item label={t('ui.pipe_scrubber.buffer_port')}>
              <Box position="relative">
                <Tooltip
                  position="top"
                  content={
                    connected
                      ? t('ui.pipe_scrubber.connected')
                      : t('ui.pipe_scrubber.disconnected')
                  }
                >
                  <Icon
                    size={2}
                    name={connected ? 'plug-circle-check' : 'plug-circle-xmark'}
                    color={connected ? 'good' : 'bad'}
                  />
                </Tooltip>
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label={t('ui.pipe_scrubber.buffer')}>
              <RoundGauge
                size={1.75}
                value={pressurePump}
                minValue={0}
                maxValue={pressureLimitPump}
                alertAfter={pressureLimitPump * 0.7}
                ranges={{
                  good: [0, pressureLimitPump * 0.7],
                  average: [pressureLimitPump * 0.7, pressureLimitPump * 0.85],
                  bad: [pressureLimitPump * 0.85, pressureLimitPump],
                }}
                format={formatPressure}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label={t('ui.pipe_scrubber.tank')}>
              <RoundGauge
                size={1.75}
                value={pressureTank}
                minValue={0}
                maxValue={pressureLimitTank}
                alertAfter={pressureLimitTank * 0.7}
                ranges={{
                  good: [0, pressureLimitTank * 0.7],
                  average: [pressureLimitTank * 0.7, pressureLimitTank * 0.85],
                  bad: [pressureLimitTank * 0.85, pressureLimitTank],
                }}
                format={formatPressure}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label={t('ui.pipe_scrubber.pump')}>
              <Button
                my={0.5}
                width={6}
                lineHeight={2}
                fontSize="18px"
                icon="power-off"
                selected={on}
                onClick={() => act('power')}
              >
                {on ? t('ui.common.on') : t('ui.common.off')}
              </Button>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title={t('ui.pipe_scrubber.direction')}
          buttons={
            <Button onClick={() => act('direction')}>
              {direction
                ? t('ui.pipe_scrubber.buffer_to_tank')
                : t('ui.pipe_scrubber.tank_to_buffer')}
            </Button>
          }
        >
          {!!direction && (
            <>
              <Box>{t('ui.pipe_scrubber.filtering_gases')}</Box>
              <Section>
                {filterTypes.map((filter) => (
                  <Button
                    key={filter.id}
                    icon={filter.enabled ? 'check-square-o' : 'square-o'}
                    content={getGasLabel(filter.gasId, filter.gasName)}
                    selected={filter.enabled}
                    onClick={() =>
                      act('toggle_filter', {
                        val: filter.gasId,
                      })
                    }
                  />
                ))}
              </Section>
            </>
          )}
          {!direction && <Box>{t('ui.pipe_scrubber.dumping_gases')}</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};
