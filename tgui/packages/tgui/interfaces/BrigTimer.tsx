import { Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  timing: BooleanLike;
  minutes: number;
  seconds: number;
  flash_charging: BooleanLike;
};

export const BrigTimer = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { timing, minutes, seconds, flash_charging } = data;
  return (
    <Window width={300} height={138}>
      <Window.Content scrollable>
        <Section
          title={t('ui.brig_timer.cell_timer')}
          buttons={
            <>
              <Button
                icon="clock-o"
                content={timing ? t('ui.common.stop') : t('ui.common.start')}
                selected={timing}
                onClick={() => act(timing ? 'stop' : 'start')}
              />
              <Button
                icon="lightbulb-o"
                content={
                  flash_charging
                    ? t('ui.brig_timer.recharging')
                    : t('ui.brig_timer.flash')
                }
                disabled={flash_charging}
                onClick={() => act('flash')}
              />
            </>
          }
        >
          <Button
            icon="fast-backward"
            onClick={() => act('time', { adjust: -600 })}
          />
          <Button
            icon="backward"
            onClick={() => act('time', { adjust: -100 })}
          />{' '}
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
          <Button icon="forward" onClick={() => act('time', { adjust: 100 })} />
          <Button
            icon="fast-forward"
            onClick={() => act('time', { adjust: 600 })}
          />
          <br />
          <Button
            icon="hourglass-start"
            content={t('ui.common.short')}
            onClick={() => act('preset', { preset: 'short' })}
          />
          <Button
            icon="hourglass-start"
            content={t('ui.common.medium')}
            onClick={() => act('preset', { preset: 'medium' })}
          />
          <Button
            icon="hourglass-start"
            content={t('ui.common.long')}
            onClick={() => act('preset', { preset: 'long' })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
