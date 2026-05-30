import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { CargoData } from './types';

const formatDeciseconds = (deciseconds = 0) => {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return `${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
};

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
    storytellerCargoModifier,
    storytellerCargoModifierDescription,
    storytellerCargoModifierLabel,
    storytellerCargoModifierRemaining,
    storytellerIncomingPods,
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
        {!!storytellerCargoModifierLabel && (
          <LabeledList.Item label="Trade Climate">
            <Box color={(storytellerCargoModifier || 1) >= 1 ? 'good' : 'bad'}>
              {storytellerCargoModifierLabel}
              {!!storytellerCargoModifierRemaining &&
                ` (${formatDeciseconds(storytellerCargoModifierRemaining)} left)`}
            </Box>
            {!!storytellerCargoModifierDescription && (
              <Box color="label" mt={0.5}>
                {storytellerCargoModifierDescription}
              </Box>
            )}
          </LabeledList.Item>
        )}
        {!!storytellerIncomingPods?.length && (
          <LabeledList.Item label="Incoming Relief Pods">
            <Stack vertical fill>
              {storytellerIncomingPods.map((delivery) => (
                <Button
                  key={delivery.id}
                  fluid
                  icon="crosshairs"
                  tooltip={`${delivery.areaName}${
                    delivery.summary ? `: ${delivery.summary}` : ''
                  }`}
                  tooltipPosition="right"
                  onClick={() =>
                    act('storytellerShowLanding', {
                      delivery_id: delivery.id,
                    })
                  }
                >
                  {delivery.name} - {delivery.areaName} ({formatDeciseconds(delivery.remaining)})
                </Button>
              ))}
            </Stack>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
