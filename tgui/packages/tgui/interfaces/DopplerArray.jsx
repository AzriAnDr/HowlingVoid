import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const DopplerArray = (props) => {
  return (
    <Window width={650} height={320} resizable>
      <Window.Content>
        <DopplerArrayContent />
      </Window.Content>
    </Window>
  );
};

const DopplerArrayContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { records = [], disk, storage } = data;
  const [activeRecordName, setActiveRecordName] = useSharedState(
    'activeRecordrecord',
    records[0]?.name,
  );
  const activeRecord = records.find((record) => {
    return record.name === activeRecordName;
  });
  const DopplerArrayFooter = (
    <Section title={disk ? `${disk} (${storage})` : t('ui.doppler_array.no_disk_inserted')}>
      <Button
        textAlign="center"
        fluid
        icon="eject"
        content={t('ui.common.eject_disk')}
        disabled={!disk}
        onClick={() => act('eject_disk')}
      />
    </Section>
  );
  const DopplerArrayRecords = (
    <Section>
      <Stack>
        <Stack.Item mr={2}>
          <Tabs vertical>
            {records.map((record) => (
              <Tabs.Tab
                icon="file"
                key={record.name}
                selected={record.name === activeRecordName}
                onClick={() => setActiveRecordName(record.name)}
              >
                {record.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        {activeRecord ? (
          <Stack.Item>
            <Section
              title={activeRecord.name}
              buttons={
                <>
                  <Button.Confirm
                    icon="trash"
                    content={t('ui.common.delete')}
                    color="bad"
                    onClick={() =>
                      act('delete_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  />
                  <Button
                    icon="floppy-disk"
                    content={t('ui.common.save')}
                    disabled={!disk}
                    tooltip={t('ui.doppler_array.save_record_tooltip')}
                    tooltipPosition="bottom"
                    onClick={() =>
                      act('save_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  />
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item label={t('ui.common.timestamp')}>
                  {activeRecord.timestamp}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.common.coordinates')}>
                  {activeRecord.coordinates}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.doppler_array.displacement')}>
                  {activeRecord.displacement} seconds
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.doppler_array.epicenter_radius')}>
                  {activeRecord.factual_epicenter_radius}
                  {activeRecord.theory_epicenter_radius &&
                    ' (Theoretical: ' +
                      activeRecord.theory_epicenter_radius +
                      ')'}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.doppler_array.outer_radius')}>
                  {activeRecord.factual_outer_radius}
                  {activeRecord.theory_outer_radius &&
                    ` (Theoretical: ${activeRecord.theory_outer_radius})`}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.doppler_array.shockwave_radius')}>
                  {activeRecord.factual_shockwave_radius}
                  {activeRecord.theory_shockwave_radius &&
                    ' (Theoretical: ' +
                      activeRecord.theory_shockwave_radius +
                      ')'}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.doppler_array.possible_causes')}>
                  {activeRecord.reaction_results.length
                    ? activeRecord.reaction_results.map((reaction_name) => (
                        <Box key={reaction_name}>{reaction_name}</Box>
                      ))
                    : t('ui.common.no_information_available')}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        ) : (
          <Stack.Item grow={1} basis={0}>
            <NoticeBox>{t('ui.doppler_array.no_record_selected')}</NoticeBox>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
  return (
    <Flex direction="column" height="100%">
      <Flex.Item grow>
        {!records.length ? (
          <NoticeBox>{t('ui.doppler_array.no_records')}</NoticeBox>
        ) : (
          DopplerArrayRecords
        )}
      </Flex.Item>
      <Flex.Item>{DopplerArrayFooter}</Flex.Item>
    </Flex>
  );
};
