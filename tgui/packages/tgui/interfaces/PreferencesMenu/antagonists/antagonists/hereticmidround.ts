import { type Antagonist, Category } from '../base';
import { HERETIC_MECHANICAL_DESCRIPTION } from './heretic';

const HereticMidround: Antagonist = {
  key: 'hereticmidround',
  name: 'Heretic (Midround)',
  description: [
    'A form of heretic that may awaken in an existing crew member during the shift.',
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default HereticMidround;
