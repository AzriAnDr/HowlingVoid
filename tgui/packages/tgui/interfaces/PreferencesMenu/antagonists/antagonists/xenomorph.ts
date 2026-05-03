import { type Antagonist, Category } from '../base';

const Xenomorph: Antagonist = {
  key: 'xenomorph',
  name: 'Xenomorph',
  description: [
    `
      Become a xenomorph. Start as a larva, choose a caste, and evolve
      into stronger forms including Ravager, Crusher, Praetorian, or Queen.
    `,
  ],
  category: Category.Midround,
};

export default Xenomorph;
