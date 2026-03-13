import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  BossID: string;
  GameActive: BooleanLike;
  Hitpoints: number;
  PauseState: BooleanLike;
  PlayerHitpoints: number;
  PlayerMP: number;
  Status: string;
  TicketCount: number;
};

export function NtosArcade(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <NtosWindow width={450} height={350}>
      <NtosWindow.Content>
        <Section title={t('ui.ntosarcade.outbomb_cuban_pete_ultra')} textAlign="center">
          <Stack fill>
            <Stack.Item>
              <PlayerStats />
            </Stack.Item>
            <Stack.Item>
              <BossBar />
            </Stack.Item>
          </Stack>
          <BottomButtons />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function PlayerStats(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { PauseState, PlayerHitpoints, PlayerMP, Status } = data;

  return (
    <>
      <LabeledList>
        <LabeledList.Item label={t('ui.ntosarcade.player_health')}>
          <ProgressBar
            value={PlayerHitpoints}
            minValue={0}
            maxValue={30}
            ranges={{
              olive: [31, Infinity],
              good: [20, 31],
              average: [10, 20],
              bad: [-Infinity, 10],
            }}
          >
            {PlayerHitpoints}HP
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntosarcade.player_magic')}>
          <ProgressBar
            value={PlayerMP}
            minValue={0}
            maxValue={10}
            ranges={{
              purple: [11, Infinity],
              violet: [3, 11],
              bad: [-Infinity, 3],
            }}
          >
            {PlayerMP}MP
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <NoticeBox danger={!PauseState}>{Status}</NoticeBox>
    </>
  );
}

function BossBar(props) {
  const { data } = useBackend<Data>();
  const { BossID, Hitpoints } = data;

  return (
    <>
      <ProgressBar
        value={Hitpoints}
        minValue={0}
        maxValue={45}
        ranges={{
          good: [30, Infinity],
          average: [5, 30],
          bad: [-Infinity, 5],
        }}
      >
        <AnimatedNumber value={Hitpoints} />
        HP
      </ProgressBar>
      <Box m={1} />
      <Section inline width="156px" textAlign="center">
        <img src={resolveAsset(BossID)} />
      </Section>
    </>
  );
}

function BottomButtons(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { GameActive, PauseState, TicketCount } = data;

  return (
    <>
      <Button
        icon="fist-raised"
        tooltip={t('ui.ntosarcade.go_in_for_the_kill')}
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Attack')}
      >
        {t('ui.common.attack')}
      </Button>
      <Button
        icon="band-aid"
        tooltip={t('ui.ntosarcade.heal_yourself')}
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Heal')}
      >
        {t('ui.common.heal')}
      </Button>
      <Button
        icon="magic"
        tooltip={t('ui.ntosarcade.recharge_your_magic')}
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Recharge_Power')}
      >
        {t('ui.common.recharge')}
      </Button>

      <Box>
        <Button
          icon="sync-alt"
          tooltip={t('ui.ntosarcade.one_more_game_couldn_t_hurt')}
          tooltipPosition="top"
          disabled={!!GameActive}
          onClick={() => act('Start_Game')}
        >
          {t('ui.ntosarcade.begin_game')}
        </Button>
        <Button
          icon="ticket-alt"
          tooltip={t(
            'ui.ntosarcade.claim_at_your_local_arcade_computer_for_prizes',
          )}
          tooltipPosition="top"
          disabled={!!GameActive}
          onClick={() => act('Dispense_Tickets')}
        >
          {t('ui.ntosarcade.claim_tickets')}
        </Button>
      </Box>
      <Box color={TicketCount >= 1 ? 'good' : 'normal'}>
        {t('ui.ntosarcade.earned_tickets')}: {TicketCount}
      </Box>
    </>
  );
}

