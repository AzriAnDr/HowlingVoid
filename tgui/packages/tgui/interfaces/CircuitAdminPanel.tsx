import { Button, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type CircuitAdminPanelData = {
  circuits: {
    ref: string;
    name: string;
    creator: string;
    has_inserter: BooleanLike;
  }[];
};

export const CircuitAdminPanel = (props) => {
  const { act, data } = useBackend<CircuitAdminPanelData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Window title={t('ui.circuit_admin.panel_title')} width={1200} height={500}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow />
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('disable_circuit_sound');
                  }}
                >
                  {t('ui.circuit_admin.disable_all_sound_emitters')}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <Table.Row header>
                <Table.Cell>{t('ui.circuit_admin.circuit_name')}</Table.Cell>

                <Table.Cell>{t('ui.circuit_admin.creator')}</Table.Cell>

                <Table.Cell>{t('ui.common.actions')}</Table.Cell>
              </Table.Row>

              {data.circuits.map((circuit) => {
                const createAct = (action: string) => () => {
                  act(action, { circuit: circuit.ref });
                };

                return (
                  <Table.Row key={circuit.ref}>
                    <Table.Cell>{circuit.name}</Table.Cell>

                    <Table.Cell>{circuit.creator}</Table.Cell>

                    <Table.Cell>
                      <Button onClick={createAct('follow_circuit')}>
                        {t('ui.common.follow')}
                      </Button>

                      <Button onClick={createAct('open_circuit')}>
                        {t('ui.common.open')}
                      </Button>

                      <Button onClick={createAct('vv_circuit')}>VV</Button>

                      <Button onClick={createAct('save_circuit')}>
                        {t('ui.common.save')}
                      </Button>

                      <Button onClick={createAct('duplicate_circuit')}>
                        {t('ui.common.duplicate')}
                      </Button>

                      {!!circuit.has_inserter && (
                        <Button onClick={createAct('open_player_panel')}>
                          {t('ui.circuit_admin.player_panel')}
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
