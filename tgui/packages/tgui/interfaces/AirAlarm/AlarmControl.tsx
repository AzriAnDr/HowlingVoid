import { useState } from 'react';
import { Button, Section } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { AirAlarmControlHome } from './screens/Home';
import { AirAlarmControlModes } from './screens/Modes';
import { AirAlarmControlScrubbers } from './screens/Scrubbers';
import { AirAlarmControlThresholds } from './screens/Thresholds';
import { AirAlarmControlVents } from './screens/Vents';
import type { AlarmScreen } from './types';

export const AIR_ALARM_ROUTES = {
  home: {
    titleKey: 'ui.air_alarm.air_controls',
    component: AirAlarmControlHome,
  },
  vents: {
    titleKey: 'ui.air_alarm.vent_controls',
    component: AirAlarmControlVents,
  },
  scrubbers: {
    titleKey: 'ui.air_alarm.scrubber_controls',
    component: AirAlarmControlScrubbers,
  },
  modes: {
    titleKey: 'ui.air_alarm.operating_mode',
    component: AirAlarmControlModes,
  },
  thresholds: {
    titleKey: 'ui.air_alarm.alarm_thresholds',
    component: AirAlarmControlThresholds,
  },
} as const;

export function AirAlarmControl(props) {
  const { t } = usePreferencesLocalization();
  const [screen, setScreen] = useState<AlarmScreen>('home');

  const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component;
  const isHome = screen === 'home';

  return (
    <Section
      fill
      scrollable
      title={t(route.titleKey)}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => setScreen('home')}
          disabled={isHome}
        >
          {t('ui.common.back')}
        </Button>
      }
    >
      <Component {...(isHome && { setScreen })} />
    </Section>
  );
}
