import { type Feature, FeatureColorInput } from '../base';

export const voidwalker_space_color: Feature<string> = {
  name: 'Color',
  description: 'The color used for your space texture.',
  component: FeatureColorInput,
};
