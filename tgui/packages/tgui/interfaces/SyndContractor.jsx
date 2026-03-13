// THIS IS A NOVA SECTOR UI FILE
import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { FakeTerminal } from './common/FakeTerminal';
import { usePreferencesLocalization } from './localization';

const CONTRACT_STATUS_INACTIVE = 1;
const CONTRACT_STATUS_ACTIVE = 2;
const CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE = 3;
const CONTRACT_STATUS_EXTRACTING = 4;
const CONTRACT_STATUS_COMPLETE = 5;
const CONTRACT_STATUS_ABORTED = 6;

export const SyndContractor = (props) => {
  return (
    <NtosWindow width={500} height={600} theme="syndicate">
      <NtosWindow.Content scrollable>
        <SyndContractorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const SyndContractorContent = (props) => {
  const { data, act } = useBackend();
  const { t } = usePreferencesLocalization(data);

  const terminalMessages = [
    'Recording biometric data...',
    'Analyzing embedded syndicate info...',
    'STATUS CONFIRMED',
    'Contacting syndicate database...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Response received, ack 4851234...',
    `CONFIRM ACC ${Math.round(Math.random() * 20000)}`,
    'Setting up private accounts...',
    'CONTRACTOR ACCOUNT CREATED',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'CONTRACTS FOUND',
    'WELCOME, AGENT',
  ];

  const infoEntries = [
    'SyndTract v2.0',
    '',
    "We've identified potentional high-value targets that are",
    'currently assigned to your mission area. They are believed',
    'to hold valuable information which could be of immediate',
    'importance to our organisation.',
    '',
    'Listed below are all of the contracts available to you. You',
    'are to bring the specified target to the designated',
    'drop-off, and contact us via this uplink. We will send',
    'a specialised extraction unit to put the body into.',
    '',
    'We want targets alive - but we will sometimes pay slight',
    "amounts if they're not, you just won't receive the shown",
    'bonus. You can redeem your payment through this uplink in',
    'the form of raw telecrystals, which can be put into your',
    'regular Syndicate uplink to purchase whatever you may need.',
    'We provide you with these crystals the moment you send the',
    'target up to us, which can be collected at anytime through',
    'this system.',
    '',
    'Targets extracted will be ransomed back to the station once',
    'their use to us is fulfilled, with us providing you a small',
    'percentage cut. You may want to be mindful of them',
    'identifying you when they come back. We provide you with',
    'a standard contractor loadout, which will help cover your',
    'identity.',
  ];

  const errorPane = !!data.error && (
    <Modal backgroundColor="red">
      <Flex align="center">
        <Flex.Item mr={2}>
          <Icon size={4} name="exclamation-triangle" />
        </Flex.Item>
        <Flex.Item mr={2} grow={1} textAlign="center">
          <Box width="260px" textAlign="left" minHeight="80px">
            {data.error}
          </Box>
          <Button
            content={t('ui.syndicate_contractor.dismiss')}
            onClick={() => act('PRG_clear_error')}
          />
        </Flex.Item>
      </Flex>
    </Modal>
  );

  if (!data.logged_in) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button
            content={t('ui.syndicate_contractor.register_user')}
            color="transparent"
            onClick={() => act('PRG_login')}
          />
        </Box>
        {!!data.error && <NoticeBox>{data.error}</NoticeBox>}
      </Section>
    );
  }

  if (data.logged_in && data.first_load) {
    return (
      <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="525px">
        <FakeTerminal
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('PRG_set_first_load_finished')}
        />
      </Box>
    );
  }

  if (data.info_screen) {
    return (
      <>
        <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="500px">
          <FakeTerminal allMessages={infoEntries} linesPerSecond={10} />
        </Box>
        <Button
          fluid
          content={t('ui.syndicate_contractor.continue')}
          color="transparent"
          textAlign="center"
          onClick={() => act('PRG_toggle_info')}
        />
      </>
    );
  }

  return (
    <>
      {errorPane}
      <SyndPane />
    </>
  );
};

