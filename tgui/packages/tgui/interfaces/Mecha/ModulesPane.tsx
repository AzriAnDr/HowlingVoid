import { GasmixParser } from 'tgui/interfaces/common/GasmixParser';
import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { MainData, MechModule } from './data';

const moduleSlotIcon = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'hand';
    case 'mecha_r_arm':
      return 'hand';
    case 'mecha_utility':
      return 'screwdriver-wrench';
    case 'mecha_power':
      return 'bolt';
    case 'mecha_armor':
      return 'shield-halved';
    default:
      return 'screwdriver-wrench';
  }
};

const moduleSlotLabel = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'ui.mecha.left_arm_module';
    case 'mecha_r_arm':
      return 'ui.mecha.right_arm_module';
    case 'mecha_utility':
      return 'ui.mecha.utility_module';
    case 'mecha_power':
      return 'ui.mecha.power_module';
    case 'mecha_armor':
      return 'ui.mecha.armor_module';
    default:
      return 'ui.mecha.common_module';
  }
};

export const ModulesPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { modules, selected_module_index, weapons_safety } = data;
  return (
    <Section
      title={t('ui.mecha.equipment')}
      fill
      style={{ overflowY: 'auto' }}
      buttons={
        <Button
          icon={!weapons_safety ? 'triangle-exclamation' : 'helmet-safety'}
          color={!weapons_safety ? 'red' : 'default'}
          onClick={() => act('toggle_safety')}
          content={
            !weapons_safety
              ? t('ui.mecha.safety_protocols_disabled')
              : t('ui.mecha.safety_protocols_enabled')
          }
        />
      }
    >
      <Stack>
        <Stack.Item>
          {modules.map((module, i) =>
            !module.ref ? (
              <Button
                maxWidth={16}
                p="4px"
                pr="8px"
                fluid
                key={i}
                color="transparent"
              >
                <Stack>
                  <Stack.Item width="32px" height="32px" textAlign="center">
                    <Icon
                      fontSize={1.5}
                      mx={0}
                      my="8px"
                      name={moduleSlotIcon(module.slot)}
                    />
                  </Stack.Item>
                  <Stack.Item
                    lineHeight="32px"
                    style={{
                      textTransform: 'capitalize',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {`${t(moduleSlotLabel(module.slot))} ${t('ui.mecha.slot')}`}
                  </Stack.Item>
                </Stack>
              </Button>
            ) : (
              <Button
                maxWidth={16}
                p="4px"
                pr="8px"
                fluid
                key={i}
                selected={i === selected_module_index}
                onClick={() =>
                  act('select_module', {
                    index: i,
                  })
                }
              >
                <Stack>
                  <Stack.Item lineHeight="0">
                    <Box
                      className={classes(['mecha_equipment32x32', module.icon])}
                    />
                  </Stack.Item>
                  <Stack.Item
                    lineHeight="32px"
                    style={{
                      textTransform: 'capitalize',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {module.name}
                  </Stack.Item>
                </Stack>
              </Button>
            ),
          )}
        </Stack.Item>
        <Stack.Item grow pl={1}>
          {selected_module_index !== null && modules[selected_module_index] && (
            <ModuleDetails module={modules[selected_module_index]} />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const ModuleDetails = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { slot, name, desc, icon, detachable, ref, snowflake } = props.module;
  return (
    <Box>
      <Section>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <h2 style={{ textTransform: 'capitalize' }}>{name}</h2>
                <Box italic opacity={0.5}>
                  {t(moduleSlotLabel(slot))}
                </Box>
              </Stack.Item>
              {!!detachable && (
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon="eject"
                    tooltip={t('ui.mecha.detach')}
                    fontSize={1.5}
                    onClick={() =>
                      act('equip_act', {
                        ref: ref,
                        gear_action: 'detach',
                      })
                    }
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>{desc}</Stack.Item>
        </Stack>
      </Section>
      <Section>
        {snowflake && snowflake.snowflake_id === MECHA_SNOWFLAKE_ID_EJECTOR ? (
          <SnowflakeCargo module={props.module} />
        ) : snowflake &&
          snowflake.snowflake_id === MECHA_SNOWFLAKE_ID_AIR_TANK ? (
          <SnowflakeAirTank module={props.module} />
        ) : snowflake &&
          snowflake.snowflake_id === MECHA_SNOWFLAKE_ID_OREBOX_MANAGER ? (
          <SnowflakeOrebox module={props.module} />
        ) : (
          <LabeledList>
            <ModuleDetailsBasic module={props.module} />
            {!!snowflake && <ModuleDetailsExtra module={props.module} />}
          </LabeledList>
        )}
      </Section>
    </Box>
  );
};

const ModuleDetailsBasic = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { power_level, weapons_safety } = data;
  const {
    ref,
    slot,
    integrity,
    can_be_toggled,
    can_be_triggered,
    active,
    active_label,
    equip_cooldown,
    energy_per_use,
  } = props.module;
  return (
    <>
      {integrity < 1 && (
        <LabeledList.Item
          label={t('ui.mecha.integrity')}
          buttons={
            <Button
              content={t('ui.mecha.repair')}
              icon="wrench"
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'repair',
                })
              }
            />
          }
        >
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={integrity}
          />
        </LabeledList.Item>
      )}
      {!weapons_safety && ['mecha_l_arm', 'mecha_r_arm'].includes(slot) && (
        <LabeledList.Item label={t('ui.mecha.safety')} color="red">
          <NoticeBox danger>{t('ui.mecha.safety_off')}</NoticeBox>
        </LabeledList.Item>
      )}
      {!!energy_per_use && (
        <LabeledList.Item label={t('ui.mecha.power_cost')}>
          {`${formatPower(energy_per_use)}, ${
            power_level ? toFixed(power_level / energy_per_use) : 0
          } ${t('ui.mecha.uses_left').toLowerCase()}`}
        </LabeledList.Item>
      )}
      {!!equip_cooldown && (
        <LabeledList.Item label={t('ui.mecha.cooldown')}>
          {equip_cooldown}
        </LabeledList.Item>
      )}
      {!!can_be_toggled && (
        <LabeledList.Item label={active_label}>
          <Button
            icon="power-off"
            content={active ? t('ui.common.enabled') : t('ui.common.disabled')}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
            selected={active}
          />
        </LabeledList.Item>
      )}
      {!!can_be_triggered && (
        <LabeledList.Item label={active_label}>
          <Button
            icon="power-off"
            content={t('ui.common.activate')}
            disabled={active}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
          />
        </LabeledList.Item>
      )}
    </>
  );
};

const MECHA_SNOWFLAKE_ID_SLEEPER = 'sleeper_snowflake';
const MECHA_SNOWFLAKE_ID_SYRINGE = 'syringe_snowflake';
const MECHA_SNOWFLAKE_ID_MODE = 'mode_snowflake';
const MECHA_SNOWFLAKE_ID_EXTINGUISHER = 'extinguisher_snowflake';
const MECHA_SNOWFLAKE_ID_EJECTOR = 'ejector_snowflake';
const MECHA_SNOWFLAKE_ID_OREBOX_MANAGER = 'orebox_manager_snowflake';
const MECHA_SNOWFLAKE_ID_RADIO = 'radio_snowflake';
const MECHA_SNOWFLAKE_ID_AIR_TANK = 'air_tank_snowflake';
const MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC = 'ballistic_weapon_snowflake';
const MECHA_SNOWFLAKE_ID_GENERATOR = 'generator_snowflake';
const MECHA_SNOWFLAKE_ID_ORE_SCANNER = 'orescanner_snowflake';
const MECHA_SNOWFLAKE_ID_CLAW = 'lawclaw_snowflake';
const MECHA_SNOWFLAKE_ID_RCD = 'rcd_snowflake';

export const ModuleDetailsExtra = (props: { module: MechModule }) => {
  const module = props.module;
  switch (module.snowflake.snowflake_id) {
    case MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC:
      return <SnowflakeWeaponBallistic module={module} />;
    case MECHA_SNOWFLAKE_ID_EXTINGUISHER:
      return <SnowflakeExtinguisher module={module} />;
    case MECHA_SNOWFLAKE_ID_SLEEPER:
      return <SnowflakeSleeper module={module} />;
    case MECHA_SNOWFLAKE_ID_SYRINGE:
      return <SnowflakeSyringe module={module} />;
    case MECHA_SNOWFLAKE_ID_MODE:
      return <SnowflakeMode module={module} />;
    case MECHA_SNOWFLAKE_ID_RADIO:
      return <SnowflakeRadio module={module} />;
    case MECHA_SNOWFLAKE_ID_GENERATOR:
      return <SnowflakeGeneraor module={module} />;
    case MECHA_SNOWFLAKE_ID_ORE_SCANNER:
      return <SnowflakeOreScanner module={module} />;
    case MECHA_SNOWFLAKE_ID_CLAW:
      return <SnowflakeLawClaw module={module} />;
    case MECHA_SNOWFLAKE_ID_RCD:
      return <SnowflakeRCD module={module} />;
    default:
      return null;
  }
};

const SnowflakeWeaponBallistic = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const {
    projectiles,
    max_magazine,
    projectiles_cache,
    projectiles_cache_max,
    disabledreload,
    ammo_type,
    mode,
  } = props.module.snowflake;
  return (
    <>
      {!!ammo_type && <LabeledList.Item label={t('ui.mecha.ammo')}>{ammo_type}</LabeledList.Item>}
      <LabeledList.Item
        label={t('ui.mecha.loaded')}
        buttons={
          !disabledreload &&
          projectiles_cache > 0 && (
            <Button
              icon="redo"
              disabled={projectiles >= max_magazine}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'reload',
                })
              }
            >
              {t('ui.mecha.reload')}
            </Button>
          )
        }
      >
        <ProgressBar value={projectiles / max_magazine}>
          {`${projectiles} of ${max_magazine}`}
        </ProgressBar>
      </LabeledList.Item>
      {!!projectiles_cache_max && (
        <LabeledList.Item label={t('ui.mecha.stored')}>
          <ProgressBar value={projectiles_cache / projectiles_cache_max}>
            {`${projectiles_cache} of ${projectiles_cache_max}`}
          </ProgressBar>
        </LabeledList.Item>
      )}
      {!!mode && <SnowflakeMode module={props.module} />}
    </>
  );
};

