// THIS IS A NOVA SECTOR UI FILE
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const EventPanel = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    event_list = [],
    end_time,
    vote_in_progress,
    previous_events,
    admin_mode,
    show_votes,
    next_vote_time,
    next_low_chaos_time,
  } = data;
  return (
    <Window title={t('ui.event.panel')} width={500} height={900} theme={'admin'}>
      <Window.Content>
        <Stack vertical fill>
          {!!admin_mode && (
            <Stack.Item>
              <Section title={t('ui.event.control')}>
                <NoticeBox color="blue">
                  {`Next vote in ${toFixed(next_vote_time, 0)} seconds.`}
                </NoticeBox>
                <NoticeBox color="blue">
                  {'Low chaos event in ' +
                    toFixed(next_low_chaos_time, 0) +
                    ' seconds.'}
                </NoticeBox>
                <Button
                  icon="plus"
                  content={t('ui.event.start_admin_vote')}
                  tooltip={t('ui.event.tooltip_start_admin_vote')}
                  disabled={vote_in_progress}
                  onClick={() => act('start_vote_admin')}
                />
                <Button
                  icon="plus"
                  content={t('ui.event.start_admin_chaos_vote')}
                  tooltip={t('ui.event.tooltip_start_admin_chaos_vote')}
                  disabled={vote_in_progress}
                  onClick={() => act('start_vote_admin_chaos')}
                />
                <Button
                  icon="user-plus"
                  content={t('ui.event.start_player_vote')}
                  tooltip={t('ui.event.tooltip_public_vote')}
                  color="average"
                  disabled={vote_in_progress}
                  onClick={() => act('start_player_vote')}
                />
                <Button
                  icon="user-plus"
                  content={t('ui.event.start_public_chaos_vote')}
                  tooltip={t('ui.event.tooltip_public_vote')}
                  color="average"
                  disabled={vote_in_progress}
                  onClick={() => act('start_player_vote_chaos')}
                />
                <Button
                  icon="stopwatch"
                  content={t('ui.event.end_vote')}
                  tooltip={t('ui.event.tooltip_end_vote')}
                  disabled={!vote_in_progress}
                  onClick={() => act('end_vote')}
                />
                <Button
                  icon="ban"
                  content={t('ui.event.cancel_vote')}
                  tooltip={t('ui.event.tooltip_cancel_vote')}
                  disabled={!vote_in_progress}
                  onClick={() => act('cancel_vote')}
                />
                <Button
                  icon="clock"
                  content={t('ui.event.reschedule_next_vote')}
                  tooltip={t('ui.event.tooltip_reschedule_next_vote')}
                  onClick={() => act('reschedule')}
                />
                <Button
                  icon="clock"
                  content={t('ui.event.reschedule_next_low_chaos_event')}
                  tooltip={t('ui.event.tooltip_reschedule_next_low_chaos_event')}
                  onClick={() => act('reschedule_low_chaos')}
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section
              scrollable
              fill
              grow
              title={
                vote_in_progress
                  ? `Available Events (${toFixed(end_time)} seconds) `
                  : 'Available Events'
              }
            >
              {vote_in_progress ? (
                <LabeledList>
                  {event_list.map((event) => (
                    <LabeledList.Item
                      label={event.name}
                      key={event.name}
                      buttons={
                        <Button
                          color={event.self_vote ? 'good' : 'blue'}
                          icon="vote-yea"
                          content={t('ui.event.vote')}
                          onClick={() =>
                            act('register_vote', {
                              event_ref: event.ref,
                            })
                          }
                        />
                      }
                    >
                      {!!show_votes || (!!admin_mode && event.votes)}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              ) : (
                <NoticeBox>{t('ui.event.no_vote_in_progress')}</NoticeBox>
              )}
            </Section>
          </Stack.Item>
          {!!admin_mode && (
            <Stack.Item>
              <Section
                scrollable
                grow
                fill
                height="150px"
                title={t('ui.event.previous_events')}
              >
                {previous_events.length > 0 ? (
                  <LabeledList>
                    {previous_events.map((event) => (
                      <LabeledList.Item label={t('ui.event.event')} key={event}>
                        {event}
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                ) : (
                  <NoticeBox>{t('ui.event.no_previous_events')}</NoticeBox>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
