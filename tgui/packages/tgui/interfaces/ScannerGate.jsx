import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

const DISEASE_THEASHOLD_LIST = [
  'Positive',
  'Harmless',
  'Minor',
  'Medium',
  'Harmful',
  'Dangerous',
  'BIOHAZARD',
];

const DISEASE_THRESHOLD_LABEL_KEYS = {
  Positive: 'ui.scanner_gate.threshold_positive',
  Harmless: 'ui.scanner_gate.threshold_harmless',
  Minor: 'ui.scanner_gate.threshold_minor',
  Medium: 'ui.scanner_gate.threshold_medium',
  Harmful: 'ui.scanner_gate.threshold_harmful',
  Dangerous: 'ui.scanner_gate.threshold_dangerous',
  BIOHAZARD: 'ui.scanner_gate.threshold_biohazard',
};
// NOVA EDIT ADDITION START
const TARGET_GENDER_LIST = [
  {
    name: 'Male',
    labelKey: 'ui.scanner_gate.gender_male',
    value: 'male',
  },
  {
    name: 'Female',
    labelKey: 'ui.scanner_gate.gender_female',
    value: 'female',
  },
];
// NOVA EDIT ADDITION END

const TARGET_NUTRITION_LIST = [
  {
    name: 'Starving',
    labelKey: 'ui.scanner_gate.nutrition_starving',
    value: 150,
  },
  {
    name: 'Obese',
    labelKey: 'ui.scanner_gate.nutrition_obese',
    value: 600,
  },
];

export const ScannerGate = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    <Window width={400} height={300}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox
          onLockedStatusChange={() => act('toggle_lock')}
        />
        {!data.locked && <ScannerGateControl t={t} />}
      </Window.Content>
    </Window>
  );
};

const SCANNER_GATE_ROUTES = {
  Off: {
    title: 'ui.scanner_gate.scanner_mode_off',
    component: () => ScannerGateOff,
  },
  Wanted: {
    title: 'ui.scanner_gate.scanner_mode_wanted',
    component: () => ScannerGateWanted,
  },
  Guns: {
    title: 'ui.scanner_gate.scanner_mode_guns',
    component: () => ScannerGateGuns,
  },
  Mindshield: {
    title: 'ui.scanner_gate.scanner_mode_mindshield',
    component: () => ScannerGateMindshield,
  },
  Disease: {
    title: 'ui.scanner_gate.scanner_mode_disease',
    component: () => ScannerGateDisease,
  },
  Species: {
    title: 'ui.scanner_gate.scanner_mode_species',
    component: () => ScannerGateSpecies,
  },
  Nutrition: {
    title: 'ui.scanner_gate.scanner_mode_nutrition',
    component: () => ScannerGateNutrition,
  },
  //  NOVA EDIT START - MORE SCANNER GATE OPTIONS
  Gender: {
    title: 'ui.scanner_gate.scanner_mode_gender',
    component: () => ScannerGateGender,
  },
  //  NOVA EDIT END - MORE SCANNER GATE OPTIONS
};

const ScannerGateControl = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { scan_mode } = data;
  const route = SCANNER_GATE_ROUTES[scan_mode] || SCANNER_GATE_ROUTES.off;
  const Component = route.component();
  return (
    <Section
      title={t(route.title)}
      buttons={
        scan_mode !== 'Off' && (
          <Button
            icon="arrow-left"
            content={t('ui.common.back')}
            onClick={() => act('set_mode', { new_mode: 'Off' })}
          />
        )
      }
    >
      <Component t={t} />
    </Section>
  );
};

const ScannerGateOff = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  return (
    <>
      <Box mb={2}>{t('ui.scanner_gate.select_scanning_mode_below')}</Box>
      <Box>
        <Button
          content={t('ui.scanner_gate.mode_wanted')}
          onClick={() => act('set_mode', { new_mode: 'Wanted' })}
        />
        <Button
          content={t('ui.scanner_gate.mode_guns')}
          onClick={() => act('set_mode', { new_mode: 'Guns' })}
        />
        <Button
          content={t('ui.scanner_gate.mode_mindshield')}
          onClick={() => act('set_mode', { new_mode: 'Mindshield' })}
        />
        <Button
          content={t('ui.scanner_gate.mode_disease')}
          onClick={() => act('set_mode', { new_mode: 'Disease' })}
        />
        <Button
          content={t('ui.scanner_gate.mode_species')}
          onClick={() => act('set_mode', { new_mode: 'Species' })}
        />
        <Button //  NOVA EDIT START - MORE SCANNER GATE OPTIONS
          content={t('ui.scanner_gate.mode_gender')}
          onClick={() => act('set_mode', { new_mode: 'Gender' })} //  NOVA EDIT END - MORE SCANNER GATE OPTIONS
        />
        <Button
          content={t('ui.scanner_gate.mode_nutrition')}
          onClick={() => act('set_mode', { new_mode: 'Nutrition' })}
        />
      </Box>
    </>
  );
};

