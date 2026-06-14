// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type ReactorInfo = {
  venting: BooleanLike;
  vent_dir: BooleanLike;
  active: BooleanLike;
  safety: BooleanLike;
  overclocked: BooleanLike;
  criticality: number;
  health_percent: number;
  max_power_generation: number;
  safeties_max_power_generation: number;
  raw_last_power_output: number;
  last_power_output: string;
  consuming: string;
  consuming_unit: string;
  raw_consuming: number;
  rod: BooleanLike;
  rod_mix_pressure: number;
  rod_pressure_limit: number;
  rod_mix_temperature: number;
  rod_trit_moles: number;

  // Misc
  jammed: BooleanLike;
  meltdown: BooleanLike;
};

export const RBMK2 = (props) => {
  const { act, data } = useBackend<ReactorInfo>();
  const { t } = usePreferencesLocalization(data);
  const statusWidth = '64px';

  return (
    <Window title={t('ui.rbmk.title')} width={360} height={710}>
      <Window.Content>
        <Section textAlign="center" title={t('ui.rbmk.status')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.rbmk.activity')}
              tooltip={t('ui.rbmk.tooltip_activity')}
            >
              <NoticeBox
                danger
                textAlign="center"
                backgroundColor={data.active ? 'good' : 'bad'}
              >
                {data.active ? t('ui.rbmk.online').toUpperCase() : t('ui.rbmk.offline').toUpperCase()}
              </NoticeBox>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.reaction')}
              tooltip={t('ui.rbmk.tooltip_reaction')}
            >
              <NoticeBox
                danger
                textAlign="center"
                backgroundColor={data.meltdown ? 'bad' : 'good'}
              >
                {data.meltdown ? t('ui.rbmk.meltdown').toUpperCase() : t('ui.rbmk.stable').toUpperCase()}
              </NoticeBox>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.clearance')}
              tooltip={t('ui.rbmk.tooltip_clearance')}
            >
              <NoticeBox
                danger
                textAlign="center"
                backgroundColor={data.jammed ? 'bad' : 'good'}
              >
                {data.jammed ? t('ui.rbmk.jammed').toUpperCase() : t('ui.rbmk.safe').toUpperCase()}
              </NoticeBox>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.power_generation')}
              tooltip={t('ui.rbmk.tooltip_power_generation')}
            >
              <ProgressBar
                value={data.raw_last_power_output}
                minValue={0}
                maxValue={data.safeties_max_power_generation}
                ranges={{
                  maroon: [data.max_power_generation * 10, Infinity],
                  bad: [
                    data.max_power_generation,
                    data.max_power_generation * 10,
                  ],
                  yellow: [
                    data.safeties_max_power_generation,
                    data.max_power_generation,
                  ],
                  good: [0, data.safeties_max_power_generation],
                }}
              >
                {data.last_power_output}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.rod_pressure')}
              tooltip={t('ui.rbmk.tooltip_rod_pressure')}
            >
              <ProgressBar
                value={data.rod_mix_pressure}
                minValue={0}
                maxValue={data.rod_pressure_limit}
                ranges={{
                  maroon: [data.rod_pressure_limit * 2, Infinity],
                  bad: [data.rod_pressure_limit, data.rod_pressure_limit * 2],
                  orange: [
                    data.rod_pressure_limit * 0.75,
                    data.rod_pressure_limit,
                  ],
                  yellow: [
                    data.rod_pressure_limit * 0.5,
                    data.rod_pressure_limit * 0.75,
                  ],
                  good: [-Infinity, data.rod_pressure_limit * 0.5],
                }}
              >
                {data.rod_mix_pressure} kPa
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.rod_temperature')}
              tooltip={t('ui.rbmk.tooltip_rod_temperature')}
            >
              <ProgressBar
                value={data.rod_mix_temperature}
                // Thermomachine/gas meter colors + maroon.
                ranges={{
                  maroon: [2000, Infinity],
                  red: [700, 2000],
                  orange: [460, 700],
                  yellow: [340, 460],
                  good: [200, 340],
                  cyan: [120, 200],
                  blue: [60, 120],
                  violet: [-Infinity, 60],
                }}
              >
                {data.rod_mix_temperature} K
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.remaining_fuel')}
              tooltip={t('ui.rbmk.tooltip_remaining_fuel')}
            >
              <ProgressBar // Changes color based on rate of consumption while giving you a total reading.
                value={data.rod_trit_moles}
                minValue={0}
                maxValue={9}
                ranges={{
                  bad: [-Infinity, data.raw_consuming * 300],
                  orange: [data.raw_consuming * 300, data.raw_consuming * 600],
                  yellow: [data.raw_consuming * 600, data.raw_consuming * 900],
                  good: [data.raw_consuming * 900, Infinity],
                }}
              >
                {data.rod_trit_moles} Moles
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.rbmk.tritium_usage')}>
              {data.consuming}/s
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.rbmk.criticality')}
              tooltip={t('ui.rbmk.tooltip_criticality')}
            >
              <ProgressBar
                value={data.criticality}
                minValue={0}
                maxValue={100}
                ranges={{
                  maroon: [100, Infinity],
                  bad: [75, 100],
                  orange: [50, 75],
                  yellow: [25, 50],
                  good: [-Infinity, 25],
                }}
              >
                {data.criticality}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.rbmk.integrity')}>
              <ProgressBar
                value={data.health_percent}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [80, Infinity],
                  yellow: [50, 80],
                  orange: [25, 50],
                  bad: [5, 25],
                  maroon: [-Infinity, 5],
                }}
              >
                {data.health_percent}%
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.rbmk.controls')} textAlign="center">
          <LabeledList>
            <Button.Confirm
              tooltip={t('ui.rbmk.tooltip_activate')}
              textAlign="center"
              width="100%"
              icon="fa-power-off"
              confirmContent={t('ui.common.are_you_sure')}
              color={data.active ? 'yellow' : 'good'}
              onClick={() => act('activate')}
            >
              {data.active ? t('ui.common.deactivate') : t('ui.common.activate')}
            </Button.Confirm>
            {data.rod ? (
              <Button.Confirm
                tooltip={t('ui.rbmk.tooltip_eject_rod')}
                textAlign="center"
                width="100%"
                icon="fa-eject"
                color="bad"
                onClick={() => act('eject')}
              >
                {t('ui.rbmk.eject_fuel_rod')}
              </Button.Confirm>
            ) : (
              <NoticeBox danger textAlign="center">
                {t('ui.rbmk.no_control_rod')}
              </NoticeBox>
            )}
          </LabeledList>
          <Section title={t('ui.rbmk.vent_controls')} textAlign="center">
            {t('ui.rbmk.vent_notice')}
            <br />
            <i>{t('ui.rbmk.vent_notice_sub')}</i>
          </Section>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.rbmk.vent_power')}
              buttons={
                <>
                  <Box
                    inline
                    mr={1}
                    width={statusWidth}
                    textAlign="right"
                    color={data.venting ? 'good' : 'bad'}
                  >
                    {data.venting ? t('ui.rbmk.online').toUpperCase() : t('ui.rbmk.offline').toUpperCase()}
                  </Box>
                  <Button.Confirm
                    tooltip={t('ui.rbmk.tooltip_toggle_vents')}
                    textAlign="center"
                    icon="fa-fan"
                    color={data.venting ? 'bad' : 'good'}
                    onClick={() => act('venttoggle')}
                  />
                </>
              }
            />
            <LabeledList.Item
              label={t('ui.rbmk.vent_direction')}
              buttons={
                <>
                  <Box
                    inline
                    mr={1}
                    width={statusWidth}
                    textAlign="right"
                    color={data.vent_dir ? 'bad' : 'good'}
                  >
                    {data.vent_dir ? t('ui.rbmk.pulling').toUpperCase() : t('ui.rbmk.pushing').toUpperCase()}
                  </Box>
                  <Button
                    tooltip={t('ui.rbmk.tooltip_vent_pull')}
                    icon="fa-clock-rotate-left"
                    disabled={data.venting}
                    color={data.vent_dir ? 'yellow' : 'blue'}
                    onClick={() => act('ventpull')}
                  />
                  <Button
                    tooltip={t('ui.rbmk.tooltip_vent_push')}
                    icon="fa-clock-rotate-left fa-flip-horizontal"
                    disabled={data.venting}
                    color={data.vent_dir ? 'blue' : 'good'}
                    onClick={() => act('ventpush')}
                  />
                </>
              }
            />
          </LabeledList>
          <Section title={t('ui.rbmk.advanced_controls')} textAlign="center">
            {t('ui.rbmk.advanced_warning')}
          </Section>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.rbmk.safeties')}
              buttons={
                <>
                  <Box
                    inline
                    mr={1}
                    width={statusWidth}
                    textAlign="right"
                    color={data.safety ? 'good' : 'bad'}
                  >
                    {data.safety ? t('ui.rbmk.online').toUpperCase() : t('ui.rbmk.offline').toUpperCase()}
                  </Box>
                  <Button.Confirm
                    tooltip={t('ui.rbmk.tooltip_toggle_safeties')}
                    icon="fa-helmet-safety"
                    color={data.safety ? 'bad' : 'good'}
                    onClick={() => act('safetytoggle')}
                  />
                </>
              }
            />
            <LabeledList.Item
              label={t('ui.rbmk.overclock')}
              buttons={
                <>
                  <Box
                    inline
                    mr={1}
                    width={statusWidth}
                    textAlign="right"
                    color={data.overclocked ? 'good' : 'bad'}
                  >
                    {data.overclocked ? t('ui.rbmk.online').toUpperCase() : t('ui.rbmk.offline').toUpperCase()}
                  </Box>
                  <Button.Confirm
                    tooltip={t('ui.rbmk.tooltip_toggle_overclock')}
                    icon="exclamation-triangle"
                    color={data.overclocked ? 'yellow' : 'good'}
                    onClick={() => act('overclocktoggle')}
                  />
                </>
              }
            />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