const SnowflakeSleeper = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const {
    patient,
    contained_reagents,
    injectible_reagents,
    has_brain_damage,
    has_traumas,
  } = props.module.snowflake;
  return !patient ? (
    <LabeledList.Item label={t('ui.mecha.patient')}>
      {t('ui.common.none')}
    </LabeledList.Item>
  ) : (
    <>
      <LabeledList.Item
        label={t('ui.mecha.patient')}
        buttons={
          <Button
            icon="eject"
            tooltip={t('ui.common.eject')}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'eject',
              })
            }
          />
        }
      >
        {patient.patient_name}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.health')}>
        <ProgressBar
          ranges={{
            good: [0.75, Infinity],
            average: [0.25, 0.75],
            bad: [-Infinity, 0.25],
          }}
          value={patient.patient_health}
        />
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label={t('ui.common.status')}>
        {patient.patient_state}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label={t('ui.common.temperature')}>
        {patient.core_temp} C
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label={t('ui.mecha.brute_damage')}>
        {patient.brute_loss}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label={t('ui.mecha.burn_severity')}>
        {patient.burn_loss}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label={t('ui.mecha.toxin_content')}>
        {patient.toxin_loss}
      </LabeledList.Item>
      <LabeledList.Item
        className="candystripe"
        label={t('ui.mecha.respiratory_damage')}
      >
        {patient.oxygen_loss}
      </LabeledList.Item>
      {!!has_brain_damage && (
        <LabeledList.Item className="candystripe" label={t('ui.mecha.detected')}>
          {t('ui.mecha.brain_damage')}
        </LabeledList.Item>
      )}
      {!!has_traumas && (
        <LabeledList.Item className="candystripe" label={t('ui.mecha.detected')}>
          {t('ui.mecha.traumatic_damage')}
        </LabeledList.Item>
      )}
      <LabeledList.Item label={t('ui.mecha.reagent_details')}>
        {contained_reagents.map((reagent) => (
          <LabeledList.Item
            key={reagent.name}
            className="candystripe"
            label={reagent.name}
          >
            <LabeledList.Item label={`${reagent.volume}u`} />
          </LabeledList.Item>
        ))}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.reagent_injection')}>
        {injectible_reagents
          ? injectible_reagents.map((reagent) => (
              <LabeledList.Item
                className="candystripe"
                key={reagent.name}
                label={reagent.name}
              >
                <LabeledList.Item label={`${reagent.volume}u`}>
                  <Button
                    onClick={() =>
                      act('equip_act', {
                        ref: ref,
                        gear_action: `inject_reagent_${reagent.name}`,
                      })
                    }
                  >
                    {t('ui.mecha.inject')}
                  </Button>
                </LabeledList.Item>
              </LabeledList.Item>
            ))
          : t('ui.common.not_available')}
      </LabeledList.Item>
    </>
  );
};
type Data = {
  contained_reagents: Reagent[];
  analyzed_reagents: KnownReagent[];
};
type Reagent = {
  name: string;
  volume: number;
};
type KnownReagent = {
  name: string;
  enabled: boolean;
};
const SnowflakeSyringe = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { power_level, weapons_safety } = data;
  const { ref, energy_per_use, equip_cooldown } = props.module;
  const {
    mode,
    syringe,
    max_syringe,
    reagents,
    total_reagents,
    contained_reagents,
    analyzed_reagents,
  } = props.module.snowflake;
  return (
    <>
      <LabeledList.Item label={t('ui.mecha.syringes')}>
        <ProgressBar value={syringe / max_syringe}>
          {`${syringe} of ${max_syringe}`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.reagents')}>
        <ProgressBar value={reagents / total_reagents}>
          {`${reagents} of ${total_reagents} units`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.mode')}>
        <Button
          content={mode}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'change_mode',
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.synthesizing')}>
        {analyzed_reagents.map((reagent) => (
          <LabeledList.Item key={reagent.name} label={reagent.name}>
            <Button.Checkbox
              checked={reagent.enabled}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: `toggle_reagent_${reagent.name}`,
                })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: `purge_all`,
            })
          }
        >
          {t('ui.mecha.purge_all')}
        </Button>
      </LabeledList.Item>
      {contained_reagents.map((reagent) => (
        <LabeledList.Item key={reagent.name} label={reagent.name}>
          <LabeledList.Item label={`${reagent.volume}u`}>
            <Button
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: `purge_reagent_${reagent.name}`,
                })
              }
            >
              {t('ui.mecha.purge')}
            </Button>
          </LabeledList.Item>
        </LabeledList.Item>
      ))}
    </>
  );
};

