import { useState } from 'react';
import {
  Button,
  NoticeBox,
  Stack,
  Table,
  TextArea,
} from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { useModifyState } from './hooks';
import { type LibraryAdminData, ModifyTypes } from './types';

function getActionColor(reason: string) {
  switch (reason) {
    case 'deleted':
      return 'rgba(255, 0, 0, 0.4)';
    case 'undeleted':
      return 'rgba(0, 120, 70, 0.4)';
    default:
      return 'rgba(0, 0, 0, 0.4)';
  }
}

export function ModifyPage(props) {
  const { act, data } = useBackend<LibraryAdminData>();
  const { t } = usePreferencesLocalization(data);

  const { can_db_request, view_raw, history } = data;
  const { modifyMethodState, modifyTargetState } = useModifyState();

  const [modifyMethod, setModifyMethod] = modifyMethodState;
  const [modifyTarget, setModifyTarget] = modifyTargetState;
  const [reason, setReason] = useState('null');

  const entries = history[modifyTarget.toString()]
    ? history[modifyTarget.toString()].sort((a, b) => b.id - a.id)
    : [];

  return (
    <Window.Content scrollable>
      <NoticeBox>
        {t('ui.library_admin.heads_up_no_full_delete')}
        <br />
        {t('ui.library_admin.dont_show_to_anyone')}
        <br />
        {t('ui.library_admin.speak_to_database_administrator')}
      </NoticeBox>
      <Stack>
        <Stack.Item fontSize="25px" pb={2}>
          {`${t('ui.library_admin.why_modify_book_prefix')} ${modifyMethod} ${t('ui.library_admin.why_modify_book_suffix')}`}
        </Stack.Item>
        <Stack.Item fontSize="17px">
          <Button
            onClick={() =>
              act('view_book', {
                book_id: modifyTarget,
              })
            }
            icon="book-reader"
          >
            {t('ui.library_admin.view')}
          </Button>
        </Stack.Item>
        <Stack.Item fontSize="17px">
          <Button
            textAlign="right"
            onClick={() => act('toggle_raw')}
            color={view_raw ? 'purple' : 'blue'}
            icon={view_raw ? 'theater-masks' : 'glasses'}
          >
            {view_raw
              ? t('ui.library_admin.raw')
              : t('ui.library_admin.normal')}
          </Button>
        </Stack.Item>
      </Stack>
      <TextArea
        fluid
        height="20vh"
        width="100%"
        backgroundColor="black"
        textColor="white"
        onChange={setReason}
      />
      <Stack justify="center" align="center" pt={1} pb={1}>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            icon="upload"
            fontSize="18px"
            color="good"
            onClick={() => {
              switch (modifyMethod) {
                case ModifyTypes.Delete:
                  act('hide_book', {
                    book_id: modifyTarget,
                    delete_reason: reason,
                  });
                  break;
                case ModifyTypes.Restore:
                  act('unhide_book', {
                    book_id: modifyTarget,
                    free_reason: reason,
                  });
                  break;
              }
              setModifyMethod('');
              setModifyTarget(0);
            }}
            lineHeight={2}
          >
            {capitalize(modifyMethod)}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            fontSize="18px"
            color="bad"
            onClick={() => {
              setModifyMethod('');
              setModifyTarget(0);
            }}
            lineHeight={2}
          >
            {t('ui.library_admin.return')}
          </Button>
        </Stack.Item>
      </Stack>
      <Table>
        <Table.Row backgroundColor="rgba(0,0,0, 0.4)" header>
          <Table.Cell className="LibraryAdmin_RecordHeader">
            {t('ui.library_admin.id')}
          </Table.Cell>
          <Table.Cell className="LibraryAdmin_RecordHeader">
            {t('ui.library_admin.action')}
          </Table.Cell>
          <Table.Cell className="LibraryAdmin_RecordHeader">
            {t('ui.library_admin.reason')}
          </Table.Cell>
          <Table.Cell className="LibraryAdmin_RecordHeader">
            {t('ui.library_admin.admin_key')}
          </Table.Cell>
          <Table.Cell className="LibraryAdmin_RecordHeader">
            {t('ui.library_admin.datetime')}
          </Table.Cell>
        </Table.Row>
        {entries.map((entry) => (
          <Table.Row
            key={entry.id}
            backgroundColor={getActionColor(entry.action)}
          >
            <Table.Cell className="LibraryAdmin_RecordCell">
              {entry.id}
            </Table.Cell>
            <Table.Cell className="LibraryAdmin_RecordCell">
              {capitalize(entry.action)}
            </Table.Cell>
            <Table.Cell
              className="LibraryAdmin_RecordCell"
              style={{
                whiteSpace: 'pre-wrap',
              }}
            >
              {entry.reason}
            </Table.Cell>
            <Table.Cell className="LibraryAdmin_RecordCell">
              {entry.ckey}
            </Table.Cell>
            <Table.Cell className="LibraryAdmin_RecordCell">
              {entry.datetime}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Window.Content>
  );
}
