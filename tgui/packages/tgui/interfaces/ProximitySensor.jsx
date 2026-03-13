import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ProximitySensor = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { minutes, seconds, timing, scanning, sensitivity } = data;
  return (
    <Window width={250} height={185}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.proximitysensor.status')}>
              <Button
                icon={scanning ? 'lock' : 'unlock'}
                content={
                  scanning
                    ? t('ui.proximity_sensor.armed')
                    : t('ui.proximity_sensor.not_armed')
                }
                selected={scanning}
                onClick={() => act('scanning')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.proximitysensor.detection_range')}>
              <Button
                icon="backward"
                disabled={scanning}
                onClick={() => act('sense', { range: -1 })}
              />{' '}
              {String(sensitivity).padStart(1, '1')}{' '}
              <Button
                icon="forward"
                disabled={scanning}
                onClick={() => act('sense', { range: 1 })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.proximitysensor.auto_arm')}
          buttons={
            <Button
              icon={'clock-o'}
              content={
                timing
                  ? t('ui.proximity_sensor.stop')
                  : t('ui.proximity_sensor.start')
              }
              selected={timing}
              disabled={scanning}
              onClick={() => act('time')}
            />
          }
        >
          <Button
            icon="fast-backward"
            disabled={scanning || timing}
            onClick={() => act('input', { adjust: -30 })}
          />
          <Button
            icon="backward"
            disabled={scanning || timing}
            onClick={() => act('input', { adjust: -1 })}
          />{' '}
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
          <Button
            icon="forward"
            disabled={scanning || timing}
            onClick={() => act('input', { adjust: 1 })}
          />
          <Button
            icon="fast-forward"
            disabled={scanning || timing}
            onClick={() => act('input', { adjust: 30 })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