const SnowflakeMode = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { mode, mode_label } = props.module.snowflake;
  return (
    <LabeledList.Item label={mode_label}>
      <Button
        content={mode}
        onClick={() =>
          act('equip_act', {
            ref: ref,
            gear_action: 'change_mode',
          })
        }
      />
    </LabeledList.Item>
  );
};

const SnowflakeRadio = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { microphone, speaker, minFrequency, maxFrequency, frequency } =
    props.module.snowflake;
  return (
    <>
      <LabeledList.Item label={t('ui.mecha.microphone')}>
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_microphone',
            })
          }
          selected={microphone}
          icon={microphone ? 'microphone' : 'microphone-slash'}
        >
          {microphone ? t('ui.common.enabled') : t('ui.common.disabled')}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.speaker')}>
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_speaker',
            })
          }
          selected={speaker}
          icon={speaker ? 'volume-up' : 'volume-mute'}
        >
          {speaker ? t('ui.common.enabled') : t('ui.common.disabled')}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.frequency')}>
        <NumberInput
          animated
          tickWhileDragging
          unit="kHz"
          step={0.2}
          stepPixelSize={10}
          minValue={minFrequency / 10}
          maxValue={maxFrequency / 10}
          value={frequency / 10}
          format={(value) => toFixed(value, 1)}
          onChange={(value) =>
            act('equip_act', {
              ref: ref,
              gear_action: 'set_frequency',
              new_frequency: value * 10,
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeAirTank = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { cabin_sealed, one_atmosphere } = data;
  const { ref, integrity, active } = props.module;
  const {
    auto_pressurize_on_seal,
    port_connected,
    tank_release_pressure,
    tank_release_pressure_min,
    tank_release_pressure_max,
    tank_pump_active,
    tank_pump_direction,
    tank_pump_pressure,
    tank_pump_pressure_min,
    tank_pump_pressure_max,
    tank_air,
    cabin_air,
  } = props.module.snowflake;
  return (
    <Box>
      <LabeledList>
        {integrity < 1 && (
          <LabeledList.Item
            label={t('ui.mecha.integrity')}
            buttons={
              <Button
                content={t('ui.mecha.repair')}
                icon="wrench"
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'repair',
                  })
                }
              />
            }
          >
            <ProgressBar
              ranges={{
                good: [0.75, Infinity],
                average: [0.25, 0.75],
                bad: [-Infinity, 0.25],
              }}
              value={integrity}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
      <Section
        title={t('ui.mecha.tank')}
        buttons={
          <Button
            icon="power-off"
            content={
              active
                ? !cabin_sealed
                  ? t('ui.mecha.release_paused')
                  : t('ui.mecha.pressurizing_cabin')
                : t('ui.mecha.release_off')
            }
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
            selected={active}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.mecha.automation')}>
            <Button
              content={
                auto_pressurize_on_seal
                  ? t('ui.mecha.pressurize_on_seal')
                  : t('ui.mecha.manual')
              }
              selected={auto_pressurize_on_seal}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'toggle_auto_pressurize',
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.mecha.cabin_pressure')}>
            <NumberInput
              value={tank_release_pressure}
              unit="kPa"
              width="75px"
              minValue={tank_release_pressure_min}
              maxValue={tank_release_pressure_max}
              step={10}
              onChange={(value) =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'set_cabin_pressure',
                  new_pressure: value,
                })
              }
            />
            <Button
              icon="sync"
              disabled={tank_release_pressure === Math.round(one_atmosphere)}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'set_cabin_pressure',
                  new_pressure: Math.round(one_atmosphere),
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.mecha.pipenet_port')}
            buttons={
              <Button
                icon="info"
                color="transparent"
                tooltip={t('ui.mecha.pipenet_port_tooltip')}
              />
            }
          >
            <Button
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'toggle_port',
                })
              }
              selected={port_connected}
            >
              {port_connected ? t('ui.mecha.connected') : t('ui.mecha.disconnected')}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title={t('ui.mecha.external_pump')}
        buttons={
          <Button
            icon="power-off"
            content={tank_pump_active ? t('ui.common.on') : t('ui.common.off')}
            selected={tank_pump_active}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle_tank_pump',
              })
            }
          />
        }
      >
        <LabeledList.Item label={t('ui.common.direction')}>
          <Button
            content={
              tank_pump_direction
                ? t('ui.mecha.area_to_tank')
                : t('ui.mecha.tank_to_area')
            }
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle_tank_pump_direction',
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.mecha.target_pressure')}>
          <NumberInput
            value={tank_pump_pressure}
            unit="kPa"
            width="75px"
            minValue={tank_pump_pressure_min}
            maxValue={tank_pump_pressure_max}
            step={10}
            format={(value) => `${Math.round(value)}`}
            onChange={(value) =>
              act('equip_act', {
                ref: ref,
                gear_action: 'set_tank_pump_pressure',
                new_pressure: value,
              })
            }
          />
          <Button
            icon="sync"
            disabled={tank_pump_pressure === Math.round(one_atmosphere)}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'set_tank_pump_pressure',
                new_pressure: Math.round(one_atmosphere),
              })
            }
          />
        </LabeledList.Item>
      </Section>
      <Section title={t('ui.mecha.sensors')}>
        <Collapsible title={t('ui.mecha.tank_air')}>
          <GasmixParser gasmix={tank_air} />
        </Collapsible>
        {cabin_sealed ? (
          <Collapsible title={t('ui.mecha.cabin_air')}>
            <GasmixParser gasmix={cabin_air} />
          </Collapsible>
        ) : (
          <NoticeBox>
            <Icon name="wind" mr={1} />
            {t('ui.mecha.cabin_open')}
          </NoticeBox>
        )}
      </Section>
    </Box>
  );
};

