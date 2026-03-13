import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const GravityGenerator = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { operational } = data;
  return (
    <Window width={400} height={155}>
      <Window.Content>
        {!operational && <NoticeBox>{t('ui.gravity_generator.no_data_available')}</NoticeBox>}
        {!!operational && <GravityGeneratorContent />}
      </Window.Content>
    </Window>
  );
};

const GravityGeneratorContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { breaker, charge_count, charging_state, on, operational } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.power')}>
          <Button
            icon={breaker ? 'power-off' : 'times'}
            content={breaker ? t('ui.common.on') : t('ui.common.off')}
            selected={breaker}
            disabled={!operational}
            onClick={() => act('gentoggle')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.gravity_generator.gravity_charge')}>
          <ProgressBar
            value={charge_count / 100}
            ranges={{
              good: [0.7, Infinity],
              average: [0.3, 0.7],
              bad: [-Infinity, 0.3],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.gravity_generator.charge_mode')}>
          {charging_state === 0 &&
            ((on && <Box color="good">{t('ui.gravity_generator.fully_charged')}</Box>) || (
              <Box color="bad">{t('ui.gravity_generator.not_charging')}</Box>
            ))}
          {charging_state === 1 && <Box color="average">{t('ui.gravity_generator.charging')}</Box>}
          {charging_state === 2 && <Box color="average">{t('ui.gravity_generator.discharging')}</Box>}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
