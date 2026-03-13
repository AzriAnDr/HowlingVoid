import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosFileManager = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { usbconnected, files = [], usbfiles = [] } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Section>
          <FileTable
            files={files}
            usbconnected={usbconnected}
            onUpload={(file) => act('PRG_copytousb', { name: file })}
            onDelete={(file) => act('PRG_deletefile', { name: file })}
            onRename={(file, newName) =>
              act('PRG_renamefile', {
                name: file,
                new_name: newName,
              })
            }
            onDuplicate={(file) => act('PRG_clone', { file: file })}
            onToggleSilence={(file) => act('PRG_togglesilence', { name: file })}
          />
        </Section>
        {usbconnected && (
          <Section title={t('ui.ntosfilemanager.data_disk')}>
            <FileTable
              usbmode
              files={usbfiles}
              usbconnected={usbconnected}
              onUpload={(file) => act('PRG_copyfromusb', { name: file })}
              onDelete={(file) => act('PRG_usbdeletefile', { name: file })}
              onRename={(file, newName) =>
                act('PRG_usbrenamefile', {
                  name: file,
                  new_name: newName,
                })
              }
              onDuplicate={(file) => act('PRG_clone', { file: file })}
            />
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const FileTable = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    files = [],
    usbconnected,
    usbmode,
    onUpload,
    onDelete,
    onRename,
    onToggleSilence,
  } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>{t('ui.ntosfilemanager.file')}</Table.Cell>
        <Table.Cell collapsing>{t('ui.ntosfilemanager.type')}</Table.Cell>
        <Table.Cell collapsing>{t('ui.ntosfilemanager.size')}</Table.Cell>
      </Table.Row>
      {files.map((file) => (
        <Table.Row key={file.name} className="candystripe">
          <Table.Cell>
            {!file.undeletable ? (
              <Button.Input
                fluid
                value={file.name}
                onCommit={(value) => onRename(file.name, value)}
              />
            ) : (
              file.name
            )}
          </Table.Cell>
          <Table.Cell>{file.type}</Table.Cell>
          <Table.Cell>{file.size}</Table.Cell>
          <Table.Cell collapsing>
            {!!file.alert_able && (
                <Button
                  icon={file.alert_silenced ? 'bell-slash' : 'bell'}
                  color={file.alert_silenced ? 'red' : 'default'}
                  tooltip={
                    file.alert_silenced
                      ? t('ui.ntosfilemanager.unmute_alerts')
                      : t('ui.ntosfilemanager.mute_alerts')
                  }
                  onClick={() => onToggleSilence(file.name)}
                />
              )}
            {!file.undeletable && (
              <>
                <Button.Confirm
                  icon="trash"
                  confirmIcon="times"
                  confirmContent=""
                  tooltip={t('ui.ntosfilemanager.delete')}
                  onClick={() => onDelete(file.name)}
                />
                {!!usbconnected &&
                  (usbmode ? (
                    <Button
                      icon="download"
                      tooltip={t('ui.ntosfilemanager.download')}
                      onClick={() => onUpload(file.name)}
                    />
                  ) : (
                    <Button
                      icon="upload"
                      tooltip={t('ui.ntosfilemanager.upload')}
                      onClick={() => onUpload(file.name)}
                    />
                  ))}
              </>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

