import { useBackend } from 'tgui/backend';
import { NoticeBox, VirtualList } from 'tgui-core/components';

import { Scrubber } from '../../common/AtmosControls';
import { usePreferencesLocalization } from '../../localization';
import type { AirAlarmData } from '../types';

export function AirAlarmControlScrubbers(props) {
  const { data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { scrubbers } = data;

  if (!scrubbers || scrubbers.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        {t('ui.common.nothing_to_show')}
      </NoticeBox>
    );
  }

  return (
    <VirtualList>
      {scrubbers.map((scrubber) => (
        <Scrubber key={scrubber.refID} {...scrubber} />
      ))}
    </VirtualList>
  );
}
