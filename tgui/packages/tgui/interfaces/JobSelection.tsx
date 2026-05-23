import { toMerged } from 'es-toolkit';
import { Color } from 'tgui-core/color';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
  StyleableSection,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';
import { usePreferencesLocalization } from './localization';

type Job = {
  unavailable_reason: string | null;
  command: BooleanLike;
  open_slots: number;
  used_slots: number;
  prioritized: BooleanLike;
  description: string;
};

type Department = {
  color: string;
  jobs: Record<string, Job>;
  open_slots: number;
};

type Data = {
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
  round_duration: string;
  alert_level: { name: string; color: string }; // NOVA EDIT ADDITION - Alert level on jobs menu
};

type JobEntryProps = {
  jobName: string;
  job: Job;
  department: Department;
  onClick: () => void;
};

function JobEntry(props: JobEntryProps) {
  const { jobName, job, department, onClick } = props;
  const { t } = usePreferencesLocalization();

  const jobIcon = JOB2ICON[jobName] || null;

  return (
    <Button
      fluid
      style={{
        // Try not to think too hard about this one.
        backgroundColor: job.unavailable_reason
          ? '#949494' // Grey background
          : job.prioritized
            ? '#16fc0f' // Bright green background
            : Color.fromHex(department.color).darken(10).toString(),
        backgroundImage: 'none',
        color: job.unavailable_reason
          ? '#616161' // Dark grey font
          : Color.fromHex(department.color).darken(90).toString(),
        fontSize: '1.1rem',
        cursor: job.unavailable_reason ? 'initial' : 'pointer',
      }}
      tooltip={
        job.unavailable_reason ||
        (job.prioritized ? (
          <>
            <p style={{ marginTop: '0px' }}>
              <b>{t('ui.jobselection.the_hop_wants_more_people_in_this_job')}</b>
            </p>
            {job.description}
          </>
        ) : (
          job.description
        ))
      }
      tooltipPosition="top"
      onClick={() => {
        !job.unavailable_reason && onClick();
      }}
    >
      <Stack fill>
        {jobIcon && (
          <Stack.Item>
            <Icon name={jobIcon} />
          </Stack.Item>
        )}
        <Stack.Item grow>{job.command ? <b>{jobName}</b> : jobName}</Stack.Item>
        <Stack.Item>
          <span
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {job.used_slots} / {job.open_slots}
          </span>
        </Stack.Item>
      </Stack>
    </Button>
  );
}

type DepartmentEntryProps = {
  name: string;
  department: Department;
};

function DepartmentEntry(props: DepartmentEntryProps) {
  const { name, department } = props;
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();

  return (
    <Box minWidth="30%">
      <StyleableSection
        title={
          <>
            {name}
            <span
              style={{
                fontSize: '1rem',
                whiteSpace: 'nowrap',
                position: 'absolute',
                right: '1em',
                color: Color.fromHex(department.color).darken(60).toString(),
              }}
            >
              {department.open_slots +
                (department.open_slots === 1
                  ? t('ui.job_selection.slot_available_suffix')
                  : t('ui.job_selection.slots_available_suffix'))}
            </span>
          </>
        }
        style={{
          backgroundColor: department.color,
          marginBottom: '1em',
          breakInside: 'avoid-column',
        }}
        titleStyle={{
          'border-bottom-color': Color.fromHex(department.color)
            .darken(50)
            .toString(),
        }}
        textStyle={{
          color: Color.fromHex(department.color).darken(80).toString(),
        }}
      >
        <Stack vertical>
          {Object.entries(department.jobs).map(([name, job]) => (
            <Stack.Item key={name}>
              <JobEntry
                key={name}
                jobName={name}
                job={job}
                department={department}
                onClick={() => {
                  act('select_job', { job: name });
                }}
              />
            </Stack.Item>
          ))}
        </Stack>
      </StyleableSection>
    </Box>
  );
}

export function JobSelection(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  if (!data?.departments_static) {
    return null; // Stop TGUI whitescreens with TGUI-dev!
  }

  const departments: Record<string, Department> = toMerged(
    data.departments,
    data.departments_static,
  );

  const { shuttle_status, round_duration } = data;

  return (
    <Window width={1012} height={shuttle_status ? 916 : 900 /* Hahahahahaha */}>
      {/* NOVA EDIT CHANGE above - Expand UI for available jobs - ORIGINAL: height={shuttle_status ? 690 : 666 */}
      <Window.Content>
        <Section
          buttons={
            <Button
              onClick={() => act('select_job', { job: 'Random' })}
              tooltip={t(
                'ui.jobselection.roll_target_random_job_you_can_re_roll_or_cancel_your_random_job',
              )}
            >
              {t('ui.job_selection.random_job')}
            </Button>
          }
          fill
          scrollable
          title={
            <>
              {shuttle_status && <NoticeBox info>{shuttle_status}</NoticeBox>}
              {
                /* NOVA EDIT ADDITION START - Alert level on jobs menu */
                <NoticeBox color={data.alert_level.color}>
                  {t('ui.job_selection.current_alert_level_is').replace(
                    '{level}',
                    data.alert_level.name,
                  )}
                </NoticeBox>
                /* NOVA EDIT ADDITION END */
              }
              <Box as="span" color="label">
                {t('ui.job_selection.current_shift_time').replace(
                  '{duration}',
                  round_duration,
                )}
              </Box>
            </>
          }
        >
          <Box style={{ columns: '20em' }}>
            {Object.entries(departments).map(([name, department]) => (
              <DepartmentEntry key={name} name={name} department={department} />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
