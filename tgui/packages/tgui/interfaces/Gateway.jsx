import {
  Box,
  Button,
  ByondUi,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Gateway = () => {
  return (
    <Window width={350} height={440}>
      <Window.Content scrollable>
        <GatewayContent />
      </Window.Content>
    </Window>
  );
};

const GatewayContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    gateway_present = false,
    gateway_status = false,
    current_target = null,
    destinations = [],
    gateway_mapkey,
  } = data;
  if (!gateway_present) {
    return (
      <Section>
        <NoticeBox>{t('ui.gateway.no_linked_gateway')}</NoticeBox>
        <Button fluid onClick={() => act('linkup')}>
          {t('ui.gateway.linkup')}
        </Button>
      </Section>
    );
  }
  if (current_target) {
    return (
      <Section title={current_target.name}>
        <ByondUi
          height="320px"
          params={{
            id: gateway_mapkey,
            type: 'map',
          }}
        />
        <Button
          mt="2px"
          textAlign="center"
          fluid
          onClick={() => act('deactivate')}
        >
          {t('ui.common.deactivate')}
        </Button>
      </Section>
    );
  }
  if (!destinations.length) {
    return <Section>{t('ui.gateway.no_gateway_nodes_detected')}</Section>;
  }
  return (
    <>
      {!gateway_status && <NoticeBox>{t('ui.gateway.gateway_unpowered')}</NoticeBox>}
      {destinations.map((dest) => (
        <Section key={dest.ref} title={dest.name}>
          {(dest.available && (
            <Button
              fluid
              onClick={() =>
                act('activate', {
                  destination: dest.ref,
                })
              }
            >
              {t('ui.common.activate')}
            </Button>
          )) || (
            <>
              <Box m={1} textColor="bad">
                {dest.reason}
              </Box>
              {!!dest.timeout && (
                <ProgressBar value={dest.timeout}>
                  {t('ui.gateway.calibrating')}
                </ProgressBar>
              )}
            </>
          )}
        </Section>
      ))}
    </>
  );
};
