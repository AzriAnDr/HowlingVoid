import { Box, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PageSelect } from '../LibraryConsole/components/PageSelect';
import { usePreferencesLocalization } from '../localization';
import { SearchAndDisplay } from './Search';
import type { LibraryAdminData } from './types';

export function BookListing(props) {
  const { act, data } = useBackend<LibraryAdminData>();
  const { t } = usePreferencesLocalization(data);
  const { can_connect, can_db_request, our_page, page_count } = data;

  if (!can_connect) {
    return (
      <NoticeBox>
        {t('ui.library_admin.unable_to_retrieve_book_listings')}
      </NoticeBox>
    );
  }

  return (
    <Stack fill vertical justify="space-between">
      <Stack.Item>
        <Box fillPositionedParent bottom="25px">
          <Window.Content scrollable>
            <SearchAndDisplay />
          </Window.Content>
        </Box>
      </Stack.Item>
      <Stack.Item align="center">
        <PageSelect
          minimum_page_count={1}
          page_count={page_count}
          current_page={our_page}
          disabled={!can_db_request}
          call_on_change={(value) =>
            act('switch_page', {
              page: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}
