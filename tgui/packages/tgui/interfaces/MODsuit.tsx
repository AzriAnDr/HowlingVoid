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
  // Static
  ui_theme: string;
  complexity_max: number;
  // Dynamic
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
  display_name: string;
  type: string;
  value: number;
  values: [];
};

export const MODsuit = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
  const { ui_theme } = data;
  const { interface_break } = data.suit_status;
  return (
    <Window
      width={600}
      height={600}
      theme={ui_theme}
      title={t('ui.modsuit.interface_panel')}
    >
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};

export const MODsuitContent = (props) => {
  const { act, data } = useBackend<MODsuitData>();
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
      width="39px"
      onChange={(value) =>
        act('configure', {
          key: name,
          value: value,
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
  return (
    <Dropdown
      selected={value}
      options={values}
      onSelected={(value) =>
        act('configure', {
          key: name,
          value: value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigurePinEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
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

// fuck u smartkar configs werent meant to be used as actions 🖕🖕🖕
// and really u couldnt be bothered to make this and instead used
// the pin entry? 🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕
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
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
    button: <ConfigureButtonEntry {...props} />,
    pin: <ConfigurePinEntry {...props} />,
  };
  return (
    <LabeledList.Item label={display_name}>
      {configureEntryTypes[type]}
    </LabeledList.Item>
  );
};

const LockedInterface = () => {
  const { t } = usePreferencesLocalization();
  return (
    <Section align="center" fill>
    <Icon color="red" name="exclamation-triangle" size={15} />
    <Box fontSize="30px" color="red">
      {t('ui.modsuit.error_interface_unresponsive')}
    </Box>
    </Section>
  );
};

const LockedModule = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
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
  const { configuration_data, module_ref, module_name } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Box pb={1}>
      <LabeledList>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <ConfigureDataEntry
              key={data.key}
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

const moduleTypeAction = (param, t) => {
  switch (param) {
    case 1:
      return t('ui.modsuit.use');
    case 2:
      return t('ui.modsuit.toggle');
    case 3:
      return t('ui.modsuit.select');
  }
};

const radiationLevels = (param, t) => {
  switch (param) {
    case 1:
      return t('ui.modsuit.radiation_low');
    case 2:
      return t('ui.modsuit.radiation_medium');
    case 3:
      return t('ui.modsuit.radiation_high');
    case 4:
      return t('ui.modsuit.radiation_extreme');
  }
};

const SuitStatusSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
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
            value={charge_current / charge_max}
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
            icon={'wifi'}
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

const HardwareSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
  const { control } = data;
  const { ai_name, core_name } = data.suit_status;
  return (
    <Section title={t('ui.modsuit.hardware')} style={{ textTransform: 'capitalize' }}>
      <LabeledList>
        <LabeledList.Item label={t('ui.modsuit.control_unit')}>{control}</LabeledList.Item>
        <LabeledList.Item label={t('ui.modsuit.core')}>
          {core_name || t('ui.modsuit.no_core_detected')}
        </LabeledList.Item>
        <ModParts />
        <LabeledList.Item label={t('ui.modsuit.ai_assistant')}>
          {ai_name || t('ui.modsuit.no_ai_detected')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ModParts = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
  const { parts } = data;
  return (
    <>
      {parts.map((part) => {
        return (
          <LabeledList.Item
            key={part.slot}
            label={`${part.slot} ${t('ui.modsuit.slot')}`}
            buttons={
              <Button
                selected={part.deployed}
                icon={part.deployed ? 'arrow-down' : 'arrow-up'}
                content={part.deployed ? t('ui.modsuit.retract') : t('ui.modsuit.deploy')}
                onClick={() => act('deploy', { ref: part.ref })}
              />
            }
          >
            {part.name}
          </LabeledList.Item>
        );
      })}
    </>
  );
};

const UserStatusSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
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
              value={active ? health / health_max : 0}
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
              value={active ? loss_brute / health_max : 0}
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
              value={active ? loss_fire / health_max : 0}
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
              value={active ? loss_oxy / health_max : 0}
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
              value={active ? loss_tox / health_max : 0}
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
      {!!viruses && (
        <Section title={t('ui.modsuit.diseases')}>
          {viruses.map((virus) => {
            return (
              <Collapsible title={virus.name} key={virus.name}>
                <LabeledList>
                  <LabeledList.Item label={t('ui.common.spread')}>
                    {virus.type}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.modsuit.stage')}>
                    {virus.stage}/{virus.maxstage}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.common.cure')}>{virus.cure}</LabeledList.Item>
                </LabeledList>
              </Collapsible>
            );
          })}
        </Section>
      )}
    </Section>
  );
};

const ModuleSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { t } = usePreferencesLocalization(data);
  const { complexity_max, module_info } = data;
  const { complexity } = data.suit_status;
  const [configureState, setConfigureState] = useState('');

  return (
    <Section
      title={t('ui.modsuit.modules')}
      fill
      buttons={`${complexity} ${t('ui.modsuit.of').toLowerCase()} ${complexity_max} ${t('ui.modsuit.complexity_used').toLowerCase()}`}
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
          {module_info.map((module) => {
            return (
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
                    title={module.module_name}
                    color={module.module_active ? 'green' : 'default'}
                  >
                    <Section mr={-19}>{module.description}</Section>
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
            );
          })}
        </Table>
      )}
    </Section>
  );
};
