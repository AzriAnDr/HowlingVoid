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
import { usePreferencesLocalization } from './localization';

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
  const { t } = usePreferencesLocalization(data);
  const { miningPower, stabilizerPower, emagged, autoShutown, stabilizers } = data;

  if (!autoShutown && !emagged) {
    return <NoticeBox danger>{t('ui.bluespace_tap.auto_shutdown_disabled')}</NoticeBox>;
  }

  if (emagged) {
    return <NoticeBox danger>{t('ui.bluespace_tap.all_safeties_disabled')}</NoticeBox>;
  }

  if (miningPower <= 15000000) {
    return null;
  }

  if (!stabilizers) {
    return <NoticeBox danger>{t('ui.bluespace_tap.stabilizers_disabled_warning')}</NoticeBox>;
  }

  if (miningPower > stabilizerPower + 15000000) {
    return <NoticeBox danger>{t('ui.bluespace_tap.stabilizers_overwhelmed_warning')}</NoticeBox>;
  }

  return <NoticeBox>{t('ui.bluespace_tap.high_power_stabilizers_engaged')}</NoticeBox>;
};

export const BluespaceTap = () => {
  const { act, data } = useBackend<BluespaceTapData>();
  const { t } = usePreferencesLocalization(data);
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
          <Collapsible title={t('ui.bluespace_tap.input_management')}>
            <Section fill title={t('ui.bluespace_tap.input')}>
              <Button
                icon={autoShutown && !emagged ? 'toggle-on' : 'toggle-off'}
                content={t('ui.bluespace_tap.auto_shutdown')}
                color={autoShutown && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip={t('ui.bluespace_tap.auto_shutdown_tooltip')}
                tooltipPosition="top"
                onClick={() => act('auto_shutdown')}
              />
              <Button
                icon={stabilizers && !emagged ? 'toggle-on' : 'toggle-off'}
                content={t('ui.bluespace_tap.stabilizers')}
                color={stabilizers && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip={t('ui.bluespace_tap.stabilizers_tooltip')}
                tooltipPosition="top"
                onClick={() => act('stabilizers')}
              />
              <Button
                icon={stabilizerPriority && !emagged ? 'toggle-on' : 'toggle-off'}
                content={t('ui.bluespace_tap.stabilizer_priority')}
                color={stabilizerPriority && !emagged ? 'green' : 'red'}
                disabled={emagged}
                tooltip={t('ui.bluespace_tap.stabilizer_priority_tooltip')}
                tooltipPosition="top"
                onClick={() => act('stabilizer_priority')}
              />
              <LabeledList>
                <LabeledList.Item label={t('ui.bluespace_tap.desired_mining_power')}>
                  {formatPower(desiredMiningPower)}
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="top" label={t('ui.bluespace_tap.set_desired_mining_power')}>
                  <Stack width="100%">
                    <Stack.Item>
                      <Button
                        icon="step-backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip={t('ui.bluespace_tap.set_to_zero')}
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: 0 })}
                      />
                      <Button
                        icon="fast-backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip={t('ui.bluespace_tap.decrease_by_10mw')}
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower - 10000000 })}
                      />
                      <Button
                        icon="backward"
                        disabled={desiredMiningPower === 0 || emagged}
                        tooltip={t('ui.bluespace_tap.decrease_by_1mw')}
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
                        tooltip={t('ui.bluespace_tap.increase_by_1mw')}
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 1000000 })}
                      />
                      <Button
                        icon="fast-forward"
                        disabled={emagged}
                        tooltip={t('ui.bluespace_tap.increase_by_10mw')}
                        tooltipPosition="bottom"
                        onClick={() => act('set', { set_power: desiredMiningPower + 10000000 })}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_tap.total_power_use')}>{formatPower(powerUse)}</LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_tap.mining_power_use')}>{formatPower(miningPower)}</LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_tap.stabilizer_power_use')}>{formatPower(stabilizerPower)}</LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_tap.surplus_power')}>{formatPower(availablePower)}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Collapsible>
          <Section fill title={t('ui.bluespace_tap.output')}>
            {dirty ? (
              <Dimmer backgroundColor="rgba(63, 39, 18, 0.85)">
                <Stack mb="30px" fontSize="256px">
                  <Stack.Item bold color="brown" fontSize="256px" textAlign="center">
                    {t('ui.bluespace_tap.blockage_detected')}
                    <br />
                    {t('ui.bluespace_tap.cleanup_required')}
                  </Stack.Item>
                </Stack>
              </Dimmer>
            ) : null}
            <Stack>
              <Stack.Item>
                <Box>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.bluespace_tap.available_points')}>{points}</LabeledList.Item>
                    <LabeledList.Item label={t('ui.bluespace_tap.total_points')}>{totalPoints}</LabeledList.Item>
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
