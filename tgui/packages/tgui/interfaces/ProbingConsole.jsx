import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ProbingConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { open, feedback, occupant, occupant_name, occupant_status } = data;
  return (
    <Window width={330} height={207} theme="abductor">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.probing_console.machine_report')}>
              {feedback}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.probing_console.scanner')}
          buttons={
            <Button
              icon={open ? 'sign-out-alt' : 'sign-in-alt'}
              content={open ? t('ui.common.close') : t('ui.common.open')}
              onClick={() => act('door')}
            />
          }
        >
          {(occupant && (
            <LabeledList>
              <LabeledList.Item label={t('ui.common.name')}>
                {occupant_name}
              </LabeledList.Item>
              <LabeledList.Item
                label={t('ui.common.status')}
                color={
                  occupant_status === 3
                    ? 'bad'
                    : occupant_status === 2
                      ? 'average'
                      : 'good'
                }
              >
                {occupant_status === 3
                  ? t('ui.common.deceased')
                  : occupant_status === 2
                    ? t('ui.common.unconscious')
                    : t('ui.common.conscious')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.probing_console.experiments')}>
                <Button
                  icon="thermometer"
                  content={t('ui.probing_console.probe')}
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 1,
                    })
                  }
                />
                <Button
                  icon="brain"
                  content={t('ui.probing_console.dissect')}
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 2,
                    })
                  }
                />
                <Button
                  icon="search"
                  content={t('ui.probing_console.analyze')}
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 3,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          )) || <NoticeBox>{t('ui.probing_console.no_subject')}</NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
