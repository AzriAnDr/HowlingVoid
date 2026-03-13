import { map } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Button,
  Flex,
  LabeledList,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ShuttleManipulator = (props) => {
  const [tab, setTab] = useState(1);
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  return (
    <Window
      title={t('ui.shuttle_manipulator.title')}
      width={800}
      height={600}
      theme="admin"
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            {t('ui.common.status')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            {t('ui.shuttle_manipulator.templates')}
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            {t('ui.shuttle_manipulator.modification')}
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <ShuttleManipulatorStatus />}
        {tab === 2 && <ShuttleManipulatorTemplates />}
        {tab === 3 && <ShuttleManipulatorModification />}
      </Window.Content>
    </Window>
  );
};

export const ShuttleManipulatorStatus = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const shuttles = data.shuttles || [];
  return (
    <Section>
      <Table>
        {shuttles.map((shuttle) => (
          <Table.Row key={shuttle.id}>
            <Table.Cell>
              <Button
                content={t('ui.shuttle_manipulator.jump_short')}
                key={shuttle.id}
                onClick={() =>
                  act('jump_to', {
                    type: 'mobile',
                    id: shuttle.id,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell>
              <Button
                content={t('ui.shuttle_manipulator.fly')}
                key={shuttle.id}
                disabled={!shuttle.can_fly}
                onClick={() =>
                  act('fly', {
                    id: shuttle.id,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell>{shuttle.name}</Table.Cell>
            <Table.Cell>{shuttle.id}</Table.Cell>
            <Table.Cell>{shuttle.status}</Table.Cell>
            <Table.Cell>
              {shuttle.mode}
              {!!shuttle.timer && (
                <>
                  ({shuttle.timeleft})
                  <Button
                    content={t('ui.shuttle_manipulator.fast_travel')}
                    key={shuttle.id}
                    disabled={!shuttle.can_fast_travel}
                    onClick={() =>
                      act('fast_travel', {
                        id: shuttle.id,
                      })
                    }
                  />
                </>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const ShuttleManipulatorTemplates = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const templateObject = data.templates || {};
  const selected = data.selected || {};
  const [selectedTemplateId, setSelectedTemplateId] = useState(
    Object.keys(templateObject)[0],
  );
  const actualTemplates = templateObject[selectedTemplateId]?.templates || [];

  return (
    <Section>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {map(templateObject, (template, templateId) => (
              <Tabs.Tab
                key={templateId}
                selected={selectedTemplateId === templateId}
                onClick={() => setSelectedTemplateId(templateId)}
              >
                {template.port_id}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          {actualTemplates.map((actualTemplate) => {
            const isSelected =
              actualTemplate.shuttle_id === selected.shuttle_id;
            // Whoever made the structure being sent is an asshole
            return (
              <Section
                title={actualTemplate.name}
                level={2}
                key={actualTemplate.shuttle_id}
                buttons={
                  <Button
                    content={
                      isSelected
                        ? t('ui.common.selected')
                        : t('ui.common.select')
                    }
                    selected={isSelected}
                    onClick={() =>
                      act('select_template', {
                        shuttle_id: actualTemplate.shuttle_id,
                      })
                    }
                  />
                }
              >
                {(!!actualTemplate.description ||
                  !!actualTemplate.admin_notes) && (
                  <LabeledList>
                    {!!actualTemplate.description && (
                      <LabeledList.Item label={t('ui.common.description')}>
                        {actualTemplate.description}
                      </LabeledList.Item>
                    )}
                    {!!actualTemplate.admin_notes && (
                      <LabeledList.Item label={t('ui.common.admin_notes')}>
                        {actualTemplate.admin_notes}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                )}
              </Section>
            );
          })}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const ShuttleManipulatorModification = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const selected = data.selected || {};
  const existingShuttle = data.existing_shuttle || {};
  return (
    <Section>
      {selected ? (
        <>
          <Section level={2} title={selected.name}>
            {(!!selected.description || !!selected.admin_notes) && (
              <LabeledList>
                {!!selected.description && (
                  <LabeledList.Item label={t('ui.common.description')}>
                    {selected.description}
                  </LabeledList.Item>
                )}
                {!!selected.admin_notes && (
                  <LabeledList.Item label={t('ui.common.admin_notes')}>
                    {selected.admin_notes}
                  </LabeledList.Item>
                )}
              </LabeledList>
            )}
          </Section>
          {existingShuttle ? (
            <Section
              level={2}
              title={`${t('ui.shuttle_manipulator.existing_shuttle')}: ${existingShuttle.name}`}
            >
              <LabeledList>
                <LabeledList.Item
                  label={t('ui.common.status')}
                  buttons={
                    <Button
                      content={t('ui.common.jump_to')}
                      onClick={() =>
                        act('jump_to', {
                          type: 'mobile',
                          id: existingShuttle.id,
                        })
                      }
                    />
                  }
                >
                  {existingShuttle.status}
                  {!!existingShuttle.timer && <>({existingShuttle.timeleft})</>}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ) : (
            <Section
              level={2}
              title={`${t('ui.shuttle_manipulator.existing_shuttle')}: ${t('ui.common.none')}`}
            />
          )}
          <Section level={2} title={t('ui.common.status')}>
            <Button
              content={t('ui.common.load')}
              color="good"
              onClick={() =>
                act('load', {
                  shuttle_id: selected.shuttle_id,
                })
              }
            />
            <Button
              content={t('ui.common.preview')}
              onClick={() =>
                act('preview', {
                  shuttle_id: selected.shuttle_id,
                })
              }
            />
            <Button
              content={t('ui.common.replace')}
              color="bad"
              onClick={() =>
                act('replace', {
                  shuttle_id: selected.shuttle_id,
                })
              }
            />
          </Section>
        </>
      ) : (
        t('ui.shuttle_manipulator.no_shuttle_selected')
      )}
    </Section>
  );
};
