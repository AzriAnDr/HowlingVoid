// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CharacterPreview } from './common/CharacterPreview';
import { usePreferencesLocalization } from './localization';

const formatURLs = (text) => {
  if (!text) return;
  const parts = [];
  const regex = /https?:\/\/[^\s/$.?#].[^\s]*/gi;
  let lastIndex = 0;

  text.replace(regex, (url, index) => {
    parts.push(text.substring(lastIndex, index));
    parts.push(
      <a
        style={{
          color: '#0591e3',
          textDecoration: 'none',
          borderBottom: 'solid 1.25px',
        }}
        href={url}
      >
        {url}
      </a>,
    );
    lastIndex = index + url.length;
    return url;
  });

  parts.push(text.substring(lastIndex));

  return <div>{parts}</div>;
};
const erpTagColor = {
  Unset: '#000000',
  'Top - Dom': '#410308',
  'Top - Switch': '#410308',
  'Top - Sub': '#410308',
  'Verse-Top - Dom': '#3d003b',
  'Verse-Top - Switch': '#3d003b',
  'Verse-Top - Sub': '#3d003b',
  'Verse - Dom': '#310042',
  'Verse - Switch': '#310042',
  'Verse - Sub': '#310042',
  'Verse-Bottom - Dom': '#29084b',
  'Verse-Bottom - Switch': '#29084b',
  'Verse-Bottom - Sub': '#29084b',
  'Bottom - Dom': '#002f51',
  'Bottom - Switch': '#002f51',
  'Bottom - Sub': '#002f51',
  'Check OOC Notes': '#333333',
  'Ask (L)OOC': '#333333',
  No: '#131313',
  Yes: '#002901',
};

export const NovaCharacterDirectory = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  const {
    personalAttraction,
    personalGender,
    personalErpTag,
    personalVoreTag,
    personalNonconTag,
    personalHypnoTag,
    assignedView,
    startViewing,
  } = data;

  const [overlay, setOverlay] = useState(null);
  const updateOverlay = (character) => {
    setOverlay(character);
  };

  // For hack to get the view to show up correctly
  // See MedicalRecords/RecordTabs.tsx for explanation
  const [viewCreated, setViewCreated] = useState(false);
  const updateViewCreated = (created) => {
    setViewCreated(created);
  };

  const [searchTerm, setSearchTerm] = useState(startViewing || '');
  const updateSearchTerm = (character) => {
    setSearchTerm(character);
  };

  const [sortId, setSortId] = useState('name');
  const updateSortId = (character) => {
    setSortId(character);
  };
  const [sortOrder, setSortOrder] = useState('asc');
  const updateSortOrder = (character) => {
    setSortOrder(character);
  };

  const [colorCodeEnabled, setColorCodeEnabled] = useState('');
  const updateColorCodeEnabled = (character) => {
    setColorCodeEnabled(character);
  };

  return (
    <Window width={1000} height={800} resizeable>
      <Window.Content scrollable>
        {(overlay && (
          <ViewCharacter
            viewCreated={setViewCreated}
            setViewCreated={setViewCreated}
            overlay={overlay}
            updateOverlay={updateOverlay}
            assignedView={assignedView}
          />
        )) || (
          <>
            <Section title={t('ui.character_directory.your_preferences')}>
              <LabeledList>
                <LabeledList.Item
                  label={t('ui.character_directory.attraction')}
                >
                  <Button fluid>{personalAttraction}</Button>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.character_directory.gender')}>
                  <Button fluid>{personalGender}</Button>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.character_directory.erp')}>
                  <Button fluid>{personalErpTag}</Button>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.character_directory.vore')}>
                  <Button fluid>{personalVoreTag}</Button>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.character_directory.hypnosis')}>
                  <Button fluid>{personalHypnoTag}</Button>
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.character_directory.noncon')}>
                  <Button fluid>{personalNonconTag}</Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <CharacterDirectoryList
              viewCreated={viewCreated}
              setViewCreated={setViewCreated}
              updateOverlay={updateOverlay}
              searchTerm={searchTerm}
              updateSearchTerm={updateSearchTerm}
              sortId={sortId}
              updateSortId={updateSortId}
              sortOrder={sortOrder}
              updateSortOrder={updateSortOrder}
              colorCodeEnabled={colorCodeEnabled}
              updateColorCodeEnabled={updateColorCodeEnabled}
            />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const ViewCharacter = (props) => {
  const { overlay, updateOverlay, assignedView } = props;
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [oocNotesIndex, setOocNotesIndex] = useState('SFW');
  const [flavorTextIndex, setFlavorTextIndex] = useState('SFW');

  return (
    <Stack fill>
      <Stack.Item>
        <Section height="375px" width="262px" title={overlay.name}>
          <CharacterPreview height="330px" width="250px" id={assignedView} />
        </Section>
        <Section title={t('ui.character_directory.headshot')}>
          <img
            src={resolveAsset(overlay.headshot)}
            height="250px"
            width="250px"
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              minHeight="375px"
              scrollable
              fill
              title={t('ui.character_directory.flavor_text')}
              preserveWhitespace
              buttons={
                <>
                  <Button
                    selected={flavorTextIndex === 'SFW'}
                    bold={flavorTextIndex === 'SFW'}
                    onClick={() => setFlavorTextIndex('SFW')}
                    width="150px"
                    textAlign="center"
                  >
                    SFW
                  </Button>
                  <Button
                    selected={flavorTextIndex === 'NSFW'}
                    disabled={!overlay.flavor_text_nsfw}
                    bold={flavorTextIndex === 'NSFW'}
                    onClick={() => setFlavorTextIndex('NSFW')}
                    width="150px"
                    textAlign="center"
                  >
                    NSFW
                  </Button>
                </>
              }
            >
              {flavorTextIndex === 'SFW' && formatURLs(overlay.flavor_text)}
              {flavorTextIndex === 'NSFW' &&
                formatURLs(overlay.flavor_text_nsfw)}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <Section
                  maxHeight="299px"
                  fill
                  scrollable
                  title={t('ui.character_directory.ooc_notes')}
                  preserveWhitespace
                  buttons={
                    <>
                      <Button
                        selected={oocNotesIndex === 'SFW'}
                        bold={oocNotesIndex === 'SFW'}
                        onClick={() => setOocNotesIndex('SFW')}
                        width="100px"
                        textAlign="center"
                      >
                        SFW
                      </Button>
                      <Button
                        selected={oocNotesIndex === 'NSFW'}
                        bold={oocNotesIndex === 'NSFW'}
                        disabled={
                          overlay.erp === 'No' && !overlay.ooc_notes_nsfw
                        }
                        onClick={() => setOocNotesIndex('NSFW')}
                        width="100px"
                        textAlign="center"
                      >
                        NSFW
                      </Button>
                    </>
                  }
                >
                  {!!overlay.veteran_status && (
                    <Stack.Item mb="30px">
                      <span
                        style={{
                          color: 'gold',
                          fontWeight: 'bold',
                        }}
                      >
                        {t('ui.character_directory.player_is_veteran')}
                      </span>
                    </Stack.Item>
                  )}
                  {oocNotesIndex === 'NSFW' && (
                    <>
                      <LabeledList>
                        <LabeledList.Item
                          label={t('ui.character_directory.attraction')}
                        >
                          {overlay.attraction}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label={t('ui.character_directory.gender')}
                        >
                          {overlay.gender}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label={t('ui.character_directory.erp')}
                        >
                          {overlay.erp}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label={t('ui.character_directory.vore')}
                        >
                          {overlay.vore}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label={t('ui.character_directory.hypnosis')}
                        >
                          {overlay.hypno}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label={t('ui.character_directory.noncon')}
                        >
                          {overlay.noncon}
                        </LabeledList.Item>
                      </LabeledList>
                      <Box mt="6px" />
                      {formatURLs(overlay.ooc_notes_nsfw)}
                    </>
                  )}
                  {oocNotesIndex === 'SFW' && formatURLs(overlay.ooc_notes)}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  maxHeight="299px"
                  fill
                  scrollable
                  title={t('ui.character_directory.character_advert')}
                >
                  {overlay.character_ad}
                </Section>
                <NoticeBox align="right" info>
                  <Button
                    align="right"
                    color="good"
                    icon="arrow-left"
                    onClick={() => updateOverlay(null)}
                  >
                    {t('ui.common.back')}
                  </Button>
                </NoticeBox>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const CharacterDirectoryList = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    viewCreated,
    setViewCreated,
    updateOverlay,
    searchTerm,
    updateSearchTerm,
    sortId,
    updateSortId,
    sortOrder,
    updateSortOrder,
    colorCodeEnabled,
    updateColorCodeEnabled,
  } = props;

  const { directory, canOrbit, assignedView } = data;

  const handleSort = (id) => {
    if (sortId === id) {
      updateSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      updateSortId(id);
      updateSortOrder('asc');
    }
  };

  const handleRandomView = () => {
    if (directory.length > 0) {
      const randomIndex = Math.floor(Math.random() * directory.length);
      const randomCharacter = directory[randomIndex];
      // See MedicalRecords/RecordTabs.tsx for explanation
      if (!viewCreated) {
        setTimeout(() => {
          act('view_character', {
            assigned_view: assignedView,
            name: randomCharacter.appearance_name,
          });
        });
      }
      setViewCreated(true);
      updateOverlay(randomCharacter);
      act('view_character', {
        assigned_view: assignedView,
        name: randomCharacter.appearance_name,
      });
    }
  };

  const filteredDirectory = directory.filter((character) =>
    character.name.toLowerCase().includes(searchTerm.toLowerCase()),
  );

  const sortedDirectory = filteredDirectory.slice().sort((a, b) => {
    const sortOrderValue = sortOrder === 'asc' ? 1 : -1;
    return sortOrderValue * a[sortId].localeCompare(b[sortId]);
  });

  return (
    <Section
      title={t('ui.character_directory.directory')}
      buttons={
        <>
          <Button icon="sync" onClick={() => act('refresh')}>
            {t('ui.common.refresh')}
          </Button>
          <Tooltip content={t('ui.character_directory.random_advert_tooltip')}>
            <Button icon="random" onClick={handleRandomView}>
              {t('ui.character_directory.i_feel_lucky')}
            </Button>
          </Tooltip>
        </>
      }
    >
      <Stack mb={-2}>
        <Stack.Item>
          <Input
            placeholder={t('ui.character_directory.search_name_placeholder')}
            onChange={updateSearchTerm}
            expensive
            value={searchTerm}
            mb={2}
          />
        </Stack.Item>
        <Stack.Divider hidden grow width="50%" />
        <Stack.Item>
          <Button.Checkbox
            checked={colorCodeEnabled}
            onClick={(e) => {
              updateColorCodeEnabled(!colorCodeEnabled);
            }}
            tooltip={t('ui.character_directory.erp_status_colors_tooltip')}
          >
            {t('ui.character_directory.erp_status_colors')}
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
      <Divider />
      <Table>
        <Table.Row bold>
          <SortButton
            id="name"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.common.name')}
          </SortButton>
          <SortButton
            id="species"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.common.species')}
          </SortButton>
          <SortButton
            id="attraction"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.attraction')}
          </SortButton>
          <SortButton
            id="gender"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.gender')}
          </SortButton>
          <SortButton
            id="erp"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.erp')}
          </SortButton>
          <SortButton
            id="vore"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.vore')}
          </SortButton>
          <SortButton
            id="hypno"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.hypnosis')}
          </SortButton>
          <SortButton
            id="noncon"
            sortId={sortId}
            sortOrder={sortOrder}
            onClick={handleSort}
          >
            {t('ui.character_directory.noncon')}
          </SortButton>
          <Table.Cell collapsing textAlign="right">
            {t('ui.character_directory.advert')}
          </Table.Cell>
        </Table.Row>
        {sortedDirectory.map((character, i) => (
          <Table.Row
            key={i}
            backgroundColor={
              colorCodeEnabled ? erpTagColor[character.erp] : 'transparent'
            }
          >
            <Table.Cell p={1}>
              {canOrbit ? (
                <Button
                  color={erpTagColor[character.erp]}
                  icon="ghost"
                  tooltip={t('ui.common.orbit')}
                  onClick={() => act('orbit', { ref: character.ref })}
                >
                  {character.name}
                </Button>
              ) : (
                character.name
              )}
            </Table.Cell>
            <Table.Cell>{character.species}</Table.Cell>
            <Table.Cell>{character.attraction}</Table.Cell>
            <Table.Cell>{character.gender}</Table.Cell>
            <Table.Cell>{character.erp}</Table.Cell>
            <Table.Cell>{character.vore}</Table.Cell>
            <Table.Cell>{character.hypno}</Table.Cell>
            <Table.Cell>{character.noncon}</Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                onClick={() => {
                  // See MedicalRecords/RecordTabs.tsx for explanation
                  if (!viewCreated) {
                    setTimeout(() => {
                      act('view_character', {
                        assigned_view: assignedView,
                        name: character.appearance_name,
                      });
                    });
                  }
                  setViewCreated(true);
                  updateOverlay(character);
                  act('view_character', {
                    assigned_view: assignedView,
                    name: character.appearance_name,
                  });
                }}
                color="transparent"
                icon="sticky-note"
                mr={1}
              >
                {t('ui.common.view')}
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const SortButton = ({ id, sortId, sortOrder, onClick, children }) => (
  <Table.Cell collapsing>
    <Button
      width="100%"
      color={sortId !== id ? 'transparent' : undefined}
      onClick={() => onClick(id)}
    >
      {children}
      {sortId === id && (
        <Icon name={sortOrder === 'asc' ? 'sort-up' : 'sort-down'} ml={0.75} />
      )}
    </Button>
  </Table.Cell>
);
