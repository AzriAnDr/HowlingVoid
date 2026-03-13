import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

import { RandomizationButton } from '../../components/RandomizationButton';
import { usePreferencesLocalization } from '../../localization';
import { type PreferencesMenuData, RandomSetting } from '../../types';
import { useRandomToggleState } from '../../useRandomToggleState';
import { CheckboxInput, type Feature, type FeatureToggle } from './base';

export const random_body: Feature<RandomSetting> = {
  name: 'Random body',
  component: (props) => {
    const [randomToggle, setRandomToggle] = useRandomToggleState();
    const { act, data } = useBackend<PreferencesMenuData>();
    const { t } = usePreferencesLocalization(data);

    return (
      <Stack>
        <Stack.Item>
          <RandomizationButton
            setValue={(newValue) => props.handleSetValue(newValue)}
            value={props.value}
          />
        </Stack.Item>

        {randomToggle ? (
          <>
            <Stack.Item>
              <Button
                color="green"
                onClick={() => {
                  act('randomize_character');
                  setRandomToggle(false);
                }}
              >
                {t('ui.common.randomize')}
              </Button>
            </Stack.Item>

            <Stack.Item>
              <Button color="red" onClick={() => setRandomToggle(false)}>
                {t('ui.common.cancel')}
              </Button>
            </Stack.Item>
          </>
        ) : (
          <Stack.Item>
            <Button onClick={() => setRandomToggle(true)}>
              {t('ui.common.randomize')}
            </Button>
          </Stack.Item>
        )}
      </Stack>
    );
  },
};

export const random_hardcore: FeatureToggle = {
  name: 'Hardcore random',
  component: CheckboxInput,
};

export const random_name: Feature<RandomSetting> = {
  name: 'Random name',
  component: (props) => {
    return (
      <RandomizationButton
        setValue={(value) => props.handleSetValue(value)}
        value={props.value}
      />
    );
  },
};

export const random_species: Feature<RandomSetting> = {
  name: 'Random species',
  component: (props) => {
    const { act, data } = useBackend<PreferencesMenuData>();

    const species = data.character_preferences.randomization.species;

    return (
      <RandomizationButton
        setValue={(newValue) =>
          act('set_random_preference', {
            preference: 'species',
            value: newValue,
          })
        }
        value={species || RandomSetting.Disabled}
      />
    );
  },
};
