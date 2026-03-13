import { sortBy } from 'es-toolkit';
import { map } from 'es-toolkit/compat';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PageSelect } from './LibraryConsole/components/PageSelect';
import { usePreferencesLocalization } from './localization';

export const LibraryVisitor = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Window title={t('ui.library_visitor.title')} width={702} height={421}>
      <BookListing />
    </Window>
  );
};

const BookListing = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { can_connect, can_db_request, our_page, page_count } = data;
  if (!can_connect) {
    return (
      <NoticeBox>
        {t('ui.library_visitor.unable_to_retrieve_book_listings')}
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
};

const SearchAndDisplay = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    can_db_request,
    search_categories = [],
    book_id,
    title,
    category,
    author,
    params_changed,
  } = data;
  const records = sortBy(
    map(data.pages, (record, i) => ({
      ...record,
      // Generate a unique id
      key: i,
    })),
    [(record) => record.key],
  );
  return (
    <Section>
      <Stack justify="space-between">
        <Stack.Item pb={0.6}>
          <Stack>
            <Stack.Item>
              <Input
                value={book_id}
                placeholder={book_id === null ? t('ui.common.id') : book_id}
                mt={0.5}
                width="70px"
                onBlur={(value) =>
                  act('set_search_id', {
                    id: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                options={search_categories}
                selected={category}
                onSelected={(value) =>
                  act('set_search_category', {
                    category: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={title}
                placeholder={title || t('ui.common.title')}
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_title', {
                    title: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author}
                placeholder={author || t('ui.common.author')}
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_author', {
                    author: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            textAlign="right"
            onClick={() => act('search')}
            color={params_changed ? 'good' : ''}
            icon="book"
          >
            {t('ui.common.search')}
          </Button>
          <Button
            disabled={!can_db_request}
            textAlign="right"
            onClick={() => act('clear_data')}
            color="bad"
            icon="fire"
          >
            {t('ui.library_visitor.reset_search')}
          </Button>
        </Stack.Item>
      </Stack>
      <Table>
        <Table.Row>
          <Table.Cell fontSize={1.5}>#</Table.Cell>
          <Table.Cell fontSize={1.5}>{t('ui.common.category')}</Table.Cell>
          <Table.Cell fontSize={1.5}>{t('ui.common.title')}</Table.Cell>
          <Table.Cell fontSize={1.5}>{t('ui.common.author')}</Table.Cell>
        </Table.Row>
        {records.map((record) => (
          <Table.Row key={record.key}>
            <Table.Cell>{record.id}</Table.Cell>
            <Table.Cell>{record.category}</Table.Cell>
            <Table.Cell>{record.title}</Table.Cell>
            <Table.Cell>{record.author}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
