import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const CivCargoHoldTerminal = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { pad, sending, status_report, id_inserted, id_bounty_info, picking } =
    data;
  const in_text = t('ui.civ_cargo_hold.welcome_employee');
  const out_text = t('ui.civ_cargo_hold.insert_id_prompt');
  return (
    <Window width={580} height={375}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item grow>
            <NoticeBox color={!id_inserted ? 'default' : 'blue'}>
              {id_inserted ? in_text : out_text}
            </NoticeBox>
            <Section
              title={t('ui.civ_cargo_hold.cargo_pad')}
              buttons={
                <>
                  <Button
                    icon={'sync'}
                    tooltip={t('ui.civ_cargo_hold.check_contents')}
                    disabled={!pad || !id_inserted}
                    onClick={() => act('recalc')}
                  />
                  <Button
                    icon={sending ? 'times' : 'arrow-up'}
                    tooltip={
                      sending
                        ? t('ui.civ_cargo_hold.stop_sending')
                        : t('ui.civ_cargo_hold.send_goods')
                    }
                    selected={sending}
                    disabled={!pad || !id_inserted}
                    onClick={() => act(sending ? 'stop' : 'send')}
                  />
                  <Button
                    icon={id_bounty_info ? 'recycle' : 'pen'}
                    color={id_bounty_info ? 'green' : 'default'}
                    tooltip={
                      id_bounty_info
                        ? t('ui.civ_cargo_hold.replace_bounty')
                        : t('ui.civ_cargo_hold.new_bounty')
                    }
                    disabled={!id_inserted}
                    onClick={() => act('bounty')}
                  />
                  <Button
                    icon={'download'}
                    content={t('ui.civ_cargo_hold.eject_id')}
                    disabled={!id_inserted}
                    onClick={() => act('eject')}
                  />
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item
                  label={t('ui.common.status')}
                  color={pad ? 'good' : 'bad'}
                >
                  {pad ? t('ui.common.online') : t('ui.common.not_found')}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.civ_cargo_hold.cargo_report')}>
                  {status_report}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            {picking ? <BountyPickBox /> : <BountyTextBox />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const BountyTextBox = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { id_bounty_info, id_bounty_value, id_bounty_num } = data;
  const na_text = t('ui.civ_cargo_hold.na_add_new_bounty');
  return (
    <Section title={t('ui.civ_cargo_hold.bounty_info')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.description')}>
          {id_bounty_info ? id_bounty_info : na_text}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.quantity')}>
          {id_bounty_info ? id_bounty_num : t('ui.common.not_applicable')}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.value')}>
          {id_bounty_info ? id_bounty_value : t('ui.common.not_applicable')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BountyPickBox = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const { id_bounty_names, id_bounty_infos, id_bounty_values } = data;
  return (
    <Section title={t('ui.civ_cargo_hold.select_bounty')} textAlign="center">
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
  const { t } = usePreferencesLocalization();
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
        {t('ui.civ_cargo_hold.payout')}: {props.bounty_value} cr
      </Box>
    </Button>
  );
};
