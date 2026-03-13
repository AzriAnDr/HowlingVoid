import { Button, Flex, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const GhostPoolProtection = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    events_or_midrounds,
    spawners,
    station_sentience,
    silicons,
    minigames,
  } = data;
  return (
    <Window
      title={t('ui.ghost_pool_protection.title')}
      width={400}
      height={270}
      theme="admin"
    >
      <Window.Content>
        <Flex grow={1} height="100%">
          <Section
            title={t('ui.common.options')}
            buttons={
              <>
                <Button
                  color="good"
                  icon="plus-circle"
                  content={t('ui.ghost_pool_protection.enable_everything')}
                  onClick={() => act('all_roles')}
                />
                <Button
                  color="bad"
                  icon="minus-circle"
                  content={t('ui.ghost_pool_protection.disable_everything')}
                  onClick={() => act('no_roles')}
                />
              </>
            }
          >
            <NoticeBox danger>
              {t('ui.ghost_pool_protection.sneaky_event_warning')}
            </NoticeBox>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color={events_or_midrounds ? 'good' : 'bad'}
                icon="meteor"
                content={t('ui.ghost_pool_protection.events_and_midround_rulesets')}
                onClick={() => act('toggle_events_or_midrounds')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color={spawners ? 'good' : 'bad'}
                icon="pastafarianism"
                content={t('ui.ghost_pool_protection.ghost_role_spawners')}
                onClick={() => act('toggle_spawners')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color={station_sentience ? 'good' : 'bad'}
                icon="user-astronaut"
                content={t('ui.ghost_pool_protection.station_created_sentience')}
                onClick={() => act('toggle_station_sentience')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color={silicons ? 'good' : 'bad'}
                icon="robot"
                content={t('ui.ghost_pool_protection.silicons')}
                onClick={() => act('toggle_silicons')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color={minigames ? 'good' : 'bad'}
                icon="gamepad"
                content={t('ui.ghost_pool_protection.minigames')}
                onClick={() => act('toggle_minigames')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                textAlign="center"
                color="orange"
                icon="check"
                content={t('ui.common.apply_changes')}
                onClick={() => act('apply_settings')}
              />
            </Flex.Item>
          </Section>
        </Flex>
      </Window.Content>
    </Window>
  );
};
