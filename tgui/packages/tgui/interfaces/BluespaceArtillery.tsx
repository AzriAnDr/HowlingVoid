import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  connected: BooleanLike;
  notice: string;
  unlocked: BooleanLike;
  target: string;
};

export const BluespaceArtillery = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { notice, connected, unlocked, target } = data;

  return (
    <Window width={400} height={220}>
      <Window.Content>
        {!!notice && <NoticeBox>{notice}</NoticeBox>}
        {connected ? (
          <>
            <Section
              title={t('ui.common.target')}
              buttons={
                <Button
                  icon="crosshairs"
                  disabled={!unlocked}
                  onClick={() => act('recalibrate')}
                />
              }
            >
              <Box color={target ? 'average' : 'bad'} fontSize="25px">
                {target || t('ui.bluespace_artillery.no_target_set')}
              </Box>
            </Section>
            <Section>
              {unlocked ? (
                <Box style={{ margin: 'auto' }}>
                  <Button
                    fluid
                    content={t('ui.bluespace_artillery.fire')}
                    color="bad"
                    disabled={!target}
                    fontSize="30px"
                    textAlign="center"
                    lineHeight="46px"
                    onClick={() => act('fire')}
                  />
                </Box>
              ) : (
                <>
                  <Box color="bad" fontSize="18px">
                    {t('ui.bluespace_artillery.currently_locked')}
                  </Box>
                  <Box mt={1}>
                    {t('ui.bluespace_artillery.awaiting_authorization')}
                  </Box>
                </>
              )}
            </Section>
          </>
        ) : (
          <Section>
            <LabeledList>
              <LabeledList.Item label={t('ui.common.maintenance')}>
                <Button
                  icon="wrench"
                  content={t('ui.bluespace_artillery.complete_deployment')}
                  onClick={() => act('build')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
