import {
  Box,
  Collapsible,
  Divider,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { Rules } from './AntagInfoRules'; // NOVA EDIT ADDITION
import type { Objective } from './common/Objectives';

type Data = {
  color: string;
  description: string;
  effects: string;
  name: string;
  objectives: Objective[];
};

const BLOB_COLOR = '#556b2f';

export const AntagInfoBlob = (props) => {
  return (
    <Window width={400} height={550}>
      <Window.Content>
        <Section fill scrollable>
          <Overview />
          <Divider />
          <Basics />
          <Structures />
          <Minions />
          <ObjectiveDisplay />
          <Rules /* NOVA EDIT ADDITION */ />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Overview = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { color, description, effects, name } = data;

  if (!name) {
    return (
      <Stack vertical>
        <Stack.Item bold fontSize="14px" textColor={BLOB_COLOR}>
          {t('ui.antaginfoblob.hidden_form_title')}
        </Stack.Item>
        <Stack.Item>
          {t('ui.antaginfoblob.hidden_form_desc')}
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack vertical>
      <Stack.Item bold fontSize="24px" textColor={BLOB_COLOR}>
        {t('ui.antaginfoblob.you_are_the_blob')}
      </Stack.Item>
      <Stack.Item>{t('ui.antaginfoblob.overmind_control')}</Stack.Item>
      <Stack.Item>
        {t('ui.antaginfoblob.blob_reagent_is')}{' '}
        <span
          style={{
            color,
          }}
        >
          {name}
        </span>
      </Stack.Item>
      <Stack.Item>
        The{' '}
        <span
          style={{
            color,
          }}
        >
          {name}
        </span>{' '}
        reagent {description}
      </Stack.Item>
      {effects && (
        <Stack.Item>
          The{' '}
          <span
            style={{
              color,
            }}
          >
            {name}
          </span>{' '}
          reagent {effects}
        </Stack.Item>
      )}
    </Stack>
  );
};

const Basics = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Collapsible title={t('ui.antaginfoblob.the_basics')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.antaginfoblob.attacking')}>
          You can expand, which will attack people, damage objects, or place a
          Normal Blob if the tile is clear.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.placement')}>
          You will be able to manually place your blob core by pressing the
          Place Blob Core button in the bottom right corner of the screen.{' '}
          <br />
          <br />
          If you are the blob infection, you can place the core where you are
          standing by pressing the pop button on the top left corner of the
          screen.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.hud')}>
          In addition to the buttons on your HUD, there are a few click
          shortcuts to speed up expansion and defense.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.shortcuts')}>
          Click = Expand Blob <br />
          Middle Mouse Click = Rally Spores <br />
          Ctrl Click = Create Shield Blob <br />
          Alt Click = Remove Blob <br />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.comms')}>
          Attempting to talk will send a message to all other overminds,
          allowing you to coordinate with them.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Minions = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Collapsible title={t('ui.antaginfoblob.minions')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.antaginfoblob.blobbernauts')}>
          This unit can be produced from factories for a cost. They are hard to
          kill, powerful, and moderately smart. The factory used to create one
          will become fragile and briefly unable to produce spores.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.spores')}>
          Produced automatically from factories, these are weak, but can be
          rallied to attack enemies. They will also attack enemies near the
          factory and attempt to zombify corpses.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Structures = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Collapsible title={t('ui.antaginfoblob.structures')}>
      <Box>
        Normal Blobs will expand your reach and can be upgraded into special
        blobs that perform certain functions. Bear in mind that expanding into
        space has an 80% chance of failing!
      </Box>
      <br />
      <Box>{t('ui.antaginfoblob.upgrade_blob_types')}</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label={t('ui.antaginfoblob.strong_blobs')}>
          Strong blobs are expensive but take more damage. In additon, they are
          fireproof and can block air, use these to protect yourself from
          station fires.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.reflective_blobs')}>
          Upgrading strong blobs creates reflective blobs, capable of reflecting
          most projectiles at the cost of the strong blob&apos;s extra health.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.resource_blobs')}>
          Blobs which produce more resources for you, build as many of these as
          possible to consume the station. This type of blob must be placed near
          node blobs or your core to work.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.factory_blobs')}>
          Blobs that spawn blob spores which will attack nearby enemies. This
          type of blob must be placed near node blobs or your core to work.
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.antaginfoblob.node_blobs')}>
          Blobs which grow, like the core. Like the core it can activate
          resource and factory blobs.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const ObjectiveDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { color, objectives } = data;

  return (
    <Collapsible title={t('ui.antaginfoblob.objectives')}>
      <LabeledList>
        {objectives.map(({ explanation }, index) => (
          <LabeledList.Item
            color={color ?? 'white'}
            key={index}
            label={(index + 1).toString()}
          >
            {explanation}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Collapsible>
  );
};
