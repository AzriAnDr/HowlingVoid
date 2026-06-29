import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type OutfitOption = {
  id: string;
  name: string;
  category: string;
};

type StaticData = {
  outfits: OutfitOption[];
  defaultOutfit: string;
};

type Data = {
  targetName?: string;
  targetKey?: string;
  spawnForSelf: BooleanLike;
  teleportMode: string;
  characterMode: string;
  outfitChoice: string;
  quirkMode: string;
  giveReturn: BooleanLike;
  canGiveReturn: BooleanLike;
  giveGodmode: BooleanLike;
  countAsAdmin: BooleanLike;
  giveNutritionSupply: BooleanLike;
};

type QuickICSpawnData = Data & StaticData;

export function QuickICSpawn() {
  const { act, data } = useBackend<QuickICSpawnData>();
  const {
    targetName = 'Unknown',
    targetKey,
    spawnForSelf,
    teleportMode,
    characterMode,
    outfitChoice,
    quirkMode,
    giveReturn,
    canGiveReturn,
    giveGodmode,
    countAsAdmin,
    giveNutritionSupply,
    outfits = [],
    defaultOutfit,
  } = data;

  // Backend can send outfits as an array or as an object keyed by id; normalize to array of safe objects.
  const outfitRawList = Array.isArray(outfits)
    ? outfits
    : Object.values(outfits || {});

  const normalizedCategory = (opt: OutfitOption | any) => {
    if (!opt || typeof opt !== 'object') {
      return 'Other';
    }
    const raw = (opt as OutfitOption).category || 'Other';
    return String(raw).trim() || 'Other';
  };

  const coerceOutfit = (opt: any, idx: number): OutfitOption => {
    if (opt && typeof opt === 'object') {
      const id = (opt as OutfitOption).id || `outfit-${idx}`;
      const name = (opt as OutfitOption).name || id;
      const category = (opt as OutfitOption).category || 'Other';
      return { id, name, category };
    }
    const id = String(opt ?? `outfit-${idx}`);
    return { id, name: id, category: 'Other' };
  };

  const outfitArray: OutfitOption[] = (outfitRawList || []).map(coerceOutfit);
  const categories = Array.from(
    new Set((outfitArray || []).map((opt) => normalizedCategory(opt))),
  );
  const initialCategory =
    normalizedCategory(
      outfitArray.find((opt) => opt.id === outfitChoice) ||
        ({} as OutfitOption),
    ) ||
    normalizedCategory(
      outfitArray.find((opt) => opt.id === defaultOutfit) ||
        ({} as OutfitOption),
    ) ||
    categories[0] ||
    '';

  const [activeCategory, setActiveCategory] = useLocalState(
    'quickICSpawnCategory',
    initialCategory,
  );

  const resolvedCategory = categories.includes(activeCategory)
    ? activeCategory
    : categories[0] || '';

  const visibleOutfits = (outfitArray || []).filter(
    (opt) => !resolvedCategory || normalizedCategory(opt) === resolvedCategory,
  );
  const outfitList = visibleOutfits.length ? visibleOutfits : outfitArray;

  const [searchText, setSearchText] = useLocalState('quickICSpawnSearch', '');
  const trimmedSearch = searchText.trim().toLowerCase();
  const filteredOutfits = trimmedSearch
    ? outfitList.filter((opt) =>
        opt.name?.toLowerCase().includes(trimmedSearch),
      )
    : outfitList;

  return (
    <Window title="IC Quick Spawn" width={680} height={680} theme="admin">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Target">
              <LabeledList>
                <LabeledList.Item label="Mob">{targetName}</LabeledList.Item>
                {!!targetKey && (
                  <LabeledList.Item label="Ckey">{targetKey}</LabeledList.Item>
                )}
                <LabeledList.Item label="For">
                  {spawnForSelf ? 'Yourself' : 'Another player'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Spawn Settings">
              <LabeledList>
                <LabeledList.Item label="Arrival">
                  <Stack wrap>
                    <Stack.Item>
                      <Button
                        selected={teleportMode === 'Bluespace'}
                        onClick={() =>
                          act('setTeleport', { teleport: 'Bluespace' })
                        }
                      >
                        Bluespace
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        selected={teleportMode === 'Pod'}
                        onClick={() => act('setTeleport', { teleport: 'Pod' })}
                      >
                        Pod
                      </Button>
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>

                <LabeledList.Item label="Character">
                  <Stack wrap>
                    <Stack.Item>
                      <Button
                        selected={characterMode === 'Selected Character'}
                        onClick={() =>
                          act('setCharacterMode', {
                            characterMode: 'Selected Character',
                          })
                        }
                      >
                        Selected character
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        selected={characterMode === 'Randomly Created'}
                        onClick={() =>
                          act('setCharacterMode', {
                            characterMode: 'Randomly Created',
                          })
                        }
                      >
                        Random
                      </Button>
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>

                <LabeledList.Item label="Quirks & Loadout">
                  <Stack wrap>
                    <Stack.Item>
                      <Button
                        disabled={characterMode !== 'Selected Character'}
                        selected={quirkMode === 'Quirks & Loadout'}
                        onClick={() =>
                          act('setQuirkMode', { quirkMode: 'Quirks & Loadout' })
                        }
                      >
                        Quirks + Loadout
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={characterMode !== 'Selected Character'}
                        selected={quirkMode === 'Quirks Only'}
                        onClick={() =>
                          act('setQuirkMode', { quirkMode: 'Quirks Only' })
                        }
                      >
                        Quirks Only
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={characterMode !== 'Selected Character'}
                        selected={quirkMode === 'Loadout Only'}
                        onClick={() =>
                          act('setQuirkMode', { quirkMode: 'Loadout Only' })
                        }
                      >
                        Loadout Only
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        selected={quirkMode === 'Neither'}
                        onClick={() =>
                          act('setQuirkMode', { quirkMode: 'Neither' })
                        }
                      >
                        None
                      </Button>
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Spawn Modifiers">
              <Stack wrap>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!giveGodmode}
                    content="Godmode"
                    tooltip="Makes the spawned character invulnerable"
                    onClick={() =>
                      act('setGodmode', { giveGodmode: !giveGodmode })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!giveReturn}
                    content="Return Spell"
                    tooltip="Gives a spell to return back as ghost"
                    onClick={() =>
                      act('setReturn', { giveReturn: !giveReturn })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!countAsAdmin}
                    content="Count as Admin"
                    tooltip="Allows access to ghost role polls even while alive"
                    onClick={() =>
                      act('setCountAsAdmin', { countAsAdmin: !countAsAdmin })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!giveNutritionSupply}
                    content="Nutrition Supply"
                    tooltip="Grants a button to restore hunger (like Ghost Cafe visitors)"
                    onClick={() =>
                      act('setNutritionSupply', {
                        giveNutritionSupply: !giveNutritionSupply,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section title="Outfit">
              {!outfitArray.length && (
                <NoticeBox color="bad">No outfits available.</NoticeBox>
              )}
              {!!outfitArray.length && (
                <Stack vertical fill>
                  <Stack.Item>
                    <Tabs>
                      {categories.map((category) => (
                        <Tabs.Tab
                          key={category}
                          selected={resolvedCategory === category}
                          onClick={() => setActiveCategory(category)}
                        >
                          {category}
                        </Tabs.Tab>
                      ))}
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Stack fill>
                      <Stack.Item grow basis="100%">
                        <Section
                          maxHeight="300px"
                          minHeight="160px"
                          title={`Selected: ${
                            outfitArray.find((opt) => opt.id === outfitChoice)
                              ?.name || 'None'
                          }`}
                          buttons={
                            <Input
                              placeholder="Search outfit..."
                              value={searchText}
                              onChange={setSearchText}
                              width="160px"
                            />
                          }
                        >
                          {!filteredOutfits.length && (
                            <Box color="label">
                              {trimmedSearch
                                ? 'No outfits match this search.'
                                : 'No outfits in this category.'}
                            </Box>
                          )}
                          <Box
                            style={{
                              maxHeight: '260px',
                              minHeight: '120px',
                              overflowY: 'scroll',
                            }}
                          >
                            <Stack vertical>
                              {filteredOutfits.map((opt) => (
                                <Stack.Item key={opt.id}>
                                  <Button
                                    fluid
                                    selected={opt.id === outfitChoice}
                                    onClick={() =>
                                      act('setOutfit', { outfit: opt.id })
                                    }
                                  >
                                    {opt.name}
                                  </Button>
                                </Stack.Item>
                              ))}
                            </Stack>
                          </Box>
                        </Section>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <Stack justify="space-between">
                <Stack.Item>
                  <Button icon="times" onClick={() => act('cancel')}>
                    Cancel
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="check"
                    color="good"
                    disabled={!outfitChoice}
                    onClick={() => act('submit')}
                  >
                    Spawn
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
