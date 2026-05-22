import {
  CheckboxInput,
  type FeatureChoiced,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const tgui_input: FeatureToggle = {
  name: 'Input: Enable TGUI',
  category: 'UI',
  description: 'Renders input boxes in TGUI.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Input: Larger buttons',
  category: 'UI',
  description: 'Makes TGUI buttons less traditional, more functional.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Input: Swap Submit/Cancel buttons',
  category: 'UI',
  description: 'Makes TGUI buttons less traditional, more functional.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Lock TGUI to main monitor',
  category: 'UI',
  description: 'Locks TGUI windows to your main monitor.',
  component: CheckboxInput,
};

export const tgui_window_theme: FeatureChoiced = {
  name: 'Window theme',
  category: 'UI',
  description: 'Sets the default theme for standard TGUI windows.',
  component: FeatureDropdownInput,
};

export const tgui_window_backdrop: FeatureChoiced = {
  name: 'Window backdrop',
  category: 'UI',
  description: 'Sets the default background art for standard TGUI windows.',
  component: FeatureDropdownInput,
};

export const ui_scale: FeatureToggle = {
  name: 'Toggle UI scaling',
  category: 'UI',
  description: 'If UIs should scale up to match your monitor scaling.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Say: Light mode',
  category: 'UI',
  description: 'Sets TGUI Say to use a light mode.',
  component: CheckboxInput,
};
