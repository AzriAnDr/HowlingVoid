import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { CharacterPreview } from '../common/CharacterPreview';
import { EditableText } from '../common/EditableText';
import {
  MENTALSTATUS2COLOR,
  MENTALSTATUS2DESC,
  MENTALSTATUS2ICON,
  PHYSICALSTATUS2COLOR,
  PHYSICALSTATUS2DESC,
  PHYSICALSTATUS2ICON,
} from './constants';
import { getQuirkStrings, useMedicalRecord } from './helpers';
import { NoteKeeper } from './NoteKeeper';
import type { MedicalRecordData } from './types';

/** Views a selected record. */
export const MedicalRecordView = (props) => {
  const foundRecord = useMedicalRecord();
  const { act, data } = useBackend<MedicalRecordData>();
  const { t } = usePreferencesLocalization(data);
  const [isValid, setIsValid] = useState(true);

  if (!foundRecord) return <NoticeBox>{t('ui.medical_records.no_record_selected')}</NoticeBox>;

  const { assigned_view, physical_statuses, mental_statuses, station_z } = data;

  // const { min_age, max_age } = data; // ORIGINAL
  const { min_age, max_age, max_chrono_age } = data; // NOVA EDIT CHANGE - Chronological age

  const {
    age,
    chrono_age, // NOVA EDIT ADDITION - Chronological age
    blood_type,
    crew_ref,
    dna,
    gender,
    major_disabilities,
    minor_disabilities,
    physical_status,
    mental_status,
    name,
    quirk_notes,
    rank,
    // NOVA EDIT START - RP Records
    past_general_records,
    past_medical_records,
    // NOVA EDIT END
    species,
  } = foundRecord;

  const minor_disabilities_array = getQuirkStrings(minor_disabilities);
  const major_disabilities_array = getQuirkStrings(major_disabilities);
  const quirk_notes_array = getQuirkStrings(quirk_notes);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={assigned_view} />
          </Stack.Item>
          <Stack.Item grow>
            <NoteKeeper />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          buttons={
            <Button.Confirm
              icon="trash"
              disabled={!station_z}
              onClick={() => act('expunge_record', { crew_ref: crew_ref })}
              tooltip={t('ui.medical_records.expunge_record_data')}
            >
              {t('ui.common.delete')}
            </Button.Confirm>
          }
          fill
          scrollable
          title={name}
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>
              <EditableText field="name" target_ref={crew_ref} text={name} />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.job')}>
              <EditableText field="job" target_ref={crew_ref} text={rank} />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.physical_age')}>
              <RestrictedInput
                minValue={min_age}
                maxValue={max_age}
                onEnter={(value) =>
                  isValid &&
                  act('edit_field', {
                    field: 'age',
                    ref: crew_ref,
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
                    field: 'chrono_age',
                    ref: crew_ref,
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
            <LabeledList.Item label={t('ui.common.dna')}>
              <EditableText
                color="good"
                field="dna"
                target_ref={crew_ref}
                text={dna}
              />
            </LabeledList.Item>
            <LabeledList.Item color="bad" label={t('ui.medical_records.blood_type')}>
              <EditableText
                field="blood_type"
                target_ref={crew_ref}
                text={blood_type}
              />
            </LabeledList.Item>
            <LabeledList.Item
              buttons={physical_statuses.map((button, index) => {
                const isSelected = button === physical_status;
                return (
                  <Button
                    color={isSelected ? PHYSICALSTATUS2COLOR[button] : 'grey'}
                    height={'1.75rem'}
                    icon={PHYSICALSTATUS2ICON[button]}
                    key={index}
                    onClick={() =>
                      act('set_physical_status', {
                        crew_ref: crew_ref,
                        physical_status: button,
                      })
                    }
                    textAlign="center"
                    tooltip={PHYSICALSTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start"
                    width={!isSelected ? '3.0rem' : 3.0}
                  >
                    {button[0]}
                  </Button>
                );
              })}
              label={t('ui.medical_records.physical_status')}
            >
              <Box color={PHYSICALSTATUS2COLOR[physical_status]}>
                {physical_status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              buttons={mental_statuses.map((button, index) => {
                const isSelected = button === mental_status;
                return (
                  <Button
                    color={isSelected ? MENTALSTATUS2COLOR[button] : 'grey'}
                    height={'1.75rem'}
                    icon={MENTALSTATUS2ICON[button]}
                    key={index}
                    onClick={() =>
                      act('set_mental_status', {
                        crew_ref: crew_ref,
                        mental_status: button,
                      })
                    }
                    textAlign="center"
                    tooltip={MENTALSTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start"
                    width={!isSelected ? '3.0rem' : 3.0}
                  >
                    {button[0]}
                  </Button>
                );
              })}
              label={t('ui.medical_records.mental_status')}
            >
              <Box color={MENTALSTATUS2COLOR[mental_status]}>
                {mental_status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.medical_records.minor_disabilities')}>
              {minor_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.medical_records.major_disabilities')}>
              {major_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.medical_records.quirks')}>
              {quirk_notes_array.map((quirk, index) => (
                <Box key={index}>&#8226; {quirk}</Box>
              ))}
            </LabeledList.Item>
            {/* NOVA EDIT START - RP Records (Not pretty but it's there) */}
            <LabeledList.Item label={t('ui.common.general_records')}>
              <Box maxWidth="100%" preserveWhitespace>
                {past_general_records || t('ui.common.not_available_short')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.medical_records.past_medical_records')}>
              <Box maxWidth="100%" preserveWhitespace>
                {past_medical_records || t('ui.common.not_available_short')}
              </Box>
            </LabeledList.Item>
            {/* NOVA EDIT END */}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
