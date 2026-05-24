// THIS IS A NOVA SECTOR UI FILE
import type { FeatureChoiced } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const antag_opt_in_status_pref: FeatureChoiced = {
  name: 'Round Removal',
  description:
    'Controls whether antagonist objective generation prefers your character for kill or round-removal targets. \
    Yes - Kill Without Round Removal allows supported kill targets. \
    Yes - Round Removal also allows marooning, debrain, sacrifice, extraction, and similar round-removal targets. \
    Security jobs set to No are treated as Yes - Kill Without Round Removal during the round. \
    Heretic target selection ignores this setting.',
  component: FeatureDropdownInput,
};
