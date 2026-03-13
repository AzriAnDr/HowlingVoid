import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { ObjectiveElement } from './ObjectiveElement';

type PrimaryObjectiveMenuProps = {
  primary_objectives;
  can_renegotiate;
};

export const PrimaryObjectiveMenu = (props: PrimaryObjectiveMenuProps) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const { primary_objectives, can_renegotiate } = props;
  return (
    <Section fill scrollable align="center">
      <Box my={4} bold fontSize={1.2} color="green">
        {t('ui.uplink.welcome_agent')}
      </Box>
      <Box my={4} bold fontSize={1.2}>
        {t('ui.uplink.primary_objectives_notice')}
      </Box>
      <Stack vertical>
        {primary_objectives.map((prim_obj, index) => (
          <Stack.Item key={index}>
            <ObjectiveElement
              key={prim_obj.id}
              name={prim_obj.task_name}
              description={prim_obj.task_text}
            />
          </Stack.Item>
        ))}
      </Stack>
      {!!can_renegotiate && (
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          <Button
            content={t('ui.uplink.renegotiate_contract')}
            tooltip={
              t('ui.uplink.renegotiate_contract_tooltip')
            }
            onClick={() => act('renegotiate_objectives')}
          />
        </Box>
      )}
      <Box my={4} fontSize={0.8}>
        <Box>{t('ui.uplink.syndos_version_317')}</Box>
        <Box color="green">{t('ui.uplink.connection_secure')}</Box>
      </Box>
    </Section>
  );
};
