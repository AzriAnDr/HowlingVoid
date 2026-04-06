// THIS IS A NOVA SECTOR UI FILE
import type { ComponentProps } from 'react';
import { Dropdown } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../../../localization';
import type { FeatureChoiced, FeatureValueProps } from '../../base';

type HeightScalingProps = FeatureValueProps<
  string,
  string,
  {
    choices: string[];
    display_names?: Record<string, string>;
  }
>;

type DropdownOptions = ComponentProps<typeof Dropdown>['options'];

const HEIGHT_LABEL_KEYS: Record<string, string> = {
  '8': 'ui.character.height.shortest',
  '10': 'ui.character.height.short',
  '12': 'ui.character.height.medium',
  '14': 'ui.character.height.tall',
  '16': 'ui.character.height.very_tall',
  '18': 'ui.character.height.maximum',
};

function getHeightLabel(
  t: (key: string, fallback?: string) => string,
  value: string,
  fallback?: string,
) {
  const key = HEIGHT_LABEL_KEYS[value];
  return key ? t(key, fallback ?? String(value)) : fallback ?? String(value);
}

function HeightScalingDropdown(props: HeightScalingProps) {
  const { serverData, handleSetValue, value } = props;
  const { t } = usePreferencesLocalization();

  const options: DropdownOptions =
    serverData?.choices?.map((choice) => ({
      displayText: getHeightLabel(t, String(choice), serverData.display_names?.[choice]),
      value: choice,
    })) ?? [];

  return (
    <Dropdown
      className="PreferencesMenu__Character__FieldDropdown"
      buttons
      disabled={!serverData}
      displayText={getHeightLabel(t, String(value), serverData?.display_names?.[value])}
      onSelected={handleSetValue}
      options={options}
      selected={value}
      width="100%"
    />
  );
}

export const height_scaling: FeatureChoiced = {
  name: 'Body Height',
  component: HeightScalingDropdown,
};
