import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Input,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  name: string;
  owner_token: string;
  money: number;
  transaction_list: Transactions[];
  wanted_token: string;
};

type Transactions = {
  adjusted_money: number;
  reason: string;
};

export const NtosPay = (props) => {
  return (
    <NtosWindow width={495} height={655}>
      <NtosWindow.Content>
        <NtosPayContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosPayContent = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { name } = data;

  if (!name) {
    return (
      <NoticeBox>
        {t('ui.ntos_pay.insert_id_card_notice')}
      </NoticeBox>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Introduction />
      </Stack.Item>
      <Stack.Item>
        <TransferSection />
      </Stack.Item>
      <Stack.Item grow>
        <TransactionHistory />
      </Stack.Item>
    </Stack>
  );
};

/** Displays the user's name and balance. */
const Introduction = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { name, owner_token, money } = data;
  return (
    <Section textAlign="center">
      <Table>
        <Table.Row>
          {t('ui.ntos_pay.hi')}, {name}.
        </Table.Row>
        <Table.Row>
          {t('ui.ntos_pay.your_pay_token_is')} {owner_token}.
        </Table.Row>
        <Table.Row>
          {t('ui.ntos_pay.account_balance')}: {money}{' '}
          {money === 1 ? t('ui.ntos_pay.credit') : t('ui.ntos_pay.credits')}
        </Table.Row>
      </Table>
    </Section>
  );
};

/** Displays the transfer section. */
const TransferSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { money, wanted_token } = data;

  const [token, setToken] = useState('');
  const [moneyToSend, setMoneyToSend] = useState(1);
  const [nameToToken, setNameToToken] = useState('');
  const [moneyToSendIsValid, setMoneyToSendIsValid] = useState(true);

  return (
    <Stack>
      <Stack.Item>
        <Section title={t('ui.ntos_pay.transfer_money')}>
          <Box>
            <Tooltip
              content={t('ui.ntos_pay.enter_pay_token_tooltip')}
              position="top"
            >
              <Input
                placeholder={t('ui.ntos_pay.pay_token')}
                width="190px"
                onChange={setToken}
              />
            </Tooltip>
          </Box>
          <Tooltip
            content={t('ui.ntos_pay.enter_amount_tooltip')}
            position="top"
          >
            <RestrictedInput
              width="83px"
              minValue={1}
              maxValue={money}
              onChange={setMoneyToSend}
              onValidationChange={setMoneyToSendIsValid}
              value={moneyToSend}
            />
          </Tooltip>
          <Button
            disabled={!moneyToSendIsValid}
            onClick={() =>
              act('Transaction', {
                token: token,
                amount: moneyToSend,
              })
            }
          >
            {t('ui.ntos_pay.send_credits')}
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t('ui.ntos_pay.get_token')} width="270px" height="98px">
          <Box>
            <Input
              placeholder={t('ui.ntos_pay.full_name_of_account')}
              width="190px"
              onChange={setNameToToken}
            />
            <Button
              onClick={() =>
                act('GetPayToken', {
                  wanted_name: nameToToken,
                })
              }
            >
              {t('ui.ntos_pay.get_it')}
            </Button>
          </Box>
          <Divider hidden />
          <Box nowrap>{wanted_token}</Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays the transaction history. */
const TransactionHistory = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { transaction_list = [] } = data;

  return (
    <Section fill title={t('ui.ntos_pay.transaction_history')}>
      <Section fill scrollable title={<TableHeaders />}>
        <Table>
          {transaction_list.map((log, index) => (
            <Table.Row
              key={index}
              className="candystripe"
              color={log.adjusted_money < 1 ? 'red' : 'green'}
            >
              <Table.Cell width="100px">
                {log.adjusted_money > 1 ? '+' : ''}
                {log.adjusted_money}
              </Table.Cell>
              <Table.Cell textAlign="center">{log.reason}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Section>
  );
};

/** Renders a set of sticky headers */
const TableHeaders = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Table>
      <Table.Row>
        <Table.Cell color="label" width="100px">
          {t('ui.ntos_pay.amount')}
        </Table.Cell>
        <Table.Cell color="label" textAlign="center">
          {t('ui.ntos_pay.reason')}
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
