import { Button } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { SWIPE_NEEDED } from './constants';
import type { CommsConsoleData } from './types';

type Props = {
  alertLevel: string;
  onClick: () => void;
};

export function AlertButton(props: Props) {
  const { alertLevel, onClick } = props;

  const { act, data } = useBackend<CommsConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const { canSetAlertLevel } = data;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && 'good'}
      onClick={() => {
        if (thisIsCurrent) {
          return;
        }

        if (canSetAlertLevel === SWIPE_NEEDED) {
          onClick();
        } else {
          act('changeSecurityLevel', {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    >
      {t(`ui.communications_console.alert_level_${alertLevel}`, capitalize(alertLevel))}
    </Button>
  );
}