export const StatusPane = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  return (
    <Section
      title={
        <>
          {t('ui.syndicate_contractor.contractor_status')}
          <Button
            content={t('ui.syndicate_contractor.view_information_again')}
            color="transparent"
            mb={0}
            ml={1}
            onClick={() => act('PRG_toggle_info')}
          />
        </>
      }
      buttons={
        <Box bold mr={1}>
          {data.contract_rep} Rep
        </Box>
      }
    >
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.syndicate_contractor.tc_available')}
              buttons={
                <Button
                  content={t('ui.syndicate_contractor.claim')}
                  disabled={data.redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')}
                />
              }
            >
              {String(data.redeemable_tc)}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.syndicate_contractor.tc_earned')}>
              {String(data.earned_tc)}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.syndicate_contractor.contracts_completed')}
            >
              {String(data.contracts_completed)}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.syndicate_contractor.current_status')}
            >
              {t('ui.syndicate_contractor.active')}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const SyndPane = (props) => {
  const [tab, setTab] = useState(1);
  const { t } = usePreferencesLocalization();
  return (
    <>
      <StatusPane state={props.state} />
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          {t('ui.syndicate_contractor.contracts')}
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          {t('ui.syndicate_contractor.hub')}
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && <ContractsTab />}
      {tab === 2 && <HubTab />}
    </>
  );
};

const ContractsTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const contracts = data.contracts || [];
  return (
    <>
      <Section
        title={t('ui.syndicate_contractor.available_contracts')}
        buttons={
          <Button
            content={t('ui.syndicate_contractor.call_extraction')}
            disabled={!data.ongoing_contract || data.extraction_enroute}
            onClick={() => act('PRG_call_extraction')}
          />
        }
      >
          {contracts
            .filter((contract) => {
              if (
                data.ongoing_contract &&
                contract.status !== CONTRACT_STATUS_ACTIVE
              ) {
                return false;
              }
              return contract.status < CONTRACT_STATUS_COMPLETE;
            })
            .map((contract) => {
              const active = contract.status > CONTRACT_STATUS_INACTIVE;
          return (
            <Section
              key={contract.target}
              title={
                contract.target
                  ? `${contract.target} (${contract.target_rank})`
                  : t('ui.syndicate_contractor.invalid_target')
              }
              level={active ? 1 : 2}
              buttons={
                <>
                  <Box inline bold mr={1}>
                    {`${contract.payout} (+${contract.payout_bonus}) TC`}
                  </Box>
                  <Button
                    content={
                      active
                        ? t('ui.syndicate_contractor.abort')
                        : t('ui.syndicate_contractor.accept')
                    }
                    disabled={contract.extraction_enroute}
                    color={active && 'bad'}
                    onClick={() =>
                      act(`PRG_contract${active ? '_abort' : '-accept'}`, {
                        contract_id: contract.id,
                      })
                    }
                  />
                </>
              }
            >
              <Stack>
                <Stack.Item grow>{contract.message}</Stack.Item>
                <Stack.Item>
                  <Box bold mb={1}>
                    {t('ui.syndicate_contractor.dropoff_location')}:
                  </Box>
                  <Box>{contract.dropoff}</Box>
                </Stack.Item>
              </Stack>
            </Section>
          );
        })}
      </Section>
      <Section
        title={t('ui.syndicate_contractor.dropoff_locator')}
        textAlign="center"
        opacity={data.ongoing_contract ? 100 : 0}
      >
        <Box bold>{data.dropoff_direction}</Box>
      </Section>
    </>
  );
};

const HubTab = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const contractor_hub_items = data.contractor_hub_items || [];
  return (
    <Section>
      {contractor_hub_items.map((item) => {
        const repInfo = item.cost
          ? `${item.cost} ${t('ui.syndicate_contractor.rep_short')}`
          : t('ui.syndicate_contractor.free');
        const limited = item.limited !== -1;
        return (
          <Section
            key={item.name}
            title={`${item.name} - ${repInfo}`}
            level={2}
            buttons={
              <>
                {limited && (
                  <Box inline bold mr={1}>
                    {item.limited} {t('ui.syndicate_contractor.remaining')}
                  </Box>
                )}
                <Button
                  content={t('ui.syndicate_contractor.purchase')}
                  disabled={
                    data.contract_rep < item.cost ||
                    (limited && item.limited <= 0)
                  }
                  onClick={() =>
                    act('buy_hub', {
                      item: item.name,
                      cost: item.cost,
                    })
                  }
                />
              </>
            }
          >
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Icon fontSize="60px" name={item.item_icon} />
                </Table.Cell>
                <Table.Cell verticalAlign="top">{item.desc}</Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        );
      })}
    </Section>
  );
};
