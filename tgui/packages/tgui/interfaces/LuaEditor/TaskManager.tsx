import type { Dispatch, SetStateAction } from 'react';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { CallInfo, LuaEditorData, LuaEditorModal } from './types';

type TaskManagerProps = {
  setToCall: Dispatch<SetStateAction<CallInfo>>;
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
};

export const TaskManager = (props: TaskManagerProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { t } = usePreferencesLocalization(data);
  const { setToCall, setModal } = props;
  const { tasks } = data;
  const { sleeps = [], yields = [] } = tasks;
  return (
    <Stack fill width="100%" justify="space-around">
      <Stack.Item grow shrink>
        <Section title={t('ui.lua_editor.sleeps')} fill>
          <LabeledList>
            {sleeps.map(({ index, name }, i) => (
              <LabeledList.Item key={i} label={name}>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() =>
                    act('killTask', { is_sleep: true, index: index })
                  }
                >
                  {t('ui.lua_editor.kill')}
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow shrink>
        <Section title={t('ui.lua_editor.yields')} fill>
          <LabeledList>
            {yields.map(({ index, name }, i) => (
              <LabeledList.Item key={i} label={name}>
                <Button
                  onClick={() => {
                    setToCall({
                      type: 'resumeTask',
                      params: { index: index },
                    });
                    setModal('call');
                  }}
                >
                  {t('ui.lua_editor.call')}
                </Button>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() => {
                    act('killTask', { is_sleep: false, index: index });
                  }}
                >
                  {t('ui.lua_editor.kill')}
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
