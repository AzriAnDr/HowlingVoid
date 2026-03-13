import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type ModularShieldGenData = {
  max_strength: number;
  current_strength: number;
  max_regeneration: number;
  current_regeneration: number;
  max_radius: number;
  current_radius: number;
  active: BooleanLike;
  recovering: BooleanLike;
  exterior_only: BooleanLike;
  initiating_field: BooleanLike;
};

export const ModularShieldGen = (props) => {
  const { act, data } = useBackend<ModularShieldGenData>();
  const { t } = usePreferencesLocalization(data);
  const {
    max_strength,
    max_regeneration,
    current_regeneration,
    max_radius,
    current_radius,
    current_strength,
    active,
    exterior_only,
    recovering,
    initiating_field,
  } = data;

  return (
    <Window title={t('ui.modular_shield.title')} width={690} height={225}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2}>
            <Section
              title={t('ui.modular_shield.shield_strength')}
              color={recovering ? 'red' : 'white'}
            >
              <ProgressBar
                value={current_strength}
                maxValue={max_strength}
                ranges={{
                  good: [max_strength * 0.75, max_strength],
                  average: [max_strength * 0.25, max_strength * 0.75],
                  bad: [0, max_strength * 0.25],
                }}
              >
                {current_strength}/{max_strength}
              </ProgressBar>
            </Section>
            <Section title={t('ui.modular_shield.regeneration_and_radius')}>
              <ProgressBar
                value={current_regeneration}
                maxValue={max_regeneration}
                ranges={{
                  good: [max_regeneration * 0.75, max_regeneration],
                  average: [max_regeneration * 0.25, max_regeneration * 0.75],
                  bad: [0, max_regeneration * 0.25],
                }}
                >
                  {t('ui.modular_shield.regeneration')} {current_regeneration}/
                  {max_regeneration}
                </ProgressBar>
              <Section>
                <ProgressBar
                  value={current_radius}
                  maxValue={max_radius}
                  ranges={{
                    good: [max_radius * 0.75, max_radius],
                    average: [max_radius * 0.25, max_radius * 0.75],
                    bad: [0, max_radius * 0.25],
                  }}
                >
                  {t('ui.modular_shield.radius')} {current_radius}/{max_radius}
                </ProgressBar>
              </Section>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title={t('ui.common.settings')}>
              <LabeledList>
                <LabeledList.Item label={t('ui.modular_shield.set_radius')}>
                  <NumberInput
                    disabled={!!active}
                    fluid
                    step={1}
                    value={current_radius}
                    minValue={3}
                    maxValue={max_radius}
                    onChange={(value) =>
                      act('set_radius', {
                        new_radius: value,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.modular_shield.limitations')}>
                  <Button
                    disabled={active}
                    onClick={() => act('toggle_exterior')}
                  >
                    {exterior_only
                      ? t('ui.modular_shield.external_only')
                      : t('ui.modular_shield.internal_and_external')}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <LabeledList>
                <LabeledList.Item label={t('ui.modular_shield.toggle_power')}>
                  <Button
                    bold
                    disabled={recovering || initiating_field}
                    selected={active}
                    content={active ? t('ui.common.on') : t('ui.common.off')}
                    icon="power-off"
                    onClick={() => act('toggle_shields')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
