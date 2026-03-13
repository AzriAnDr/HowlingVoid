import {
  Box,
  Button,
  Divider,
  LabeledList,
  Modal,
  Stack,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import type { SubsystemData } from './types';

type Props = {
  subsystem: SubsystemData;
  onClose: () => void;
};

export function SubsystemDialog(props: Props) {
  const { t } = usePreferencesLocalization();
  const { subsystem, onClose } = props;
  const {
    cost_ms,
    init_order,
    initialization_failure_message,
    last_fire,
    name,
    next_fire,
    overtime,
    tick_usage,
    usage_per_tick,
  } = subsystem;

  return (
    <Modal width="85%" ml={7}>
      <Stack fill>
        <Stack.Item grow fontSize="22px">
          {name}
        </Stack.Item>
        <Stack.Item>
          <Button color="bad" icon="times" onClick={onClose} />
        </Stack.Item>
      </Stack>
      <Divider />
      <Box p={1}>
        <LabeledList>
          <LabeledList.Item label={t('ui.controller_overview.init_order')}>
            {init_order}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.controller_overview.last_fire')}>
            {last_fire}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.controller_overview.next_fire')}>
            {next_fire}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.cost')}>
            {cost_ms.toFixed(2)}ms
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.controller_overview.tick_usage')}>
            {tick_usage.toFixed(2)}%
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.controller_overview.avg_usage_per_tick')}
          >
            {usage_per_tick.toFixed(2)}%
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.controller_overview.tick_overrun')}>
            {overtime.toFixed(2)}%
          </LabeledList.Item>
          {initialization_failure_message && (
            <LabeledList.Item color="bad">
              {initialization_failure_message}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Stack fill justify="space-between">
        <Stack.Item />
        <Stack.Item>
          <Button color="good" onClick={onClose} px={3} py={1}>
            {t('ui.common.close')}
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
