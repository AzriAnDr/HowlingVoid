// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  connected: BooleanLike;
  notice: string;
  unlocked: BooleanLike;
  target: string;
  powernet_power: number;
  capacitor_charge: number;
  target_capacitor_charge: number;
  max_capacitor_charge: number;
  status: string;
};

export const BluespaceArtilleryNova = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const {
    notice,
    connected,
    unlocked,
    target,
    powernet_power,
    capacitor_charge,
    target_capacitor_charge,
    max_capacitor_charge,
    status,
  } = data;

  return (
    <Window width={600} height={600}>
      <Window.Content>
        {!!notice && <NoticeBox>{notice}</NoticeBox>}
        {connected ? (
          <>
            <Section title={t('ui.bluespace_artillery.system_status')}>
              <Box
                color={status !== 'SYSTEM READY' ? 'bad' : 'green'}
                fontSize="25px"
              >
                {status}
              </Box>
            </Section>
            <Section
              title={t('ui.bluespace_artillery.capacitors')}
              buttons={
                <Button
                  content={t('ui.bluespace_artillery.charge_capacitors')}
                  color="orange"
                  onClick={() => act('charge')}
                />
              }
            >
              <LabeledList>
                <LabeledList.Item label={t('ui.bluespace_artillery.capacitor_charge')}>
                  {formatPower(capacitor_charge, 1)}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_artillery.available_power')}>
                  {formatPower(powernet_power, 1)}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.bluespace_artillery.target_charge')}>
                  <Slider
                    value={target_capacitor_charge}
                    fillValue={target_capacitor_charge}
                    minValue={0}
                    maxValue={max_capacitor_charge}
                    step={100000}
                    stepPixelSize={1}
                    format={(value) => formatPower(value, 1)}
                    onChange={(e, value) =>
                      act('capacitor_target_change', {
                        capacitor_target: value,
                      })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section
              title={t('ui.common.target')}
              buttons={
                <Button
                  icon="crosshairs"
                  disabled={!unlocked}
                  onClick={() => act('recalibrate')}
                />
              }
            >
              <Box color={target ? 'average' : 'bad'} fontSize="25px">
                {target || t('ui.bluespace_artillery.no_target_set')}
              </Box>
            </Section>
            <Section>
              {unlocked ? (
                <Box style={{ margin: 'auto' }}>
                  <Button
                    fluid
                    content={t('ui.bluespace_artillery.fire')}
                    color="bad"
                    disabled={!target || status !== 'SYSTEM READY'}
                    fontSize="30px"
                    textAlign="center"
                    lineHeight="46px"
                    onClick={() => act('fire')}
                  />
                </Box>
              ) : (
                <>
                  <Box color="bad" fontSize="18px">
                    {t('ui.bluespace_artillery.currently_locked')}
                  </Box>
                  <Box mt={1}>
                    {t('ui.bluespace_artillery.awaiting_authorization')}
                  </Box>
                </>
              )}
            </Section>
          </>
        ) : (
          <Section>
            <LabeledList>
              <LabeledList.Item label={t('ui.common.maintenance')}>
                <Button
                  icon="wrench"
                  content={t('ui.bluespace_artillery.complete_deployment')}
                  onClick={() => act('build')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
