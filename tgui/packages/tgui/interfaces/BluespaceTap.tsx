import {
  Blink,
  Box,
  Button,
  Collapsible,
  Dimmer,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BluespaceTapProduct = {
  key: string;
  name: string;
  price: number;
};

type BluespaceTapData = {
  portaling: boolean;
  desiredMiningPower: number;
  miningPower: number;
  points: number;
  totalPoints: number;
  powerUse: number;
  availablePower: number;
  emagged: boolean;
  dirty: boolean;
  autoShutown: boolean;
  stabilizers: boolean;
  stabilizerPower: number;
  stabilizerPriority: boolean;
  product: BluespaceTapProduct[];
};

const Incursion = () => {
  const { data } = useBackend<BluespaceTapData>();
  const { portaling } = data;

  if (!portaling) {
    return null;
  }

  return (
    <Dimmer fontSize="256px" backgroundColor="rgba(35,0,0,0.85)">
      <Blink
        interval={Math.random() > 0.25 ? 750 + 400 * Math.random() : 290 + 150 * Math.random()}
        time={60 + 150 * Math.random()}
      >
        <Stack mb="30px" fontSize="256px">
          <Stack.Item bold color="red" fontSize="256px" textAlign="center">
            <Icon name="skull" size={14} mb="64px" />
            <br />
            E$#OR:& U#KN!WN IN%ERF#R_NCE
          </Stack.Item>
        </Stack>
      </Blink>
    </Dimmer>
  );
};

const Alerts = () => {
  const { data } = useBackend<BluespaceTapData>();
  const { miningPower, stabilizerPower, emagged, autoShutown, stabilizers } = data;

  if (!autoShutown && !emagged) {
    return <NoticeBox danger>Auto shutdown disabled</NoticeBox>;
  }

  if (emagged) {
    return <NoticeBox danger>All safeties disabled</NoticeBox>;
  }

  if (miningPower <= 15000000) {
    return null;
  }

  if (!stabilizers) {
    return <NoticeBox danger>Stabilizers disabled, instability likely</NoticeBox>;
  }

  if (miningPower > stabilizerPower + 15000000) {
    return <NoticeBox danger>Stabilizers overwhelmed, instability likely</NoticeBox>;
  }

  return <NoticeBox>High power level detected, stabilizers engaged</NoticeBox>;
};

export const BluespaceTap = () => {
  const { act, data } = useBackend<BluespaceTapData>();
  const {
    desiredMiningPower,
    miningPower,
    points,
    totalPoints,
    powerUse,
    availablePower,
    emagged,
    dirty,
    autoShutown,
    stabilizers,
    stabilizerPower,
    stabilizerPriority,
    product,
  } = data;

  return (
    <Window width={650} height={450}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Incursion />
          <Alerts />
          <Collapsible title="Input Management">
            <Section fill title="Input">
              <Button
                icon={autoShutown && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Auto shutdown"
                color={autoShutown && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip="Turn auto shutdown on or off"
                tooltipPosition="top"
                onClick={() => act('auto_shutdown')}
              />
              <Button
                icon={stabilizers && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Stabilizers"
                color={stabilizers && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip="Turn stabilizers on or off"
                tooltipPosition="top"
                onClick={() => act('stabilizers')}
              />
              <Button
                icon={stabilizerPriority && !emagged ? 'toggle-on' : 'toggle-off'}
                content="Stabilizer priority"
                color={stabilizerPriority && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip="When enabled, mining power will not exceed what the stabilizers can safely support"
                tooltipPosition="top"
                onClick={() => act('stabilizer_priority')}
              />
              <LabeledList>
                <LabeledList.Item label="Desired mining power">
                  {formatPower(desiredMiningPower)}
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="top" label="Set desired mining power">
                  <Stack width="100%">
                    <Stack.Item>
                      <Button
                        icon="step-backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip="Set to 0"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: 0 })}
                      />
                      <Button
                        icon="fast-backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip="Decrease by 10 MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower - 10000000 })}
                      />
                      <Button
                        icon="backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip="Decrease by 1 MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower - 1000000 })}
                      />
                    </Stack.Item>
                    <Stack.Item grow mx={1}>
                      <NumberInput
                        disabled={emagged}
                        minValue={0}
                        value={desiredMiningPower}
                        maxValue={Infinity}
                        step={1}
                        onChange={(value) => act('set', { set_power: value })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="forward"
                        disabled={emagged}
                        tooltip="Increase by 1 MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 1000000 })}
                      />
                      <Button
                        icon="fast-forward"
                        disabled={emagged}
                        tooltip="Increase by 10 MW"
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 10000000 })}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Total power use">{formatPower(powerUse)}</LabeledList.Item>
                <LabeledList.Item label="Mining power use">{formatPower(miningPower)}</LabeledList.Item>
                <LabeledList.Item label="Stabilizer power use">{formatPower(stabilizerPower)}</LabeledList.Item>
                <LabeledList.Item label="Surplus power">{formatPower(availablePower)}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Collapsible>
          <Section fill title="Output">
            {dirty ? (
              <Dimmer backgroundColor="rgba(63, 39, 18, 0.85)">
                <Stack mb="30px" fontSize="256px">
                  <Stack.Item bold color="brown" fontSize="256px" textAlign="center">
                    Blockage detected
                    <br />
                    Cleanup required
                  </Stack.Item>
                </Stack>
              </Dimmer>
            ) : null}
            <Stack>
              <Stack.Item>
                <Box>
                  <LabeledList>
                    <LabeledList.Item label="Available points">{points}</LabeledList.Item>
                    <LabeledList.Item label="Total points">{totalPoints}</LabeledList.Item>
                  </LabeledList>
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Box>
                  <LabeledList>
                    {product.map((singleProduct) => (
                      <LabeledList.Item key={singleProduct.key} label={singleProduct.name}>
                        <Button
                          disabled={singleProduct.price >= points}
                          onClick={() => act('vend', { target: singleProduct.key })}
                          content={singleProduct.price}
                        />
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};