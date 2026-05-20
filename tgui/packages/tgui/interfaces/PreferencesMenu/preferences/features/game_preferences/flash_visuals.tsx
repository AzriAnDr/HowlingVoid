import { type FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const flash_visuals: FeatureChoiced = {
  name: 'Screen Flash Visuals',
  category: 'GAMEPLAY',
  description: `
    Changes how being flashed affects your screen.
    "Light" mode has your screen flash white.
    "Dark" mode has your screen flash black.
    "Blur" mode has your screen heavily blur.
  `,
  component: (props) => <FeatureDropdownInput buttons {...props} />,
};
