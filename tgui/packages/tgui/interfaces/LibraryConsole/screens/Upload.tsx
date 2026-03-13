import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { sanitizeText } from 'tgui/sanitize';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import type { LibraryConsoleData } from '../types';
import { useLibraryContext } from '../useLibraryContext';

export function Upload(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const {
    active_newscaster_cooldown,
    cache_author,
    cache_content,
    cache_title,
    can_db_request,
    cooldown_string,
    has_cache,
    has_scanner,
  } = data;

  const { uploadToDBState } = useLibraryContext();
  const [uploadToDB, setUploadToDB] = uploadToDBState;

  if (!has_scanner) {
    return (
      <NoticeBox>
        {t('ui.library.no_nearby_scanner')}
      </NoticeBox>
    );
  }

  if (!has_cache) {
    return <NoticeBox>{t('ui.library.scan_book_to_upload')}</NoticeBox>;
  }

  const contentHtml = {
    __html: sanitizeText(cache_content),
  };

  return (
    <>
      <Stack vertical height="100%">
        <Stack.Item>
          <Box fontSize="20px" textAlign="center" pt="6px">
            {t('ui.library.current_scan_cache')}
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical height="100%">
            <Stack.Item>
              <Stack justify="center">
                <Stack.Item>
                  <Box pt={1} fontSize={'20px'}>
                    {t('ui.common.title')}:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    fontSize="20px"
                    value={cache_title}
                    placeholder={cache_title || t('ui.common.title')}
                    mt={0.5}
                    width={22}
                    onBlur={(value) =>
                      act('set_cache_title', {
                        title: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box pt={1} fontSize="20px">
                    {t('ui.common.author')}:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    fontSize="20px"
                    value={cache_author}
                    placeholder={cache_author || t('ui.common.author')}
                    mt={0.5}
                    onBlur={(value) =>
                      act('set_cache_author', {
                        author: value,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section
                fill
                scrollable
                preserveWhitespace
                fontSize="15px"
                title={`${t('ui.common.content')}:`}
              >
                <Box dangerouslySetInnerHTML={contentHtml} />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                disabled={!active_newscaster_cooldown}
                fluid
                tooltip={
                  active_newscaster_cooldown
                    ? t('ui.library.send_book_to_newscaster')
                    : `${t('ui.library.please_wait')} ${cooldown_string} ${t('ui.library.before_sending_newscaster')}`
                }
                tooltipPosition="top"
                icon="newspaper"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => act('news_post')}
              >
                {t('ui.library.newscaster')}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                disabled={!can_db_request}
                fluid
                icon="server"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => setUploadToDB(true)}
              >
                {t('ui.library.archive')}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      {!!uploadToDB && <UploadModal />}
    </>
  );
}

function UploadModal(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const { upload_categories, default_category, can_db_request } = data;

  const { uploadToDBState } = useLibraryContext();
  const [uploadToDB, setUploadToDB] = uploadToDBState;

  const [uploadCategory, setUploadCategory] = useState('');

  const display_category = uploadCategory || default_category;

  return (
    <Modal width="650px">
      <Box fontSize="20px" pb={2}>
        {t('ui.library.confirm_upload_to_database')}
      </Box>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.category')}>
          <Dropdown
            options={upload_categories}
            selected={display_category}
            onSelected={(value) => setUploadCategory(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Stack justify="center" align="center" pt={2}>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            icon="upload"
            fontSize="18px"
            color="good"
            onClick={() => {
              setUploadToDB(false);
              act('upload', {
                category: display_category,
              });
            }}
            lineHeight={2}
          >
            {t('ui.library.upload_to_db')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            fontSize="18px"
            color="bad"
            onClick={() => setUploadToDB(false)}
            lineHeight={2}
          >
            {t('ui.common.return')}
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
