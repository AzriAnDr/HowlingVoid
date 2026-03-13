import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const PortableTurret = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    silicon_user,
    locked,
    on,
    check_weapons,
    neutralize_criminals,
    neutralize_all,
    neutralize_unidentified,
    neutralize_nonmindshielded,
    neutralize_cyborgs,
    neutralize_heads,
    manual_control,
    allow_manual_control,
    lasertag_turret,
  } = data;
  return (
    <Window width={310} height={lasertag_turret ? 110 : 292}>
      <Window.Content>
        <NoticeBox>
          {t('ui.portable_turret.swipe_id_to')}{' '}
          {locked ? t('ui.portable_turret.unlock') : t('ui.portable_turret.lock')}{' '}
          {t('ui.portable_turret.this_interface')}
        </NoticeBox>

        <Section>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.common.status')}
              buttons={
                !lasertag_turret &&
                (!!allow_manual_control ||
                  (!!manual_control && !!silicon_user)) && (
                  <Button
                    icon={manual_control ? 'wifi' : 'terminal'}
                    content={
                      manual_control
                        ? t('ui.portable_turret.remotely_controlled')
                        : t('ui.portable_turret.manual_control')
                    }
                    disabled={manual_control}
                    color="bad"
                    onClick={() => act('manual')}
                  />
                )
              }
            >
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? t('ui.common.on') : t('ui.common.off')}
                selected={on}
                disabled={locked}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!lasertag_turret && (
          <Section
            title={t('ui.portable_turret.target_settings')}
            buttons={
              <Button.Checkbox
                checked={!neutralize_heads}
                content={t('ui.portable_turret.ignore_command')}
                disabled={locked}
                onClick={() => act('shootheads')}
              />
            }
          >
            <Button.Checkbox
              fluid
              checked={neutralize_all}
              content={t('ui.portable_turret.non_security_and_non_command')}
              disabled={locked}
              onClick={() => act('shootall')}
            />
            <Button.Checkbox
              fluid
              checked={check_weapons}
              content={t('ui.portable_turret.unauthorized_weapons')}
              disabled={locked}
              onClick={() => act('authweapon')}
            />
            <Button.Checkbox
              fluid
              checked={neutralize_unidentified}
              content={t('ui.portable_turret.unidentified_life_signs')}
              disabled={locked}
              onClick={() => act('checkxenos')}
            />
            <Button.Checkbox
              fluid
              checked={neutralize_nonmindshielded}
              content={t('ui.portable_turret.non_mindshielded')}
              disabled={locked}
              onClick={() => act('checkloyal')}
            />
            <Button.Checkbox
              fluid
              checked={neutralize_criminals}
              content={t('ui.portable_turret.wanted_criminals')}
              disabled={locked}
              onClick={() => act('shootcriminals')}
            />
            <Button.Checkbox
              fluid
              checked={neutralize_cyborgs}
              content={t('ui.portable_turret.cyborgs')}
              disabled={locked}
              onClick={() => act('shootborgs')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
