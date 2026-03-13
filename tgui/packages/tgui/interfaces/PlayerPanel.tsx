// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Slider,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  mob_name: string;
  mob_type: string;
  admin_mob_type: string;
  client_ckey: string;
  client_rank: string;
  ranks: string;
  last_ckey: string;
  playtimes_enabled: boolean;
  playtime: string;
  godmode: boolean;
  is_frozen: boolean;
  is_slept: boolean;
  client_muted: number;
  current_time: string;
  data_related_ip: string;
  data_related_cid: string;
  data_player_join_date: string;
  data_account_join_date: string;
  data_byond_version: string;
  data_old_names: string;

  glob_mute_bits: {
    name: string;
    bitflag: number;
  }[];

  glob_limbs: {
    [key: string]: string;
  };

  transformables: {
    name: string;
    color: string;
    types: {
      name: string;
      key: string;
    }[];
  }[];
};

const PAGES = [
  {
    titleKey: 'ui.player_panel.tab_general',
    component: () => GeneralActions,
    color: 'green',
    icon: 'tools',
  },
  {
    titleKey: 'ui.player_panel.tab_mob',
    component: () => PhysicalActions,
    color: 'yellow',
    icon: 'bolt',
    canAccess: (data) => {
      return !!data.mob_type.includes('/mob/living');
    },
  },
  {
    titleKey: 'ui.player_panel.tab_transform',
    component: () => TransformActions,
    color: 'orange',
    icon: 'exchange-alt',
  },
  {
    titleKey: 'ui.player_panel.tab_punish',
    component: () => PunishmentActions,
    color: 'red',
    icon: 'gavel',
  },
  {
    titleKey: 'ui.player_panel.tab_fun',
    component: () => FunActions,
    color: 'blue',
    icon: 'laugh',
  },
  {
    titleKey: 'ui.player_panel.tab_other',
    component: () => OtherActions,
    color: 'blue',
    icon: 'crosshairs',
  },
];

function isPresent<T>(value: T | null): value is T {
  return value !== null;
}

