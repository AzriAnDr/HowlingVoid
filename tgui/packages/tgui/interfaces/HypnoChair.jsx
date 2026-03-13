import {
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const HypnoChair = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window width={375} height={480}>
      <Window.Content>
        <Section
          title={t('ui.hypno_chair.information')}
          backgroundColor="#450F44"
        >
          {t('ui.hypno_chair.information_text')}
        </Section>
        <Section title={t('ui.hypno_chair.occupant_information')} textAlign="center">
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              {data.occupant.name ? data.occupant.name : t('ui.hypno_chair.no_occupant')}
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
            <LabeledList.Item label={t('ui.hypno_chair.trigger_phrase')}>
              <Input
                value={data.trigger}
                onBlur={(value) =>
                  act('set_phrase', {
                    phrase: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.hypno_chair.interrogate_occupant')}>
              <Button
                icon="code-branch"
                content={
                  data.interrogating
                    ? t('ui.hypno_chair.interrupt_interrogation')
                    : t('ui.hypno_chair.begin_enhanced_interrogation')
                }
                onClick={() => act('interrogate')}
              />
              {data.interrogating === 1 && (
                <Icon name="cog" color="orange" spin />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
