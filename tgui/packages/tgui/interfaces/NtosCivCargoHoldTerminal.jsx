import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosCivCargoHoldTerminal = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { status_report, id_inserted, id_bounty_info, picking } = data;
  const in_text = t('ui.ntoscivcargoholdterminal.welcome_valued_employee');
  const out_text = t(
    'ui.ntoscivcargoholdterminal.to_begin_insert_your_id_into_the_console',
  );
  return (
    <NtosWindow width={580} height={375}>
      <NtosWindow.Content scrollable>
        <Flex>
          <Flex.Item grow>
            <NoticeBox color={!id_inserted ? 'default' : 'blue'}>
              {id_inserted ? in_text : out_text}
            </NoticeBox>
            <Section
              title={t('ui.ntoscivcargoholdterminal.bounty_choice')}
              buttons={
                <Button
                  icon={id_bounty_info ? 'recycle' : 'pen'}
                  color={id_bounty_info ? 'green' : 'default'}
                  tooltip={
                    id_bounty_info
                      ? t('ui.ntoscivcargoholdterminal.replace_bounty')
                      : t('ui.ntoscivcargoholdterminal.new_bounty')
                  }
                  disabled={!id_inserted}
                  onClick={() => act('bounty')}
                />
              }
            >
              <LabeledList>
                <LabeledList.Item label={t('ui.ntoscivcargoholdterminal.cargo_report')}>
                  {status_report}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            {picking ? <BountyPickBox /> : <BountyTextBox />}
          </Flex.Item>
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const BountyTextBox = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { id_bounty_info, id_bounty_value, id_bounty_num } = data;
  const na_text = t('ui.ntoscivcargoholdterminal.n_a_please_add_a_new_bounty');
  return (
    <Section title={t('ui.ntoscivcargoholdterminal.bounty_info')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.ntoscivcargoholdterminal.description')}>
          {id_bounty_info ? id_bounty_info : na_text}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntoscivcargoholdterminal.quantity')}>
          {id_bounty_info ? id_bounty_num : t('ui.common.not_available')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.ntoscivcargoholdterminal.value')}>
          {id_bounty_info ? id_bounty_value : t('ui.common.not_available')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BountyPickBox = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { id_bounty_names, id_bounty_infos, id_bounty_values } = data;
  return (
    <Section
      title={t('ui.ntoscivcargoholdterminal.please_select_a_bounty')}
      textAlign="center"
    >
      <Flex width="100%" wrap>
        <Flex.Item shrink={0} grow={0.5}>
          <BountyPickButton
            bounty_name={id_bounty_names[0]}
            bounty_info={id_bounty_infos[0]}
            bounty_value={id_bounty_values[0]}
            pick_value={1}
            act={act}
          />
        </Flex.Item>
        <Flex.Item shrink={0} grow={0.5} px={1}>
          <BountyPickButton
            bounty_name={id_bounty_names[1]}
            bounty_info={id_bounty_infos[1]}
            bounty_value={id_bounty_values[1]}
            pick_value={2}
            act={act}
          />
        </Flex.Item>
        <Flex.Item shrink={0} grow={0.5}>
          <BountyPickButton
            bounty_name={id_bounty_names[2]}
            bounty_info={id_bounty_infos[2]}
            bounty_value={id_bounty_values[2]}
            pick_value={3}
            act={act}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const BountyPickButton = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  return (
    <Button
      fluid
      color="green"
      onClick={() => props.act('pick', { value: props.pick_value })}
      style={{
        display: 'flex',
        textWrap: 'wrap',
        whiteSpace: 'normal',
        paddingLeft: '0',
        paddingRight: '0',
      }}
    >
      <Box>{props.bounty_name}</Box>
      <Box
        textAlign="left"
        color="black"
        backgroundColor="linen"
        lineHeight="1.2em"
        p={1}
      >
        {props.bounty_info}
      </Box>
      <Box>
        {t('ui.ntoscivcargoholdterminal.payout')}: {props.bounty_value} cr
      </Box>
    </Button>
  );
};

