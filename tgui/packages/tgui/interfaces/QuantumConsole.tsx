import {
  Button,
  Collapsible,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { LoadingScreen } from './common/LoadingScreen';

type Data =
  | {
      available_domains: Domain[];
      avatars: Avatar[];
      connected: 1;
      generated_domain: string | null;
      occupants: number;
      points: number;
      randomized: BooleanLike;
      ready: BooleanLike;
      retries_left: number;
      scanner_tier: number;
      broadcasting: BooleanLike;
      broadcasting_on_cd: BooleanLike;
    }
  | {
      connected: 0;
    };

type Avatar = {
  health: number;
  name: string;
  pilot: string;
  brute: number;
  burn: number;
  tox: number;
  oxy: number;
};

type Domain = {
  announce_ghosts: BooleanLike;
  cost: number;
  desc: string;
  difficulty: number;
  id: string;
  is_modular: BooleanLike;
  has_secondary_objectives: BooleanLike;
  name: string;
  reward: number | string;
};

type DomainEntryProps = {
  domain: Domain;
};

type DisplayDetailsProps = {
  amount: number | string;
  color: string;
  icon: string;
};

enum Difficulty {
  None,
  Low,
  Medium,
  High,
}

function isConnected(data: Data): data is Data & { connected: 1 } {
  return data.connected === 1;
}

function getColor(difficulty: number) {
  switch (difficulty) {
    case Difficulty.Low:
      return 'yellow';
    case Difficulty.Medium:
      return 'average';
    case Difficulty.High:
      return 'bad';
    default:
      return 'green';
  }
}

export function QuantumConsole(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization();

  return (
    <Window title={t('ui.quantum_console.title')} width={500} height={500}>
      <Window.Content>
        {!!data.connected && !data.ready && <LoadingScreen />}
        <AccessView />
      </Window.Content>
    </Window>
  );
}

function AccessView(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const [tab, setTab] = useSharedState('tab', 0);

  if (!isConnected(data)) {
    return <NoticeBox danger>{t('ui.quantum_console.no_server_connected')}</NoticeBox>;
  }

  const {
    available_domains = [],
    broadcasting,
    broadcasting_on_cd,
    generated_domain,
    occupants,
    points,
    randomized,
    ready,
  } = data;

  const sorted = available_domains.sort((a, b) => a.cost - b.cost);

  const filtered = sorted.filter((domain) => {
    return domain.difficulty === tab;
  });

  let selected;
  if (generated_domain) {
    selected = randomized
      ? '???'
      : sorted.find(({ id }) => id === generated_domain)?.name;
  } else {
    selected = t('ui.quantum_console.nothing_loaded');
  }

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack fill>
              <Tooltip
                content={t(
                  'ui.quantum_console.broadcast_to_entertainment_monitors',
                )}
              >
                <Button.Checkbox
                  checked={broadcasting}
                  disabled={broadcasting_on_cd}
                  onClick={() => act('broadcast')}
                >
                  {t('ui.quantum_console.broadcast')}
                </Button.Checkbox>
              </Tooltip>
              <Tooltip
                content={t('ui.quantum_console.random_domain_tooltip')}
              >
                <Button
                  disabled={
                    !ready || occupants > 0 || points < 1 || !!generated_domain
                  }
                  icon="random"
                  onClick={() => act('random_domain')}
                  mr={1}
                >
                  {t('ui.common.randomize')}
                </Button>
              </Tooltip>
              <Tooltip
                content={t('ui.quantum_console.accrued_points_for_purchasing_domains')}
              >
                <Icon color="pink" name="star" mr={1} />
                {points}
              </Tooltip>
            </Stack>
          }
          fill
          scrollable
          title={t('ui.quantum_console.virtual_domains')}
        >
          <Tabs fluid>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.None)}
              textColor="white"
              selected={tab === 0}
              onClick={() => setTab(0)}
              icon="chevron-down"
            >
              {t('ui.quantum_console.peaceful')}
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.Low)}
              textColor="black"
              selected={tab === 1}
              onClick={() => setTab(1)}
              icon="chevron-down"
            >
              {t('ui.common.easy')}
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.Medium)}
              textColor="white"
              selected={tab === 2}
              onClick={() => setTab(2)}
              icon="chevron-down"
            >
              {t('ui.common.medium')}
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.High)}
              textColor="white"
              selected={tab === 3}
              onClick={() => setTab(3)}
              icon="chevron-down"
            >
              {t('ui.common.hard')} <Icon name="skull" ml={1} />{' '}
            </Tabs.Tab>
          </Tabs>
          {filtered.map((domain) => (
            <DomainEntry key={domain.id} domain={domain} />
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <AvatarDisplay />
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack fill>
            <Stack.Item grow>
              <NoticeBox info={!!generated_domain}>{selected}</NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Tooltip content={t('ui.quantum_console.stop_domain_tooltip')}>
                <Button.Confirm
                  disabled={!ready || !generated_domain}
                  onClick={() => act('stop_domain')}
                >
                  {t('ui.quantum_console.stop_domain')}
                </Button.Confirm>
              </Tooltip>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function DomainEntry(props: DomainEntryProps) {
  const { t } = usePreferencesLocalization();
  const {
    domain: {
      announce_ghosts,
      cost,
      desc,
      difficulty,
      id,
      is_modular,
      has_secondary_objectives,
      name,
      reward,
    },
  } = props;
  const { act, data } = useBackend<Data>();
  if (!isConnected(data)) {
    return null;
  }

  const { generated_domain, ready, occupants, randomized, points } = data;

  const current = generated_domain === id;
  const occupied = occupants > 0;
  let buttonIcon, buttonName;
  if (randomized) {
    buttonIcon = '';
    buttonName = '???';
  } else if (current) {
    buttonIcon = 'download';
    buttonName = t('ui.quantum_console.deployed');
  } else {
    buttonIcon = 'coins';
    buttonName = t('ui.quantum_console.deploy');
  }

  const canView = name !== '???';

  return (
    <Collapsible
      buttons={
        <Tooltip
          content={
            !!generated_domain ? t('ui.quantum_console.stop_current_domain_first') : ''
          }
        >
          <Button
            disabled={!!generated_domain || !ready || occupied || points < cost}
            icon={buttonIcon}
            onClick={() => act('set_domain', { id })}
          >
            {buttonName}
          </Button>
        </Tooltip>
      }
      color={getColor(difficulty)}
      title={
        <>
          {name}
          {!!is_modular && canView && <Icon name="cubes" ml={1} />}
          {!!has_secondary_objectives && canView && <Icon name="gem" ml={1} />}
          {!!announce_ghosts && canView && <Icon name="ghost" ml={1} />}
        </>
      }
    >
      <Stack height={5}>
        <Stack.Item color="label" grow={4}>
          {desc}
          {!!is_modular && ` (${t('ui.quantum_console.modular')})`}
          {!!has_secondary_objectives &&
            ` (${t('ui.quantum_console.secondary_objective_available')})`}
          {!!announce_ghosts && ` (${t('ui.quantum_console.ghost_interaction')})`}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Table>
            <Table.Row>
              <Tooltip content={t('ui.quantum_console.points_cost_for_deploying_domain')}>
                <DisplayDetails amount={cost} color="pink" icon="star" />
              </Tooltip>
            </Table.Row>
            <Table.Row>
              <Tooltip content={t('ui.quantum_console.reward_for_completing_domain')}>
                <DisplayDetails amount={reward} color="gold" icon="coins" />
              </Tooltip>
            </Table.Row>
          </Table>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
}

const AvatarDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  if (!isConnected(data)) {
    return null;
  }

  const { avatars = [], generated_domain, retries_left } = data;

  return (
    <Section
      title={t('ui.quantum_console.connected_clients')}
      buttons={
        <Stack align="center">
          {!!generated_domain && (
            <Stack.Item>
              <Tooltip
                content={t('ui.quantum_console.available_bandwidth_for_new_connections')}
              >
                <DisplayDetails
                  color="green"
                  icon="broadcast-tower"
                  amount={retries_left}
                />
              </Tooltip>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tooltip content={t('ui.quantum_console.refresh_avatar_data')}>
              <Button icon="sync" onClick={() => act('refresh')}>
                {t('ui.common.refresh')}
              </Button>
            </Tooltip>
          </Stack.Item>
        </Stack>
      }
    >
      <Table>
        {avatars.map(({ health, name, pilot, brute, burn, tox, oxy }) => (
          <Table.Row key={name}>
            <Table.Cell color="label">
              {pilot} {t('ui.quantum_console.as')}{' '}
              <span style={{ color: 'white' }}>&quot;{name}&quot;</span>
            </Table.Cell>
            <Table.Cell collapsing>
              <Stack>
                {brute === 0 && burn === 0 && tox === 0 && oxy === 0 && (
                  <Stack.Item>
                    <Icon color="green" name="check" />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Icon color={brute > 50 ? 'bad' : 'gray'} name="tint" />
                </Stack.Item>
                <Stack.Item>
                  <Icon color={burn > 50 ? 'average' : 'gray'} name="fire" />
                </Stack.Item>
                <Stack.Item>
                  <Icon
                    color={tox > 50 ? 'green' : 'gray'}
                    name="skull-crossbones"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Icon color={oxy > 50 ? 'blue' : 'gray'} name="lungs" />
                </Stack.Item>
              </Stack>
            </Table.Cell>
            <Table.Cell>
              <ProgressBar
                minValue={-100}
                maxValue={100}
                ranges={{
                  good: [90, Infinity],
                  average: [50, 89],
                  bad: [-Infinity, 45],
                }}
                value={health}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const DisplayDetails = (props: DisplayDetailsProps) => {
  const { t } = usePreferencesLocalization();
  const { amount = 0, color, icon = 'star' } = props;

  if (amount === 0) {
    return <Table.Cell color="label">{t('ui.common.none')}</Table.Cell>;
  }

  if (typeof amount === 'string') {
    return <Table.Cell color="label">{String(amount)}</Table.Cell>; // don't ask
  }

  if (amount > 4) {
    return (
      <Table.Cell>
        <Stack>
          <Stack.Item>{amount}</Stack.Item>
          <Stack.Item>
            <Icon color={color} name={icon} />
          </Stack.Item>
        </Stack>
      </Table.Cell>
    );
  }

  return (
    <Table.Cell>
      <Stack>
        {Array.from({ length: amount }, (_, index) => (
          <Stack.Item key={index}>
            <Icon color={color} name={icon} />
          </Stack.Item>
        ))}
      </Stack>
    </Table.Cell>
  );
};
