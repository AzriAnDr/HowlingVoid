import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import {
  getDefaultPrintDescription,
  getDefaultPrintHeader,
  getSecurityRecord,
} from './helpers';
import { PRINTOUT, type SecurityRecordsData } from './types';

/** Handles printing posters and rapsheets */
export const RecordPrint = (props) => {
  const { t } = usePreferencesLocalization();
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { crew_ref, crimes, name } = foundRecord;
  const innocent = !crimes?.length;
  const { act } = useBackend<SecurityRecordsData>();

  const [open, setOpen] = useLocalState('printOpen', true);
  const [alias, setAlias] = useState(name);

  const [printType, setPrintType] = useState(PRINTOUT.Missing);
  const [header, setHeader] = useState('');
  const [description, setDescription] = useState('');

  /** Prints the record and resets. */
  const printSheet = () => {
    act('print_record', {
      alias: alias,
      crew_ref: crew_ref,
      desc: description,
      head: header,
      type: printType,
    });
    reset();
  };

  /** Close everything and reset to blank. */
  const reset = () => {
    setAlias('');
    setHeader('');
    setDescription('');
    setPrintType(PRINTOUT.Missing);
    setOpen(false);
  };

  /** Clears the value and sets it to default. */
  const clearField = (field: string) => {
    switch (field) {
      case 'alias':
        setAlias(name);
        break;
      case 'header':
        setHeader(getDefaultPrintHeader(printType));
        break;
      case 'description':
        setDescription(getDefaultPrintDescription(name, printType));
        break;
    }
  };

  /** If they have the fields defaulted to a specific type, change the message */
  const swapTabs = (tab: PRINTOUT) => {
    if (description === getDefaultPrintDescription(name, printType)) {
      setDescription(getDefaultPrintDescription(name, tab));
    }
    if (header === getDefaultPrintHeader(printType)) {
      setHeader(getDefaultPrintHeader(tab));
    }
    setPrintType(tab);
  };

  return (
    <Section
      buttons={
        <>
          <Button
            icon="question"
            onClick={() => swapTabs(PRINTOUT.Missing)}
            selected={printType === PRINTOUT.Missing}
            tooltip={t('ui.security_records.print_missing_tooltip')}
            tooltipPosition="bottom"
          >
            {t('ui.security_records.missing')}
          </Button>
          <Button
            // NOVA EDIT REMOVE START - REMOVE INNOCENT CHECK, ALLOWS RAPSHEETS TO BE PRINTED WITHOUT ANY CRIMES HAVING BEEN LOGGED
            // disabled={innocent}
            // SKYRA EDIT REMOVE END
            icon="file-alt"
            onClick={() => swapTabs(PRINTOUT.Rapsheet)}
            selected={printType === PRINTOUT.Rapsheet}
            tooltip={t('ui.security_records.print_rapsheet_tooltip')} // NOVA EDIT CHANGE START - ORIGINAL:
            // tooltip={`Prints a standard paper with the record on it.${
            //  innocent ? ' (Requires crimes)' : ''
            // }`}
            // NOVA EDIT CHANGE END
            tooltipPosition="bottom"
          >
            {t('ui.security_records.rapsheet')}
          </Button>
          <Button
            disabled={innocent}
            icon="handcuffs"
            onClick={() => swapTabs(PRINTOUT.Wanted)}
            selected={printType === PRINTOUT.Wanted}
            tooltip={`${t('ui.security_records.print_wanted_tooltip')}${
              innocent ? ` ${t('ui.security_records.requires_crimes')}` : ''
            }`}
            tooltipPosition="bottom"
          >
            {t('ui.security_records.wanted')}
          </Button>
          <Button color="bad" icon="times" onClick={reset} />
        </>
      }
      fill
      scrollable
      title={t('ui.security_records.print_record')}
    >
      <Stack color="label" fill vertical>
        <Stack.Item>
          <Box>{t('ui.security_records.enter_header')}</Box>
          <Input onChange={setHeader} maxLength={7} value={header} />
          <Button
            icon="sync"
            onClick={() => clearField('header')}
            tooltip={t('ui.common.reset')}
          />
        </Stack.Item>
        <Stack.Item>
          <Box>{t('ui.security_records.enter_alias')}</Box>
          <Input onChange={setAlias} maxLength={42} value={alias} width="55%" />
          <Button
            icon="sync"
            onClick={() => clearField('alias')}
            tooltip={t('ui.common.reset')}
          />
        </Stack.Item>
        <Stack.Item>
          <Box>{t('ui.security_records.enter_description')}</Box>
          <Stack fill>
            <Stack.Item grow>
              <Input
                fluid
                maxLength={150}
                onChange={setDescription}
                value={description}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="sync"
                onClick={() => clearField('description')}
                tooltip={t('ui.common.reset')}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item mt={2}>
          <Box align="right">
            <Button color="bad" onClick={() => setOpen(false)}>
              {t('ui.common.cancel')}
            </Button>
            <Button color="good" onClick={printSheet}>
              {t('ui.common.print')}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
