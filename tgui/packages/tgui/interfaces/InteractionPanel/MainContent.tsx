// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import { useBackend } from '../../backend';
import type { BooleanLike } from 'tgui-core/react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { InfoSection } from './InfoSection';
import {
  InteractionsTab,
  LewdItemsTab,
  PreferenceTab,
} from './tabs';

type InteractionPreference = {
  id: string;
  name: string;
  description?: string;
  type: 'toggle' | 'choice';
  category?: string;
  value: BooleanLike | string;
  choices?: string[];
};

type Interaction = {
  erp_interaction: BooleanLike;
  use_subtler: BooleanLike;
  erp_subtle_max_length: number;
  categories: string[];
  interactions: Record<string, string[]>;
  erp_categories: string[];
  erp_interactions: Record<string, string[]>;
  translation_keys: Record<string, string>;
  description_translation_keys: Record<string, string>;
  category_translation_keys: Record<string, string>;
  erp_preferences: InteractionPreference[];
};

export const MainContent = () => {
  const [searchText, setSearchText] = useState('');
  const [activeTab, setActiveTab] = useState('interactions');
  const [showCategories, setShowCategories] = useState(true);
  const [subtleMessage, setSubtleMessage] = useState('');
  const { act, data } = useBackend<Interaction>();
  const { t } = usePreferencesLocalization(data);
  const {
    erp_interaction,
    use_subtler,
    erp_subtle_max_length = 2048,
    categories = [],
    interactions = {},
    erp_categories = [],
    erp_interactions = {},
    erp_preferences = [],
  } = data;

  const availableTabs = [
    {
      key: 'interactions',
      label: t('ui.interaction_panel.interactions_tab'),
    },
    ...(erp_interaction
      ? [
          {
            key: 'erp_panel',
            label: t('ui.interaction_panel.erp_panel_tab'),
          },
          {
            key: 'lewd_items',
            label: t('ui.interaction_panel.lewd_items_tab'),
          },
        ]
      : []),
    ...(erp_preferences.length
      ? [
          {
            key: 'erp_preferences',
            label: t('ui.interaction_panel.erp_preferences_tab'),
          },
        ]
      : []),
  ];

  const placeholder =
    activeTab === 'lewd_items'
      ? t('ui.interaction_panel.search_item_placeholder')
      : activeTab === 'interactions' || activeTab === 'erp_panel'
        ? t('ui.interaction_panel.search_interaction_placeholder')
        : t('ui.interaction_panel.search_unavailable_placeholder');

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Tabs fluid textAlign="center">
            {availableTabs.map((tab) => (
              <Tabs.Tab
                key={tab.key}
                selected={activeTab === tab.key}
                onClick={() => setActiveTab(tab.key)}
              >
                {tab.label}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Stack align="baseline" fill>
            <Stack.Item>
              <Icon name="search" />
            </Stack.Item>
            <Stack.Item grow>
              <Input
                fluid
                value={searchText}
                placeholder={placeholder}
                onChange={(value) => setSearchText(value)}
              />
            </Stack.Item>
            {(activeTab === 'interactions' || activeTab === 'erp_panel') && (
              <Stack.Item>
                <Button
                  icon={showCategories ? 'folder' : 'list'}
                  color="green"
                  tooltip={
                    showCategories
                      ? t('ui.interaction_panel.hide_categories')
                      : t('ui.interaction_panel.show_categories')
                  }
                  onClick={() => setShowCategories(!showCategories)}
                />
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item grow mb={-1.6}>
          <Section fill>
            {activeTab === 'lewd_items' ? (
              <LewdItemsTab searchText={searchText} />
            ) : activeTab === 'erp_panel' ? (
              <Stack fill vertical>
                <Stack.Item>
                  <InfoSection />
                </Stack.Item>
                <Stack.Item>
                  <Section
                    title={t('ui.interaction_panel.custom_subtle_title')}
                    buttons={(
                      <Box color="label">
                        {subtleMessage.length}/{erp_subtle_max_length}
                      </Box>
                    )}
                  >
                    <Stack vertical>
                      <Stack.Item>
                        <LabeledList>
                          <Button.Checkbox
                            checked={use_subtler}
                            onClick={() =>
                              act('toggle_subtler', {
                                use_subtler: !use_subtler,
                              })
                            }
                            tooltip={t('ui.interaction_panel.subtler_tooltip')}
                          >
                            {t('ui.interaction_panel.use_subtler')}
                          </Button.Checkbox>
                        </LabeledList>
                      </Stack.Item>
                      <Stack.Item>
                        <TextArea
                          fluid
                          height={5}
                          maxLength={erp_subtle_max_length}
                          value={subtleMessage}
                          placeholder={t('ui.interaction_panel.custom_subtle_placeholder')}
                          onChange={(value) =>
                            setSubtleMessage(
                              String(value || '').slice(0, erp_subtle_max_length),
                            )
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          fluid
                          icon="comment"
                          disabled={!subtleMessage.trim().length}
                          tooltip={t('ui.interaction_panel.custom_subtle_send_tooltip')}
                          onClick={() => {
                            act('send_subtle_message', {
                              message: subtleMessage,
                            });
                            setSubtleMessage('');
                          }}
                        >
                          {t('ui.interaction_panel.custom_subtle_send_message')}
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <InteractionsTab
                          searchText={searchText}
                          showCategories={showCategories}
                          categories={erp_categories}
                          interactions={erp_interactions}
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              </Stack>
            ) : activeTab === 'erp_preferences' ? (
              <PreferenceTab
                preferences={erp_preferences}
                searchText={searchText}
                onSetPreference={(preferenceId, value) =>
                  act('set_preference', {
                    preference_id: preferenceId,
                    value,
                  })
                }
              />
            ) : (
              <InteractionsTab
                searchText={searchText}
                showCategories={showCategories}
                categories={categories}
                interactions={interactions}
              />
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