export const PlayerPanel = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [pageIndex, setPageIndex] = useState(0);
  const PageComponent = PAGES[pageIndex].component();

  const {
    mob_name,
    mob_type,
    client_ckey,
    client_rank,
    ranks,
    last_ckey,
    playtimes_enabled,
    playtime,
  } = data;

  return (
    <Window title={`${mob_name} ${t('ui.player_panel.title_suffix')}`} width={650} height={500}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item width="80px" color="label" align="center">
              {t('ui.player_panel.name')}
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                width="100%"
                value={mob_name}
                onEnter={(value) => act('set_name', { name: value })}
              />
            </Flex.Item>
            {!!client_ckey && (
              <Flex.Item>
                <Box inline ml=".75rem" mr=".5rem" color="label">
                  {t('ui.player_panel.rank')}
                </Box>
                <Flex.Item inline>
                  <Button
                    minWidth="11rem"
                    textAlign="center"
                    onClick={() => act('edit_rank')}
                  >
                    {client_rank}
                  </Button>
                </Flex.Item>
              </Flex.Item>
            )}
          </Flex>
          <Flex mt={1} align="center" wrap="wrap" justify="flex-end">
            <Flex.Item width="80px" color="label">
              {t('ui.player_panel.mob_type')}
            </Flex.Item>
            <Flex.Item grow={1} align="right">
              {mob_type}
            </Flex.Item>
            <Flex.Item align="right">
              <Button
                minWidth="11rem"
                textAlign="center"
                ml=".5rem"
                icon="window-restore"
                onClick={() => act('access_variables')}
              >
                {t('ui.player_panel.access_variables')}
              </Button>
            </Flex.Item>
            {!!client_ckey && (
              <Flex.Item>
                <Button
                  minWidth="11rem"
                  textAlign="center"
                  ml=".5rem"
                  icon="window-restore"
                  disabled={!playtimes_enabled}
                  onClick={() => act('access_playtimes')}
                >
                  {playtimes_enabled ? playtime : t('ui.player_panel.playtimes')}
                </Button>
              </Flex.Item>
            )}
          </Flex>
          {(!!client_ckey || !!last_ckey) && (
            <Flex mt={1} align="center">
              <Flex.Item width="80px" color="label">
                {client_ckey
                  ? t('ui.player_panel.client')
                  : t('ui.player_panel.last_client')}
              </Flex.Item>
              <Flex.Item tooltip grow={1}>
                <Tooltip
                  position="bottom"
                  content={ranks || t('ui.player_panel.no_additional_ranks')}
                >
                  <Box
                    inline
                    style={{
                      borderBottom: ranks
                        ? '2px dotted rgba(255, 255, 255, 0.8)'
                        : 'none',
                    }}
                  >
                    {client_ckey || last_ckey}
                  </Box>
                </Tooltip>

                {!client_ckey && !!last_ckey && (
                  <Button
                    ml={1}
                    icon="magnifying-glass"
                    tooltip={t('ui.player_panel.get_current_panel')}
                    onClick={() => act('open_latest_panel')}
                  />
                )}
              </Flex.Item>

              {!!client_ckey && (
                <Flex.Item align="right">
                  <Button
                    minWidth="11rem"
                    textAlign="center"
                    mx=".5rem"
                    icon="comment-dots"
                    onClick={() => act('private_message')}
                  >
                    {t('ui.player_panel.private_message')}
                  </Button>
                  <Button
                    minWidth="11rem"
                    textAlign="center"
                    icon="phone-alt"
                    onClick={() => act('subtle_message')}
                  >
                    {t('ui.player_panel.subtle_message')}
                  </Button>
                </Flex.Item>
              )}
            </Flex>
          )}
        </Section>
        <Flex grow>
          <Flex.Item>
            <Section fitted>
              <Tabs vertical>
                {PAGES
                  .map((page, index) =>
                    !page.canAccess || page.canAccess(data)
                      ? { page, index }
                      : null
                  )
                  .filter(isPresent)
                  .map(({ page, index }) => (
                    <Tabs.Tab
                      key={index}
                      color={page.color}
                      selected={index === pageIndex}
                      icon={page.icon}
                      onClick={() => setPageIndex(index)}
                    >
                      {t(page.titleKey)}
                    </Tabs.Tab>
                  ))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item grow>
            <PageComponent />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const GeneralActions = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { client_ckey, mob_type, admin_mob_type } = data;
  return (
    <Section>
      <Section title={t('ui.player_panel.damage')}>
        <Flex>
          <Button
            width="100%"
            icon="heart"
            color="green"
            disabled={!mob_type.includes('/mob/living')}
            onClick={() => act('heal')}
          >
            {t('ui.player_panel.rejuvenate')}
          </Button>
          <Button
            width="100%"
            height="100%"
            icon="bolt"
            color="orange"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('smite')}
          >
            {t('ui.player_panel.smite')}
          </Button>
        </Flex>
      </Section>

      <Section title={t('ui.player_panel.teleportation')}>
        <Flex>
          <Button.Confirm
            width="100%"
            icon="reply"
            onClick={() => act('bring')}
          >
            {t('ui.player_panel.bring')}
          </Button.Confirm>
          <Button width="100%" onClick={() => act('orbit')}>
            {t('ui.player_panel.orbit')}
          </Button>
          <Button.Confirm
            width="100%"
            height="100%"
            icon="share"
            onClick={() => act('jump_to')}
          >
            {t('ui.player_panel.jump_to')}
          </Button.Confirm>
        </Flex>
      </Section>

      <Section title={t('ui.player_panel.miscellaneous')}>
        <Flex>
          <Button
            width="100%"
            icon="user-tie"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('select_equipment')}
          >
            {t('ui.player_panel.select_equipment')}
          </Button>
          <Button.Confirm
            icon="trash-alt"
            width="100%"
            height="100%"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('strip')}
          >
            {t('ui.player_panel.drop_all_items')}
          </Button.Confirm>
        </Flex>
        <Flex>
          <Button.Confirm
            icon="snowflake"
            width="100%"
            color="orange"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('cryo')}
          >
            {t('ui.player_panel.send_to_cryo')}
          </Button.Confirm>
          <Button.Confirm
            width="100%"
            height="100%"
            color="orange"
            icon="undo"
            disabled={!mob_type.includes('/mob/dead/observer')}
            tooltip={
              mob_type !== '/mob/dead/observer'
                ? t('ui.player_panel.can_only_be_used_on_ghosts')
                : ''
            }
            onClick={() => act('lobby')}
          >
            {t('ui.player_panel.send_to_lobby')}
          </Button.Confirm>
        </Flex>
      </Section>
      <Section title={t('ui.player_panel.control')}>
        <Flex>
          <Button.Confirm
            width="100%"
            icon="ghost"
            confirmColor="bad"
            disabled={!client_ckey || !mob_type.includes('/mob/living')}
            onClick={() => act('ghost')}
          >
            {t('ui.player_panel.eject_ghost')}
          </Button.Confirm>
          <Button.Confirm
            width="100%"
            confirmColor="bad"
            disabled={
              mob_type.includes('/mob/dead/observer') ||
              !admin_mob_type.includes('/mob/dead/observer')
            }
            onClick={() => act('take_control')}
          >
            {t('ui.player_panel.take_control')}
          </Button.Confirm>
          <Button.Confirm
            width="100%"
            height="100%" // weird ass bug here, so height set to 100%
            icon="ghost"
            tooltip={t('ui.player_panel.offers_control_to_ghosts')}
            disabled={!mob_type.includes('/mob/living')}
            onClick={() => act('offer_control')}
          >
            {t('ui.player_panel.offer_control')}
          </Button.Confirm>
        </Flex>
      </Section>
    </Section>
  );
};

