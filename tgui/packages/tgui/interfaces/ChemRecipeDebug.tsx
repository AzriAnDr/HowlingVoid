import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type ActiveReaction, ReactionDisplay } from './ChemHeater';
import { type Beaker, BeakerSectionDisplay } from './common/BeakerDisplay';
import { usePreferencesLocalization } from './localization';

const TEMP_MODES = [
  'Reaction Temp',
  'Forced Temp',
  'Minimum Temp',
  'Optimal Temp',
  'Overheat Temp',
];
const TEMP_MODE_KEYS = [
  'ui.chem_recipe_debug.temp_mode_reaction_temp',
  'ui.chem_recipe_debug.temp_mode_forced_temp',
  'ui.chem_recipe_debug.temp_mode_minimum_temp',
  'ui.chem_recipe_debug.temp_mode_optimal_temp',
  'ui.chem_recipe_debug.temp_mode_overheat_temp',
];
const REACTION_MODES = ['Next Reaction', 'Previous Reaction', 'Pick Reaction'];
const REACTION_MODE_KEYS = [
  'ui.chem_recipe_debug.reaction_mode_next',
  'ui.chem_recipe_debug.reaction_mode_previous',
  'ui.chem_recipe_debug.reaction_mode_pick',
];
const REACTION_VARS = [
  'Required Temp',
  'Optimal Temp',
  'Overheat Temp',
  'Optimal Min Ph',
  'Optimal Max Ph',
  'Ph Range',
  'Temp Exp Factor',
  'Ph Exp Factor',
  'Thermic Constant',
  'H Ion Release',
  'Rate Up Limit',
  'Purity Min',
];
const REACTION_VAR_KEYS = [
  'ui.chem_recipe_debug.required_temp',
  'ui.chem_recipe_debug.optimal_temp',
  'ui.chem_recipe_debug.overheat_temp',
  'ui.chem_recipe_debug.optimal_min_ph',
  'ui.chem_recipe_debug.optimal_max_ph',
  'ui.chem_recipe_debug.ph_range',
  'ui.chem_recipe_debug.temp_exp_factor',
  'ui.chem_recipe_debug.ph_exp_factor',
  'ui.chem_recipe_debug.thermic_constant',
  'ui.chem_recipe_debug.h_ion_release',
  'ui.chem_recipe_debug.rate_up_limit',
  'ui.chem_recipe_debug.purity_min',
];

type BeakerDebug = Beaker & {
  currentTemp: number;
  purity: number;
};

type Reaction = {
  name: string;
  editVar: string;
  editValue: number;
};

type Data = {
  forced_temp: number;
  temp_mode: number;
  forced_ph: number;
  use_forced_ph: BooleanLike;
  forced_purity: number;
  use_forced_purity: number;
  volume_multiplier: number;
  isReacting: BooleanLike;
  current_reaction_name: string;
  current_reaction_mode: number;
  beaker: BeakerDebug;
  isFlashing: number;
  activeReactions: ActiveReaction[];
  editReaction: Reaction;
};

