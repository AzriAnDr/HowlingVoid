import { sortBy } from 'es-toolkit';
import type { PropsWithChildren, ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Dropdown, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import jobsRu from './locales/jobs.ru.json';
import {
  getCharacterPreferencesLanguage,
  localize,
} from './localization';

import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

type JobsLocale = {
  job_names: Record<string, string>;
  alt_job_titles: Record<string, string>;
  experience_types: Record<string, string>;
};

const JOBS_LOCALE_RU = jobsRu as JobsLocale;

function localizeJobName(language: 'english' | 'russian', name: string): string {
  if (language !== 'russian') {
    return name;
  }
  return JOBS_LOCALE_RU.job_names[name] ?? name;
}

function localizeAltTitle(language: 'english' | 'russian', title: string): string {
  if (language !== 'russian') {
    return title;
  }
  return (
    JOBS_LOCALE_RU.alt_job_titles[title] ??
    JOBS_LOCALE_RU.job_names[title] ??
    title
  );
}

function localizeExperienceType(language: 'english' | 'russian', exp: string): string {
  if (language !== 'russian') {
    return exp;
  }
  return JOBS_LOCALE_RU.experience_types[exp] ?? exp;
}

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
    // NOVA EDIT START
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
    // NOVA EDIT END
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
  const { data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  return (
    <Stack>
      <Stack.Item grow />

      <Stack.Item className={className}>{localize(language, 'Off')}</Stack.Item>

      <Stack.Item className={className}>{localize(language, 'Low')}</Stack.Item>

      <Stack.Item className={className}>{localize(language, 'Medium')}</Stack.Item>

      <Stack.Item className={className}>{localize(language, 'High')}</Stack.Item>
    </Stack>
  );
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Box // NOVA EDIT - Originally a stack
      style={{
        alignItems: 'center',
        height: '100%',
        justifyContent: 'flex-end',
        paddingLeft: '0.3em',
        paddingTop: '0.12em', // NOVA EDIT ADDITION - Add some vertical padding
        paddingBottom: '0.12em', // NOVA EDIT ADDITION - To make this look nicer
      }}
    >
      {isOverflow ? (
        <>
          <PriorityButton
            name={localize(language, 'Off')}
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name={localize(language, 'On')}
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name={localize(language, 'Off')}
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name={localize(language, 'Low')}
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name={localize(language, 'Medium')}
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name={localize(language, 'High')}
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Box> // NOVA EDIT - Originally a stack
  );
}

type JobRowProps = {
  className?: string;
  job: Job;
  name: string;
};

function JobRow(props: JobRowProps) {
  const { data, act } = useBackend<PreferencesMenuData>(); // NOVA EDIT CHANGE - Adds act param
  const language = getCharacterPreferencesLanguage(data);
  const { className, job, name } = props;

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded = data.job_required_experience?.[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  // NOVA EDIT ADDITION START
  const alt_title_selected = data.job_alt_titles[name]
    ? data.job_alt_titles[name]
    : name;
  // NOVA EDIT ADDITION END

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
          <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> {localize(language, 'as')} {localizeExperienceType(language, experience_type)}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    const daysSuffix =
      daysLeft === 1 ? localize(language, 'day') : localize(language, 'days');
    const daysLeftText = localize(language, 'left');
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> {daysSuffix} {daysLeftText}
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{localize(language, 'Banned')}</b>
        </Stack.Item>
      </Stack>
    );
    // NOVA EDIT START
  } else if (job.nova_star && !data.is_nova_star) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{localize(language, 'Nova Stars Only')}</b>
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
          <b>{localize(language, 'Bad species')}</b>
        </Stack.Item>
      </Stack>
    );
    // NOVA EDIT END
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
        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {
              // NOVA EDIT CHANGE START - ORIGINAL: {name}
              !job.alt_titles ? (
                localizeJobName(language, name)
              ) : (
                <Dropdown
                  className="PreferencesMenu__Character__JobsDropdown"
                  width="100%"
                  options={job.alt_titles.map((title) => ({
                    displayText: localizeAltTitle(language, title),
                    value: title,
                  }))}
                  selected={alt_title_selected}
                  displayText={localizeAltTitle(language, alt_title_selected)}
                  onSelected={(value) =>
                    act('set_job_title', { job: name, new_title: value })
                  }
                />
              )
              // NOVA EDIT CHANGE END
            }
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
  if (!data) return;

  const { departments, jobs } = data.jobs;
  const department = departments[name];

  // This isn't necessarily a bug, it's like this
  // so that you can remove entire departments without
  // having to edit the UI.
  // This is used in events, for instance.
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
        {jobsForDepartment.map(([name, job]) => {
          return (
            <JobRow
              className={classes([
                className,
                name === department.head && 'head',
              ])}
              key={name}
              job={job}
              name={name}
            />
          );
        })}
      </Stack>

      {children}
    </Box>
  );
}

function JoblessRoleDropdown(props) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  const selected = data.character_preferences.misc.joblessrole;
  const overflowRole = localizeJobName(language, data.overflow_role);
  const overflowTemplate = localize(language, 'Join as {role} if unavailable');
  const overflowText = overflowTemplate.replace('{role}', overflowRole);

  const optionsRaw = [
    {
      displayText: overflowText,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const options = optionsRaw.map((option) => ({
    ...option,
    displayText: localize(language, option.displayText),
  }));

  const selection = options?.find(
    (option) => option.value === selected,
  )?.displayText;

  return (
    <Box
      className="PreferencesMenu__Character__JobsRoleDropdown"
      position="absolute"
      right={0}
      width="30%"
    >
      <Dropdown
        className="PreferencesMenu__Character__JobsRoleDropdown"
        width="100%"
        selected={selection}
        displayText={selection}
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
