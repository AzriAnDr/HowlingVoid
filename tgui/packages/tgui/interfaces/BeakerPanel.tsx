import { useState } from 'react';
import {
  Button,
  Dropdown,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type typePath = string;

type Reagent = {
  id: typePath;
  text: string;
};

type ContainerType = {
  id: typePath;
  text: string;
  volume: number;
};

type Data = {
  reagents: Reagent[];
  containers: ContainerType[];
};

type Container = {
  type: typePath;
  reagents: Record<typePath, number>;
};

function makeContainerState(default_type: ContainerType) {
  return useState<Container>({
    type: default_type.id,
    reagents: {},
  });
}

function removeContainerReagent(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
) {
  const newReagents = { ...container.reagents };
  delete newReagents[reagent];
  setContainer({ ...container, reagents: newReagents });
}

function setContainerReagentVolume(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
  volume: number = 10,
) {
  const newReagents = { ...container.reagents };
  newReagents[reagent] = volume;
  setContainer({ ...container, reagents: newReagents });
}

function containerToSpawnInfo(container: Container) {
  return {
    container: container.type,
    reagents: container.reagents,
  };
}

function readableContainerType(container_type: ContainerType) {
  return capitalizeFirst(`${container_type.text} (${container_type.volume}u)`);
}

function readableReagentType(reagent: Reagent) {
  return capitalizeFirst(reagent.text);
}

function grenadeCheck(containers: Container[]) {
  return containers.every((container) => container.type.includes('beaker'));
}

type ContainerProps = {
  container: Container;
  number: number;
  updateContainer: (container: Container) => void;
  reagents: Reagent[];
  containers: ContainerType[];
};

const ContainerSection = (props: ContainerProps) => {
  const { container, number, updateContainer, reagents, containers } = props;
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();

  const [setAddingReagent, setSetAddingReagent] = useState<string>(
    reagents[0].id,
  );
  const [setAddingReagentVolume, setSetAddingReagentVolume] =
    useState<number>(50);

  return (
    <Section
      fill
      title={`${t('ui.common.container')} ${number}`}
      buttons={
        <Button
          icon="cog"
          onClick={() =>
            act('spawn', { spawn_info: containerToSpawnInfo(container) })
          }
        >
          {t('ui.common.spawn')}
        </Button>
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <Dropdown
            fluid
            options={containers.map((container) => ({
              displayText: readableContainerType(container),
              value: container.id,
            }))}
            placeholder={t('ui.beaker_panel.select_container_type')}
            selected={container.type}
            displayText={readableContainerType(
              containers.find((c) => c.id === container.type)!,
            )}
            onSelected={(value) => {
              updateContainer({ ...container, type: value });
            }}
          />
        </Stack.Item>
        {Object.keys(container.reagents).map((reagent) => (
          <Stack.Item key={reagent}>
            <Stack>
              <Stack.Item grow>
                <Button disabled fluid>
                  {reagents.find((r) => r.id === reagent)?.text}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  fluid
                  step={1}
                  minValue={0}
                  maxValue={1000}
                  unit="u"
                  value={container.reagents[reagent]}
                  onChange={(value) => {
                    setContainerReagentVolume(
                      container,
                      updateContainer,
                      reagent,
                      value,
                    );
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="red"
                  icon="minus"
                  onClick={() => {
                    removeContainerReagent(container, updateContainer, reagent);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Dropdown
                fluid
                options={reagents.map((reagent) => ({
                  displayText: readableReagentType(reagent),
                  value: reagent.id,
                }))}
                placeholder={t('ui.beaker_panel.add_reagent')}
                selected={setAddingReagent}
                displayText={readableReagentType(
                  reagents.find((r) => r.id === setAddingReagent)!,
                )}
                onSelected={(value) => {
                  setSetAddingReagent(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                fluid
                step={1}
                minValue={0}
                maxValue={1000}
                unit="u"
                value={setAddingReagentVolume}
                onChange={(value) => {
                  setSetAddingReagentVolume(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="green"
                icon="plus"
                onClick={() => {
                  setContainerReagentVolume(
                    container,
                    updateContainer,
                    setAddingReagent,
                    setAddingReagentVolume,
                  );
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const BeakerPanel = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { reagents, containers } = data;

  const [container_one, setContainerOne] = makeContainerState(containers[0]);
  const [container_two, setContainerTwo] = makeContainerState(containers[0]);
  const [grenadeTimer, setGrenadeTimer] = useState<number>(5.0);

  const reagentsSorted = reagents.sort((a, b) => (a.text < b.text ? -1 : 1));
  const containersSorted = containers.sort((a, b) =>
    readableContainerType(a) < readableContainerType(b) ? -1 : 1,
  );

  return (
    <Window
      title={t('ui.beaker_panel.spawn_reagent_container')}
      width={750}
      height={400}
      theme="admin"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Button
                    tooltip={
                      grenadeCheck([container_one, container_two])
                        ? ''
                        : t('ui.beaker_panel.both_containers_must_be_beakers')
                    }
                    disabled={!grenadeCheck([container_one, container_two])}
                    onClick={() =>
                      act('spawngrenade', {
                        spawn_info: [
                          containerToSpawnInfo(container_one),
                          containerToSpawnInfo(container_two),
                        ],
                        grenade_info: {
                          detonation_type: 'normal', // to be implemented
                          detonation_timer: grenadeTimer,
                        },
                      })
                    }
                  >
                    {t('ui.beaker_panel.spawn_grenade')}
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  {t('ui.beaker_panel.timer')}:&nbsp;
                  <NumberInput
                    step={0.1}
                    minValue={1.0}
                    maxValue={10.0}
                    unit={t('ui.common.seconds_lower')}
                    value={grenadeTimer}
                    onChange={(value) => {
                      setGrenadeTimer(value);
                    }}
                  />
                </Stack.Item>
                <Stack.Item fontSize={0.9} align="center">
                  <i>
                    {t('ui.beaker_panel.spawned_containers_will_grow')}
                  </i>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <ContainerSection
                  container={container_one}
                  number={1}
                  updateContainer={setContainerOne}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
              <Stack.Item grow>
                <ContainerSection
                  container={container_two}
                  number={2}
                  updateContainer={setContainerTwo}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