const SnowflakeOrebox = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { contents } = props.module.snowflake;
  return (
    <Section
      title={t('ui.mecha.contents')}
      buttons={
        <Button
          icon="arrows-down-to-line"
          content={t('ui.mecha.dump')}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'dump',
            })
          }
          disabled={!Object.keys(contents).length}
        />
      }
    >
      {Object.keys(contents).length ? (
        Object.keys(contents).map((item, i) => (
          <Stack key={i}>
            <Stack.Item lineHeight="0">
              <Box
                m="-4px"
                className={classes([
                  'mecha_equipment32x32',
                  contents[item].icon,
                ])}
              />
            </Stack.Item>
            <Stack.Item
              lineHeight="24px"
              style={{
                textTransform: 'capitalize',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {`${contents[item].amount}x ${contents[item].name}`}
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <NoticeBox info>{t('ui.mecha.ore_box_empty')}</NoticeBox>
      )}
    </Section>
  );
};

const SnowflakeCargo = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { cargo, cargo_capacity } = props.module.snowflake;
  return (
    <Box>
      <Section
        title={t('ui.mecha.contents')}
        buttons={`${cargo.length} of ${cargo_capacity}`}
      >
        {!cargo.length ? (
          <NoticeBox info>{t('ui.mecha.compartment_empty')}</NoticeBox>
        ) : (
          cargo.map((item, i) => (
            <Button
              fluid
              py={0.2}
              key={i}
              icon="eject"
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  cargoref: item.ref,
                  gear_action: 'eject',
                })
              }
              style={{
                textTransform: 'capitalize',
              }}
            >
              {item.name}
            </Button>
          ))
        )}
      </Section>
    </Box>
  );
};

