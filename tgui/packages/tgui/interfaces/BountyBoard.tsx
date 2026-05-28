import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Flex,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { UserDetails } from './Vending';

type Data = {
  accountName?: string;
  requests?: Request[] | null;
  applicants?: Applicant[] | null;
  bountyValue?: number | null;
  bountyText?: string | null;
  user?: User | null;
};

type Request = {
  name: string;
  owner: string;
  description: string;
  value: number;
  acc_number: number;
};

type Applicant = {
  name: string;
  request_id: number;
  requestee_id: number;
};

type User = {
  name: string;
};

export const BountyBoard = (props) => {
  return (
    <Window width={550} height={600}>
      <Window.Content scrollable>
        <BountyBoardContent />
      </Window.Content>
    </Window>
  );
};

export const BountyBoardContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    requests,
    applicants,
    bountyValue,
    user,
  } = data;
  const displayedRequests = requests || [];
  const displayedApplicants = applicants || [];
  const displayedBountyValue = bountyValue ?? 1;
  const displayedUser = user || { name: 'Unknown' };
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(50, 50, 170, 0.5)';
  return (
    <>
      <Section
        title={t('ui.bounty_board.user_details')}
        buttons={
          <Button
            icon="power-off"
            content={t('ui.bounty_board.reset_account')}
            onClick={() => act('clear')}
          />
        }
      >
        <UserDetails />
      </Section>
      <Flex mb={1}>
        <Flex.Item grow={1} basis={0}>
          {displayedRequests.map((request) => (
            <Collapsible key={request.name} title={request.owner} width="300px">
              <Section key={request.name} width="300px">
                <Stack align="baseline">
                  <Stack.Item bold width="310px">
                    {request.owner}
                  </Stack.Item>
                  <Stack.Item width="100px">
                    {`${formatMoney(request.value)} cr`}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="pen-fancy"
                      content={t('ui.bounty_board.apply')}
                      disabled={request.owner === displayedUser.name}
                      onClick={() =>
                        act('apply', {
                          request: request.acc_number,
                        })
                      }
                    />
                    <Button
                      fluid
                      icon="trash-alt"
                      content={t('ui.common.delete')}
                      color="red"
                      onClick={() =>
                        act('deleteRequest', {
                          request: request.acc_number,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
                <BlockQuote pt={1} align="center">
                  <i>&quot;{request.description}&quot;</i>
                </BlockQuote>
                <Section title={t('ui.bounty_board.request_applicants')}>
                  {displayedApplicants.map(
                    (applicant) =>
                      applicant.request_id === request.acc_number && (
                        <Flex key={applicant.request_id}>
                          <Flex.Item
                            grow={1}
                            p={0.5}
                            backgroundColor={backColor}
                            width="500px"
                            textAlign="center"
                            style={{
                              border: `2px solid ${color}`,
                            }}
                          >
                            {applicant.name}
                          </Flex.Item>
                          <Flex.Item align="end">
                            <Button
                              fluid
                              p={1}
                              icon="cash-register"
                              tooltip={t('ui.bounty_board.pay_out_tooltip')}
                              onClick={() =>
                                act('payApplicant', {
                                  applicant: applicant.requestee_id,
                                  request: request.acc_number,
                                })
                              }
                            />
                          </Flex.Item>
                        </Flex>
                      ),
                  )}
                </Section>
              </Section>
            </Collapsible>
          ))}
        </Flex.Item>
        <Flex.Item>
          <Collapsible title={t('ui.bounty_board.new_bounty')} width="220px" color="green">
            <Section>
              <TextArea
                height="150px"
                width="200px"
                onBlur={(value) =>
                  act('bountyText', {
                    bountytext: value,
                  })
                }
              />
              <Box>
                <NumberInput
                  animated
                  unit="cr"
                  minValue={1}
                  maxValue={1000}
                  value={displayedBountyValue}
                  step={1}
                  width="80px"
                  onChange={(value) =>
                    act('bountyVal', {
                      bountyval: value,
                    })
                  }
                />
                <Button
                  icon="print"
                  content={t('ui.bounty_board.submit_bounty')}
                  disabled={displayedUser.name === 'Unknown'}
                  onClick={() => act('createBounty')}
                />
              </Box>
            </Section>
          </Collapsible>
        </Flex.Item>
      </Flex>
    </>
  );
};
