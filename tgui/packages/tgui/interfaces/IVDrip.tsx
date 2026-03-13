import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type IVDripData = {
  hasInternalStorage: BooleanLike;
  hasContainer: BooleanLike;
  canRemoveContainer: BooleanLike;
  mode: BooleanLike;
  canDraw: BooleanLike;
  injectFromPlumbing: BooleanLike;
  canAdjustTransfer: BooleanLike;
  transferRate: number;
  transferStep: number;
  minTransferRate: number;
  maxTransferRate: number;
  hasObjectAttached: BooleanLike;
  objectName: string;
  containerReagentColor: string;
  containerCurrentVolume: number;
  containerMaxVolume: number;
};

enum MODE {
  drawing,
  injecting,
}

export const IVDrip = (props) => {
  const { act, data } = useBackend<IVDripData>();
  const { t } = usePreferencesLocalization();
  const {
    hasContainer,
    canRemoveContainer,
    mode,
    canDraw,
    hasInternalStorage,
    transferRate,
    transferStep,
    maxTransferRate,
    minTransferRate,
    hasObjectAttached,
    objectName,
    containerCurrentVolume,
    containerMaxVolume,
    containerReagentColor,
  } = data;
  return (
    <Window width={400} height={220}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.iv_drip.flow_rate')}
              buttons={
                <Box>
                  <Button
                    width={4}
                    lineHeight={2}
                    align="center"
                    icon="angles-left"
                    onClick={() =>
                      act('changeRate', {
                        rate: minTransferRate,
                      })
                    }
                  />
                  <Button
                    width={4}
                    lineHeight={2}
                    align="center"
                    icon="angles-right"
                    onClick={() =>
                      act('changeRate', {
                        rate: maxTransferRate,
                      })
                    }
                  />
                </Box>
              }
            >
              <Slider
                step={transferStep}
                my={1}
                value={transferRate}
                minValue={minTransferRate}
                maxValue={maxTransferRate}
                unit={t('ui.iv_drip.units_per_sec')}
                onChange={(e, value) =>
                  act('changeRate', {
                    rate: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.common.direction')}
              color={!mode ? 'bad' : ''}
              buttons={
                <Button
                  my={1}
                  width={8}
                  lineHeight={2}
                  align="center"
                  disabled={!canDraw}
                  color={!mode && 'bad'}
                  content={
                    mode
                      ? t('ui.iv_drip.injecting')
                      : t('ui.iv_drip.draining')
                  }
                  icon={mode ? 'syringe' : 'droplet'}
                  onClick={() => act('changeMode')}
                />
              }
            >
              {mode
                ? hasInternalStorage
                  ? t('ui.iv_drip.reagents_from_network')
                  : t('ui.iv_drip.reagents_from_container')
                : t('ui.iv_drip.blood_into_container')}
            </LabeledList.Item>
            {hasContainer || hasInternalStorage ? (
              <LabeledList.Item
                label={t('ui.common.container')}
                buttons={
                  !hasInternalStorage &&
                  !!canRemoveContainer && (
                    <Button
                      my={1}
                      width={8}
                      lineHeight={2}
                      align="center"
                      icon="eject"
                      content={t('ui.common.eject')}
                      onClick={() => act('eject')}
                    />
                  )
                }
              >
                <ProgressBar
                  value={containerCurrentVolume}
                  minValue={0}
                  maxValue={containerMaxVolume}
                  color={containerReagentColor}
                >
                  <span
                    style={{
                      textShadow: '1px 1px 0 black',
                    }}
                  >
                    {`${containerCurrentVolume} ${t('ui.common.of')} ${containerMaxVolume} ${t('ui.iv_drip.units')}`}
                  </span>
                </ProgressBar>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label={t('ui.common.container')}>
                <Tooltip
                  content={t(
                    'ui.iv_drip.click_the_drip_with_a_container_in_hand_to_attach',
                  )}
                >
                  <NoticeBox my={0.7}>
                    {t('ui.iv_drip.no_container_attached')}
                  </NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
            {hasObjectAttached ? (
              <LabeledList.Item
                label={t('ui.common.object')}
                buttons={
                  <Button
                    disabled={!hasObjectAttached}
                    my={1}
                    width={8}
                    lineHeight={2}
                    align="center"
                    icon="ban"
                    content={t('ui.common.disconnect')}
                    onClick={() => act('detach')}
                  />
                }
              >
                <Box maxHeight={'45px'} overflow={'hidden'}>
                  {objectName}
                </Box>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label={t('ui.common.object')}>
                <Tooltip
                  content={t(
                    'ui.iv_drip.drag_the_cursor_from_the_drip_and_drop_it_on_an_object_to_connect',
                  )}
                >
                  <NoticeBox my={0.7}>
                    {t('ui.iv_drip.no_object_attached')}
                  </NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
