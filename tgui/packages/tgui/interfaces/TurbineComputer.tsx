import {
  Box,
  Button,
  LabeledList,
  Modal,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type TurbineInfo = {
  connected: BooleanLike;
  active: BooleanLike;
  rpm: number;
  power: number;
  temp: number;
  integrity: number;
  max_rpm: number;
  max_temperature: number;
  regulator: number;
};

const TurbineDisplay = (props) => {
  const { act, data } = useBackend<TurbineInfo>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Section
      title={t('ui.turbine_computer.status')}
      buttons={
        <Button
          icon={data.active ? 'power-off' : 'times'}
          selected={data.active}
          disabled={!!(data.rpm >= 1000)}
          onClick={() => act('toggle_power')}
        >
          {data.active
            ? t('ui.turbine_computer.online')
            : t('ui.turbine_computer.offline')}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.turbine_computer.intake_regulator')}>
          <NumberInput
            animated
            tickWhileDragging
            value={data.regulator * 100}
            unit="%"
            step={1}
            minValue={1}
            maxValue={100}
            onChange={(value) =>
              act('regulate', {
                regulate: value * 0.01,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.turbine_computer.turbine_integrity')}>
          <ProgressBar
            value={data.integrity}
            minValue={0}
            maxValue={100}
            ranges={{
              good: [60, 100],
              average: [40, 59],
              bad: [0, 39],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.turbine_computer.turbine_speed')}>
          {data.rpm} RPM
        </LabeledList.Item>
        <LabeledList.Item
          label={t('ui.turbine_computer.max_turbine_speed')}
        >
          {data.max_rpm} RPM
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.turbine_computer.input_temperature')}>
          {data.temp} K
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.turbine_computer.max_temperature')}>
          {data.max_temperature} K
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.turbine_computer.generated_power')}>
          {formatPower(data.power)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const OutOfService = (props) => {
  const { data } = useBackend<TurbineInfo>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Modal>
      <Stack fill vertical>
        <Stack.Item textAlign="center">
          <Box style={{ margin: 'auto' }} textAlign="center" width="300px">
            {t('ui.turbine_computer.out_of_service_message')}
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const TurbineComputer = (props) => {
  const { data } = useBackend<TurbineInfo>();

  return (
    <Window width={310} height={240}>
      <Window.Content>
        {data.connected ? <TurbineDisplay /> : <OutOfService />}
      </Window.Content>
    </Window>
  );
};
