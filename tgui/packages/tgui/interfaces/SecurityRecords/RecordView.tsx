import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { usePreferencesLocalization } from '../localization';

import { CharacterPreview } from '../common/CharacterPreview';
import { EditableText } from '../common/EditableText';
import { CRIMESTATUS2COLOR, CRIMESTATUS2DESC } from './constants';
import { CrimeWatcher } from './CrimeWatcher';
import { getSecurityRecord } from './helpers';
import { RecordPrint } from './RecordPrint';
import type { SecurityRecordsData } from './types';

/** Views a selected record. */
export const SecurityRecordView = (props) => {
  const foundRecord = getSecurityRecord();
  const { data } = useBackend<SecurityRecordsData>();
  const { t } = usePreferencesLocalization(data);
  if (!foundRecord) return <NoticeBox>{t('ui.common.nothing_selected')}</NoticeBox>;

  const { assigned_view } = data;

  const [open] = useLocalState<boolean>('printOpen', false);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={assigned_view} />
          </Stack.Item>
          <Stack.Item grow>
            <CrimeWatcher />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>{open ? <RecordPrint /> : <RecordInfo />}</Stack.Item>
    </Stack>
  );
};

const RecordInfo = (props) => {
  const foundRecord = getSecurityRecord();
  const { act, data } = useBackend<SecurityRecordsData>();
  const { t } = usePreferencesLocalization(data);
  if (!foundRecord) return <NoticeBox>{t('ui.common.nothing_selected')}</NoticeBox>;

  const { available_statuses } = data;
  const [open, setOpen] = useLocalState<boolean>('printOpen', false);

  // const { min_age, max_age } = data; // ORIGINAL
  const { min_age, max_age, max_chrono_age } = data; // NOVA EDIT CHANGE - Chronological age

  const {
    age,
    chrono_age, // NOVA EDIT ADDITION - Chronological age
    crew_ref,
    crimes,
    fingerprint,
    gender,
    name,
    note,
    rank,
    species,
    wanted_status,
    voice,
    // NOVA EDIT START - RP Records
    past_general_records,
    past_security_records,
    // NOVA EDIT END
  } = foundRecord;

  const [isValid, setIsValid] = useState(true);

  const hasValidCrimes = !!crimes.find((crime) => !!crime.valid);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  height="1.7rem"
                  icon="print"
                  onClick={() => setOpen(true)}
                  tooltip={t('ui.security_records.print_rapsheet_or_poster')}
                >
                  {t('ui.common.print')}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  icon="trash"
                  onClick={() => act('delete_record', { crew_ref: crew_ref })}
                  tooltip={t('ui.security_records.delete_record_data')}
                >
                  {t('ui.common.delete')}
                </Button.Confirm>
              </Stack.Item>
            </Stack>
          }
          fill
          title={
            <Table.Cell color={CRIMESTATUS2COLOR[wanted_status]}>
              {name}
            </Table.Cell>
          }
        >
          <LabeledList>
            <LabeledList.Item
              buttons={available_statuses.map((button, index) => {
                const isSelected = button === wanted_status;
                return (
                  <Button
                    color={isSelected ? CRIMESTATUS2COLOR[button] : 'grey'}
                    disabled={button === 'Arrest' && !hasValidCrimes}
                    icon={isSelected ? 'check' : ''}
                    key={index}
                    onClick={() =>
                      act('set_wanted', {
                        crew_ref: crew_ref,
                        status: button,
                      })
                    }
                    pl={!isSelected ? '1.8rem' : 1}
                    tooltip={CRIMESTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start"
                  >
                    {button[0]}
                  </Button>
                );
              })}
              label={t('ui.common.status')}
            >
              <Box color={CRIMESTATUS2COLOR[wanted_status]}>
                {wanted_status}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow={2}>
        <Section fill scrollable>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              <EditableText field="name" target_ref={crew_ref} text={name} />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.job')}>
              <EditableText field="rank" target_ref={crew_ref} text={rank} />
            </LabeledList.Item>
            {/* ORIGINAL AGE FIELD */}
            {/* NOVA EDIT CHANGE BEGIN - Chronological age */}
            <LabeledList.Item label={t('ui.common.physical_age')}>
              {/* NOVA EDIT CHANGE END */}
              <RestrictedInput
                minValue={min_age}
                maxValue={max_age}
                onEnter={(value) =>
                  isValid &&
                  act('edit_field', {
                    crew_ref: crew_ref,
                    field: 'age',
                    value: value,
                  })
                }
                onValidationChange={setIsValid}
                value={age}
              />
            </LabeledList.Item>
            {/* NOVA EDIT ADDITION BEGIN - Chronological age */}
            <LabeledList.Item label={t('ui.common.chronological_age')}>
              <RestrictedInput
                minValue={min_age}
                maxValue={max_chrono_age}
                onEnter={(value) =>
                  act('edit_field', {
                    crew_ref: crew_ref,
                    field: 'chrono_age',
                    value: value,
                  })
                }
                value={chrono_age}
              />
            </LabeledList.Item>
            {/* NOVA EDIT ADDITION END */}
            <LabeledList.Item label={t('ui.common.species')}>
              <EditableText
                field="species"
                target_ref={crew_ref}
                text={species}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.gender')}>
              <EditableText
                field="gender"
                target_ref={crew_ref}
                text={gender}
              />
            </LabeledList.Item>
            <LabeledList.Item color="good" label={t('ui.security_records.fingerprint')}>
              <EditableText
                color="good"
                field="fingerprint"
                target_ref={crew_ref}
                text={fingerprint}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.voice')}>
              <EditableText field="voice" target_ref={crew_ref} text={voice} />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.note')}>
              <EditableText
                field="security_note"
                target_ref={crew_ref}
                text={note}
              />
            </LabeledList.Item>
            {/* NOVA EDIT START - RP Records (Not pretty but it's there) */}
            <LabeledList.Item label={t('ui.common.general_records')}>
              <Box maxWidth="100%" preserveWhitespace>
                {past_general_records || 'N/A'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.security_records.past_security_records')}>
              <Box maxWidth="100%" preserveWhitespace>
                {past_security_records || 'N/A'}
              </Box>
            </LabeledList.Item>
            {/* NOVA EDIT END */}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
