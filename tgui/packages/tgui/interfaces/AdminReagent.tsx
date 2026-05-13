import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ReagentEntry = {
  id: string;
  name?: string | null;
};

type ContainerEntry = {
  id: string;
  name?: string | null;
  volume?: number | null;
};

type MixtureEntry = {
  key: number;
  reagent: string;
  amount: number;
};

type AdminReagentData = {
  reagents: ReagentEntry[];
  containers: ContainerEntry[];
};

const resolveName = (value?: string | null) => {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length ? trimmed : null;
};

const formatVolume = (value: number) =>
  value.toLocaleString(undefined, {
    maximumFractionDigits: 2,
  });

export const AdminReagent = () => {
  const { act, data } = useBackend<AdminReagentData>();
  const { reagents = [], containers = [] } = data;

  const reagentMap = useMemo(() => {
    const map = new Map<string, ReagentEntry>();
    reagents.forEach((entry) => {
      if (entry?.id) {
        map.set(entry.id, entry);
      }
    });
    return map;
  }, [reagents]);

  const containerMap = useMemo(() => {
    const map = new Map<string, ContainerEntry>();
    containers.forEach((entry) => {
      if (entry?.id) {
        map.set(entry.id, entry);
      }
    });
    return map;
  }, [containers]);

  const [containerSearchText, setContainerSearchText] = useState('');
  const containerSearch = useMemo(
    () =>
      createSearch(
        containerSearchText,
        (entry: ContainerEntry) =>
          `${entry.id} ${resolveName(entry.name) ?? ''}`,
      ),
    [containerSearchText],
  );

  const filteredContainers = useMemo(
    () => containers.filter((entry) => entry?.id && containerSearch(entry)),
    [containers, containerSearch],
  );

  const [selectedContainer, setSelectedContainer] = useState(
    containers[0]?.id ?? '',
  );
  useEffect(() => {
    if (containers.some((entry) => entry?.id === selectedContainer)) {
      return;
    }
    const fallback = containers[0]?.id ?? '';
    if (fallback !== selectedContainer) {
      setSelectedContainer(fallback);
    }
  }, [containers, selectedContainer]);

  const [searchText, setSearchText] = useState('');
  const search = useMemo(
    () =>
      createSearch(
        searchText,
        (entry: ReagentEntry) => `${entry.id} ${resolveName(entry.name) ?? ''}`,
      ),
    [searchText],
  );

  const filteredReagents = useMemo(
    () => reagents.filter((entry) => entry?.id && search(entry)),
    [reagents, search],
  );

  const [additionAmount, setAdditionAmount] = useState(10);
  const [mixture, setMixture] = useState<MixtureEntry[]>([]);
  const [nextKey, setNextKey] = useState(1);

  const handleAdditionAmountChange = (value: number | null) => {
    const numericValue = Number(value);
    if (!Number.isFinite(numericValue)) {
      return;
    }
    setAdditionAmount(Math.max(0, numericValue));
  };

  const handleAddReagent = (reagentId: string) => {
    const entry = reagentMap.get(reagentId);
    if (!entry) {
      return;
    }
    const amount = Math.max(0, additionAmount);
    if (!amount) {
      return;
    }

    let addedNew = false;
    const keyForEntry = nextKey;
    setMixture((previous) => {
      const existingIndex = previous.findIndex(
        (item) => item.reagent === reagentId,
      );
      if (existingIndex >= 0) {
        const next = [...previous];
        next[existingIndex] = {
          ...next[existingIndex],
          amount: next[existingIndex].amount + amount,
        };
        return next;
      }
      addedNew = true;
      return [
        ...previous,
        {
          key: keyForEntry,
          reagent: reagentId,
          amount,
        },
      ];
    });
    if (addedNew) {
      setNextKey((value) => value + 1);
    }
  };

  const handleUpdateEntry = (entryKey: number, value: number | null) => {
    const numericValue = Number(value);
    if (!Number.isFinite(numericValue)) {
      return;
    }
    const amount = Math.max(0, numericValue);
    setMixture((previous) =>
      previous.map((entry) =>
        entry.key === entryKey ? { ...entry, amount } : entry,
      ),
    );
  };

  const handleRemoveEntry = (entryKey: number) => {
    setMixture((previous) =>
      previous.filter((entry) => entry.key !== entryKey),
    );
  };

  const handleClearMixture = () => {
    setMixture([]);
  };

  const validMixture = mixture.filter((entry) => entry.amount > 0);
  const totalVolume = validMixture.reduce(
    (sum, entry) => sum + entry.amount,
    0,
  );

  const containerEntry = selectedContainer
    ? containerMap.get(selectedContainer)
    : undefined;
  const containerName = resolveName(containerEntry?.name);
  const containerVolume =
    typeof containerEntry?.volume === 'number' ? containerEntry.volume : null;
  const exceedsVolume =
    containerVolume !== null && totalVolume > containerVolume;

  const spawnDisabled = !selectedContainer || !validMixture.length;
  let spawnTooltip: string | undefined;
  if (!selectedContainer) {
    spawnTooltip = 'Select a container type.';
  } else if (!validMixture.length) {
    spawnTooltip = 'Add at least one reagent with a positive amount.';
  }

  const handleSpawn = () => {
    if (spawnDisabled) {
      return;
    }

    const payload = validMixture.map((entry) => ({
      path: entry.reagent,
      amount: entry.amount,
    }));

    act('spawn', {
      container: selectedContainer,
      reagents: JSON.stringify(payload),
    });
  };

  const containerOptions = useMemo(() => {
    const options = filteredContainers.map((entry) => ({
      value: entry.id,
      displayText: resolveName(entry.name) ?? entry.id,
    }));

    if (
      selectedContainer &&
      !options.some((option) => option.value === selectedContainer)
    ) {
      const selectedEntry = containerMap.get(selectedContainer);
      const displayName =
        resolveName(selectedEntry?.name) ??
        selectedEntry?.id ??
        selectedContainer;
      options.unshift({
        value: selectedContainer,
        displayText: `${displayName} (selected)`,
      });
    }

    return options;
  }, [filteredContainers, selectedContainer, containerMap]);

  return (
    <Window title="Create Reagent" theme="admin" width={640} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title={`Container (${filteredContainers.length}/${containers.length})`}
            >
              {containers.length ? (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Search">
                      <Input
                        placeholder="Name or path..."
                        value={containerSearchText}
                        onChange={setContainerSearchText}
                        width="100%"
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Container Type">
                      <Dropdown
                        selected={selectedContainer}
                        displayText={
                          containerName ?? selectedContainer ?? 'Select...'
                        }
                        placeholder="Select container..."
                        options={containerOptions}
                        width="100%"
                        onSelected={(value) => setSelectedContainer(value)}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Default Capacity">
                      {containerVolume !== null ? (
                        <>{formatVolume(containerVolume)} u</>
                      ) : (
                        <Box color="label">Varies by subtype</Box>
                      )}
                    </LabeledList.Item>
                    <LabeledList.Item label="Type Path">
                      {selectedContainer ? (
                        <Box style={{ wordBreak: 'break-all' }}>
                          {selectedContainer}
                        </Box>
                      ) : (
                        <Box color="label">No container selected</Box>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                  {containerSearchText.trim().length > 0 &&
                    !filteredContainers.length && (
                      <NoticeBox info>
                        No containers match the current search.
                      </NoticeBox>
                    )}
                </>
              ) : (
                <NoticeBox danger>
                  No reagent containers are available to spawn.
                </NoticeBox>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis="50%">
                <Section
                  title={`Reagents (${filteredReagents.length}/${reagents.length})`}
                  fill
                  scrollable
                >
                  <LabeledList>
                    <LabeledList.Item label="Search">
                      <Input
                        placeholder="Name or path..."
                        value={searchText}
                        onChange={setSearchText}
                        width="100%"
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Units per click">
                      <NumberInput
                        value={additionAmount}
                        minValue={0}
                        maxValue={1000000}
                        step={1}
                        width="90px"
                        onChange={handleAdditionAmountChange}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                  <Box color="label" mt={1} mb={1}>
                    Click a reagent to add it to the mixture.
                  </Box>
                  {filteredReagents.length ? (
                    <VirtualList>
                      {filteredReagents.map((entry) => {
                        const name = resolveName(entry.name);
                        return (
                          <Button
                            key={entry.id}
                            fluid
                            onClick={() => handleAddReagent(entry.id)}
                            tooltip={`Add ${formatVolume(additionAmount)} units`}
                          >
                            <Box
                              style={{
                                width: '100%',
                                textAlign: 'left',
                                display: 'flex',
                                flexDirection: 'column',
                                gap: '0.25rem',
                              }}
                            >
                              <Box style={{ fontWeight: 600 }}>
                                {name ?? entry.id}
                              </Box>
                              <Box
                                color="label"
                                style={{
                                  fontFamily: 'monospace',
                                  fontSize: '0.8em',
                                  wordBreak: 'break-all',
                                }}
                              >
                                {entry.id}
                              </Box>
                            </Box>
                          </Button>
                        );
                      })}
                    </VirtualList>
                  ) : (
                    <NoticeBox info>No reagents match the search.</NoticeBox>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item grow basis="50%">
                <Section
                  title={`Mixture (${mixture.length})`}
                  fill
                  scrollable
                  buttons={
                    <Button
                      icon="trash"
                      tooltip="Clear mixture"
                      disabled={!mixture.length}
                      onClick={handleClearMixture}
                    />
                  }
                >
                  {mixture.length ? (
                    <Stack vertical>
                      {mixture.map((entry) => {
                        const reagentEntry = reagentMap.get(entry.reagent);
                        const name = resolveName(reagentEntry?.name);
                        return (
                          <Stack.Item key={entry.key} mb={0.75}>
                            <Stack align="center" justify="space-between">
                              <Stack.Item grow>
                                <Box style={{ fontWeight: 600 }}>
                                  {name ?? entry.reagent}
                                </Box>
                                <Box
                                  color="label"
                                  style={{
                                    fontFamily: 'monospace',
                                    fontSize: '0.8em',
                                    wordBreak: 'break-all',
                                  }}
                                >
                                  {entry.reagent}
                                </Box>
                              </Stack.Item>
                              <Stack.Item>
                                <NumberInput
                                  value={entry.amount}
                                  minValue={0}
                                  maxValue={1000000}
                                  step={1}
                                  width="90px"
                                  onChange={(value) =>
                                    handleUpdateEntry(entry.key, value)
                                  }
                                />
                              </Stack.Item>
                              <Stack.Item>
                                <Button
                                  icon="trash"
                                  color="bad"
                                  tooltip="Remove this reagent"
                                  onClick={() => handleRemoveEntry(entry.key)}
                                />
                              </Stack.Item>
                            </Stack>
                          </Stack.Item>
                        );
                      })}
                    </Stack>
                  ) : (
                    <NoticeBox info>
                      Add reagents from the list to build a mixture.
                    </NoticeBox>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section title="Summary & Spawn">
              <LabeledList>
                <LabeledList.Item label="Reagent Entries">
                  {validMixture.length}
                </LabeledList.Item>
                <LabeledList.Item label="Total Volume">
                  {formatVolume(totalVolume)} u
                </LabeledList.Item>
                <LabeledList.Item label="Default Capacity">
                  {containerVolume !== null ? (
                    <>{formatVolume(containerVolume)} u</>
                  ) : (
                    <Box color="label">Varies by subtype</Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
              {exceedsVolume && (
                <NoticeBox info>
                  Mixture exceeds the container default capacity. The container
                  will expand to fit.
                </NoticeBox>
              )}
              <Stack justify="flex-end" mt={1}>
                <Stack.Item>
                  <Button
                    icon="flask"
                    content="Create Container"
                    disabled={spawnDisabled}
                    tooltip={spawnTooltip}
                    onClick={handleSpawn}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
