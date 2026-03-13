import { useState } from 'react';
import { Button, Input, Modal, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { LuaEditorData, LuaEditorModal } from './types';

type StateSelectModalProps = {
  setModal: (modal: LuaEditorModal) => void;
};

export const StateSelectModal = (props: StateSelectModalProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { t } = usePreferencesLocalization(data);
  const { setModal } = props;

  const [input, setInput] = useState('');
  const { states } = data;

  return (
    <Modal position="absolute" width="30%" height="50%" top="25%" left="35%">
      <Section
        fill
        title={t('ui.lua_editor.states')}
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(undefined);
            }}
          >
            {t('ui.common.cancel')}
          </Button>
        }
      >
        {states.map((value, i) => (
          <Button
            key={i}
            onClick={() => {
              setModal(undefined);
              act('switchState', { index: i + 1 });
            }}
          >
            {value}
          </Button>
        ))}
        <Stack fill>
          <Stack.Item grow>
            <Input
              fluid
              placeholder={t('ui.lua_editor.new_state')}
              value={input}
              onChange={setInput}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => {
                setModal(undefined);
                act('newState', { name: input });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};
