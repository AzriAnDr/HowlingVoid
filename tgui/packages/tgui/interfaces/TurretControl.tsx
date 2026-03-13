import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { usePreferencesLocalization } from './localization';

type Data = {
  enabled: BooleanLike;
  lethal: BooleanLike;
  locked: BooleanLike;
  shootCyborgs: BooleanLike;
  siliconUser: BooleanLike;
};

export const TurretControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { enabled, lethal, locked, siliconUser, shootCyborgs } = data;
  const isLocked = locked && !siliconUser;

  return (
    <Window width={305} height={siliconUser ? 168 : 164}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.turret_control.turret_status')}>
              <Button
                icon={enabled ? 'power-off' : 'times'}
                content={
                  enabled
                    ? t('ui.turret_control.enabled')
                    : t('ui.turret_control.disabled')
                }
                selected={enabled}
                disabled={isLocked}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.turret_control.turret_mode')}>
              <Button
                icon={lethal ? 'exclamation-triangle' : 'minus-circle'}
                content={
                  lethal
                    ? t('ui.turret_control.lethal')
                    : t('ui.turret_control.stun')
                }
                color={lethal ? 'bad' : 'average'}
                disabled={isLocked}
                onClick={() => act('mode')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.turret_control.target_cyborgs')}>
              <Button
                icon={shootCyborgs ? 'check' : 'times'}
                content={shootCyborgs ? t('ui.common.yes') : t('ui.common.no')}
                selected={shootCyborgs}
                disabled={isLocked}
                onClick={() => act('shoot_silicons')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
