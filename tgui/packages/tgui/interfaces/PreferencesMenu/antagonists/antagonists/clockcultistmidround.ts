import { type Antagonist, Category } from '../base';

const ClockCultistMidround: Antagonist = {
  key: 'clockcultistmidround',
  name: 'Clock Cultist (Midround)',
  description: [
    `
      A servant of Ratvar that may awaken in an existing crew member during the
      shift.
    `,

    `
      Begin with a Clockwork Slab, build clockwork structures, and act as a
      solo servant of the Clockwork Justiciar.
    `,
  ],
  category: Category.Midround,
};

export default ClockCultistMidround;
