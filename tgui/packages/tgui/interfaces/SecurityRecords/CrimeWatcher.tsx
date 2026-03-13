import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Tabs,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { getSecurityRecord } from './helpers';
import { type Crime, SECURETAB, type SecurityRecordsData } from './types';

/** Displays a list of crimes and allows to add new ones. */
export const CrimeWatcher = (props) => {
  const { t } = usePreferencesLocalization();
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;
  const { crimes, citations } = foundRecord;
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    'selectedTab',
    SECURETAB.Crimes,
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Crimes)}
            selected={selectedTab === SECURETAB.Crimes}
          >
            {t('ui.security_records.crimes')}: {crimes.length}
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Citations)}
            selected={selectedTab === SECURETAB.Citations}
          >
            {t('ui.security_records.citations')}: {citations.length}
          </Tabs.Tab>
          <Tooltip content={t('ui.security_records.add_new_crime_or_citation')} position="bottom">
            <Tabs.Tab
              onClick={() => setSelectedTab(SECURETAB.Add)}
              selected={selectedTab === SECURETAB.Add}
            >
              <Icon name="plus" />
            </Tabs.Tab>
          </Tooltip>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {selectedTab < SECURETAB.Add ? (
            <CrimeList tab={selectedTab} />
          ) : (
            <CrimeAuthor />
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays the crimes and citations of a record. */
const CrimeList = (props) => {
  const { t } = usePreferencesLocalization();
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { citations, crimes } = foundRecord;
  const { tab } = props;
  const toDisplay = tab === SECURETAB.Crimes ? crimes : citations;

  return (
    <Stack fill vertical>
      {!toDisplay.length ? (
        <Stack.Item>
          <NoticeBox>
            {tab === SECURETAB.Crimes
              ? t('ui.security_records.no_crimes_found')
              : t('ui.security_records.no_citations_found')}
          </NoticeBox>
        </Stack.Item>
      ) : (
        toDisplay.map((item, index) => <CrimeDisplay key={index} item={item} />)
      )}
    </Stack>
  );
};

/** Displays an individual crime */
const CrimeDisplay = ({ item }: { item: Crime }) => {
  const { t } = usePreferencesLocalization();
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { crew_ref } = foundRecord;
  const { act, data } = useBackend<SecurityRecordsData>();
  const { current_user, higher_access } = data;
  const { author, crime_ref, details, fine, name, paid, time, valid, voider } =
    item;
  const showFine = !!fine && fine > 0 ? `: ${fine} cr` : `: ${t('ui.security_records.paid_off')}`;

  let collapsibleColor = '';
  if (!valid) {
    collapsibleColor = 'grey';
  } else if (fine && fine > 0) {
    collapsibleColor = 'average';
  }

  let displayTitle = name;
  if (fine !== undefined) {
    displayTitle = name.slice(0, 18) + showFine;
  }

  const [editing, setEditing] = useLocalState(`editing_${crime_ref}`, false);

  return (
    <Stack.Item>
      <Collapsible color={collapsibleColor} open={editing} title={displayTitle}>
        <LabeledList>
          <LabeledList.Item label={t('ui.common.time')}>{time}</LabeledList.Item>
          <LabeledList.Item label={t('ui.common.author')}>{author}</LabeledList.Item>
          <LabeledList.Item color={!valid ? 'bad' : 'good'} label={t('ui.common.status')}>
            {!valid ? t('ui.security_records.void') : t('ui.common.active')}
          </LabeledList.Item>
          {!valid && (
            <LabeledList.Item
              color={voider ? 'gold' : 'good'}
              label={t('ui.security_records.voided_by')}
            >
              {!voider ? t('ui.security_records.automation') : voider}
            </LabeledList.Item>
          )}
          {!!fine && fine > 0 && (
            <>
              <LabeledList.Item color="bad" label={t('ui.security_records.fine')}>
                {fine}cr <Icon color="gold" name="coins" />
              </LabeledList.Item>
              <LabeledList.Item color="good" label={t('ui.security_records.paid')}>
                {paid}cr <Icon color="gold" name="coins" />
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
        <Box color="label" mt={1} mb={1}>
          {t('ui.security_records.details')}:
        </Box>
        <BlockQuote>{details}</BlockQuote>

        {!editing ? (
          <Box mt={2}>
            <Button
              disabled={!valid || (!higher_access && author !== current_user)}
              icon="pen"
              onClick={() => setEditing(true)}
            >
              {t('ui.common.edit')}
            </Button>
            <Button.Confirm
              content={t('ui.security_records.invalidate')}
              disabled={!valid || (!higher_access && author !== current_user)}
              icon="ban"
              onClick={() =>
                act('invalidate_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                })
              }
            />
          </Box>
        ) : (
          <>
            <Input
              fluid
              maxLength={25}
              onEscape={() => setEditing(false)}
              onEnter={(value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  name: value,
                });
              }}
              placeholder={t('ui.security_records.enter_new_name')}
            />
            <Input
              fluid
              maxLength={1025}
              mt={1}
              onEscape={() => setEditing(false)}
              onEnter={(value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  description: value,
                });
              }}
              placeholder={t('ui.security_records.enter_new_description')}
            />
          </>
        )}
      </Collapsible>
    </Stack.Item>
  );
};

/** Writes a new crime. Reducers don't seem to work here, so... */
const CrimeAuthor = (props) => {
  const { t } = usePreferencesLocalization();
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { crew_ref } = foundRecord;
  const { act } = useBackend<SecurityRecordsData>();

  const [crimeName, setCrimeName] = useState('');
  const [crimeDetails, setCrimeDetails] = useState('');
  const [crimeFine, setCrimeFine] = useState(0);
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    'selectedTab',
    SECURETAB.Crimes,
  );
  const [crimeFineIsValid, setCrimeFineIsValid] = useState(true);

  const nameMeetsReqs = crimeName?.length > 2;

  /** Sends form to backend */
  const createCrime = () => {
    if (!crimeName || !crimeFineIsValid) return;
    act('add_crime', {
      crew_ref: crew_ref,
      details: crimeDetails,
      fine: crimeFine,
      name: crimeName,
    });
    reset();
  };

  /** Resets form data since it persists.. */
  const reset = () => {
    setCrimeDetails('');
    setCrimeFine(0);
    setCrimeName('');
    setSelectedTab(crimeFine ? SECURETAB.Citations : SECURETAB.Crimes);
  };

  return (
    <Stack fill vertical>
      <Stack.Item color="label">
        {t('ui.common.name')}
        <Input
          fluid
          maxLength={25}
          onChange={setCrimeName}
          placeholder={t('ui.security_records.brief_overview')}
        />
      </Stack.Item>
      <Stack.Item color="label">
        {t('ui.security_records.details')}
        <TextArea
          fluid
          height={4}
          maxLength={1025}
          onChange={setCrimeDetails}
          placeholder={t('ui.security_records.type_some_details')}
        />
      </Stack.Item>
      <Stack.Item color="label">
        {t('ui.security_records.fine_leave_blank_to_arrest')}
        <RestrictedInput
          fluid
          value={crimeFine}
          maxValue={1000}
          onChange={setCrimeFine}
          onValidationChange={setCrimeFineIsValid}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          disabled={!nameMeetsReqs || !crimeFineIsValid}
          icon="plus"
          onClick={createCrime}
          tooltip={!nameMeetsReqs ? t('ui.security_records.name_min_length') : ''}
        >
          {t('ui.common.create')}
        </Button.Confirm>
      </Stack.Item>
    </Stack>
  );
};
