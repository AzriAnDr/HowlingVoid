import '../styles/interfaces/AntagInfoHeretic.scss';

import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';
import { usePreferencesLocalization } from './localization';
import { Rules } from './AntagInfoRules'; // NOVA EDIT ADDITION
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  category?: ShopCategory;
  depth: number;
  done: BooleanLike;
  ascension: BooleanLike;
  disabled: BooleanLike;
  tooltip?: string;
};

enum ShopCategory {
  Tree = 'tree',
  Shop = 'shop',
  Draft = 'draft',
  Start = 'start',
}

type KnowledgeTier = {
  nodes: Knowledge[];
};

type HereticPassive = {
  name: string;
  description: string[];
};

type HereticPath = {
  route: string;
  complexity: string;
  complexity_color: string;
  description: string[];
  pros: string[];
  cons: string[];
  tips: string[];
  starting_knowledge: Knowledge;
  preview_abilities: Knowledge[];
  passive: HereticPassive;
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
  paths: HereticPath[];
  knowledge_shop: Knowledge[];
  knowledge_tiers: KnowledgeTier[];
  passive_level: number;
  points_to_aura: number;
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title={t('ui.heretic.you_are_the_heretic')} fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            {/* NOVA EDIT ADDITION START */}
            <Stack.Item>
              <Rules />
            </Stack.Item>
            {/* NOVA EDIT ADDITION END */}
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
            <Stack.Divider />

            {!ascended && (
              <Stack.Item>
                <ObjectivePrintout
                  fill
                  titleMessage={
                    can_change_objective
                      ? t('ui.heretic.objectives_primary_with_ascend_tasks') /* NOVA EDIT CHANGE - opfor objectives */
                      : t('ui.heretic.objectives_primary_with_personal_goal') /* NOVA EDIT CHANGE - opfor objectives  */
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={t('ui.heretic.reject_ascension')}
                      button_colour={'red'}
                      button_tooltip={
                        t('ui.heretic.reject_ascension_tooltip')
                      }
                    />
                  }
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  const { t } = usePreferencesLocalization();
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            {t('ui.heretic.flavor_intro_start')}&nbsp;
            <span style={hereticBlue}>{t('ui.heretic.shimmer')}</span>
            &nbsp;{t('ui.heretic.flavor_intro_middle')}&nbsp;
            <span style={hereticRed}>{t('ui.heretic.strange')}</span>
            &nbsp;{t('ui.heretic.flavor_intro_end')}
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            {t('ui.heretic.the')}{' '}
            <span style={hereticPurple}>{t('ui.heretic.gates_of_mansus')}</span>
            &nbsp;{t('ui.heretic.on_them_for')}
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { points_to_aura } = data;
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - {t('ui.heretic.guide_find_reality_smashing')}&nbsp;
          <span style={hereticPurple}>{t('ui.heretic.influences')}</span>
          &nbsp;{t('ui.heretic.around_you')}&nbsp;
          <b>{t('ui.heretic.right_click')}</b> {t('ui.heretic.on_them_for')}&nbsp;
          <span style={hereticBlue}>{t('ui.heretic.knowledge_points')}</span>.{' '}
          {t('ui.heretic.guide_tapping_visibility')}
        </Stack.Item>
        <Stack.Item>
          - {t('ui.heretic.you_have')}&nbsp;
          <span style={hereticRed}>{t('ui.heretic.living_heart_action')}</span>
          &nbsp;{t('ui.heretic.to_find')}&nbsp;
          <span style={hereticRed}>{t('ui.heretic.sacrifice_targets')}</span>,{' '}
          {t('ui.heretic.but_be_careful')}: {t('ui.heretic.guide_pulsing_warning')}{' '}
          {t('ui.heretic.guide_heart_tied')} <b>{t('ui.heretic.heart')}</b> -{' '}
          {t('ui.heretic.guide_regain_heart')}
        </Stack.Item>
        <Stack.Item>
          - {t('ui.heretic.draw_a')}&nbsp;
          <span style={hereticGreen}>{t('ui.heretic.transmutation_rune')}</span>{' '}
          {t('ui.heretic.guide_by_using_drawing_tool')}&nbsp;
          <span style={hereticGreen}>{t('ui.heretic.mansus_grasp')}</span>
          &nbsp;{t('ui.heretic.guide_active_in_other_hand')} {t('ui.heretic.guide_rune_allows_rituals')}
        </Stack.Item>
        <Stack.Item>
          - {t('ui.heretic.follow_your')}{' '}
          <span style={hereticRed}>{t('ui.heretic.living_heart')}</span>{' '}
          {t('ui.heretic.to_find')} your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>{t('ui.heretic.transmutation_rune')}</span>{' '}
          {t('ui.heretic.in_critical')}&nbsp;
          <span style={hereticRed}>{t('ui.heretic.sacrifice')}</span>{' '}
          {t('ui.heretic.them_for')}&nbsp;
          <span style={hereticBlue}>{t('ui.heretic.knowledge_points')}</span>.{' '}
          {t('ui.heretic.the_mansus')} <b>{t('ui.heretic.only')}</b>{' '}
          {t('ui.heretic.accepts_targets')}&nbsp;
          <span style={hereticRed}>{t('ui.heretic.living_heart')}</span>.
        </Stack.Item>
        <Stack.Item>
          - {t('ui.heretic.make_yourself_a')}{' '}
          <span style={hereticYellow}>{t('ui.heretic.focus')}</span>{' '}
          {t('ui.heretic.guide_focus_spells')}
        </Stack.Item>
        <Stack.Item>
          - {t('ui.heretic.guide_accomplish_objectives')}{' '}
          <span style={hereticYellow}>{t('ui.heretic.final_ritual')}</span>.{' '}
          {t('ui.heretic.guide_become_all_powerful')}
        </Stack.Item>
        <Stack.Item>
          <span style={hereticRed}>{t('ui.heretic.warning')}!</span>
          <br /> {t('ui.heretic.accumulating_total')} <b>{points_to_aura}</b>&nbsp;
          <span style={hereticBlue}>{t('ui.heretic.knowledge_points')}</span>
          &nbsp;{t('ui.heretic.to_manifest_aura')}&nbsp;
          <span style={hereticPurple}>{t('ui.heretic.mansus_energy')}</span> {t('ui.heretic.around_you')}.{' '}
          {t('ui.heretic.guide_gaining_points_sufficient')}
          <br />
          {t('ui.heretic.guide_aura_visible_warning')}
          <br />
          {t('ui.heretic.keep_in_mind')}&nbsp;
          <span style={hereticPurple}>{t('ui.heretic.codex_cicatrix')}</span>{' '}
          {t('ui.heretic.will_also_make')}&nbsp;
          <span style={hereticYellow}>{t('ui.heretic.influences')}</span>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>{t('ui.heretic.you_have')}</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  {t('ui.heretic.ascended')}
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          {t('ui.heretic.you_have')} <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>
            {t('ui.heretic.knowledge_point')}
            {charges !== 1 ? 's' : ''}
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          {t('ui.heretic.you_have_made_total')}&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>{t('ui.heretic.sacrifices')}</span>.
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const KnowledgeTree = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { knowledge_tiers } = data;

  const nodesToShow = knowledge_tiers.filter((tier) => tier.nodes.length > 0);

  return (
    <Section title={t('ui.heretic.research_tree')} fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>{t('ui.heretic.dawn')}</span>
      </Box>
      <Stack vertical>
        {nodesToShow.length === 0
          ? t('ui.common.none')
          : nodesToShow.map((tier, i) => (
              <Stack.Item key={i}>
                <Stack
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <KnowledgeNode
                      key={node.path}
                      node={node}
                      // hack, free nodes are draft nodes
                      purchaseCategory={node.category}
                    />
                  ))}
                </Stack>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

type KnowledgeNodeProps = {
  node: Knowledge;
  purchaseCategory?: ShopCategory;
  can_buy?: BooleanLike;
};

const KnowledgeNode = (props: KnowledgeNodeProps) => {
  const { node, can_buy = true, purchaseCategory } = props;
  const { data, act } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { charges } = data;

  const isBuyable = can_buy && !node.done && !node.disabled;

  const iconState = () => {
    if (!can_buy) {
      return node.bgr;
    }
    if (node.done) {
      return 'node_finished';
    }
    if (charges < node.cost || node.disabled) {
      return 'node_locked';
    }
    return node.bgr;
  };

  return (
    <Stack.Item key={node.name}>
      <Button
        color="transparent"
        tooltip={
          node.tooltip ??
          `${node.name}:
          ${node.desc}`
        }
        onClick={
          !isBuyable
            ? () => logger.warn(`Cannot buy ${node.name}`)
            : () =>
                act('research', { path: node.path, category: purchaseCategory })
        }
        width={node.ascension ? '192px' : '64px'}
        height={node.ascension ? '192px' : '64px'}
        m="8px"
        style={{
          borderRadius: '50%',
        }}
      >
        <DmIcon
          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
          icon_state={iconState()}
          height={node.ascension ? '192px' : '64px'}
          width={node.ascension ? '192px' : '64px'}
          top="0px"
          left="0px"
          position="absolute"
        />
        <DmIcon
          icon={node.icon_params?.icon}
          icon_state={node.icon_params?.state}
          frame={node.icon_params?.frame}
          direction={node.icon_params?.dir}
          movement={node.icon_params?.moving}
          height={node.ascension ? '152px' : '64px'}
          width={node.ascension ? '152px' : '64px'}
          top={node.ascension ? '20px' : '0px'}
          left={node.ascension ? '20px' : '0px'}
          position="absolute"
        />
        <Box
          position="absolute"
          top="0px"
          left="0px"
          backgroundColor="black"
          textColor="white"
          bold
          style={{ margin: '2px', borderRadius: '100%' }}
        >
          {isBuyable && (node.cost > 0 ? node.cost : t('ui.common.free'))}
        </Box>
      </Button>
      {!!node.ascension && (
        <Box textAlign="center" fontSize="32px">
          <span style={hereticPurple}>{t('ui.heretic.dusk')}</span>
        </Box>
      )}
    </Stack.Item>
  );
};

const KnowledgeShop = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { knowledge_shop } = data;

  if (!knowledge_shop || knowledge_shop.length === 0) {
    return null;
  }

  return (
    <Section title={t('ui.heretic.knowledge_shop')} fill scrollable>
      <Stack vertical fill>
        <Knowledges />
      </Stack>
    </Section>
  );

  function Knowledges() {
    // filter the list into being indexed by tier
    const tiers: Knowledge[][] = knowledge_shop.reduce((acc, knowledge) => {
      const tierIndex = knowledge.depth - 1; // depth starts at 1, so
      if (!acc[tierIndex]) {
        acc[tierIndex] = [];
      }
      acc[tierIndex].push(knowledge);
      return acc;
    }, [] as Knowledge[][]);

    return tiers?.map((tier, index) => (
      <Stack.Item key={`tier-${index}`}>
        {t('ui.common.tier')} {index + 1}
        <Stack fill scrollable wrap="wrap">
          {tier.map((knowledge) => (
            <Stack.Item key={`knowledge-${knowledge.path}`}>
              <KnowledgeNode
                node={knowledge}
                purchaseCategory={knowledge.category}
              />
            </Stack.Item>
          ))}
        </Stack>
        <hr />
      </Stack.Item>
    ));
  }
};

const ResearchInfo = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { charges, knowledge_shop } = data;

  return (
    <>
      <Stack.Item mb={1.5} fontSize="20px" textAlign="center">
        {t('ui.heretic.you_have')} <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          {t('ui.heretic.knowledge_point')}
          {charges !== 1 ? 's' : ''}
        </span>{' '}
        {t('ui.heretic.to_spend')}
      </Stack.Item>
      <Stack fill>
        <Stack.Item grow>
          <KnowledgeTree />
        </Stack.Item>
        {knowledge_shop?.length && (
          <Stack.Item grow>
            <KnowledgeShop />
          </Stack.Item>
        )}
      </Stack>
    </>
  );
};

const PathInfo = ({ currentPath }: { currentPath?: HereticPath }) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { paths } = data;

  const pathBoughtIndex = paths.findIndex(
    (path) => currentPath && path.route === currentPath.route,
  );

  const [currentTab, setCurrentTab] = useState(
    pathBoughtIndex !== -1 ? pathBoughtIndex : 0,
  );

  return (
    <Stack fill>
      {!currentPath && (
        <Stack.Item>
          <Tabs fluid vertical>
            {paths.map((path, index) => (
              <Tabs.Tab
                key={index}
                icon="info"
                selected={currentTab === index}
                onClick={() => setCurrentTab(index)}
              >
                {path.route}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <PathContent path={paths[currentTab]} isPathSelected={!!currentPath} />
      </Stack.Item>
    </Stack>
  );
};

const PathContent = ({
  path,
  isPathSelected,
}: {
  path: HereticPath;
  isPathSelected: boolean;
}) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { passive_level } = data;
  const { name, description } = path.passive;
  return (
    <Section
      title={<h1 className="PathTitle">{path.route}</h1>}
      textAlign="center"
      fill
      scrollable
    >
      <Stack vertical>
        {!isPathSelected && (
          <Stack.Item verticalAlign="center" textAlign="center">
            <h1>{t('ui.heretic.choose_path')}:</h1>{' '}
            <KnowledgeNode
              node={path.starting_knowledge}
              purchaseCategory={ShopCategory.Start}
            />
            <div>
              <h3>
                {t('ui.heretic.complexity')}:{' '}
                <span style={{ color: path.complexity_color }}>
                  {path.complexity}
                </span>
              </h3>
            </div>
          </Stack.Item>
        )}

        <Stack.Item>
          <b>{t('ui.heretic.description')}:</b>{' '}
          {path.description.map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </Stack.Item>
        {(!isPathSelected && (
          <Stack.Item style={{ justifyItems: 'center' }}>
            <b>{t('ui.heretic.passive')}: {name}</b>
            <p className="Passive">{description[0]}</p>
          </Stack.Item>
        )) || (
          <Stack.Item>
            <b>
              {t('ui.heretic.passive')}: {name}, {t('ui.common.level')}: {passive_level}
            </b>
            <Stack>
              {description.map((line, index) => (
                <Stack.Item
                  key={index}
                  className={`Passive ${passive_level >= index + 1 ? 'Passive--Active' : ''}`}
                >
                  {t('ui.common.level')} {index + 1}
                  <br />
                  {line}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          {!isPathSelected && (
            <>
              <b>{t('ui.heretic.guaranteed_abilities')}:</b>
              <Stack wrap="wrap" justify="center">
                {path.preview_abilities.map((ability) => (
                  <Stack.Item key={`guaranteed_${ability.name}`} m={1}>
                    <KnowledgeNode node={ability} can_buy={false} />
                  </Stack.Item>
                ))}
              </Stack>
            </>
          )}
        </Stack.Item>
        {!isPathSelected && (
          <>
            <Stack.Item>
              <b>{t('ui.heretic.pros')}:</b>
              <div>
                {path.pros.map((pro, index) => (
                  <p key={index}>{pro}</p>
                ))}
              </div>
            </Stack.Item>
            <Stack.Item>
              <b>{t('ui.heretic.cons')}:</b>
              <div>
                {path.cons.map((con, index) => (
                  <p key={index}>{con}</p>
                ))}
              </div>
            </Stack.Item>
          </>
        )}

        {isPathSelected && (
          <Stack.Item textAlign="left" mt={2} mb={1}>
            <b>{t('ui.heretic.tips')}:</b>
            <ul>
              {path.tips.map((tip, index) => (
                <li key={index}>{tip}</li>
              ))}
            </ul>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoHeretic = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { ascended, knowledge_tiers, paths } = data;

  const [currentTab, setTab] = useState(1);
  // only tiers has done variables set
  const currentPath = paths.find((path) =>
    knowledge_tiers.some((tier) =>
      tier.nodes.some(
        (node) => node.done && node.path === path.starting_knowledge.path,
      ),
    ),
  );

  const tabs = [
    {
      label: t('ui.heretic.tab_information'),
      icon: 'info',
      content: <IntroductionSection />,
    },
    {
      label: t('ui.heretic.tab_path_info'),
      icon: 'info',
      content: <PathInfo currentPath={currentPath} />,
    },
    { label: t('ui.heretic.tab_research'), icon: 'book', content: <ResearchInfo /> },
  ];

  const currentTheme = () => {
    if (currentPath?.route) {
      return `Heretic theme-Heretic--${currentPath.route.replace(' ', '')}`;
    }
    return 'Heretic';
  };

  return (
    <Window
      width={750}
      height={635}
      theme={`${currentTheme()}${ascended ? ' heretic-theme-ascended' : ''}`}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              {tabs.map((tab, index) => (
                <Tabs.Tab
                  key={index}
                  icon={tab.icon}
                  selected={currentTab === index}
                  onClick={() => setTab(index)}
                >
                  {tab.label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tabs[currentTab].content}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
