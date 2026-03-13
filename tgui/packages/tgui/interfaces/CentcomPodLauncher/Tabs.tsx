import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { PodLauncherData } from './types';

export function TabPod(props) {
  const { t } = usePreferencesLocalization();
  return (
    <Box color="label">
      {t('ui.centcom_pod_launcher.tab_pod_note_line1')}
      <br />
      {t('ui.centcom_pod_launcher.tab_pod_note_line2')}
    </Box>
  );
}

export function TabBay(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportCentcom')}>
        {t('ui.common.teleport')}
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : t('ui.centcom_pod_launcher.go_back')}
      </Button>
    </>
  );
}

export function TabDrop(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportDropoff')}>
        {t('ui.common.teleport')}
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : t('ui.centcom_pod_launcher.go_back')}
      </Button>
    </>
  );
}
