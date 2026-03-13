import { Box, Button, Icon, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type AirlockControllerData = {
  airlockState: string;
  sensorPressure: number;
  pumpStatus: string;
  interiorStatus: string;
  exteriorStatus: string;
};

type AirlockStatus = {
  primary: string;
  icon: string;
  color: string;
};

export const AirlockController = (props) => {
  const { data } = useBackend<AirlockControllerData>();
  const { t } = usePreferencesLocalization(data);
  const { airlockState, pumpStatus, interiorStatus, exteriorStatus } = data;
  const currentStatus: AirlockStatus = getAirlockStatus(airlockState, t);
  const nameToUpperCase = (str: string) =>
    str.replace(/^\w/, (c) => c.toUpperCase());

  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title={t('ui.airlock_controller.airlock_status')} buttons={<AirLockButtons />}>
          <LabeledList>
            <LabeledList.Item label={t('ui.airlock_controller.current_status')}>
              {currentStatus.primary}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_controller.chamber_pressure')}>
              <PressureIndicator currentStatus={currentStatus} />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_controller.control_pump')}>
              {nameToUpperCase(pumpStatus)}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_controller.interior_door')}>
              <Box color={interiorStatus === 'open' && 'good'}>
                {nameToUpperCase(interiorStatus)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_controller.exterior_door')}>
              <Box color={exteriorStatus === 'open' && 'good'}>
                {nameToUpperCase(exteriorStatus)}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Displays the buttons on top of the window to cycle the airlock */
const AirLockButtons = (props) => {
  const { act, data } = useBackend<AirlockControllerData>();
  const { t } = usePreferencesLocalization(data);
  const { airlockState } = data;
  switch (airlockState) {
    case 'pressurize':
    case 'depressurize':
      return (
        <Button icon="stop-circle" onClick={() => act('abort')}>
          {t('ui.airlock_controller.abort')}
        </Button>
      );
    case 'closed':
      return (
        <>
          <Button icon="lock-open" onClick={() => act('cycleInterior')}>
            {t('ui.airlock_controller.open_interior_airlock')}
          </Button>
          <Button icon="lock-open" onClick={() => act('cycleExterior')}>
            {t('ui.airlock_controller.open_exterior_airlock')}
          </Button>
        </>
      );
    case 'inopen':
      return (
        <>
          <Button icon="lock" onClick={() => act('cycleClosed')}>
            {t('ui.airlock_controller.close_interior_airlock')}
          </Button>
          <Button icon="sync" onClick={() => act('cycleExterior')}>
            {t('ui.airlock_controller.cycle_to_exterior_airlock')}
          </Button>
        </>
      );
    case 'outopen':
      return (
        <>
          <Button icon="lock" onClick={() => act('cycleClosed')}>
            {t('ui.airlock_controller.close_exterior_airlock')}
          </Button>
          <Button icon="sync" onClick={() => act('cycleInterior')}>
            {t('ui.airlock_controller.cycle_to_interior_airlock')}
          </Button>
        </>
      );
    default:
      return null;
  }
};

/** Displays the numeric pressure alongside an icon for the user */
const PressureIndicator = (props) => {
  const { data } = useBackend<AirlockControllerData>();
  const { sensorPressure } = data;
  const {
    currentStatus: { icon, color },
  } = props;
  const spin = icon === 'fan';

  return (
    <Box color={color}>
      {sensorPressure} kPa {icon && <Icon name={icon} spin={spin} />}
    </Box>
  );
};

/** Displays the current status as two text strings, depending on door state. */
const getAirlockStatus = (airlockState, t): AirlockStatus => {
  switch (airlockState) {
    case 'inopen':
      return {
        primary: t('ui.airlock_controller.interior_airlock_open'),
        icon: '',
        color: 'good',
      };
    case 'pressurize':
      return {
        primary: t('ui.airlock_controller.cycling_to_interior_airlock'),
        icon: 'fan',
        color: 'average',
      };
    case 'closed':
      return {
        primary: t('ui.airlock_controller.inactive'),
        icon: '',
        color: 'white',
      };
    case 'depressurize':
      return {
        primary: t('ui.airlock_controller.cycling_to_exterior_airlock'),
        icon: 'fan',
        color: 'average',
      };
    case 'outopen':
      return {
        primary: t('ui.airlock_controller.exterior_airlock_open'),
        icon: 'exclamation-triangle',
        color: 'bad',
      };
    default:
      return {
        primary: t('ui.airlock_controller.unknown'),
        icon: '',
        color: 'average',
      };
  }
};
