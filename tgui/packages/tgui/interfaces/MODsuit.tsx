import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  ColorBox,
  Dimmer,
  Dropdown,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type MODsuitData = {
  ui_theme: string;
  complexity_max: number;
  suit_status: SuitStatus;
  user_status: UserStatus;
  module_custom_status: ModuleCustomStatus;
  module_info: Module[];
  control: string;
  parts: PartData[];
};

type PartData = {
  slot: string;
  name: string;
  deployed: BooleanLike;
  ref: string;
};

type SuitStatus = {
  core_name: string;
  charge_current: number;
  charge_max: number;
  chargebar_color: string;
  chargebar_string: string;
  active: BooleanLike;
  open: BooleanLike;
  seconds_electrified: number;
  malfunctioning: BooleanLike;
  locked: BooleanLike;
  interface_break: BooleanLike;
  complexity: number;
  selected_module: string;
  ai_name: string;
  has_pai: BooleanLike;
  is_ai: BooleanLike;
  link_id: string;
  link_freq: string;
  link_call: string;
};

type UserStatus = {
  user_name: string;
  user_assignment: string;
};

type ModuleCustomStatus = {
  health: number;
  health_max: number;
  loss_brute: number;
  loss_fire: number;
  loss_tox: number;
  loss_oxy: number;
  is_user_irradiated: BooleanLike;
  background_radiation_level: number;
  display_time: BooleanLike;
  shift_time: string;
  shift_id: string;
  body_temperature: number;
  nutrition: number;
  dna_unique_identity: string;
  dna_unique_enzymes: string;
  viruses: VirusData[];
};

type VirusData = {
  name: string;
  type: string;
  stage: number;
  maxstage: number;
  cure: string;
};

type Module = {
  module_name: string;
  description: string;
  module_type: number;
  module_active: BooleanLike;
  pinned: BooleanLike;
  idle_power: number;
  active_power: number;
  use_energy: number;
  module_complexity: number;
  cooldown_time: number;
  cooldown: number;
  id: string;
  ref: string;
  configuration_data: ModuleConfig[];
};

type ModuleConfig = {
  key?: string;
  display_name: string;
  type: string;
  value: number | string | boolean;
  values: string[];
};

const CONFIG_TRANSLATIONS: Record<string, string> = {
  'Scan Mode': 'Режим сканирования',
  'Light Color': 'Цвет света',
  'Light Range': 'Дальность света',
};

const VALUE_TRANSLATIONS: Record<string, string> = {
  Health: 'Здоровье',
  Wound: 'Раны',
  Chemical: 'Химия',
};

const MODULE_NAME_TRANSLATIONS: Record<string, string> = {
  'MOD advanced quick carry module': 'Продвинутый модуль быстрой переноски MOD',
  'MOD storage module': 'Модуль хранилища MOD',
  'MOD expanded storage module': 'Расширенный модуль хранилища MOD',
  'MOD flashlight module': 'Модуль фонаря MOD',
  'MOD health analyzer module': 'Модуль анализатора здоровья MOD',
  'MOD injector module': 'Инъекционный модуль MOD',
  'MOD radio module': 'Радиомодуль MOD',
};

