import {
  type ComponentProps,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';
import type { PreferencesMenuData } from '../../types';
import {
  localizeDataLabelById,
  usePreferencesLocalization,
} from '../../localization';

import type {
  Feature,
  FeatureChoicedServerData,
  FeatureValueProps,
} from './base';

export type DropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
> &
  Partial<{
    disabled: boolean;
    buttons: boolean;
  }>;

type IconnedDropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
>;

export type FeatureWithIcons<T> = Feature<string, T, FeatureChoicedServerData>;

type DropdownOptions = ComponentProps<typeof Dropdown>['options'];

type DropdownEntry = {
  displayText: ReactNode;
  value: string | number;
};

export function translateDropdownText(
  sourceId: string,
  text: ReactNode,
  language: 'english' | 'russian',
): ReactNode {
  if (typeof text !== 'string') {
    return text;
  }

  return localizeDataLabelById(language, sourceId, text);
}

function capitalizeDropdownDisplayText(text: ReactNode): ReactNode {
  return typeof text === 'string' ? capitalizeFirst(text) : text;
}

export function generateOptions(
  serverData: FeatureChoicedServerData,
  language: 'english' | 'russian' = 'english',
): DropdownEntry[] {
  const { choices = [] } = serverData;

  const newOptions: DropdownEntry[] = [];

  for (const choice of choices) {
    const displayTextRaw: ReactNode = serverData.display_names
      ? serverData.display_names[choice]
      : capitalizeFirst(choice);
    const displayText = translateDropdownText(choice, displayTextRaw, language);

    newOptions.push({
      displayText,
      value: choice,
    });
  }

  return newOptions;
}

export function FeatureDropdownInput(props: DropdownInputProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const { language } = usePreferencesLocalization(data);

  return FeatureDropdownInputCore(props, (serverData, setDropdownOptions) =>
    setDropdownOptions(generateOptions(serverData, language)),
  );
}

export function FeatureDropdownInputCore(
  props: DropdownInputProps,
  populateOptions: (
    serverData: FeatureChoicedServerData,
    setDropdownOptions: (newValue: DropdownOptions) => void,
  ) => void,
) {
  const { serverData, disabled, buttons, handleSetValue, value } = props;

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  useEffect(() => {
    if (serverData) {
      populateOptions(serverData, setDropdownOptions);
    }
  }, [serverData, populateOptions]);

  const { data } = useBackend<PreferencesMenuData>();
  const { language } = usePreferencesLocalization(data);

  const displayTextRaw = serverData?.display_names?.[value] || String(value);
  const displayText = translateDropdownText(value, displayTextRaw, language);

  return (
    <Dropdown
      className="PreferencesMenu__Character__FieldDropdown"
      buttons={buttons}
      disabled={disabled || !serverData}
      onSelected={handleSetValue}
      displayText={displayText ? capitalizeDropdownDisplayText(displayText) : ''}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;
  const { data } = useBackend<PreferencesMenuData>();
  const { language } = usePreferencesLocalization(data);

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  function populateOptions() {
    if (!serverData) return;
    const { icons = {}, choices = [] } = serverData;

    const newOptions: DropdownOptions = [];

    for (const choice of choices) {
      const displayTextRaw: ReactNode = serverData.display_names?.[choice]
        ? serverData.display_names?.[choice]
        : capitalizeFirst(choice);
      let displayText: ReactNode = translateDropdownText(
        choice,
        displayTextRaw,
        language,
      );

      if (serverData.icons?.[choice]) {
        displayText = (
          <Stack>
            <Stack.Item>
              <Box
                className={classes(['preferences32x32', icons[choice]])}
                style={{ transform: 'scale(0.8)' }}
              />
            </Stack.Item>
            <Stack.Item grow>{displayText}</Stack.Item>
          </Stack>
        );
      }

      newOptions.push({
        displayText,
        value: choice,
      });
    }

    setDropdownOptions(newOptions);
  }

  useEffect(() => {
    if (serverData) {
      populateOptions();
    }
  }, [serverData]);

  const displayTextRaw = serverData?.display_names?.[value] || String(value);
  const displayText = translateDropdownText(value, displayTextRaw, language);

  return (
    <Dropdown
      className="PreferencesMenu__Character__FieldDropdown"
      buttons
      displayText={displayText ? capitalizeDropdownDisplayText(displayText) : ''}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value}
      width="100%"
      menuWidth="max-content"
    />
  );
}