const PhysicalActions = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { glob_limbs, godmode, mob_type } = data;
  const [mobScale, setMobScale] = useState(1);
  const limbs = Object.keys(glob_limbs);
  const limb_flags = limbs.map((_, i) => 1 << i);
  const [delimbOption, setDelimbOption] = useState(0);

  return (
    <Section fill>
      <Section
        title={t('ui.player_panel.traits')}
        buttons={
          <Button
            icon={godmode ? 'check-square-o' : 'square-o'}
            color={godmode ? 'green' : 'transparent'}
            onClick={() => act('toggle_godmode')}
          >
            {t('ui.player_panel.god_mode')}
          </Button>
        }
      >
        <Flex>
          <Button
            width="100%"
            icon="paw"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('species')}
          >
            {t('ui.player_panel.species')}
          </Button>
          <Button
            width="100%"
            icon="bolt"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('quirk')}
          >
            {t('ui.player_panel.quirks')}
          </Button>
          <Button
            width="100%"
            height="100%"
            icon="magic"
            onClick={() => act('spell')}
          >
            {t('ui.player_panel.spells')}
          </Button>
        </Flex>
        <Flex>
          <Button
            width="100%"
            icon="fist-raised"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() => act('martial_art')}
          >
            {t('ui.player_panel.martial_arts')}
          </Button>
          <Button
            width="100%"
            icon="lightbulb"
            onClick={() => act('skill_panel')}
          >
            {t('ui.player_panel.skills')}
          </Button>
          <Button
            width="100%"
            height="100%"
            icon="comment-dots"
            onClick={() => act('languages')}
          >
            {t('ui.player_panel.languages')}
          </Button>
        </Flex>
      </Section>
      <Section
        title={t('ui.player_panel.limbs')}
        buttons={
          <Flex>
            {limbs.map((val, index) => (
              <Button.Checkbox
                key={index}
                height="100%"
                checked={delimbOption & limb_flags[index]}
                disabled={!mob_type.includes('/mob/living/carbon/human')}
                onClick={() =>
                  setDelimbOption(
                    delimbOption & limb_flags[index]
                      ? delimbOption & ~limb_flags[index]
                      : delimbOption | limb_flags[index],
                  )
                }
              >
                {val}
              </Button.Checkbox>
            ))}
          </Flex>
        }
      >
        <Flex>
          <Button.Confirm
            width="100%"
            icon="unlink"
            color="red"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() =>
              act('limb', {
                limbs: limb_flags.map(
                  (val, index) =>
                    !!(delimbOption & val) && glob_limbs[limbs[index]],
                ),
                delimb_mode: true,
              })
            }
          >
            {t('ui.player_panel.delimb')}
          </Button.Confirm>
          <Button.Confirm
            width="100%"
            height="100%"
            icon="link"
            color="green"
            disabled={!mob_type.includes('/mob/living/carbon/human')}
            onClick={() =>
              act('limb', {
                limbs: limb_flags.map(
                  (val, index) =>
                    !!(delimbOption & val) && glob_limbs[limbs[index]],
                ),
              })
            }
          >
            {t('ui.player_panel.relimb')}
          </Button.Confirm>
        </Flex>
      </Section>
      <Section
        title={t('ui.player_panel.scale')}
        buttons={
          <Button
            icon="sync"
            onClick={() => {
              setMobScale(1);
              act('scale', { new_scale: 1 });
            }}
          >
            {t('ui.common.reset')}
          </Button>
        }
      >
        <Flex mt={1}>
          <Slider
            minValue={0.25}
            maxValue={8}
            value={mobScale}
            stepPixelSize={12}
            step={0.25}
            onChange={(e, value) => {
              setMobScale(value); // Update slider value
              act('scale', { new_scale: value }); // Update mob's value
            }}
            unit="x"
          />
        </Flex>
      </Section>
      <Section title={t('ui.player_panel.speak')}>
        <Flex mt={1}>
          <Flex.Item width="100px" color="label">
            {t('ui.player_panel.force_say')}
          </Flex.Item>
          <Flex.Item grow={1}>
            <Input
              width="100%"
              onEnter={(value) => act('force_say', { to_say: value })}
            />
          </Flex.Item>
        </Flex>
        <Flex mt={2}>
          <Flex.Item width="100px" color="label">
            {t('ui.player_panel.force_emote')}
          </Flex.Item>
          <Flex.Item grow={1}>
            <Input
              width="100%"
              onEnter={(value) => act('force_emote', { to_emote: value })}
            />
          </Flex.Item>
        </Flex>
      </Section>
    </Section>
  );
};

