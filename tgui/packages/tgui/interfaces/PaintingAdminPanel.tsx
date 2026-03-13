import { useState } from 'react';
import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type PaintingAdminPanelData = {
  paintings: PaintingData[];
};

type PaintingData = {
  md5: string;
  title: string;
  creator_ckey: string;
  creator_name: string | null;
  creation_date: Date | null;
  creation_round_id: number | null;
  patron_ckey: string | null;
  patron_name: string | null;
  credit_value: number;
  width: number;
  height: number;
  ref: string;
  tags: string[] | null;
  medium: string | null;
};

export const PaintingAdminPanel = (props) => {
  const { act, data } = useBackend<PaintingAdminPanelData>();
  const { t } = usePreferencesLocalization(data);
  const [chosenPaintingRef, setChosenPaintingRef] = useState<
    string | undefined
  >();
  const { paintings } = data;
  const chosenPainting = paintings.find((p) => p.ref === chosenPaintingRef);

  return (
    <Window title={t('ui.painting_admin.panel_title')} width={800} height={600}>
      <Window.Content scrollable>
        {chosenPainting && (
          <Section
            title={t('ui.painting_admin.painting_information')}
            buttons={
              <Button onClick={() => setChosenPaintingRef(undefined)}>
                {t('ui.common.close')}
              </Button>
            }
          >
            <img
              src={resolveAsset(`paintings_${chosenPainting.md5}`)}
              height="96px"
              width="96px"
              style={{
                verticalAlign: 'middle',
              }}
            />
            <LabeledList>
              <LabeledList.Item label={t('ui.painting_admin.md5')} content={chosenPainting.md5} />
              <LabeledList.Item label={t('ui.common.title')}>
                <Box inline style={{ wordBreak: 'break-all' }}>
                  {decodeHtmlEntities(chosenPainting.title)}
                </Box>
                <Button
                  onClick={() => act('rename', { ref: chosenPainting.ref })}
                  icon="edit"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label={t('ui.painting_admin.creator_ckey')}
                content={chosenPainting.creator_ckey}
              />
              <LabeledList.Item label={t('ui.painting_admin.creator_name')}>
                <Box inline>{chosenPainting.creator_name}</Box>
                <Button
                  onClick={() =>
                    act('rename_author', { ref: chosenPainting.ref })
                  }
                  icon="edit"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label={t('ui.painting_admin.creation_date')}
                content={chosenPainting.creation_date}
              />
              <LabeledList.Item
                label={t('ui.painting_admin.creation_round_id')}
                content={chosenPainting.creation_round_id}
              />
              <LabeledList.Item
                label={t('ui.painting_admin.medium')}
                content={chosenPainting.medium}
              />
              <LabeledList.Item label={t('ui.painting_admin.tags')}>
                {chosenPainting.tags?.map((tag) => (
                  <Button
                    key={tag}
                    color="red"
                    icon="minus-circle"
                    iconPosition="right"
                    content={tag}
                    onClick={() =>
                      act('remove_tag', { tag, ref: chosenPainting.ref })
                    }
                  />
                ))}
                <Button
                  color="green"
                  icon="plus-circle"
                  onClick={() => act('add_tag', { ref: chosenPainting.ref })}
                />
              </LabeledList.Item>
              <LabeledList.Item
                label={t('ui.painting_admin.patron_ckey')}
                content={chosenPainting.patron_ckey}
              />
              <LabeledList.Item
                label={t('ui.painting_admin.patron_name')}
                content={chosenPainting.patron_name}
              />
              <LabeledList.Item
                label={t('ui.painting_admin.credit_value')}
                content={chosenPainting.credit_value}
              />
              <LabeledList.Item label={t('ui.common.width')} content={chosenPainting.width} />
              <LabeledList.Item
                label={t('ui.common.height')}
                content={chosenPainting.height}
              />
            </LabeledList>
            <Section title={t('ui.common.actions')}>
              <Button.Confirm
                onClick={() => {
                  setChosenPaintingRef(undefined);
                  act('delete', { ref: chosenPainting.ref });
                }}
                content={t('ui.common.delete')}
              />
              <Button
                onClick={() => act('dumpit', { ref: chosenPainting.ref })}
              >
                {t('ui.painting_admin.reset_patronage')}
              </Button>
            </Section>
          </Section>
        )}
        {!chosenPainting && (
          <Table>
            <Table.Row>
              <Table.Cell color="label">{t('ui.common.title')}</Table.Cell>
              <Table.Cell color="label">{t('ui.common.author')}</Table.Cell>
              <Table.Cell color="label">{t('ui.common.preview')}</Table.Cell>
              <Table.Cell color="label">{t('ui.common.actions')}</Table.Cell>
            </Table.Row>
            {paintings.map((painting) => (
              <Table.Row key={painting.ref} className="candystripe">
                <Table.Cell style={{ wordBreak: 'break-all' }}>
                  {decodeHtmlEntities(painting.title)}
                </Table.Cell>
                <Table.Cell>{painting.creator_ckey}</Table.Cell>
                <Table.Cell>
                  <img
                    src={resolveAsset(`paintings_${painting.md5}`)}
                    height="36px"
                    width="36px"
                    style={{
                      verticalAlign: 'middle',
                    }}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Button onClick={() => setChosenPaintingRef(painting.ref)}>
                    {t('ui.common.edit')}
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Window.Content>
    </Window>
  );
};
