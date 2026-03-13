// THIS IS A NOVA SECTOR UI FILE
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type GlassData = {
  hasGlass: BooleanLike;
  inUse: BooleanLike;
  glass: Glass;
};

type Glass = {
  chosenItem: CraftItem;
  stepsRemaining: RemainingSteps;
  timeLeft: number;
  totalTime: number;
  isFinished: BooleanLike;
};

type CraftItem = {
  name: string;
  type: string;
};

type RemainingSteps = {
  blow: number;
  spin: number;
  paddle: number;
  shear: number;
  jacks: number;
};

export const GlassBlowing = (props) => {
  const { act, data } = useBackend<GlassData>();
  const { t } = usePreferencesLocalization();
  const { glass, inUse } = data;

  return (
    <Window width={335} height={325}>
      <Window.Content scrollable>
        <Section
          title={
            glass?.timeLeft
              ? t('ui.glass_blowing.molten_glass')
              : t('ui.glass_blowing.cooled_glass')
          }
          buttons={
            <Button
              icon={
                glass?.isFinished
                  ? 'check'
                  : glass?.timeLeft
                    ? 'triangle-exclamation'
                    : 'arrow-right'
              }
              color={
                glass?.isFinished
                  ? 'good'
                  : glass?.timeLeft
                    ? 'red'
                    : 'default'
              }
              tooltipPosition="bottom"
              tooltip={
                glass?.timeLeft
                  ? t('ui.glass_blowing.hot_glass_warning')
                  : t('ui.glass_blowing.safe_to_handle')
              }
              content={
                glass?.isFinished
                  ? t('ui.glass_blowing.complete_craft')
                  : t('ui.glass_blowing.remove')
              }
              disabled={!glass || inUse}
              onClick={() => act('Remove')}
            />
          }
        />
        {glass && !glass.chosenItem && (
          <Section title={t('ui.glass_blowing.pick_a_craft')}>
            <Stack fill vertical>
              <Stack.Item>
                <Box>{t('ui.glass_blowing.what_will_you_craft')}</Box>
              </Stack.Item>

              <Stack.Item>
                <Button
                  content={t('ui.glass_blowing.plate')}
                  disabled={inUse}
                  onClick={() => act('Plate')}
                />
                <Button
                  content={t('ui.glass_blowing.bowl')}
                  tooltipPosition="bottom"
                  disabled={inUse}
                  onClick={() => act('Bowl')}
                />
                <Button
                  content={t('ui.glass_blowing.globe')}
                  disabled={inUse}
                  onClick={() => act('Globe')}
                />
                <Button
                  content={t('ui.glass_blowing.cup')}
                  disabled={inUse}
                  onClick={() => act('Cup')}
                />
                <Button
                  content={t('ui.glass_blowing.lens')}
                  tooltipPosition="bottom"
                  disabled={inUse}
                  onClick={() => act('Lens')}
                />
                <Button
                  content={t('ui.glass_blowing.bottle')}
                  disabled={inUse}
                  onClick={() => act('Bottle')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        )}
        {glass?.chosenItem && (
          <>
            <Section title={t('ui.glass_blowing.steps_remaining')}>
              <Stack fill vertical>
                <Stack.Item>
                  <Box>
                    {t('ui.glass_blowing.you_are_crafting')} {glass.chosenItem.name}.
                    <br />
                    <br />
                  </Box>
                </Stack.Item>
                <Table>
                  <Stack.Item>
                    {glass.stepsRemaining.blow !== 0 && (
                      <Table.Cell>
                        <Button
                          content={t('ui.glass_blowing.blow')}
                          icon="fire"
                          color="orange"
                          disabled={inUse || !glass.timeLeft}
                          tooltipPosition="bottom"
                          tooltip={
                            glass.timeLeft === 0
                              ? t('ui.glass_blowing.needs_to_be_glowing_hot')
                              : ''
                          }
                          onClick={() => act('Blow')}
                        />
                        &nbsp;x{glass.stepsRemaining.blow}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.spin !== 0 && (
                      <Table.Cell>
                        <Button
                          content={t('ui.glass_blowing.spin')}
                          icon="fire"
                          color="orange"
                          disabled={inUse || !glass.timeLeft}
                          tooltipPosition="bottom"
                          tooltip={
                            glass.timeLeft === 0
                              ? t('ui.glass_blowing.needs_to_be_glowing_hot')
                              : ''
                          }
                          onClick={() => act('Spin')}
                        />
                        &nbsp;x{glass.stepsRemaining.spin}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.paddle !== 0 && (
                      <Table.Cell>
                        <Button
                          content={t('ui.glass_blowing.paddle')}
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={t('ui.glass_blowing.you_need_to_use_a_paddle')}
                          onClick={() => act('Paddle')}
                        />
                        &nbsp;x{glass.stepsRemaining.paddle}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.shear !== 0 && (
                      <Table.Cell>
                        <Button
                          content={t('ui.glass_blowing.shears')}
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={t('ui.glass_blowing.you_need_to_use_shears')}
                          onClick={() => act('Shear')}
                        />
                        &nbsp;x{glass.stepsRemaining.shear}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.jacks !== 0 && (
                      <Table.Cell>
                        <Button
                          content={t('ui.glass_blowing.jacks')}
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={t('ui.glass_blowing.you_need_to_use_jacks')}
                          onClick={() => act('Jacks')}
                        />
                        &nbsp;x{glass.stepsRemaining.jacks}
                      </Table.Cell>
                    )}
                  </Stack.Item>
                </Table>
              </Stack>
            </Section>
            <Section title>
              <Flex direction="row-reverse">
                <Flex.Item>
                  <Button
                    icon="times"
                    color={glass.timeLeft ? 'orange' : 'default'}
                    content={t('ui.glass_blowing.cancel_craft')}
                    disabled={inUse}
                    onClick={() => act('Cancel')}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </>
        )}
        {glass && glass.timeLeft !== 0 && (
          <Section title={t('ui.glass_blowing.heat_level')}>
            <ProgressBar
              value={glass.timeLeft / glass.totalTime}
              ranges={{
                red: [0.8, Infinity],
                orange: [0.65, 0.8],
                yellow: [0.3, 0.65],
                blue: [0.05, 0.3],
                black: [-Infinity, 0.05],
              }}
              style={{
                backgroundImage: 'linear-gradient(to right, blue, yellow, red)',
              }}
            >
              <AnimatedNumber
                value={glass.timeLeft}
                format={(value) => toFixed(value, 1)}
              />
              {`/${glass.totalTime.toFixed(1)}`}
            </ProgressBar>
          </Section>
        )}
        {glass && glass.timeLeft === 0 && (
          <Section title={t('ui.glass_blowing.heat_level')}>
            <ProgressBar
              value={0 / 0}
              ranges={{}}
              style={{
                backgroundImage: 'grey',
              }}
            >
              <AnimatedNumber value={0} />
            </ProgressBar>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