const SnowflakeExtinguisher = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { reagents, total_reagents, reagents_required } =
    props.module.snowflake;
  return (
    <>
      <LabeledList.Item
        label={t('ui.mecha.water')}
        buttons={
          <Button
            content={t('ui.mecha.refill')}
            icon="fill"
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'refill',
              })
            }
          />
        }
      >
        <ProgressBar value={reagents} minValue={0} maxValue={total_reagents}>
          {reagents}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.extinguisher')}>
        <Button
          content={t('ui.mecha.activate')}
          color="red"
          disabled={reagents < reagents_required}
          icon="fire-extinguisher"
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'activate',
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};

const SnowflakeGeneraor = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { sheet_material_amount } = data;
  const { ref, active, name } = props.module;
  const { fuel } = props.module.snowflake;
  return (
    <LabeledList.Item label={t('ui.mecha.fuel_amount')}>
      {fuel === null
        ? t('ui.common.none')
        : `${toFixed(fuel * sheet_material_amount, 0.1)} cm³`}
    </LabeledList.Item>
  );
};

const SnowflakeOreScanner = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { cooldown } = props.module.snowflake;
  return (
    <LabeledList.Item label={t('ui.mecha.vent_scanner')}>
      <NoticeBox info={cooldown <= 0}>
        {cooldown / 10 > 0
          ? `${t('ui.mecha.recharging')}...`
          : t('ui.mecha.ready_to_scan_vents')}
        <Button
          my={1}
          width="100%"
          icon="satellite-dish"
          color={cooldown <= 0 ? 'green' : 'transparent'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'area_scan',
            })
          }
          disabled={!(cooldown <= 0)}
        >
          {t('ui.mecha.scan_nearby_vents')}
        </Button>
      </NoticeBox>
    </LabeledList.Item>
  );
};

const SnowflakeLawClaw = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { autocuff } = props.module.snowflake;
  return (
    <LabeledList.Item
      label={t('ui.mecha.handcuff_suspects')}
      buttons={
        <Button
          content={t('ui.common.toggle')}
          color={autocuff ? 'green' : 'blue'}
          icon="handcuffs"
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'togglecuff',
            })
          }
        />
      }
    />
  );
};

const SnowflakeRCD = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const { ref } = props.module;
  const { scan_ready, deconstructing, mode } = props.module.snowflake;
  return (
    <>
      <LabeledList.Item label={t('ui.mecha.destruction_scan')}>
        <Button
          icon="satellite-dish"
          color={scan_ready ? 'green' : 'transparent'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'rcd_scan',
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.deconstructing')}>
        <Button
          icon="power-off"
          content={deconstructing ? t('ui.common.on') : t('ui.common.off')}
          color={deconstructing ? 'green' : 'blue'}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_deconstruct',
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.mecha.construction_mode')}>
        <Button
          content={mode}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'change_mode',
            })
          }
        />
      </LabeledList.Item>
    </>
  );
};
