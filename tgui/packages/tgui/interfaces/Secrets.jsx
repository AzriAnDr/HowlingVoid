import { useState } from 'react';
import {
  Button,
  Flex,
  LabeledControls,
  NoticeBox,
  RoundGauge,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const lineHeightNormal = 2.79;
const buttonWidthNormal = 12.9;
const lineHeightDebug = 6.09;

const DebuggingTab = (props) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content={t('ui.secrets.maint_access_engie_brig')}
          onClick={() => act('maint_access_engiebrig')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content={t('ui.secrets.maint_access_brig')}
          onClick={() => act('maint_access_brig')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="average"
          lineHeight={lineHeightDebug}
          icon="question"
          fluid
          content={t('ui.secrets.remove_sec_officer_cap')}
          onClick={() => act('infinite_sec')}
        />
      </Stack.Item>
    </Stack>
  );
};

const HelpfulTab = (props) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}
            >
              {t('ui.secrets.admin_button_placeholder')}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.cure_all_diseases')}
              onClick={() => act('clear_virus')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="biohazard"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.trigger_outbreak')}
              onClick={() => act('virus')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}
            >
              {t('ui.secrets.admin_button_placeholder')}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="grin-beam-sweat"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.break_all_lights')}
              onClick={() => act('blackout')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="magic"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.fix_all_lights')}
              onClick={() => act('whiteout')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bomb"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.list_bombers')}
              onClick={() => act('list_bombers')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="signal"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.list_signalers')}
              onClick={() => act('list_signalers')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="robot"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.list_laws')}
              onClick={() => act('list_lawchanges')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="address-book"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.show_manifest')}
              onClick={() => act('manifest')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="dna"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.show_dna')}
              onClick={() => act('dna')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="fingerprint"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.show_fingerprints')}
              onClick={() => act('fingerprints')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="flag"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.toggle_ctf')}
              onClick={() => act('ctfbutton')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="sync-alt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.reset_thunderdome')}
              onClick={() => act('tdomereset')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="moon"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.set_nightshift')}
              onClick={() => act('night_shift_set')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="pencil-alt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.rename_station')}
              onClick={() => act('set_name')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eraser"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.default_station_name')}
              onClick={() => act('reset_name')}
            />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox
              mb={-0.5}
              width={buttonWidthNormal}
              height={lineHeightNormal}
            >
              {t('ui.secrets.admin_button_placeholder')}
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const FunTab = (props) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="robot"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.make_nerd')}
              onClick={() => act('makeNerd')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="flag"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.ctf_instagib_mode')}
              onClick={() => act('ctf_instagib')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.mass_heal_everyone')}
              onClick={() => act('mass_heal')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bolt"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.all_areas_powered')}
              onClick={() => act('power')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="moon"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.all_areas_unpowered')}
              onClick={() => act('unpower')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plug"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.recharge_smes')}
              onClick={() => act('quickpower')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="user-ninja"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.anonymous_names')}
              onClick={() => act('anon_name')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="robot"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.triple_ai_mode')}
              onClick={() => act('tripleAI')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="bullhorn"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.there_can_only_be')}
              onClick={() => act('onlyone')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="grin-beam-sweat"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.summon_guns')}
              onClick={() => act('guns')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="magic"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.summon_magic')}
              onClick={() => act('magic')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="meteor"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.summon_events')}
              onClick={() => act('events')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="hammer"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.egalitarian_station')}
              onClick={() => act('eagles')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="house"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.send_shuttle_back')}
              onClick={() => act('send_shuttle_back')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="oil-well"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.tap_ore_vents')}
              onClick={() => act('ore_vents')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              icon="bullseye"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.custom_portal_storm')}
              onClick={() => act('customportal')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="bomb"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.change_bomb_cap')}
              onClick={() => act('changebombcap')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="dollar-sign"
              lineHeight={lineHeightNormal}
              width={buttonWidthNormal}
              content={t('ui.secrets.department_order_cooldown')}
              onClick={() => act('department_cooldown_override')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const FunForYouTab = (props) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <NoticeBox danger mb={0} width={19.6}>
              <Button
                color="red"
                icon="user-secret"
                fluid
                content={t('ui.secrets.everyone_is_antag')}
                onClick={() => act('antag_all')}
              />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="brain"
                fluid
                content={t('ui.secrets.everyone_gets_brain_damage')}
                onClick={() => act('massbraindamage')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <NoticeBox danger mb={0} width={19.6}>
              <Button
                color="red"
                icon="hand-lizard"
                fluid
                content={t('ui.secrets.change_everyones_species')}
                onClick={() => act('allspecies')}
              />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="paw"
                fluid
                content={t('ui.secrets.change_everyone_to_monkeys')}
                onClick={() => act('monkey')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="black"
            icon="fire"
            fluid
            content={t('ui.secrets.the_floor_is_lava')}
            onClick={() => act('floorlava')}
          />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger mb={0}>
          <Button
            color="black"
            icon="fire"
            fluid
            content={t('ui.secrets.chinese_cartoons')}
            onClick={() => act('anime')}
          />
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="cat"
                fluid
                content={t('ui.secrets.mass_purrbation')}
                onClick={() => act('masspurrbation')}
              />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info width={19.6} mb={0}>
              <Button
                color="blue"
                icon="user"
                fluid
                content={t('ui.secrets.cure_purrbation')}
                onClick={() => act('massremovepurrbation')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="cat"
                fluid
                content={t('ui.secrets.cascade')}
                onClick={() => act('cascade')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="flushed"
                fluid
                content={t('ui.secrets.fully_immerse_everyone')}
                onClick={() => act('massimmerse')}
              />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info width={19.6} mb={0}>
              <Button
                color="blue"
                icon="sync-alt"
                fluid
                content={t('ui.secrets.shatter_immersion')}
                onClick={() => act('unmassimmerse')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <NoticeBox danger width={19.6} mb={0}>
              <Button
                color="red"
                icon="comment-slash"
                fluid
                content={t('ui.secrets.tower_of_babel')}
                onClick={() => act('towerOfBabel')}
              />
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info width={19.6} mb={0}>
              <Button
                color="blue"
                icon="comment"
                fluid
                content={t('ui.secrets.undo_tower_of_babel')}
                onClick={() => act('cureTowerOfBabel')}
              />
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const TAB2NAME = [
  {
    titleKey: 'ui.secrets.tab_debugging',
    blurbKey: 'ui.secrets.debugging_blurb',
    gauge: 5,
    component: DebuggingTab,
  },
  {
    titleKey: 'ui.secrets.tab_helpful',
    blurbKey: 'ui.secrets.helpful_blurb',
    gauge: 25,
    component: HelpfulTab,
  },
  {
    titleKey: 'ui.secrets.tab_fun',
    blurbKey: 'ui.secrets.fun_blurb',
    gauge: 75,
    component: FunTab,
  },
  {
    titleKey: 'ui.secrets.tab_fun_for_you',
    blurbKey: 'ui.secrets.only_fun_for_you_blurb',
    gauge: 95,
    component: FunForYouTab,
  },
];

export const Secrets = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { is_debugger, is_funmin } = data;
  const [tabIndex, setTabIndex] = useState(2);
  const TabComponent = TAB2NAME[tabIndex - 1].component;

  return (
    <Window title={t('ui.secrets.panel_title')} width={500} height={520} theme="admin">
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item mb={1}>
            <Section
              title={t('ui.secrets.section_title')}
              buttons={
                <>
                  <Button
                    color="blue"
                    icon="address-card"
                    content={t('ui.secrets.admin_log')}
                    onClick={() => act('admin_log')}
                  />
                  <Button
                    color="blue"
                    icon="eye"
                    content={t('ui.secrets.show_admins')}
                    onClick={() => act('show_admins')}
                  />
                </>
              }
            >
              <Flex mx={-0.5} align="stretch" justify="center">
                <Flex.Item bold>
                  <NoticeBox color="black">
                    {t('ui.secrets.adminbuse_rule_quote')}
                  </NoticeBox>
                </Flex.Item>
              </Flex>
              <Flex
                textAlign="center"
                mx={-0.5}
                align="stretch"
                justify="center"
              >
                <Flex.Item ml={-10} mr={1}>
                  <Button
                    selected={tabIndex === 2}
                    icon="check-circle"
                    content={t('ui.secrets.tab_helpful')}
                    onClick={() => setTabIndex(2)}
                  />
                </Flex.Item>
                <Flex.Item ml={1}>
                  <Button
                    disabled={is_funmin === 0}
                    selected={tabIndex === 3}
                    icon="smile"
                    content={t('ui.secrets.tab_fun')}
                    onClick={() => setTabIndex(3)}
                  />
                </Flex.Item>
              </Flex>
              <Flex mx={-0.5} align="stretch" justify="center">
                <Flex.Item mt={1}>
                  <Button
                    disabled={is_debugger === 0}
                    selected={tabIndex === 1}
                    icon="glasses"
                    content={t('ui.secrets.tab_debugging')}
                    onClick={() => setTabIndex(1)}
                  />
                </Flex.Item>
                <Flex.Item>
                  <LabeledControls>
                    <LabeledControls.Item
                      minWidth="66px"
                      label={t('ui.secrets.admin_complaint_chance')}
                    >
                      <RoundGauge
                        size={2}
                        value={TAB2NAME[tabIndex - 1].gauge}
                        minValue={0}
                        maxValue={100}
                        alertAfter={100 * 0.7}
                        ranges={{
                          good: [-2, 100 * 0.25],
                          average: [100 * 0.25, 100 * 0.75],
                          bad: [100 * 0.75, 100],
                        }}
                        format={(value) => `${toFixed(value)}%`}
                      />
                    </LabeledControls.Item>
                  </LabeledControls>
                </Flex.Item>
                <Flex.Item mt={1}>
                  <Button
                    disabled={is_funmin === 0}
                    selected={tabIndex === 4}
                    icon="smile-wink"
                    content={t('ui.secrets.tab_fun_for_you')}
                    onClick={() => setTabIndex(4)}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section
              fill={false}
              title={
                `${t(TAB2NAME[tabIndex - 1].titleKey)}: ${t(TAB2NAME[tabIndex - 1].blurbKey)}`
              }
            >
              <TabComponent />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