const MODULE_DESCRIPTION_TRANSLATIONS: Record<string, string> = {
  "A suite of advanced servos, redirecting power from the suit's arms to help carry the wounded; or simply for fun. However, Nanotrasen has locked the module's ability to assist in hand-to-hand combat.":
    'Комплекс продвинутых сервоприводов перераспределяет мощность рук костюма, помогая быстро переносить раненых. Для рукопашного боя модуль заблокирован.',
  'What amounts to a series of integrated storage compartments and specialized pockets installed across the surface of the suit, useful for storing various bits, and or bobs.':
    'Система встроенных отсеков и специализированных карманов по всей поверхности костюма для хранения различного снаряжения.',
  'Reverse engineered by Nakamura Engineering from Donk Company designs, this system of hidden compartments is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; whether smuggling, or simply hauling.':
    'Система скрытых отсеков, переработанная Nakamura Engineering на основе решений Donk Company. Равномерно распределяет предметы и вес по костюму.',
  'A simple pair of configurable flashlights installed on the left and right sides of the helmet, useful for providing light in a variety of ranges and colors. Some survivalists prefer the color green for their illumination, for reasons unknown.':
    'Пара настраиваемых фонарей по бокам шлема. Позволяет менять дальность и цвет освещения под задачу.',
  "A module installed into the glove of the suit. This is a high-tech biological scanning suite, allowing the user indepth information on the vitals and injuries of others even at a distance, all with the flick of the wrist. Data is displayed in a convenient package, but it's up to you to do something with it.":
    'Модуль в перчатке костюма с биосканером высокого класса. Даёт подробные данные о состоянии и травмах цели даже на расстоянии.',
  "A self-contained chem-archiving platform installed into the wrist of the suit. Once it has sampled enough of a reagent, it can synthesize fresh doses from the MOD's power reserves, store custom emergency cocktails, and inject through any armor in moments.":
    'Автономная химическая архивно-инъекционная платформа в запястье костюма. После забора образца умеет синтезировать реагент от заряда MOD, хранить коктейли и вводить препараты через любую защиту.',
  'A compact radio/telephone module that provides a handset while active.':
    'Компактный радио-телефонный модуль, который при активации разворачивает трубку связи.',
};

const THEME_WORD_TRANSLATIONS: Record<string, string> = {
  Rescue: 'Спасатель',
  Standard: 'Стандарт',
  Medical: 'Медицинский',
  Security: 'Охранный',
  Engineering: 'Инженерный',
  Atmospheric: 'Атмосферный',
  Research: 'Исследовательский',
  Mining: 'Шахтёрский',
  Civilian: 'Гражданский',
  Advanced: 'Продвинутый',
};

const SLOT_TRANSLATIONS: Record<string, string> = {
  head: 'Слот шлема',
  oversuit: 'Слот нагрудника',
  glove: 'Слот перчаток',
  shoe: 'Слот ботинок',
  back: 'Слот ранца',
  suit: 'Слот костюма',
  'suit storage': 'Слот крепления',
  undersuit: 'Слот комбинезона',
  hand: 'Слот руки',
  belt: 'Слот пояса',
  ear: 'Слот ушей',
  glasses: 'Слот очков',
  mask: 'Слот маски',
  neck: 'Слот шеи',
  pocket: 'Слот кармана',
  id: 'Слот ID',
};

const translateThemeWord = (value: string) =>
  THEME_WORD_TRANSLATIONS[value] ?? value;

const titleCase = (value: string) =>
  value.replace(/\b\w/g, (match) => match.toUpperCase());

const translateHardwareName = (value: string, isRu: boolean) => {
  if (!isRu || !value) {
    return value;
  }
  if (MODULE_NAME_TRANSLATIONS[value]) {
    return MODULE_NAME_TRANSLATIONS[value];
  }
  if (value === 'MOD Standard Core') {
    return 'Стандартное ядро MOD';
  }

  let match = value.match(/^(.+) MOD Control Unit$/);
  if (match) {
    return `Блок управления MOD «${translateThemeWord(match[1])}»`;
  }

  match = value.match(/^(.+) MOD Helmet$/);
  if (match) {
    return `Шлем MOD «${translateThemeWord(match[1])}»`;
  }

  match = value.match(/^(.+) MOD Chestplate$/);
  if (match) {
    return `Нагрудник MOD «${translateThemeWord(match[1])}»`;
  }

  match = value.match(/^(.+) MOD Gauntlets$/);
  if (match) {
    return `Перчатки MOD «${translateThemeWord(match[1])}»`;
  }

  match = value.match(/^(.+) MOD Boots$/);
  if (match) {
    return `Ботинки MOD «${translateThemeWord(match[1])}»`;
  }

  return value;
};

const translateModuleName = (value: string, isRu: boolean) =>
  !isRu ? value : MODULE_NAME_TRANSLATIONS[value] ?? translateHardwareName(value, true);

const translateModuleDescription = (value: string, isRu: boolean) =>
  !isRu ? value : MODULE_DESCRIPTION_TRANSLATIONS[value] ?? value;

