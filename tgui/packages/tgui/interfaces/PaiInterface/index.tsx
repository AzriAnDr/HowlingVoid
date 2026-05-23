import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Stack, Tabs } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { AvailableDisplay } from './Available';
import { PAI_TAB } from './constants';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';

export function PaiInterface(props) {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [tab, setTab] = useState(PAI_TAB.System);

  return (
    <Window title={t('ui.pai_interface.title')} width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {tab === PAI_TAB.System && <SystemDisplay />}
            {tab === PAI_TAB.Directive && <DirectiveDisplay />}
            {tab === PAI_TAB.Installed && <InstalledDisplay />}
            {tab === PAI_TAB.Available && <AvailableDisplay />}
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.System)}
                selected={tab === PAI_TAB.System}
              >
                {t('ui.pai_interface.system')}
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Directive)}
                selected={tab === PAI_TAB.Directive}
              >
                {t('ui.pai_interface.directives')}
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Installed)}
                selected={tab === PAI_TAB.Installed}
              >
                {t('ui.pai_interface.installed')}
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Available)}
                selected={tab === PAI_TAB.Available}
              >
                {t('ui.pai_interface.download')}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
