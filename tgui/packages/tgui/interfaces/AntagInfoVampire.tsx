import { type SetStateAction, useState } from 'react';
import { sanitizeText } from 'tgui/sanitize';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';
import { usePreferencesLocalization } from './localization';

type VampireInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  powers: PowerInfo[];
};

type ClanInfo = {
  name: string;
  description: string;
  icon: string;
  icon_state: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
  icon_state: string;
  cost: string;
  constant_cost: string;
  cooldown: string;
};

type Info = {
  objectives: Objective[];
};

enum InfoTab {
  General = 1,
  Basics,
  Powers,
}

export const AntagInfoVampire = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  // Set default to 2 so Basics (now in the middle) opens by default
  const [tab, setTab] = useState(InfoTab.Basics);

  // Styles for the top-level tabs:
  const topTabsStyle = {
    display: 'flex',
    width: '100%',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;
  const topTabStyle = {
    flex: 1,
    fontSize: '25px',
    padding: '10px 12px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
    fontWeight: 900,
    letterSpacing: '0.5px',
    textShadow: '0 1px 0 rgba(0,0,0,0.6)',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;

  return (
    <Window width={700} height={750} theme="spookyconsole">
      <Window.Content>
        <Box align="center" style={{ width: '100%' }}>
          <Tabs style={topTabsStyle}>
            {/* Guide on the left */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === InfoTab.General}
              onClick={() => setTab(InfoTab.General)}
            >
              {t('ui.antag_info_vampire.general_guide')}
            </Tabs.Tab>

            {/* Basics in the middle (slightly larger/bold for emphasis) */}
            <Tabs.Tab
              style={{ ...topTabStyle, fontSize: '30px', fontWeight: 900 }}
              selected={tab === InfoTab.Basics}
              onClick={() => setTab(InfoTab.Basics)}
            >
              {t('ui.antag_info_vampire.basics')}
            </Tabs.Tab>

            {/* Powers on the right */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === InfoTab.Powers}
              onClick={() => setTab(InfoTab.Powers)}
            >
              {t('ui.antag_info_vampire.powers')}
            </Tabs.Tab>
          </Tabs>
        </Box>

        {/* Re-map which component shows for each tab index to match the new ordering */}
        {tab === InfoTab.General && <VampireGuide />}
        {tab === InfoTab.Basics && <VampireIntroduction setTab={setTab} />}
        {tab === InfoTab.Powers && <PowerSection />}
      </Window.Content>
    </Window>
  );
};

const VampireIntroduction = (props: {
  setTab: React.Dispatch<SetStateAction<InfoTab>>;
}) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { objectives } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow maxHeight="220px">
        <ObjectivePrintout objectives={objectives} />
      </Stack.Item>
      <Stack.Item textAlign="center">
        <Button
          fluid
          align="middle"
          fontSize="200%"
          onClick={() => props.setTab(InfoTab.General)}
        >
          {t('ui.antag_info_vampire.read_the_guide')}
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

enum GuideTab {
  Basics = 1,
  Masquerade,
  Humanity,
  Society,
  Leveling,
  Vitae,
  Combat,
  Lair,
  Structures,
  Vassals,
}

const VampireGuide = () => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const [tab, setTab] = useState(GuideTab.Basics);

  // small vertical padding for each tab; tweak values as desired
  const guideTabStyle = { paddingTop: '10px', paddingBottom: '10px' } as const;

  return (
    <Section title={t('ui.antag_info_vampire.guide')}>
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Basics}
              onClick={() => setTab(GuideTab.Basics)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.the_basics')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Masquerade}
              onClick={() => setTab(GuideTab.Masquerade)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.the_masquerade')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Humanity}
              onClick={() => setTab(GuideTab.Humanity)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.humanity')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Society}
              onClick={() => setTab(GuideTab.Society)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.princes_society')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Leveling}
              onClick={() => setTab(GuideTab.Leveling)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.leveling')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Vitae}
              onClick={() => setTab(GuideTab.Vitae)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.vitae')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Combat}
              onClick={() => setTab(GuideTab.Combat)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.combat')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Lair}
              onClick={() => setTab(GuideTab.Lair)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.your_lair')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Structures}
              onClick={() => setTab(GuideTab.Structures)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.structures')}
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === GuideTab.Vassals}
              onClick={() => setTab(GuideTab.Vassals)}
              style={guideTabStyle}
            >
              {t('ui.antag_info_vampire.vassals')}
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
          <VampireGuideContent tab={tab} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type VampireGuideContentProps = {
  tab: GuideTab;
};

function getVampireGuideSuffix(tab: GuideTab): string {
  switch (tab) {
    case GuideTab.Basics:
      return 'basics';
    case GuideTab.Masquerade:
      return 'masquerade';
    case GuideTab.Humanity:
      return 'humanity';
    case GuideTab.Society:
      return 'society';
    case GuideTab.Leveling:
      return 'leveling';
    case GuideTab.Vitae:
      return 'vitae';
    case GuideTab.Combat:
      return 'combat';
    case GuideTab.Lair:
      return 'lair';
    case GuideTab.Structures:
      return 'structures';
    case GuideTab.Vassals:
      return 'vassals';
    default:
      return 'basics';
  }
}

const VampireGuideContent = (props: VampireGuideContentProps) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const suffix = getVampireGuideSuffix(props.tab);
  const subtitle = t(`ui.antag_info_vampire.guide_${suffix}_subtitle`);

  return (
    <Box>
      <Box fontSize="18px" textColor="red" bold>
        {t(`ui.antag_info_vampire.guide_${suffix}_title`)}
      </Box>
      {subtitle && (
        <Box fontSize="13px" textColor="label" italic mb={1}>
          {subtitle}
        </Box>
      )}
      <Box
        fontSize="13px"
        style={{ whiteSpace: 'pre-wrap', lineHeight: 1.35 }}
      >
        {t(`ui.antag_info_vampire.guide_${suffix}_body`)}
      </Box>
    </Box>
  );
};

const PowerSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { t } = usePreferencesLocalization(data);
  const { powers } = data;
  if (!powers) {
    return <Section minHeight="220px" />;
  }

  const [tab, setTab] = useState(0);
  return (
    <Section title={t('ui.antag_info_vampire.powers')}>
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            {powers.map((power, index) => (
              <Tabs.Tab
                key={index}
                selected={tab === index}
                onClick={() => setTab(index)}
              >
                <Stack align="center">
                  <Stack.Item>
                    <DmIcon
                      inline
                      icon={power.icon}
                      icon_state={power.icon_state}
                      fallback={
                        <Icon mr={1} name="spinner" spin fontSize="30px" />
                      }
                      width="32px"
                      style={{
                        imageRendering: 'pixelated',
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>{power.name}</Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          {powers.map(
            (power, index) =>
              tab === index && (
                <Box key={index}>
                  <Box inline bold textColor="red">
                    {power.cost !== '0' && (
                      <>{t('ui.antag_info_vampire.blood_cost')}: {power.cost}</>
                    )}
                    {power.cost !== '0' && power.constant_cost !== '0' && (
                      <br />
                    )}
                    {power.constant_cost !== '0' && (
                      <>{t('ui.antag_info_vampire.blood_drain')}: {power.constant_cost}</>
                    )}
                    {(power.cost !== '0' || power.constant_cost !== '0') &&
                      power.cooldown !== '0' && (
                        <>
                          <br />
                          <br />
                        </>
                      )}
                    {power.cooldown !== '0' && (
                      <>
                        {t('ui.antag_info_vampire.cooldown')}: {power.cooldown}{' '}
                        {t('ui.common.seconds_lower')}
                        <br />
                        <br />
                      </>
                    )}
                  </Box>
                  <Box
                    style={{ whiteSpace: 'pre-wrap', lineHeight: '1' }}
                    dangerouslySetInnerHTML={{
                      __html: sanitizeText(
                        power.explanation.replace(/\n/g, '\n\n'),
                      ),
                    }}
                  />
                </Box>
              ),
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ClanSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { t } = usePreferencesLocalization(data);
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section title={t('ui.antag_info_vampire.clan')}>
        <Stack vertical>
          <Stack.Item fontSize="20px">
            <Box inline textColor="red">
              {t('ui.antag_info_vampire.not_in_clan')}
            </Box>
          </Stack.Item>
          <Stack.Item>
            {t('ui.antag_info_vampire.determine_clan')}
          </Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Section title={t('ui.antag_info_vampire.clan')}>
      {clan.map((ClanInfo, index) => (
        <Stack key={index}>
          <Stack.Item>
            <DmIcon
              icon={ClanInfo.icon}
              icon_state={ClanInfo.icon_state}
              fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
              width="128px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack.Item textAlign="center">
              <Box inline fontSize="20px" textColor="red">
                {t('ui.antag_info_vampire.part_of_clan_prefix')}{' '}
                <b>{ClanInfo.name}!</b>
              </Box>
            </Stack.Item>
            <Box
              fontSize="16px"
              dangerouslySetInnerHTML={{ __html: ClanInfo.description }}
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
