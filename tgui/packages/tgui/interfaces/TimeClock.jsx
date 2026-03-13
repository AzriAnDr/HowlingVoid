// THIS IS A NOVA SECTOR UI FILE
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const TimeClock = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    inserted_id,
    insert_id_cooldown,
    id_holder_name,
    id_job_title,
    station_alert_level,
    current_time,
    clock_status,
  } = data;

  return (
    <Window title={t('ui.time_clock.title')} width={500} height={250} resizable>
      <Window.Content>
        <Section>
          <Box textAlign="center" fontSize="15px">
            {t('ui.time_clock.station_time')}: <b>{current_time}</b>
          </Box>
          <Box textAlign="center" fontSize="15px">
            {t('ui.time_clock.current_alert_level')}: <b>{station_alert_level}</b>
          </Box>
        </Section>
        {inserted_id ? (
          <>
            <Section title={false}>
              <LabeledList>
                <LabeledList.Item label={t('ui.time_clock.id_holder')}>
                  {id_holder_name}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.time_clock.current_job')}>
                  {id_job_title}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Box>
              <Button
                width="95%"
                disabled={insert_id_cooldown}
                onClick={() => act('clock_in_or_out')}
              >
                <center>
                  {clock_status
                    ? t('ui.time_clock.clock_in')
                    : t('ui.time_clock.clock_out')}
                </center>
              </Button>
              <Button icon="eject" onClick={() => act('eject_id')} />
            </Box>
          </>
        ) : (
          <Section title={false}>
            {' '}
            <Box fontSize="18px">
              <center>
                <b>{t('ui.time_clock.insert_id_to_begin')}</b>
              </center>
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
