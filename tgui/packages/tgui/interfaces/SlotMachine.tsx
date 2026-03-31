import { useEffect, useRef, useState } from 'react';
import { Blink, Box, Button, Icon, Section, Stack } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  icons: string[];
  reels: Reel[];
  balance: number;
  working: number;
  winning: number;
  money: number;
  cost: number;
  plays: number;
  jackpots: number;
  jackpot: number;
  paymode: number;
};

type Reel = {
  icons: string[];
  spinning: number;
};

type IconMeta = {
  color: string;
};

const iconMetaByName: Record<string, IconMeta> = {
  'fa-7': { color: '#b22' },
  'fa-star': { color: '#fd6' },
  'fa-lemon': { color: '#ce0' },
  'fa-apple-whole': { color: '#d64' },
  'fa-biohazard': { color: '#2c0' },
  'fa-dollar-sign': { color: '#08b' },
  'fa-bomb': { color: '#876' },
};

const pluralS = (amount: number) => {
  return amount === 1 ? '' : 's';
};

const slotIconToColor = (iconName: string): string => {
  return iconMetaByName[iconName]?.color || '#f0f';
};

const pickRandomMany = <T extends unknown>(items: T[], n: number) => {
  const result: T[] = [];
  for (let i = 0; i < n; i += 1) {
    result.push(pickRandom(items));
  }
  return result;
};

const pickRandom = <T extends unknown>(items: T[]) => {
  return items[Math.floor(Math.random() * items.length)];
};

export const SlotMachine = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { icons, cost, reels, balance } = data;
  const spinning = data.working === 1;

  return (
    <Window width={300} height={396}>
      <Window.Content>
        <Banner />
        <Section>
          <div className={'SlotMachine__Reels'}>
            {reels.map((reel, i) => (
              <div key={i} className={'SlotMachine__Reel'}>
                <IconStrip
                  icons={icons}
                  iconsNeeded={reel.icons}
                  spinning={spinning}
                />
              </div>
            ))}
          </div>
        </Section>
        <Stack align={'stretch'}>
          <Stack.Item grow={1}>
            <Section
              fill
              title={t('ui.common.balance')}
              buttons={
                <Button onClick={() => act('payout')} disabled={balance <= 0}>
                  {t('ui.slot_machine.refund')}
                </Button>
              }
            >
              <Box textAlign={'center'} fontSize={2}>
                {formatMoney(balance)} cr
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill>
              <Button
                fluid
                textAlign={'center'}
                fontSize={3}
                color={'green'}
                onClick={() => act('spin')}
                disabled={spinning || balance < cost}
              >
                {t('ui.slot_machine.spin')}
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getBannerPages = () => [
  BannerTitle,
  BannerOnlyFewCreds,
  BannerPrizeMoney,
  BannerTitle,
  BannerJackpot,
  BannerStats,
];

const Banner = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [page, setPage] = useState(0);
  const winningTexts = [
    null,
    t('ui.slot_machine.free_spins'),
    t('ui.slot_machine.prize'),
    t('ui.slot_machine.big_prize'),
    t('ui.slot_machine.jackpot_banner'),
  ];

  useEffect(() => {
    const interval = setInterval(() => {
      setPage((page) => (page + 1) % getBannerPages().length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const winningText = winningTexts[data.winning];
  if (winningText) {
    return (
      <Section className={'SlotMachine__Banner SlotMachine__Banner--winning'}>
        <BannerTitle text={winningText} />
      </Section>
    );
  }

  const Component = getBannerPages()[page];

  return (
    <Section className={'SlotMachine__Banner'}>
      <Component />
    </Section>
  );
};

type BannerTitleProps = {
  text?: string;
};

const BannerTitle = (props: BannerTitleProps) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const bannerTexts = [
    t('ui.slot_machine.spin_spin'),
    t('ui.slot_machine.warmed_up'),
    t('ui.slot_machine.hot_slots'),
    t('ui.slot_machine.spin_and_win'),
    t('ui.slot_machine.believe_it'),
    t('ui.slot_machine.zero_to_hero'),
    t('ui.slot_machine.just_one_more'),
    t('ui.slot_machine.spin_of_fate'),
    t('ui.slot_machine.bonus_time'),
    t('ui.slot_machine.born_to_spin'),
    t('ui.slot_machine.nice_spin'),
    t('ui.slot_machine.no_spin_no_win'),
    t('ui.slot_machine.bet_and_forget'),
    t('ui.slot_machine.honk_for_luck'),
    t('ui.slot_machine.debt_for_life'),
    t('ui.slot_machine.spingularity'),
    t('ui.slot_machine.spin_city'),
    t('ui.slot_machine.burn_and_earn'),
    t('ui.slot_machine.jackpot_soon'),
    t('ui.slot_machine.win_the_day'),
    t('ui.slot_machine.fortune_calls'),
    t('ui.slot_machine.instant_gold'),
    t('ui.slot_machine.dream_bigger'),
    t('ui.slot_machine.winners_only'),
    t('ui.slot_machine.spin_is_life'),
    t('ui.slot_machine.big_one_soon'),
    t('ui.slot_machine.lucky_spin'),
    t('ui.slot_machine.cash_out_no'),
  ];
  const defaultText = useRef(pickRandom(bannerTexts));
  let text = props.text;
  if (!text) {
    if (data.balance <= 0) {
      text = t('ui.slot_machine.insert_coin');
    } else if (data.balance <= 5) {
      text = t('ui.slot_machine.one_last_spin');
    } else {
      text = defaultText.current;
    }
  }
  const letters = text.split('');
  return (
    <div className={'SlotMachine__BannerTitle'}>
      {letters.map((letter, i) => (
        <span key={i}>{letter}</span>
      ))}
    </div>
  );
};

const BannerOnlyFewCreds = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const variant = useRef(pickRandom([0, 1]));

  if (variant.current === 1) {
    return (
      <div>
        {t('ui.slot_machine.for_only')}{' '}
        <Blink interval={200} time={200}>
          <b>{data.cost}</b>
        </Blink>{' '}
        credit{pluralS(data.cost)}!
        <br />
        <Box inline fontSize={'12px'}>
          {t('ui.slot_machine.fix_all_your_problems')}
        </Box>
      </div>
    );
  }

  return (
    <div>
      {t('ui.slot_machine.only')}{' '}
      <Blink interval={200} time={200}>
        <b>{data.cost}</b>
      </Blink>{' '}
      credit{pluralS(data.cost)} {t('ui.slot_machine.for_a_chance')}
      <br />
      {t('ui.slot_machine.to_win')} <b>{t('ui.slot_machine.big')}</b>!
    </div>
  );
};

const BannerPrizeMoney = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <div>
      {t('ui.slot_machine.available_prize_money')}
      <br />
      <b>
        {data.money} credit{pluralS(data.money)}
      </b>
    </div>
  );
};

const BannerJackpot = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <div>
      {t('ui.slot_machine.current_jackpot')}
      <br />
      <b>
        {data.money + data.jackpot} credit{pluralS(data.money + data.jackpot)}!
      </b>
    </div>
  );
};

