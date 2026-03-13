import { useState } from 'react';

import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { BookListing } from './BookListing';
import { ModifyState } from './hooks';
import { ModifyPage } from './Modify';

export function LibraryAdmin(props) {
  const modifyMethodState = useState('');
  const modifyTargetState = useState(0);
  const { t } = usePreferencesLocalization({});

  return (
    <Window
      title={t('ui.library_admin.title')}
      theme="admin"
      width={800}
      height={600}
    >
      <ModifyState.Provider value={{ modifyMethodState, modifyTargetState }}>
        {modifyMethodState[0] ? <ModifyPage /> : <BookListing />}
      </ModifyState.Provider>
    </Window>
  );
}
