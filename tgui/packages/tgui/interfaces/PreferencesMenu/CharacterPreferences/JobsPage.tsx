import { sortBy } from 'es-toolkit';
import type { PropsWithChildren, ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Dropdown, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { usePreferencesLocalization } from './localization';

function sortJobs(entries: [string, Job][], head?: string) {
  return sortBy(entries, [
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  ]);
}

const PRIORITY_BUTTON_SIZE = '18px';

type PriorityButtonProps = {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Button
      className={classes([
        className,
        props.modifier && `${className}--${props.modifier}`,
      ])}
      color={props.enabled ? props.color : 'white'}
      circular
      onClick={props.onClick}
      tooltip={props.name}
      tooltipPosition="bottom"
      height={PRIORITY_BUTTON_SIZE}
      width={PRIORITY_BUTTON_SIZE}
    />
  );
}

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

function createCreateSetPriorityFromName(jobName: string): CreateSetPriority {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  function createSetPriority(priority: JobPriority | null) {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    function setPriority() {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    }

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  }

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
}

function PriorityHeaders() {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';
  const { t } = usePreferencesLocalization();

  return (
    <Stack>
      <Stack.Item grow />
      <Stack.Item className={className}>{t('jobs_off')}</Stack.Item>
      <Stack.Item className={className}>{t('jobs_low')}</Stack.Item>
      <Stack.Item className={className}>{t('jobs_medium')}</Stack.Item>
      <Stack.Item className={className}>{t('jobs_high')}</Stack.Item>
    </Stack>
  );
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { t } = usePreferencesLocalization();
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Box
      style={{
        alignItems: 'center',
        height: '100%',
        justifyContent: 'flex-end',
        paddingLeft: '0.3em',
        paddingTop: '0.12em',
        paddingBottom: '0.12em',
      }}
    >
      {isOverflow ? (
        <>
          <PriorityButton
            name={t('jobs_off')}
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name={t('jobs_on')}
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name={t('jobs_off')}
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name={t('jobs_low')}
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name={t('jobs_medium')}
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name={t('jobs_high')}
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Box>
  );
}

type JobRowProps = {
  className?: string;
  job: Job;
  name: string;
};

function JobRow(props: JobRowProps) {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { t, localizeAltJobTitle, localizeDataLabel, localizeJobName } =
    usePreferencesLocalization(data);
  const { className, job, name } = props;

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded = data.job_required_experience?.[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  const altTitleSelected = data.job_alt_titles[name]
    ? data.job_alt_titles[name]
    : name;

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> {t('jobs_as')}{' '}
          {localizeDataLabel(experience_type)}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> {t('jobs_day')}
          {daysLeft === 1 ? '' : t('jobs_day_plural_suffix')}{' '}
          {t('jobs_left')}
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{t('jobs_banned')}</b>
        </Stack.Item>
      </Stack>
    );
  } else if (job.nova_star && !data.is_nova_star) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{t('jobs_nova_stars_only')}</b>
        </Stack.Item>
      </Stack>
    );
  } else if (
    data.species_restricted_jobs &&
    data.species_restricted_jobs.indexOf(name) !== -1
  ) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{t('jobs_bad_species')}</b>
        </Stack.Item>
      </Stack>
    );
  } else {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        isOverflow={isOverflow}
        priority={priority}
      />
    );
  }

  return (
    <Stack.Item className={className} height="100%" mt={0}>
      <Stack fill align="center">
        <Tooltip content={localizeDataLabel(job.description)} position="bottom-start">
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {!job.alt_titles ? (
              localizeJobName(name)
            ) : (
              <Dropdown
                className="PreferencesMenu__Character__JobsDropdown"
                width="100%"
                options={job.alt_titles.map((title) => ({
                  value: title,
                  displayText: localizeAltJobTitle(title),
                }))}
                selected={altTitleSelected}
                onSelected={(value) =>
                  act('set_job_title', { job: name, new_title: value })
                }
              />
            )}
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          {rightSide}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type DepartmentProps = {
  department: string;
} & PropsWithChildren;

function Department(props: DepartmentProps) {
  const { children, department: name } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  const data = useServerPrefs();
  if (!data) return null;

  const { departments, jobs } = data.jobs;
  const department = departments[name];

  if (!department) {
    return null;
  }

  const jobsForDepartment = sortJobs(
    Object.entries(jobs).filter(([_, job]) => job.department === name),
    department.head,
  );

  return (
    <Box>
      <Stack fill vertical g={0}>
        {jobsForDepartment.map(([jobName, job]) => {
          return (
            <JobRow
              className={classes([
                className,
                jobName === department.head && 'head',
              ])}
              key={jobName}
              job={job}
              name={jobName}
            />
          );
        })}
      </Stack>

      {children}
    </Box>
  );
}

function JoblessRoleDropdown() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeJobName } = usePreferencesLocalization(data);
  const selected = data.character_preferences.misc.joblessrole;
  const overflowRoleName = localizeJobName(data.overflow_role);

  const options = [
    {
      displayText: t('jobs_join_as_role_if_unavailable').replace(
        '{role}',
        overflowRoleName,
      ),
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: t('jobs_join_as_random_if_unavailable'),
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: t('jobs_return_to_lobby_if_unavailable'),
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const selection = options.find((option) => option.value === selected)?.displayText;

  return (
    <Box position="absolute" right={0} width="30%">
      <Dropdown
        className="PreferencesMenu__Character__JobsRoleDropdown"
        width="100%"
        selected={selection}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
      />
    </Box>
  );
}

export function JobsPage() {
  return (
    <>
      <JoblessRoleDropdown />
      <Stack vertical fill>
        <Stack.Item mt={15}>
          <Stack fill g={1} className="PreferencesMenu__Jobs">
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department department="Engineering" />
                <Department department="Science" />
                <Department department="Silicon" />
                <Department department="Assistant" />
              </Stack>
            </Stack.Item>
            <Stack.Item mt={-5.9}>
              <Stack vertical>
                <PriorityHeaders />
                <Department department="Captain" />
                <Department department="Service" />
                <Department department="Cargo" />
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department department="Security" />
                <Department department="Medical" />
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
}

