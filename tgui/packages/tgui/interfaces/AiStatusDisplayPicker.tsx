import { useState } from 'react';
import {
  Box,
  DmIcon,
  Flex,
  ImageButton,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type StatusDisplayOption = {
  name: string;
  icon_state: string;
  is_original: BooleanLike;
  dmi: string;
  icon: string;
};

type CurrentIcon = {
  icon: string;
  icon_state: string;
};

type Data = {
  current_emotion: string;
  current_icon: CurrentIcon | null;
  options: StatusDisplayOption[];
};

export const AiStatusDisplayPicker = () => {
  const { t } = usePreferencesLocalization();
  return (
    <Window width={500} height={600} title={t('ui.ai_status_display.title')}>
      <Window.Content scrollable>
        <AiStatusDisplayPickerContent />
      </Window.Content>
    </Window>
  );
};

const AiStatusDisplayPickerContent = () => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { current_emotion, current_icon, options = [] } = data;

  const [searchTerm, setSearchTerm] = useState('');

  // Filter options based on search term
  const filteredOptions = options.filter((option) =>
    option.name.toLowerCase().includes(searchTerm.toLowerCase()),
  );

  // Separate original emotions and new AI core options
  const originalOptions = filteredOptions.filter(
    (option) => option.is_original,
  );
  const newOptions = filteredOptions.filter((option) => !option.is_original);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title={t('ui.ai_status_display.current_display')}>
          <Flex align="center" justify="center" direction="column">
            {current_icon && (
              <Flex.Item mb={2}>
                <Box
                  style={{
                    border: '2px solid #4a9eff',
                    borderRadius: '4px',
                    backgroundColor: '#1a1a1a',
                    padding: '8px',
                  }}
                >
                  <DmIcon
                    icon={current_icon.icon}
                    icon_state={current_icon.icon_state}
                    width="64px"
                    height="64px"
                  />
                </Box>
              </Flex.Item>
            )}
            <Flex.Item mb={1}>
                <Box fontSize="1.4em" textAlign="center" bold color="good">
                {current_emotion || t('ui.ai_status_display.no_selection')}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section>
          <Input
            fluid
            placeholder={t('ui.ai_status_display.search_placeholder')}
            value={searchTerm}
            onChange={(value) => setSearchTerm(value)}
          />
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          {originalOptions.length > 0 && (
            <Stack.Item>
              <Section title={t('ui.ai_status_display.ai_emotions')}>
                <OptionsList options={originalOptions} />
              </Section>
            </Stack.Item>
          )}

          {newOptions.length > 0 && (
            <Stack.Item>
              <Section title={t('ui.ai_status_display.additional_options')}>
                <OptionsList options={newOptions} />
              </Section>
            </Stack.Item>
          )}

          {filteredOptions.length === 0 && (
            <Stack.Item>
              <Box textAlign="center" color="average" mt={4}>
                {t('ui.ai_status_display.no_options_found_matching')} "{searchTerm}"
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const OptionsList = ({ options }: { options: StatusDisplayOption[] }) => {
  const { act } = useBackend<Data>();

  return (
    <>
      {options.map((option) => (
        <ImageButton
          key={option.name}
          dmIcon={option.icon}
          dmIconState={option.icon_state}
          onClick={() => act('select_option', { option: option.name })}
          imageSize={64}
          tooltip={option.name}
        >
          {option.name}
        </ImageButton>
      ))}
    </>
  );
};
