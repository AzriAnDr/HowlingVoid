import { Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const MinigamesMenu = (props) => {
  const { t } = usePreferencesLocalization();
  const { act } = useBackend();

  return (
    <Window title={t('ui.minigames.menu_title')} width={530} height={320}>
      <Window.Content>
        <Section title={t('ui.minigames.select_minigame')} textAlign="center" fill>
          <Stack>
            <Stack.Item grow>
              <Button
                content={t('ui.minigames.ctf')}
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('ctf')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                content={t('ui.minigames.mafia')}
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('mafia')}
              />
            </Stack.Item>
          </Stack>
          <Divider />
          <Stack>
            <Stack.Item grow>
              <Button
                content={t('ui.minigames.basketball')}
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('basketball')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                content={t('ui.minigames.deathmatch')}
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('deathmatch')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
