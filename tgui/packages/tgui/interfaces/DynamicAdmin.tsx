import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type RulesetCount = Record<string, number>;

type DynamicConfig = Record<string, any>;

type typePath = string;

type Player = {
  key: string;
};

type RulesetReport = RulesetType & {
  index: number;
  selected_players: Player[];
  hidden: BooleanLike;
};

type RulesetType = {
  name: string;
  id: string;
  typepath: typePath;
  admin_disabled: BooleanLike;
};

type Data = {
  current_tier?: {
    number: number;
    name: string;
  };
  ruleset_count?: RulesetCount;
  full_config?: DynamicConfig;
  queued_rulesets: RulesetReport[];
  active_rulesets: RulesetReport[];
  all_rulesets: Record<string, RulesetType[]>;
  time_until_lights: number;
  time_until_heavies: number;
  time_until_latejoins: number;
  time_until_next_midround: number;
  time_until_next_latejoin: number;
  failed_latejoins: number;
  light_midround_chance: number;
  heavy_midround_chance: number;
  latejoin_chance: number;
  roundstarted: BooleanLike;
  config_even_enabled: BooleanLike;
  light_chance_maxxed: BooleanLike;
  heavy_chance_maxxed: BooleanLike;
  latejoin_chance_maxxed: BooleanLike;
  next_dynamic_tick: number;
  antag_events_enabled: BooleanLike;
};

function formatTime(seconds: number, t: (key: string) => string): string {
  seconds /= 10;
  if (seconds < 0) {
    return t('ui.dynamic_admin.never');
  }
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.round(seconds % 60);

  return `${hours}h ${minutes}m ${secs}s`;
}

function getPlayerString(players: Player[], t: (key: string) => string): string {
  if (players.length === 0) {
    return t('ui.dynamic_admin.no_one');
  } else if (players.length === 1) {
    return players[0].key;
  } else if (players.length === 2) {
    return `${players[0].key} ${t('ui.common.and')} ${players[1].key}`;
  }
  let playerString = '';
  for (let i = 0; i < players.length; i++) {
    playerString += players[i].key;
    if (i < players.length - 1) {
      playerString += ', ';
    }
    if (i === players.length - 2) {
      playerString += `${t('ui.common.and')} `;
    }
  }
  return playerString;
}

