import {
  Box,
  Button,
  Divider,
  Dropdown,
  Flex,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CharacterPreview } from './common/CharacterPreview';
import { usePreferencesLocalization } from './localization';

type CharacterEntry = {
  index: number;
  name: string;
};

type SlotEntry = {
  index: number;
  name: string | null;
  occupied: BooleanLike;
};

type PreferenceImporterData = {
  characters: CharacterEntry[];
  selected_character: number;
  slots: SlotEntry[];
  target_slot: number;
  active_slot: number;
  has_keybindings: BooleanLike;
  has_game_prefs: BooleanLike;
  has_emote_panel: BooleanLike;
  import_keybindings: BooleanLike;
  import_game_prefs: BooleanLike;
  import_character: BooleanLike;
  import_emote_panel: BooleanLike;
  export_version: number;
  preview_map: string | null;
  preview_mode: string;
  preview_options: string[];
};

export function PreferenceImporter() {
  const { act, data } = useBackend<PreferenceImporterData>();
  const { t } = usePreferencesLocalization(data);

  const {
    characters,
    selected_character,
    slots,
    target_slot,
    active_slot,
    has_keybindings,
    has_game_prefs,
    has_emote_panel,
    import_keybindings,
    import_game_prefs,
    import_character,
    import_emote_panel,
    export_version,
    preview_map,
    preview_mode,
    preview_options,
  } = data;

  const selectedChar = characters.find(
    (character) => character.index === selected_character,
  );

  return (
    <Window
      title={t('ui.character.preference_importer.window_title')}
      width={1000}
      height={700}
    >
      <Window.Content scrollable>
        <Stack>
          <Stack.Item width="340px">
            <Section
              title={t('ui.character.preference_importer.preview')}
              textAlign="center"
            >
              <Stack vertical align="center" justify="center">
                <Stack.Item>
                  {preview_map ? (
                    <CharacterPreview
                      height="320px"
                      width="320px"
                      id={preview_map}
                    />
                  ) : (
                    <Box
                      height="320px"
                      width="320px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <Box color="label" italic>
                        <Icon name="user-slash" size={3} />
                        <br />
                        {t('ui.character.preference_importer.no_preview')}
                      </Box>
                    </Box>
                  )}
                </Stack.Item>
                {selectedChar && (
                  <Stack.Item mt={1}>
                    <Box bold fontSize="14px">
                      {selectedChar.name}
                    </Box>
                  </Stack.Item>
                )}
                <Stack.Item mt={0.5}>
                  <Dropdown
                    selected={preview_mode}
                    options={preview_options || []}
                    onSelected={(value: string) =>
                      act('set_preview_mode', { mode: value })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Stack vertical>
              {characters.length > 1 && (
                <Stack.Item>
                  <Section
                    title={t(
                      'ui.character.preference_importer.select_character',
                    )}
                  >
                    <Stack vertical>
                      {characters.map((character) => (
                        <Stack.Item key={character.index}>
                          <Button
                            fluid
                            selected={character.index === selected_character}
                            color={
                              character.index === selected_character
                                ? undefined
                                : 'transparent'
                            }
                            icon={
                              character.index === selected_character
                                ? 'check-circle'
                                : 'circle'
                            }
                            onClick={() =>
                              act('select_character', {
                                index: character.index,
                              })
                            }
                          >
                            {character.name}
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Section>
                </Stack.Item>
              )}

              <Stack.Item>
                <Section
                  title={t('ui.character.preference_importer.import_to_slot')}
                >
                  <Box
                    style={{
                      maxHeight: '250px',
                      overflowY: 'auto',
                      overflowX: 'hidden',
                      paddingRight: '4px',
                    }}
                  >
                    <Stack vertical>
                      {slots.map((slot) => (
                        <Stack.Item key={slot.index}>
                          <Button
                            fluid
                            selected={slot.index === target_slot}
                            icon={
                              slot.index === target_slot
                                ? 'check-circle'
                                : 'circle'
                            }
                            color={
                              slot.index === target_slot
                                ? undefined
                                : 'transparent'
                            }
                            onClick={() =>
                              act('select_slot', { slot: slot.index })
                            }
                          >
                            <Flex>
                              <Flex.Item grow>
                                {t('ui.character.preference_importer.slot')}{' '}
                                {slot.index}:
                                {slot.occupied ? (
                                  <b> {slot.name}</b>
                                ) : (
                                  <Box as="span" color="label" italic>
                                    {' '}
                                    {t(
                                      'ui.character.preference_importer.empty',
                                    )}
                                  </Box>
                                )}
                              </Flex.Item>
                              {slot.index === active_slot && (
                                <Flex.Item>
                                  <Box as="span" color="label" fontSize="10px">
                                    {t(
                                      'ui.character.preference_importer.active',
                                    )}
                                  </Box>
                                </Flex.Item>
                              )}
                            </Flex>
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Box>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section
                  title={t('ui.character.preference_importer.import_options')}
                >
                  <LabeledList>
                    <LabeledList.Item
                      label={t(
                        'ui.character.preference_importer.character_data',
                      )}
                      buttons={
                        <Button
                          icon={import_character ? 'toggle-on' : 'toggle-off'}
                          selected={!!import_character}
                          color={import_character ? 'good' : 'bad'}
                          onClick={() => act('toggle_character')}
                        >
                          {import_character
                            ? t('ui.character.preference_importer.import')
                            : t('ui.character.preference_importer.skip')}
                        </Button>
                      }
                    >
                      {t(
                        'ui.character.preference_importer.character_data_description',
                      )}
                    </LabeledList.Item>
                    {has_emote_panel ? (
                      <LabeledList.Item
                        label={t(
                          'ui.character.preference_importer.emote_panel',
                        )}
                        buttons={
                          <Button
                            icon={
                              import_emote_panel ? 'toggle-on' : 'toggle-off'
                            }
                            selected={!!import_emote_panel}
                            color={import_emote_panel ? 'good' : 'bad'}
                            onClick={() => act('toggle_emote_panel')}
                          >
                            {import_emote_panel
                              ? t('ui.character.preference_importer.import')
                              : t('ui.character.preference_importer.skip')}
                          </Button>
                        }
                      >
                        {t(
                          'ui.character.preference_importer.emote_panel_description',
                        )}
                      </LabeledList.Item>
                    ) : null}
                    {has_keybindings ? (
                      <LabeledList.Item
                        label={t(
                          'ui.character.preference_importer.keybindings',
                        )}
                        buttons={
                          <Button
                            icon={
                              import_keybindings ? 'toggle-on' : 'toggle-off'
                            }
                            selected={!!import_keybindings}
                            color={import_keybindings ? 'good' : 'bad'}
                            onClick={() => act('toggle_keybindings')}
                          >
                            {import_keybindings
                              ? t('ui.character.preference_importer.import')
                              : t('ui.character.preference_importer.skip')}
                          </Button>
                        }
                      >
                        {t('ui.character.preference_importer.found_in_file')}
                      </LabeledList.Item>
                    ) : null}
                    {has_game_prefs ? (
                      <LabeledList.Item
                        label={t(
                          'ui.character.preference_importer.game_preferences',
                        )}
                        buttons={
                          <Button
                            icon={
                              import_game_prefs ? 'toggle-on' : 'toggle-off'
                            }
                            selected={!!import_game_prefs}
                            color={import_game_prefs ? 'good' : 'bad'}
                            onClick={() => act('toggle_game_prefs')}
                          >
                            {import_game_prefs
                              ? t('ui.character.preference_importer.import')
                              : t('ui.character.preference_importer.skip')}
                          </Button>
                        }
                      >
                        {t('ui.character.preference_importer.found_in_file')}
                      </LabeledList.Item>
                    ) : null}
                  </LabeledList>
                </Section>
              </Stack.Item>

              {export_version < 2 && (
                <Stack.Item>
                  <Box
                    color="average"
                    fontSize="11px"
                    italic
                    textAlign="center"
                  >
                    <Icon name="info-circle" />{' '}
                    {t('ui.character.preference_importer.old_export_warning')}
                  </Box>
                </Stack.Item>
              )}

              <Divider />

              <Stack.Item>
                <Stack fill>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="times"
                      color="bad"
                      onClick={() => act('cancel')}
                    >
                      {t('ui.common.cancel')}
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="file-import"
                      color="good"
                      onClick={() => act('confirm_import')}
                    >
                      {t(
                        'ui.character.preference_importer.import_to_slot_action',
                      ).replace('{slot}', String(target_slot))}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
