import {
  AnimatedNumber,
  Box,
  Button,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  enabled: BooleanLike;
  dos_capacity: number;
  dos_overload: number;
  dos_crashed: BooleanLike;
};

export const NtnetRelay = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { enabled, dos_capacity, dos_overload, dos_crashed } = data;

  return (
    <Window title={t('ui.ntnet_relay.title')} width={400} height={300}>
      <Window.Content>
        <Section
          title={t('ui.ntnet_relay.network_buffer')}
          buttons={
              <Button
                icon="power-off"
                selected={enabled}
                content={
                  enabled
                    ? t('ui.common.enabled_uppercase')
                    : t('ui.common.disabled_uppercase')
                }
                onClick={() => act('toggle')}
              />
          }
        >
          {!dos_crashed ? (
            <ProgressBar
              value={dos_overload}
              minValue={0}
              maxValue={dos_capacity}
            >
              <AnimatedNumber value={dos_overload} /> GQ
              {' / '}
              {dos_capacity} GQ
            </ProgressBar>
          ) : (
            <Box fontFamily="monospace">
              <Box fontSize="20px">{t('ui.ntnet_relay.network_buffer_overflow')}</Box>
              <Box fontSize="16px">{t('ui.ntnet_relay.overload_recovery_mode')}</Box>
              <Box>{t('ui.ntnet_relay.outage_warning')}</Box>
              <Box fontSize="20px" color="bad">
                {t('ui.ntnet_relay.administrator_override')}
              </Box>
              <Box fontSize="16px" color="bad">
                {t('ui.ntnet_relay.caution_data_loss')}
              </Box>
              <Button
                icon="signal"
                content={t('ui.ntnet_relay.purge_buffer')}
                mt={1}
                color="bad"
                onClick={() => act('restart')}
              />
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
