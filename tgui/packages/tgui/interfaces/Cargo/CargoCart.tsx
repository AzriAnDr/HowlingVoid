import { useState } from 'react';
import {
  Button,
  Icon,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { CargoData } from './types';

export function CargoCart(props) {
  const { act, data } = useBackend<CargoData>();
  const { t } = usePreferencesLocalization(data);
  const { can_send, away, cart = [], docked, location } = data;

  const sendable = !!away && !!docked;

  return (
    <Stack fill vertical g={0}>
      <Stack.Item grow>
        <Section fill scrollable>
          <CheckoutItems />
        </Section>
      </Stack.Item>
      {cart.length > 0 && !!can_send && (
        <Stack.Item>
          <Section textAlign="right">
            <Stack fill align="center">
              <Stack.Item grow>
                {!sendable && (
                  <Icon mr={0.5} size={1.5} color="blue" name="toolbox" spin />
                )}
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="green"
                  disabled={!sendable}
                  onClick={() => act('send')}
                  px={2}
                  py={1}
                  tooltip={sendable ? '' : `Shuttle is at ${location}`}
                >
                  {t('ui.cargo.confirm_order')}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}

function CheckoutItems(props) {
  const { act, data } = useBackend<CargoData>();
  const { t } = usePreferencesLocalization(data);
  const { can_send, cart = [], max_order } = data;

  const [isValid, setIsValid] = useState(true);

  if (cart.length === 0) {
    return <NoticeBox>{t('ui.cargo.nothing_in_cart')}</NoticeBox>;
  }

  return (
    <Table>
      <Table.Row header color="gray">
        <Table.Cell collapsing>{t('ui.common.id')}</Table.Cell>
        <Table.Cell>{t('ui.cargo.supply_type')}</Table.Cell>
        <Table.Cell>{t('ui.common.amount')}</Table.Cell>
        <Table.Cell collapsing />
        <Table.Cell collapsing textAlign="right">
          {t('ui.common.cost')}
        </Table.Cell>
      </Table.Row>

      {cart.map((entry) => (
        <Table.Row className="candystripe" key={entry.cart_key || entry.id}>
          <Table.Cell collapsing color="label">
            #{entry.id}
          </Table.Cell>
          <Table.Cell>{entry.object}</Table.Cell>

          <Table.Cell width={11}>
            {!!can_send && !!entry.can_be_cancelled ? (
              <>
                <Button
                  icon="minus"
                  onClick={() =>
                    act('remove', {
                      cart_key: entry.cart_key,
                      order_name: entry.object,
                    })
                  }
                />
                <RestrictedInput
                  width={5}
                  minValue={0}
                  maxValue={max_order}
                  value={entry.amount}
                  onEnter={(value) =>
                    isValid &&
                    act('modify', {
                      cart_key: entry.cart_key,
                      order_name: entry.object,
                      amount: value,
                    })
                  }
                  onValidationChange={setIsValid}
                />
                <Button
                  icon="plus"
                  disabled={entry.amount >= max_order}
                  onClick={() =>
                    act('add_by_name', {
                      order_name: entry.object,
                    })
                  }
                />
              </>
            ) : (
              <RestrictedInput width="40px" value={entry.amount} disabled />
            )}
          </Table.Cell>

          <Table.Cell collapsing color="average">
            {!!entry.paid && <b>[Private x {entry.amount}]</b>}
            {!!entry.dep_order && <b>[Department x {entry.amount}]</b>}
          </Table.Cell>

          <Table.Cell collapsing color="gold" textAlign="right">
            {formatMoney(entry.cost)} {entry.cost_type}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}
