import { Button, Input, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const TOOLTIP_NAME = `
  Enter a new name for this unit. Set to blank to reset to default,
  which means unit will be able to choose its own name.
`;

const TOOLTIP_LOCOMOTION = `
  If restricted, unit will be
  under lockdown until released.
`;

const TOOLTIP_PANEL = `
  If unlocked, unit's cover panel will be
  accessible even without proper authorization.
`;

const TOOLTIP_AISYNC = `
  If closed, this unit will
  not be paired with any AI.
`;

const TOOLTIP_AI = `
  Controls who will be the
  master AI of this unit.
`;

const TOOLTIP_LAWSYNC = `
  If closed, this unit will not synchronize
  its laws with its master AI.
`;

export const CyborgBootDebug = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { designation, master, lawsync, aisync, locomotion, panel } = data;
  return (
    <Window width={master?.length > 26 ? 537 : 440} height={289}>
      <Window.Content>
        <Section title={t('ui.cyborg_boot_debug.basic_settings')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.designation')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_name')}
                  tooltipPosition="left"
                />
              }
            >
                <Input
                  fluid
                  value={designation || t('ui.cyborg_boot_debug.default_cyborg')}
                onBlur={(value) =>
                  act('rename', {
                    new_name: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.servo_motor_functions')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_locomotion')}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={locomotion ? 'unlock' : 'lock'}
                content={
                  locomotion
                    ? t('ui.cyborg_boot_debug.free')
                    : t('ui.cyborg_boot_debug.restricted')
                }
                color={locomotion ? 'good' : 'bad'}
                onClick={() => act('locomotion')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.cover_panel')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_panel')}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={panel ? 'lock' : 'unlock'}
                content={panel ? t('ui.common.locked') : t('ui.common.unlocked')}
                onClick={() => act('panel')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.cyborg_boot_debug.ai_settings')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.ai_connection_port')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_aisync')}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={aisync ? 'unlock' : 'lock'}
                content={aisync ? t('ui.common.open') : t('ui.common.closed')}
                onClick={() => act('aisync')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.master_ai')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_ai')}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={!aisync ? 'times' : master ? 'edit' : 'sync'}
                content={
                  !aisync
                    ? t('ui.common.none')
                    : master || t('ui.cyborg_boot_debug.automatic')
                }
                color={master ? 'default' : 'good'}
                disabled={!aisync}
                onClick={() => act('set_ai')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.cyborg_boot_debug.lawsync_port')}
              buttons={
                <Button
                  icon="info"
                  tooltip={t('ui.cyborg_boot_debug.tooltip_lawsync')}
                  tooltipPosition="top-start"
                />
              }
            >
              <Button
                icon={!aisync ? 'lock' : lawsync ? 'unlock' : 'lock'}
                content={
                  !aisync
                    ? t('ui.common.closed')
                    : lawsync
                      ? t('ui.common.open')
                      : t('ui.common.closed')
                }
                disabled={!aisync}
                onClick={() => act('lawsync')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

