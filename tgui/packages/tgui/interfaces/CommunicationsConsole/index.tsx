import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { PageBuyingShuttle } from './BuyingShuttle';
import { PageChangingStatus } from './ChangingStatus';
import { PageMain } from './Main';
import { PageMessages } from './Messages';
import { NoConnectionModal } from './NoConnectionModal';
import { type CommsConsoleData, ShuttleState } from './types';

export function CommunicationsConsole(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const {
    authenticated,
    authorizeName,
    canLogOut,
    canRequestSafeCode,
    emagged,
    hasConnection,
    page,
    safeCodeDeliveryArea,
    safeCodeDeliveryWait,
  } = data;

  let currentPage;
  switch (page) {
    case ShuttleState.BUYING_SHUTTLE:
      currentPage = <PageBuyingShuttle />;
      break;
    case ShuttleState.CHANGING_STATUS:
      currentPage = <PageChangingStatus />;
      break;
    case ShuttleState.MAIN:
      currentPage = <PageMain />;
      break;
    case ShuttleState.MESSAGES:
      currentPage = <PageMessages />;
      break;
    default:
      currentPage = (
        <Box>
          {t('ui.communications_console.page_not_implemented').replace(
            '{page}',
            String(page),
          )}
        </Box>
      );
      break;
  }

  return (
    //<Window width={400} height={650} theme={emagged ? 'syndicate' : undefined}> // NOVA EDIT REMOVAL
    <Window width={450} height={750} theme={emagged ? 'syndicate' : undefined}> { /* NOVA EDIT ADDITION */ }
      <Window.Content scrollable>
        {!hasConnection && <NoConnectionModal />}

        {(canLogOut || !authenticated) && (
          <Section title={t('ui.communications_console.authentication')}>
            <Button
              icon={authenticated ? 'sign-out-alt' : 'sign-in-alt'}
              color={authenticated ? 'bad' : 'good'}
              onClick={() => act('toggleAuthentication')}
            >
              {authenticated
                ? `${t('ui.common.log_out')}${
                    authorizeName ? ` (${authorizeName})` : ''
                  }`
                : t('ui.communications_console.log_in')}
            </Button>
          </Section>
        )}

        {canRequestSafeCode ? (
          <Section title={t('ui.communications_console.emergency_safe_code')}>
            <Button
              icon="key"
              color="good"
              onClick={() => act('requestSafeCodes')}
            >
              {t('ui.communications_console.request_safe_code')}
            </Button>
          </Section>
        ) : (
          !!safeCodeDeliveryWait && (
            <Section
              title={t('ui.communications_console.emergency_safe_code_delivery')}
              color="label"
            >
              {t('ui.communications_console.drop_pod_delivery')
                .replace('{area}', safeCodeDeliveryArea)
                .replace('{seconds}', String(Math.round(safeCodeDeliveryWait / 10)))}
            </Section>
          )
        )}

        {!!authenticated && currentPage}
      </Window.Content>
    </Window>
  );
}
