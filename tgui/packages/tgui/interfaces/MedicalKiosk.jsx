import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const MedicalKiosk = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [scanIndex] = useSharedState('scanIndex');
  const { active_status_1, active_status_2, active_status_3, active_status_4 } =
    data;
  return (
    <Window width={575} height={420}>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item mr={1}>
            <Section minHeight="100%">
              <MedicalKioskScanButton
                index={1}
                icon="procedures"
                name={t('ui.medical_kiosk.general_health_scan')}
                description={t(
                  'ui.medical_kiosk.general_health_scan_description',
                )}
              />
              <MedicalKioskScanButton
                index={2}
                icon="heartbeat"
                name={t('ui.medical_kiosk.symptom_based_checkup')}
                description={t(
                  'ui.medical_kiosk.symptom_based_checkup_description',
                )}
              />
              <MedicalKioskScanButton
                index={3}
                icon="radiation-alt"
                name={t('ui.medical_kiosk.neurological_radiological_scan')}
                description={t(
                  'ui.medical_kiosk.neurological_radiological_scan_description',
                )}
              />
              <MedicalKioskScanButton
                index={4}
                icon="mortar-pestle"
                name={t('ui.medical_kiosk.chemical_and_psychoactive_scan')}
                description={t(
                  'ui.medical_kiosk.chemical_and_psychoactive_scan_description',
                )}
              />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <MedicalKioskInstructions />
          </Flex.Item>
        </Flex>
        {!!active_status_1 && scanIndex === 1 && <MedicalKioskScanResults1 />}
        {!!active_status_2 && scanIndex === 2 && <MedicalKioskScanResults2 />}
        {!!active_status_3 && scanIndex === 3 && <MedicalKioskScanResults3 />}
        {!!active_status_4 && scanIndex === 4 && <MedicalKioskScanResults4 />}
      </Window.Content>
    </Window>
  );
};

const MedicalKioskScanButton = (props) => {
  const { index, name, description, icon } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [scanIndex, setScanIndex] = useSharedState('scanIndex');
  const paid = data[`active_status_${index}`];
  return (
    <Stack align="baseline">
      <Stack.Item width="16px" textAlign="center">
        <Icon
          name={paid ? 'check' : 'dollar-sign'}
          color={paid ? 'green' : 'grey'}
          tooltip={paid ? t('ui.common.paid') : t('ui.common.unpaid')}
        />
      </Stack.Item>
      <Stack.Item grow basis="content">
        <Button
          fluid
          icon={icon}
          selected={paid && scanIndex === index}
          tooltip={description}
          tooltipPosition="right"
          content={name}
          onClick={() => {
            if (!paid) {
              act(`beginScan_${index}`);
            }
            setScanIndex(index);
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

const MedicalKioskInstructions = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { kiosk_cost, patient_name } = data;
  return (
    <Section minHeight="100%">
      <Box italic>
        {t('ui.medical_kiosk.greeting_and_instruction_prefix')}{' '}
        <b>
          {kiosk_cost} {t('ui.common.credits')}
        </b>
        .
      </Box>
      <Box mt={1}>
        <Box inline color="label" mr={1}>
          {t('ui.medical_kiosk.patient')}:
        </Box>
        {patient_name}
      </Box>
      <Button
        mt={1}
        tooltip={t('ui.medical_kiosk.reset_scanner_tooltip')}
        icon="sync"
        color="average"
        onClick={() => act('clearTarget')}
        content={t('ui.medical_kiosk.reset_scanner')}
      />
    </Section>
  );
};

const MedicalKioskScanResults1 = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    patient_health,
    brute_health,
    burn_health,
    suffocation_health,
    toxin_health,
  } = data;
  return (
    <Section title={t('ui.medical_kiosk.patient_health')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.medical_kiosk.total_health')}>
          <ProgressBar value={patient_health / 100}>
            <AnimatedNumber value={patient_health} />%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label={t('ui.medical_kiosk.brute_damage')}>
          <ProgressBar value={brute_health / 100} color="bad">
            <AnimatedNumber value={brute_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.burn_damage')}>
          <ProgressBar value={burn_health / 100} color="bad">
            <AnimatedNumber value={burn_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.oxygen_damage')}>
          <ProgressBar value={suffocation_health / 100} color="bad">
            <AnimatedNumber value={suffocation_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.toxin_damage')}>
          <ProgressBar value={toxin_health / 100} color="bad">
            <AnimatedNumber value={toxin_health} />
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults2 = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    patient_status,
    patient_illness,
    illness_info,
    bleed_status,
    blood_levels,
    blood_name,
    blood_status,
  } = data;
  return (
    <Section title={t('ui.medical_kiosk.symptom_based_checkup')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.medical_kiosk.patient_status')} color="good">
          {patient_status}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label={t('ui.medical_kiosk.disease_status')}>
          {patient_illness}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.disease_information')}>
          {illness_info}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label={`${blood_name} ${t('ui.medical_kiosk.levels')}`}>
          <ProgressBar value={blood_levels / 100} color="bad">
            <AnimatedNumber value={blood_levels} />
          </ProgressBar>
          <Box mt={1} color="label">
            {bleed_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label={`${blood_name} ${t('ui.common.information')}`}>
          {blood_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults3 = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { brain_damage, brain_health, trauma_status } = data;
  return (
    <Section title={t('ui.medical_kiosk.patient_neurological_health')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.medical_kiosk.brain_damage')}>
          <ProgressBar value={brain_damage / 100} color="good">
            <AnimatedNumber value={brain_damage} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.brain_status')} color="health-0">
          {brain_health}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.brain_trauma_status')}>
          {trauma_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults4 = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    chemical_list = [],
    overdose_list = [],
    addict_list = [],
    hallucinating_status,
    blood_alcohol,
  } = data;
  return (
    <Section title={t('ui.medical_kiosk.chemical_and_psychoactive_analysis')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.medical_kiosk.chemical_contents')}>
          {chemical_list.length === 0 && (
            <Box color="average">{t('ui.medical_kiosk.no_reagents_detected')}</Box>
          )}
          {chemical_list.map((chem) => (
            <Box key={chem.id} color="good">
              {chem.volume} {t('ui.medical_kiosk.units_of')} {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.overdose_status')} color="bad">
          {overdose_list.length === 0 && (
            <Box color="good">{t('ui.medical_kiosk.patient_not_overdosing')}</Box>
          )}
          {overdose_list.map((chem) => (
            <Box key={chem.id}>
              {t('ui.medical_kiosk.overdosing_on')} {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.addiction_status')} color="bad">
          {addict_list.length === 0 && (
            <Box color="good">{t('ui.medical_kiosk.patient_no_addictions')}</Box>
          )}
          {addict_list.map((chem) => (
            <Box key={chem.id}>
              {t('ui.medical_kiosk.addicted_to')} {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.psychoactive_status')}>
          {hallucinating_status}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_kiosk.blood_alcohol_content')}>
          <ProgressBar
            value={blood_alcohol}
            minValue={0}
            maxValue={0.3}
            ranges={{
              blue: [-Infinity, 0.23],
              bad: [0.23, Infinity],
            }}
          >
            <AnimatedNumber value={blood_alcohol} />
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
