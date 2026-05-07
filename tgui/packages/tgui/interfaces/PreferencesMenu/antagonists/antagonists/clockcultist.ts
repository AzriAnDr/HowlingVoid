import { type Antagonist, Category } from '../base';

const ClockCultist: Antagonist = {
  key: 'clockcultist',
  name: 'Clock Cultist',
  description: [
    `
      Serve the Clockwork Justiciar Ratvar and prepare the station for the
      return of the Engine.
    `,

    `
      Build clockwork structures, convert new servants, protect anchoring
      crystals, awaken the Ark, and summon Ratvar.
    `,
  ],
  category: Category.Roundstart,
};

export default ClockCultist;
