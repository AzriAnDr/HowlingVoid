import { useState } from 'react';
import {
  Blink,
  Box,
  Button,
  Dimmer,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

// 3.5x crate value, 10 minutes
const COST_MODERATE_BOUND = 700;
// 13.5x crate value, 15 minutes
const COST_LONG_BOUND = 2700;
// 40x crate value, 20 minutes
const COST_VERY_LONG_BOUND = 8000;

type typePath = string;

type Pack = {
  name: string;
  desc: string;
  cost: number;
  id: typePath;
};

type Category = {
  name: string;
  packs: Pack[];
};

type Info = {
  can_override: BooleanLike;
  time_left: string | null;
  supplies: Category[];
  no_link: BooleanLike;
  id_inside: BooleanLike;
};

const CooldownEstimate = (props) => {
  const { t } = usePreferencesLocalization();
  const { cost } = props;
  const cooldownColor =
    (cost >= COST_VERY_LONG_BOUND && 'red') ||
    (cost >= COST_LONG_BOUND && 'orange') ||
    (cost >= COST_MODERATE_BOUND && 'yellow') ||
    'green';
  const cooldownText =
    (cost >= COST_VERY_LONG_BOUND && t('ui.ntos_dept_order.cooldown_very_long')) ||
    (cost >= COST_LONG_BOUND && t('ui.ntos_dept_order.cooldown_long')) ||
    (cost >= COST_MODERATE_BOUND && t('ui.ntos_dept_order.cooldown_moderate')) ||
    t('ui.ntos_dept_order.cooldown_short');
  return (
    <Box as="span" textColor={cooldownColor}>
      {cooldownText} {t('ui.ntos_dept_order.cooldown_suffix')}
    </Box>
  );
};

export const DepartmentOrderContent = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { no_link, time_left } = data;
  if (!data) {
    return null;
  }

  if (no_link) {
    return <NoLinkDimmer />;
  }
  if (time_left) {
    return <CooldownDimmer />;
  }

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox info>
              {t('ui.ntos_dept_order.free_orders_notice')}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <DepartmentCatalog />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const NtosDeptOrder = () => {
  const { t } = usePreferencesLocalization();
  return (
    <NtosWindow title={t('ui.ntosdeptorder.department_orders')} width={620} height={580}>
      <NtosWindow.Content>
        <DepartmentOrderContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const CooldownDimmer = () => {
  const { act, data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { can_override, time_left } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item textAlign="center">
          <Icon color="bug" name="route" size={20} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="orange">
          {t('ui.ntos_dept_order.ready_for_order_in').replace(
            '{time}',
            time_left ?? '',
          )}
        </Stack.Item>
        <Stack.Item textAlign="center" color="orange">
          <Button
            width="300px"
            lineHeight={2}
            tooltip={
              (!!can_override &&
                t('ui.ntos_dept_order.override_requires_hos')) ||
              t('ui.ntos_dept_order.crate_already_shipped')
            }
            fontSize="14px"
            color="red"
            disabled={!can_override}
            onClick={() => act('override_order')}
          >
            <Box fontSize="22px">{t('ui.ntosdeptorder.override')}</Box>
          </Button>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const NoLinkDimmer = () => {
  const { act, data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { id_inside } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item textAlign="center">
          <Blink>
            <Icon color="red" name="exclamation" size={16} opacity={0.8} />
          </Blink>
        </Stack.Item>
        <Stack.Item textAlign="center" fontSize="22px" color="red">
          {t('ui.ntos_dept_order.unlinked')}
        </Stack.Item>
        <Stack.Item textAlign="center" fontSize="14px" color="red">
          <Button disabled={!id_inside} onClick={() => act('link')}>
            {t('ui.ntos_dept_order.insert_hos_id')}
          </Button>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const DepartmentCatalog = () => {
  const { act, data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { supplies } = data;
  const [tabCategory, setTabCategory] = useState(supplies[0]);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs textAlign="center" fluid>
          {supplies.map((cat) => (
            <Tabs.Tab
              key={cat.name}
              selected={tabCategory === cat}
              onClick={() => setTabCategory(cat)}
            >
              {cat.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical>
            {tabCategory.packs.map((pack) => (
              <Stack.Item className="candystripe" key={pack.name}>
                <Stack fill>
                  <Stack.Item grow>
                    <Tooltip content={pack.desc}>
                      <Box
                        as="span"
                        style={{
                          borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                        }}
                      >
                        {pack.name}
                      </Box>
                    </Tooltip>
                  </Stack.Item>
                  <Stack.Item>
                    <CooldownEstimate cost={pack.cost} />
                    &ensp;
                    <Button
                      onClick={() =>
                        act('order', {
                          id: pack.id,
                        })
                      }
                    >
                      {t('ui.ntos_dept_order.order')}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
