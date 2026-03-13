import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { ReagentLookup } from '../common/ReagentLookup';
import { RecipeLookup } from '../common/RecipeLookup';
import { bookmarkedReactions } from '.';
import type { ReagentsData } from './types';

export function Lookup() {
  const { act, data } = useBackend<ReagentsData>();
  const { t } = usePreferencesLocalization();
  const { beakerSync, reagent_mode_recipe, reagent_mode_reagent } = data;

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section
          title={t('ui.reagents.recipe_lookup')}
          minWidth="353px"
          buttons={
            <>
              <Button
                icon="atom"
                color={beakerSync ? 'green' : 'red'}
                tooltip={t(
                  'ui.reagents.when_enabled_the_displayed_reaction_will_automatically_display_o',
                )}
                onClick={() => act('beaker_sync')}
              >
                {t('ui.reagents.beaker_sync')}
              </Button>
              <Button
                icon="search"
                color="purple"
                tooltip={t('ui.reagents.search_for_a_recipe_by_product_name')}
                onClick={() => act('search_recipe')}
              >
                {t('ui.common.search')}
              </Button>
              <Button
                icon="times"
                color="red"
                disabled={!reagent_mode_recipe}
                onClick={() =>
                  act('recipe_click', {
                    id: null,
                  })
                }
              />
            </>
          }
        >
          <RecipeLookup
            recipe={reagent_mode_recipe}
            bookmarkedReactions={bookmarkedReactions}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section
          title={t('ui.reagents.reagent_lookup')}
          minWidth="300px"
          buttons={
            <>
              <Button
                icon="search"
                tooltip={t('ui.reagents.search_for_a_reagent_by_name')}
                tooltipPosition="left"
                onClick={() => act('search_reagents')}
              >
                {t('ui.common.search')}
              </Button>
              <Button
                icon="times"
                color="red"
                disabled={!reagent_mode_reagent}
                onClick={() =>
                  act('reagent_click', {
                    id: null,
                  })
                }
              />
            </>
          }
        >
          <ReagentLookup reagent={reagent_mode_reagent} />
        </Section>
      </Stack.Item>
    </Stack>
  );
}
