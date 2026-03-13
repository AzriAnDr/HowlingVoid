import { Button, NoticeBox, Section, Table } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { CargoData } from './types';

export function CargoRequests(props) {
  const { act, data } = useBackend<CargoData>();
  const { t } = usePreferencesLocalization(data);
  const { requests = [], requestonly, can_send, can_approve_requests, displayed_currency_name} = data;

  return (
    <Section fill scrollable>
      {requests.length === 0 && <NoticeBox success>{t('ui.cargo.no_requests')}</NoticeBox>}
      {requests.length > 0 && (
        <Table>
          <Table.Row header color="gray">
            <Table.Cell>{t('ui.common.id')}</Table.Cell>
            <Table.Cell>{t('ui.cargo.object')}</Table.Cell>
            <Table.Cell>{t('ui.cargo.orderer')}</Table.Cell>
            <Table.Cell>{t('ui.cargo.reason')}</Table.Cell>
            <Table.Cell>{t('ui.cargo.account')}</Table.Cell>
            <Table.Cell>{t('ui.common.cost')}</Table.Cell>
            {(!requestonly || !!can_send) && !!can_approve_requests && (
              <Table.Cell>{t('ui.common.actions')}</Table.Cell>
            )}
          </Table.Row>

          {requests.map((request) => (
            <Table.Row key={request.id} className="candystripe" color="label">
              <Table.Cell collapsing>#{request.id}</Table.Cell>
              <Table.Cell>{request.object}</Table.Cell>
              <Table.Cell>
                <b>{request.orderer}</b>
              </Table.Cell>
              <Table.Cell color="lightgray" width="25%">
                <i>{decodeHtmlEntities(request.reason)}</i>
              </Table.Cell>
              <Table.Cell collapsing>
                {request.account}
              </Table.Cell>
              <Table.Cell collapsing color="gold">
                {formatMoney(request.cost)}{displayed_currency_name}
              </Table.Cell>
              {(!requestonly || !!can_send) && !!can_approve_requests && (
                <Table.Cell collapsing>
                  <Button
                    icon="check"
                    color="good"
                    onClick={() =>
                      act('approve', {
                        id: request.id,
                      })
                    }
                  />
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() =>
                      act('deny', {
                        id: request.id,
                      })
                    }
                  />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}
