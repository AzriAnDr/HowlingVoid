import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { StatusDisplayControls } from '../common/StatusDisplayControls';
import { ShuttleState } from './types';

export function PageChangingStatus(props) {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          onClick={() => act('setState', { state: ShuttleState.MAIN })}
        >
          {t('ui.common.back')}
        </Button>
      </Section>

      <StatusDisplayControls />
    </Box>
  );
}
