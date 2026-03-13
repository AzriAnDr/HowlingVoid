import { useBackend } from 'tgui/backend';
import { Dropdown } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { usePreferencesLocalization } from '../localization';
import { type PreferencesMenuData, RandomSetting } from '../types';

type Props = {
  dropdownProps?: Record<string, unknown>;
  setValue: (newValue: RandomSetting) => void;
  value: RandomSetting;
};

export function RandomizationButton(props: Props) {
  const { dropdownProps = {}, setValue, value } = props;
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  const options = [
    {
      displayText: t('ui.character.randomization_disabled'),
      value: RandomSetting.Disabled,
    },

    {
      displayText: t('ui.character.randomization_always'),
      value: RandomSetting.Enabled,
    },

    {
      displayText: t('ui.character.randomization_antag_only'),
      value: RandomSetting.AntagOnly,
    },
  ];

  let color;

  switch (value) {
    case RandomSetting.AntagOnly:
      color = 'orange';
      break;
    case RandomSetting.Disabled:
      color = 'red';
      break;
    case RandomSetting.Enabled:
      color = 'green';
      break;
    default:
      exhaustiveCheck(value);
  }

  return (
    <Dropdown
      color={color}
      {...dropdownProps}
      icon="dice-d20"
      iconOnly
      options={options}
      onSelected={setValue}
      menuWidth={20}
      selected={t('ui.common.none')}
    />
  );
}