const TransformActions = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { transformables, mob_type } = data;
  return (
    <Section>
      <Button
        width="100%"
        py=".5rem"
        textAlign="center"
        onClick={() => act('transform', { newType: '/mob/living' })}
      >
        {t('ui.player_panel.custom')}
      </Button>

      {transformables.map((transformables_category) => {
        return (
          <Section title={transformables_category.name} key={0}>
            <Flex wrap="wrap" justify="space-between">
              {transformables_category.types.map((transformables_type) => {
                return (
                  <Flex.Item key={0} width="calc(33.3% - .125rem)" mb=".25rem">
                    <Button.Confirm
                      width="100%"
                      height="100%"
                      color={transformables_category.color}
                      disabled={mob_type === transformables_type.key}
                      onClick={() =>
                        act('transform', {
                          newType: transformables_type.key,
                          newTypeName: transformables_type.name,
                        })
                      }
                    >
                      {transformables_type.name}
                    </Button.Confirm>
                  </Flex.Item>
                );
              })}
            </Flex>
          </Section>
        );
      })}
    </Section>
  );
};

const PunishmentActions = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    client_ckey,
    mob_type,
    is_frozen,
    is_slept,
    glob_mute_bits,
    client_muted,
    data_related_cid,
    data_related_ip,
    data_byond_version,
    data_player_join_date,
    data_account_join_date,
    data_old_names,
    current_time,
  } = data;
  return (
    <Section>
      <Flex>
        <Button
          width="50%"
          py=".5rem"
          icon="clipboard-list"
          color="orange"
          textAlign="center"
          disabled={!client_ckey}
          onClick={() => act('notes')}
        >
          {t('ui.player_panel.notes')}
        </Button>
        <Button
          width="50%"
          height="100%"
          py=".5rem"
          icon="clipboard-list"
          color="orange"
          textAlign="center"
          onClick={() => act('logs')}
        >
          {t('ui.player_panel.logs')}
        </Button>
      </Flex>
      <Section title={t('ui.player_panel.contain')}>
        <Flex>
          <Button
            width="100%"
            color={is_frozen ? 'orange' : ''}
            icon={is_frozen ? 'check-square-o' : 'square-o'}
            disabled={!mob_type.includes('/mob/living')}
            onClick={() => act('freeze')}
          >
            {t('ui.player_panel.freeze')}
          </Button>
          <Button
            width="100%"
            color={is_slept ? 'orange' : ''}
            icon={is_slept ? 'check-square-o' : 'square-o'}
            disabled={!mob_type.includes('/mob/living')}
            onClick={() => act('sleep')}
          >
            {t('ui.player_panel.sleep')}
          </Button>
          <Button.Confirm
            width="100%"
            height="100%"
            icon="share"
            color="bad"
            disabled={!mob_type.includes('/mob/living')}
            onClick={() => act('prison')}
          >
            {t('ui.player_panel.admin_prison')}
          </Button.Confirm>
        </Flex>
      </Section>

      <Section title={t('ui.player_panel.banishment')}>
        <Flex>
          <Button.Confirm
            width="100%"
            icon="ban"
            color="red"
            disabled={!client_ckey}
            onClick={() => act('kick')}
          >
            {t('ui.player_panel.kick')}
          </Button.Confirm>
          <Button
            width="100%"
            icon="gavel"
            color="red"
            disabled={!client_ckey}
            onClick={() => act('ban')}
          >
            {t('ui.player_panel.ban')}
          </Button>
          <Button.Confirm
            width="100%"
            height="100%"
            icon="gavel"
            color="red"
            disabled={!client_ckey}
            onClick={() => act('sticky_ban')}
          >
            {t('ui.player_panel.sticky_ban')}
          </Button.Confirm>
        </Flex>
      </Section>

      <Section
        title={t('ui.player_panel.mute')}
        buttons={
          <>
            <Button
              icon="lock-open"
              color="green"
              disabled={!client_ckey}
              onClick={() => act('unmute_all')}
            >
              {t('ui.player_panel.unmute_all')}
            </Button>
            <Button
              icon="lock"
              color="red"
              disabled={!client_ckey}
              onClick={() => act('mute_all')}
            >
              {t('ui.player_panel.mute_all')}
            </Button>
          </>
        }
      >
        <Flex>
          {glob_mute_bits.map((bit, i) => {
            const isMuted = client_muted && client_muted & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                icon={isMuted ? 'check-square-o' : 'square-o'}
                color={isMuted ? 'bad' : ''}
                disabled={!client_ckey}
                onClick={() =>
                  act('mute', {
                    mute_flag: !isMuted
                      ? client_muted | bit.bitflag
                      : client_muted & ~bit.bitflag,
                  })
                }
              >
                {bit.name}
              </Button>
            );
          })}
        </Flex>
      </Section>
      <Section
        title={t('ui.player_panel.investigate')}
        buttons={
          <Flex>
            <Flex.Item align="center" mr=".5rem" color="label">
              {t('ui.player_panel.related_accounts_by')}
            </Flex.Item>
            <Button
              minWidth="5rem"
              color="orange"
              textAlign="center"
              mr=".5rem"
              disabled={!data_related_cid}
              onClick={() => act('related_accounts', { related_thing: 'CID' })}
            >
              {t('ui.player_panel.cid')}
            </Button>
            <Button
              minWidth="5rem"
              height="100%"
              color="orange"
              textAlign="center"
              disabled={!data_related_ip}
              onClick={() => act('related_accounts', { related_thing: 'IP' })}
            >
              {t('ui.player_panel.ip')}
            </Button>
          </Flex>
        }
      >
        <Collapsible width="100%" color="orange" title={t('ui.player_panel.details')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.now')} color="label">
              {current_time}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.player_panel.account_made')}>
              {data_account_join_date}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.player_panel.first_joined_server')}>
              {data_player_join_date}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.player_panel.byond_version')}>
              {data_byond_version}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.player_panel.old_names')}>
              {data_old_names}
            </LabeledList.Item>
          </LabeledList>
        </Collapsible>
      </Section>
    </Section>
  );
};

