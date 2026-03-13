import {
  Box,
  Button,
  Dimmer,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { MainData } from './data';

export const InternalDamageToDamagedDesc = {
  MECHA_INT_FIRE: 'ui.mecha.internal_fire_detected',
  MECHA_INT_TEMP_CONTROL: 'ui.mecha.thermoregulator_offline',
  MECHA_CABIN_AIR_BREACH: 'ui.mecha.cabin_breach_detected',
  MECHA_INT_CONTROL_LOST: 'ui.mecha.motors_damaged',
  MECHA_INT_SHORT_CIRCUIT: 'ui.mecha.circuits_shorted',
};

export const InternalDamageToNormalDesc = {
  MECHA_INT_FIRE: 'ui.mecha.no_internal_fires',
  MECHA_INT_TEMP_CONTROL: 'ui.mecha.thermoregulator_active',
  MECHA_CABIN_AIR_BREACH: 'ui.mecha.cabin_sealing_intact',
  MECHA_INT_CONTROL_LOST: 'ui.mecha.motors_active',
  MECHA_INT_SHORT_CIRCUIT: 'ui.mecha.circuits_operational',
};

export const AlertPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const { t } = usePreferencesLocalization(data);
  const {
    internal_damage,
    internal_damage_keys,
    servo_rating,
    scanmod_rating,
    capacitor_rating,
    can_use_overclock,
    overclock_safety_available,
    overclock_safety,
    overclock_mode,
    overclock_temp_percentage,
  } = data;
  return (
    <Section
      title={t('ui.mecha.status')}
      buttons={
        (!!overclock_mode || !!can_use_overclock) && (
          <>
            <Button
              icon="forward"
              onClick={() => !!can_use_overclock && act('toggle_overclock')}
              color={
                overclock_mode &&
                (overclock_temp_percentage > 1
                  ? 'bad'
                  : overclock_temp_percentage > 0.5
                    ? 'average'
                    : 'good')
              }
            >
              {overclock_mode
                ? `${t('ui.mecha.overclock')} (${Math.round(
                    overclock_temp_percentage * 100,
                  )}%)`
                : t('ui.mecha.overclock')}
            </Button>
            {!!overclock_safety_available && (
              <Button
                icon={
                  overclock_safety
                    ? 'temperature-arrow-down'
                    : 'temperature-arrow-up'
                }
                onClick={() => act('toggle_overclock_safety')}
                color={overclock_safety ? 'good' : 'bad'}
                tooltip={
                  overclock_safety
                    ? t('ui.mecha.oc_safety_prevents_overheat')
                    : t('ui.mecha.oc_safety_disabled')
                }
              />
            )}
          </>
        )
      }
    >
      <Stack vertical>
        {!scanmod_rating ? (
          <Box height={8}>
            <Dimmer>{t('ui.mecha.scanning_module_missing')}</Dimmer>
          </Box>
        ) : (
          Object.keys(internal_damage_keys).map((damageKey) => (
            <Stack.Item key={damageKey}>
              <Stack justify="space-between">
                <Stack.Item>
                  <Box
                    color={
                      internal_damage & internal_damage_keys[damageKey]
                        ? 'red'
                        : 'green'
                    }
                  >
                    <Icon
                      mr={1}
                      name={
                        internal_damage & internal_damage_keys[damageKey]
                          ? 'warning'
                          : 'check'
                      }
                    />
                    {internal_damage & internal_damage_keys[damageKey]
                      ? t(InternalDamageToDamagedDesc[damageKey])
                      : t(InternalDamageToNormalDesc[damageKey])}
                  </Box>
                </Stack.Item>
                {!!(internal_damage & internal_damage_keys[damageKey]) && (
                  <Stack.Item>
                    <Button
                      my="-4px"
                      onClick={() =>
                        act('repair_int_damage', {
                          flag: internal_damage_keys[damageKey],
                        })
                      }
                      color={'red'}
                    >
                      {t('ui.mecha.repair')}
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          ))
        )}
      </Stack>
    </Section>
  );
};