export const ChemRecipeDebug = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const [controlState, setControlState] = useState('Environment');
  const {
    forced_temp,
    temp_mode,
    forced_ph,
    use_forced_ph,
    forced_purity,
    use_forced_purity,
    volume_multiplier,
    isReacting,
    current_reaction_name,
    current_reaction_mode,
    beaker,
    isFlashing,
    activeReactions,
    editReaction,
  } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section title={t('ui.chem_recipe_debug.controls')}>
          <Tabs>
            <Tabs.Tab
              key={'Environment'}
              selected={controlState === 'Environment'}
              onClick={() => setControlState('Environment')}
            >
              {t('ui.chem_recipe_debug.environment')}
            </Tabs.Tab>
            <Tabs.Tab
              key={'Reactions'}
              selected={controlState === 'Reactions'}
              onClick={() => setControlState('Reactions')}
            >
              {t('ui.chem_recipe_debug.reactions')}
            </Tabs.Tab>
            <Tabs.Tab
              key={'Editing'}
              selected={controlState === 'Editing'}
              onClick={() => setControlState('Editing')}
            >
              {t('ui.chem_recipe_debug.edit_reactions')}
            </Tabs.Tab>
          </Tabs>
          {controlState === 'Environment' && (
            <Section>
              <Stack vertical={false}>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.common.temperature')}>
                      <NumberInput
                        tickWhileDragging
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={forced_temp}
                        minValue={0}
                        maxValue={1000}
                        onChange={(value) =>
                          act('forced_temp', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item ml="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -15%)',
                          }}
                        >
                          {t('ui.chem_recipe_debug.temp_mode')}
                        </Box>
                      }
                    >
                      <Dropdown
                        width="100%"
                        selected={TEMP_MODES[temp_mode]}
                        options={TEMP_MODES.map((mode, i) => ({
                          value: mode,
                          displayText: t(TEMP_MODE_KEYS[i]),
                        }))}
                        onSelected={(value) =>
                          act('temp_mode', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={<Box width="82px">{t('ui.chem_master.ph')}</Box>}>
                      <NumberInput
                        tickWhileDragging
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={forced_ph}
                        minValue={0}
                        maxValue={14}
                        onChange={(value) =>
                          act('forced_ph', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item ml="20px">
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.force_ph')}>
                      <Button.Checkbox
                        checked={use_forced_ph}
                        onClick={() => act('toggle_forced_ph')}
                        ml="20px"
                      >
                        {use_forced_ph ? t('ui.common.disable') : t('ui.common.enable')}
                      </Button.Checkbox>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={<Box width="82px">{t('ui.chem_master.purity')}</Box>}>
                      <NumberInput
                        tickWhileDragging
                        width="65px"
                        step={0.01}
                        stepPixelSize={3}
                        value={forced_purity}
                        minValue={0}
                        maxValue={1}
                        onChange={(value) =>
                          act('forced_purity', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item ml="20px">
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.force_purity')}>
                      <Button.Checkbox
                        checked={use_forced_purity}
                        onClick={() => act('toggle_forced_purity')}
                      >
                        {use_forced_purity
                          ? t('ui.common.disable')
                          : t('ui.common.enable')}
                      </Button.Checkbox>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Stack vertical={false} mt="10px">
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.volume_mulx')}>
                      <NumberInput
                        tickWhileDragging
                        width="65px"
                        step={1}
                        stepPixelSize={3}
                        value={volume_multiplier}
                        minValue={1}
                        maxValue={1000}
                        unit="x"
                        onChange={(value) =>
                          act('volume_multiplier', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
          {controlState === 'Reactions' && (
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.reagent')}>
                      <Button
                        color="green"
                        onClick={() => act('pick_reaction')}
                      >
                        {t('ui.chem_recipe_debug.select_reaction')}
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.reaction')}>
                      {current_reaction_name}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -10%)',
                          }}
                        >
                          {t('ui.common.direction')}
                        </Box>
                      }
                    >
                      <Dropdown
                        width="35%"
                        selected={REACTION_MODES[current_reaction_mode]}
                        options={REACTION_MODES.map((mode, i) => ({
                          value: mode,
                          displayText: t(REACTION_MODE_KEYS[i]),
                        }))}
                        disabled={current_reaction_name === 'N/A'}
                        onSelected={(value) =>
                          act('reaction_mode', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={<Box width="60px">{t('ui.chem_recipe_debug.process')}</Box>}
                    >
                      <Button
                        color="green"
                        icon="play"
                        disabled={isReacting || current_reaction_name === 'N/A'}
                        onClick={() => act('start_reaction')}
                      >
                        {t('ui.common.play')}
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
          {controlState === 'Editing' && (
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.chem_recipe_debug.reaction')}>
                      <Button
                        color="green"
                        icon="flask"
                        onClick={() => act('edit_reaction')}
                      >
                        {editReaction?.name || t('ui.chem_recipe_debug.edit_reaction')}
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={
                        <Box
                          style={{
                            transform: 'translate(0%, -10%)',
                            width: '57px',
                          }}
                        >
                          {t('ui.chem_recipe_debug.param')}
                        </Box>
                      }
                    >
                      <Dropdown
                        width="40%"
                        selected={editReaction?.editVar || REACTION_VARS[1]}
                        options={REACTION_VARS.map((param, i) => ({
                          value: param,
                          displayText: t(REACTION_VAR_KEYS[i]),
                        }))}
                        onSelected={(value) =>
                          act('edit_var', { target: value })
                        }
                        disabled={editReaction === null}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={<Box width="57px">{t('ui.common.value')}</Box>}
                    >
                      <NumberInput
                        tickWhileDragging
                        width="65px"
                        step={0.1}
                        stepPixelSize={3}
                        value={editReaction?.editValue || 0}
                        minValue={-1000}
                        maxValue={1000}
                        disabled={editReaction === null}
                        onChange={(value) =>
                          act('edit_value', {
                            target: value,
                          })
                        }
                      />
                      <Button
                        color="green"
                        icon="sync"
                        tooltip={t('ui.chem_recipe_debug.reset_value')}
                        disabled={editReaction === null}
                        onClick={() => act('reset_value')}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item mt="20px">
                  <LabeledList>
                    <LabeledList.Item
                      label={<Box width="57px">{t('ui.common.export')}</Box>}
                    >
                      <Button
                        color="green"
                        icon="save"
                        onClick={() => act('export')}
                        disabled={editReaction === null}
                      >
                        {t('ui.common.export')}
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          )}
        </Section>
        {beaker && (
          <Section title={t('ui.chem_recipe_debug.variables')}>
            <LabeledList>
              <LabeledList.Item label={t('ui.common.temperature')}>
                {beaker.currentTemp}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.chem_master.purity')}>
                {beaker.purity}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {beaker && (
          <ReactionDisplay
            beaker={beaker}
            isFlashing={isFlashing}
            activeReactions={activeReactions}
            highQualityDisplay
            highDangerDisplay
          />
        )}
        <BeakerSectionDisplay
          title_label="Internal Buffer"
          beaker={beaker}
          showpH={false}
        />
      </Window.Content>
    </Window>
  );
};
