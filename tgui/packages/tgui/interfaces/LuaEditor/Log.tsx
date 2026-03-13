import type { Dispatch, SetStateAction } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { logger } from '../../logging';
import { usePreferencesLocalization } from '../localization';
import { ListMapper } from './ListMapper';
import type { LuaEditorData, LuaEditorModal } from './types';

const parsePanic = (
  name,
  panic_json,
  t: (key: string, fallback?: string) => string,
) => {
  const panic_info = JSON.parse(panic_json);
  const {
    message,
    location: { file, line },
    backtrace,
  } = panic_info;
  return (
    <>
      <Box textColor="red">
        <b>{name}</b> {t('ui.lua_editor.panicked_at')} {file}:{line}: {message}
      </Box>
      <Collapsible title={t('ui.lua_editor.backtrace')}>
        <Stack vertical>
          {backtrace
            ?.filter(
              (frame) => frame.file !== undefined && frame.line !== undefined,
            )
            ?.map(({ name, file, line }, i) => (
              <>
                {i > 0 && <Divider />}
                <Stack.Item key={i}>
                  <LabeledList>
                    <LabeledList.Item label={t('ui.lua_editor.function')}>
                      {name}
                    </LabeledList.Item>
                    <LabeledList.Item label={t('ui.lua_editor.location')}>
                      {file}:{line}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </>
            ))}
        </Stack>
      </Collapsible>
    </>
  );
};

type LogProps = {
  setViewedChunk: Dispatch<SetStateAction<string | undefined>>;
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
};

export const Log = (props: LogProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { t } = usePreferencesLocalization(data);
  const { stateLog } = data;
  const { setViewedChunk, setModal } = props;

  return stateLog.map((element, i) => {
    const { status, repeats } = element;
    let output;
    let messageColor;
    switch (status) {
      case 'sleep': {
        const { chunk, name } = element;
        if (chunk) {
          messageColor = 'blue';
          output = (
            <>
              <b>{name}</b> {t('ui.lua_editor.slept')}.
            </>
          );
        }
        break;
      }
      case 'yield': {
        const { name, return_values, variants } = element;
        output = (
          <>
            <b>{name}</b> {t('ui.lua_editor.yielded')}
            {return_values.length
              ? ` ${return_values.length} ${
                  return_values.length > 1
                    ? t('ui.lua_editor.values')
                    : t('ui.lua_editor.value')
                }`
              : ''}
            .
            {return_values.length ? (
              <ListMapper
                list={return_values}
                variants={variants}
                skipNulls
                name={t('ui.lua_editor.return_values')}
                collapsible
                vvAct={(path) =>
                  act('vvReturnValue', {
                    entryIndex: i + 1,
                    indices: path,
                  })
                }
              />
            ) : (
              <br />
            )}
          </>
        );
        messageColor = 'yellow';
        break;
      }
      case 'finished': {
        const { name, return_values, variants } = element;
        output = (
          <>
            <b>{name}</b> {t('ui.lua_editor.returned')}
            {return_values.length
              ? ` ${return_values.length} ${
                  return_values.length > 1
                    ? t('ui.lua_editor.values')
                    : t('ui.lua_editor.value')
                }`
              : ''}
            .
            {return_values.length ? (
              <Box color="default">
                <ListMapper
                  list={return_values}
                  variants={variants}
                  skipNulls
                  name={t('ui.lua_editor.return_values')}
                  collapsible
                  vvAct={(path) =>
                    act('vvReturnValue', {
                      entryIndex: i + 1,
                      tableIndices: path,
                    })
                  }
                />
              </Box>
            ) : (
              <br />
            )}
          </>
        );
        messageColor = 'green';
        break;
      }
      case 'error': {
        const { message } = element;
        output = message;
        messageColor = 'red';
        break;
      }
      case 'panic': {
        const { name, message } = element;
        output = parsePanic(name, message, t);
        break;
      }
      case 'runtime': {
        const { file, line, message, stack } = element;
        output = (
          <>
            {t('ui.lua_editor.runtime_at')} {file}:{line}: {message}
            <ListMapper
              list={stack.map((frame) => {
                return { key: null, value: frame };
              })}
              name={t('ui.lua_editor.stack_trace')}
              collapsible
            />
          </>
        );
        messageColor = 'red';
        break;
      }
      case 'print': {
        const { message } = element;
        output = message;
        break;
      }
      default:
        logger.warn(`unknown log status ${status}`);
    }
    if (output === undefined) {
      return null;
    }
    const { chunk } = element;
    if (chunk) {
      output = (
        <>
          <Box>{output}</Box>
          <Button
            onClick={() => {
              setViewedChunk(chunk);
              setModal('viewChunk');
            }}
          >
            {t('ui.lua_editor.view_source')}
          </Button>
        </>
      );
    }
    return (
      <>
        {i > 0 && <Divider />}
        <Box width="100%" key={i} color={messageColor}>
          {output}
        </Box>
        {repeats && (
          <Box
            inline
            px="0.25rem"
            mt="0.25rem"
            style={{
              borderRadius: '0.5em',
            }}
            backgroundColor={messageColor}
          >
            x{repeats + 1}
          </Box>
        )}
      </>
    );
  });
};
