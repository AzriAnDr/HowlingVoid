import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const LibraryScanner = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Window title={t('ui.library.library_scanner')} width={350} height={150}>
      <BookScanning />
    </Window>
  );
};

const BookScanning = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { has_book, has_cache, book } = data;
  if (!has_book && !has_cache) {
    return <NoticeBox>{t('ui.library.insert_a_book_to_scan')}</NoticeBox>;
  }
  return (
    <Stack direction="column" height="100%" justify="flex-end">
      <Stack.Item grow>
        <Section textAlign="center" height="100%" title={book.author}>
          {book.title}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              onClick={() => act('eject')}
              disabled={!has_book}
            >
              {t('ui.library.eject_book')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              onClick={() => act('scan')}
              color="good"
              icon="qrcode"
              disabled={!has_book}
            >
              {t('ui.library.scan_book')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="fire"
              onClick={() => act('clear')}
              color="bad"
              disabled={!has_cache}
            >
              {t('ui.library.clear_cache')}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
