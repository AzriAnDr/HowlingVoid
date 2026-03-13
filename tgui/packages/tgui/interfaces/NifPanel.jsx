// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Dropdown,
  Flex,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NifPanel = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    linked_mob_name,
    loaded_nifsofts,
    max_nifsofts,
    max_power,
    current_theme,
  } = data;
  const [settingsOpen, setSettingsOpen] = useState(0);

  return (
    <Window
      title={t('ui.nif_panel.nanite_implant_framework')}
      width={500}
      height={400}
      resizable
      theme={current_theme}
    >
      <Window.Content>
        <Section
          title={`${t('ui.nif_panel.welcome_to_your_nif')}, ${linked_mob_name}`}
          buttons={
            <Button
              icon="cogs"
              tooltip={t('ui.nif_panel.nif_settings')}
              tooltiptooltipPosition="bottom-end"
              selected={settingsOpen}
              onClick={() => setSettingsOpen(!settingsOpen)}
            />
          }
        >
          {(settingsOpen && <NifSettings />) || <NifStats />}
          {(!settingsOpen && (
            <Section
              title={`${t('ui.nif_panel.nifsoft_programs')} (${
                max_nifsofts - loaded_nifsofts.length
              } ${t('ui.nif_panel.slots_remaining')})`}
              right
            >
              {(loaded_nifsofts.length && (
                <Flex direction="column">
                  {loaded_nifsofts.map((nifsoft) => (
                    <Flex.Item key={nifsoft.name}>
                      <Collapsible
                        title={
                          <>
                            {<Icon name={nifsoft.ui_icon} />}
                            {`${nifsoft.name}  `}
                          </>
                        }
                        buttons={
                          <Button
                            icon="play"
                            color="green"
                            onClick={() =>
                              act('activate_nifsoft', {
                                activated_nifsoft: nifsoft.reference,
                              })
                            }
                          />
                        }
                      >
                        <Table>
                          <Table.Row>
                            <Table.Cell>
                              <Button
                                icon="bolt"
                                color="yellow"
                                tooltip={t('ui.nif_panel.activation_power_tooltip')}
                              />
                              {nifsoft.activation_cost === 0
                                ? ` ${t('ui.nif_panel.no_activation_cost')}`
                                : ' ' +
                                  (nifsoft.activation_cost / max_power) * 100 +
                                  `% ${t('ui.nif_panel.per_activation')}`}
                            </Table.Cell>
                            <Table.Cell>
                              <Button
                                icon="battery-half"
                                color="orange"
                                tooltip={t('ui.nif_panel.active_drain_tooltip')}
                                disabled={nifsoft.active_cost === 0}
                              />
                              {nifsoft.active_cost === 0
                                ? ` ${t('ui.nif_panel.no_active_drain')}`
                                : ' ' +
                                  (nifsoft.active_cost / max_power) * 100 +
                                  `% ${t('ui.nif_panel.consumed_while_active')}`}
                            </Table.Cell>
                            <Table.Cell>
                              <Button
                                icon="exclamation"
                                color={nifsoft.active ? 'green' : 'red'}
                                disabled={!nifsoft.active_mode}
                                tooltip={t('ui.nif_panel.program_active_tooltip')}
                              />
                              {nifsoft.active
                                ? ` ${t('ui.nif_panel.nifsoft_active')}`
                                : ` ${t('ui.nif_panel.nifsoft_inactive')}`}
                            </Table.Cell>
                          </Table.Row>
                        </Table>
                        <br />
                        <BlockQuote preserveWhitespace>
                          {nifsoft.desc}
                        </BlockQuote>
                        {nifsoft.able_to_keep ? (
                          <box>
                            <br />
                            <Button
                              icon="floppy-disk"
                              content={
                                nifsoft.keep_installed
                                  ? t('ui.nif_panel.nifsoft_will_stay_saved')
                                  : t('ui.nif_panel.nifsoft_wont_stay_saved')
                              }
                              color={nifsoft.keep_installed ? 'green' : 'red'}
                              fluid
                              tooltip={t('ui.nif_panel.keep_saved_tooltip')}
                              onClick={() =>
                                act('toggle_keeping_nifsoft', {
                                  nifsoft_to_keep: nifsoft.reference,
                                })
                              }
                            />
                          </box>
                        ) : (
                          null
                        )}
                        <box>
                          <br />
                          <Button.Confirm
                            icon="trash"
                            content={t('ui.nif_panel.uninstall')}
                            color="red"
                            fluid
                            tooltip={t('ui.nif_panel.uninstall_tooltip')}
                            confirmContent={t('ui.common.are_you_sure')}
                            confirmIcon="question"
                            onClick={() =>
                              act('uninstall_nifsoft', {
                                nifsoft_to_remove: nifsoft.reference,
                              })
                            }
                          />
                        </box>
                      </Collapsible>
                    </Flex.Item>
                  ))}
                </Flex>
              )) || (
                <Box>
                  {' '}
                  <center>
                    <b>{t('ui.nif_panel.no_nifsofts_installed')}</b>
                  </center>{' '}
                </Box>
              )}
            </Section>
          )) || (
            <Section title={t('ui.nif_panel.product_info')}>
              <NifProductNotes />
            </Section>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const NifSettings = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    nutrition_drain,
    ui_themes,
    current_theme,
    nutrition_level,
    blood_drain,
    minimum_blood_level,
    blood_level,
    stored_points,
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.nif_panel.nif_theme')}>
        <Dropdown
          width="100%"
          selected={current_theme}
          options={ui_themes}
          onSelected={(value) => act('change_theme', { target_theme: value })}
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.nif_panel.nif_flavor_text')}>
        <Input
          onChange={(value) => act('change_examine_text', { new_text: value })}
          width="100%"
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.nif_panel.nutrition_drain')}>
        <Button
          fluid
          content={
            nutrition_drain === 0
              ? t('ui.nif_panel.nutrition_drain_disabled')
              : t('ui.nif_panel.nutrition_drain_enabled')
          }
          tooltip={t('ui.nif_panel.nutrition_drain_tooltip')}
          onClick={() => act('toggle_nutrition_drain')}
          disabled={nutrition_level < 26}
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.nif_panel.blood_drain')}>
        <Button
          fluid
          content={
            blood_drain === 0
              ? t('ui.nif_panel.blood_drain_disabled')
              : t('ui.nif_panel.blood_drain_enabled')
          }
          tooltip={t('ui.nif_panel.blood_drain_tooltip')}
          onClick={() => act('toggle_blood_drain')}
          disabled={blood_level < minimum_blood_level}
        />
      </LabeledList.Item>
      <LabeledList.Item
        label={t('ui.nif_panel.rewards_points')}
        buttons={
          <Button
            icon="info"
            tooltip={t('ui.nif_panel.rewards_points_tooltip')}
          />
        }
      >
        {stored_points}
      </LabeledList.Item>
    </LabeledList>
  );
};

const NifProductNotes = (props) => {
  const { act, data } = useBackend();
  const { product_notes } = data;
  return <BlockQuote>{product_notes}</BlockQuote>;
};

const NifStats = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    max_power,
    power_level,
    durability,
    power_usage,
    nutrition_drain,
    blood_drain,
    max_durability,
  } = data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label={t('ui.nif_panel.nif_condition')}>
          <ProgressBar
            value={durability}
            minValue={0}
            maxValue={max_durability}
            ranges={{
              good: [max_durability * 0.66, max_durability],
              average: [max_durability * 0.33, max_durability * 0.66],
              bad: [0, max_durability * 0.33],
            }}
            alertAfter={max_durability * 0.25}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.nif_panel.nif_power')}>
          <ProgressBar
            value={power_level}
            minValue={0}
            maxValue={max_power}
            ranges={{
              good: [max_power * 0.66, max_power],
              average: [max_power * 0.33, max_power * 0.66],
              bad: [0, max_power * 0.33],
            }}
            alertAfter={max_power * 0.1}
          >
            {(power_level / max_power) * 100 +
              '%' +
              ' (' +
              (power_usage / max_power) * 100 +
              `% ${t('ui.nif_panel.usage')})`}
          </ProgressBar>
        </LabeledList.Item>
        {nutrition_drain === 1 && (
          <LabeledList.Item label={t('ui.nif_panel.user_nutrition')}>
            <NifNutritionBar />
          </LabeledList.Item>
        )}
        {blood_drain === 1 && (
          <LabeledList.Item label={t('ui.nif_panel.user_blood_level')}>
            <NifBloodBar />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};

const NifNutritionBar = (props) => {
  const { act, data } = useBackend();
  const { nutrition_level } = data;
  return (
    <ProgressBar
      value={nutrition_level}
      minValue={0}
      maxValue={550}
      ranges={{
        good: [250, Infinity],
        average: [150, 250],
        bad: [0, 150],
      }}
    />
  );
};

const NifBloodBar = (props) => {
  const { act, data } = useBackend();
  const { blood_level, minimum_blood_level, max_blood_level } = data;
  return (
    <ProgressBar
      value={blood_level}
      minValue={0}
      maxValue={max_blood_level}
      ranges={{
        good: [minimum_blood_level, Infinity],
        average: [336, minimum_blood_level],
        bad: [0, 336],
      }}
    />
  );
};
