import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { REVERSE_OPTIONS } from './constants';
import { useTab } from './hooks';
import type { PodLauncherData } from './types';

export function ReverseMenu(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const {
    customDropoff,
    effectReverse,
    picking_dropoff_turf,
    reverse_option_list,
  } = data;

  const [tab, setTab] = useTab();

  return (
    <Section
      buttons={
        <Button
          icon={effectReverse ? 'toggle-on' : 'toggle-off'}
          onClick={() => {
            act('effectReverse');
            if (tab === 2) {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
          selected={effectReverse}
          tooltip={t('ui.centcom_pod_launcher.reverse_tooltip')}
          tooltipPosition="bottom"
        />
      }
      fill
      title={t('ui.centcom_pod_launcher.reverse')}
    >
      {!!effectReverse && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              disabled={!effectReverse}
              onClick={() => act('pickDropoffTurf')}
              selected={picking_dropoff_turf}
              tooltip={t('ui.centcom_pod_launcher.dropoff_turf_tooltip')}
              tooltipPosition="bottom-end"
            >
              {t('ui.centcom_pod_launcher.dropoff_turf')}
            </Button>
            <Button
              disabled={!customDropoff}
              icon="trash"
              inline
              onClick={() => {
                act('clearDropoffTurf');
                if (tab === 2) {
                  setTab(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
              tooltip={t('ui.centcom_pod_launcher.clear_dropoff_turf_tooltip')}
              tooltipPosition="bottom"
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                disabled={!effectReverse}
                key={i}
                icon={option.icon}
                inline
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key || option.title,
                  })
                }
                selected={
                  option.key
                    ? reverse_option_list[option.key]
                    : reverse_option_list[option.title]
                }
                tooltip={option.title}
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}
