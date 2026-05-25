import {
  Box,
  Button,
  DmIcon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { Fallback } from './Fallback';
import type { PlantAnalyzerData } from './types';

export function PlantAnalyzerTrayStats(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { t } = usePreferencesLocalization(data);
  const { tray_data } = data;

  if (!tray_data) {
    // This shouldn't be rendered if tray_data is null
    return null;
  }

  return (
    <Section title={capitalizeFirst(tray_data.name)}>
      <Stack>
        <Stack.Item mx={2}>
          <Stack vertical align="center" width="100px">
            <Stack.Item>
              <DmIcon
                fallback={Fallback}
                icon={tray_data.icon}
                icon_state={tray_data.icon_state}
                height="64px"
                width="64px"
              />
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item>
                  <Button
                    icon="hand-holding-droplet"
                    color={tray_data.self_sustaining ? 'yellow' : 'transparent'}
                    tooltip={
                      tray_data.self_sustaining
                        ? 'Autogrow active - providing light, reclaiming water and reducing weed and pest levels.'
                        : 'Autogrow inactive'
                    }
                    disabled={1}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="wind"
                    color={tray_data.being_pollinated ? 'teal' : 'transparent'}
                    tooltip={
                      tray_data.being_pollinated
                        ? 'Cross pollinating nearby plants - potentially sharing plant reagents.'
                        : 'Not cross pollinating'
                    }
                    disabled={1}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="sun"
                    color={tray_data.yield_mod > 1 ? 'olive' : 'transparent'}
                    tooltip={
                      tray_data.yield_mod > 1
                        ? 'Pollinated by bees - doubling yield.'
                        : 'No yield modifier'
                    }
                    disabled={1}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item width="100%">
          {!!tray_data.storyteller_anomaly_title && (
            <NoticeBox
              mb={1}
              {...(tray_data.storyteller_anomaly_positive
                ? { info: true }
                : { danger: true })}
            >
              <Box bold>
                Detected botanical anomaly: {tray_data.storyteller_anomaly_title}
              </Box>
              {!!tray_data.storyteller_anomaly_description && (
                <Box mt={0.5}>{tray_data.storyteller_anomaly_description}</Box>
              )}
              <Box mt={0.5} color="label">
                Estimated dissipation:{' '}
                {formatDeciseconds(tray_data.storyteller_anomaly_remaining || 0)}
                {!!tray_data.storyteller_anomaly_modifier &&
                  ` | Measured bias ${Math.round(
                    ((tray_data.storyteller_anomaly_modifier || 1) - 1) * 100,
                  )}%`}
              </Box>
            </NoticeBox>
          )}
          <LabeledList>
            <LabeledList.Item
              label={t('ui.plant_analyzer.water')}
              tooltip={t('ui.plant_analyzer.tooltip_water')}
            >
              <ProgressBar
                value={tray_data.water / tray_data.water_max}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {tray_data.water} / {tray_data.water_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label={t('ui.plant_analyzer.nutrients')}
              tooltip={t('ui.plant_analyzer.tooltip_nutrients')}
            >
              {tray_data.reagents.length > 0 ? (
                <Box>
                  <ProgressBar
                    width="234px" // why won't you scale??
                    position="absolute"
                    value={0}
                    color="transparent"
                    style={{
                      zIndex: 3,
                      border: `1px solid ${nutriToColor(tray_data.nutri, tray_data.nutri_max)}`,
                    }}
                  >
                    {tray_data.nutri} / {tray_data.nutri_max}
                  </ProgressBar>
                  {tray_data.reagents.map((reagent, i) => (
                    <ProgressBar
                      key={`${i}-${reagent.name}`}
                      mb={-0.5}
                      width={`${(reagent.volume / tray_data.nutri_max) * 234}px`}
                      value={1}
                      color={reagent.color}
                      empty
                    />
                  ))}
                </Box>
              ) : (
                <ProgressBar
                  value={tray_data.nutri / tray_data.nutri_max}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.3, 0.7],
                    bad: [0, 0.3],
                  }}
                >
                  {tray_data.nutri} / {tray_data.nutri_max}
                </ProgressBar>
              )}
            </LabeledList.Item>

            <LabeledList.Item
              label={t('ui.plant_analyzer.light')}
              tooltip={t('ui.plant_analyzer.tooltip_light')}
            >
              <ProgressBar
                value={tray_data.light_level}
                maxValue={1}
                ranges={{
                  bad: [0, 0.2],
                  average: [0.2, 0.4],
                  good: [0.4, Infinity],
                }}
              >
                {Math.round(tray_data.light_level * 100)}%
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label={t('ui.plant_analyzer.weeds')}
              tooltip={t('ui.plant_analyzer.tooltip_weeds')}
            >
              <ProgressBar
                value={tray_data.weeds}
                maxValue={tray_data.weeds_max}
                ranges={{
                  good: [-Infinity, 5],
                  average: [5, 10],
                  bad: [10, tray_data.weeds_max],
                }}
              >
                {tray_data.weeds} / {tray_data.weeds_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label={t('ui.plant_analyzer.pests')}
              tooltip={t('ui.plant_analyzer.tooltip_pests')}
            >
              <ProgressBar
                value={tray_data.pests}
                maxValue={tray_data.pests_max}
                ranges={{
                  good: [-Infinity, 4],
                  average: [4, 8],
                  bad: [8, tray_data.pests_max],
                }}
              >
                {tray_data.pests} / {tray_data.pests_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label={t('ui.plant_analyzer.toxins')}
              tooltip={t('ui.plant_analyzer.tooltip_toxins')}
            >
              <ProgressBar
                value={tray_data.toxins}
                maxValue={tray_data.toxins_max}
                ranges={{
                  good: [-Infinity, 0],
                  average: [1, Math.round(tray_data.toxins_max * 0.5)],
                  bad: [Math.round(tray_data.toxins_max * 0.5), Infinity],
                }}
              >
                {tray_data.toxins} / {tray_data.toxins_max}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

export function PlantAnalyzerTrayChems(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { t } = usePreferencesLocalization(data);
  const { tray_data } = data;

  if (!tray_data) {
    // This shouldn't be rendered if tray_data is null
    return null;
  }

  return (
    <Section title={capitalizeFirst(`${tray_data.name} Nutrients`)}>
      {tray_data.reagents.length === 0 ? (
        <NoticeBox color="red" align="center">
          {t('ui.plant_analyzer.no_reagents_detected')}
        </NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>{t('ui.common.reagent')}</Table.Cell>
            <Table.Cell>{t('ui.common.volume')}</Table.Cell>
          </Table.Row>
          {tray_data.reagents.map((reagent, i) => (
            <Table.Row key={i} className="candystripe">
              <Table.Cell py={0.5} pl={1}>
                {reagent.name}
              </Table.Cell>
              <Table.Cell>{reagent.volume}u</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}

function nutriToColor(nutri: number, maxNutri: number) {
  if (nutri < maxNutri * 0.3) return 'red';
  if (nutri < maxNutri * 0.7) return 'yellow';
  return 'green';
}

function formatDeciseconds(deciseconds = 0) {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return `${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
}