function readableRulesesetCategory(ruleset_category: string): string {
  // Replace underlines with spaces and auto-capitalize first letter of every word
  return ruleset_category
    .replace(/_/g, ' ')
    .split(' ')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

const StatusPanel = () => {
  const { data, act } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    current_tier,
    ruleset_count,
    time_until_lights,
    time_until_heavies,
    time_until_latejoins,
    time_until_next_midround,
    time_until_next_latejoin,
    failed_latejoins,
    light_midround_chance,
    heavy_midround_chance,
    latejoin_chance,
    roundstarted,
    light_chance_maxxed,
    heavy_chance_maxxed,
    latejoin_chance_maxxed,
    next_dynamic_tick,
  } = data;

  if (!current_tier) {
    return (
      <LabeledList>
        <LabeledList.Item label={t('ui.dynamic_admin.current_tier')}>
          <Button onClick={() => act('set_tier')}>
            {t('ui.dynamic_admin.click_to_set')}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.dynamic_admin.current_tier')}>
        <Box>
          <b>{current_tier.number}</b> ({current_tier.name})
        </Box>
        {!roundstarted && (
          <Button ml={1} onClick={() => act('set_tier')}>
            (Change)
          </Button>
        )}
      </LabeledList.Item>
      {ruleset_count &&
        Object.entries(ruleset_count).map(([name, count]) => (
          <LabeledList.Item
            key={name}
            label={`${readableRulesesetCategory(name)} Ruleset Count`}
          >
            <Flex>
              <Flex.Item>{count}</Flex.Item>
              {(name !== 'roundstart' || !roundstarted) && (
                <Flex.Item ml={1}>
            <Button
                    icon="plus"
                    tooltip={t('ui.dynamic_admin.add_one_max_ruleset')}
                    tooltipPosition="right"
                    onClick={() =>
                      act('add_ruleset_category_count', {
                        ruleset_category: name,
                      })
                    }
                  />
                </Flex.Item>
              )}
              {(name !== 'roundstart' || !roundstarted) && (
                <Flex.Item ml={0.5}>
                  <Button
                    icon="times"
                    disabled={count === 0}
                    tooltip={t('ui.dynamic_admin.set_max_ruleset_zero')}
                    tooltipPosition="right"
                    onClick={() =>
                      act('set_ruleset_category_count', {
                        ruleset_category: name,
                        ruleset_count: 0,
                      })
                    }
                  />
                </Flex.Item>
              )}
            </Flex>
          </LabeledList.Item>
        ))}
      {time_until_lights > 0 ? (
        <LabeledList.Item label={t('ui.dynamic_admin.light_midround_start')}>
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_lights, t)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('light_start_now')}>
                {t('ui.dynamic_admin.start_now')}
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label={t('ui.dynamic_admin.light_midround_cooldown')}>
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_midround > 0
                    ? formatTime(time_until_next_midround, t)
                    : `${t('ui.dynamic_admin.next_dynamic_tick')} (${formatTime(next_dynamic_tick, t)})`}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_midround <= 0}
                  onClick={() => act('reset_midround_cooldown')}
                >
                  {t('ui.dynamic_admin.reset_cooldown')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.dynamic_admin.light_midround_chance')}>
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip content={t('ui.dynamic_admin.light_midround_chance_tooltip')}>
                    {light_midround_chance}%
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_light_chance')}>
                  {light_chance_maxxed
                    ? t('ui.common.reset')
                    : t('ui.dynamic_admin.set_to_100')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
      {time_until_heavies > 0 ? (
        <LabeledList.Item label={t('ui.dynamic_admin.heavy_midround_start')}>
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_heavies, t)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('heavy_start_now')}>
                {t('ui.dynamic_admin.start_now')}
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label={t('ui.dynamic_admin.heavy_midround_cooldown')}>
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_midround > 0
                    ? formatTime(time_until_next_midround, t)
                    : `${t('ui.dynamic_admin.next_dynamic_tick')} (${formatTime(next_dynamic_tick, t)})`}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_midround <= 0}
                  onClick={() => act('reset_midround_cooldown')}
                >
                  {t('ui.dynamic_admin.reset_cooldown')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.dynamic_admin.heavy_midround_chance')}>
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip content={t('ui.dynamic_admin.heavy_midround_chance_tooltip')}>
                    {heavy_midround_chance}%
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_heavy_chance')}>
                  {heavy_chance_maxxed
                    ? t('ui.common.reset')
                    : t('ui.dynamic_admin.set_to_100')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
      {time_until_latejoins > 0 ? (
        <LabeledList.Item label={t('ui.dynamic_admin.latejoin_start')}>
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_latejoins, t)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('latejoin_start_now')}>
                {t('ui.dynamic_admin.start_now')}
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label={t('ui.dynamic_admin.latejoin_cooldown')}>
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_latejoin
                    ? formatTime(time_until_next_latejoin, t)
                    : t('ui.dynamic_admin.next_latejoin')}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_latejoin <= 0}
                  onClick={() => act('reset_latejoin_cooldown')}
                >
                  {t('ui.dynamic_admin.reset_cooldown')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.dynamic_admin.latejoin_chance')}>
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip content={t('ui.dynamic_admin.latejoin_chance_tooltip')}>
                    {latejoin_chance}% ({failed_latejoins}{' '}
                    {t('ui.dynamic_admin.failed_attempts')})
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_latejoin_chance')}>
                  {latejoin_chance_maxxed
                    ? t('ui.common.reset')
                    : t('ui.dynamic_admin.set_to_100')}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
    </LabeledList>
  );
};

