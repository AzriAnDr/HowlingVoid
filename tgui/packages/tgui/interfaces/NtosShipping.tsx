import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  current_user: string;
  card_owner: string;
  paperamt: number;
  barcode_split: number;
  has_id_slot: BooleanLike;
};

export const NtosShipping = (props) => {
  return (
    <NtosWindow width={450} height={350}>
      <NtosWindow.Content scrollable>
        <ShippingHub />
        <ShippingOptions />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

/** Returns information about the current user, available paper, etc */
const ShippingHub = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { current_user, card_owner, paperamt, barcode_split } = data;

  return (
    <Section
      title={t('ui.ntosshipping.ntos_shipping_hub')}
      buttons={
        <Button
          icon="eject"
          content={t('ui.ntosshipping.eject_id')}
          onClick={() => act('ejectid')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.ntosshipping.current_user')}>
          {current_user || t('ui.common.not_available')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntosshipping.inserted_card')}>
          {card_owner || t('ui.common.not_available')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntosshipping.available_paper')}>
          {paperamt}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntosshipping.profit_on_sale')}>
          {barcode_split}%
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

/** Returns shipping options */
const ShippingOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { has_id_slot, current_user } = data;

  return (
    <Section title={t('ui.ntosshipping.shipping_options')}>
      <Box>
        <Button
          icon="id-card"
          tooltip={t(
            'ui.ntosshipping.the_currently_id_card_will_become_the_current_user',
          )}
          tooltipPosition="right"
          disabled={!has_id_slot}
          onClick={() => act('selectid')}
          content={t('ui.ntosshipping.set_current_id')}
        />
      </Box>
      <Box>
        <Button
          icon="print"
          tooltip={t(
            'ui.ntosshipping.print_a_barcode_to_use_on_a_wrapped_package',
          )}
          tooltipPosition="right"
          disabled={!current_user}
          onClick={() => act('print')}
          content={t('ui.ntosshipping.print_barcode')}
        />
      </Box>
      <Box>
        <Button
          icon="tags"
          tooltip={t(
            'ui.ntosshipping.set_how_much_profit_you_d_like_on_your_package',
          )}
          tooltipPosition="right"
          onClick={() => act('setsplit')}
          content={t('ui.ntosshipping.set_profit_margin')}
        />
      </Box>
      <Box>
        <Button
          icon="sync-alt"
          content={t('ui.ntosshipping.reset_id')}
          onClick={() => act('resetid')}
        />
      </Box>
    </Section>
  );
};

