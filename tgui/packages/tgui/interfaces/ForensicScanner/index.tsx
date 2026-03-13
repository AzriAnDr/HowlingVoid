import { Button, NoticeBox, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { ForensicLogs } from './ForensicLogs';
import type { ForensicScannerData } from './types';

export function ForensicScanner() {
  const { act, data } = useBackend<ForensicScannerData>();
  const { t } = usePreferencesLocalization();
  const { logs = [] } = data;
  return (
    <Window width={512} height={512}>
      <Window.Content>
        {logs.length === 0 ? (
          <NoticeBox>{t('ui.forensic_scanner.log_empty')}</NoticeBox>
        ) : (
          <Section
            title={t('ui.forensic_scanner.scan_history')}
            fill
            scrollable
            buttons={
              <>
                <Button.Confirm
                  icon="trash"
                  color="danger"
                  onClick={() => act('clear')}
                >
                  {t('ui.forensic_scanner.clear_logs')}
                </Button.Confirm>
                <Button icon="print" onClick={() => act('print')}>
                  {t('ui.forensic_scanner.print_report')}
                </Button>
              </>
            }
          >
            {logs
              .map((log, index) => (
                <ForensicLogs
                  key={index}
                  dataEntries={log.dataEntries}
                  scanTarget={log.scanTarget}
                  scanTime={log.scanTime}
                  index={index}
                />
              ))
              .reverse()}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}
