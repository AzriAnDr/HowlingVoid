import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  priority: string[];
  minor: string[];
};

export const AtmosAlertConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { priority = [], minor = [] } = data;

  return (
    <Window width={350} height={300}>
      <Window.Content scrollable>
        <Section title={t('ui.atmos_alert_console.alarms')}>
          <ul>
            {priority.length === 0 && (
              <li className="color-good">
                {t('ui.atmos_alert_console.no_priority_alerts')}
              </li>
            )}
            {priority.map((alert) => (
              <li key={alert}>
                <Button
                  icon="times"
                  content={alert}
                  color="bad"
                  onClick={() => act('clear', { zone: alert })}
                />
              </li>
            ))}
            {minor.length === 0 && (
              <li className="color-good">
                {t('ui.atmos_alert_console.no_minor_alerts')}
              </li>
            )}
            {minor.map((alert) => (
              <li key={alert}>
                <Button
                  icon="times"
                  content={alert}
                  color="average"
                  onClick={() => act('clear', { zone: alert })}
                />
              </li>
            ))}
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
