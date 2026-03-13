import { Button, Icon, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ImplantChair = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window width={375} height={280}>
      <Window.Content>
        <Section title={t('ui.implant_chair.occupant_information')} textAlign="center">
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              {data.occupant.name || t('ui.implant_chair.no_occupant')}
            </LabeledList.Item>
            {!!data.occupied && (
              <LabeledList.Item
                label={t('ui.common.status')}
                color={
                  data.occupant.stat === 0
                    ? 'good'
                    : data.occupant.stat === 1
                      ? 'average'
                      : 'bad'
                }
              >
                {data.occupant.stat === 0
                  ? t('ui.common.conscious')
                  : data.occupant.stat === 1
                    ? t('ui.common.unconscious')
                    : t('ui.common.dead')}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title={t('ui.common.operations')} textAlign="center">
          <LabeledList>
            <LabeledList.Item label={t('ui.common.door')}>
              <Button
                icon={data.open ? 'unlock' : 'lock'}
                color={data.open ? 'default' : 'red'}
                content={data.open ? t('ui.common.open') : t('ui.common.closed')}
                onClick={() => act('door')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.implant_chair.implant_occupant')}>
              <Button
                icon="code-branch"
                content={
                  data.ready
                    ? data.special_name || t('ui.implant_chair.implant')
                    : t('ui.implant_chair.recharging')
                }
                onClick={() => act('implant')}
              />
              {data.ready === 0 && <Icon name="cog" color="orange" spin />}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.implant_chair.implants_remaining')}>
              {data.ready_implants}
              {data.replenishing === 1 && <Icon name="sync" color="red" spin />}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
