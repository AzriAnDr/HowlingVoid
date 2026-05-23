import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import type { AirAlarmData } from '../types';

const normalizeModeKey = (value: string | undefined) =>
  (value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');

const modeNameKey = (name: string) =>
  `ui.air_alarm.mode_${normalizeModeKey(name)}.name`;

const modeDescKey = (name: string) =>
  `ui.air_alarm.mode_${normalizeModeKey(name)}.desc`;

export function AirAlarmControlModes(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { modes, selectedModePath } = data;

  if (!modes || modes.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        {t('ui.common.nothing_to_show')}
      </NoticeBox>
    );
  }

  return (
    <Stack vertical>
      {modes.map((mode) => (
        <Stack.Item key={mode.path}>
          <Button
            icon={
              mode.path === selectedModePath ? 'check-square-o' : 'square-o'
            }
            color={
              mode.path === selectedModePath && (mode.danger ? 'red' : 'green')
            }
            onClick={() => act('mode', { mode: mode.path })}
          >
            {`${t(modeNameKey(mode.name), mode.name)} - ${t(
              modeDescKey(mode.name),
              mode.desc,
            )}`}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}
