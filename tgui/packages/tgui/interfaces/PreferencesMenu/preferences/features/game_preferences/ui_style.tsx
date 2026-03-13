import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { usePreferencesLocalization } from '../../../localization';
import type { PreferencesMenuData } from '../../../types';
import {
  type FeatureChoiced,
  type FeatureChoicedServerData,
  type FeatureValueProps,
  sortChoices,
} from '../base';

function UIStyleInput(
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const { serverData, value } = props;
  if (!serverData) {
    return null;
  }

  const { icons } = serverData;

  if (!icons) {
    return <Box color="red">{t('ui.character.ui_style_no_icons')}</Box>;
  }

  const choices = Object.fromEntries(
    Object.entries(icons).map(([name, icon]) => {
      return [
        name,
        <Stack key={name}>
          <Stack.Item>
            <Box
              className={classes(['preferences64x32', icon])}
              style={{
                transform: 'scale(0.8)',
              }}
            />
          </Stack.Item>

          <Stack.Item grow>{name}</Stack.Item>
        </Stack>,
      ];
    }),
  );

  return (
    <Dropdown
      selected={value}
      clipSelectedText={false}
      onSelected={props.handleSetValue}
      width="100%"
      options={sortChoices(Object.entries(choices)).map(
        ([dataValue, label]) => {
          return {
            displayText: label,
            value: dataValue,
          };
        },
      )}
    />
  );
}

export const UI_style: FeatureChoiced = {
  name: 'UI Style',
  category: 'UI',
  component: UIStyleInput,
};
