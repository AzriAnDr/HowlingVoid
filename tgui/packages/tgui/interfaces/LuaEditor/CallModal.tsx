import type { Dispatch, SetStateAction } from 'react';
import { Button, Modal, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { ListMapper } from './ListMapper';
import type { CallInfo, LuaEditorData, LuaEditorModal } from './types';

type CallModalProps = {
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
  toCall: CallInfo;
  setToCall: Dispatch<SetStateAction<CallInfo | undefined>>;
};

export const CallModal = (props: CallModalProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { t } = usePreferencesLocalization(data);
  const { callArguments } = data;
  const { setModal, toCall, setToCall } = props;
  const { type, params } = toCall;
  return (
    <Modal
      height={`${window.innerHeight * 0.8}px`}
      width={`${window.innerWidth * 0.5}px`}
    >
      <Section
        fill
        scrollable
        scrollableHorizontal
        title={t('ui.lua_editor.call_function_or_task')}
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(undefined);
              setToCall(undefined);
              act('clearArgs');
            }}
          >
            {t('ui.common.cancel')}
          </Button>
        }
      >
        <ListMapper name={t('ui.lua_editor.arguments')} list={callArguments} editable />
        <Button
          onClick={() => {
            setModal(undefined);
            setToCall(undefined);
            act(type, params);
          }}
        >
          {t('ui.lua_editor.call')}
        </Button>
      </Section>
    </Modal>
  );
};