const BannerStats = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <div>
      <Box inline fontSize={'13px'}>
        {t('ui.slot_machine.so_far_people_have_spun')}{' '}
        <b>
          {data.plays} time{pluralS(data.plays)}
        </b>
      </Box>
      <br />
      {t('ui.slot_machine.and_won')}{' '}
      <b>
        {data.jackpots} jackpot{pluralS(data.jackpots)}!
      </b>
    </div>
  );
};

const ICON_STRIP_LENGTH = 30;

type IconStripProps = {
  icons: string[];
  iconsNeeded: string[];
  spinning?: boolean;
};

const IconStrip = (props: IconStripProps) => {
  const { icons, iconsNeeded, spinning } = props;

  const [drawnIcons, setDrawnIcons] = useState([
    ...pickRandomMany(icons, ICON_STRIP_LENGTH - 3),
    ...iconsNeeded,
  ]);

  useEffect(() => {
    if (spinning) {
      setDrawnIcons((drawnIcons) => [
        ...drawnIcons.slice(-3),
        ...pickRandomMany(icons, ICON_STRIP_LENGTH - 6),
        ...iconsNeeded,
      ]);
    } else {
      setDrawnIcons([
        ...pickRandomMany(icons, ICON_STRIP_LENGTH - 3),
        ...iconsNeeded,
      ]);
    }
  }, [spinning]);

  return (
    <div
      className={classes([
        'SlotMachine__IconStrip',
        spinning && 'SlotMachine__IconStrip--spinning',
      ])}
    >
      {drawnIcons.map((icon, i) => (
        <Icon
          key={i}
          size={2}
          lineHeight={'60px'}
          name={icon}
          color={slotIconToColor(icon)}
          style={{
            display: 'block',
          }}
        />
      ))}
    </div>
  );
};
