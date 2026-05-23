import {
  Box,
  Button,
  Icon,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { GasmixParser } from './common/GasmixParser';
import { usePreferencesLocalization } from './localization';

export const AnomalyRefinery = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window title={t('ui.anomaly_refinery.title')} width={620} height={360}>
      <Window.Content>
        <AnomalyRefineryContent />
      </Window.Content>
    </Window>
  );
};

const AnomalyRefineryContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [currentTab, changeTab] = useSharedState('exploderTab', 1);
  const { core, valvePresent, active } = data;

  return (
    <Stack vertical fill>
      {currentTab === 1 && <CoreCompressorContent />}
      {currentTab === 2 && <BombProcessorContent />}
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              disabled={!core || active}
              onClick={() => act('eject_core')}
            >
              {t('ui.anomaly_refinery.eject_core')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon={currentTab === 1 ? 'server' : 'compress-arrows-alt'}
              onClick={() => changeTab(currentTab === 1 ? 2 : 1)}
            >
              {currentTab === 1
                ? t('ui.anomaly_refinery.run_simulations')
                : t('ui.anomaly_refinery.implosion_control')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              disabled={!valvePresent || active}
              onClick={() => act('eject_bomb')}
            >
              {t('ui.anomaly_refinery.eject_bomb')}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const CoreCompressorContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { core, requiredRadius, gasList, valveReady, active, valvePresent } =
    data;
  const tankStatus = (gasmix) =>
    `${gasmix.total_moles ? String(gasmix.total_moles.toFixed(2)) : '-'} ${t(
      'ui.anomaly_refinery.moles_at',
    )} ${
      gasmix.total_moles ? String(gasmix.temperature.toFixed(2)) : '-'
    } ${t('ui.anomaly_refinery.kelvin')}`;
  const tankPressure = (gasmix) =>
    `${gasmix.total_moles ? String(gasmix.pressure.toFixed(2)) : '-'} kPa`;

  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          title={t('ui.anomaly_refinery.inserted_core')}
          buttons={
            <Button
              icon="compress-arrows-alt"
              backgroundColor="red"
              onClick={() => act('start_implosion')}
              disabled={active || !valveReady || !core}
            >
              {t('ui.anomaly_refinery.implode_core')}
            </Button>
          }
        >
          {!core && (
            <Modal textAlign="center">
              {t('ui.anomaly_refinery.no_core_inserted')}
            </Modal>
          )}
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              {core ? core : '-'}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.anomaly_refinery.required_radius')}>
              {requiredRadius
                ? `${requiredRadius} ${t('ui.anomaly_refinery.tiles')}`
                : t('ui.anomaly_refinery.implosion_not_possible')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          title={t('ui.anomaly_refinery.inserted_bomb')}
          buttons={
            <Button
              disabled={!valveReady}
              icon="exchange-alt"
              onClick={() => act('swap')}
            >
              {t('ui.anomaly_refinery.swap_merging_order')}
            </Button>
          }
        >
          {!valvePresent && (
            <Modal textAlign="center">
              {t('ui.anomaly_refinery.no_bomb_inserted')}
            </Modal>
          )}
          <Stack align="center">
            <Stack.Item grow textAlign="center">
              <Box height={2} width="100%" bold>
                {`${t('ui.anomaly_refinery.giver_tank')} (${
                  gasList[1].name ? gasList[1].name : t('ui.common.not_available')
                }` +
                  ')'}
              </Box>
              <Box height={2} width="100%">
                {tankStatus(gasList[1])}
              </Box>
              <Box height={2} width="100%">
                {tankPressure(gasList[1])}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Icon size={2} name="arrow-right" />
            </Stack.Item>
            <Stack.Item grow textAlign="center">
              <Box height={2} width="100%" bold>
                {`${t('ui.anomaly_refinery.target_tank')} (${
                  gasList[0].name ? gasList[0].name : t('ui.common.not_available')
                }` +
                  ')'}
              </Box>
              <Box height={2} width="100%">
                {tankStatus(gasList[0])}
              </Box>
              <Box height={2} width="100%">
                {tankPressure(gasList[0])}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </>
  );
};
const BombProcessorContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { gasList, reactionIncrement } = data;
  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          title={gasList[2].name}
          scrollable
          buttons={
            <Button
              tooltip={
                reactionIncrement === 0
                  ? t('ui.anomaly_refinery.valve_status_closed')
                  : t('ui.anomaly_refinery.valve_status_open_current_reaction') +
                    reactionIncrement
              }
              icon="vial"
              tooltipPosition="left"
              onClick={() => act('react')}
              textAlign="center"
              disabled={!gasList[0].total_moles || !gasList[1].total_moles}
              content={
                reactionIncrement === 0
                  ? t('ui.anomaly_refinery.open_valve')
                  : t('ui.anomaly_refinery.react')
              }
            />
          }
        >
          {!gasList[2].total_moles && (
            <Modal textAlign="center">
              {t('ui.anomaly_refinery.no_gas_present')}
            </Modal>
          )}
          <GasmixParser gasmix={gasList[2]} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          {[gasList[0], gasList[1]].map((individualGasmix) => (
            <Stack.Item grow key={individualGasmix.ref}>
              <Section
                fill
                scrollable
                title={
                  individualGasmix.name
                    ? individualGasmix.name
                    : t('ui.common.not_available')
                }
              >
                {!individualGasmix.total_moles && (
                  <Modal textAlign="center">
                    {t('ui.anomaly_refinery.no_gas_present')}
                  </Modal>
                )}
                <GasmixParser gasmix={individualGasmix} />
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </>
  );
};
