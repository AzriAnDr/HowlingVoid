import { useState } from 'react';
import {
  Button,
  Collapsible,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  db_connected: boolean;
  cached_ckeys: string[];
  ticket_cache: TicketData[];
  target_ckey?: string;
};

type TicketData = {
  ticket_number: number;
  round_id: number;
  ticket_log: TicketLogData[];
};

type TicketLogData = {
  timestamp: string;
  origin_ckey: string;
  target_ckey: string;
  action: string;
  message: string;
};

enum Pages {
  Cache = 1,
  TicketHistory = 2,
}

export const PlayerTicketHistory = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  const [page, setPage] = useState(
    data.target_ckey ? Pages.TicketHistory : Pages.Cache,
  );

  const [cacheInput, setCacheInput] = useState('');
  const [cacheCount, setCacheCount] = useState(5);

  if (!data.db_connected) {
    return (
      <Window title={t('ui.player_ticket_history.title')} width={300} height={300}>
        <Window.Content>
          <NoticeBox>{t('ui.player_ticket_history.database_not_connected')}</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      width={300}
      height={300}
      title={`${t('ui.player_ticket_history.title')}${
        data.target_ckey ? ` - ${data.target_ckey}` : ''
      }`}
    >
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            key={Pages.Cache}
            selected={page === Pages.Cache}
            onClick={() => setPage(Pages.Cache)}
          >
            {t('ui.player_ticket_history.cache')}
          </Tabs.Tab>
          <Tabs.Tab
            key={Pages.TicketHistory}
            selected={page === Pages.TicketHistory}
            onClick={() => setPage(Pages.TicketHistory)}
          >
            {t('ui.player_ticket_history.ticket_history')}
          </Tabs.Tab>
        </Tabs>
        {page === Pages.TicketHistory && <TicketHistory />}
        {page === Pages.Cache && (
          <Cache
            cacheInput={cacheInput}
            setCacheInput={setCacheInput}
            cacheCount={cacheCount}
            setCacheCount={setCacheCount}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const TicketHistory = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  if (data.ticket_cache === undefined) {
    return (
      <Section>
        <NoticeBox>{t('ui.player_ticket_history.no_player_selected')}</NoticeBox>
      </Section>
    );
  }

  const [activeTicket, setActiveTicket] = useState<TicketData | undefined>();

  // sory by round then ticket number, descending
  data.ticket_cache.sort((b, a) => {
    if (a.round_id === b.round_id) {
      return a.ticket_number - b.ticket_number;
    }
    return a.round_id - b.round_id;
  });

  return (
    <Section>
      {t('ui.player_ticket_history.tickets_order_most_recent_to_oldest')}:
      <hr />
      <Section scrollableHorizontal>
        <Stack>
          {data.ticket_cache.map((ticket, index) => (
            <Stack.Item key={index}>
              <Button
                icon="ticket"
                selected={
                  activeTicket !== undefined &&
                  activeTicket.round_id === ticket.round_id &&
                  activeTicket.ticket_number === ticket.ticket_number
                }
                onClick={() => {
                  setActiveTicket(ticket);
                }}
              >
                {`${ticket.round_id} #${ticket.ticket_number}`}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
      <hr />
      {activeTicket === undefined ? (
        <NoticeBox>{t('ui.player_ticket_history.no_ticket_selected')}</NoticeBox>
      ) : (
        <TicketView ticket={activeTicket} />
      )}
    </Section>
  );
};

type CacheProps = {
  cacheInput: string;
  setCacheInput: (value: string) => void;
  cacheCount: number;
  setCacheCount: (value: number) => void;
};

const Cache = (props: CacheProps) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Section>
      <div>
        {t('ui.player_ticket_history.query_and_cache')}:&nbsp;
        <Input
          value={props.cacheInput}
          onBlur={(value) => props.setCacheInput(value.toLowerCase())}
        />
        <NumberInput
          step={1}
          value={props.cacheCount}
          minValue={1}
          maxValue={20}
          onChange={(value: number) => props.setCacheCount(value)}
        />
        <Button
          icon="search"
          disabled={!props.cacheInput}
          onClick={() => {
            act('cache-user', {
              target: props.cacheInput,
              amount: props.cacheCount,
            });
          }}
        />
      </div>
      <div>
        {data.cached_ckeys.map((ckey) => (
          <Button
            key={ckey}
            icon="user"
            onClick={() => {
              act('select-user', { target: ckey });
            }}
          >
            {ckey}
          </Button>
        ))}
      </div>
    </Section>
  );
};

type TicketViewProps = {
  ticket: TicketData;
};

const TicketView = (props: TicketViewProps) => {
  const { act, data } = useBackend<Data>();
  const [forceExpand, setForceExpand] = useState(false);

  // sort by timestamp
  props.ticket.ticket_log.sort((a, b) => {
    return a.timestamp.localeCompare(b.timestamp);
  });

  return (
    <Section
      buttons={
        <Button
          icon={forceExpand ? 'compress' : 'expand'}
          onClick={() => setForceExpand(!forceExpand)}
        />
      }
    >
      {props.ticket.ticket_log.map((log, index) => (
        <Collapsible
          open={forceExpand}
          key={`${props.ticket.round_id}-${props.ticket.ticket_number}-${index}`}
          title={`${log.action} - ${log.origin_ckey}${
            log.target_ckey ? ` -> ${log.target_ckey}` : ''
          }`}
        >
          {log.message}
        </Collapsible>
      ))}
    </Section>
  );
};