const translateConfigName = (value: string, isRu: boolean) =>
  !isRu ? value : CONFIG_TRANSLATIONS[value] ?? value;

const translateConfigValue = (value: string, isRu: boolean) =>
  !isRu ? value : VALUE_TRANSLATIONS[value] ?? value;

const getSlotLabel = (slot: string, isRu: boolean, slotText: string) => {
  if (!isRu) {
    return `${titleCase(slot)} ${slotText}`;
  }
  const normalized = slot.toLowerCase();
  return SLOT_TRANSLATIONS[normalized] ?? `Слот: ${slot}`;
};

const formatComplexityUsage = (
  isRu: boolean,
  current: number,
  max: number,
  ofText: string,
  complexityUsedText: string,
) =>
  isRu
    ? `${current} из ${max} сложности занято`
    : `${current} ${ofText.toLowerCase()} ${max} ${complexityUsedText.toLowerCase()}`;

const useModLocale = (data?: unknown) => {
  const { language, t } = usePreferencesLocalization(data);
  return {
    t,
    isRu: language === 'russian',
  };
};

export const MODsuit = () => {
  const { data } = useBackend<MODsuitData>();
  const { t } = useModLocale(data);
  const { ui_theme } = data;
  const { interface_break } = data.suit_status;

  return (
    <Window
      width={760}
      height={760}
      theme={ui_theme}
      title={t('ui.modsuit.interface_panel')}
    >
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};

export const MODsuitContent = () => {
  const { data } = useBackend<MODsuitData>();
  const { interface_break } = data.suit_status;
  return (
    <Box>
      {interface_break ? (
        <LockedInterface />
      ) : (
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <SuitStatusSection />
              </Stack.Item>
              <Stack.Item grow>
                <UserStatusSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <ModuleSection />
          </Stack.Item>
          <Stack.Item>
            <HardwareSection />
          </Stack.Item>
        </Stack>
      )}
    </Box>
  );
};

const ConfigureNumberEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      step={1}
      stepPixelSize={5}
      width="52px"
      onChange={(newValue) =>
        act('configure', {
          key: name,
          value: newValue,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureBoolEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('configure', {
          key: name,
          value: !value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureColorEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() =>
          act('configure', {
            key: name,
            ref: module_ref,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
    </>
  );
};

const ConfigureListEntry = (props) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend();
  const { isRu } = useModLocale();
  return (
    <Dropdown
      selected={value}
      displayText={translateConfigValue(String(value), isRu)}
      options={values.map((option) => ({
        displayText: translateConfigValue(option, isRu),
        value: option,
      }))}
      onSelected={(selectedValue) =>
        act('configure', {
          key: name,
          value: selectedValue,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigurePinEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  const { t } = useModLocale();
  return (
    <Button
      onClick={() =>
        act('configure', { key: name, value: !value, ref: module_ref })
      }
      icon="thumbtack"
      selected={value}
      tooltip={t('ui.modsuit.pin')}
      tooltipPosition="left"
    />
  );
};

const ConfigureButtonEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button
      onClick={() => act('configure', { key: name, ref: module_ref })}
      icon={value}
    />
  );
};

const ConfigureDataEntry = (props) => {
  const { name, display_name, type } = props;
  const { isRu } = useModLocale();
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
    button: <ConfigureButtonEntry {...props} />,
    pin: <ConfigurePinEntry {...props} />,
  };
  return (
    <LabeledList.Item label={translateConfigName(display_name || name, isRu)}>
      {configureEntryTypes[type]}
    </LabeledList.Item>
  );
};

const LockedInterface = () => {
  const { t } = useModLocale();
  return (
    <Section align="center" fill>
      <Icon color="red" name="exclamation-triangle" size={15} />
      <Box fontSize="30px" color="red">
        {t('ui.modsuit.error_interface_unresponsive')}
      </Box>
    </Section>
  );
};

const LockedModule = () => {
  const { t } = useModLocale();
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          {t('ui.modsuit.suit_unpowered')}
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ConfigureScreen = (props) => {
  const { configuration_data, module_ref } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Box pb={1}>
      <LabeledList>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <ConfigureDataEntry
              key={data.key || key}
              name={key}
              display_name={data.display_name}
              type={data.type}
              value={data.value}
              values={data.values}
              module_ref={module_ref}
            />
          );
        })}
      </LabeledList>
    </Box>
  );
};

const moduleTypeAction = (param: number, t: (key: string) => string) => {
  switch (param) {
    case 1:
      return t('ui.modsuit.use');
    case 2:
      return t('ui.modsuit.toggle');
    case 3:
      return t('ui.modsuit.select');
    default:
      return '';
  }
};

const radiationLevels = (param: number, t: (key: string) => string) => {
  switch (param) {
    case 1:
      return t('ui.modsuit.radiation_low');
    case 2:
      return t('ui.modsuit.radiation_medium');
    case 3:
      return t('ui.modsuit.radiation_high');
    case 4:
      return t('ui.modsuit.radiation_extreme');
    default:
      return '';
  }
};

const SuitStatusSection = () => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = useModLocale(data);
  const {
    charge_current,
    charge_max,
    chargebar_color,
    chargebar_string,
    active,
    open,
    seconds_electrified,
    malfunctioning,
    locked,
    ai_name,
    has_pai,
    is_ai,
    link_id,
    link_freq,
    link_call,
  } = data.suit_status;
  const { display_time, shift_time, shift_id } = data.module_custom_status;
  const status = malfunctioning
    ? t('ui.modsuit.status_malfunctioning')
    : active
      ? t('ui.modsuit.status_active')
      : t('ui.modsuit.status_inactive');

  return (
    <Section
      title={t('ui.modsuit.suit_status')}
      fill
      buttons={
        <Button
          icon="power-off"
          color={active ? 'good' : 'default'}
          content={status}
          onClick={() => act('activate')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.modsuit.charge')}>
          <ProgressBar
            value={charge_max ? charge_current / charge_max : 0}
            color={chargebar_color}
            style={{
              textShadow: '1px 1px 0 black',
            }}
          >
            {chargebar_string}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.modsuit.id_lock')}>
          <Button
            icon={locked ? 'lock' : 'lock-open'}
            color={locked ? 'good' : 'default'}
            content={locked ? t('ui.modsuit.locked') : t('ui.modsuit.unlocked')}
            onClick={() => act('lock')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.modsuit.modlink')}>
          <Button
            icon="wifi"
            color={link_call ? 'good' : 'default'}
            disabled={!link_freq}
            tooltip={link_freq ? '' : t('ui.modsuit.set_frequency_multitool')}
            content={
              link_freq
                ? link_call
                  ? `${t('ui.modsuit.calling')} (${link_call})`
                  : `${t('ui.modsuit.call')} (${link_id})`
                : t('ui.modsuit.frequency_unset')
            }
            onClick={() => act('call')}
          />
        </LabeledList.Item>
        {!!open && (
          <LabeledList.Item label={t('ui.modsuit.cover')}>
            <Box color="red">{t('ui.modsuit.open')}</Box>
          </LabeledList.Item>
        )}
        {!!seconds_electrified && (
          <LabeledList.Item label={t('ui.modsuit.circuits')}>
            <Box color="red">{t('ui.modsuit.shorted')}</Box>
          </LabeledList.Item>
        )}
        {!!ai_name && (
          <LabeledList.Item label={t('ui.modsuit.pai_control')}>
            {has_pai && (
              <Button
                icon="eject"
                content={t('ui.modsuit.eject_pai')}
                disabled={is_ai}
                onClick={() => act('eject_pai')}
              />
            )}
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!display_time && (
        <Section title={t('ui.modsuit.operation')} mt={2}>
          <LabeledList.Item label={t('ui.common.time')}>
            {active ? shift_time : t('ui.modsuit.time_zero')}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.modsuit.number')}>
            {active && shift_id ? shift_id : '???'}
          </LabeledList.Item>
        </Section>
      )}
    </Section>
  );
};

const HardwareSection = () => {
  const { data } = useBackend<MODsuitData>();
  const { t, isRu } = useModLocale(data);
  const { control } = data;
  const { ai_name, core_name } = data.suit_status;
  return (
    <Section title={t('ui.modsuit.hardware')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.modsuit.control_unit')}>
          {translateHardwareName(control, isRu)}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.modsuit.core')}>
          {translateHardwareName(core_name, isRu) ||
            t('ui.modsuit.no_core_detected')}
        </LabeledList.Item>
        <ModParts />
        <LabeledList.Item label={t('ui.modsuit.ai_assistant')}>
          {translateHardwareName(ai_name, isRu) ||
            t('ui.modsuit.no_ai_detected')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ModParts = () => {
  const { act, data } = useBackend<MODsuitData>();
  const { t, isRu } = useModLocale(data);
  const { parts } = data;
  return (
    <>
      {parts.map((part) => (
        <LabeledList.Item
          key={part.slot}
          label={getSlotLabel(part.slot, isRu, t('ui.modsuit.slot'))}
          buttons={
            <Button
              selected={part.deployed}
              icon={part.deployed ? 'arrow-down' : 'arrow-up'}
              content={
                part.deployed ? t('ui.modsuit.retract') : t('ui.modsuit.deploy')
              }
              onClick={() => act('deploy', { ref: part.ref })}
            />
          }
        >
          {translateHardwareName(part.name, isRu)}
        </LabeledList.Item>
      ))}
    </>
  );
};

const UserStatusSection = () => {
  const { data } = useBackend<MODsuitData>();
  const { t } = useModLocale(data);
  const { active } = data.suit_status;
  const { user_name, user_assignment } = data.user_status;
  const {
    health,
    health_max,
    loss_brute,
    loss_fire,
    loss_tox,
    loss_oxy,
    is_user_irradiated,
    background_radiation_level,
    body_temperature,
    nutrition,
    dna_unique_identity,
    dna_unique_enzymes,
    viruses,
  } = data.module_custom_status;
  return (
    <Section title={t('ui.modsuit.user_status')} fill>
      {!active && <LockedModule />}
      <LabeledList>
        {health !== undefined && (
          <LabeledList.Item label={t('ui.common.health')}>
            <ProgressBar
              value={active && health_max ? health / health_max : 0}
              ranges={{
                good: [0.5, Infinity],
                average: [0.2, 0.5],
                bad: [-Infinity, 0.2],
              }}
            >
              <AnimatedNumber value={active ? health : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_brute !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.brute_damage')}>
            <ProgressBar
              value={active && health_max ? loss_brute / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_brute : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_fire !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.burn_damage')}>
            <ProgressBar
              value={active && health_max ? loss_fire / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_fire : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_oxy !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.oxy_damage')}>
            <ProgressBar
              value={active && health_max ? loss_oxy / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_oxy : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_tox !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.tox_damage')}>
            <ProgressBar
              value={active && health_max ? loss_tox / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_tox : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {background_radiation_level !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.radiation')}>
            {!active ? (
              t('ui.modsuit.unknown')
            ) : is_user_irradiated ? (
              <NoticeBox danger>{t('ui.modsuit.user_irradiated')}</NoticeBox>
            ) : background_radiation_level ? (
              <NoticeBox>
                {`${t('ui.modsuit.background')}: ${radiationLevels(background_radiation_level, t)}`}
              </NoticeBox>
            ) : (
              <NoticeBox info>{t('ui.common.not_detected')}</NoticeBox>
            )}
          </LabeledList.Item>
        )}
        {body_temperature !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.body_temp')}>
            {`${active ? Math.round(body_temperature) : 0} K`}
          </LabeledList.Item>
        )}
        {nutrition !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.satiety_level')}>
            {`${active ? Math.round(nutrition) : 0}`}
          </LabeledList.Item>
        )}
        <LabeledList.Item label={t('ui.common.name')}>{user_name}</LabeledList.Item>
        <LabeledList.Item label={t('ui.modsuit.assignment')}>
          {user_assignment}
        </LabeledList.Item>
        {dna_unique_identity !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.fingerprints')}>
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_identity : '???'}
            </Box>
          </LabeledList.Item>
        )}
        {dna_unique_enzymes !== undefined && (
          <LabeledList.Item label={t('ui.modsuit.enzymes')}>
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_enzymes : '???'}
            </Box>
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!viruses?.length && (
        <Section title={t('ui.modsuit.diseases')}>
          {viruses.map((virus) => (
            <Collapsible title={virus.name} key={virus.name}>
              <LabeledList>
                <LabeledList.Item label={t('ui.common.spread')}>
                  {virus.type}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.modsuit.stage')}>
                  {virus.stage}/{virus.maxstage}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.common.cure')}>
                  {virus.cure}
                </LabeledList.Item>
              </LabeledList>
            </Collapsible>
          ))}
        </Section>
      )}
    </Section>
  );
};

const ModuleSection = () => {
  const { act, data } = useBackend<MODsuitData>();
  const { t, isRu } = useModLocale(data);
  const { complexity_max, module_info } = data;
  const { complexity } = data.suit_status;
  const [configureState, setConfigureState] = useState('');

  return (
    <Section
      title={t('ui.modsuit.modules')}
      fill
      buttons={formatComplexityUsage(
        isRu,
        complexity,
        complexity_max,
        t('ui.modsuit.of'),
        t('ui.modsuit.complexity_used'),
      )}
    >
      {!module_info.length ? (
        <NoticeBox>{t('ui.modsuit.no_modules_detected')}</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell colSpan={3}>{t('ui.common.actions')}</Table.Cell>
            <Table.Cell>{t('ui.common.name')}</Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="plug"
                tooltip={t('ui.modsuit.idle_power_cost_watts')}
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="lightbulb"
                tooltip={t('ui.modsuit.active_power_cost_watts')}
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="bolt"
                tooltip={t('ui.modsuit.use_energy_cost_joules')}
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="save"
                tooltip={t('ui.modsuit.complexity')}
                tooltipPosition="top"
              />
            </Table.Cell>
          </Table.Row>
          {module_info.map((module) => (
            <Table.Row key={module.ref}>
              <Table.Cell width={1}>
                <Button
                  onClick={() => act('select', { ref: module.ref })}
                  icon={
                    module.module_type === 3
                      ? module.module_active
                        ? 'check-square-o'
                        : 'square-o'
                      : 'power-off'
                  }
                  selected={module.module_active}
                  tooltip={moduleTypeAction(module.module_type, t)}
                  tooltipPosition="left"
                  disabled={!module.module_type || module.cooldown > 0}
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  onClick={() =>
                    setConfigureState(
                      configureState === module.ref ? '' : module.ref,
                    )
                  }
                  icon="cog"
                  selected={configureState === module.ref}
                  tooltip={t('ui.modsuit.configure')}
                  tooltipPosition="left"
                  disabled={module.configuration_data.length === 0}
                />
              </Table.Cell>
              <Table.Cell width={1}>
                <Button
                  onClick={() => act('pin', { ref: module.ref })}
                  icon="thumbtack"
                  selected={module.pinned}
                  tooltip={t('ui.modsuit.pin')}
                  tooltipPosition="left"
                  disabled={!module.module_type}
                />
              </Table.Cell>
              <Table.Cell>
                <Collapsible
                  title={translateModuleName(module.module_name, isRu)}
                  color={module.module_active ? 'green' : 'default'}
                >
                  <Section mr={-19}>
                    {translateModuleDescription(module.description, isRu)}
                  </Section>
                </Collapsible>
                {configureState === module.ref && (
                  <ConfigureScreen
                    configuration_data={module.configuration_data}
                    module_ref={module.ref}
                    module_name={module.module_name}
                  />
                )}
              </Table.Cell>
              <Table.Cell textAlign="center">
                {formatSiUnit(module.idle_power, 0)}
              </Table.Cell>
              <Table.Cell textAlign="center">
                {formatSiUnit(module.active_power, 0)}
              </Table.Cell>
              <Table.Cell textAlign="center">
                {formatSiUnit(module.use_energy, 0)}
              </Table.Cell>
              <Table.Cell textAlign="center">
                {module.module_complexity}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
