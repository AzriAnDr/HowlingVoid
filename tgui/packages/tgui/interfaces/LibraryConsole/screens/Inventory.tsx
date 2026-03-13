import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Stack, Table } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import { PageSelect } from '../components/PageSelect';
import { ScrollableSection } from '../components/ScrollableSection';
import type { LibraryConsoleData } from '../types';

export function Inventory(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const { inventory_page_count, inventory_page, has_inventory } = data;

  if (!has_inventory) {
    return (
      <NoticeBox>{t('ui.library.no_book_records_detected')}</NoticeBox>
    );
  }

  return (
    <Stack vertical justify="space-between" height="100%">
      <Stack.Item grow>
        <ScrollableSection
          header={t('ui.library.inventory')}
          contents={<InventoryDetails />}
        />
      </Stack.Item>
      <Stack.Item align="center">
        <PageSelect
          minimum_page_count={1}
          page_count={inventory_page_count}
          current_page={inventory_page}
          call_on_change={(value) =>
            act('switch_inventory_page', {
              page: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}

function InventoryDetails(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const { inventory = [] } = data;

  const sorted = inventory
    .map((book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    }))
    .sort((a, b) => a.key - b.key);

  return (
    <Table>
      <Table.Row header className="candystripe">
        <Table.Cell>{t('ui.common.title')}</Table.Cell>
        <Table.Cell>{t('ui.common.author')}</Table.Cell>
        <Table.Cell textAlign="center">{t('ui.common.remove')}</Table.Cell>
      </Table.Row>
      {sorted.map((book) => (
        <Table.Row key={book.key} className="candystripe">
          <Table.Cell>{book.title}</Table.Cell>
          <Table.Cell>{book.author}</Table.Cell>
          <Table.Cell collapsing>
            <Button
              mb={1}
              color="bad"
              onClick={() =>
                act('inventory_remove', {
                  book_id: book.ref,
                })
              }
              icon="times"
            >
              {t('ui.library.clear_record')}
            </Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}
