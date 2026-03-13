import {
  AnimatedNumber,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  current_balance: number;
  siphoning: BooleanLike;
  station_name: string;
};

export const BankMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { current_balance, siphoning, station_name } = data;

  return (
    <Window width={350} height={155}>
      <Window.Content>
        <NoticeBox danger>{t('ui.bank_machine.authorized_personnel_only')}</NoticeBox>
        <Section title={`${station_name} Vault`}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.bank_machine.current_balance')}
              buttons={
                <Button
                  icon={siphoning ? 'times' : 'sync'}
                  content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
                  selected={siphoning}
                  onClick={() => act(siphoning ? 'halt' : 'siphon')}
                />
              }
            >
              <AnimatedNumber
                value={current_balance}
                format={(value) => formatMoney(value)}
              />
              {' cr'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
