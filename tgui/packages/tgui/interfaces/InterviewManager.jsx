import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const InterviewManager = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { open_interviews, closed_interviews } = data;

  const colorMap = (status) => {
    switch (status) {
      case 'interview_approved':
        return 'good';
      case 'interview_denied':
        return 'bad';
      case 'interview_pending':
        return 'average';
    }
  };

  return (
    <Window width={500} height={600} theme="admin">
      <Window.Content scrollable>
        <Section title={t('ui.interview_manager.active_interviews')}>
          {open_interviews.map(({ id, ckey, status, queued, disconnected }) => (
            <Button
              key={id}
              content={ckey + (disconnected ? ' (DC)' : '')}
              color={queued ? 'default' : colorMap(status)}
              onClick={() => act('open', { id: id })}
            />
          ))}
        </Section>
        <Section title={t('ui.interview_manager.closed_interviews')}>
          {closed_interviews.map(({ id, ckey, status, disconnected }) => (
            <Button
              key={id}
              content={ckey + (disconnected ? ' (DC)' : '')}
              color={colorMap(status)}
              onClick={() => act('open', { id: id })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
