import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { usePreferencesLocalization } from '../localization';
import { DIRECTIVE_COMPREHENSION, DIRECTIVE_ORDER } from './constants';
import type { PaiData } from './types';

/** Shows the hardcoded PAI info along with any supplied orders. */
export function DirectiveDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { t } = usePreferencesLocalization(data);
  const { directives = [], master_name } = data;
  const displayedLaw = directives?.length
    ? decodeHtmlEntities(directives[0])
    : t('ui.common.none');

  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <Section fill scrollable title={t('ui.pai_interface.logic_core')}>
          <Box color="label">
            {t(
              'ui.pai_interface.directive_comprehension',
              DIRECTIVE_COMPREHENSION,
            )}
            <br />
            <br />
            {t('ui.pai_interface.directive_order', DIRECTIVE_ORDER)}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={t('ui.pai_interface.directives')}>
          {!master_name ? (
            t('ui.common.none')
          ) : (
            <LabeledList>
              <LabeledList.Item label={t('ui.pai_interface.prime')}>
                {t('ui.pai_interface.serve_your_master')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.pai_interface.supplemental')}>
                <BlockQuote>{displayedLaw}</BlockQuote>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
