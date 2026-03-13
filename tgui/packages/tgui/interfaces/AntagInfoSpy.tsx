import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const greenText = {
  fontWeight: 'italics',
  color: '#20b142',
};

const redText = {
  fontWeight: 'italics',
  color: '#e03c3c',
};

type Data = {
  antag_name: string;
  uplink_location: string | null;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

export const AntagInfoSpy = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { antag_name, uplink_location, objectives, can_change_objective } =
    data;
  const antagName = antag_name || t('ui.antaginfospy.spy');
  const disguisedAs = uplink_location || t('ui.antaginfospy.something');

  return (
    <Window width={380} height={450} theme="ntos_darkmode">
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section
          title={t('ui.antaginfospy.you_are_the').replace(
            '{antag_name}',
            antagName,
          )}
        >
          <Stack vertical fill ml={1} mr={1}>
            <Stack.Item fontSize={1.2}>
              {t('ui.antaginfospy.equipped_with_uplink').replace(
                '{uplink_location}',
                disguisedAs,
              )}
            </Stack.Item>
            <Stack.Item>
              <span style={greenText}>
                <b>{t('ui.antaginfospy.use_it_in_hand')}</b>{' '}
                {t('ui.antaginfospy.to_access_uplink_and')}{' '}
                <b>{t('ui.antaginfospy.right_click')}</b>{' '}
                {t('ui.antaginfospy.on_bounty_targets')}
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              {t('ui.antaginfospy.other_spies_may_exist')}
            </Stack.Item>
            <Stack.Item>
              {t('ui.antaginfospy.work_together_or_against_them')}{' '}
              <span style={redText}>
                {t('ui.antaginfospy.same_bounty_not_twice')}
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <ObjectivePrintout
                titleMessage={t(
                  'ui.antaginfospy.your_mission_if_you_choose_to_accept_it',
                )}
                objectives={objectives}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textAlign="center">
              {
                <ReplaceObjectivesButton
                  can_change_objective={can_change_objective}
                  button_title={t('ui.antaginfospy.make_your_own_plan')}
                  button_colour="green"
                />
              }
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
