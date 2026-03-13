// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  NoticeBox,
  NumberInput,
  ProgressBar,
  RoundGauge,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const AmmoWorkbench = (props) => {
  const [tab, setTab] = useSharedState('tab', 1);
  const { t } = usePreferencesLocalization();
  return (
    <Window width={600} height={600} title={t('ui.ammo_workbench.title')}>
      <Window.Content scrollable>
        <Tabs fluid textAlign="center">
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            {t('ui.ammo_workbench.ammunition')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            {t('ui.common.materials')}
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <AmmunitionsTab />}
        {tab === 2 && <MaterialsTab />}
      </Window.Content>
    </Window>
  );
};

export const AmmunitionsTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    mag_loaded,
    system_busy,
    error,
    error_type,
    mag_name,
    turboBoost,
    current_rounds,
    max_rounds,
    efficiency,
    time,
    caliber,
    datadisk_loaded,
    datadisk_name,
    available_rounds = [],
  } = data;
  return (
    <>
      {!!error && (
        <NoticeBox textAlign="center" color={error_type}>
          {error}
        </NoticeBox>
      )}
      <Section title={t('ui.ammo_workbench.machine_settings')}>
        <Box inline mr={4}>
          {t('ui.ammo_workbench.current_efficiency')}:{' '}
          <RoundGauge
            value={efficiency}
            minValue={1.6}
            maxValue={1}
            format={() => null}
          />
        </Box>
        <Box>
          {t('ui.ammo_workbench.time_per_round')}: {time}{' '}
          {t('ui.common.seconds').toLowerCase()}
        </Box>
        <Button.Checkbox
          textAlign="right"
          checked={turboBoost}
          onClick={() => act('turboBoost')}
        >
          {t('ui.ammo_workbench.overclock')}
        </Button.Checkbox>
      </Section>
      <Section
        title={t('ui.ammo_workbench.loaded_magazine')}
        buttons={
          <>
            {!!mag_loaded && (
              <Box inline mr={2}>
                <ProgressBar
                  value={current_rounds}
                  minValue={0}
                  maxValue={max_rounds}
                />
              </Box>
            )}
            <Button
              icon="eject"
              content={t('ui.common.eject')}
              disabled={!mag_loaded}
              onClick={() => act('EjectMag')}
            />
          </>
        }
      >
        {!!mag_loaded && <Box>{mag_name}</Box>}
        {!!mag_loaded && (
          <Box bold textAlign="right">
            {current_rounds} / {max_rounds}
          </Box>
        )}
      </Section>
      <Section title={t('ui.ammo_workbench.available_ammunition_types')}>
        {!!mag_loaded && (
          <Flex.Item grow={1} basis={0}>
            {available_rounds.map((available_round) => (
              <Box
                key={available_round.name}
                className="candystripe"
                p={1}
                pb={2}
              >
                <Stack.Item>
                  <Tooltip
                    content={available_round.mats_list}
                    position={'right'}
                  >
                    <Button
                      content={available_round.name}
                      disabled={system_busy}
                      onClick={() =>
                        act('FillMagazine', {
                          selected_type: available_round.typepath,
                        })
                      }
                    />
                  </Tooltip>
                </Stack.Item>
              </Box>
            ))}
          </Flex.Item>
        )}
      </Section>
      <Section
        title={t('ui.ammo_workbench.module_management')}
        buttons={
          <Button
            icon="eject"
            content={t('ui.common.eject')}
            disabled={!datadisk_loaded}
            onClick={() => act('EjectDisk')}
          />
        }
      >
        {!!datadisk_loaded && (
          <Box>
            {t('ui.ammo_workbench.loaded_module')}: {datadisk_name}
          </Box>
        )}
        <Collapsible title={t('ui.ammo_workbench.owners_manual')}>
          <Section color="label">
            {t('ui.ammo_workbench.manual_line_1')}
            <br />
            <br />
            {t('ui.ammo_workbench.manual_line_2_prefix')} <b>{t('ui.ammo_workbench.reusable')}</b>{' '}
            {t('ui.ammo_workbench.manual_line_2_suffix')}
          </Section>
        </Collapsible>
      </Section>
    </>
  );
};

export const MaterialsTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { materials = [] } = data;
  return (
    <Section title={t('ui.common.materials')}>
      <Table>
        {materials
          .filter((material) => material.amount > 0)
          .map((material) => (
            <MaterialRow
              key={material.id}
              material={material}
              onRelease={(amount) =>
                act('Release', {
                  id: material.id,
                  sheets: amount,
                })
              }
            />
          ))}
      </Table>
    </Section>
  );
};

const MaterialRow = (props) => {
  const { material, onRelease } = props;
  const { t } = usePreferencesLocalization();

  const [amount, setAmount] = useState(1);

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row>
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {amountAvailable} {t('ui.ammo_workbench.sheets')}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          width="32px"
          step={1}
          stepPixelSize={5}
          minValue={1}
          maxValue={50}
          value={amount}
          onChange={(value) => setAmount(value)}
        />
        <Button
          disabled={amountAvailable < 1}
          content={t('ui.common.release')}
          onClick={() => onRelease(amount)}
        />
      </Table.Cell>
    </Table.Row>
  );
};
