import { Button, ByondUi, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { POD_GREY, TABPAGES } from './constants';
import { useTab } from './hooks';
import type { PodLauncherData } from './types';

export function ViewTabHolder(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { mapRef, customDropoff, effectReverse } = data;

  const [tab, setTab] = useTab();

  const TabPageComponent = TABPAGES[tab].component;

  return (
    <Section
      buttons={
        <>
          {!!customDropoff && !!effectReverse && (
            <Button
              color="transparent"
              icon="arrow-circle-down"
              inline
              onClick={() => {
                setTab(2);
                act('tabSwitch', { tabIndex: 2 });
              }}
              selected={tab === 2}
              tooltip={t('ui.centcom_pod_launcher.view_dropoff_location')}
            />
          )}
          <Button
            color="transparent"
            icon="rocket"
            inline
            onClick={() => {
              setTab(0);
              act('tabSwitch', { tabIndex: 0 });
            }}
            selected={tab === 0}
            tooltip={t('ui.centcom_pod_launcher.view_pod')}
          />
          <Button
            color="transparent"
            icon="th"
            inline
            onClick={() => {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }}
            selected={tab === 1}
            tooltip={t('ui.centcom_pod_launcher.view_source_bay')}
          />
          <span style={POD_GREY}>|</span>
          <Button
            color="transparent"
            icon="sync-alt"
            inline
            onClick={() => {
              setTab(tab);
              act('refreshView');
            }}
            tooltip={t('ui.centcom_pod_launcher.refresh_view_window')}
          />
        </>
      }
      fill
      title={t('ui.common.view')}
    >
      <Stack fill vertical>
        <Stack.Item>
          <TabPageComponent />
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            params={{
              id: mapRef,
              type: 'map',
              zoom: 0,
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
