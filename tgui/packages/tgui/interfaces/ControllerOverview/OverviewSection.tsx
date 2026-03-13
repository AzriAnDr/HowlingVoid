import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { ControllerData } from './types';

export function OverviewSection(props) {
  const { act, data } = useBackend<ControllerData>();
  const { t } = usePreferencesLocalization(data);
  const {
    fast_update,
    rolling_length,
    map_cpu,
    subsystems = [],
    world_time,
  } = data;

  let avgUsage = 0;
  let overallOverrun = 0;
  for (let i = 0; i < subsystems.length; i++) {
    avgUsage += subsystems[i].usage_per_tick;
    overallOverrun += subsystems[i].overtime;
  }

  return (
    <Section
      fill
      title={t('ui.controller_overview.master_overview')}
      buttons={
        <>
          <Button
            tooltip={t('ui.controller_overview.fast_update')}
            icon={fast_update ? 'check-square-o' : 'square-o'}
            color={fast_update && 'average'}
            onClick={() => {
              act('toggle_fast_update');
            }}
          >
            {t('ui.controller_overview.fast')}
          </Button>
          <Button.Input
            buttonText={t('ui.controller_overview.average_seconds').replace(
              '{seconds}',
              (rolling_length / 10).toFixed(2),
            )}
            value={(rolling_length / 10).toString()}
            onCommit={(value) => {
              act('set_rolling_length', {
                rolling_length: value,
              });
            }}
          />
        </>
      }
    >
      <Stack fill>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label={t('ui.controller_overview.world_time')}>
              {world_time.toFixed(1)}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.controller_overview.map_cpu')}>
              {map_cpu.toFixed(2)}%
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.controller_overview.overall_avg_usage')}
            >
              {avgUsage.toFixed(2)}%
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.controller_overview.overall_overrun')}
            >
              {overallOverrun.toFixed(2)}%
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
