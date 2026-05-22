import {
  Box,
  Button,
  Divider,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ShuttleData = {
  etaSeconds: number;
  state: number;
  isIdleOrRecalled: BooleanLike;
  canSendBack: BooleanLike;
  canCall: BooleanLike;
  callDisabledReason?: string | null;
};

type RoundData = {
  duration: string;
  shuttle: ShuttleData;
  delayEnd: BooleanLike;
  readyForReboot: BooleanLike;
  ctfEnabled: BooleanLike;
};

type Counts = {
  connected: number;
  lobby: number;
  living: number;
  livingConnected: number;
  antagonists: number;
  antagonistsAlive: number;
  antagonistsDead: number;
  security: number;
  securityDead: number;
  skipped: number;
  drones: number;
  observers: number;
  observersConnected: number;
  brains: number;
  other: number;
};

type AntagonistEntry = {
  display: string;
  role: string;
  status: string;
  ckey?: string;
  mobRef?: string;
  mindRef?: string;
  canFollow: BooleanLike;
  hasClient: BooleanLike;
};

type AntagonistSection = {
  title: string;
  entries: AntagonistEntry[];
  type: string;
};

type DiskCoords = {
  x: number;
  y: number;
  z: number;
};

type NukeDisk = {
  ref: string;
  name: string;
  fake: BooleanLike;
  secured: BooleanLike;
  lastMove?: number | null;
  holder?: string | null;
  holderType?: string | null;
  location?: string | null;
  coords?: DiskCoords | null;
};

type LoneOperative = {
  weight: number;
  occurrences: number;
  maxOccurrences: number;
  chance: number;
};

type NukeData = {
  disks: NukeDisk[];
  code?: string | null;
  loneOp?: LoneOperative | null;
  hasDisks: BooleanLike;
};

type Permissions = {
  canAdmin: BooleanLike;
  canServer: BooleanLike;
};

type AntagonistPanelData = {
  hasRights: BooleanLike;
  roundStarted: BooleanLike;
  round?: RoundData;
  counts?: Counts;
  antagonists?: AntagonistSection[];
  opforHtml?: string | null;
  nuke?: NukeData;
  permissions?: Permissions;
};

const asBool = (value: BooleanLike | string | undefined | null) =>
  value === true || value === 1 || value === '1' || value === 'true';

const formatSeconds = (seconds?: number | null) => {
  if (seconds === null || seconds === undefined) {
    return '—';
  }
  const total = Math.max(Number(seconds) || 0, 0);
  const mins = Math.floor(total / 60);
  const secs = Math.floor(total % 60)
    .toString()
    .padStart(2, '0');
  return `${mins}:${secs}`;
};

const formatDeciseconds = (ds?: number | null) => {
  if (ds === null || ds === undefined) {
    return '—';
  }
  return formatSeconds(Math.floor(Number(ds) / 10));
};

const statusColor = (status: string) => {
  const lowered = status.toLowerCase();
  if (lowered.includes('dead') || lowered.includes('destroyed')) {
    return 'bad';
  }
  if (lowered.includes('no client')) {
    return 'average';
  }
  return 'good';
};

const coordsText = (coords?: DiskCoords | null) =>
  coords ? `${coords.x}, ${coords.y}, ${coords.z}` : '—';

const DiskSecureIcon = ({ secured }: { secured: BooleanLike }) => (
  <Tooltip content={asBool(secured) ? 'Secured' : 'Unsecured'}>
    <Icon
      color={asBool(secured) ? 'good' : 'bad'}
      name={asBool(secured) ? 'lock' : 'unlock'}
    />
  </Tooltip>
);

const AntagStatus = ({ status }: { status: string }) => (
  <Box color={statusColor(status)}>{status}</Box>
);

const RoundControls = ({
  round,
  permissions,
}: {
  round?: RoundData;
  permissions: Permissions;
}) => {
  const { act } = useBackend<AntagonistPanelData>();
  const shuttle = round?.shuttle;
  const canServer = asBool(permissions.canServer);
  const delayed = asBool(round?.delayEnd);
  const ctfEnabled = asBool(round?.ctfEnabled);
  const readyForReboot = asBool(round?.readyForReboot);

  return (
    <Section
      title="Round Controls"
      buttons={
        <Stack wrap justify="end" g={1}>
          <Stack.Item>
            <Button
              icon="rocket"
              content="Call Shuttle"
              disabled={!asBool(shuttle?.canCall)}
              tooltip={shuttle?.callDisabledReason || undefined}
              onClick={() => act('call_shuttle')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="undo"
              content="Send Back"
              disabled={!asBool(shuttle?.canSendBack)}
              onClick={() => act('send_shuttle_back')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="clock"
              content="Edit Time"
              disabled={!canServer}
              tooltip={canServer ? undefined : 'Requires server rights.'}
              onClick={() => act('edit_shuttle_time')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="hourglass-half"
              content={delayed ? 'Undelay End' : 'Delay End'}
              color={delayed ? 'average' : 'warning'}
              disabled={!canServer}
              tooltip={canServer ? undefined : 'Requires server rights.'}
              onClick={() =>
                act(delayed ? 'undelay_round_end' : 'delay_round_end')
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="flag-checkered"
              color="danger"
              content="End Round"
              onClick={() => act('end_round')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrows-spin"
              content="Reboot"
              onClick={() => act('reboot_world')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="users-viewfinder"
              content="Check Teams"
              onClick={() => act('check_teams')}
            />
          </Stack.Item>
        </Stack>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Duration">
          {round?.duration || '—'}
        </LabeledList.Item>
        <LabeledList.Item label="Shuttle ETA">
          {formatSeconds(shuttle?.etaSeconds)}{' '}
          <Box
            inline
            color={asBool(shuttle?.isIdleOrRecalled) ? 'label' : 'good'}
          >
            {asBool(shuttle?.isIdleOrRecalled) ? 'Idle / Recalled' : 'In Transit'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="CTF">
          <Stack align="center" g={1}>
            <Box color={ctfEnabled ? 'good' : 'label'}>
              {ctfEnabled ? 'Enabled' : 'Disabled'}
            </Box>
            <Button compact onClick={() => act('toggle_ctf')}>
              Toggle
            </Button>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Reboot">
          <Box color={readyForReboot ? 'warning' : 'label'}>
            {readyForReboot ? 'Ready for Reboot' : 'Not Ready'}
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PopulationStats = ({ counts }: { counts?: Counts }) => {
  if (!counts) {
    return null;
  }

  return (
    <Section title="Population">
      <LabeledList>
        <LabeledList.Item label="Players">
          {counts.connected - counts.lobby} in-round / {counts.connected}{' '}
          connected / {counts.lobby} lobby
        </LabeledList.Item>
        <LabeledList.Item label="Living">
          {counts.livingConnected} active /{' '}
          {counts.living - counts.livingConnected} disconnected
        </LabeledList.Item>
        <LabeledList.Item label="Antagonists">
          {counts.antagonistsAlive} alive / {counts.antagonistsDead} dead /{' '}
          {counts.antagonists} total
        </LabeledList.Item>
        <LabeledList.Item label="Security">
          {counts.security - counts.securityDead} alive / {counts.securityDead}{' '}
          dead / {counts.security} total
        </LabeledList.Item>
        <LabeledList.Item label="Observers">
          {counts.observersConnected} active /{' '}
          {counts.observers - counts.observersConnected} disconnected /{' '}
          {counts.brains} brains
        </LabeledList.Item>
        <LabeledList.Item label="Other">
          Skipped: {counts.skipped} | Drones: {counts.drones} | Other:{' '}
          {counts.other}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const NukeSection = ({ nuke }: { nuke?: NukeData }) => {
  const { act } = useBackend<AntagonistPanelData>();
  const disks = nuke?.disks || [];
  const loneOp = nuke?.loneOp;

  return (
    <Section
      title="Nuclear Authentication"
      buttons={
        <Stack g={1}>
          <Button
            icon="pen"
            content="Set Code"
            onClick={() => act('set_nuke_code')}
          />
          <Button
            icon="shuffle"
            content="Randomize"
            onClick={() => act('randomize_nuke_code')}
          />
          <Button
            icon="plus"
            content="Spawn Disk"
            onClick={() => act('respawn_disk')}
          />
          <Button
            icon="bullseye"
            content="Teleport First"
            disabled={!disks.length}
            onClick={() =>
              disks[0] && act('teleport_disk', { target: disks[0].ref })
            }
          />
        </Stack>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Code">
          {nuke?.code ? (
            <Box fontFamily="monospace">{nuke.code}</Box>
          ) : (
            <Box color="label">No code detected</Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Lone Operative">
          {loneOp ? (
            <Box>
              Weight {loneOp.weight} | Chance {loneOp.chance}% | Occurrences{' '}
              {loneOp.occurrences}/{loneOp.maxOccurrences}
            </Box>
          ) : (
            <Box color="label">Controller not found</Box>
          )}
        </LabeledList.Item>
      </LabeledList>

      <Divider />

      {disks.length ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Disk</Table.Cell>
            <Table.Cell>Secured</Table.Cell>
            <Table.Cell>Location</Table.Cell>
            <Table.Cell>Holder</Table.Cell>
            <Table.Cell>Last Move</Table.Cell>
            <Table.Cell collapsing>Actions</Table.Cell>
          </Table.Row>
          {disks.map((disk) => (
            <Table.Row key={disk.ref} color={asBool(disk.fake) ? 'average' : undefined}>
              <Table.Cell>
                <Stack align="center" g={1}>
                  <Box>{disk.name}</Box>
                  {asBool(disk.fake) && (
                    <Tooltip content="This is a fake disk.">
                      <Icon name="mask" color="average" />
                    </Tooltip>
                  )}
                </Stack>
              </Table.Cell>
              <Table.Cell>
                <DiskSecureIcon secured={disk.secured} />
              </Table.Cell>
              <Table.Cell>
                <Box>{disk.location || 'Unknown'}</Box>
                <Box color="label">{coordsText(disk.coords)}</Box>
              </Table.Cell>
              <Table.Cell>{disk.holder || disk.holderType || '—'}</Table.Cell>
              <Table.Cell>{formatDeciseconds(disk.lastMove)}</Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="bullseye"
                  content="Teleport"
                  onClick={() => act('teleport_disk', { target: disk.ref })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <NoticeBox>No tracked disks right now.</NoticeBox>
      )}
    </Section>
  );
};

const AntagonistSectionList = ({
  sections,
}: {
  sections: AntagonistSection[];
}) => {
  const { act } = useBackend<AntagonistPanelData>();

  if (!sections.length) {
    return (
      <Section title="Antagonists">
        <NoticeBox>No antagonists found.</NoticeBox>
      </Section>
    );
  }

  return (
    <Section title="Antagonists" scrollable>
      <Stack vertical g={1}>
        {sections.map((section) => (
          <Section key={section.title} title={section.title}>
            <Table>
              <Table.Row header>
                <Table.Cell>Name</Table.Cell>
                <Table.Cell>Role</Table.Cell>
                <Table.Cell>Status</Table.Cell>
                <Table.Cell>Ckey</Table.Cell>
                <Table.Cell collapsing>Actions</Table.Cell>
              </Table.Row>
              {section.entries.map((entry) => (
                <Table.Row
                  key={`${section.title}-${entry.display}-${entry.ckey || ''}`}
                  color={!asBool(entry.hasClient) ? 'average' : undefined}
                >
                  <Table.Cell>{entry.display}</Table.Cell>
                  <Table.Cell>{entry.role}</Table.Cell>
                  <Table.Cell>
                    <AntagStatus status={entry.status} />
                  </Table.Cell>
                  <Table.Cell>{entry.ckey || '—'}</Table.Cell>
                  <Table.Cell collapsing>
                    <Stack justify="end" g={1}>
                      <Button
                        icon="eye"
                        tooltip={asBool(entry.canFollow) ? 'Follow target' : 'No body to follow'}
                        disabled={!asBool(entry.canFollow)}
                        onClick={() => act('follow', { target: entry.mobRef })}
                      />
                      <Button
                        icon="list-ol"
                        tooltip="Traitor Panel"
                        onClick={() =>
                          act('traitor_panel', {
                            target: entry.mindRef || entry.mobRef,
                          })
                        }
                      />
                      <Button
                        icon="comment"
                        tooltip={entry.ckey ? 'PM player' : 'No ckey'}
                        disabled={!entry.ckey}
                        onClick={() => entry.ckey && act('pm', { ckey: entry.ckey })}
                      />
                    </Stack>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        ))}
      </Stack>
    </Section>
  );
};

export const AntagonistPanel = () => {
  const { data } = useBackend<AntagonistPanelData>();
  const {
    hasRights,
    roundStarted,
    round,
    counts,
    antagonists = [],
    opforHtml,
    nuke,
  } = data;
  const permissions = data.permissions || { canAdmin: false, canServer: false };

  if (!asBool(hasRights)) {
    return (
      <Window title="Antagonist Panel" theme="admin" width={1000} height={720}>
        <Window.Content>
          <NoticeBox color="bad">
            You need admin rights to view this panel.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  if (!asBool(roundStarted)) {
    return (
      <Window title="Antagonist Panel" theme="admin" width={1000} height={720}>
        <Window.Content>
          <NoticeBox color="average">The game has not started yet.</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Antagonist Panel" theme="admin" width={1100} height={780}>
      <Window.Content scrollable>
        <Stack vertical g={1}>
          <RoundControls round={round} permissions={permissions} />
          <Stack g={1} wrap>
            <Stack.Item grow basis="50%">
              <PopulationStats counts={counts} />
            </Stack.Item>
            <Stack.Item grow basis="50%">
              <NukeSection nuke={nuke} />
            </Stack.Item>
          </Stack>

          {!!opforHtml && (
            <Section title="Opposing Force">
              <Box dangerouslySetInnerHTML={{ __html: opforHtml }} />
            </Section>
          )}

          <AntagonistSectionList sections={antagonists} />
        </Stack>
      </Window.Content>
    </Window>
  );
};
