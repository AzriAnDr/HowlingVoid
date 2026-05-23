import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Flex, Stack } from 'tgui-core/components'; // NOVA EDIT CHANGE - ORIGINAL: import { Button, Stack } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import type { PreferencesMenuData } from '../types';
import { AntagsPage } from './AntagsPage';
import { JobsPage } from './JobsPage';
// NOVA EDIT ADDITION START
import { LanguagesPage } from './LanguagesMenu';
import { LimbsPage } from './LimbsPage';
// NOVA EDIT ADDITION END
import { LoadoutPage } from './loadout';
import { usePreferencesLocalization } from './localization';
import { MainPage } from './MainPage';
import { QuirkPersonalityPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
  // NOVA EDIT ADDITION START
  Limbs,
  Languages,
  // NOVA EDIT ADDITION END
}

type ProfileProps = {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
  t: (key: string, fallback?: string) => string;
};

function CharacterProfiles(props: ProfileProps) {
  const { activeSlot, onClick, profiles, t } = props;

  return (
    <Flex /* NOVA EDIT CHANGE START - Nova uses a dropdown instead of buttons */
      className="PreferencesMenu__Character__Profiles"
      align="center"
      justify="center"
    >
      <Flex.Item width="25%">
        <Dropdown
          className="PreferencesMenu__Character__ProfilesDropdown"
          width="100%"
          selected={activeSlot as unknown as string}
          displayText={profiles[activeSlot]}
          options={profiles.map((profile, slot) => ({
            value: slot,
            displayText: profile ?? t('ui.character.new_character'),
          }))}
          onSelected={(slot) => {
            onClick(slot);
          }}
        />
      </Flex.Item>
    </Flex> /* NOVA EDIT CHANGE END */
  );
}

export function CharacterPreferenceWindow(props) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  const [currentPage, setCurrentPage] = useState(Page.Main);

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    case Page.Main:
      pageContents = (
        <MainPage openSpecies={() => setCurrentPage(Page.Species)} />
      );

      break;
    case Page.Species:
      pageContents = (
        <SpeciesPage closeSpecies={() => setCurrentPage(Page.Main)} />
      );

      break;
    case Page.Quirks:
      pageContents = <QuirkPersonalityPage />;
      break;

    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;
    // NOVA EDIT ADDITION START
    case Page.Limbs:
      pageContents = <LimbsPage />;
      break;
    case Page.Languages:
      pageContents = <LanguagesPage />;
      break;
    // NOVA EDIT ADDITION END

    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Stack vertical fill className="PreferencesMenu__Character">
      <Stack.Item>
        <Stack align="center">
          <Stack.Item grow>
            <CharacterProfiles
              activeSlot={data.active_slot - 1}
              t={t}
              onClick={(slot) => {
                act('change_slot', {
                  slot: slot + 1,
                });
              }}
              profiles={data.character_profiles}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!data.content_unlocked && (
        <Stack.Item align="center">
          <Box className="PreferencesMenu__Character__PremiumNotice">
            {t('ui.character.buy_byond_premium_more_slots')}
          </Box>
        </Stack.Item>
      )}
      <Stack.Divider />
      <Stack.Item className="PreferencesMenu__Character__TopTabs">
        <Stack fill>
          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Main}
              setPage={setCurrentPage}
              otherActivePages={[Page.Species]}
            >
              {t('ui.character.tab_character')}
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Loadout}
              setPage={setCurrentPage}
            >
              {t('ui.character.tab_loadout')}
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Jobs}
              setPage={setCurrentPage}
            >
              {/*
                    Fun fact: This isn't "Jobs" so that it intentionally
                    catches your eyes, because it's really important!
                  */}
              {t('ui.character.tab_occupations')}
            </PageButton>
          </Stack.Item>
          {/* NOVA EDIT ADDITION START */}
          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Limbs}
              setPage={setCurrentPage}
            >
              {t('ui.character.tab_augments')}
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Languages}
              setPage={setCurrentPage}
            >
              {t('ui.character.tab_languages')}
            </PageButton>
          </Stack.Item>
          {/* NOVA EDIT ADDITION end */}
          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Antags}
              setPage={setCurrentPage}
            >
              {t('ui.character.tab_antagonists')}
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              className="PreferencesMenu__Character__TopTabButton"
              currentPage={currentPage}
              page={Page.Quirks}
              setPage={setCurrentPage}
            >
              {t('ui.character.tab_quirks_personality')}
            </PageButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow position="relative" overflowX="hidden" overflowY="auto">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
}
