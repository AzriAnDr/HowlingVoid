import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import {
  AtmosHandbookContent,
  atmosHandbookHooks,
} from './common/AtmosHandbook';
import { type Gasmix, GasmixParser } from './common/GasmixParser';

type Chamber = {
  id: string;
  name: string;
  gasmix?: Gasmix;
  input_info?: { active: boolean; amount: number };
  output_info?: { active: boolean; amount: number };
};

export const AtmosControlConsole = (props) => {
  const { act, data } = useBackend<{
    chambers: Chamber[];
    maxInput: number;
    maxOutput: number;
    reconnecting: boolean;
    control: boolean;
  }>();
  const { t } = usePreferencesLocalization(data);
  const chambers = data.chambers || [];
  const [chamberId, setChamberId] = useState(chambers[0]?.id);
  const selectedChamber =
    chambers.length === 1
      ? chambers[0]
      : chambers.find((chamber) => chamber.id === chamberId);
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks();
  return (
    <Window width={550} height={350}>
      <Window.Content scrollable>
        {chambers.length > 1 && (
          <Section title={t('ui.atmos_control_console.chamber_selection')}>
            <Dropdown
              width="100%"
              options={chambers.map((chamber) => chamber.name)}
              selected={selectedChamber?.name}
              onSelected={(value) =>
                setChamberId(
                  chambers.find((chamber) => chamber.name === value)?.id ||
                    chambers[0].id,
                )
              }
            />
          </Section>
        )}
        <Section
          title={
            selectedChamber
              ? selectedChamber.name
              : t('ui.atmos_control_console.chamber_reading')
          }
          buttons={
            !!data.reconnecting && (
              <Button
                icon="undo"
                content={t('ui.atmos_control_console.reconnect')}
                onClick={() => act('reconnect')}
              />
            )
          }
        >
          {!!selectedChamber && !!selectedChamber.gasmix ? (
            <GasmixParser
              gasmix={selectedChamber.gasmix}
              gasesOnClick={setActiveGasId}
              reactionOnClick={setActiveReactionId}
            />
          ) : (
            <Box italic>{t('ui.atmos_control_console.no_sensors_detected')}</Box>
          )}
        </Section>
        {!!selectedChamber && !!data.control && (
          <Section title={t('ui.atmos_control_console.chamber_controls')}>
            <Stack>
              <Stack.Item grow>
                {selectedChamber.input_info ? (
                  <LabeledList>
                    <LabeledList.Item
                      label={t('ui.atmos_control_console.input_injector')}
                    >
                      <Button
                        icon={
                          selectedChamber.input_info.active
                            ? 'power-off'
                            : 'times'
                        }
                        content={
                          selectedChamber.input_info.active
                            ? t('ui.atmos_control_console.injecting')
                            : t('ui.common.off')
                        }
                        selected={selectedChamber.input_info.active}
                        onClick={() =>
                          act('toggle_input', {
                            chamber: selectedChamber.id,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.atmos_control_console.input_rate')}
                    >
                      <NumberInput
                        step={1}
                        value={Number(selectedChamber.input_info.amount)}
                        unit="L/s"
                        width="63px"
                        minValue={0}
                        maxValue={data.maxInput}
                        onChange={(value) =>
                          act('adjust_input', {
                            chamber: selectedChamber.id,
                            rate: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                ) : (
                  <Box italic>
                    {t('ui.atmos_control_console.no_input_device_detected')}
                  </Box>
                )}
              </Stack.Item>
              <Stack.Item grow>
                {selectedChamber.output_info ? (
                  <LabeledList>
                    <LabeledList.Item
                      label={t('ui.atmos_control_console.output_regulator')}
                    >
                      <Button
                        icon={
                          selectedChamber.output_info.active
                            ? 'power-off'
                            : 'times'
                        }
                        content={
                          selectedChamber.output_info.active
                            ? t('ui.common.open')
                            : t('ui.common.closed')
                        }
                        selected={selectedChamber.output_info.active}
                        onClick={() =>
                          act('toggle_output', {
                            chamber: selectedChamber.id,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t('ui.atmos_control_console.output_pressure')}
                    >
                      <NumberInput
                        value={Number(selectedChamber.output_info.amount)}
                        unit="kPa"
                        width="75px"
                        minValue={0}
                        maxValue={data.maxOutput}
                        step={10}
                        onChange={(value) =>
                          act('adjust_output', {
                            chamber: selectedChamber.id,
                            rate: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                ) : (
                  <Box italic>
                    {t('ui.atmos_control_console.no_output_device_detected')}
                  </Box>
                )}
              </Stack.Item>
            </Stack>
          </Section>
        )}
        <AtmosHandbookContent />
      </Window.Content>
    </Window>
  );
};
