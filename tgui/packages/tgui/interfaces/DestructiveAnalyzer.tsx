import { Box, Button, Image, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  server_connected: BooleanLike;
  loaded_item: string;
  item_icon: string;
  indestructible: BooleanLike;
  already_deconstructed: BooleanLike;
  recoverable_points: string;
  node_data: NodeData[];
  research_point_id: string;
};

type NodeData = {
  node_name: string;
  node_id: string;
  node_hidden: BooleanLike;
};

export const DestructiveAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    server_connected,
    indestructible,
    loaded_item,
    item_icon,
    already_deconstructed,
    recoverable_points,
    research_point_id,
    node_data = [],
  } = data;
  if (!server_connected) {
    return (
      <Window
        width={400}
        height={260}
        title={t('ui.destructive_analyzer.title')}
      >
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            {t('ui.destructive_analyzer.not_connected_to_server')}
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  if (!loaded_item) {
    return (
      <Window
        width={400}
        height={260}
        title={t('ui.destructive_analyzer.title')}
      >
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            {t('ui.destructive_analyzer.no_item_loaded')}
            <br />
            {t('ui.destructive_analyzer.insert_item_hint')}
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window
      width={400}
      height={260}
      title={t('ui.destructive_analyzer.title')}
    >
      <Window.Content scrollable>
        <Section
          title={loaded_item}
          buttons={
            <Button
              icon="eject"
              tooltip={t('ui.destructive_analyzer.eject_tooltip')}
              onClick={() => act('eject_item')}
            />
          }
        >
          <Image
            src={`data:image/jpeg;base64,${item_icon}`}
            height="64px"
            width="64px"
            verticalAlign="middle"
          />
        </Section>
        <Section title={t('ui.destructive_analyzer.deconstruction_methods')}>
          {!indestructible && (
            <NoticeBox textAlign="center" danger>
              {t('ui.destructive_analyzer.item_cannot_be_deconstructed')}
            </NoticeBox>
          )}
          {!!indestructible && (
            <>
              {!!recoverable_points && (
                <>
                  <Box fontSize="14px">
                    {t('ui.destructive_analyzer.research_points_from_deconstruction')}
                  </Box>
                  <Box>{recoverable_points}</Box>
                </>
              )}
              <Button.Confirm
                content={t('ui.destructive_analyzer.deconstruct')}
                icon="hammer"
                tooltip={
                  already_deconstructed
                    ? t('ui.destructive_analyzer.already_deconstructed_tooltip')
                    : t('ui.destructive_analyzer.destroy_object_tooltip')
                }
                onClick={() =>
                  act('deconstruct', { deconstruct_id: research_point_id })
                }
              />
            </>
          )}
          {node_data.map((node) => (
            <Button.Confirm
              icon="cash-register"
              mt={1}
              disabled={!node.node_hidden}
              key={node.node_id}
              tooltip={
                node.node_hidden
                  ? t('ui.destructive_analyzer.deconstruct_for_node_research')
                  : t('ui.destructive_analyzer.node_already_researched')
              }
              onClick={() =>
                act('deconstruct', { deconstruct_id: node.node_id })
              }
            >
              {node.node_name}
            </Button.Confirm>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
