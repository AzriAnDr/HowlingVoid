/**
 * @file
 * @copyright 2022 raffclar
 * @license MIT
 */

import { useRef, useState } from 'react';
import { Box, Dialog, Divider, MenuBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import type { NTOSData } from '../layouts/NtosWindow';
import { createLogger } from '../logging';
import { usePreferencesLocalization } from './localization';

const logger = createLogger('NtosNotepad');

type PartiallyUnderlinedProps = {
  str: string;
  indexStart: number;
};

const PartiallyUnderlined = (props: PartiallyUnderlinedProps) => {
  const { str, indexStart } = props;
  const start = str.substring(0, indexStart);
  const underlined = str.substring(indexStart, indexStart + 1);
  const end = indexStart < str.length - 1 ? str.substring(indexStart + 1) : '';
  return (
    <>
      {start}
      <span style={{ textDecoration: 'underline' }}>{underlined}</span>
      {end}
    </>
  );
};

enum Dialogs {
  NONE = 0,
  UNSAVED_CHANGES = 1,
  OPEN = 2,
  ABOUT = 3,
}

type MenuBarProps = {
  onSave: () => void;
  onExit: () => void;
  onNewNote: () => void;
  onCutSelected: () => void;
  onCopySelected: () => void;
  onPasteSelected: () => void;
  onDeleteSelected: () => void;
  showStatusBar: boolean;
  setShowStatusBar: (boolean) => void;
  wordWrap: boolean;
  setWordWrap: (boolean) => void;
  aboutNotepadDialog: () => void;
};

const NtosNotepadMenuBar = (props: MenuBarProps) => {
  const { t } = usePreferencesLocalization();
  const {
    onSave,
    onExit,
    onNewNote,
    onCutSelected,
    onCopySelected,
    onPasteSelected,
    onDeleteSelected,
    setShowStatusBar,
    showStatusBar,
    wordWrap,
    setWordWrap,
    aboutNotepadDialog,
  } = props;
  const [openOnHover, setOpenOnHover] = useState(false);
  const [openMenuBar, setOpenMenuBar] = useState<string | null>(null);
  const onMenuItemClick = (value) => {
    setOpenOnHover(false);
    setOpenMenuBar(null);
    switch (value) {
      case 'save':
        onSave();
        break;
      case 'exit':
        onExit();
        break;
      case 'new':
        onNewNote();
        break;
      case 'cut':
        onCutSelected();
        break;
      case 'copy':
        onCopySelected();
        break;
      case 'paste':
        onPasteSelected();
        break;
      case 'delete':
        onDeleteSelected();
        break;
      case 'statusBar':
        setShowStatusBar(!showStatusBar);
        break;
      case 'wordWrap':
        setWordWrap(!wordWrap);
        break;
      case 'aboutNotepad':
        aboutNotepadDialog();
        break;
    }
  };
  // Adds the key using the value
  const getMenuItemProps = (value: string, displayText: string) => {
    return {
      key: value,
      value,
      displayText,
      onClick: onMenuItemClick,
    };
  };
  const itemProps = {
    openOnHover,
    setOpenOnHover,
    openMenuBar,
    setOpenMenuBar,
  };

  return (
    <MenuBar>
      <MenuBar.Dropdown
        entry="file"
        openWidth="22rem"
        display={<PartiallyUnderlined str={t('ui.ntos_notepad.file')} indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('new', t('ui.common.new'))} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('save', t('ui.common.save'))} />
        <MenuBar.Dropdown.Separator key="firstSep" />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('exit', t('ui.common.exit_ellipsis'))} />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="edit"
        openWidth="22rem"
        display={<PartiallyUnderlined str={t('ui.common.edit')} indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('cut', t('ui.common.cut'))} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('copy', t('ui.common.copy'))} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('paste', t('ui.common.paste'))} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('delete', t('ui.common.delete'))} />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="format"
        openWidth="15rem"
        display={<PartiallyUnderlined str={t('ui.common.format')} indexStart={1} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItemToggle
          checked={wordWrap}
          {...getMenuItemProps('wordWrap', t('ui.ntos_notepad.word_wrap'))}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="view"
        openWidth="15rem"
        display={<PartiallyUnderlined str={t('ui.ntos_notepad.view')} indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItemToggle
          checked={showStatusBar}
          {...getMenuItemProps('statusBar', t('ui.ntos_notepad.status_bar'))}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="help"
        openWidth="17rem"
        display={<PartiallyUnderlined str={t('ui.common.help')} indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('aboutNotepad', t('ui.ntos_notepad.about_notepad'))}
        />
      </MenuBar.Dropdown>
    </MenuBar>
  );
};

