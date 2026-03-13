import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { CargoData } from './types';

export function CargoStatus(props) {
  const { act, data } = useBackend<CargoData>();
  const { t } = usePreferencesLocalization(data);
  const {
    department,
    grocery,
    away,
    docked,
    loan,
    loan_dispatched,
    location,
    message,
    points,
    requestonly,
    can_send,
  } = data;

  return (
    <Section
      title={department}
      buttons={
        <Box inline bold verticalAlign="middle">
          <AnimatedNumber
            value={points}
            format={(value) => formatMoney(value)}
          />
          {data.displayed_currency_full_name}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.cargo.shuttle')}>
          {!!docked && !requestonly && !!can_send ? (
            <Button
              color={grocery ? 'orange' : 'green'}
              tooltip={
                grocery
                  ? t('ui.cargo.kitchen_waiting_for_grocery_delivery')
                  : ''
              }
              tooltipPosition="right"
              onClick={() => act('send')}
            >
              {location}
            </Button>
          ) : (
            String(location)
          )}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.cargo.centcom_message')}>{message}</LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label={t('ui.cargo.loan')}>
            {!loan_dispatched ? (
              <Button disabled={!(away && docked)} onClick={() => act('loan')}>
                {t('ui.cargo.loan_shuttle')}
              </Button>
            ) : (
              <Box color="bad">{t('ui.cargo.loaned_to_centcom')}</Box>
            )}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
