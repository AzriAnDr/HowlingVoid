import { Fragment, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { CharacterPreview } from 'tgui/interfaces/common/CharacterPreview';
import { removeAllSkiplines } from 'tgui/interfaces/TextInputModal'; // NOVA EDIT ADDITION: Multiple loadout presets
import {
  Box,
  Button,
  Dimmer, // NOVA EDIT ADDITION: Multiple loadout presets
  Divider,
  Dropdown,
  // NOVA EDIT ADDITION: Multiple loadout presets
  Flex,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../../types'; // NOVA EDIT ADDITION: Multiple loadout presets
import { useServerPrefs } from '../../useServerPrefs';
import { usePreferencesLocalization } from '../localization';
import type {
  LoadoutCategory,
  LoadoutItem,
  LoadoutManagerData,
  typePath,
} from './base';
import { ItemIcon, LoadoutTabDisplay, SearchDisplay } from './ItemDisplay';
import { LoadoutModifyDimmer } from './ModifyPanel';

export function LoadoutPage() {
  const serverData = useServerPrefs();
  const loadout_tabs = (serverData?.loadout.loadout_tabs || []).filter(
    (tab) => tab.name?.toLowerCase() !== 'erotic',
  );
  /* NOVA EDIT CHANGE - Original: const { data } = useBackend<LoadoutManagerData>();
  const { erp_pref } = data; */
  const erp_pref = useBackend<LoadoutManagerData>().data.erp_pref;

  const [searchLoadout, setSearchLoadout] = useState('');
  const [selectedTabName, setSelectedTab] = useState(
    loadout_tabs?.[0].name || '',
  );
  const [modifyItemDimmer, setModifyItemDimmer] = useState<LoadoutItem | null>(
    null,
  );
  // NOVA EDIT ADDITION START: Multiple loadout presets
  const [managingPreset, _setManagingPreset] = useState<string | null>(null);
  const { act, data } = useBackend<PreferencesMenuData>();
  const [input, setInput] = useState('');
  const { t, localizeDataLabelById } = usePreferencesLocalization(data);
  const setManagingPreset = (value) => {
    _setManagingPreset(value);
    setInput('');
  };
  const onType = (value: string) => {
    if (value === input) {
      return;
    }
    setInput(removeAllSkiplines(value));
  };
  // NOVA EDIT END

  if (!serverData) {
    return <NoticeBox>{t('ui.character.loading')}</NoticeBox>;
  }

  return (
    <Stack className="PreferencesMenu__Loadout" vertical fill>
      <Stack.Item>
        {/* NOVA EDIT ADDITION START: Multiple loadout presets */}
        {!!managingPreset && (
          <Dimmer
            className="PreferencesMenu__Loadout__PresetDimmer"
            style={{ zIndex: '100' }}
          >
            <Stack
              vertical
              width="400px"
              backgroundColor="#101010"
              style={{
                borderRadius: '2px',
                position: 'relative',
                display: 'inline-block',
                padding: '5px',
              }}
            >
              <Stack.Item height="20px" width="100%">
                <Flex>
                  <Flex.Item fontSize="1.3rem">
                    {t(
                      `loadout_preset_action_${(managingPreset || '').toLowerCase()}`,
                    )}{' '}
                    {t('ui.character.loadout_preset')}
                  </Flex.Item>
                  {managingPreset === 'Add' && (
                    <Flex.Item ml="6px" mt="4px">
                      (
                      {
                        data.character_preferences.misc.loadout_lists.loadouts
                          .length
                      }{' '}
                      / 12)
                    </Flex.Item>
                  )}
                  <Flex.Item ml="auto">
                    <Button
                      icon="times"
                      color="red"
                      onClick={() => {
                        setManagingPreset(null);
                      }}
                    />
                  </Flex.Item>
                </Flex>
              </Stack.Item>
              <Stack.Item width="100%" height="20px">
                <Input
                  placeholder={t('ui.character.loadout_maximum_24_characters')}
                  width="100%"
                  maxLength={24}
                  onChange={(value) => onType(value)}
                  onEnter={() => {
                    act(`${managingPreset.toLowerCase()}_loadout_preset`, {
                      name: input,
                    });
                    setManagingPreset(null);
                  }}
                  onEscape={() => setManagingPreset(null)}
                />
              </Stack.Item>
              <Stack.Item>
                <Stack justify="center">
                  <Button
                    onClick={() => {
                      act(`${managingPreset.toLowerCase()}_loadout_preset`, {
                        name: input,
                      });
                      setManagingPreset(null);
                    }}
                  >
                    {t('ui.character.loadout_done')}
                  </Button>
                </Stack>
              </Stack.Item>
            </Stack>
          </Dimmer>
        )}
        {/* NOVA EDIT END */}
        {!!modifyItemDimmer && (
          <LoadoutModifyDimmer
            modifyItemDimmer={modifyItemDimmer}
            setModifyItemDimmer={setModifyItemDimmer}
          />
        )}
        <Section
          className="PreferencesMenu__Loadout__TopSection"
          fitted
        >
          <Stack className="PreferencesMenu__Loadout__TopRow" align="center">
            <Stack.Item grow>
              <Tabs fluid align="center">
                {loadout_tabs // NOVA EDIT CHANGE - Adds filter before map()
                  // NOVA EDIT ADDITION START - Prefslocked tabs
                  .filter(
                    (curTab) =>
                      (!curTab.erp_category ||
                        (curTab.erp_category && erp_pref)) &&
                      curTab.name?.toLowerCase() !== 'erotic',
                  ) // NOVA EDIT ADDITION END
                  .map((curTab) => (
                    <Tabs.Tab
                      key={curTab.name}
                      selected={
                        searchLoadout.length <= 1 &&
                        curTab.name === selectedTabName
                      }
                      onClick={() => {
                        setSelectedTab(curTab.name);
                        setSearchLoadout('');
                      }}
                    >
                      <Box>
                        {curTab.category_icon && (
                          <Icon name={curTab.category_icon} mr={1} />
                        )}
                        {localizeDataLabelById(
                          `loadout_tab_${curTab.name}`,
                          curTab.name,
                        )}
                      </Box>
                    </Tabs.Tab>
                  ))}
              </Tabs>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <LoadoutTabs
          loadout_tabs={loadout_tabs}
          currentTab={selectedTabName}
          currentSearch={searchLoadout}
          setCurrentSearch={setSearchLoadout}
          modifyItemDimmer={modifyItemDimmer}
          setModifyItemDimmer={setModifyItemDimmer}
          setManagingPreset={setManagingPreset} // NOVA EDIT ADDITION: Multiple loadout presets
        />
      </Stack.Item>
    </Stack>
  );
}

type LoadoutTabsProps = {
  loadout_tabs: LoadoutCategory[];
  currentTab: string;
  currentSearch: string;
  setCurrentSearch: (value: string) => void;
  modifyItemDimmer: LoadoutItem | null;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
  setManagingPreset: (string) => void; // NOVA EDIT ADDITION: Multiple loadout presets
};

function LoadoutTabs(props: LoadoutTabsProps) {
  const {
    loadout_tabs,
    currentTab,
    currentSearch,
    setCurrentSearch,
    modifyItemDimmer,
    setModifyItemDimmer,
    setManagingPreset, // NOVA EDIT ADDITION: Multiple loadout presets
  } = props;
  const activeCategory = loadout_tabs.find((curTab) => {
    return curTab.name === currentTab;
  });
  const searching = currentSearch.length > 1;

  const { act, data } = useBackend<PreferencesMenuData>(); // NOVA EDIT ADDITION: Multiple loadout presets
  const { t, localizeDataLabelById } = usePreferencesLocalization(data);
  return (
    <Stack className="PreferencesMenu__Loadout__Body" fill>
      <Stack.Item align="center" width="250px" height="100%">
        <Stack vertical fill>
          <Stack.Item height="390px">
            <LoadoutPreviewSection />
          </Stack.Item>
          {/* NOVA EDIT ADDITION START: Multiple loadout presets */}
          <Stack.Item>
            <Section className="PreferencesMenu__Loadout__TopSection">
              <Stack vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Dropdown
                        className="PreferencesMenu__Loadout__Dropdown"
                        width="209px"
                        options={
                          data.character_preferences.misc.loadout_lists.loadouts
                        }
                        selected={data.character_preferences.misc.loadout_index}
                        onSelected={(value) =>
                          act('set_loadout_preset', { name: value })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        className="PreferencesMenu__Loadout__ActionButton"
                        icon="pen"
                        onClick={() => setManagingPreset('Rename')}
                        disabled={
                          data.character_preferences.misc.loadout_index ===
                          'Default'
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        className="PreferencesMenu__Loadout__ActionButton"
                        onClick={() => setManagingPreset('Add')}
                        icon="plus"
                        color="good"
                      >
                        {t('ui.character.loadout_add_new')}
                      </Button>
                    </Stack.Item>
                    <Stack.Item ml={12.5}>
                      <Button.Confirm
                        className="PreferencesMenu__Loadout__ActionButton"
                        icon="trash"
                        color="red"
                        align="center"
                        disabled={
                          data.character_preferences.misc.loadout_index ===
                          'Default'
                        }
                        tooltip={
                          data.character_preferences.misc.loadout_index ===
                          'Default'
                            ? t('ui.character.loadout_cant_delete_default')
                            : t('ui.character.loadout_delete_current_entry')
                        }
                        onClick={() => act('remove_loadout_preset')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {/* NOVA EDIT END */}
          <Stack.Item grow>
            <LoadoutSelectedSection
              all_tabs={loadout_tabs}
              modifyItemDimmer={modifyItemDimmer}
              setModifyItemDimmer={setModifyItemDimmer}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {searching || activeCategory?.contents ? (
          <Section
            className="PreferencesMenu__Loadout__CatalogSection"
            title={
              <Stack fill align="center">
                <Stack.Item grow>
                  {searching ? (
                    t('ui.character.loadout_search_results')
                  ) : (
                    <Stack align="center">
                      <Stack.Item>{t('ui.character.loadout_catalog')}</Stack.Item>
                      {!!activeCategory?.category_info && (
                        <Stack.Item ml={1}>
                          <Box italic opacity={0.85}>
                            {localizeDataLabelById(
                              `loadout_category_info_${activeCategory.name}`,
                              activeCategory.category_info,
                            )}
                          </Box>
                        </Stack.Item>
                      )}
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Input
                    className="PreferencesMenu__Loadout__SearchInput"
                    width="210px"
                    onChange={setCurrentSearch}
                    placeholder={t('ui.character.loadout_search_item')}
                    value={currentSearch}
                  />
                </Stack.Item>
              </Stack>
            }
            fill
            scrollable
          >
            <Stack vertical>
              <Stack.Item>
                {searching ? (
                  <SearchDisplay
                    loadout_tabs={loadout_tabs}
                    currentSearch={currentSearch}
                  />
                ) : (
                  <LoadoutTabDisplay category={activeCategory} />
                )}
              </Stack.Item>
            </Stack>
          </Section>
        ) : (
          <Section
            className="PreferencesMenu__Loadout__CatalogSection"
            title={
              <Stack fill align="center">
                <Stack.Item grow>
                  {t('ui.character.loadout_catalog')}
                </Stack.Item>
                <Stack.Item>
                  <Input
                    className="PreferencesMenu__Loadout__SearchInput"
                    width="210px"
                    onChange={setCurrentSearch}
                    placeholder={t('ui.character.loadout_search_item')}
                    value={currentSearch}
                  />
                </Stack.Item>
              </Stack>
            }
            fill
          >
            <Box>{t('ui.character.loadout_no_contents_selected_tab')}</Box>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
}

function typepathToLoadoutItem(
  typepath: typePath,
  all_tabs: LoadoutCategory[],
) {
  // Maybe a bit inefficient, could be replaced with a hashmap?
  for (const tab of all_tabs) {
    for (const item of tab.contents) {
      if (item.path === typepath) {
        return item;
      }
    }
  }
  return null;
}

type LoadoutSelectedItemProps = {
  path: typePath;
  all_tabs: LoadoutCategory[];
  modifyItemDimmer: LoadoutItem | null;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
};

function LoadoutSelectedItem(props: LoadoutSelectedItemProps) {
  const { all_tabs, path, modifyItemDimmer, setModifyItemDimmer } = props;
  const { act, data } = useBackend<LoadoutManagerData>();
  const { localizeDataLabelById } = usePreferencesLocalization(data);

  const item = typepathToLoadoutItem(path, all_tabs);
  if (!item) {
    return null;
  }

  return (
    <Stack align={'center'}>
      <Stack.Item>
        <ItemIcon item={item} scale={1} />
      </Stack.Item>
      <Stack.Item width="55%">
        {localizeDataLabelById(`loadout_item_${path}_name`, item.name)}
      </Stack.Item>
      {item.buttons.length ? (
        <Stack.Item>
          <Button
            color="none"
            width="32px"
            onClick={() => {
              setModifyItemDimmer(item);
            }}
          >
            <Icon size={1.8} name="cogs" color="grey" />
          </Button>
        </Stack.Item>
      ) : (
        <Stack.Item width="32px" /> // empty space
      )}
      <Stack.Item>
        <Button
          color="none"
          width="32px"
          onClick={() => act('select_item', { path: path, deselect: true })}
        >
          <Icon size={2.4} name="times" color="red" />
        </Button>
      </Stack.Item>
    </Stack>
  );
}

type LoadoutSelectedSectionProps = {
  all_tabs: LoadoutCategory[];
  modifyItemDimmer: LoadoutItem | null;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
};

function LoadoutSelectedSection(props: LoadoutSelectedSectionProps) {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { t } = usePreferencesLocalization(data);
  const loadout_list = data.character_preferences.misc.loadout_lists.loadout; // NOVA EDIT CHANGE - Multiple loadout presets - ORIGINAL: const { loadout_list } = data.character_preferences.misc;
  const { all_tabs, modifyItemDimmer, setModifyItemDimmer } = props;

  return (
    <Section
      className="PreferencesMenu__Loadout__SelectedSection"
      title={t('ui.character.loadout_selected_items')}
      scrollable
      fill
      buttons={
        <Button.Confirm
          className="PreferencesMenu__Loadout__ActionButton"
          icon="times"
          color="red"
          align="center"
          disabled={!loadout_list || Object.keys(loadout_list).length === 0}
          tooltip={t('ui.character.loadout_clear_all_tooltip')}
          onClick={() => act('clear_all_items')}
        >
          {t('ui.character.loadout_clear_all')}
        </Button.Confirm>
      }
    >
      {!loadout_list.length && // NOVA EDIT CHANGE - ORIGINAL: {loadout_list &&
        Object.entries(loadout_list).map(([path, item]) => (
          <Fragment key={path}>
            <LoadoutSelectedItem
              path={path}
              all_tabs={all_tabs}
              modifyItemDimmer={modifyItemDimmer}
              setModifyItemDimmer={setModifyItemDimmer}
            />
            <Divider />
          </Fragment>
        ))}
    </Section>
  );
}

function LoadoutPreviewSection() {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { t, localizeDataLabelById } =
    usePreferencesLocalization(data);
  const previewDropdownOptions = data.preview_options.map((option) => ({
    value: option,
    displayText: data.preview_option_ids?.[option]
      ? localizeDataLabelById(data.preview_option_ids[option], option)
      : localizeDataLabelById(`preview_option_${option}`, option),
  }));
  const selectedPreviewText =
    previewDropdownOptions.find(
      (option) => option.value === data.preview_selection,
    )?.displayText ?? data.preview_selection;

  return (
    <Section
      className="PreferencesMenu__Loadout__PreviewSection"
      fill
      title={t('ui.character.loadout_preview')}
      buttons={
        <Button.Checkbox
          className="PreferencesMenu__Loadout__ActionButton"
          align="center"
          checked={data.job_clothes}
          onClick={() => act('toggle_job_clothes')}
        >
          {t('ui.character.loadout_job_clothes')}
        </Button.Checkbox>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow align="center">
          <CharacterPreview
            height="100%"
            width="240px"
            id={data.character_preview_view}
          />{' '}
          {/* NOVA EDIT CHANGE - ORIGINAL: <CharacterPreview height="100%" id={data.character_preview_view} /> */}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item align="center">
          <Stack>
            {/* NOVA EDIT ADDITION START: Better loadout pref */}
            <Stack.Item>
              <Dropdown
                className="PreferencesMenu__Loadout__Dropdown"
                displayText={selectedPreviewText}
                selected={data.preview_selection}
                options={previewDropdownOptions}
                onSelected={(value) =>
                  act('update_preview', {
                    updated_preview: value,
                  })
                }
              />
            </Stack.Item>
            {/* NOVA EDIT END */}
            <Stack.Item>
              <Button
                className="PreferencesMenu__Loadout__ActionButton"
                icon="chevron-left"
                onClick={() =>
                  act('rotate_dummy', {
                    dir: 'left',
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                className="PreferencesMenu__Loadout__ActionButton"
                icon="chevron-right"
                onClick={() =>
                  act('rotate_dummy', {
                    dir: 'right',
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
