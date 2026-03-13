import { LabeledList, NoticeBox } from 'tgui-core/components';
import { usePreferencesLocalization } from '../localization';

import type { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
};

/** Displays some info on the mob as a tooltip. */
export function OrbitTooltip(props: Props) {
  const { item, realNameDisplay } = props;
  const { extra, full_name, health, job, mind_job } = item;
  const { t } = usePreferencesLocalization();

  let antag;
  if ('antag' in item) {
    antag = item.antag;
  }

  const extraInfo = extra?.split(':');
  const displayHealth =
    !!health && health >= 0 ? `${health}%` : t('ui.orbit.critical');
  const showAFK = 'client' in item && !item.client;
  const displayJob = realNameDisplay ? mind_job : job;

  return (
    <>
      <NoticeBox textAlign="center" nowrap info={showAFK}>
        {t('ui.orbit.last_known_data')}
      </NoticeBox>
      <LabeledList>
        {extraInfo ? (
          <LabeledList.Item label={extraInfo[0]}>
            {extraInfo[1]}
          </LabeledList.Item>
        ) : (
          <>
            {!!full_name && (
              <LabeledList.Item label={t('ui.orbit.real_id')}>
                {full_name}
              </LabeledList.Item>
            )}
            {!!displayJob && (
              <LabeledList.Item label={t('ui.common.job')}>
                {displayJob}
              </LabeledList.Item>
            )}
            {!!antag && (
              <LabeledList.Item label={t('ui.orbit.threat')}>
                {antag}
              </LabeledList.Item>
            )}
            {!!health && (
              <LabeledList.Item label={t('ui.common.health')}>
                {displayHealth}
              </LabeledList.Item>
            )}
          </>
        )}
        {showAFK && (
          <LabeledList.Item label={t('ui.common.status')}>
            {t('ui.orbit.away')}
          </LabeledList.Item>
        )}
      </LabeledList>
    </>
  );
}
