import { useBackend } from 'tgui/backend';
import { NoticeBox, VirtualList } from 'tgui-core/components';

import { Vent } from '../../common/AtmosControls';
import { usePreferencesLocalization } from '../../localization';
import type { AirAlarmData } from '../types';

export function AirAlarmControlVents(props) {
  const { data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { vents } = data;

  if (!vents || vents.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        {t('ui.common.nothing_to_show')}
      </NoticeBox>
    );
  }

  return (
    <VirtualList>
      {vents.map((vent) => (
        <Vent key={vent.refID} {...vent} />
      ))}
    </VirtualList>
  );
}
