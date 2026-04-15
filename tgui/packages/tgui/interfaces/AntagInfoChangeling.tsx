import { useState } from 'react';
import {
  Button,
  Dimmer,
  Dropdown,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Rules } from './AntagInfoRules'; // NOVA EDIT ADDITION
import { usePreferencesLocalization } from './localization';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const hivemindstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

const fallenstyle = {
  color: 'black',
  fontWeight: 'bold',
};

type Memory = {
  name: string;
  story: string;
};

type Info = {
  true_name: string;
  hive_name: string;
  stolen_antag_info: string;
  memories: Memory[];
  objectives: Objective[];
  can_change_objective: BooleanLike;
  absorbed_dna: number;
};

// NOVA EDIT change height from 750 to 900
export const AntagInfoChangeling = (props) => {
  return (
    <Window width={720} height={900}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item maxHeight={16}>
            <IntroductionSection />
          </Stack.Item>
          {/* NOVA EDIT ADDITION START */}
          <Stack.Item>
            <Rules />
          </Stack.Item>
          {/* NOVA EDIT ADDITION END */}
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
          <BetrayalWarning />
          <Stack.Item grow={3}>
            <Stack fill>
              <Stack.Item grow>
                <MemoriesSection />
              </Stack.Item>
              <Stack.Item grow>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const {
    true_name,
    hive_name,
    objectives,
    can_change_objective,
    absorbed_dna,
  } = data;
  return (
    <Section
      fill
      title={t('ui.antaginfochangeling.intro')}
      style={{ overflowY: 'auto' }}
      buttons={
        <Button
          icon="dna"
          tooltipPosition="left"
          tooltip="Absorbed DNA"
          color="purple"
        >
          {absorbed_dna}
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          You are {true_name} from the
          <span style={hivestyle}> {hive_name}</span>.
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout
            objectives={objectives}
            objectiveFollowup={
              <ReplaceObjectivesButton
                can_change_objective={can_change_objective}
                button_title="Evolve New Directives"
                button_colour={'green'}
              />
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { true_name } = data;
  return (
    <Section fill title={t('ui.antaginfochangeling.abilities')}>
      <Stack fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Your
              <span style={absorbstyle}>&ensp;{t('ui.antaginfochangeling.absorb_dna')}</span> ability allows
              you to steal the DNA and memories of a victim. The
              <span style={absorbstyle}>&ensp;{t('ui.antaginfochangeling.extract_dna_sting')}</span> ability
              also steals the DNA of a victim, and is undetectable, but does not
              grant you their memories or speech patterns.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              Your
              <span style={revivestyle}>&ensp;{t('ui.antaginfochangeling.reviving_stasis')}</span> ability
              allows you to revive. It means nothing short of a complete body
              destruction can stop you! Obviously, this is loud and so should
              not be done in front of people you are not planning on silencing.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Your
              <span style={transformstyle}>&ensp;{t('ui.antaginfochangeling.transform')}</span> ability allows
              you to change into the form of those you have collected DNA from,
              lethally and nonlethally. It will also mimic (NOT REAL CLOTHING)
              the clothing they were wearing for every slot you have open.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              The
              <span style={storestyle}>&ensp;{t('ui.antaginfochangeling.cellular_emporium')}</span> is where
              you purchase more abilities beyond your starting kit. You have 10
              genetic points to spend on abilities and you are able to readapt
              after absorbing a body, refunding your points for different kits.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              All abilities require using{' '}
              <span style={hivemindstyle}>chemicals</span>, you can see how much
              you have with the HUD on the left side of the screen. You may also
              hover your cursor over it to see the maximum amount of chemicals
              you can hold. This number can increase by
              <span style={absorbstyle}>&ensp;absorbing</span> other
              Changelings.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              All Changelings, regardless of origin, are linked together by the{' '}
              <span style={hivemindstyle}>{t('ui.antaginfochangeling.hivemind_2')}</span>. You may communicate
              to other Changelings under your mental alias,{' '}
              <span style={hivemindstyle}>{true_name}</span>, by starting a
              message with <span style={hivemindstyle}>{t('ui.antaginfochangeling.hive_chat_prefix')}</span>. Work together,
              and you will bring the station to new heights of terror.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BetrayalWarning = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  return (
    <NoticeBox danger>
      Other Changelings are strong allies, but some Changelings may betray you.
      Changelings grow in power greatly by absorbing their kind, and getting
      absorbed by another Changeling will leave you as a{' '}
      <span style={fallenstyle}>{t('ui.antaginfochangeling.fallen_changeling')}</span>. There is no greater
      humiliation.
    </NoticeBox>
  );
};

const MemoriesSection = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { memories } = data;
  const [selectedMemory, setSelectedMemory] = useState(
    (!!memories && memories[0]) || null,
  );
  const memoryMap = {};
  for (const index in memories) {
    const memory = memories[index];
    memoryMap[memory.name] = memory;
  }

  return (
    <Section
      fill
      scrollable={!!memories && !!memories.length}
      title={t('ui.antaginfochangeling.stolen_memories')}
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={`
            Absorbing targets allows
            you to collect their memories. They should
            help you impersonate your target!
          `}
        />
      }
    >
      {(!!memories && !memories.length && (
        <Dimmer fontSize="20px">{t('ui.antaginfochangeling.absorb_a_victim_first')}</Dimmer>
      )) || (
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              selected={selectedMemory?.name}
              options={memories.map((memory) => {
                return memory.name;
              })}
              onSelected={(selected) => setSelectedMemory(memoryMap[selected])}
            />
          </Stack.Item>
          <Stack.Item>{!!selectedMemory && selectedMemory.story}</Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const VictimPatternsSection = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { stolen_antag_info } = data;
  return (
    <Section
      fill
      scrollable={!!stolen_antag_info}
      title={t('ui.antaginfochangeling.additional_stolen_information')}
    >
      {(!!stolen_antag_info && stolen_antag_info) || (
        <Dimmer fontSize="20px">{t('ui.antaginfochangeling.absorb_a_victim_first')}</Dimmer>
      )}
    </Section>
  );
};
