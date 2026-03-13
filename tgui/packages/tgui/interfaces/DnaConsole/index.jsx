import {
  Box,
  Button,
  Dimmer,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import {
  CONSOLE_MODE_ENZYMES,
  CONSOLE_MODE_FEATURES,
  CONSOLE_MODE_SEQUENCER,
  CONSOLE_MODE_STORAGE,
  STORAGE_MODE_CONSOLE,
} from './constants';
import { DnaConsoleEnzymes } from './DnaConsoleEnzymes';
import { DnaConsoleSequencer } from './DnaConsoleSequencer';
import { DnaConsoleStorage } from './DnaConsoleStorage';
import { DnaScanner } from './DnaScanner';

export const DnaConsole = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { isPulsing, timeToPulse, subjectUNI, subjectUF } = data;
  const { consoleMode } = data.view;

  return (
    <Window title={t('ui.dna.console')} width={539} height={710}>
      {!!isPulsing && (
        <Dimmer fontSize="14px" textAlign="center">
          <Icon mr={1} name="spinner" spin />
          Pulse in progress...
          <Box mt={1} />
          {timeToPulse}s
        </Dimmer>
      )}
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <DnaScanner />
          </Stack.Item>
          <Stack.Item>
            <DnaConsoleCommands />
          </Stack.Item>
          <Stack.Item grow>
            {consoleMode === CONSOLE_MODE_STORAGE && <DnaConsoleStorage />}
            {consoleMode === CONSOLE_MODE_SEQUENCER && <DnaConsoleSequencer />}
            {consoleMode === CONSOLE_MODE_ENZYMES && (
              <DnaConsoleEnzymes
                subjectBlock={subjectUNI}
                type="ui"
                name={t('ui.dna.enzymes')}
              />
            )}
            {consoleMode === CONSOLE_MODE_FEATURES && (
              <DnaConsoleEnzymes
                subjectBlock={subjectUF}
                type="uf"
                name={t('ui.dna.features')}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DnaConsoleCommands = (props) => {
  const { data, act } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { hasDisk, isInjectorReady, injectorSeconds } = data;
  const { consoleMode } = data.view;

  return (
    <Section
      title={t('ui.dna.console')}
      buttons={
        !isInjectorReady && (
          <Box lineHeight="20px" color="label">
            Injector on cooldown ({injectorSeconds}s)
          </Box>
        )
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.common.mode')}>
          <Button
            content={t('ui.common.storage')}
            selected={consoleMode === CONSOLE_MODE_STORAGE}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_STORAGE,
              })
            }
          />
          <Button
            content={t('ui.dna.sequencer')}
            disabled={!data.isViableSubject}
            selected={consoleMode === CONSOLE_MODE_SEQUENCER}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_SEQUENCER,
              })
            }
          />
          <Button
            content={t('ui.dna.enzymes')}
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_ENZYMES,
              })
            }
          />
          <Button
            content={t('ui.dna.features')}
            selected={consoleMode === CONSOLE_MODE_FEATURES}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_FEATURES,
              })
            }
          />
        </LabeledList.Item>
        {!!hasDisk && (
          <LabeledList.Item label={t('ui.common.disk')}>
            <Button
              icon="eject"
              content={t('ui.common.eject')}
              onClick={() => {
                act('eject_disk');
                act('set_view', {
                  storageMode: STORAGE_MODE_CONSOLE,
                });
              }}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
