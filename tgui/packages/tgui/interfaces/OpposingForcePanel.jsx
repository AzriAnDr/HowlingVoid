// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Slider,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const OpposingForcePanel = (props) => {
  const [tab, setTab] = useState(1);
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { admin_mode, creator_ckey, owner_antag, opt_in_enabled } = data;
  return (
    <Window
      title={`${t('ui.opposing_force.title_prefix')}: ${creator_ckey}`}
      width={585}
      height={840}
      theme={owner_antag ? 'syndicate' : 'admin'}
    >
      <Window.Content scrollable>
        <Stack vertical grow mb={1}>
          <Stack.Item>
            <Tabs fill>
              {admin_mode ? (
                <>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 1}
                    onClick={() => setTab(1)}
                  >
                    {t('ui.opposing_force.admin_control')}
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 2}
                    onClick={() => setTab(2)}
                  >
                    {t('ui.opposing_force.admin_chat')}
                  </Tabs.Tab>
                </>
              ) : (
                <>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 1}
                    onClick={() => setTab(1)}
                  >
                    {t('ui.opposing_force.summary')}
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 2}
                    onClick={() => setTab(2)}
                  >
                    {t('ui.opposing_force.equipment')}
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 3}
                    onClick={() => setTab(3)}
                  >
                    {t('ui.opposing_force.admin_chat')}
                  </Tabs.Tab>
                  {!!opt_in_enabled && (
                    <Tabs.Tab
                      width="100%"
                      selected={tab === 4}
                      onClick={() => setTab(4)}
                    >
                      {t('ui.opposing_force.target_list')}
                    </Tabs.Tab>
                  )}
                </>
              )}
            </Tabs>
          </Stack.Item>
        </Stack>
        {admin_mode ? (
          <>
            {tab === 1 && <AdminTab />}
            {tab === 2 && <AdminChatTab />}
          </>
        ) : (
          <>
            {tab === 1 && <OpposingForceTab />}
            {tab === 2 && <EquipmentTab />}
            {tab === 3 && <AdminChatTab />}
            {tab === 4 && <TargetTab />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

export const OpposingForceTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    creator_ckey,
    objectives = [],
    can_submit,
    status,
    can_request_update,
    request_updates_muted,
    can_edit,
    backstory,
    handling_admin,
    blocked,
    approved,
    denied,
  } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section
          title={
            handling_admin
              ? `${t('ui.opposing_force.control')} - ${t('ui.opposing_force.handling_admin')}: ${handling_admin}`
              : t('ui.opposing_force.control')
          }
        >
          <Stack>
            <Stack.Item>
              <Button
                icon="check"
                color="good"
                tooltip={
                  t('ui.opposing_force.submit_application_tooltip') +
                  (blocked ? ` (${t('ui.opposing_force.blocked')})` : '')
                }
                disabled={!can_submit || blocked}
                content={t('ui.opposing_force.submit_application')}
                onClick={() => act('submit')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="question"
                color="orange"
                tooltip={
                  t('ui.opposing_force.ask_for_update_tooltip') +
                  (request_updates_muted
                    ? ` (${t('ui.opposing_force.muted')})`
                    : '')
                }
                disabled={!can_request_update || request_updates_muted}
                content={t('ui.opposing_force.ask_for_update')}
                onClick={() => act('request_update')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="wrench"
                color="blue"
                tooltip={t('ui.opposing_force.modify_request_tooltip')}
                disabled={can_edit}
                content={t('ui.opposing_force.modify_request')}
                onClick={() => act('modify_request')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="trash"
                color="bad"
                tooltip={t('ui.opposing_force.withdraw_application_tooltip')}
                disabled={status === 'Not submitted'}
                content={t('ui.opposing_force.withdraw_application')}
                onClick={() => act('close_application')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <Button
                icon="file-import"
                color="blue"
                tooltip={t('ui.opposing_force.import_json_tooltip')}
                disabled={status === 'Awaiting approval'}
                content={t('ui.opposing_force.import_json')}
                onClick={() => act('import_json')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-export"
                color="purple"
                tooltip={t('ui.opposing_force.export_json_tooltip')}
                disabled={status === 'Awaiting approval'}
                content={t('ui.opposing_force.export_json')}
                onClick={() => act('export_json')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <a href="https://docs.google.com/document/u/0/d/e/2PACX-1vRVI8-SmicLDV7ny_8BwJ3s8nIYBPU-nhrFDNA95VQxfpmGeUWEuqsnHr1_YDBoEUYRSITEoUbnWlru/pub?pli=1">
                <Button
                  icon="info"
                  color="orange"
                  tooltip={t('ui.opposing_force.opfor_guide_tooltip')}
                  content={t('ui.opposing_force.opfor_guide')}
                />
              </a>
            </Stack.Item>
            <Stack.Item>
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Opfor_Related_Stuff:">
                <Button
                  icon="wrench"
                  color="red"
                  tooltip={t('ui.opposing_force.opfor_policy_tooltip')}
                  content={t('ui.opposing_force.opfor_policy')}
                />
              </a>
            </Stack.Item>
            <Stack.Item>
              <a href="https://wiki.novasector13.com/index.php/Server_Rules#Rule_10:_No_Self-Antagging">
                <Button
                  icon="question"
                  color="yellow"
                  tooltip={t('ui.opposing_force.needs_opfor_tooltip')}
                  content={t('ui.opposing_force.needs_opfor')}
                />
              </a>
            </Stack.Item>
          </Stack>
          <NoticeBox
            color={approved ? 'good' : denied ? 'bad' : 'orange'}
            mt={2}
          >
            {status}
          </NoticeBox>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t('ui.opposing_force.backstory')}>
          <TextArea
            expensive
            disabled={!can_edit}
            height="100px"
            fluid
            value={backstory}
            placeholder={t('ui.opposing_force.backstory_placeholder')}
            onChange={(value) =>
              act('set_backstory', {
                backstory: value,
              })
            }
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={t('ui.opposing_force.objectives')}
          buttons={
            <Button
              icon="plus"
              content={t('ui.opposing_force.add_objective')}
              onClick={() => act('add_objective')}
            />
          }
        >
          {!!objectives.length && <OpposingForceObjectives />}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const OpposingForceObjectives = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { objectives = [], can_edit } = data;

  const [selectedObjectiveID, setSelectedObjective] = useState(
    objectives[0]?.id,
  );

  const selectedObjective = objectives.find((objective) => {
    return objective.id === selectedObjectiveID;
  });

  return (
    <Stack vertical grow>
      {objectives.length > 0 && (
        <Stack.Item>
          <Tabs fill>
            {objectives.map((objective) => (
              <Tabs.Tab
                color={
                  objective.status_text === 'Not Reviewed'
                    ? 'yellow'
                    : objective.approved
                      ? 'good'
                      : 'bad'
                }
                textColor={
                  objective.status_text === 'Not Reviewed'
                    ? 'yellow'
                    : objective.approved
                      ? 'good'
                      : 'bad'
                }
                width="25%"
                key={objective.id}
                selected={objective.id === selectedObjectiveID}
                onClick={() => setSelectedObjective(objective.id)}
              >
                <Stack align="center">
                  <Stack.Item width="80%">
                    {objective.title
                      ? objective.title
                      : t('ui.opposing_force.blank_objective')}
                  </Stack.Item>
                  <Stack.Item width="20%">
                    <Button
                      disabled={!can_edit}
                      height="90%"
                      icon="minus"
                      color="bad"
                      textAlign="center"
                      tooltip={t('ui.opposing_force.remove_objective')}
                      onClick={() =>
                        act('remove_objective', {
                          objective_ref: objective.ref,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      {selectedObjective ? (
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>{t('ui.common.title')}</Stack.Item>
                  <Stack.Item>
                    <Input
                      disabled={!can_edit}
                      fluid
                      placeholder={t('ui.opposing_force.blank_objective_placeholder')}
                      value={selectedObjective.title}
                      onChange={(value) =>
                        act('set_objective_title', {
                          objective_ref: selectedObjective.ref,
                          title: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    {t('ui.opposing_force.intensity')}: {selectedObjective.text_intensity}
                  </Stack.Item>
                  <Stack.Item>
                    <Slider
                      disabled={!can_edit}
                      step={0.1}
                      stepPixelSize={0.1}
                      value={selectedObjective.intensity}
                      format={(value) => round(value)}
                      minValue={0}
                      maxValue={500}
                      onChange={(e, value) =>
                        act('set_objective_intensity', {
                          objective_ref: selectedObjective.ref,
                          new_intensity_level: value,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item>
                        <Button
                          ml={7.6}
                          mr={15}
                          disabled={!can_edit}
                          icon="laugh"
                          color="good"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 50,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="smile"
                          color="teal"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 150,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="meh-blank"
                          color="olive"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 250,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="frown"
                          color="orange"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 350,
                            })
                          }
                        />
                        <Button
                          disabled={!can_edit}
                          icon="grimace"
                          color="red"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 450,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    {t('ui.common.description')}
                    <Button
                      icon="info"
                      tooltip={t('ui.opposing_force.objective_description_tooltip')}
                      color="light-gray"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <TextArea
                      expensive
                      fluid
                      disabled={!can_edit}
                      height="85px"
                      value={selectedObjective.description}
                      onChange={(value) =>
                        act('set_objective_description', {
                          objective_ref: selectedObjective.ref,
                          new_desciprtion: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    {t('ui.opposing_force.justification')}
                    <Button
                      icon="info"
                      tooltip={t('ui.opposing_force.justification_tooltip')}
                      color="light-gray"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <TextArea
                      expensive
                      disabled={!can_edit}
                      height="85px"
                      fluid
                      value={selectedObjective.justification}
                      onChange={(value) =>
                        act('set_objective_justification', {
                          objective_ref: selectedObjective.ref,
                          new_justification: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item mt={2}>
                <NoticeBox color={selectedObjective.approved ? 'good' : 'bad'}>
                  {selectedObjective.status_text === 'Not Reviewed'
                    ? t('ui.opposing_force.objective_not_reviewed')
                    : selectedObjective.approved
                      ? t('ui.opposing_force.objective_approved')
                      : selectedObjective.denied_text
                        ? `${t('ui.opposing_force.objective_denied_reason')}: ` +
                          selectedObjective.denied_text
                        : t('ui.opposing_force.objective_denied')}
                </NoticeBox>
              </Stack.Item>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ) : (
        <Stack.Item>{t('ui.opposing_force.no_objectives_selected')}</Stack.Item>
      )}
    </Stack>
  );
};

export const EquipmentTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { equipment_list = [], selected_equipment = [], can_edit } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section title={t('ui.opposing_force.selected_equipment')}>
          {selected_equipment.length === 0 ? (
            <Box color="bad">{t('ui.opposing_force.no_equipment_selected')}</Box>
          ) : (
            selected_equipment.map((equipment) => (
              <>
                <LabeledList key={equipment.ref}>
                  <LabeledList.Item
                    buttons={
                      <>
                        <NumberInput
                          value={equipment.count}
                          step={1}
                          minValue={1}
                          maxValue={5}
                          onChange={(value) =>
                            act('set_equipment_count', {
                              selected_equipment_ref: equipment.ref,
                              new_equipment_count: value,
                            })
                          }
                        />
                        <Button
                          icon="times"
                          color="bad"
                          content={t('ui.common.remove')}
                          onClick={() =>
                            act('remove_equipment', {
                              selected_equipment_ref: equipment.ref,
                            })
                          }
                        />
                      </>
                    }
                    label={equipment.name}
                  />
                  <LabeledList.Item label={t('ui.common.status')}>
                    {equipment.denied_reason
                      ? equipment.status +
                        ` - ${t('ui.common.reason')}: ` +
                        equipment.denied_reason
                      : equipment.status}
                  </LabeledList.Item>
                </LabeledList>
                <Input
                  mt={1}
                  mb={1}
                  disabled={!can_edit}
                  width="100%"
                  placeholder={t('ui.opposing_force.reason_for_item')}
                  value={equipment.reason}
                  onChange={(value) =>
                    act('set_equipment_reason', {
                      selected_equipment_ref: equipment.ref,
                      new_equipment_reason: value,
                    })
                  }
                />
              </>
            ))
          )}
        </Section>
        <Section title={t('ui.opposing_force.available_equipment')}>
          <Stack vertical fill>
            {equipment_list.map((equipment_category) => (
              <Stack.Item key={equipment_category.category}>
                <Collapsible
                  title={equipment_category.category}
                  key={equipment_category.category}
                >
                  <Section>
                    {equipment_category.items.map((item) => (
                      <Section
                        title={item.name}
                        key={item.ref}
                        buttons={
                          <Button
                            icon="check"
                            color="good"
                            content={t('ui.common.select')}
                            disabled={!can_edit}
                            onClick={() =>
                              act('select_equipment', {
                                equipment_ref: item.ref,
                              })
                            }
                          />
                        }
                      >
                        <LabeledList>
                          <LabeledList.Item label={t('ui.common.description')}>
                            {item.description}
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    ))}
                  </Section>
                </Collapsible>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const AdminChatTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { messages = [] } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow={10}>
        <Section scrollable fill>
          {messages.map((message) => (
            <Box key={message.msg}>{message.msg}</Box>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Input
          height="22px"
          fluid
          selfClear
          placeholder={t('ui.opposing_force.send_message_or_command')}
          mt={1}
          onEnter={(value) =>
            act('send_message', {
              message: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

export const AdminTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    request_updates_muted,
    approved,
    denied,
    objectives = [],
    selected_equipment = [],
    backstory,
    blocked,
    equipment_issued,
    owner_mob,
    owner_role,
    raw_status,
  } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section title={t('ui.opposing_force.user_information')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.name')}>{owner_mob}</LabeledList.Item>
            <LabeledList.Item label={t('ui.common.role')}>{owner_role}</LabeledList.Item>
            <LabeledList.Item label={t('ui.opposing_force.application_status')}>
              {raw_status}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.opposing_force.admin_control')}>
          <Stack mb={1}>
            <Stack.Item>
              <Button
                icon="check"
                color="good"
                tooltip={t('ui.opposing_force.approve_tooltip')}
                disabled={approved}
                content={t('ui.common.approve')}
                onClick={() => act('approve')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="check-double"
                color="orange"
                tooltip={t('ui.opposing_force.approve_all_tooltip')}
                disabled={approved}
                content={t('ui.common.approve_all')}
                onClick={() => act('approve_all')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="universal-access"
                color="purple"
                disabled={!approved || equipment_issued}
                tooltip={t('ui.opposing_force.issue_gear_tooltip')}
                content={t('ui.opposing_force.issue_gear')}
                onClick={() => act('issue_gear')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                color="red"
                disabled={denied}
                content={t('ui.common.deny')}
                onClick={() => act('deny')}
              />
            </Stack.Item>
            <Stack.Item>
              {blocked ? (
                <Button
                  icon="check-circle"
                  color="green"
                  tooltip={t('ui.opposing_force.unblock_user_tooltip')}
                  content={t('ui.opposing_force.unblock_user')}
                  onClick={() => act('toggle_block')}
                />
              ) : (
                <Button
                  icon="ban"
                  color="red"
                  tooltip={t('ui.opposing_force.block_user_tooltip')}
                  content={t('ui.opposing_force.block_user')}
                  onClick={() => act('toggle_block')}
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="suitcase"
                color="blue"
                tooltip={t('ui.opposing_force.handle_tooltip')}
                content={t('ui.opposing_force.handle')}
                onClick={() => act('handle')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              {request_updates_muted ? (
                <Button
                  icon="volume-up"
                  color="green"
                  content={t('ui.opposing_force.unmute_help_requests')}
                  onClick={() => act('mute_request_updates')}
                />
              ) : (
                <Button
                  icon="volume-mute"
                  color="red"
                  content={t('ui.opposing_force.mute_help_requests')}
                  onClick={() => act('mute_request_updates')}
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="compress-arrows-alt"
                color="teal"
                tooltip={t('ui.opposing_force.follow_user_tooltip')}
                content={t('ui.common.follow')}
                onClick={() => act('flw_user')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t('ui.opposing_force.backstory')}>
          {backstory.length === 0 ? (
            <Box color="bad">{t('ui.opposing_force.no_backstory_set')}</Box>
          ) : (
            <Box preserveWhitespace>{backstory}</Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t('ui.opposing_force.objectives')}>
          {objectives.length === 0 ? (
            <Box color="bad">{t('ui.opposing_force.no_objectives_selected')}</Box>
          ) : (
            objectives.map((objective, index) => (
              <Section
                title={`${index + 1}. ${objective.title}`}
                key={objective.id}
              >
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList key={objective.id}>
                      <LabeledList.Item label={t('ui.common.description')}>
                        {objective.description}
                      </LabeledList.Item>
                      <LabeledList.Item label={t('ui.opposing_force.justification')}>
                        {objective.justification}
                      </LabeledList.Item>
                      <LabeledList.Item label={t('ui.opposing_force.intensity')}>
                        {'(' +
                          objective.intensity +
                          ') ' +
                          objective.text_intensity}
                      </LabeledList.Item>
                      <LabeledList.Item label={t('ui.common.status')}>
                        {objective.status_text === 'Not Reviewed'
                          ? t('ui.opposing_force.objective_not_reviewed')
                          : objective.approved
                            ? t('ui.opposing_force.objective_approved')
                            : objective.denied_text
                              ? `${t('ui.opposing_force.objective_denied_reason')}: ` +
                                objective.denied_text
                              : t('ui.opposing_force.objective_denied')}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack mb={-1.5}>
                    <Stack.Divider hidden grow width="50%" />
                    <Stack.Item>
                      <Button
                        icon="check"
                        color="good"
                        disabled={
                          objective.approved &&
                          objective.status_text !== 'Not Reviewed'
                        }
                        content={t('ui.opposing_force.approve_objective')}
                        onClick={() =>
                          act('approve_objective', {
                            objective_ref: objective.ref,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        color="bad"
                        disabled={
                          !objective.approved &&
                          objective.status_text !== 'Not Reviewed'
                        }
                        content={t('ui.opposing_force.deny_objective')}
                        onClick={() =>
                          act('deny_objective', {
                            objective_ref: objective.ref,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack>
              </Section>
            ))
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t('ui.opposing_force.equipment')}>
          {selected_equipment.length === 0 ? (
            <Box color="bad">{t('ui.opposing_force.no_equipment_selected')}</Box>
          ) : (
            selected_equipment.map((equipment, index) => (
              <Section
                title={equipment.name}
                key={equipment.ref}
                buttons={
                  <>
                    <Button
                      icon="check"
                      color="good"
                      disabled={
                        equipment.approved &&
                        equipment.status !== 'Not Reviewed'
                      }
                      content={t('ui.opposing_force.approve_equipment')}
                      onClick={() =>
                        act('approve_equipment', {
                          selected_equipment_ref: equipment.ref,
                        })
                      }
                    />
                    <Button
                      icon="times"
                      color="bad"
                      disabled={
                        !equipment.approved &&
                        equipment.status !== 'Not Reviewed'
                      }
                      content={t('ui.opposing_force.deny_equipment')}
                      onClick={() =>
                        act('deny_equipment', {
                          selected_equipment_ref: equipment.ref,
                        })
                      }
                    />
                  </>
                }
              >
                <LabeledList key={equipment.ref}>
                  <LabeledList.Item label={t('ui.common.description')}>
                    {equipment.description}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.common.reason')}>
                    {equipment.reason}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.common.status')}>
                    {equipment.denied_reason
                      ? equipment.status +
                        ` - ${t('ui.common.reason')}: ` +
                        equipment.denied_reason
                      : equipment.status}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.common.amount')}>
                    {equipment.count}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.opposing_force.equipment_note')}>
                    {equipment.admin_note}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const TargetTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { current_crew = [], opt_in_colors = { optin, color } } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow={10}>
        <Section title={t('ui.opposing_force.currently_active_crew')}>
          {current_crew.map((crew) => (
            <Stack vertical={false} key={crew.name} pb="10px">
              <Stack.Item>
                <span style={{ textDecoration: 'underline' }}>{crew.name}</span>
                {': '}
                {crew.rank}, {t('ui.opposing_force.current_opt_in_status')}:{' '}
                <span
                  style={{
                    fontWeight: 'bold',
                    color: opt_in_colors[crew.opt_in_status],
                  }}
                >
                  {crew.opt_in_status}
                </span>
                , {t('ui.opposing_force.ideal_opt_in_status')}:{' '}
                <span
                  style={{ color: opt_in_colors[crew.ideal_opt_in_status] }}
                >
                  {crew.ideal_opt_in_status}
                </span>
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
