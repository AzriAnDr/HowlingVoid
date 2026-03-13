import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import {
  SUBJECT_CONCIOUS,
  SUBJECT_DEAD,
  SUBJECT_HARD_CRIT,
  SUBJECT_SOFT_CRIT,
  SUBJECT_TRANSFORMING,
  SUBJECT_UNCONSCIOUS,
} from './constants';

const DnaScannerButtons = (props) => {
  const { data, act } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    hasDelayedAction,
    isPulsing,
    isScannerConnected,
    isScrambleReady,
    isViableSubject,
    scannerLocked,
    scannerOpen,
    scrambleSeconds,
  } = data;
  if (!isScannerConnected) {
    return (
      <Button
        content={t('ui.dna.connect_scanner')}
        onClick={() => act('connect_scanner')}
      />
    );
  }
  return (
    <>
      {!!hasDelayedAction && (
        <Button
          content={t('ui.dna.cancel_delayed_action')}
          onClick={() => act('cancel_delay')}
        />
      )}
      {!!isViableSubject && (
        <Button
          disabled={!isScrambleReady || isPulsing}
          onClick={() => act('scramble_dna')}
        >
          Scramble DNA
          {!isScrambleReady && ` (${scrambleSeconds}s)`}
        </Button>
      )}
      <Box inline mr={1} />
      <Button
        icon={scannerLocked ? 'lock' : 'lock-open'}
        color={scannerLocked && 'bad'}
        disabled={scannerOpen}
        content={scannerLocked ? 'Locked' : 'Unlocked'}
        onClick={() => act('toggle_lock')}
      />
      <Button
        disabled={scannerLocked}
        content={scannerOpen ? 'Close' : 'Open'}
        onClick={() => act('toggle_door')}
      />
    </>
  );
};

/**
 * Displays subject status based on the value of the status prop.
 */
const SubjectStatus = (props) => {
  const { status } = props;
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  if (status === SUBJECT_CONCIOUS) {
    return (
      <Box inline color="good">
        Conscious
      </Box>
    );
  }
  if (status === SUBJECT_UNCONSCIOUS || status === SUBJECT_HARD_CRIT) {
    return (
      <Box inline color="average">
        Unconscious
      </Box>
    );
  }
  if (status === SUBJECT_SOFT_CRIT) {
    return (
      <Box inline color="average">
        Critical
      </Box>
    );
  }
  if (status === SUBJECT_DEAD) {
    return (
      <Box inline color="bad">
        Dead
      </Box>
    );
  }
  if (status === SUBJECT_TRANSFORMING) {
    return (
      <Box inline color="bad">
        Transforming
      </Box>
    );
  }
  return <Box inline>{t('ui.common.unknown')}</Box>;
};

const DnaScannerContent = (props) => {
  const { data, act } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    subjectName,
    isScannerConnected,
    isViableSubject,
    subjectHealth,
    subjectDamage,
    subjectStatus,
  } = data;
  if (!isScannerConnected) {
    return <Box color="bad">{t('ui.dna.scanner_not_connected')}</Box>;
  }
  if (!isViableSubject) {
    return <Box color="average">{t('ui.dna.no_viable_subject')}</Box>;
  }
  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.common.status')}>
        {subjectName}
        <Icon mx={1} color="label" name="long-arrow-alt-right" />
        <SubjectStatus status={subjectStatus} />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.health')}>
        <ProgressBar
          value={subjectHealth}
          minValue={0}
          maxValue={100}
          ranges={{
            olive: [101, Infinity],
            good: [70, 101],
            average: [30, 70],
            bad: [-Infinity, 30],
          }}
        >
          {subjectHealth}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.dna.genetic_damage')}>
        <ProgressBar
          value={subjectDamage}
          minValue={0}
          maxValue={100}
          ranges={{
            bad: [71, Infinity],
            average: [30, 71],
            good: [0, 30],
            olive: [-Infinity, 0],
          }}
        >
          {subjectDamage}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

export const DnaScanner = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Section title={t('ui.dna.scanner')} buttons={<DnaScannerButtons />}>
      <DnaScannerContent />
    </Section>
  );
};
