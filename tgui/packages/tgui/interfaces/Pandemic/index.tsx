import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, NoticeBox, Stack } from 'tgui-core/components';

import { BeakerDisplay } from './Beaker';
import { SpecimenDisplay } from './Specimen';
import type { Data } from './types';

const formatDeciseconds = (deciseconds = 0) => {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return `${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
};

export const Pandemic = (props) => {
  const { data } = useBackend<Data>();
  const {
    has_beaker,
    has_blood,
    storytellerReplicationDescription,
    storytellerReplicationLabel,
    storytellerReplicationRemaining,
    storytellerReplicationSpeed,
  } = data;

  return (
    <Window width={650} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!storytellerReplicationLabel && (
            <Stack.Item>
              <NoticeBox
                {...((storytellerReplicationSpeed || 1) < 1
                  ? { danger: true }
                  : { info: true })}
              >
                {storytellerReplicationLabel}
                {!!storytellerReplicationRemaining &&
                  ` (${formatDeciseconds(storytellerReplicationRemaining)} left)`}
                {!!storytellerReplicationDescription && (
                  <Box mt={0.5}>{storytellerReplicationDescription}</Box>
                )}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!has_beaker && !!has_blood && (
            <Stack.Item grow>
              <SpecimenDisplay />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
