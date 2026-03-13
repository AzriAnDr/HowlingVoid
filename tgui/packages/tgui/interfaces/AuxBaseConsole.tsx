import { useState } from 'react';
import { Button, NoticeBox, Section, Table, Tabs } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { ShuttleConsoleContent } from './ShuttleConsole';

type Data = {
  type: string;
  blind_drop: BooleanLike;
  turrets: Turret[];
};

type Turret = {
  ref: string;
  key: string;
  name: string;
  integrity: number;
  status: string;
  direction: string;
  distance: number;
};

const STATUS_COLOR_KEYS = {
  ERROR: 'bad',
  Disabled: 'bad',
  Firing: 'average',
  'All Clear': 'good',
} as const;

const STATUS_TEXT_KEYS = {
  ERROR: 'ui.aux_base_console.status_error',
  Disabled: 'ui.aux_base_console.status_disabled',
  Firing: 'ui.aux_base_console.status_firing',
  'All Clear': 'ui.aux_base_console.status_all_clear',
} as const;

const formatTurretStatus = (
  t: (key: string, fallback?: string) => string,
  status: string,
) => {
  const key = STATUS_TEXT_KEYS[status];
  return key ? t(key) : status;
};

enum TAB {
  Shuttle = 1,
  Aux,
}

export const AuxBaseConsole = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [tab, setTab] = useState(TAB.Shuttle);
  const { type, blind_drop, turrets = [] } = data;

  return (
    <Window
      width={turrets.length ? 620 : 350}
      height={turrets.length ? 310 : 260}
    >
      <Window.Content scrollable={!!turrets.length}>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === TAB.Shuttle}
            onClick={() => setTab(TAB.Shuttle)}
          >
            {type === 'shuttle'
              ? t('ui.aux_base_console.shuttle_launch')
              : t('ui.aux_base_console.base_launch')}
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === TAB.Aux}
            onClick={() => setTab(TAB.Aux)}
          >
            {t('ui.aux_base_console.turrets')} ({turrets.length})
          </Tabs.Tab>
        </Tabs>
        {tab === TAB.Shuttle && (
          <ShuttleConsoleContent type={type} blind_drop={blind_drop} />
        )}
        {tab === TAB.Aux && <AuxBaseConsoleContent />}
      </Window.Content>
    </Window>
  );
};

export const AuxBaseConsoleContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { turrets = [] } = data;

  return (
    <Section
      fill
      scrollable
      title={t('ui.aux_base_console.turret_control')}
      buttons={
        !!turrets.length && (
            <Button icon="power-off" onClick={() => act('turrets_power')}>
            {t('ui.aux_base_console.toggle_power')}
            </Button>
        )
      }
    >
      {!turrets.length ? (
        <NoticeBox>{t('ui.aux_base_console.no_connected_turrets')}</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>{t('ui.aux_base_console.unit')}</Table.Cell>
            <Table.Cell>{t('ui.aux_base_console.condition')}</Table.Cell>
            <Table.Cell>{t('ui.common.status')}</Table.Cell>
            <Table.Cell>{t('ui.common.direction')}</Table.Cell>
            <Table.Cell>{t('ui.common.distance')}</Table.Cell>
            <Table.Cell>{t('ui.common.power')}</Table.Cell>
          </Table.Row>
          {turrets.map((turret) => (
            <Table.Row key={turret.key}>
              <Table.Cell bold>{turret.name}</Table.Cell>
              <Table.Cell>{turret.integrity}%</Table.Cell>
              <Table.Cell color={STATUS_COLOR_KEYS[turret.status] || 'bad'}>
                {formatTurretStatus(t, turret.status)}
              </Table.Cell>
              <Table.Cell>{turret.direction}</Table.Cell>
              <Table.Cell>{turret.distance}m</Table.Cell>
              <Table.Cell>
                <Button
                  icon="power-off"
                  onClick={() =>
                    act('single_turret_power', {
                      single_turret_power: turret.ref,
                    })
                  }
                >
                  {t('ui.common.toggle')}
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