// This just reports the entire config
const ConfigPanel = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { full_config = {} } = data;

  const configKeys = Object.keys(full_config);
  const [shownConfig, setShownConfig] = useState(configKeys[0]);
  // Config given to us is basically just a big json object
  // Future TODO make this a whole functional config editor

  if (configKeys.length === 0) {
    return (
      <NoticeBox>
        {t('ui.dynamic_admin.no_config_loaded')}
      </NoticeBox>
    );
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <NoticeBox>
          {t('ui.dynamic_admin.config_notice')}
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Dropdown
          options={configKeys}
          selected={shownConfig}
          onSelected={(key) => setShownConfig(key)}
        />
      </Stack.Item>
      <Stack.Item height="180px">
        <Section fill scrollable>
          <LabeledList>
            {Object.entries(full_config[shownConfig]).map(
              ([config_name, config]) => (
                <LabeledList.Item key={config_name} label={config_name}>
                  <Box
                    style={{
                      wordBreak: 'break-all',
                      wordWrap: 'break-word',
                    }}
                  >
                    {JSON.stringify(config)}
                  </Box>
                </LabeledList.Item>
              ),
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// This is where you can see queued rulesets, active rulesets, and trigger new ones
const RulesetsPanel = () => {
  const { data, act } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { all_rulesets, queued_rulesets, active_rulesets, roundstarted } = data;

  const any_admin_disabled = Object.values(all_rulesets).some((ruleset_list) =>
    ruleset_list.some((ruleset) => ruleset.admin_disabled),
  );
  const all_admin_disabled = Object.values(all_rulesets).every((ruleset_list) =>
    ruleset_list.every((ruleset) => ruleset.admin_disabled),
  );

  const [searchText, setSearchText] = useState('');
  const searchFilter = createSearch(
    searchText,
    (ruleset: RulesetType) => ruleset.name,
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={t('ui.dynamic_admin.queued_rulesets')}>
          <Stack vertical>
            {queued_rulesets.length === 0 ? (
              <Stack.Item grow>
                <NoticeBox align="center">
                  {t('ui.dynamic_admin.no_rulesets_queued')}
                </NoticeBox>
              </Stack.Item>
            ) : (
              queued_rulesets.map((ruleset) => (
                <Stack.Item key={ruleset.id}>
                  <Button
                    mr={0.5}
                    icon="times"
                    tooltip={t('ui.dynamic_admin.remove_from_queue')}
                    onClick={() =>
                      act('remove_queued_ruleset', {
                        ruleset_index: ruleset.index,
                      })
                    }
                  />
                  {ruleset.name} ({ruleset.id})
                </Stack.Item>
              ))
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Section title={t('ui.dynamic_admin.active_rulesets')}>
          <Stack vertical>
            {active_rulesets.length === 0 ? (
              <Stack.Item grow>
                <NoticeBox align="center">
                  {t('ui.dynamic_admin.no_rulesets_active')}
                </NoticeBox>
              </Stack.Item>
            ) : (
              active_rulesets.map((ruleset) => (
                <Stack.Item key={ruleset.id}>
                  <Flex>
                    <Flex.Item
                      style={
                        ruleset.hidden
                          ? { textDecoration: 'line-through' }
                          : undefined
                      }
                    >
                      {ruleset.name} ({ruleset.id})
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Button.Checkbox
                        checked={ruleset.hidden}
                        icon="times"
                        tooltip={t('ui.dynamic_admin.hidden_ruleset_tooltip')}
                        onClick={() =>
                          act('hide_ruleset', {
                            ruleset_index: ruleset.index,
                          })
                        }
                      />
                    </Flex.Item>
                  </Flex>
                  <BlockQuote>
                    {t('ui.dynamic_admin.selected')}:{' '}
                    {getPlayerString(ruleset.selected_players, t)}
                  </BlockQuote>
                </Stack.Item>
              ))
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item height="330px">
        <Section
          fill
          title={t('ui.dynamic_admin.available_rulesets')}
          scrollable
          buttons={
            <>
              <Input
                placeholder={t('ui.dynamic_admin.search_for_ruleset')}
                onChange={setSearchText}
                expensive
                value={searchText}
              />
              <Button
                disabled={all_admin_disabled}
                onClick={() => act('disable_all')}
              >
                {t('ui.dynamic_admin.disable_all')}
              </Button>
              <Button
                disabled={!any_admin_disabled}
                onClick={() => act('enable_all')}
              >
                {t('ui.dynamic_admin.enable_all')}
              </Button>
            </>
          }
        >
          <Stack>
            {Object.entries(all_rulesets).map(
              ([ruleset_category, ruleset_list]) => (
                <Stack.Item key={ruleset_category} grow>
                  <Stack vertical>
                    <Stack.Item align="center">
                      <h4>{readableRulesesetCategory(ruleset_category)}</h4>
                    </Stack.Item>
                    {ruleset_list
                      .filter(searchFilter)
                      .sort((a, b) => (a.name > b.name ? 1 : -1))
                      .map((ruleset, index) => (
                        <Stack.Item key={ruleset.id}>
                          <Flex>
                            {ruleset_category === 'roundstart' ||
                            ruleset_category === 'latejoin' ? (
                              <Flex.Item>
                                <Button
                                  icon="plus"
                                  tooltip={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                      ? t('ui.dynamic_admin.round_already_started')
                                      : t('ui.dynamic_admin.add_to_queue')
                                  }
                                  tooltipPosition="right"
                                  disabled={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                  }
                                  onClick={() =>
                                    act('add_queued_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            ) : (
                              <Flex.Item>
                                <Button
                                  icon="play"
                                  tooltip={t('ui.dynamic_admin.execute_ruleset')}
                                  tooltipPosition="right"
                                  onClick={() =>
                                    act('execute_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            )}
                            {(ruleset_category !== 'roundstart' ||
                              !roundstarted) && (
                              <Flex.Item>
                                <Button.Checkbox
                                  ml={0.5}
                                  tooltipPosition="right"
                                  tooltip={t('ui.dynamic_admin.disable_ruleset_tooltip')}
                                  checked={ruleset.admin_disabled}
                                  color={
                                    ruleset.admin_disabled ? 'bad' : 'grey'
                                  }
                                  disabled={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                  }
                                  onClick={() =>
                                    act('disable_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            )}
                            <Flex.Item
                              style={{
                                borderBottom:
                                  '2px dotted rgba(255, 255, 255, 0.8)',
                              }}
                              ml={1}
                            >
                              <Tooltip content={`ID: ${ruleset.id}`}>
                                {ruleset.name}
                              </Tooltip>
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      ))}
                  </Stack>
                </Stack.Item>
              ),
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

enum TABS {
  Status = 'Status',
  Rulesets = 'Rulesets',
  Config = 'Config',
}

export const DynamicAdmin = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { config_even_enabled, antag_events_enabled } = data;

  // disable config tab if config_even_enabled is false
  const tabs_filtered = Object.keys(TABS).filter(
    (tab) => tab !== TABS.Config || config_even_enabled,
  );

  const [currentTab, setCurrentTab] = useState(tabs_filtered[0]);

  let componentShown;

  switch (currentTab) {
    case TABS.Status:
      componentShown = <StatusPanel />;
      break;
    case TABS.Config:
      componentShown = <ConfigPanel />;
      break;
    case TABS.Rulesets:
      componentShown = <RulesetsPanel />;
      break;
    default:
      componentShown = <StatusPanel />;
  }

  return (
    <Window
      title={t('ui.dynamic_admin.panel_title')}
      width={currentTab === TABS.Rulesets ? 800 : 500}
      height={currentTab === TABS.Rulesets ? 600 : 400}
    >
      <Window.Content>
        <Section
          title={t('ui.dynamic_admin.section_spacer')}
          height="100%"
          width="100%"
          buttons={
            <>
              <Button.Checkbox
                checked={antag_events_enabled}
                tooltip={t('ui.dynamic_admin.antag_events_tooltip')}
                onClick={() => act('toggle_antag_events')}
              >
                {t('ui.dynamic_admin.antag_events')}
              </Button.Checkbox>
              <Button
                tooltip={t('ui.dynamic_admin.open_vv_tooltip')}
                onClick={() => act('dynamic_vv')}
              >
                VV
              </Button>
            </>
          }
        >
          <Tabs>
            {tabs_filtered.map((tab) => (
              <Tabs.Tab
                key={tab}
                selected={currentTab === tab}
                onClick={() => setCurrentTab(tab)}
              >
                {t(`ui.dynamic_admin.tab_${tab.toLowerCase()}`)}
              </Tabs.Tab>
            ))}
          </Tabs>
          {componentShown}
        </Section>
      </Window.Content>
    </Window>
  );
};
