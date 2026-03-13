import { binaryInsertWith } from 'common/collections';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { type Antagonist, Category } from '../antagonists/base';
import type { PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

const requireAntag = require.context(
  '../antagonists/antagonists',
  false,
  /.ts$/,
);

const antagsByCategory = new Map<Category, Antagonist[]>();

// This will break at priorities higher than 10, but that almost definitely
// will not happen.
function binaryInsertAntag(collection: Antagonist[], value: Antagonist) {
  return binaryInsertWith(collection, value, (antag) => {
    return `${antag.priority}_${antag.name}`;
  });
}

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag<{
    default?: Antagonist;
  }>(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(antagsByCategory.get(antag.category) || [], antag),
  );
}

type AntagSelectionProps = {
  antagonists: Antagonist[];
  name: string;
};

function AntagSelection(props: AntagSelectionProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabelById } = usePreferencesLocalization(data);
  const className = 'PreferencesMenu__Antags__antagSelection';

  const [predictedState, setPredictedState] = useState(
    new Set(data.selected_antags),
  );

  function enableAntags(antags: string[]) {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: true,
    });
  }

  function disableAntags(antags: string[]) {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: false,
    });
  }

  const antagonistKeys = props.antagonists.map((antagonist) => antagonist.key);

  return (
    <Section
      title={props.name}
      buttons={
        <>
          <Button color="good" onClick={() => enableAntags(antagonistKeys)}>
            {t('ui.character.antags_enable_all')}
          </Button>

          <Button color="bad" onClick={() => disableAntags(antagonistKeys)}>
            {t('ui.character.antags_disable_all')}
          </Button>
        </>
      }
    >
      <Flex className={className} align="flex-end" wrap>
        {props.antagonists.map((antagonist) => {
          const isBanned =
            data.antag_bans && data.antag_bans.indexOf(antagonist.key) !== -1;

          const daysLeft = data.antag_days_left?.[antagonist.key] || 0;

          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${
                  isBanned || daysLeft > 0
                    ? 'banned'
                    : predictedState.has(antagonist.key)
                      ? 'on'
                      : 'off'
                }`,
              ])}
              key={antagonist.key}
            >
              <Stack align="center" vertical>
                <Stack.Item
                  style={{
                    fontWeight: 'bold',
                    marginTop: 'auto',
                    maxWidth: '100px',
                    textAlign: 'center',
                  }}
                >
                  {localizeDataLabelById(
                    `antag_${antagonist.key}_name`,
                    antagonist.name,
                  )}
                </Stack.Item>

                <Stack.Item align="center">
                  <Tooltip
                    content={
                      isBanned
                        ? t('ui.character.antags_banned_tooltip').replace(
                            '{name}',
                            localizeDataLabelById(
                              `antag_${antagonist.key}_name`,
                              antagonist.name,
                            ),
                          )
                        : antagonist.description.map((text, index) => {
                            return (
                              <div key={antagonist.key + index}>
                                {localizeDataLabelById(
                                  `antag_${antagonist.key}_description_${index}`,
                                  text,
                                )}
                                {index !==
                                  antagonist.description.length - 1 && (
                                  <Divider />
                                )}
                              </div>
                            );
                          })
                    }
                    position="bottom"
                  >
                    <Box
                      className={'antagonist-icon-parent'}
                      onClick={() => {
                        if (isBanned) {
                          return;
                        }

                        if (predictedState.has(antagonist.key)) {
                          disableAntags([antagonist.key]);
                        } else {
                          enableAntags([antagonist.key]);
                        }
                      }}
                    >
                      <Box
                        className={classes([
                          'antagonists96x96',
                          antagonist.key,
                          'antagonist-icon',
                        ])}
                      />

                      {isBanned && <Box className="antagonist-banned-slash" />}

                      {daysLeft > 0 && (
                        <Box className="antagonist-days-left">
                          <b>{daysLeft}</b> {t('ui.character.antags_days_left')}
                        </Box>
                      )}
                    </Box>
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          );
        })}
      </Flex>
    </Section>
  );
}

export function AntagsPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Box className="PreferencesMenu__Antags">
      <AntagSelection
        name={t('ui.character.antags_roundstart')}
        antagonists={antagsByCategory.get(Category.Roundstart)!}
      />

      <AntagSelection
        name={t('ui.character.antags_midround')}
        antagonists={antagsByCategory.get(Category.Midround)!}
      />

      <AntagSelection
        name={t('ui.character.antags_latejoin')}
        antagonists={antagsByCategory.get(Category.Latejoin)!}
      />
    </Box>
  );
}
