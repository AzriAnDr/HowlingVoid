import { Button, Divider, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { DELAYS, REV_DELAYS } from './constants';
import { DelayHelper } from './DelayHelper';
import type { PodLauncherData } from './types';

export function Timing(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { custom_rev_delay, effectReverse } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="undo"
            onClick={() => act('resetTiming')}
            tooltip={t('ui.centcom_pod_launcher.reset_timings_delays')}
            tooltipPosition="bottom-start"
          />
          <Button
            color="transparent"
            disabled={!effectReverse}
            icon={custom_rev_delay === 1 ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggleRevDelays')}
            selected={custom_rev_delay}
            tooltip={t('ui.centcom_pod_launcher.toggle_reverse_delays_tooltip')}
            tooltipPosition="bottom"
          />
        </>
      }
      fill
      title={t('ui.common.time')}
    >
      <DelayHelper delay_list={DELAYS} />
      {!!custom_rev_delay && (
        <>
          <Divider />
          <DelayHelper delay_list={REV_DELAYS} reverse />
        </>
      )}
    </Section>
  );
}
