import type { ReactNode } from 'react';
import { Box, NoticeBox } from 'tgui-core/components';
import { usePreferencesLocalization } from '../localization';

import type { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
};

type TooltipItemProps = {
  label: string;
  children: ReactNode;
};

const TooltipItem = (props: TooltipItemProps) => {
  const { label, children } = props;

  return (
    <Box className="OrbitTooltip__item">
      <Box className="OrbitTooltip__label">{label}</Box>
      <Box className="OrbitTooltip__value">{children}</Box>
    </Box>
  );
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
      <Box className="OrbitTooltip">
        {extraInfo ? (
          <TooltipItem label={extraInfo[0]}>{extraInfo[1]}</TooltipItem>
        ) : (
          <>
            {!!full_name && (
              <TooltipItem label={t('ui.orbit.real_id')}>
                {full_name}
              </TooltipItem>
            )}
            {!!displayJob && (
              <TooltipItem label={t('ui.common.job')}>{displayJob}</TooltipItem>
            )}
            {!!antag && (
              <TooltipItem label={t('ui.orbit.threat')}>{antag}</TooltipItem>
            )}
            {!!health && (
              <TooltipItem label={t('ui.common.health')}>
                {displayHealth}
              </TooltipItem>
            )}
          </>
        )}
        {showAFK && (
          <TooltipItem label={t('ui.common.status')}>
            {t('ui.orbit.away')}
          </TooltipItem>
        )}
      </Box>
    </>
  );
}
