import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GamePanelData = {
  canSpawn: boolean;
  hasMarkedAtom: boolean;
};

export const GamePanel = () => {
  const { act, data } = useBackend<GamePanelData>();
  const { canSpawn, hasMarkedAtom } = data;
  const spawnTooltip = canSpawn ? undefined : 'Requires spawn rights.';
  const duplicateTooltip = !canSpawn
    ? 'Requires spawn rights.'
    : !hasMarkedAtom
      ? 'Mark an atom via VV to duplicate it.'
      : undefined;

  return (
    <Window title="Game Panel" theme="admin" width={320} height={200}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section title="Creation Tools">
              <Stack vertical>
                <Stack.Item>
                  <Button
                    icon="map-marker"
                    fluid
                    disabled={!canSpawn}
                    tooltip={spawnTooltip}
                    content="Spawn Panel"
                    onClick={() => act('spawn_panel')}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="flask"
                    fluid
                    disabled={!canSpawn}
                    tooltip={spawnTooltip}
                    content="Create Reagent"
                    onClick={() => act('create_reagent')}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="clone"
                    fluid
                    disabled={!canSpawn || !hasMarkedAtom}
                    tooltip={duplicateTooltip}
                    content="Duplicate Marked Datum"
                    onClick={() => act('duplicate_marked')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