const ScannerGateWanted = (props) => {
  const { data } = useBackend();
  const { t } = props;
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person')}{' '}
        {reverse
          ? t('ui.scanner_gate.does_not_have')
          : t('ui.scanner_gate.has')}{' '}
        {t('ui.scanner_gate.any_warrants_for_arrest')}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

const ScannerGateGuns = (props) => {
  const { data } = useBackend();
  const { t } = props;
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person')}{' '}
        {reverse
          ? t('ui.scanner_gate.does_not_have')
          : t('ui.scanner_gate.has')}{' '}
        {t('ui.scanner_gate.any_guns')}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

const ScannerGateMindshield = (props) => {
  const { data } = useBackend();
  const { t } = props;
  const { reverse } = data;
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person')}{' '}
        {reverse
          ? t('ui.scanner_gate.does_not_have')
          : t('ui.scanner_gate.has')}{' '}
        {t('ui.scanner_gate.a_mindshield')}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

const ScannerGateDisease = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { reverse, disease_threshold } = data;
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person')}{' '}
        {reverse
          ? t('ui.scanner_gate.does_not_have')
          : t('ui.scanner_gate.has')}{' '}
        {t('ui.scanner_gate.a_disease_equal_or_worse_than')} {disease_threshold}.
      </Box>
      <Box mb={2}>
        {DISEASE_THEASHOLD_LIST.map((threshold) => (
          <Button.Checkbox
            key={threshold}
            checked={threshold === disease_threshold}
            content={t(DISEASE_THRESHOLD_LABEL_KEYS[threshold])}
            onClick={() =>
              act('set_disease_threshold', {
                new_threshold: threshold,
              })
            }
          />
        ))}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

const ScannerGateSpecies = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { reverse, target_species_id, available_species, target_zombie } = data;
  const species = available_species.find((species) => {
    return species.specie_id === target_species_id;
  });
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person_is')} {reverse ? t('ui.common.not') : ''} {t('ui.scanner_gate.of_the')}{' '}
        {species.specie_name} species.
        {target_zombie
          ? ` ${t('ui.scanner_gate.all_zombie_types_detected')}`
          : null}
      </Box>
      <Box mb={2}>
        {available_species.map((species) => (
          <Button.Checkbox
            key={species.specie_id}
            checked={species.specie_id === target_species_id}
            onClick={() =>
              act('set_target_species', {
                new_species_id: species.specie_id,
              })
            }
          >
            {species.specie_name}
          </Button.Checkbox>
        ))}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

const ScannerGateNutrition = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { reverse, target_nutrition } = data;
  const nutrition = TARGET_NUTRITION_LIST.find((nutrition) => {
    return nutrition.value === target_nutrition;
  });
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person')}{' '}
        {reverse
          ? t('ui.scanner_gate.does_not_have')
          : t('ui.scanner_gate.has')}{' '}
        {t('ui.scanner_gate.the')}{' '}
        {t(nutrition.labelKey)} {t('ui.scanner_gate.nutrition_level')}.
      </Box>
      <Box mb={2}>
        {TARGET_NUTRITION_LIST.map((nutrition) => (
          <Button.Checkbox
            key={nutrition.name}
            checked={nutrition.value === target_nutrition}
            content={t(nutrition.labelKey)}
            onClick={() =>
              act('set_target_nutrition', {
                new_nutrition: nutrition.name,
              })
            }
          />
        ))}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};

//  NOVA EDIT START - MORE SCANNER GATE OPTIONS
const ScannerGateGender = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { reverse, target_gender } = data;
  const gender = TARGET_GENDER_LIST.find((gender) => {
    return gender.value === target_gender;
  });
  return (
    <>
      <Box mb={2}>
        {t('ui.scanner_gate.trigger_if_scanned_person_is')}{' '}
        {reverse ? t('ui.common.not') : ''} {t('ui.scanner_gate.a')}{' '}
        {t(gender.labelKey)}.
      </Box>
      <Box mb={2}>
        {TARGET_GENDER_LIST.map((gender) => (
          <Button.Checkbox
            key={gender.name}
            checked={gender.value === target_gender}
            content={t(gender.labelKey)}
            onClick={() =>
              act('set_target_gender', {
                new_gender: gender.name,
              })
            }
          />
        ))}
      </Box>
      <ScannerGateMode t={t} />
    </>
  );
};
//  NOVA EDIT END - MORE SCANNER GATE OPTIONS
const ScannerGateMode = (props) => {
  const { act, data } = useBackend();
  const { t } = props;
  const { reverse } = data;
  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.scanner_gate.scanning_mode')}>
        <Button
          content={
            reverse ? t('ui.scanner_gate.inverted') : t('ui.scanner_gate.default')
          }
          icon={reverse ? 'random' : 'long-arrow-alt-right'}
          onClick={() => act('toggle_reverse')}
          color={reverse ? 'bad' : 'good'}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
