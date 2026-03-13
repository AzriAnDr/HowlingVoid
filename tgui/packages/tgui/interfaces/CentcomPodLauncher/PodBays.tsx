import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { BAYS } from './constants';
import type { PodLauncherData } from './types';

export function PodBays(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { bayNumber } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="trash"
            onClick={() => act('clearBay')}
            tooltip={t('ui.centcom_pod_launcher.clear_selected_bay')}
            tooltipPosition="top-end"
          />
          <Button
            color="transparent"
            icon="question"
            tooltip={t('ui.centcom_pod_launcher.bay_help_tooltip')}
            tooltipPosition="top-end"
          />
        </>
      }
      fill
      title={t('ui.centcom_pod_launcher.bay')}
    >
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          onClick={() => act('switchBay', { bayNumber: `${i + 1}` })}
          selected={bayNumber === `${i + 1}`}
          tooltipPosition="bottom-end"
        >
          {bay.title}
        </Button>
      ))}
    </Section>
  );
}
