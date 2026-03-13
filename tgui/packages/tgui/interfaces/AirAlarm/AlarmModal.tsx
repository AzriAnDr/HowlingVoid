import { Box, Button, Modal, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { AirAlarmData, EditingModalProps } from './types';

export function AlarmEditingModal(props: EditingModalProps) {
  const { act, data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const { id, name, type, typeName, unit, oldValue, finish, typeVar } = props;

  return (
    <Modal>
      <Section
        title={t('ui.air_alarm.threshold_value_editor')}
        buttons={<Button onClick={() => finish()} icon="times" color="red" />}
      >
        <Box mb={1.5}>
          {`${t('ui.air_alarm.editing_threshold_value_for')} ${typeName.toLowerCase()} (${name.toLowerCase()})...`}
        </Box>
        {oldValue === -1 ? (
          <Button
            onClick={() =>
              act('set_threshold', {
                threshold: id,
                threshold_type: type,
                value: 0,
              })
            }
          >
            {t('ui.common.enable')}
          </Button>
        ) : (
          <>
            <NumberInput
              onChange={(value) =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: value,
                })
              }
              unit={unit}
              value={oldValue}
              minValue={0}
              maxValue={100000}
              step={10}
            />
            <Button
              onClick={() =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: -1,
                })
              }
            >
              {t('ui.common.disable')}
            </Button>
          </>
        )}
      </Section>
    </Modal>
  );
}
