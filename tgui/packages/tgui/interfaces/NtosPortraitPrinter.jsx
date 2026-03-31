import { useState } from 'react';
import {
  Button,
  Image,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosPortraitPrinter = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [listIndex, setListIndex] = useState(0);
  const { paintings, search_string, search_mode, is_console } = data;
  const got_paintings = !!paintings.length;
  const current_portrait_title = got_paintings && paintings[listIndex].title;
  const current_portrait_author =
    got_paintings && `${t('ui.portrait_picker.by')} ${paintings[listIndex].creator}`;
  const current_portrait_asset_name =
    got_paintings && `paintings_${paintings[listIndex].md5}`;
  const current_portrait_ratio = got_paintings && paintings[listIndex].ratio;

  return (
    <NtosWindow
      title={t('ui.ntos_portrait_printer.art_galaxy')}
      width={400}
      height={460}
    >
      <NtosWindow.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title={t('ui.common.search')}>
              <Stack>
                <Stack.Item grow>
                  <Input
                    fluid
                    placeholder={t('ui.portrait_picker.search_paintings_placeholder')}
                    value={search_string}
                    onBlur={(value) => {
                      act('search', {
                        to_search: value,
                      });
                      setListIndex(0);
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content={search_mode}
                    onClick={() => {
                      act('change_search_mode');
                      if (search_string) {
                        setListIndex(0);
                      }
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Section fill>
              <Stack
                height="100%"
                align="center"
                justify="center"
                direction="column"
              >
                {got_paintings ? (
                  <>
                    <Stack.Item>
                      <Image
                        src={resolveAsset(current_portrait_asset_name)}
                        height="128px"
                        width={`${Math.round(128 * current_portrait_ratio)}px`}
                        style={{
                          verticalAlign: 'middle',
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item className="Section__titleText">
                      {current_portrait_title}
                    </Stack.Item>
                    <Stack.Item>{current_portrait_author}</Stack.Item>
                  </>
                ) : (
                  <Stack.Item className="Section__titleText">
                    {t('ui.portrait_picker.no_paintings_found')}
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow={3}>
                <Section height="100%">
                  <Stack justify="space-between" align="center">
                    <Stack.Item>
                      <Button
                        icon="angle-double-left"
                        disabled={listIndex === 0}
                        onClick={() => setListIndex(0)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={listIndex === 0}
                        icon="chevron-left"
                        onClick={() => setListIndex(listIndex - 1)}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Stack vertical align="center">
                        {!!is_console && (
                          <Stack.Item>
                            <Button
                              icon="print"
                              content={t('ui.ntos_portrait_printer.print_portrait')}
                              disabled={!got_paintings}
                              onClick={() =>
                                act('print', {
                                  selected: paintings[listIndex].ref,
                                })
                              }
                            />
                          </Stack.Item>
                        )}
                        <Stack.Item>
                          <Button
                            icon="download"
                            content={t('ui.common.download')}
                            disabled={!got_paintings}
                            onClick={() =>
                              act('download', {
                                selected: paintings[listIndex].ref,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(listIndex + 1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(paintings.length - 1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1} mb={-1}>
              <NoticeBox info>
                {t('ui.ntos_portrait_printer.printing_canvas_cost')}
              </NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
