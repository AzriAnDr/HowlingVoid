import '../styles/interfaces/AntagInfoHeretic.scss';

import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';
import {
  HERETIC_COMPLEXITY_RU,
  HERETIC_KNOWLEDGE_RU,
  HERETIC_PASSIVE_RU,
  HERETIC_PATH_RU,
  useAntagInfoLocale,
} from './AntagInfo/localization';
import { Rules } from './AntagInfoRules'; // SKYRAT EDIT ADDITION
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
  const { objectives, ascended, can_change_objective } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section
          title={isRu ? 'Вы - Еретик!' : 'You are the Heretic!'}
          fill
          scrollable
          fontSize="14px"
        >
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            {/* SKYRAT EDIT ADDITION START */}
            <Stack.Item>
              <Rules />
            </Stack.Item>
            {/* SKYRAT EDIT ADDITION END */}
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
                      ? isRu
                        ? 'Ваши цели ОПФОР - главные, но чтобы вознестись, вам нужно выполнить ещё и эти задачи'
                        : 'Your OPFOR objectives are your primary ones, but in order to ascend, you have these tasks to fulfill' /* SKYRAT EDIT CHANGE - opfor objectives */
                      : isRu
                        ? 'Ваши цели ОПФОР - главные. Используйте тёмные знания для выполнения личной цели'
                        : 'Your OPFOR objectives are your primary ones. Use your dark knowledge to fulfill your personal goal' /* SKYRAT EDIT CHANGE - opfor objectives  */
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={isRu ? 'Отвергнуть Вознесение' : 'Reject Ascension'}
                      button_colour={'red'}
                      button_tooltip={
                        isRu
                          ? 'Отвернитесь от Мансуса ради задачи по своему выбору. Это предотвратит Вознесение!'
                          : 'Turn your back on the Mansus to accomplish a task of your choosing. Selecting this option will prevent you from ascending!'
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
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          {isRu ? (
            <i>
              Очередной день на бессмысленной работе. Вы ощущаете{' '}
              <span style={hereticBlue}>мерцание</span>
              &nbsp;вокруг себя, осознавая нечто&nbsp;
              <span style={hereticRed}>странное</span>
              &nbsp;в воздухе. Вы смотрите внутрь себя и обнаруживаете нечто,
              что изменит вашу жизнь.
            </i>
          ) : (
            <i>
              Another day at a meaningless job. You feel a&nbsp;
              <span style={hereticBlue}>shimmer</span>
              &nbsp;around you, as a realization of something&nbsp;
              <span style={hereticRed}>strange</span>
              &nbsp;in the air unfolds. You look inwards and discover something
              that will change your life.
            </i>
          )}
        </Stack.Item>
        <Stack.Item>
          <b>
            {isRu ? (
              <>
                <span style={hereticPurple}>Врата Мансуса</span>
                &nbsp;открываются перед вашим разумом.
              </>
            ) : (
              <>
                The <span style={hereticPurple}>Gates of Mansus</span>
                &nbsp;open up to your mind.
              </>
            )}
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  const { data } = useBackend<Info>();
  const { points_to_aura } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          {isRu ? (
            <>
              - Ищите&nbsp;
              <span style={hereticPurple}>влияния</span>, разбивающие
              реальность, невидимые для обычных людей, и&nbsp;
              <b>нажмите правой кнопкой</b>, чтобы собрать их в&nbsp;
              <span style={hereticBlue}>очки знаний</span>. Прикосновение
              сделает их видимыми для всех через некоторое время. Мечтания о
              Мансусе помогут их найти.
            </>
          ) : (
            <>
              - Find reality smashing&nbsp;
              <span style={hereticPurple}>influences</span>
              &nbsp;around the station invisible to the normal eye and&nbsp;
              <b>right click</b> on them to harvest them for&nbsp;
              <span style={hereticBlue}>knowledge points</span>. Tapping them
              makes them visible to all after a short time. Dreaming of Mansus
              may help to find them.
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              - Используйте действие&nbsp;
              <span style={hereticRed}>Живого Сердца</span>
              &nbsp;для отслеживания&nbsp;
              <span style={hereticRed}>жертв</span>. Осторожно: пульсация
              создаёт звук сердцебиения, который могут услышать люди рядом.
              Если сердце потеряно, выполните ритуал для его возвращения.
            </>
          ) : (
            <>
              - Use your&nbsp;
              <span style={hereticRed}>Living Heart action</span>
              &nbsp;to track down&nbsp;
              <span style={hereticRed}>sacrifice targets</span>, but be
              careful: Pulsing it will produce a heartbeat sound that nearby
              people may hear. This action is tied to your <b>heart</b> - if
              you lose it, you must complete a ritual to regain it.
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              - Нарисуйте&nbsp;
              <span style={hereticGreen}>руну трансмутации</span>, используя
              рисовательный инструмент (ручку или мелок) на полу, держа&nbsp;
              <span style={hereticGreen}>Хватку Мансуса</span>
              &nbsp;в другой руке. Руна позволяет выполнять ритуалы и
              жертвоприношения.
            </>
          ) : (
            <>
              - Draw a&nbsp;
              <span style={hereticGreen}>transmutation rune</span> by using a
              drawing tool (a pen or crayon) on the floor while having&nbsp;
              <span style={hereticGreen}>Mansus Grasp</span>
              &nbsp;active in your other hand. This rune allows you to complete
              rituals and sacrifices.
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              - Следуйте своему{' '}
              <span style={hereticRed}>Живому Сердцу</span>, чтобы найти цели.
              Доставьте их к&nbsp;
              <span style={hereticGreen}>руне трансмутации</span> в критическом
              или худшем состоянии для&nbsp;
              <span style={hereticRed}>жертвоприношения</span> и получения&nbsp;
              <span style={hereticBlue}>очков знаний</span>. Мансус принимает{' '}
              <b>ТОЛЬКО</b> цели, указанные&nbsp;
              <span style={hereticRed}>Живым Сердцем</span>.
            </>
          ) : (
            <>
              - Follow your <span style={hereticRed}>Living Heart</span> to
              find your targets. Bring them back to a&nbsp;
              <span style={hereticGreen}>transmutation rune</span> in critical
              or worse condition to&nbsp;
              <span style={hereticRed}>sacrifice</span> them for&nbsp;
              <span style={hereticBlue}>knowledge points</span>. The Mansus{' '}
              <b>ONLY</b> accepts targets pointed to by the&nbsp;
              <span style={hereticRed}>Living Heart</span>.
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              - Создайте себе{' '}
              <span style={hereticYellow}>фокус</span>, чтобы использовать
              различные продвинутые заклинания для добычи всё более сложных
              жертв.
            </>
          ) : (
            <>
              - Make yourself a{' '}
              <span style={hereticYellow}>focus</span> to be able to cast
              various advanced spells to assist you in acquiring harder and
              harder sacrifices.
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              - Выполните все свои цели, чтобы изучить{' '}
              <span style={hereticYellow}>финальный ритуал</span>. Завершите
              ритуал, чтобы стать всемогущим!
            </>
          ) : (
            <>
              - Accomplish all of your objectives to be able to learn the{' '}
              <span style={hereticYellow}>final ritual</span>. Complete the
              ritual to become all powerful!
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              <span style={hereticRed}>ПРЕДУПРЕЖДЕНИЕ!</span>
              <br /> Накопление <b>{points_to_aura}</b>&nbsp;
              <span style={hereticBlue}>очков знаний</span>
              &nbsp;породит видимую ауру&nbsp;
              <span style={hereticPurple}>энергии Мансуса</span> вокруг вас.
              Трата очков не отменяет триггер - важно именно накопление.
              <br />
              Аура видна всем вокруг и выдаёт вас как еретика. Оцените риски
              перед накоплением!
              <br />
              Использование{' '}
              <span style={hereticPurple}>Codex Cicatrix</span> при осушении{' '}
              <span style={hereticYellow}>влияний</span> тоже сделает вас
              очевидным еретиком.
            </>
          ) : (
            <>
              <span style={hereticRed}>WARNING!</span>
              <br /> Accumulating a total of <b>{points_to_aura}</b>&nbsp;
              <span style={hereticBlue}>knowledge points</span>
              &nbsp;to manifest a visible aura of&nbsp;
              <span style={hereticPurple}>Mansus energy</span> around you.
              Simply gaining the points is sufficent, spending them will not
              trigger it.
              <br />
              This aura will be visible to all those around you and will mark
              you as a heretic. Consider the risks before accumulating too much
              knowledge!
              <br />
              Keep in mind that using a&nbsp;
              <span style={hereticPurple}>Codex Cicatrix</span> will also make
              you very obvious as a heretic when draining&nbsp;
              <span style={hereticYellow}>influences</span>
            </>
          )}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = () => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>{isRu ? 'Вы' : 'You have'}</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  {isRu ? 'ВОЗНЕСЛИСЬ' : 'ASCENDED'}
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          {isRu ? (
            <>
              У вас <b>{charges || 0}</b>&nbsp;
              <span style={hereticBlue}>
                очков знаний
              </span>
              .
            </>
          ) : (
            <>
              You have <b>{charges || 0}</b>&nbsp;
              <span style={hereticBlue}>
                knowledge point{charges !== 1 ? 's' : ''}
              </span>
              .
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          {isRu ? (
            <>
              Всего вы совершили&nbsp;
              <b>{total_sacrifices || 0}</b>&nbsp;
              <span style={hereticRed}>жертвоприношений</span>.
            </>
          ) : (
            <>
              You have made a total of&nbsp;
              <b>{total_sacrifices || 0}</b>&nbsp;
              <span style={hereticRed}>sacrifices</span>.
            </>
          )}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const KnowledgeTree = () => {
  const { data } = useBackend<Info>();
  const { knowledge_tiers } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

  const nodesToShow = knowledge_tiers.filter((tier) => tier.nodes.length > 0);

  return (
    <Section title={isRu ? 'Дерево исследований' : 'Research Tree'} fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>{isRu ? 'РАССВЕТ' : 'DAWN'}</span>
      </Box>
      <Stack vertical>
        {nodesToShow.length === 0
          ? (isRu ? 'Нет!' : 'None!')
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
  const { charges } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';
  const ruKnowledge = isRu ? HERETIC_KNOWLEDGE_RU[node.name] : undefined;
  const displayName = ruKnowledge?.name ?? node.name;
  const displayDesc = ruKnowledge?.desc ?? node.desc;

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
          `${displayName}:
          ${displayDesc}`
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
          {isBuyable && (node.cost > 0 ? node.cost : isRu ? 'ДАРОМ' : 'FREE')}
        </Box>
      </Button>
      {!!node.ascension && (
        <Tooltip
          content={
            node.tooltip ??
            `${displayName}:
          ${displayDesc}`
          }
        >
          <Box textAlign="center" fontSize="32px">
            <span style={hereticPurple}>{displayName}</span>
          </Box>
        </Tooltip>
      )}
    </Stack.Item>
  );
};

const KnowledgeShop = () => {
  const { data } = useBackend<Info>();
  const { knowledge_shop } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

  if (!knowledge_shop || knowledge_shop.length === 0) {
    return null;
  }

  return (
    <Section title={isRu ? 'Магазин знаний' : 'Knowledge Shop'} fill scrollable>
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
        {isRu ? `Уровень ${index + 1}` : `Tier ${index + 1}`}
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
  const { charges, knowledge_shop } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

  return (
    <>
      <Stack.Item mb={1.5} fontSize="20px" textAlign="center">
        {isRu ? (
          <>
            У вас <b>{charges || 0}</b>&nbsp;
            <span style={hereticBlue}>очков знаний</span> для трат.
          </>
        ) : (
          <>
            You have <b>{charges || 0}</b>&nbsp;
            <span style={hereticBlue}>
              knowledge point{charges !== 1 ? 's' : ''}
            </span>{' '}
            to spend.
          </>
        )}
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
  const { paths } = data;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

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
                {isRu
                  ? (HERETIC_PATH_RU[path.route]?.name ?? path.route)
                  : path.route}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <PathContent
          path={currentPath || paths[currentTab]}
          isPathSelected={!!currentPath}
        />
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
  const { passive_level } = data;
  const { name, description } = path.passive;
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';

  const ruData = isRu ? HERETIC_PATH_RU[path.route] : undefined;
  const shownDescription = ruData ? ruData.description : path.description;
  const shownPros = ruData ? ruData.pros : path.pros;
  const shownCons = ruData ? ruData.cons : path.cons;
  const shownTips = ruData ? ruData.tips : path.tips;
  const shownRoute = ruData ? ruData.name : path.route;
  const shownComplexity = isRu
    ? (HERETIC_COMPLEXITY_RU[path.complexity] ?? path.complexity)
    : path.complexity;
  const ruPassive = isRu ? HERETIC_PASSIVE_RU[name] : undefined;
  const shownPassiveName = ruPassive?.name ?? name;
  const shownPassiveDescs = ruPassive?.descriptions ?? description;

  return (
    <Section
      title={<h1 className="PathTitle">{shownRoute}</h1>}
      textAlign="center"
      fill
      scrollable
    >
      <Stack vertical>
        {!isPathSelected && (
          <Stack.Item verticalAlign="center" textAlign="center">
            <h1>{isRu ? 'Выбрать путь:' : 'Choose Path:'}</h1>{' '}
            <KnowledgeNode
              node={path.starting_knowledge}
              purchaseCategory={ShopCategory.Start}
            />
            <div>
              <h3>
                {isRu ? 'Сложность: ' : 'Complexity: '}
                <span style={{ color: path.complexity_color }}>
                  {shownComplexity}
                </span>
              </h3>
            </div>
          </Stack.Item>
        )}

        <Stack.Item>
          <b>{isRu ? 'Описание:' : 'Description:'}</b>{' '}
          {shownDescription.map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </Stack.Item>
        {(!isPathSelected && (
          <Stack.Item style={{ justifyItems: 'center' }}>
            <b>{isRu ? `Пассивка: ${shownPassiveName}` : `Passive: ${shownPassiveName}`}</b>
            <p className="Passive">{shownPassiveDescs[0]}</p>
          </Stack.Item>
        )) || (
          <Stack.Item>
            <b>
              {isRu
                ? `Пассивка: ${shownPassiveName}, уровень: ${passive_level}`
                : `Passive: ${shownPassiveName}, level: ${passive_level}`}
            </b>
            <Stack>
              {shownPassiveDescs.map((line, index) => (
                <Stack.Item
                  key={index}
                  className={`Passive ${passive_level >= index + 1 ? 'Passive--Active' : ''}`}
                >
                  {isRu ? `Уровень ${index + 1}` : `Level ${index + 1}`}
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
              <b>{isRu ? 'Гарантированные способности:' : 'Guaranteed Abilities:'}</b>
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
              <b>{isRu ? 'Плюсы:' : 'Pros:'}</b>
              <div>
                {shownPros.map((pro, index) => (
                  <p key={index}>{pro}</p>
                ))}
              </div>
            </Stack.Item>
            <Stack.Item>
              <b>{isRu ? 'Минусы:' : 'Cons:'}</b>
              <div>
                {shownCons.map((con, index) => (
                  <p key={index}>{con}</p>
                ))}
              </div>
            </Stack.Item>
          </>
        )}

        {isPathSelected && (
          <Stack.Item textAlign="left" mt={2} mb={1}>
            <b>{isRu ? 'Советы:' : 'Tips:'}</b>
            <ul>
              {shownTips.map((tip, index) => (
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
  const { ascended, knowledge_tiers, paths } = data;

  const [currentTab, setTab] = useState(1);
  const { lang } = useAntagInfoLocale();
  const isRu = lang === 'ru';
  // only tiers has done variables set
  const currentPath = paths?.find((path) =>
    knowledge_tiers?.some((tier) =>
      tier.nodes.some(
        (node) => node.done && node.path === path.starting_knowledge.path,
      ),
    ),
  );

  const tabs = [
    { label: isRu ? 'Информация' : 'Information', icon: 'info', content: <IntroductionSection /> },
    {
      label: isRu ? 'Путь' : 'Path Info',
      icon: 'info',
      content: <PathInfo currentPath={currentPath} />,
    },
    { label: isRu ? 'Исследования' : 'Research', icon: 'book', content: <ResearchInfo /> },
  ];

  const currentTheme = () => {
    const themes = ['Heretic'];
    if (currentPath?.route) {
      themes.push(`theme-Heretic--${currentPath.route.replace(/ /g, '')}`);
    }
    if (ascended) {
      themes.push('heretic-theme-ascended');
    }
    return themes.join(' ');
  };

  return (
    <Window width={750} height={635} theme={currentTheme()}>
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
