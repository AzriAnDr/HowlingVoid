import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { usePreferencesLocalization } from './localization';

export type Data = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  controls: NavBeaconControl;
  static_controls: NavBeaconStaticControl;
};

export type NavBeaconControl = {
  location: string;
  patrol_enabled: BooleanLike;
  patrol_next: string;
  delivery_enabled: BooleanLike;
  delivery_direction: string;
  cover_locked: BooleanLike;
};

export type DisabledProps = {
  disabled: BooleanLike;
};

export type NavBeaconStaticControl = {
  direction_options: string[];
  has_codes: BooleanLike;
};

export const NavBeacon = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window title={t('ui.nav_beacon.title')} width={400} height={350}>
      <Window.Content>
        <NavBeaconContent />
      </Window.Content>
    </Window>
  );
};

export const NavBeaconContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  const disabled = data.locked && !data.siliconUser;
  return (
    <Stack vertical fill>
      <InterfaceLockNoticeBox />
      <NavBeaconControlSection disabled={disabled} />
      <NavBeaconMaintenanceSection disabled={disabled} />
    </Stack>
  );
};

export const NavBeaconControlSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { controls, static_controls } = data;
  return (
    <Section title={t('ui.common.controls')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.location')}>
          <Button
            fluid
            content={controls.location ?? t('ui.nav_beacon.none_set')}
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_location')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nav_beacon.enable_as_patrol_beacon')}>
          <Button.Checkbox
            fluid
            checked={controls.patrol_enabled}
            content={
              controls.patrol_enabled
                ? t('ui.common.enabled')
                : t('ui.common.disabled')
            }
            disabled={props.disabled}
            onClick={() => act('toggle_patrol')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nav_beacon.next_patrol')}>
          <Button
            fluid
            content={controls.patrol_next ?? t('ui.nav_beacon.no_next_patrol_location')}
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_patrol_next')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nav_beacon.enable_as_delivery_beacon')}>
          <Button.Checkbox
            fluid
            checked={controls.delivery_enabled}
            content={
              controls.delivery_enabled
                ? t('ui.common.enabled')
                : t('ui.common.disabled')
            }
            disabled={props.disabled}
            onClick={() => act('toggle_delivery')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nav_beacon.delivery_direction')}>
          <Dropdown
            disabled={!!props.disabled}
            options={static_controls.direction_options}
            selected={controls.delivery_direction}
            onSelected={(value) =>
              act('set_delivery_direction', {
                direction: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const NavBeaconMaintenanceSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { controls, static_controls } = data;
  return (
    <Section title={t('ui.common.maintenance')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.nav_beacon.reset_codes')}>
          {!!static_controls.has_codes && (
            <Button
              fluid
              content={t('ui.common.reset')}
              icon="power-off"
              disabled={props.disabled}
              onClick={() => act('reset_codes')}
            />
          )}
          {!static_controls.has_codes && (
            <Box>{t('ui.nav_beacon.no_backup_codes_found')}</Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nav_beacon.maintenance_hatch_cover')}>
          <Button.Checkbox
            fluid
            checked={controls.cover_locked}
            content={
              controls.cover_locked
                ? t('ui.common.locked')
                : t('ui.common.unlocked')
            }
            disabled={props.disabled}
            onClick={() => act('toggle_cover')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
