import {
  Button,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type EyeColorData = {
  mode: BooleanLike;
  hasOwner: BooleanLike;
  left: string;
  right: string;
};

type Data = {
  eyeColor: EyeColorData;
  lightColor: string;
  range: number;
};

enum ToUpdate {
  LightColor,
  LeftEye,
  RightEye,
}

const LightColorDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { lightColor } = data;
  return (
    <LabeledList.Item label={t('ui.common.color')}>
      <ColorBox color={lightColor} />{' '}
      <Button
        icon="palette"
        onClick={() => act('pick_color', { to_update: ToUpdate.LightColor })}
        tooltip={t('ui.high_luminosity_eyes.pick_light_color')}
      />
      <Button
        icon="dice"
        onClick={() => act('random_color', { to_update: ToUpdate.LightColor })}
        tooltip={t('ui.high_luminosity_eyes.randomize_light_color')}
      />
      <Input
        value={lightColor}
        width={6}
        maxLength={7}
        onBlur={(value) =>
          act('enter_color', {
            new_color: value,
            to_update: ToUpdate.LightColor,
          })
        }
      />
    </LabeledList.Item>
  );
};

const RangeDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { range } = data;
  return (
    <LabeledList.Item label={t('ui.common.range')}>
      <Button
        icon="minus-square-o"
        onClick={() => act('set_range', { new_range: range - 1 })}
        tooltip={t('ui.high_luminosity_eyes.reduce_range')}
      />
      <Button
        icon="plus-square-o"
        onClick={() => act('set_range', { new_range: range + 1 })}
        tooltip={t('ui.high_luminosity_eyes.increase_range')}
      />
      <NumberInput
        animated
        tickWhileDragging
        width="35px"
        step={1}
        stepPixelSize={5}
        value={range}
        minValue={0}
        maxValue={5}
        onChange={(value) =>
          act('set_range', {
            new_range: value,
          })
        }
      />
    </LabeledList.Item>
  );
};

const EyeColorDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { eyeColor } = data;
  return (
    <>
      <LabeledList.Item label={t('ui.high_luminosity_eyes.match_color')}>
        <Button.Checkbox
          checked={eyeColor.mode}
          onClick={() => act('toggle_eye_color')}
          tooltip={t('ui.high_luminosity_eyes.toggle_eye_match')}
        />
      </LabeledList.Item>
      {!eyeColor.mode && (
        <>
          <LabeledList.Item label={t('ui.high_luminosity_eyes.left_eye')}>
            <ColorBox color={eyeColor.left} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { to_update: ToUpdate.LeftEye })}
              tooltip={t('ui.high_luminosity_eyes.pick_light_color')}
            />
            <Button
              icon="dice"
              onClick={() =>
                act('random_color', { to_update: ToUpdate.LeftEye })
              }
              tooltip={t('ui.high_luminosity_eyes.randomize_eye_color')}
            />
            <Input
              value={eyeColor.left}
              width={6}
              maxLength={7}
              onBlur={(value) =>
                act('enter_color', {
                  new_color: value,
                  to_update: ToUpdate.LeftEye,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.high_luminosity_eyes.right_eye')}>
            <ColorBox color={eyeColor.right} />{' '}
            <Button
              icon="palette"
              onClick={() =>
                act('pick_color', { to_update: ToUpdate.RightEye })
              }
              tooltip={t('ui.high_luminosity_eyes.pick_light_color')}
            />
            <Button
              icon="dice"
              onClick={() =>
                act('random_color', { to_update: ToUpdate.RightEye })
              }
              tooltip={t('ui.high_luminosity_eyes.randomize_eye_color')}
            />
            <Input
              value={eyeColor.right}
              width={6}
              maxLength={7}
              onBlur={(value) =>
                act('enter_color', {
                  new_color: value,
                  to_update: ToUpdate.RightEye,
                })
              }
            />
          </LabeledList.Item>
        </>
      )}
    </>
  );
};

export const HighLuminosityEyesMenu = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { eyeColor } = data;
  return (
    <Window
      title={t('ui.high_luminosity_eyes.title')}
      width={eyeColor.hasOwner ? 262 : 225}
      height={eyeColor.hasOwner ? (eyeColor.mode ? 170 : 220) : 135}
    >
      <Window.Content>
        <Section fill title={t('ui.common.settings')}>
          <LabeledList>
            <LightColorDisplay />
            <RangeDisplay />
            {!!eyeColor.hasOwner && <EyeColorDisplay />}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
