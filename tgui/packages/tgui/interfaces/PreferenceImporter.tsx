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
  import_keybindings: BooleanLike;
  import_game_prefs: BooleanLike;
  import_character: BooleanLike;
  export_version: number;
  preview_map: string;
  preview_mode: string;
  preview_options: string[];
};

export function PreferenceImporter() {
  const { act, data } = useBackend<PreferenceImporterData>();

  const {
    characters,
    selected_character,
    slots,
    target_slot,
    active_slot,
    has_keybindings,
    has_game_prefs,
    import_keybindings,
    import_game_prefs,
    import_character,
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
      title="Import Character"
      width={1000}
      height={700}
    >
      <Window.Content>
        <Stack>
          <Stack.Item width="225px">
            <Section title="Preview" textAlign="center">
              <Stack vertical align="center" justify="center">
                <Stack.Item>
                  {preview_map ? (
                    <CharacterPreview
                      height="280px"
                      width="225px"
                      id={preview_map}
                    />
                  ) : (
                    <Box
                      height="280px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <Box color="label" italic>
                        <Icon name="user-slash" size={3} />
                        <br />
                        No preview available
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
                  <Section title="Select Character">
                    <Stack vertical>
                      {characters.map((character) => (
                        <Stack.Item key={character.index}>
                          <Button
                            fluid
                            selected={character.index === selected_character}
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
                <Section title="Import to Slot">
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
                                ? 'good'
                                : slot.occupied
                                  ? undefined
                                  : 'transparent'
                            }
                            onClick={() => act('select_slot', { slot: slot.index })}
                          >
                            <Flex>
                              <Flex.Item grow>
                                Slot {slot.index}:
                                {slot.occupied ? (
                                  <b> {slot.name}</b>
                                ) : (
                                  <Box as="span" color="label" italic>
                                    {' '}
                                    Empty
                                  </Box>
                                )}
                              </Flex.Item>
                              {slot.index === active_slot && (
                                <Flex.Item>
                                  <Box as="span" color="label" fontSize="10px">
                                    (active)
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
                <Section title="Import Options">
                  <LabeledList>
                    <LabeledList.Item
                      label="Character Data"
                      buttons={
                        <Button
                          icon={import_character ? 'toggle-on' : 'toggle-off'}
                          selected={!!import_character}
                          color={import_character ? 'good' : 'bad'}
                          onClick={() => act('toggle_character')}
                        >
                          {import_character ? 'Import' : 'Skip'}
                        </Button>
                      }
                    >
                      Appearance, species, name, quirks and slot data.
                    </LabeledList.Item>
                    {has_keybindings ? (
                      <LabeledList.Item
                        label="Keybindings"
                        buttons={
                          <Button
                            icon={import_keybindings ? 'toggle-on' : 'toggle-off'}
                            selected={!!import_keybindings}
                            color={import_keybindings ? 'good' : 'bad'}
                            onClick={() => act('toggle_keybindings')}
                          >
                            {import_keybindings ? 'Import' : 'Skip'}
                          </Button>
                        }
                      >
                        Found in file
                      </LabeledList.Item>
                    ) : null}
                    {has_game_prefs ? (
                      <LabeledList.Item
                        label="Game Preferences"
                        buttons={
                          <Button
                            icon={import_game_prefs ? 'toggle-on' : 'toggle-off'}
                            selected={!!import_game_prefs}
                            color={import_game_prefs ? 'good' : 'bad'}
                            onClick={() => act('toggle_game_prefs')}
                          >
                            {import_game_prefs ? 'Import' : 'Skip'}
                          </Button>
                        }
                      >
                        Found in file
                      </LabeledList.Item>
                    ) : null}
                  </LabeledList>
                </Section>
              </Stack.Item>

              {export_version < 2 && (
                <Stack.Item>
                  <Box color="average" fontSize="11px" italic textAlign="center">
                    <Icon name="info-circle" /> Old export format detected.
                    Re-export for keybindings and game settings.
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
                      Cancel
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button
                      fluid
                      icon="file-import"
                      color="good"
                      onClick={() => act('confirm_import')}
                    >
                      Import to Slot {target_slot}
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