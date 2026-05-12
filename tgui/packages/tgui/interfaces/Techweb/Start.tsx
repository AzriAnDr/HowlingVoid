import { useState } from 'react';
import { Button, Modal } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { TechwebContent } from './Content';
import { TechWebRoute } from './hooks';
import type { TechWebData } from './types';

export function TechwebStart(props) {
  const { act, data } = useBackend<TechWebData>();
  const { t } = usePreferencesLocalization(data, 'rnd');
  const { locked, stored_research } = data;
  const techwebState = useState({
    route: '',
  });

  if (locked) {
    return (
      <Modal width="15em" align="center" className="Techweb__LockedModal">
        <div>
          <b>{t('ui.techweb.console_locked')}</b>
        </div>
        <Button icon="unlock" onClick={() => act('toggleLock')}>
          {t('ui.common.unlock')}
        </Button>
      </Modal>
    );
  }

  if (!stored_research) {
    return (
      <Modal width="25em" align="center" className="Techweb__LockedModal">
        <div>
          <b>{t('ui.techweb.no_research_techweb_found')}</b>
        </div>
      </Modal>
    );
  }

  return (
    <TechWebRoute.Provider value={techwebState}>
      <TechwebContent />
    </TechWebRoute.Provider>
  );
}
