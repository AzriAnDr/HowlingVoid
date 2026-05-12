import { useState } from 'react';
import {
  Button,
  Divider,
  Flex,
  Section,
  Tabs,
  VirtualList,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import type { TechwebNode } from '../types';
import { TechNode } from './TechNode';

type NodeDetailProps = {
  selectedNode: string;
};

export function TechwebNodeDetail(props: NodeDetailProps) {
  const { selectedNode } = props;

  const { data } = useRemappedBackend();
  const { nodes } = data;

  const selectedNodeData =
    selectedNode && nodes.find((x) => x.id === selectedNode);

  if (!selectedNodeData) return;

  return <TechNodeDetail node={selectedNodeData} />;
}

type TechNodeDetailProps = {
  node: TechwebNode;
};

enum Tab {
  REQUIRED,
  UNLOCKS,
}

export function TechNodeDetail(props: TechNodeDetailProps) {
  const { node } = props;

  const { data } = useRemappedBackend();
  const { t } = usePreferencesLocalization(data, 'rnd');
  const { nodes, node_cache } = data;

  const { prereq_ids, unlock_ids } = node_cache[node.id];

  const [tabIndex, setTabIndex] = useState(Tab.REQUIRED);
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  const prereqNodes = nodes.filter((x) => prereq_ids.includes(x.id));
  const complPrereq = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const unlockedNodes = nodes.filter((x) => unlock_ids.includes(x.id));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item shrink={1}>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {t('ui.techweb.node', 'Node')}
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === Tab.REQUIRED}
                onClick={() => setTabIndex(Tab.REQUIRED)}
              >
                {t('ui.techweb.required', 'Required')} ({complPrereq}/{prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === Tab.UNLOCKS}
                // disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(Tab.UNLOCKS)}
              >
                {t('ui.techweb.unlocks', 'Unlocks')} ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button icon="home" onClick={() => setTechwebRoute({ route: '' })}>
              {t('ui.common.home')}
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" shrink={0}>
        <TechNode node={node} nodetails />
        <Divider />
      </Flex.Item>
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes" grow>
          <Section scrollable fill>
            <VirtualList>
              {prereqNodes.map((n) => (
                <TechNode key={n.id} node={n} />
              ))}
            </VirtualList>
          </Section>
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes" grow>
          <Section scrollable fill>
            <VirtualList>
              {unlockedNodes.map((n) => (
                <TechNode key={n.id} node={n} />
              ))}
            </VirtualList>
          </Section>
        </Flex.Item>
      )}
    </Flex>
  );
}