const FunActions = () => {
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();

  const colours = {
    White: '#a4bad6',
    Dark: '#42474D',
    Red: '#c51e1e',
    'Red Bright': '#FF0000',
    Velvet: '#660015',
    Green: '#059223',
    Blue: '#6685f5',
    Purple: '#800080',
    'Purple Dark': '#5000A0',
    Narsie: '#973e3b',
    Ratvar: '#BE8700',
  };

  const [lockExplode, setLockExplode] = useState(true);
  const [empMode, setEmpMode] = useState(false);
  const [expPower, setExpPower] = useState(8);
  const [narrateSize, setNarrateSize] = useState(1);
  const [narrateMessage, setNarrateMessage] = useState('');
  const [narrateColour, setNarrateColour] = useState(Object.keys(colours)[0]);
  const [narrateFont, setNarrateFont] = useState('Verdana');
  const [narrateBold, setNarrateBold] = useState(false);
  const [narrateItalic, setNarrateItalic] = useState(false);
  const [narrateGlobal, setNarrateGlobal] = useState(false);
  const [narrateRange, setNarrateRange] = useState(7);

  const narrateStyles = {
    color: colours[narrateColour],
    'font-size': `${narrateSize}rem`,
    'font-weight': narrateBold ? 'bold' : '',
    'font-family': narrateFont,
    'font-style': narrateItalic ? 'italic' : '',
  };

  return (
    <Section fill>
      <NoticeBox info textAlign="center">
        {t('ui.player_panel.features_centered_on_viewport')}
      </NoticeBox>

      <Section
        title={t('ui.player_panel.explosion')}
        buttons={
          <>
            <Button.Checkbox
              checked={empMode}
              color="transparent"
              onClick={() => setEmpMode(!empMode)}
            >
              {t('ui.player_panel.emp_mode')}
            </Button.Checkbox>
            <Button
              icon={lockExplode ? 'lock' : 'lock-open'}
              onClick={() => setLockExplode(!lockExplode)}
              color={lockExplode ? 'green' : 'bad'}
            >
              {lockExplode ? t('ui.common.locked') : t('ui.common.unlocked')}
            </Button>
          </>
        }
      >
        <Flex align="right" grow={1} mt={1}>
          <Flex.Item>
            <Button
              width="100%"
              height="100%"
              color="red"
              disabled={lockExplode}
              onClick={() =>
                act('explode', { power: expPower, emp_mode: empMode })
              }
            >
              <Box height="100%" pt={2} pb={2} textAlign="center">
                {t('ui.player_panel.detonate')}
              </Box>
            </Button>
          </Flex.Item>
          <Flex.Item ml={1} grow={1}>
            <Slider
              unit="Range"
              value={expPower}
              stepPixelSize={15}
              onChange={(e, value) => setExpPower(value)}
              ranges={{
                green: [0, 8],
                orange: [8, 15],
                red: [15, 30],
              }}
              minValue={1}
              maxValue={30}
              height="100%"
            />
          </Flex.Item>
        </Flex>
      </Section>
      <Section
        title={t('ui.player_panel.narrate')}
        buttons={
          <Button
            icon={narrateGlobal ? 'check-square-o' : 'square-o'}
            color={narrateGlobal ? 'red' : 'transparent'}
            onClick={() => setNarrateGlobal(!narrateGlobal)}
          >
            {t('ui.player_panel.global_narrate')}
          </Button>
        }
      >
        <Flex width="100%">
          <Flex width="100%" wrap>
            <Flex.Item width="52%">
              <LabeledList>
                <LabeledList.Item label={t('ui.player_panel.colour')}>
                  <Dropdown
                    width="calc(100% - 1rem)"
                    options={Object.keys(colours)}
                    selected={narrateColour}
                    onSelected={(value) => setNarrateColour(value)}
                  />
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.player_panel.font')}>
                  <Dropdown
                    width="calc(100% - 1rem)"
                    selected={narrateFont}
                    options={[
                      'Verdana',
                      'Consolas',
                      'Trebuchet MS',
                      'Comic Sans MS',
                      'Times New Roman',
                    ]}
                    onSelected={(value) => setNarrateFont(value)}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            <Flex.Item width="20%">
              <LabeledList>
                <LabeledList.Item label={t('ui.player_panel.bold')}>
                  <Button.Checkbox
                    checked={narrateBold}
                    height="100%"
                    color="transparent"
                    onClick={() => setNarrateBold(!narrateBold)}
                  />
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.player_panel.italic')}>
                  <Button.Checkbox
                    checked={narrateItalic}
                    height="100%"
                    color="transparent"
                    onClick={() => setNarrateItalic(!narrateItalic)}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            <Flex.Item width="28%">
              <LabeledList>
                <LabeledList.Item label={t('ui.player_panel.size')}>
                  <NumberInput
                    width="100%"
                    value={narrateSize}
                    minValue={1}
                    maxValue={6}
                    unit="rem"
                    // align="center"
                    step={1}
                    stepPixelSize={25}
                    onChange={(value) => setNarrateSize(value)}
                  />
                </LabeledList.Item>
                {!narrateGlobal && (
                  <LabeledList.Item label={t('ui.player_panel.range')}>
                    <NumberInput
                      width="100%"
                      value={narrateRange}
                      minValue={1}
                      maxValue={14}
                      unit="Tiles"
                      step={1}
                      // align="center"
                      stepPixelSize={25}
                      onChange={(value) => setNarrateRange(value)}
                    />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Flex>

        <Flex mt="1rem">
          <Flex.Item width="100%" mr="1rem">
            <Input
              width="100%"
              my=".5rem"
              onEnter={(value) => setNarrateMessage(value)}
            />
          </Flex.Item>

          <Button
            color="green"
            p=".5rem"
            textAlign="center"
            disabled={!narrateMessage}
            onClick={() =>
              act('narrate', {
                message: narrateMessage,
                classes: narrateStyles,
                range: narrateRange,
                mode_global: narrateGlobal,
              })
            }
          >
            {t('ui.player_panel.broadcast')}
          </Button>
        </Flex>

        <Box
          style={narrateStyles}
          mt="1rem"
          pl=".5rem"
          width="37rem"
          maxWidth="37rem"
        >
          {narrateMessage}
        </Box>
      </Section>
    </Section>
  );
};

const OtherActions = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { mob_type, client_ckey } = data;

  return (
    <Section fill>
      <Section title={t('ui.player_panel.miscellaneous_features')}>
        <Button
          width="100%"
          p=".5rem"
          mb=".5rem"
          textAlign="center"
          disabled={!client_ckey}
          onClick={() => act('traitor_panel')}
        >
          {t('ui.player_panel.traitor_panel')}
        </Button>
        <Button
          width="100%"
          p=".5rem"
          mb=".5rem"
          textAlign="center"
          disabled={!client_ckey}
          onClick={() => act('commend')}
        >
          {t('ui.player_panel.commend_behavior')}
        </Button>
        <Button
          width="100%"
          p=".5rem"
          mb=".5rem"
          textAlign="center"
          disabled={!client_ckey}
          onClick={() => act('play_sound_to')}
        >
          {t('ui.player_panel.play_sound_to')}
        </Button>
        <Button
          width="100%"
          p=".5rem"
          mb=".5rem"
          textAlign="center"
          disabled={
            !client_ckey || !mob_type.includes('/mob/living/carbon/human')
          }
          onClick={() => act('apply_client_quirks')}
        >
          {t('ui.player_panel.apply_client_quirks')}
        </Button>
      </Section>
    </Section>
  );
};
