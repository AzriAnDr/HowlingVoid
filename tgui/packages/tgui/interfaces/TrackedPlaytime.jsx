import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Flex,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED = 1;
const JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS = 2;

const sortByPlaytime = (array) => sortBy(array, [([_, playtime]) => -playtime]);

const PlaytimeSection = (props) => {
  const { t } = usePreferencesLocalization();
  const { playtimes } = props;

  const sortedPlaytimes = sortByPlaytime(Object.entries(playtimes)).filter(
    (entry) => entry[1],
  );

  if (!sortedPlaytimes.length) {
    return t('ui.tracked_playtime.no_recorded_playtime');
  }

  const mostPlayed = sortedPlaytimes[0][1];
  return (
    <Table>
      {sortedPlaytimes.map(([jobName, playtime]) => {
        const ratio = playtime / mostPlayed;
        return (
          <Table.Row key={jobName}>
            <Table.Cell
              collapsing
              p={0.5}
              style={{
                verticalAlign: 'middle',
              }}
            >
              <Box align="right">{jobName}</Box>
            </Table.Cell>
            <Table.Cell>
              <ProgressBar maxValue={mostPlayed} value={playtime}>
                <Flex>
                  <Flex.Item width={`${ratio * 100}%`} />
                  <Flex.Item>
                    {(playtime / 60).toLocaleString(undefined, {
                      minimumFractionDigits: 1,
                      maximumFractionDigits: 1,
                    })}
                    h
                  </Flex.Item>
                </Flex>
              </ProgressBar>
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
};

export const TrackedPlaytime = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const {
    failReason,
    jobPlaytimes,
    specialPlaytimes,
    exemptStatus,
    isAdmin,
    livingTime,
    ghostTime,
    adminTime,
  } = data;
  return (
    <Window title={t('ui.tracked_playtime.title')} width={550} height={650}>
      <Window.Content scrollable>
        {(failReason &&
          ((failReason === JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED && (
            <Box>{t('ui.tracked_playtime.tracking_disabled')}</Box>
          )) ||
            (failReason === JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS && (
              <Box>{t('ui.tracked_playtime.no_records')}</Box>
            )))) || (
          <Box>
            <Section title={t('ui.common.total')}>
              <PlaytimeSection
                playtimes={{
                  [t('ui.tracked_playtime.ghost')]: ghostTime,
                  [t('ui.tracked_playtime.living')]: livingTime,
                  [t('ui.common.admin')]: adminTime,
                }}
              />
            </Section>
            <Section
              title={t('ui.common.jobs')}
              buttons={
                !!isAdmin && (
                  <Button.Checkbox
                    checked={!!exemptStatus}
                    onClick={() => act('toggle_exempt')}
                  >
                    {t('ui.tracked_playtime.job_playtime_exempt')}
                  </Button.Checkbox>
                )
              }
            >
              <PlaytimeSection playtimes={jobPlaytimes} />
            </Section>
            <Section title={t('ui.common.special')}>
              <PlaytimeSection playtimes={specialPlaytimes} />
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
