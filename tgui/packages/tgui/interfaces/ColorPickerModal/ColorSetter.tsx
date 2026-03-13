/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */
import React, { useCallback, useState } from 'react';
import {
  type HsvaColor,
  hexToHsva,
  hsvaToHex,
  hsvaToRgba,
  rgbaToHsva,
} from 'tgui-core/color';
import { Box, Button, Stack, Tooltip } from 'tgui-core/components';
import { InputButtons } from '../common/InputButtons';
import { usePreferencesLocalization } from '../localization';
import {
  ColorPresets,
  Hue,
  RGBSlider,
  Saturation,
  SaturationValue,
  Value,
} from './Color';
import { HexColorInput, TextSetter } from './TextSetter';

interface ColorSelectorProps {
  color: HsvaColor;
  setColor: React.Dispatch<React.SetStateAction<HsvaColor>>;
  defaultColor: string;
}

export const ColorSelector: React.FC<ColorSelectorProps> = React.memo(
  ({ color, setColor, defaultColor }) => {
    const { t } = usePreferencesLocalization();
    const handleChange = useCallback(
      (params: Partial<HsvaColor>) => {
        setColor((current) => ({ ...current, ...params }));
      },
      [setColor],
    );

    const [showPresets, setShowPresets] = useState<boolean>(false);
    const rgb = hsvaToRgba(color);
    const hexColor = hsvaToHex(color);

    return (
      <Stack className="PreferencesMenu__ColorPickerModal__Body" direction="row">
        <Stack.Item mr={2} mt={2.5}>
          <Stack vertical>
            <Stack.Item>
              <div className="react-colorful">
                <SaturationValue hsva={color} onChange={handleChange} />
                <Hue
                  hue={color.h}
                  onChange={handleChange}
                  className="react-colorful__last-control"
                />
              </div>
            </Stack.Item>
            <Stack.Item mt={3}>
              <Box inline width="100px" height="20px" textAlign="center">
                {t('ui.common.new')}
              </Box>
              <Box inline width="100px" height="20px" textAlign="center">
                {t('ui.common.current')}
              </Box>
              <br />
              <Tooltip content={hexColor} position="bottom">
                <Box
                  inline
                  width="100px"
                  height="30px"
                  backgroundColor={hexColor}
                />
              </Tooltip>
              <Tooltip content={defaultColor} position="bottom">
                <Box
                  inline
                  width="100px"
                  height="30px"
                  backgroundColor={defaultColor}
                />
              </Tooltip>
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={hsvaToHex(color)} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow fontSize="15px" lineHeight="24px">
          {showPresets ? (
            <ColorPresets
              setColor={(c) => handleChange(c)}
              setShowPresets={setShowPresets}
            />
          ) : (
            <Stack vertical>
              <Stack.Item mt={5.5}>
                <Stack>
                  <Stack.Item>
                    <Box textColor="label">{t('ui.color_picker.hex')}:</Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <HexColorInput
                      fluid
                      color={hsvaToHex(color).substring(1)}
                      onChange={(value) => {
                        setColor(hexToHsva(value));
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      className="PreferencesMenu__ColorPickerModal__PresetButton"
                      icon="chevron-down"
                      onClick={() => setShowPresets(true)}
                    >
                      {t('ui.color_picker.skin_tones_and_presets')}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Divider mt={2} mb={2} />
              <HueRow color={color} handleChange={handleChange} t={t} />
              <SaturationRow color={color} handleChange={handleChange} t={t} />
              <ValueRow color={color} handleChange={handleChange} t={t} />
              <Stack.Divider mt={2} mb={2} />
              <RedRow color={color} handleChange={handleChange} t={t} />
              <GreenRow color={color} handleChange={handleChange} t={t} />
              <BlueRow color={color} handleChange={handleChange} t={t} />
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    );
  },
);

interface RowProps {
  color: HsvaColor;
  handleChange: (c: Partial<HsvaColor>) => void;
  t: (key: string, fallback?: string) => string;
}

const HueRow: React.FC<RowProps> = React.memo(({ color, handleChange, t }) => (
  <Stack.Item>
    <Stack>
      <Stack.Item width="25px">
        <Box textColor="label">{t('ui.color_picker.hue_short')}</Box>
      </Stack.Item>
      <Stack.Item grow>
        <Hue hue={color.h} onChange={handleChange} />
      </Stack.Item>
      <Stack.Item>
        <TextSetter
          value={color.h}
          callback={(v) => handleChange({ h: v })}
          max={360}
          unit="°"
        />
      </Stack.Item>
    </Stack>
  </Stack.Item>
));

const SaturationRow: React.FC<RowProps> = React.memo(
  ({ color, handleChange, t }) => (
    <Stack.Item>
      <Stack>
        <Stack.Item width="25px">
          <Box textColor="label">{t('ui.color_picker.saturation_short')}</Box>
        </Stack.Item>
        <Stack.Item grow>
          <Saturation color={color} onChange={handleChange} />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={color.s}
            callback={(v) => handleChange({ s: v })}
            unit="%"
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  ),
);

const ValueRow: React.FC<RowProps> = React.memo(({ color, handleChange, t }) => (
  <Stack.Item>
    <Stack>
      <Stack.Item width="25px">
        <Box textColor="label">{t('ui.color_picker.value_short')}</Box>
      </Stack.Item>
      <Stack.Item grow>
        <Value color={color} onChange={handleChange} />
      </Stack.Item>
      <Stack.Item>
        <TextSetter
          value={color.v}
          callback={(v) => handleChange({ v })}
          unit="%"
        />
      </Stack.Item>
    </Stack>
  </Stack.Item>
));

interface RGBRowProps {
  color: HsvaColor;
  handleChange: (c: HsvaColor) => void;
  t: (key: string, fallback?: string) => string;
}

const RedRow: React.FC<RGBRowProps> = React.memo(({ color, handleChange, t }) => {
  const rgb = hsvaToRgba(color);
  return (
    <Stack.Item>
      <Stack>
      <Stack.Item width="25px">
          <Box textColor="label">{t('ui.color_picker.red_short')}</Box>
        </Stack.Item>
        <Stack.Item grow>
          <RGBSlider color={color} onChange={handleChange} target="r" />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={rgb.r}
            callback={(v) => {
              handleChange(rgbaToHsva({ ...rgb, r: v }));
            }}
            max={255}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
});

const GreenRow: React.FC<RGBRowProps> = React.memo(
  ({ color, handleChange, t }) => {
    const rgb = hsvaToRgba(color);
    return (
      <Stack.Item>
        <Stack>
          <Stack.Item width="25px">
            <Box textColor="label">{t('ui.color_picker.green_short')}</Box>
          </Stack.Item>
          <Stack.Item grow>
            <RGBSlider color={color} onChange={handleChange} target="g" />
          </Stack.Item>
          <Stack.Item>
            <TextSetter
              value={rgb.g}
              callback={(v) => {
                handleChange(rgbaToHsva({ ...rgb, g: v }));
              }}
              max={255}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    );
  },
);

const BlueRow: React.FC<RGBRowProps> = React.memo(({ color, handleChange, t }) => {
  const rgb = hsvaToRgba(color);
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item width="25px">
          <Box textColor="label">{t('ui.color_picker.blue_short')}</Box>
        </Stack.Item>
        <Stack.Item grow>
          <RGBSlider color={color} onChange={handleChange} target="b" />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={rgb.b}
            callback={(v) => {
              handleChange(rgbaToHsva({ ...rgb, b: v }));
            }}
            max={255}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
});
