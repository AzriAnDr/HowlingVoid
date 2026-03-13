import { Box, Input, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  valid_id: BooleanLike;
  redeemed_coupons: CouponData[];
  printed_coupons: CouponData[];
};

type CouponData = {
  goody: string;
  discount: number;
};

export const NtosCouponMaster = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { valid_id, redeemed_coupons = [], printed_coupons = [] } = data;
  return (
    <NtosWindow width={400} height={400}>
      <NtosWindow.Content scrollable>
        {!valid_id ? (
          <NoticeBox danger>
            {t('ui.ntos_coupon_master.no_valid_bank_account')}
          </NoticeBox>
        ) : (
          <>
            <NoticeBox info>
              {t('ui.ntos_coupon_master.print_redeemed_notice')}
            </NoticeBox>
            <Input
              fontSize={1.2}
              placeholder={t('ui.ntoscouponmaster.insert_your_coupon_code_here')}
              onEnter={(value) =>
                act('redeem', {
                  code: value,
                })
              }
            />
            <Section title={t('ui.ntoscouponmaster.redeemed_coupons')}>
              {redeemed_coupons.map((coupon, index) => (
                <Box key={index} className="candystripe">
                  {coupon.goody} ({coupon.discount}% OFF)
                </Box>
              ))}
            </Section>
            <Section title={t('ui.ntoscouponmaster.printed_coupons')}>
              {printed_coupons.map((coupon, index) => (
                <Box key={index} className="candystripe">
                  {coupon.goody} ({coupon.discount}% OFF)
                </Box>
              ))}
            </Section>
          </>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
