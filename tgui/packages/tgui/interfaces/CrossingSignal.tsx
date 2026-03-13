import { LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  sensorStatus: BooleanLike;
  operatingStatus: number;
  inboundPlatform: number;
  outboundPlatform: number;
};

export const CrossingSignal = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  const { sensorStatus, operatingStatus, inboundPlatform, outboundPlatform } =
    data;

  return (
    <Window
      title={t('ui.crossing_signal.title')}
      width={400}
      height={175}
      theme="dark"
    >
      <Window.Content>
        <Section title={t('ui.crossing_signal.system_status')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.crossing_signal.operating_status')}
              color={operatingStatus ? 'bad' : 'good'}
            >
              {operatingStatus
                ? t('ui.crossing_signal.degraded')
                : t('ui.common.normal')}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.crossing_signal.sensor_status')}
              color={sensorStatus ? 'good' : 'bad'}
            >
              {sensorStatus
                ? t('ui.common.connected')
                : t('ui.common.error')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.crossing_signal.inbound_platform')}>
              {inboundPlatform}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.crossing_signal.outbound_platform')}>
              {outboundPlatform}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
