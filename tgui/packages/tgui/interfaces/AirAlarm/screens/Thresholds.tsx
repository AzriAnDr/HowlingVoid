import { useBackend } from 'tgui/backend';
import { Button, Table } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import type { AirAlarmData } from '../types';
import { useAlarmModal } from '../useModal';

export function AirAlarmControlThresholds(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { t } = usePreferencesLocalization(data);
  const [activeModal, setActiveModal] = useAlarmModal();
  const { tlvSettings, thresholdTypeMap } = data;

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold>{t('ui.air_alarm.threshold')}</Table.Cell>
        <Table.Cell bold color="bad">
          {t('ui.air_alarm.danger_below')}
        </Table.Cell>
        <Table.Cell bold color="average">
          {t('ui.air_alarm.warning_below')}
        </Table.Cell>
        <Table.Cell bold color="average">
          {t('ui.air_alarm.warning_above')}
        </Table.Cell>
        <Table.Cell bold color="bad">
          {t('ui.air_alarm.danger_above')}
        </Table.Cell>
        <Table.Cell bold>{t('ui.common.actions')}</Table.Cell>
      </Table.Row>
      {tlvSettings.map((tlv) => (
        <Table.Row key={tlv.name} className="candystripe">
          <Table.Cell>{tlv.name}</Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setActiveModal({
                  id: tlv.id,
                  name: tlv.name,
                  type: thresholdTypeMap.hazard_min,
                  typeVar: 'hazard_min',
                  typeName: t('ui.air_alarm.minimum_hazard'),
                  unit: tlv.unit,
                  finish: () => setActiveModal(undefined),
                })
              }
            >
              {tlv.hazard_min === -1
                ? t('ui.common.disabled')
                : `${tlv.hazard_min} ${tlv.unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setActiveModal({
                  id: tlv.id,
                  name: tlv.name,
                  type: thresholdTypeMap.warning_min,
                  typeVar: 'warning_min',
                  typeName: t('ui.air_alarm.minimum_warning'),
                  unit: tlv.unit,
                  finish: () => setActiveModal(undefined),
                })
              }
            >
              {tlv.warning_min === -1
                ? t('ui.common.disabled')
                : `${tlv.warning_min} ${tlv.unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setActiveModal({
                  id: tlv.id,
                  name: tlv.name,
                  type: thresholdTypeMap.warning_max,
                  typeVar: 'warning_max',
                  typeName: t('ui.air_alarm.maximum_warning'),
                  unit: tlv.unit,
                  finish: () => setActiveModal(undefined),
                })
              }
            >
              {tlv.warning_max === -1
                ? t('ui.common.disabled')
                : `${tlv.warning_max} ${tlv.unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setActiveModal({
                  id: tlv.id,
                  name: tlv.name,
                  type: thresholdTypeMap.hazard_max,
                  typeVar: 'hazard_max',
                  typeName: t('ui.air_alarm.maximum_hazard'),
                  unit: tlv.unit,
                  finish: () => setActiveModal(undefined),
                })
              }
            >
              {tlv.hazard_max === -1
                ? t('ui.common.disabled')
                : `${tlv.hazard_max} ${tlv.unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              color="green"
              icon="sync"
              onClick={() =>
                act('reset_threshold', {
                  threshold: tlv.id,
                  threshold_type: thresholdTypeMap.all,
                })
              }
            />
            <Button
              color="red"
              icon="times"
              onClick={() =>
                act('set_threshold', {
                  threshold: tlv.id,
                  threshold_type: thresholdTypeMap.all,
                  value: -1,
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}
