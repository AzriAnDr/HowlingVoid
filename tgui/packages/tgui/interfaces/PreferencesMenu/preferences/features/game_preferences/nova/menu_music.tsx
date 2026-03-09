import {
  CheckboxInput,
  type Feature,
  FeatureSliderInput,
  type FeatureToggle,
} from '../../base';

export const menu_music_enabled: FeatureToggle = {
  name: 'Enable menu music',
  category: 'SOUND',
  description: 'Controls background music on the title screen.',
  component: CheckboxInput,
};

export const sound_menu_music_volume: Feature<number> = {
  name: 'Menu music Howling Void volume',
  category: 'SOUND',
  description: 'Volume for Howling Void title screen music.',
  component: FeatureSliderInput,
};
