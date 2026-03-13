import {
  Box,
  Button,
  ByondUi,
  Flex,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const colorToMatrix = (param) => {
  switch (param) {
    case 'red':
      return [
        1, 0, 0, 0, 0.25, 0.5, 0, 0, 0.25, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'yellow':
      return [
        0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0.25, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
    case 'green':
      return [
        0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'teal':
      return [
        0.25, 0.25, 0.25, 0, 0, 0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0, 0, 1, 0, 0,
        0, 0,
      ];
    case 'blue':
      return [
        0.25, 0, 0.25, 0, 0, 0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'purple':
      return [
        0.5, 0, 0.5, 0, 0.25, 0.5, 0.25, 0, 0.5, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
  }
};

export const MODpaint = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { mapRef, currentColor } = data;
  const presets = ['red', 'yellow', 'green', 'teal', 'blue', 'purple'];
  const prefixes = ['r', 'g', 'b'];
  return (
    <Window width={600} height={365}>
      <Window.Content>
        <Stack fill>
          <Stack.Item fill width="30%">
            {[0, 1, 2].map((row) => (
              <Section
                key={row}
                title={`${t(`ui.modpaint.${prefixes[row]}_turns_to`)}`}
              >
                {[0, 1, 2].map((col) => (
                  <Flex key={col}>
                    <Flex.Item align="left" width="30%">
                      <Box inline textColor="label">
                        {`${t(`ui.modpaint.${prefixes[col]}`)}:`}
                      </Box>
                    </Flex.Item>
                    <Flex.Item align="right" width="70%">
                      <Slider
                        inline
                        textAlign="right"
                        value={currentColor[row * 4 + col] * 100}
                        minValue={0}
                        maxValue={125}
                        step={1}
                        stepPixelSize={0.75}
                        format={(value) => `${value}%`}
                        onChange={(e, value) => {
                          const retColor = currentColor;
                          retColor[row * 4 + col] = value / 100;
                          act('transition_color', { color: retColor });
                        }}
                      />
                    </Flex.Item>
                  </Flex>
                ))}
              </Section>
            ))}
          </Stack.Item>
          <Stack.Item width="25%">
            <Section height="70%" title={t('ui.modpaint.presets')}>
              <Box textAlign="center">
                {presets.map((preset) => (
                  <Button
                    key={preset}
                    height="50px"
                    width="50px"
                    color={preset}
                    tooltipPosition="top"
                    tooltip={capitalize(preset)}
                    onClick={() =>
                      act('transition_color', { color: colorToMatrix(preset) })
                    }
                  />
                ))}
              </Box>
            </Section>
            <Section textAlign="center" fontSize="28px">
              <Button
                height="50px"
                width="50px"
                icon="question"
                color="average"
                tooltipPosition="top"
                tooltip={t(
                  'ui.modpaint.this_is_a_color_matrix_think_of_it_as_editing_the_image_in_3_lay',
                )}
              />
              <Button
                height="50px"
                width="50px"
                icon="check"
                color="good"
                tooltipPosition="top"
                tooltip={t('ui.modpaint.confirm_changes')}
                onClick={() => act('confirm')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item width="45%">
            <Section fill title={t('ui.modpaint.preview')}>
              <ByondUi
                height="230px"
                params={{
                  id: mapRef,
                  type: 'map',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
