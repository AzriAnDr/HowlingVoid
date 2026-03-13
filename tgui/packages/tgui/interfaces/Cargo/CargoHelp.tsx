import { Box, NoticeBox, Section, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';

export function CargoHelp(props) {
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable>
          <Section color="label" title={t('ui.cargo.department_orders')}>
            {t('ui.cargo.help_order_text')}
            <br />
            <br />
            {t('ui.cargo.help_examine_crate')}
          </Section>
          <Section title={t('ui.cargo.mulebots')}>
            <Box color="label">
              {t('ui.cargo.help_mulebot_description')}
            </Box>
            <br />
            <Box bold color="green">
              {t('ui.cargo.help_mulebot_setup_intro')}
            </Box>
            <b>1.</b> {t('ui.cargo.help_mulebot_step_1')}
            <br />
            <b>2.</b> {t('ui.cargo.help_mulebot_step_2')}
            <br />
            <b>3.</b> {t('ui.cargo.help_mulebot_step_3')}
            <br />
            <b>4.</b> {t('ui.cargo.help_mulebot_step_4')}<br />
            <b>5.</b> {t('ui.cargo.help_mulebot_step_5')}<br />
            <b>6.</b> {t('ui.cargo.help_mulebot_step_6')}
            <br />
            <b>7.</b> {t('ui.cargo.help_mulebot_step_7')}<br />
            <b>8.</b> {t('ui.cargo.help_mulebot_step_8')}
            <br />
            <b>9.</b> {t('ui.cargo.help_mulebot_step_9')}
          </Section>
          <Section title={t('ui.cargo.disposals_delivery_system')}>
            <Box color="label">{t('ui.cargo.help_disposal_text')}</Box>
            <br />
            <Box bold color="green">
              {t('ui.cargo.help_disposal_intro')}
            </Box>
            <b>1.</b> {t('ui.cargo.help_disposal_step_1')}
            <br />
            <b>2.</b> {t('ui.cargo.help_disposal_step_2')}
            <br />
            <b>3.</b> {t('ui.cargo.help_disposal_step_3')}
            <br />
            <b>4.</b> {t('ui.cargo.help_disposal_step_4')}
            <br />
          </Section>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox textAlign="center" info mb={0}>
          {t('ui.cargo.help_footer')}
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
}
