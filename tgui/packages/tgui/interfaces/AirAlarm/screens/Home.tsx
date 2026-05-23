import type { Dispatch, SetStateAction } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import type { AirAlarmData, AlarmScreen } from '../types';

type Props = {
  setScreen?: Dispatch<SetStateAction<AlarmScreen>>;
};

export function AirAlarmControlHome(props: Props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { setScreen } = props;
  if (!setScreen) {
    throw new Error('setScreen is required');
  }

  const {
    allowLinkChange,
    atmosAlarm,
    filteringPath,
    panicSiphonPath,
    selectedModePath,
    sensor,
  } = data;

  const isPanicSiphoning = selectedModePath === panicSiphonPath;
  return (
    <Stack vertical>
      <Stack.Item>
        <Button
          icon={atmosAlarm ? 'exclamation-triangle' : 'exclamation'}
          color={atmosAlarm && 'caution'}
          onClick={() => act(atmosAlarm ? 'reset' : 'alarm')}
        >
          {t('ui.air_alarm.area_atmosphere_alarm')}
        </Button>
      </Stack.Item>
      <Stack.Item mb={1}>
        <Button
          icon={isPanicSiphoning ? 'exclamation-triangle' : 'exclamation'}
          color={isPanicSiphoning && 'danger'}
          onClick={() =>
            act('mode', {
              mode: isPanicSiphoning ? filteringPath : panicSiphonPath,
            })
          }
        >
          {t('ui.air_alarm.mode_panic_siphon.name')}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="sign-out-alt" onClick={() => setScreen('vents')}>
          {t('ui.air_alarm.vent_controls')}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="filter" onClick={() => setScreen('scrubbers')}>
          {t('ui.air_alarm.scrubber_controls')}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="cog" onClick={() => setScreen('modes')}>
          {t('ui.air_alarm.operating_mode')}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="chart-bar" onClick={() => setScreen('thresholds')}>
          {t('ui.air_alarm.alarm_thresholds')}
        </Button>
      </Stack.Item>
      {!!sensor && !!allowLinkChange && (
        <Stack.Item>
          <Button.Confirm
            icon="link-slash"
            color="danger"
            onClick={() => act('disconnect_sensor')}
          >
            {t('ui.air_alarm.disconnect_sensor')}
          </Button.Confirm>
        </Stack.Item>
      )}
    </Stack>
  );
}
