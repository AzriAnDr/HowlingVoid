import { useState } from 'react';
import {
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type LogViewerData = {
  round_id: number;
  logging_start_timestamp: string;
  tree: LogViewerCategoryTree;
  last_data_update: number;
  categories: Record<string, LogViewerCategoryData>;
};

type LogViewerCategoryTree = {
  enabled: string[];
  disabled: string[];
};

type LogViewerCategoryData = {
  entry_count: number;
  entries: LogEntryData[];
};

type LogEntryData = {
  id: number;
  message: string;
  timestamp: string;
  semver?: Record<string, string>;
  data?: any[];
};

const CATEGORY_ALL = 'all';

export const LogViewer = (_: any) => {
  const { data, act } = useBackend<LogViewerData>();
  const { t } = usePreferencesLocalization(data);

  const [activeCategory, setActiveCategory] = useState('');

  let viewerData: LogViewerCategoryData = {
    entry_count: 0,
    entries: [],
  };

  if (activeCategory) {
    if (activeCategory !== CATEGORY_ALL) {
      viewerData = data.categories[activeCategory];
    } else {
      for (const category in data.categories) {
        const categoryData = data.categories[category];
        for (const entry of categoryData.entries) {
          viewerData.entries.push(entry);
        }
        viewerData.entry_count += categoryData.entry_count;
      }
      viewerData.entries.sort((a, b) => a.id - b.id);
    }
  }

  return (
    <Window width={720} height={720}>
      <Window.Content scrollable>
        <Section>
          <Button icon="sync" onClick={() => act('refresh')} />
        </Section>
        <CategoryBar
          t={t}
          options={data.tree.enabled}
          active={activeCategory}
          setActive={setActiveCategory}
        />
        <CategoryViewer activeCategory={activeCategory} data={viewerData} t={t} />
      </Window.Content>
    </Window>
  );
};

type CategoryBarProps = {
  t: (key: string, fallback?: string) => string;
  options: string[];
  active: string;
  setActive: (active: string) => void;
};

const CategoryBar = (props: CategoryBarProps) => {
  const sorted = [...props.options].sort();
  const [categorySearch, setCategorySearch] = useState('');

  return (
    <Section
      title={props.t('ui.log_viewer.categories')}
      scrollableHorizontal
      buttons={
        <Input
          placeholder={props.t('ui.common.search')}
          value={categorySearch}
          onChange={setCategorySearch}
        />
      }
    >
      <Stack>
        {/** these are not in stack items to have them directly next to eachother */}
        <Button
          selected={props.active === ''}
          onClick={() => props.setActive('')}
        >
          {props.t('ui.common.none')}
        </Button>
        <Button
          tooltip={props.t('ui.log_viewer.this_can_be_slow')}
          selected={props.active === CATEGORY_ALL}
          onClick={() => props.setActive(CATEGORY_ALL)}
        >
          {props.t('ui.common.all')}
        </Button>
        {sorted
          .filter((cat) =>
            cat.toLowerCase().includes(categorySearch.toLowerCase()),
          )
          .map((category) => (
            <Button
              key={category}
              selected={category === props.active}
              onClick={() => props.setActive(category)}
            >
              {category}
            </Button>
          ))}
      </Stack>
    </Section>
  );
};

type CategoryViewerProps = {
  t: (key: string, fallback?: string) => string;
  activeCategory: string;
  data?: LogViewerCategoryData;
};

const validateRegExp = (str: string) => {
  try {
    new RegExp(str);
    return true;
  } catch (e) {
    return e;
  }
};

const CategoryViewer = (props: CategoryViewerProps) => {
  const [search, setSearch] = useState('');
  let [searchRegex, setSearchRegex] = useState(false);
  const [caseSensitive, setCaseSensitive] = useState(false);
  if (!search && searchRegex) {
    setSearchRegex(false);
    searchRegex = false;
  }
  let regexValidation: boolean | SyntaxError = true;
  if (searchRegex) {
    regexValidation = validateRegExp(search);
  }

  return (
    <Section
      title={`Category Viewer${
        props.activeCategory
          ? ` - ${props.activeCategory}[${props.data?.entry_count}]`
          : ` - ${props.t('ui.log_viewer.select_category')}`
      }`}
      buttons={
        <>
          <Input
            placeholder={props.t('ui.common.search')}
            value={search}
            onChange={setSearch}
          />
          <Button
            icon="code"
            tooltip={props.t('ui.log_viewer.regex_search')}
            selected={searchRegex}
            onClick={() => setSearchRegex(!searchRegex)}
          />
          <Button
            icon="font"
            selected={caseSensitive}
            tooltip={props.t('ui.log_viewer.case_sensitive')}
            onClick={() => setCaseSensitive(!caseSensitive)}
          />
          <Button
            icon="trash"
            tooltip={props.t('ui.log_viewer.clear_search')}
            color="bad"
            onClick={() => {
              setSearch('');
              setSearchRegex(false);
            }}
          />
        </>
      }
    >
      <Stack vertical>
        {!searchRegex || regexValidation === true ? (
          props.data?.entries.map((entry) => {
            if (search) {
              if (searchRegex) {
                const regex = new RegExp(search, caseSensitive ? 'g' : 'gi');
                if (!regex.test(entry.message)) {
                  return null;
                }
              } else {
                if (caseSensitive) {
                  if (!entry.message.includes(search)) {
                    return null;
                  }
                } else {
                  if (
                    !entry.message.toLowerCase().includes(search.toLowerCase())
                  ) {
                    return null;
                  }
                }
              }
            }

            return (
              <Stack.Item key={entry.id}>
                <Collapsible title={`[${entry.id}] - ${entry.message}`}>
                  <Stack vertical fill>
                    <Stack.Item>
                      <p font-family="Courier">{entry.message}</p>
                    </Stack.Item>
                    <Stack.Item>
                      {entry.semver && (
                        <Stack.Item>
                          <JsonViewer
                            data={entry.semver}
                            title={props.t('ui.log_viewer.semver')}
                          />
                        </Stack.Item>
                      )}
                    </Stack.Item>
                    {entry.data && (
                      <Stack.Item>
                        <JsonViewer
                          data={entry.data}
                          title={props.t('ui.common.data')}
                        />
                      </Stack.Item>
                    )}
                  </Stack>
                </Collapsible>
              </Stack.Item>
            );
          })
        ) : (
          <NoticeBox danger>
            {props.t('ui.log_viewer.invalid_regex')}:{' '}
            {(regexValidation as SyntaxError).message}
          </NoticeBox>
        )}
      </Stack>
    </Section>
  );
};

const JsonViewer = (props: { data: any; title: string }) => {
  return (
    <Collapsible title={props.title}>
      <pre>{JSON.stringify(props.data, null, 2)}</pre>
    </Collapsible>
  );
};
