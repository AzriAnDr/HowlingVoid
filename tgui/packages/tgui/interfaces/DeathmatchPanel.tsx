import {
  Button,
  Dropdown,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Lobby = {
  name: string;
  players: number;
  max_players: number;
  map: string;
  playing: BooleanLike;
};

type Data = {
  hosting: BooleanLike;
  admin: BooleanLike;
  playing: string;
  lobbies: Lobby[];
};

export function DeathmatchPanel(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { hosting } = data;

  return (
    <Window title={t('ui.deathmatchpanel.deathmatch_lobbies')} width={360} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox danger>
              {t('ui.deathmatchpanel.return_to_body_warning')}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <LobbyPane />
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!!hosting}
              fluid
              textAlign="center"
              color="good"
              onClick={() => act('host')}
            >
              {t('ui.deathmatchpanel.create_lobby')}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function LobbyPane(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { lobbies = [] } = data;

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row header>
          <Table.Cell>{t('ui.deathmatchpanel.host')}</Table.Cell>
          <Table.Cell>{t('ui.deathmatchpanel.map')}</Table.Cell>
          <Table.Cell>
            <Tooltip content={t('ui.deathmatchpanel.players')}>
              <Icon name="users" />
            </Tooltip>
          </Table.Cell>
          <Table.Cell align="center">
            <Icon name="hammer" />
          </Table.Cell>
        </Table.Row>

        {lobbies.length === 0 && (
          <Table.Row>
            <Table.Cell colSpan={4}>
              <NoticeBox textAlign="center">
                {t('ui.deathmatchpanel.no_lobbies_found_start_one')}
              </NoticeBox>
            </Table.Cell>
          </Table.Row>
        )}

        {lobbies.map((lobby, index) => (
          <LobbyDisplay key={index} lobby={lobby} />
        ))}
      </Table>
    </Section>
  );
}

function LobbyDisplay(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { admin, playing, hosting } = data;
  const { lobby } = props;

  const isActive = (!!hosting || !!playing) && playing !== lobby.name;

  return (
    <Table.Row className="candystripe" key={lobby.name}>
      <Table.Cell>
        {!admin ? (
          lobby.name
        ) : (
          <Dropdown
            width={10}
            noChevron
            selected={lobby.name}
            options={[t('ui.common.close'), t('ui.common.view')]}
            onSelected={(value) =>
              act('admin', {
                id: lobby.name,
                func: value,
              })
            }
          />
        )}
      </Table.Cell>
      <Table.Cell>{lobby.map}</Table.Cell>
      <Table.Cell collapsing>
        {lobby.players}/{lobby.max_players}
      </Table.Cell>
      <Table.Cell collapsing>
        {!lobby.playing ? (
          <Button
            disabled={isActive}
            color="good"
            onClick={() => act('join', { id: lobby.name })}
            width="100%"
            textAlign="center"
          >
            {playing === lobby.name
              ? t('ui.common.view')
              : t('ui.deathmatchpanel.join')}
          </Button>
        ) : (
          <Button
            disabled={isActive}
            color="good"
            onClick={() => act('spectate', { id: lobby.name })}
          >
            {t('ui.deathmatchpanel.spectate')}
          </Button>
        )}
      </Table.Cell>
    </Table.Row>
  );
}
