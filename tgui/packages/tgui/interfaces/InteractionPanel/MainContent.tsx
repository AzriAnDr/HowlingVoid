// THIS IS A NOVA SECTOR UI FILE
import { storage } from 'common/storage';
import { useEffect, useMemo, useState } from 'react';
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
  ref_self?: string;
  ref_user?: string;
  self?: string;
  user_name?: string;
  target_name?: string;
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
  const [savedDraft, setSavedDraft] = useState('');
  const [draftReady, setDraftReady] = useState(false);
  const { act, data } = useBackend<Interaction>();
  const { t } = usePreferencesLocalization(data);
  const {
    erp_interaction,
    use_subtler,
    erp_subtle_max_length = 2048,
    ref_self,
    ref_user,
    self,
    user_name,
    target_name,
    categories = [],
    interactions = {},
    erp_categories = [],
    erp_interactions = {},
    erp_preferences = [],
  } = data;

  const stableDraftTarget = target_name || self || 'unknown';
  const stableDraftUser = user_name || 'unknown';
  const subtleDraftKey = useMemo(
    () => `interaction-panel-subtle-draft:${stableDraftUser}:${stableDraftTarget}`,
    [stableDraftTarget, stableDraftUser],
  );
  const legacySubtleDraftKey = useMemo(
    () => `interaction-panel-subtle-draft:${ref_user || 'unknown'}:${ref_self || 'unknown'}`,
    [ref_self, ref_user],
  );

  const readDraftFromLocalStorage = () => {
    try {
      return window.localStorage?.getItem(subtleDraftKey) || '';
    } catch {
      return '';
    }
  };

  const writeDraftToLocalStorage = (value: string) => {
    try {
      if (value.length) {
        window.localStorage?.setItem(subtleDraftKey, value);
      } else {
        window.localStorage?.removeItem(subtleDraftKey);
      }
    } catch {
      // Ignore local storage failures and fall back to TGUI storage.
    }
  };

  const persistDraft = (value: string) => {
    const nextValue = String(value || '').slice(0, erp_subtle_max_length);
    writeDraftToLocalStorage(nextValue);
    setSavedDraft(nextValue);

    if (nextValue.length) {
      storage.set(subtleDraftKey, nextValue);
      return;
    }

    storage.remove(subtleDraftKey);
  };

  useEffect(() => {
    let cancelled = false;
    setDraftReady(false);

    const loadDraft = async () => {
      const immediateDraft = readDraftFromLocalStorage();
      const storedDraft =
        immediateDraft ||
        (await storage.get(subtleDraftKey)) ||
        (await storage.get(legacySubtleDraftKey)) ||
        '';
      if (cancelled) {
        return;
      }
      if (storedDraft && legacySubtleDraftKey !== subtleDraftKey) {
        writeDraftToLocalStorage(String(storedDraft));
        storage.set(subtleDraftKey, String(storedDraft));
        storage.remove(legacySubtleDraftKey);
      }
      setSavedDraft(String(storedDraft).slice(0, erp_subtle_max_length));
      setDraftReady(true);
    };

    loadDraft();

    return () => {
      cancelled = true;
    };
  }, [legacySubtleDraftKey, subtleDraftKey, erp_subtle_max_length]);

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
                      <Stack align="center">
                        {!!savedDraft.length && (
                          <Stack.Item>
                            <Button
                              color="transparent"
                              tooltip={t('ui.interaction_panel.custom_subtle_draft_saved')}
                          onClick={() => setSubtleMessage(savedDraft)}
                            >
                              {t('ui.interaction_panel.custom_subtle_draft_saved')}
                            </Button>
                          </Stack.Item>
                        )}
                        <Stack.Item>
                          <Box color="label">
                            {subtleMessage.length}/{erp_subtle_max_length}
                          </Box>
                        </Stack.Item>
                      </Stack>
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
                            {
                              const nextValue = String(value || '').slice(0, erp_subtle_max_length);
                              setSubtleMessage(nextValue);
                              if (draftReady) {
                                persistDraft(nextValue);
                              }
                            }}
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
                            persistDraft('');
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
