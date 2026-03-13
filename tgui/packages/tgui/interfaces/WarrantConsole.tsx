import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  BlockQuote,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  records: WarrantRecord[];
};

type WarrantRecord = {
  citations: Citation[];
  crew_name: string;
  crew_ref: string;
  rank: string;
};

type Citation = {
  details: string;
  fine_name: string;
  fine_ref: string;
  fine: number;
  paid: number;
  time: number;
};

export const WarrantConsole = (props) => {
  const [selectedRecord] = useLocalState<WarrantRecord | undefined>(
    'warrantRecord',
    undefined,
  );

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2}>
            <RecordList />
          </Stack.Item>
          {selectedRecord && (
            <Stack.Item grow={3}>
              <ViewRecord />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays all valid records with warrants. */
const RecordList = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { records = [] } = data;
  const sorted = sortBy(records, [(record) => record.crew_name]);

  const [selectedRecord, setSelectedRecord] = useLocalState<
    WarrantRecord | undefined
  >('warrantRecord', undefined);

  const selectHandler = (record: WarrantRecord) => {
    if (selectedRecord?.crew_ref === record.crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
    }
  };

  return (
    <Section
      buttons={
        <Button
          icon="sync"
          onClick={() => act('refresh')}
          tooltip={t('ui.common.refresh')}
          tooltipPosition="bottom-start"
        />
      }
      fill
      scrollable
      title={t('ui.warrant_console.citations')}
    >
      <Stack fill vertical>
        {!records?.length ? (
          <NoticeBox>{t('ui.warrant_console.no_citations_issued')}</NoticeBox>
        ) : (
          <Tabs vertical>
            {sorted.map((record, index) => (
              <Tabs.Tab
                className="candystripe"
                key={index}
                onClick={() => selectHandler(record)}
                selected={selectedRecord?.crew_ref === record.crew_ref}
              >
                {record.crew_name}: {record.citations.length}
              </Tabs.Tab>
            ))}
          </Tabs>
        )}
      </Stack>
    </Section>
  );
};

/** Views info on the current selection. */
const ViewRecord = (props) => {
  const foundRecord = getCurrentRecord();
  if (!foundRecord) return;

  const { citations = [], crew_name } = foundRecord;

  return (
    <Section fill scrollable title={crew_name}>
      <Stack fill vertical>
        {citations.map((citation, index) => (
          <Stack.Item key={index}>
            <CitationManager citation={citation} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

/** Handles paying fines */
const CitationManager = (props) => {
  const foundRecord = getCurrentRecord();
  if (!foundRecord) return;

  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    citation: { author, details, fine, fine_ref, fine_name, paid, time },
  } = props;

  const { crew_ref } = foundRecord;

  const [paying, setPaying] = useState(5);
  const [payingIsValid, setPayingIsValid] = useState(true);

  return (
    <Collapsible
      buttons={
        <Button
          disabled={fine <= 0}
          icon="print"
          onClick={() =>
            act('print', { crew_ref: crew_ref, fine_ref: fine_ref })
          }
        >
          {t('ui.common.print')}
        </Button>
      }
      color={getFineColor(fine)}
      title={fine_name}
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.common.details')}>
          <BlockQuote>{details}</BlockQuote>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.author')}>{author}</LabeledList.Item>
        <LabeledList.Item label={t('ui.common.time')}>{time}</LabeledList.Item>
        <LabeledList.Item label={t('ui.warrant_console.fine')}>{fine}</LabeledList.Item>
        <LabeledList.Item label={t('ui.warrant_console.paid')}>{paid}</LabeledList.Item>
        {fine > 0 && (
          <LabeledList.Item label={t('ui.common.pay')}>
            <RestrictedInput
              maxValue={fine}
              minValue={5}
              onChange={setPaying}
              value={paying}
              onValidationChange={setPayingIsValid}
            />
            <Button.Confirm
              disabled={!payingIsValid}
              onClick={() =>
                act('pay', {
                  amount: paying,
                  crew_ref: crew_ref,
                  fine_ref: fine_ref,
                })
              }
            >
              {t('ui.common.pay')}
            </Button.Confirm>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Collapsible>
  );
};

/** We need an active reference and this a pain to rewrite */
export const getCurrentRecord = () => {
  const [selectedRecord] = useLocalState<WarrantRecord | undefined>(
    'warrantRecord',
    undefined,
  );
  if (!selectedRecord) return;
  const { data } = useBackend<Data>();
  const { records = [] } = data;
  const foundRecord = records.find(
    (record) => record.crew_ref === selectedRecord.crew_ref,
  );
  if (!foundRecord) return;

  return foundRecord;
};

/** Returns a color based on the fine amount */
export const getFineColor = (fine: number) => {
  switch (true) {
    case fine > 700:
      return 'bad';
    case fine > 300:
      return 'average';
    case fine === 0:
      return 'grey';
    default:
      return '';
  }
};
