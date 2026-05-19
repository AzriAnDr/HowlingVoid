import {
  Box,
  Button,
  Collapsible,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { Experiment } from '../../ExperimentConfigure';
import { usePreferencesLocalization } from '../../localization';
import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import { LockedExperiment } from '../LockedExperiment';
import type { TechwebNode } from '../types';

type Props = {
  node: TechwebNode;
} & Partial<{
  nocontrols: BooleanLike;
  nodetails: BooleanLike;
}>;

export function TechNode(props: Props) {
  const { act, data } = useRemappedBackend();
  const { t } = usePreferencesLocalization(data, 'rnd');
  const {
    node_cache,
    design_cache,
    experiments,
    points = [],
    nodes,
    point_types_abbreviations = [],
    queue_nodes = [],
    show_experiments,
  } = data;
  const { node, nodetails, nocontrols } = props;
  const {
    id,
    can_unlock,
    have_experiments_done,
    tier,
    enqueued_by_user,
    is_free,
  } = node;
  const {
    name,
    description,
    costs,
    design_ids,
    prereq_ids,
    required_experiments,
    discount_experiments,
  } = node_cache[id];
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  const expcompl = show_experiments
    ? required_experiments.filter((x) => experiments[x]?.completed).length
    : 0;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / required_experiments.length}
    >
      {t('ui.techweb.experiments')} ({expcompl}/{required_experiments.length})
    </ProgressBar>
  );

  const techcompl = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const techProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={techcompl / prereq_ids.length}
    >
      {t('ui.techweb.tech')} ({techcompl}/{prereq_ids.length})
    </ProgressBar>
  );

  // Notice that this logic will have to be changed if we make the discounts
  // pool-specific
  const nodeDiscount = show_experiments
    ? Object.keys(discount_experiments)
        .filter((x) => experiments[x]?.completed)
        .reduce((tot, curr) => {
          return tot + discount_experiments[curr];
        }, 0)
    : 0;

  return (
    <Section
      className="Techweb__NodeContainer"
      title={name}
      buttons={
        !nocontrols && (
          <>
            {tier > 0 &&
              (!!can_unlock && (is_free || queue_nodes.length === 0) ? (
                <Button
                  icon="lightbulb"
                  disabled={!can_unlock || tier > 1 || queue_nodes.length > 0}
                  onClick={() => act('researchNode', { node_id: id })}
                >
                  {t('ui.techweb.research')}
                </Button>
              ) : enqueued_by_user ? (
                <Button
                  icon="trash"
                  color="bad"
                  onClick={() => act('dequeueNode', { node_id: id })}
                >
                  {t('ui.techweb.dequeue')}
                </Button>
              ) : id in queue_nodes && !enqueued_by_user ? (
                <Button icon="check" color="good">
                  {t('ui.techweb.queued')}
                </Button>
              ) : (
                <Button
                  icon="lightbulb"
                  disabled={
                    !have_experiments_done ||
                    id in queue_nodes ||
                    techcompl < prereq_ids.length
                  }
                  onClick={() => act('enqueueNode', { node_id: id })}
                >
                  {t('ui.techweb.enqueue')}
                </Button>
              ))}
            {!nodetails && (
              <Button
                icon="tasks"
                onClick={() => {
                  setTechwebRoute({ route: 'details', selectedNode: id });
                }}
              >
                {t('ui.common.details')}
              </Button>
            )}
          </>
        )
      }
    >
      {tier !== 0 && (
        <Stack className="Techweb__NodeProgress">
          {costs.map((k) => {
            const reqPts = Math.max(0, k.value - nodeDiscount);
            const nodeProg = Math.min(reqPts, points[k.type]) || 0;
            return (
              <Stack.Item key={k.type} grow basis={0}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={
                    reqPts === 0
                      ? 1
                      : Math.min(1, (points[k.type] || 0) / reqPts)
                  }
                >
                  {point_types_abbreviations[k.type]} ({nodeProg}/{reqPts})
                </ProgressBar>
              </Stack.Item>
            );
          })}
          {prereq_ids.length > 0 && (
            <Stack.Item grow basis={0}>
              {techProgress}
            </Stack.Item>
          )}
          {!!show_experiments && required_experiments.length > 0 && (
            <Stack.Item grow basis={0}>
              {experimentProgress}
            </Stack.Item>
          )}
        </Stack>
      )}
      <Box className="Techweb__NodeDescription" mb={2}>
        {description}
      </Box>
      <Box className="Techweb__NodeUnlockedDesigns" mb={2}>
        {design_ids.map((k, i) => (
          <Button
            key={k}
            className={`${design_cache[k].class} Techweb__DesignIcon`}
            tooltip={design_cache[k].name}
            tooltipPosition={i % 15 < 7 ? 'right' : 'left'}
          />
        ))}
      </Box>
      {!!show_experiments && required_experiments.length > 0 && (
        <Collapsible
          className="Techweb__NodeExperimentsRequired"
          title={t('ui.techweb.required_experiments')}
        >
          {required_experiments.map((k, index) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment key={index} />;
            }
            return <Experiment key={thisExp.name} exp={thisExp} />;
          })}
        </Collapsible>
      )}
      {!!show_experiments && Object.keys(discount_experiments).length > 0 && (
        <Collapsible
          className="TechwebNodeExperimentsRequired"
          title={t('ui.techweb.discount_eligible_experiments')}
        >
          {Object.keys(discount_experiments).map((k, index) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment key={index} />;
            }
            return (
              <Experiment key={thisExp.name} exp={thisExp}>
                <Box className="Techweb__ExperimentDiscount">
                  {t(
                    'ui.techweb.provides_discount',
                    'Provides a discount of {points} points to all required point pools.',
                  ).replace('{points}', `${discount_experiments[k]}`)}
                </Box>
              </Experiment>
            );
          })}
        </Collapsible>
      )}
    </Section>
  );
}
