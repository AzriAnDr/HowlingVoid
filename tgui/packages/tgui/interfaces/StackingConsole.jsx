import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const StackingConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { machine } = data;
  return (
    <Window width={320} height={340}>
      <Window.Content scrollable>
        {!machine ? (
          <NoticeBox>{t('ui.stacking_console.no_connected_stacking_machine')}</NoticeBox>
        ) : (
          <StackingConsoleContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const StackingConsoleContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    input_direction,
    output_direction,
    stacking_amount,
    contents = [],
  } = data;
  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item label={t('ui.stacking_console.stacking_amount')}>
            {stacking_amount || t('ui.common.unknown')}
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.common.input')}
            buttons={
              <Button
                icon="rotate"
                content={t('ui.common.rotate')}
                onClick={() =>
                  act('rotate', {
                    input: 1,
                  })
                }
              />
            }
          >
            <Box style={{ textTransform: 'capitalize' }}>{input_direction}</Box>
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.common.output')}
            buttons={
              <Button
                icon="rotate"
                content={t('ui.common.rotate')}
                onClick={() =>
                  act('rotate', {
                    input: 0,
                  })
                }
              />
            }
          >
            <Box style={{ textTransform: 'capitalize' }}>
              {output_direction}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={t('ui.stacking_console.stored_materials')}>
        {!contents.length ? (
          <NoticeBox>{t('ui.stacking_console.no_stored_materials')}</NoticeBox>
        ) : (
          <LabeledList>
            {contents.map((sheet) => (
              <LabeledList.Item
                key={sheet.type}
                label={sheet.name}
                buttons={
                  <Button
                    icon="eject"
                    content={t('ui.common.release')}
                    onClick={() =>
                      act('release', {
                        type: sheet.type,
                      })
                    }
                  />
                }
              >
                {sheet.amount || t('ui.common.unknown')}
              </LabeledList.Item>
            ))}
          </LabeledList>
        )}
      </Section>
    </>
  );
};
