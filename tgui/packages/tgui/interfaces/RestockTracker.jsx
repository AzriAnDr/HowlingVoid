import { sortBy } from 'es-toolkit';
import {
  Button,
  ColorBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Restock = (props) => {
  return (
    <Window width={860} height={560}>
      <Window.Content scrollable>
        <RestockTracker />
      </Window.Content>
    </Window>
  );
};

export const RestockTracker = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const vending_list = sortBy(data.vending_list ?? [], [
    (vend) => vend.percentage,
  ]);
  return (
    <Section fill title={t('ui.restock_tracker.vendor_stocking_status')}>
      <Stack vertical>
        <Stack fill horizontal>
          <Stack.Item bold width="18%">
            Vending Name
          </Stack.Item>
          <Stack.Item bold width="15%">
            Location
          </Stack.Item>
          <Stack.Item bold width="24%">
            Needed
          </Stack.Item>
          <Stack.Item bold width="12%">
            Stock %
          </Stack.Item>
          <Stack.Item bold width="8%">
            Cash inside
          </Stack.Item>
          <Stack.Item bold width="15%">
            Task
          </Stack.Item>
          <Stack.Item bold width="8%">
            Order
          </Stack.Item>
        </Stack>
        {vending_list.length === 0 && <RestockTrackerFull />}
        {vending_list.map((vend) => (
          <Stack key={vend.id} fill horizontal>
            <Stack.Item wrap width="18%" height="100%">
              {vend.name}
            </Stack.Item>
            <Stack.Item wrap width="15%" height="100%">
              {vend.location}
            </Stack.Item>
            <Stack.Item wrap width="24%" height="100%">
              {vend.missing_total > 0 ? (
                <>
                  {(vend.missing_products ?? [])
                    .map((product) => `${product.missing}x ${product.name}`)
                    .join(', ')}
                  {vend.missing_extra > 0 && `, +${vend.missing_extra} more`}
                </>
              ) : (
                'No refill needed'
              )}
            </Stack.Item>
            <Stack.Item
              wrap
              width="12%"
              textAlign={
                vend.percentage > 75
                  ? 'left'
                  : vend.percentage > 45
                    ? 'right'
                    : 'center'
              }
            >
              <ProgressBar
                value={vend.percentage}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [75, 100],
                  average: [45, 75],
                  bad: [0, 45],
                }}
              >
                {round(vend.percentage, 0.01)}
              </ProgressBar>
            </Stack.Item>
            <Stack.Item
              wrap
              width="8%"
              color={vend.credits > 50 ? 'good' : 'bad'}
            >
              <ColorBox color={vend.credits > 50 ? 'good' : 'bad'} mr={'5%'} />
              {vend.credits}
            </Stack.Item>
            <Stack.Item wrap width="15%">
              {vend.missing_total <= 0 ? (
                '-'
              ) : vend.claimed_by_you ? (
                <>
                  <Button color="good" disabled>
                    {vend.claimed_by} +{vend.reward}
                  </Button>{' '}
                  {vend.time_left}
                </>
              ) : vend.claimed_by ? (
                <>
                  <Button disabled>{vend.claimed_by}</Button>{' '}
                  {vend.time_left}
                </>
              ) : (
                <>
                  <Button
                    disabled={!vend.claimable}
                    icon="hand"
                    onClick={() =>
                      act('claim_task', {
                        vendor: vend.vendor,
                      })
                    }
                  >
                    +{vend.reward}
                  </Button>{' '}
                  Fine {vend.penalty}
                </>
              )}
            </Stack.Item>
            <Stack.Item wrap width="8%">
              {vend.order_pending ? (
                <Button disabled>#{vend.order_id}</Button>
              ) : vend.order_sent ? (
                <Button disabled>Ordered</Button>
              ) : (
                <Button
                  disabled={!vend.orderable || vend.missing_total <= 0}
                  icon="cart-shopping"
                  onClick={() =>
                    act('order_restock', {
                      vendor: vend.vendor,
                    })
                  }
                >
                  Order
                </Button>
              )}
            </Stack.Item>
          </Stack>
        ))}
      </Stack>
    </Section>
  );
};

export const RestockTrackerFull = (props) => {
  return (
    <Stack.Item bold textAlign="center" mt={2}>
      All vending machines stocked!
    </Stack.Item>
  );
};
