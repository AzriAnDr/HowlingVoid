import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  active_bets: ActiveBets[];
  bank_name: string;
  bank_money: number;
  can_create_bet: BooleanLike;
  max_title_length: number;
  max_description_length: number;
};

type ActiveBets = {
  name: string;
  description: string;
  owner: BooleanLike;
  creator: string;
  current_bets: CurrentBets[];
  locked: BooleanLike;
};

type CurrentBets = {
  option_name: string;
  total_amount: number;
  personally_invested: number;
};

export const NtosSpaceBetting = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { bank_name, bank_money, can_create_bet } = data;
  return (
    <NtosWindow width={500} height={620}>
      <NtosWindow.Content scrollable>
        <Section title={t('ui.ntosspacebetting.user_information')}>
          <Stack>
            <Stack.Item mr={1.5}>
              <Icon
                name="id-card"
                size={3}
                mr={1}
                color={bank_name ? 'green' : 'red'}
              />
            </Stack.Item>
            <Stack fill vertical>
              <Stack.Item>
                {t('ui.ntosspacebetting.username')}: {bank_name}
              </Stack.Item>
              <Stack.Item>
                {t('ui.ntosspacebetting.money_available')}: {bank_money}cr
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
        <PollsSection />
        {!!can_create_bet && <BettingCreation />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const PollsSection = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { active_bets = [] } = data;
  const [Winner, set_winner] = useState('');
  return (
    <Section>
      {!active_bets.length ? (
        <Box>
          {t('ui.ntosspacebetting.no_active_polls')}
        </Box>
      ) : (
        active_bets.map(
          (
            { name, description, owner, creator, current_bets = [], locked },
            index,
          ) => (
            <Section title={`${name} - Created by ${creator}`} key={name}>
              <Stack>
                <Stack.Item grow>
                  <Stack.Item grow>{description}</Stack.Item>
                  <Divider />
                  {current_bets.map(
                    (
                      { option_name, total_amount, personally_invested },
                      index,
                    ) => (
                      <Stack.Item
                        grow
                        key={option_name}
                        className="candystripe"
                        my={1.5}
                      >
                        <Stack.Item>
                          <Stack.Item my={1}>
                            {option_name} (Has {total_amount || 0}cr bet on it)
                            {!owner ? (
                              <NumberInput
                                value={personally_invested}
                                unit="cr"
                                width="15px"
                                disabled={!!locked}
                                minValue={0}
                                maxValue={10000}
                                step={1}
                                onChange={(value) =>
                                  act('place_bet', {
                                    bet_selected: name,
                                    option_selected: option_name,
                                    money_betting: value,
                                  })
                                }
                              />
                            ) : (
                              <Button.Checkbox
                                tooltip={t(
                                  'ui.ntosspacebetting.whether_this_answer_won',
                                )}
                                checked={Winner === option_name}
                                key={option_name}
                                onClick={() => set_winner(option_name)}
                              />
                            )}
                          </Stack.Item>
                        </Stack.Item>
                      </Stack.Item>
                    ),
                  )}
                  {!!owner &&
                    (!locked ? (
                      <Stack.Item>
                          <Button.Confirm
                          fluid
                          icon="minus"
                          tooltip={t(
                            'ui.ntosspacebetting.lock_the_ability_to_place_retract_bets_this_is_irreversible',
                          )}
                          onClick={() =>
                            act('lock_betting', { bet_selected: name })
                          }
                        >
                          {t('ui.ntosspacebetting.lock_betting')}
                        </Button.Confirm>
                      </Stack.Item>
                    ) : (
                      <Button.Confirm
                        fluid
                        icon="plus"
                        tooltip={t(
                          'ui.ntosspacebetting.finalize_results_as_the_checked_answer_being_the_winner',
                        )}
                        onClick={() =>
                          act('select_winner', {
                            bet_selected: name,
                            winning_answer: Winner,
                          })
                        }
                      >
                        {t('ui.ntosspacebetting.finalize_results')}
                      </Button.Confirm>
                    ))}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    icon="minus"
                    disabled={locked}
                    tooltip={t(
                      'ui.ntosspacebetting.if_you_have_any_bets_this_will_remove_them_and_refund_the_money',
                    )}
                    onClick={() => act('cancel_bet', { bet_selected: name })}
                  >
                    {t('ui.ntosspacebetting.cancel_bet')}
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          ),
        )
      )}
    </Section>
  );
};

export const BettingCreation = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { max_title_length, max_description_length } = data;
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [option1, setOption1] = useState('');
  const [option2, setOption2] = useState('');
  const [option3, setOption3] = useState('');
  const [option4, setOption4] = useState('');

  return (
    <Collapsible title={t('ui.ntosspacebetting.bet_creation')}>
      <Stack fill vertical>
        <Stack.Item grow>
          <Input
            fluid
            placeholder={t('ui.ntosspacebetting.title')}
            maxLength={max_title_length}
            onChange={setTitle}
          />
        </Stack.Item>
        <Stack.Item grow>
          <TextArea
            fluid
            placeholder={t('ui.ntosspacebetting.description')}
            height="100px"
            width="100%"
            maxLength={max_description_length}
            backgroundColor="black"
            textColor="white"
            onChange={setDescription}
          />
        </Stack.Item>
        <Input
          fluid
          placeholder={t('ui.ntosspacebetting.option_1')}
          maxLength={max_title_length}
          onChange={setOption1}
        />
        <Input
          fluid
          placeholder={t('ui.ntosspacebetting.option_2')}
          maxLength={max_title_length}
          onChange={setOption2}
        />
        <Input
          fluid
          placeholder={t('ui.ntosspacebetting.option_3_optional')}
          maxLength={max_title_length}
          onChange={setOption3}
        />
        <Input
          fluid
          placeholder={t('ui.ntosspacebetting.option_4_optional')}
          maxLength={max_title_length}
          onChange={setOption4}
        />
        <Stack.Item grow>
          <Button
            fluid
            onClick={() =>
              act('create_bet', {
                title,
                description,
                option1,
                option2,
                option3,
                option4,
              })
            }
          >
            {t('ui.ntosspacebetting.create_bet')}
          </Button>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
};

