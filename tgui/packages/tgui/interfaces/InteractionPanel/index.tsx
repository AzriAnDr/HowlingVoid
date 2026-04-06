// THIS IS A NOVA SECTOR UI FILE
import { Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

import { usePreferencesLocalization } from '../localization';

import { MainContent } from './MainContent';

type Interaction = {
  self;
  erp_interaction: BooleanLike;
};

export function InteractionPanel() {
  const { data } = useBackend<Interaction>();
  const { t } = usePreferencesLocalization(data);
  const {
    self,
    erp_interaction,
  } = data;

  return (
    <Window
      width={640}
      height={720}
      title={`${t('ui.interaction_panel.title')} - ${self}`}
    >
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <MainContent />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
