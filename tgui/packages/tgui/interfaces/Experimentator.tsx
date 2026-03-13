import {
  Button,
  Icon,
  Image,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  hasItem: BooleanLike;
  isOnCooldown: BooleanLike;
  isServerConnected: BooleanLike;
  loadedItem: Item;
};

type Item = {
  name: string;
  icon: string;
  isRelic: BooleanLike;
  associatedNodes: Node[];
};

type Node = {
  name: string;
  isUnlocked: BooleanLike;
};

export const Experimentator = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { hasItem, isOnCooldown, isServerConnected, loadedItem } = data;

  return (
    <Window width={450} height={325} title={t('ui.experimentator.e_x_p_e_r_i_mentor')}>
      <Window.Content>
        {isServerConnected ? (
          hasItem && loadedItem ? (
            <ExperimentScreen
              item={loadedItem}
              isOnCooldown={isOnCooldown}
              onEject={() => act('eject')}
              onExperiment={(id) => act('experiment', { id: id })}
            />
          ) : (
            <NoticeBox danger textAlign="center">
              {t('ui.experimentator.no_item_present_insert_one')}
            </NoticeBox>
          )
        ) : (
          <NoticeBox danger textAlign="center">
            {t('ui.experimentator.not_connected_sync_server')}
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

enum Experiment {
  Poke = 'Poke',
  Irradiate = 'Irradiate',
  Gas = 'Gas',
  Heat = 'Heat',
  Cold = 'Freeze',
  Obliterate = 'Obliterate',
}

const EXPERIMENT2ICON = {
  Poke: 'hand',
  Irradiate: 'radiation',
  Gas: 'cloud',
  Heat: 'fire',
  Cold: 'snowflake',
  Obliterate: 'trash',
};

type ExperimentScreenProps = {
  item: Item;
  isOnCooldown: BooleanLike;
  onEject: () => void;
  onExperiment: (id: number) => void;
};

const ExperimentScreen = (props: ExperimentScreenProps) => {
  const { item, isOnCooldown, onEject, onExperiment } = props;
  const { name, icon, isRelic, associatedNodes } = item;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <ItemPreview name={name} icon={icon} onEject={onEject} />
          </Stack.Item>
          <Stack.Item grow>
            <NodePreview nodes={associatedNodes} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <ExperimentButtons
          isRelic={isRelic}
          disabled={isOnCooldown}
          onExperiment={onExperiment}
        />
      </Stack.Item>
    </Stack>
  );
};

type ItemPreviewProps = {
  name: string;
  icon: string;
  onEject: () => void;
};

const ItemPreview = (props: ItemPreviewProps) => {
  const { name, icon, onEject } = props;
  const { t } = usePreferencesLocalization();

  return (
    <Stack fill vertical align="center">
      <Stack.Item align="stretch">
        <Stack fill>
          <Stack.Item>
            <Button
              fluid
              color="bad"
              icon="eject"
              height="100%"
              fontSize={1.5}
              tooltip={t('ui.experimentator.eject')}
              textAlign="center"
              onClick={() => onEject()}
              verticalAlignContent="middle"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill bold textAlign="center">
              {toTitleCase(name)}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical align="center" justify="center">
          <Stack.Item>
            <Image
              width="128px"
              height="128px"
              src={`data:image/jpeg;base64,${icon}`}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

type NodePreviewProps = {
  nodes: Node[];
};

const NodePreview = (props: NodePreviewProps) => {
  const { nodes } = props;
  const { t } = usePreferencesLocalization();

  return (
    <Section fill title={t('ui.experimentator.affected_nodes')}>
      {nodes.length > 0 ? (
        <LabeledList>
          {nodes.map((node, index) => (
            <LabeledList.Item
              key={index}
              label={node.name}
              color={node.isUnlocked ? 'good' : 'bad'}
            >
              {node.isUnlocked ? t('ui.common.unlocked') : t('ui.common.locked')}
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Stack fill vertical align="center" justify="center">
          <Stack.Item className="hypertorus__unselectable">
            <Icon
              fontSize={4}
              name="circle-question"
              className={'FabricatorRecipe__Title--disabled'}
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

type ExperimentButtonsProps = {
  isRelic: BooleanLike;
  disabled: BooleanLike;
  onExperiment: (id: number) => void;
};

const ExperimentButtons = (props: ExperimentButtonsProps) => {
  const { isRelic, disabled, onExperiment } = props;
  const { t } = usePreferencesLocalization();

  return (
    <Section fill>
      <Stack fill>
        {Object.keys(Experiment).map((value, index) => (
          <Stack.Item key={index}>
            <Button
              width={3}
              height={3}
              fontSize={1.6}
              textAlign="center"
              disabled={disabled}
              tooltip={Experiment[value]}
              verticalAlignContent="middle"
              icon={EXPERIMENT2ICON[value]}
              onClick={() => onExperiment(index + 1)}
            />
          </Stack.Item>
        ))}
        <Stack.Item grow>
          <Button
            bold
            fluid
            height={3}
            fontSize={1.6}
            textAlign="center"
            icon="magnifying-glass"
            verticalAlignContent="middle"
            disabled={!isRelic || disabled}
            onClick={() => onExperiment(7)}
          >
            {t('ui.experimentator.discover')}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
