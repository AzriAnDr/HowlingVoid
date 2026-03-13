import { vecLength, vecSubtract } from 'tgui-core/vector';
import { sortBy } from 'es-toolkit';
import { map } from 'es-toolkit/compat';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Table,
} from 'tgui-core/components';
import { flow } from 'tgui-core/fp';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const coordsToVec = (coords) => map(coords.split(', '), parseFloat);

export const Gps = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { currentArea, currentCoords, globalmode, power, tag, updating } = data;
  const signals = flow([
    (signals) =>
      map(signals, (signal, index) => {
        // Calculate distance to the target. BYOND distance is capped to 127,
        // that's why we roll our own calculations here.
        const dist =
          signal.dist &&
          Math.round(
            vecLength(
              vecSubtract(
                coordsToVec(currentCoords),
                coordsToVec(signal.coords),
              ),
            ),
          );
        return { ...signal, dist, index };
      }),
    (signals) =>
      sortBy(signals, [
        // Signals with distance metric go first
        (signal) => signal.dist === undefined,
        // Sort alphabetically
        (signal) => signal.entrytag,
      ]),
  ])(data.signals || []);
  return (
    <Window title={t('ui.gps.global_positioning_system')} width={470} height={700}>
      <Window.Content scrollable>
        <Section
          title={t('ui.common.controls')}
          buttons={
            <Button
              icon="power-off"
              content={power ? t('ui.common.on') : t('ui.common.off')}
              selected={power}
              onClick={() => act('power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.tag')}>
              <Button
                icon="pencil-alt"
                content={tag}
                onClick={() => act('rename')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.gps.scan_mode')}>
              <Button
                icon={updating ? 'unlock' : 'lock'}
                content={updating ? t('ui.common.auto') : t('ui.common.manual')}
                color={!updating && 'bad'}
                onClick={() => act('updating')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.range')}>
              <Button
                icon="sync"
                content={globalmode ? t('ui.gps.maximum') : t('ui.gps.local')}
                selected={!globalmode}
                onClick={() => act('globalmode')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!power && (
          <>
            <Section title={t('ui.gps.current_location')}>
              <Box fontSize="18px">
                {currentArea} ({currentCoords})
              </Box>
            </Section>
            <Section title={t('ui.gps.detected_signals')}>
              <Table>
                <Table.Row bold>
                  <Table.Cell content={t('ui.common.name')} />
                  <Table.Cell collapsing content={t('ui.common.direction')} />
                  <Table.Cell collapsing content={t('ui.common.coordinates')} />
                </Table.Row>
                {signals.map((signal) => (
                  <Table.Row
                    key={signal.entrytag + signal.coords + signal.index}
                    className="candystripe"
                  >
                    <Table.Cell bold color="label">
                      {signal.entrytag}
                    </Table.Cell>
                    <Table.Cell
                      collapsing
                      opacity={
                        signal.dist !== undefined &&
                        clamp(1.2 / Math.log(Math.E + signal.dist / 20), 0.4, 1)
                      }
                    >
                      {signal.degrees !== undefined && (
                        <Icon
                          mr={1}
                          size={1.2}
                          name="arrow-up"
                          rotation={signal.degrees}
                        />
                      )}
                      {signal.dist !== undefined && `${signal.dist}m`}
                    </Table.Cell>
                    <Table.Cell collapsing>{signal.coords}</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
