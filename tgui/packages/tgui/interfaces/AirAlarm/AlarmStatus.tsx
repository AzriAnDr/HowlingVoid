import { LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { AirAlarmData } from './types';

const dangerMap = {
  0: {
    color: 'good',
    localStatusTextKey: 'ui.air_alarm.optimal',
  },
  1: {
    color: 'average',
    localStatusTextKey: 'ui.air_alarm.caution',
  },
  2: {
    color: 'bad',
    localStatusTextKey: 'ui.air_alarm.danger_internals_required',
  },
} as const;

const faultMap = {
  0: {
    color: 'good',
    areaFaultTextKey: 'ui.common.none',
  },
  1: {
    color: 'purple',
    areaFaultTextKey: 'ui.air_alarm.manual_trigger',
  },
  2: {
    color: 'average',
    areaFaultTextKey: 'ui.air_alarm.automatic_detection',
  },
} as const;

export function AirAlarmStatus(props) {
  const { data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { envData } = data;

  const localStatus = dangerMap[data.dangerLevel] || dangerMap[0];
  const areaFault = faultMap[data.faultStatus] || faultMap[0];

  return (
    <Section title={t('ui.air_alarm.air_status')}>
      <LabeledList>
        {envData.length <= 0 ? (
          <LabeledList.Item label={t('ui.common.warning')} color="bad">
            {t('ui.air_alarm.cannot_obtain_air_sample')}
          </LabeledList.Item>
        ) : (
          <>
            {envData.map((entry) => {
              const status = dangerMap[entry.danger] || dangerMap[0];
              return (
                <LabeledList.Item
                  key={entry.name}
                  label={entry.name}
                  color={status.color}
                >
                  {entry.value}
                </LabeledList.Item>
              );
            })}
            <LabeledList.Item label={t('ui.air_alarm.local_status')} color={localStatus.color}>
              {t(localStatus.localStatusTextKey)}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.air_alarm.area_status')}
              color={data.atmosAlarm || data.fireAlarm ? 'bad' : 'good'}
            >
              {(data.atmosAlarm && t('ui.air_alarm.atmosphere_alarm')) ||
                (data.fireAlarm && t('ui.air_alarm.fire_alarm')) ||
                t('ui.air_alarm.nominal')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.air_alarm.fault_status')} color={areaFault.color}>
              {t(areaFault.areaFaultTextKey)}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.air_alarm.fault_location')}
              color={data.faultLocation ? 'blue' : 'good'}
            >
              {data.faultLocation || t('ui.common.none')}
            </LabeledList.Item>
          </>
        )}
        {!!data.emagged && (
          <LabeledList.Item label={t('ui.common.warning')} color="bad">
            {t('ui.air_alarm.safety_measures_offline')}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
