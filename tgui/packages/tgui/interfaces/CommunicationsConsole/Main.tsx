import { useState } from 'react';
import { Box, Button, Flex, Modal, Section } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { AlertButton } from './AlertButton';
import { MessageModal } from './MessageModal';
import { type CommsConsoleData, ShuttleState } from './types';

export function PageMain(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { t } = usePreferencesLocalization(data);
  const {
    alertLevel,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRecallShuttles,
    canRequestNuke,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    canToggleEngineeringOverride, // NOVA EDIT ADDITION - Engineering Override
    emagged,
    syndicate,
    emergencyAccess,
    engineeringOverride, // NOVA EDIT ADDITION - Engineering Override
    importantActionReady,
    sectors,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const [callingShuttle, setCallingShuttle] = useState(false);
  const [messagingAssociates, setMessagingAssociates] = useState(false);
  const [messagingSector, setMessagingSector] = useState('');
  const [requestingNukeCodes, setRequestingNukeCodes] = useState(false);

  const [newAlertLevel, setNewAlertLevel] = useState('');
  const showAlertLevelConfirm = newAlertLevel && newAlertLevel !== alertLevel;

  return (
    <Box>
      {!syndicate && (
        <Section title={t('ui.communications_console.emergency_shuttle')}>
          {shuttleCalled ? (
            <Button.Confirm
              icon="space-shuttle"
              color="bad"
              disabled={!canRecallShuttles || !shuttleRecallable}
              tooltip={
                (canRecallShuttles &&
                  !shuttleRecallable &&
                  t(
                    'ui.communications_console.too_late_to_recall_emergency_shuttle',
                  )) ||
                t(
                  'ui.communications_console.no_permission_recall_emergency_shuttle',
                )
              }
              tooltipPosition="top"
              onClick={() => act('recallShuttle')}
            >
              {t('ui.communications_console.recall_emergency_shuttle')}
            </Button.Confirm>
          ) : (
            <Button
              icon="space-shuttle"
              disabled={shuttleCanEvacOrFailReason !== 1}
              tooltip={
                shuttleCanEvacOrFailReason !== 1
                  ? shuttleCanEvacOrFailReason
                  : undefined
              }
              tooltipPosition="top"
              onClick={() => setCallingShuttle(true)}
            >
              {t('ui.communications_console.call_emergency_shuttle')}
            </Button>
          )}
          {!!shuttleCalledPreviously &&
            (shuttleLastCalled ? (
              <Box>
                {t('ui.communications_console.most_recent_shuttle_trace')}{' '}
                <b>{shuttleLastCalled}</b>
              </Box>
            ) : (
              <Box>
                {t(
                  'ui.communications_console.unable_to_trace_shuttle_recall_signal',
                )}
              </Box>
            ))}
        </Section>
      )}

      {!!canSetAlertLevel && (
        <Section title={t('ui.communications_console.alert_level')}>
          <Flex justify="space-between">
            <Flex.Item>
              <Box>
                {t('ui.communications_console.currently_on_alert_level').replace(
                  '{level}',
                  capitalize(alertLevel),
                )}
              </Box>
            </Flex.Item>

            <Flex.Item>
              <AlertButton
                alertLevel="green"
                onClick={() => setNewAlertLevel('green')}
              />

              <AlertButton
                alertLevel="blue"
                onClick={() => setNewAlertLevel('blue')}
              />
              {/* NOVA EDIT ADDITION START - Alerts */}
              <AlertButton
                alertLevel="violet"
                onClick={() => setNewAlertLevel('violet')}
              />

              <AlertButton
                alertLevel="orange"
                onClick={() => setNewAlertLevel('orange')}
              />

              <AlertButton
                alertLevel="amber"
                onClick={() => setNewAlertLevel('amber')}
              />
              {/* NOVA EDIT ADDITION END - Alerts */}
            </Flex.Item>
          </Flex>
        </Section>
      )}

      <Section title={t('ui.communications_console.functions')}>
        <Flex direction="column">
          {!!canMakeAnnouncement && (
            <Button
              icon="bullhorn"
              onClick={() => act('makePriorityAnnouncement')}
            >
              {t('ui.communications_console.make_priority_announcement')}
            </Button>
          )}

          {!!canToggleEmergencyAccess && (
            <Button.Confirm
              icon="id-card-o"
              confirmIcon="id-card-o"
              color={emergencyAccess ? 'bad' : undefined}
              onClick={() => act('toggleEmergencyAccess')}
            >
              {(emergencyAccess
                ? t('ui.common.disable')
                : t('ui.common.enable')) +
                ' ' +
                t('ui.communications_console.emergency_maintenance_access')}
            </Button.Confirm>
          )}
          {/* NOVA EDIT ADDITION START - Engineering Override */}
          {!!canToggleEngineeringOverride && (
            <Button.Confirm
              icon="wrench"
              confirmIcon="wrench"
              color={engineeringOverride ? 'bad' : undefined}
              onClick={() => act('toggleEngOverride')}
            >
              {(engineeringOverride
                ? t('ui.common.disable')
                : t('ui.common.enable')) +
                ' ' +
                t('ui.communications_console.engineering_override_access')}
            </Button.Confirm>
          )}
          {/* NOVA EDIT ADDITION END */}
          {!syndicate && (
            <Button
              icon="desktop"
              onClick={() =>
                act('setState', { state: ShuttleState.CHANGING_STATUS })
              }
            >
              {t('ui.communications_console.set_status_display')}
            </Button>
          )}

          <Button
            icon="envelope-o"
            onClick={() => act('setState', { state: ShuttleState.MESSAGES })}
          >
            {t('ui.communications_console.message_list')}
          </Button>

          {canBuyShuttles !== 0 && (
            <Button
              icon="shopping-cart"
              disabled={canBuyShuttles !== 1}
              // canBuyShuttles is a string detailing the fail reason
              // if one can be given
              tooltip={canBuyShuttles !== 1 ? canBuyShuttles : undefined}
              tooltipPosition="top"
              onClick={() =>
                act('setState', { state: ShuttleState.BUYING_SHUTTLE })
              }
            >
              {t('ui.communications_console.purchase_shuttle')}
            </Button>
          )}

          {!!canMessageAssociates && (
            <Button
              icon="comment-o"
              disabled={!importantActionReady}
              onClick={() => setMessagingAssociates(true)}
            >
              {t('ui.communications_console.send_message_to').replace(
                '{target}',
                emagged
                  ? t('ui.communications_console.unknown_target')
                  : t('ui.communications_console.centcom'),
              )}
            </Button>
          )}

          {!!canRequestNuke && (
            <Button
              icon="radiation"
              disabled={!importantActionReady}
              onClick={() => setRequestingNukeCodes(true)}
            >
              {t(
                'ui.communications_console.request_nuclear_authentication_codes',
              )}
            </Button>
          )}

          {!!emagged && !syndicate && (
            <Button icon="undo" onClick={() => act('restoreBackupRoutingData')}>
              {t('ui.communications_console.restore_backup_routing_data')}
            </Button>
          )}
          {/* NOVA EDIT ADDITION START */}
          {!!canMessageAssociates && (
            <Button
              icon="bullhorn"
              color="gold"
              disabled={!importantActionReady}
              onClick={() => act('messagethefeds')}
            >
              {t(
                'ui.communications_console.send_message_sol_federation_regional_command',
              )}
            </Button>
          )}
          {!!canMakeAnnouncement && (
            <Button icon="bullhorn" onClick={() => act('callThePolice')}>
              {t(
                'ui.communications_console.call_sol_federation_911_marshals_response',
              )}
            </Button>
          )}
          {!!canMakeAnnouncement && (
            <Button icon="bullhorn" onClick={() => act('callTheCatmos')}>
              {t(
                'ui.communications_console.call_sol_federation_811_advanced_atmospherics_response',
              )}
            </Button>
          )}
          {!!canMakeAnnouncement && (
            <Button icon="bullhorn" onClick={() => act('callTheParameds')}>
              {t(
                'ui.communications_console.call_sol_federation_911_medical_response',
              )}
            </Button>
          )}
          {!!emagged && (
            <Button icon="bullhorn" onClick={() => act('callThePizza')}>
              {t('ui.communications_console.place_order_with_dogginos_pizza')}
            </Button>
          )}
          {/* NOVA EDIT ADDITION END */}
        </Flex>
      </Section>

      {!!canMessageAssociates && messagingAssociates && (
        <MessageModal
          label={t(
            'ui.communications_console.message_to_transmit_via_quantum_entanglement',
          ).replace(
            '{target}',
            emagged
              ? t('ui.communications_console.abnormal_routing_coordinates')
              : t('ui.communications_console.centcom'),
          )}
          notice={t('ui.communications_console.message_associates_notice')}
          icon="bullhorn"
          buttonText={t('ui.common.send')}
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(message) => {
            setMessagingAssociates(false);
            act('messageAssociates', {
              message,
            });
          }}
        />
      )}

      {!!canRequestNuke && requestingNukeCodes && (
        <MessageModal
          label={t(
            'ui.communications_console.reason_for_requesting_nuclear_self_destruct_codes',
          )}
          notice={t('ui.communications_console.nuclear_request_system_notice')}
          icon="bomb"
          buttonText={t('ui.communications_console.request_codes')}
          onBack={() => setRequestingNukeCodes(false)}
          onSubmit={(reason) => {
            setRequestingNukeCodes(false);
            act('requestNukeCodes', {
              reason,
            });
          }}
        />
      )}

      {!!callingShuttle && (
        <MessageModal
          label={t('ui.communications_console.nature_of_emergency')}
          icon="space-shuttle"
          buttonText={t('ui.communications_console.call_shuttle')}
          minLength={callShuttleReasonMinLength}
          onBack={() => setCallingShuttle(false)}
          onSubmit={(reason) => {
            setCallingShuttle(false);
            act('callShuttle', {
              reason,
            });
          }}
        />
      )}

      {!!canSetAlertLevel && showAlertLevelConfirm && (
        <Modal>
          <Flex direction="column" textAlign="center" width="300px">
            <Flex.Item fontSize="16px" mb={2}>
              {t('ui.communications_console.swipe_id_to_confirm_change')}
            </Flex.Item>

            <Flex.Item mr={2} mb={1}>
              <Button
                icon="id-card-o"
                color="good"
                fontSize="16px"
                onClick={() => {
                  act('changeSecurityLevel', {
                    newSecurityLevel: newAlertLevel,
                  });
                  setNewAlertLevel('');
                }}
              >
                {t('ui.communications_console.swipe_id')}
              </Button>

              <Button
                icon="times"
                color="bad"
                fontSize="16px"
                onClick={() => setNewAlertLevel('')}
              >
                {t('ui.common.cancel')}
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}

      {!!canSendToSectors && sectors.length > 0 && (
        <Section title={t('ui.communications_console.allied_sectors')}>
          <Flex direction="column">
            {sectors.map((sectorName) => (
              <Flex.Item key={sectorName}>
                <Button
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector(sectorName)}
                >
                  {t(
                    'ui.communications_console.send_message_to_station_in_sector',
                  ).replace('{sector}', sectorName)}
                </Button>
              </Flex.Item>
            ))}

            {sectors.length > 2 && (
              <Flex.Item>
                <Button
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector('all')}
                >
                  {t(
                    'ui.communications_console.send_message_to_all_allied_stations',
                  )}
                </Button>
              </Flex.Item>
            )}
          </Flex>
        </Section>
      )}

      {!!canSendToSectors && sectors.length > 0 && messagingSector && (
        <MessageModal
          label={t('ui.communications_console.message_to_send_to_allied_station')}
          notice={t('ui.communications_console.send_to_allied_station_notice')}
          icon="bullhorn"
          buttonText={t('ui.common.send')}
          onBack={() => setMessagingSector('')}
          onSubmit={(message) => {
            act('sendToOtherSector', {
              destination: messagingSector,
              message,
            });

            setMessagingSector('');
          }}
        />
      )}
    </Box>
  );
}
