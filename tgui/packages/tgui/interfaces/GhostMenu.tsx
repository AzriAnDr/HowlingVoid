import { useState } from 'react';
import {
  Button,
  Dropdown,
  ImageButton,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  can_boo: BooleanLike;
  hud_info: HudInfo[];
  has_fun: BooleanLike;
  lag_switch_on: BooleanLike;
  notification_data: NotificationData[];
  max_extra_view: number;
  body_name: string;
  current_darkness: string;
  darkness_levels: string[];
};

type HudInfo = {
  name: string;
  enabled: BooleanLike;
  flag: string;
  tooltip: string;
};

type NotificationData = {
  key: string;
  enabled: BooleanLike;
  desc: string;
};

export const GhostMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { has_fun, can_boo } = data;
  return (
    <Window
      title={t('ui.ghost_menu.title')}
      width={500}
      height={630}
      buttons={
        !!has_fun && (
          <>
            <Button
              disabled={!can_boo}
              tooltip={t('ui.ghost_menu.tooltip_boo')}
              onClick={() => act('boo')}
            >
              Boo!
            </Button>
            <Button
              tooltip={t('ui.ghost_menu.tooltip_possess')}
              onClick={() => act('possess')}
            >
              Possess
            </Button>
          </>
        )
      }
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item width="40%">
            <Section title={t('ui.ghost_menu.player_round_info')}>
              <RoundSection />
            </Section>
            <Section title={t('ui.ghost_menu.huds')}>
              <HudSection />
            </Section>
            <Section title={t('ui.ghost_menu.settings')}>
              <GhostSettingsSection />
            </Section>
          </Stack.Item>
          <Stack.Item width="60%">
            <NotificationPreferences />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RoundSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { body_name } = data;
  return (
    <>
      {!!body_name && (
        <ImageButton
          fluid
          dmIcon="icons/mob/simple/mob.dmi"
          dmIconState="ghost"
          tooltip={t('ui.ghost_menu.tooltip_reenter_body')}
          onClick={() => act('return_to_body')}
          fontSize="11px"
          buttons={
            <Button.Confirm
              icon="ghost"
              tooltip={t('ui.ghost_menu.tooltip_dnr')}
              onClick={() => act('DNR')}
            />
          }
        >
          Re-enter {body_name}
        </ImageButton>
      )}
      <ImageButton
        fluid
        dmIcon="icons/obj/machines/wallmounts.dmi"
        dmIconState="newscaster_off"
        onClick={() => act('crew_manifest')}
        fontSize="11px"
      >
        View Crew Manifest
      </ImageButton>
      <ImageButton
        fluid
        dmIcon="icons/obj/aicards.dmi"
        dmIconState="pai"
        onClick={() => act('signup_pai')}
        fontSize="11px"
      >
        Sign up as pAI
      </ImageButton>
    </>
  );
};

const HudSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { hud_info, lag_switch_on } = data;
  return (
    <Stack vertical>
      {hud_info.map((individual_hud) => (
        <Stack.Item key={individual_hud.name}>
          <Button
            fluid
            icon={individual_hud.enabled ? 'check' : 'times'}
            color={individual_hud.enabled ? 'good' : 'bad'}
            tooltip={individual_hud.tooltip}
            onClick={() =>
              act('toggle_visibility', { toggling: individual_hud.flag })
            }
          >
            {individual_hud.name}
          </Button>
        </Stack.Item>
      ))}
      {!lag_switch_on && (
        <Button
          tooltip={t('ui.ghost_menu.tooltip_tray_scan')}
          onClick={() => act('tray_scan')}
        >
          T-ray Scan
        </Button>
      )}
    </Stack>
  );
};

const GhostSettingsSection = (props) => {
  const [viewNumber, setviewNumber] = useState<number>(0);
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { current_darkness, darkness_levels, max_extra_view, lag_switch_on } =
    data;
  return (
    <Stack vertical>
      <Stack.Item>
        <Dropdown
          options={darkness_levels}
          selected={current_darkness}
          onSelected={(value) =>
            act('darkness', {
              darkness_level: value,
            })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          tooltip={t('ui.ghost_menu.tooltip_restore_appearance')}
          onClick={() => act('restore_appearance')}
        >
          Restore Ghost Character
        </Button>
      </Stack.Item>
      {!lag_switch_on && (
        <Stack.Item mx={1}>
          Extra View Distance:
          <NumberInput
            width="30px"
            step={1}
            value={viewNumber}
            minValue={0}
            maxValue={max_extra_view}
            onChange={(new_range) => {
              setviewNumber(new_range);
              act('view_range', {
                new_view_range: new_range,
              });
            }}
          />
        </Stack.Item>
      )}
    </Stack>
  );
};

const NotificationPreferences = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { notification_data } = data;
  if (!notification_data) {
    return 'No notifications!';
  }

  const ignores = notification_data.sort((a, b) => {
    const descA = a.desc.toLowerCase();
    const descB = b.desc.toLowerCase();
    if (descA < descB) {
      return -1;
    }
    if (descA > descB) {
      return 1;
    }
    return 0;
  });

  return (
    <Section
      scrollable
      fill
      title={t('ui.ghost_menu.role_notifications')}
      buttons={
        <>
          <Button
            icon="check"
            color="good"
            tooltip={t('ui.ghost_menu.tooltip_enable_all_notifications')}
            onClick={() => act('turn_all_on')}
          />
          <Button
            icon="times"
            color="bad"
            tooltip={t('ui.ghost_menu.tooltip_disable_all_notifications')}
            onClick={() => act('turn_all_off')}
          />
        </>
      }
    >
      {ignores.map((ignore) => (
        <Button
          fluid
          key={ignore.key}
          icon={ignore.enabled ? 'times' : 'check'}
          color={ignore.enabled ? 'bad' : 'good'}
          onClick={() => act('change_notification', { key: ignore.key })}
        >
          {ignore.desc}
        </Button>
      ))}
    </Section>
  );
};