interface StatusBarProps {
  statuses: Statuses;
}

const StatusBar = (props: StatusBarProps) => {
  const { t } = usePreferencesLocalization();
  const { statuses } = props;
  return (
    <Box className="NtosNotepad__StatusBar">
      <Box className="NtosNotepad__StatusBar__entry" minWidth="25rem">
        {t('ui.ntos_notepad.press_shift_enter')}
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="15rem">
        {t('ui.ntos_notepad.line_short')} {statuses.line},{' '}
        {t('ui.ntos_notepad.column_short')} {statuses.column}
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="5rem">
        100%
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">
        NtOS (LF)
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">
        UTF-8
      </Box>
    </Box>
  );
};

type Statuses = {
  line: number;
  column: number;
};

const getStatusCounts = (text: string, selectionStart: number): Statuses => {
  const lines = text.substr(0, selectionStart).split('\n');
  return {
    line: lines.length,
    column: lines[lines.length - 1].length + 1,
  };
};

const TEXTAREA_UPDATE_TRIGGERS = [
  'click',
  'input',
  'paste',
  'cut',
  'mousemove',
  'select',
  'selectstart',
  'keydown',
];

interface NotePadTextAreaProps {
  text: string;
  wordWrap: boolean;
  setText: (text: string) => void;
  setStatuses: (statuses: Statuses) => void;
}

function NotePadTextArea(props: NotePadTextAreaProps) {
  const { text, setText, wordWrap, setStatuses } = props;

  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  function handleEvent(event) {
    const area = event.target as HTMLTextAreaElement;
    setStatuses(getStatusCounts(area.value, area.selectionStart));
  }

  return (
    <textarea
      autoFocus
      className="NtosNotepad__textarea"
      onClick={handleEvent}
      onMouseUp={handleEvent}
      onChange={(event) => {
        setText(event.currentTarget.value);
        handleEvent(event);
      }}
      ref={textareaRef}
      spellCheck={false}
      style={{
        whiteSpace: wordWrap ? 'normal' : 'nowrap',
        overflow: wordWrap ? 'hidden auto' : 'scroll hidden',
      }}
      value={text}
    />
  );
}

type AboutDialogProps = {
  close: () => void;
};

const AboutDialog = (props: AboutDialogProps) => {
  const { t } = usePreferencesLocalization();
  const { close } = props;
  const { data } = useBackend<NTOSData>();
  const { show_imprint, login } = data;
  const paragraphStyle = { padding: '.5rem 1rem 0 2rem' };

  return (
    <Dialog title={t('ui.ntos_notepad.about_notepad')} onClose={close} width={'500px'}>
      <div className="Dialog__body">
        <span className="NtosNotepad__AboutDialog__logo">{t('ui.ntos_notepad.ntos')}</span>
        <Divider />
        <Box className="NtosNotepad__AboutDialog__text">
          <span style={paragraphStyle}>{t('ui.ntos_notepad.nanotrasen_ntos')}</span>
          <span style={paragraphStyle}>
            {t('ui.common.version')} 7815696ecbf1c96e6894b779456d330e
          </span>
          <span style={paragraphStyle}>
            {t('ui.ntos_notepad.copyright_text')}
          </span>
          <span style={{ padding: '3rem 1rem 3rem 2rem' }}>
            {t('ui.ntos_notepad.legal_notice')}
          </span>
          <span
            style={{
              padding: '3rem 1rem 0.5rem 2rem',
              maxWidth: '35rem',
            }}
          >
            {t('ui.ntos_notepad.licensed_to')}
          </span>
          <span style={{ padding: '0 1rem 0 4rem' }}>
            {show_imprint ? login.IDName : t('ui.common.unknown')}
          </span>
        </Box>
      </div>
      <div className="Dialog__footer">
        <Dialog.Button onClick={close}>{t('ui.common.ok')}</Dialog.Button>
      </div>
    </Dialog>
  );
};

type NoteData = {
  note: string;
};
type RetryActionType = (retrying?: boolean) => void;

