import adminEn from './ui.admin.en.json';
import adminRu from './ui.admin.ru.json';
import characterEn from './ui.character.en.json';
import characterRu from './ui.character.ru.json';
import commonEn from './ui.common.en.json';
import commonRu from './ui.common.ru.json';
import dataEn from './ui.data.en.json';
import dataRu from './ui.data.ru.json';
import gameEn from './ui.game.en.json';
import gameRu from './ui.game.ru.json';
import jobsEn from './ui.jobs.en.json';
import jobsRu from './ui.jobs.ru.json';
import keybindingsEn from './ui.keybindings.en.json';
import keybindingsRu from './ui.keybindings.ru.json';
import loadoutEn from './ui.loadout.en.json';
import loadoutRu from './ui.loadout.ru.json';
import speciesEn from './ui.species.en.json';
import speciesRu from './ui.species.ru.json';

const uiEn = {
  ...commonEn,
  ...characterEn,
  ...jobsEn,
  ...speciesEn,
  ...loadoutEn,
  ...gameEn,
  ...keybindingsEn,
  ...adminEn,
  ...dataEn,
} as Record<string, string>;

const uiRu = {
  ...commonRu,
  ...characterRu,
  ...jobsRu,
  ...speciesRu,
  ...loadoutRu,
  ...gameRu,
  ...keybindingsRu,
  ...adminRu,
  ...dataRu,
} as Record<string, string>;

export { uiEn, uiRu };