export const NtosNotepad = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<NoteData>();
  const { note } = data;
  const defaultDocumentName = t('ui.ntos_notepad.untitled');
  const [documentName, setDocumentName] = useState(defaultDocumentName);
  const [originalText, setOriginalText] = useState(note);
  const [text, setText] = useState(note);
  const [statuses, setStatuses] = useState<Statuses>({
    line: 0,
    column: 0,
  });
  const [activeDialog, setActiveDialog] = useState(Dialogs.NONE);
  const [retryAction, setRetryAction] = useState<RetryActionType | null>(null);
  const [showStatusBar, setShowStatusBar] = useState(true);
  const [wordWrap, setWordWrap] = useState(true);

  const handleCloseDialog = () => setActiveDialog(Dialogs.NONE);
  const handleSave = (newDocumentName: string = documentName) => {
    logger.log(`Saving the document as ${newDocumentName}`);
    act('UpdateNote', { newnote: text });
    setOriginalText(text);
    setDocumentName(newDocumentName);
    logger.log('Attempting to retry previous action');
    setActiveDialog(Dialogs.NONE);

    // Retry the previous action now that we've saved. The previous action could be to
    // close the application, a new document being created or
    // an existing document being opened
    if (retryAction) {
      retryAction(true);
    }
    setRetryAction(null);
  };
  const ensureUnsavedChangesAreHandled = (
    action: () => void,
    retrying = false,
  ): boolean => {
    // This is a guard function that throws up the "unsaved changes" dialog if the user is
    // attempting to do something that will make them lose data
    if (!retrying && originalText !== text) {
      logger.log('Unsaved changes. Asking client to save');
      setRetryAction(() => action);
      setActiveDialog(Dialogs.UNSAVED_CHANGES);
      return true;
    }

    return false;
  };
  const exit = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(exit, retrying)) {
      return;
    }
    logger.log('Exiting Notepad');
    act('PC_exit');
  };
  const newNote = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(newNote, retrying)) {
      return;
    }
    setOriginalText('');
    setText('');
    setDocumentName(defaultDocumentName);
  };

  // MS Notepad displays an asterisk when there's unsaved changes
  const unsavedAsterisk = text !== originalText ? '*' : '';
  return (
    <NtosWindow
      title={`${unsavedAsterisk}${documentName} - ${t('ui.ntos_notepad.notepad')}`}
      width={840}
      height={900}
    >
      <NtosWindow.Content>
        <Box className="NtosNotepad__layout">
          <NtosNotepadMenuBar
            onSave={handleSave}
            onExit={exit}
            onNewNote={newNote}
            onCutSelected={() => document.execCommand('cut')}
            onCopySelected={() => document.execCommand('copy')}
            onPasteSelected={() => document.execCommand('paste')}
            onDeleteSelected={() => document.execCommand('delete')}
            showStatusBar={showStatusBar}
            setShowStatusBar={setShowStatusBar}
            wordWrap={wordWrap}
            setWordWrap={setWordWrap}
            aboutNotepadDialog={() => setActiveDialog(Dialogs.ABOUT)}
          />
          <Section fill>
            <NotePadTextArea
              text={text}
              setText={setText}
              wordWrap={wordWrap}
              setStatuses={setStatuses}
            />
          </Section>
          {showStatusBar && <StatusBar statuses={statuses} />}
        </Box>
      </NtosWindow.Content>
      {activeDialog === Dialogs.UNSAVED_CHANGES && (
        <Dialog title={t('ui.ntos_notepad.notepad')} onClose={handleCloseDialog}>
          <div className="Dialog__body">
            {t('ui.ntos_notepad.save_changes_question')} {documentName}?
          </div>
          <div className="Dialog__footer">
            <Dialog.Button onClick={handleSave}>{t('ui.common.save')}</Dialog.Button>
            <Dialog.Button onClick={handleCloseDialog}>
              {t('ui.ntos_notepad.dont_save')}
            </Dialog.Button>
            <Dialog.Button onClick={handleCloseDialog}>{t('ui.common.cancel')}</Dialog.Button>
          </div>
        </Dialog>
      )}
      {activeDialog === Dialogs.ABOUT && (
        <AboutDialog close={handleCloseDialog} />
      )}
    </NtosWindow>
  );
};
