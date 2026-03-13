import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type BasketballPanelData = {
  total_votes: number;
  players_min: number;
  players_max: number;
  lobbydata: {
    ckey: string;
    status: string;
  }[];
};

export const BasketballPanel = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<BasketballPanelData>();

  return (
    <Window title={t('ui.basketball.title')} width={650} height={580}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={t('ui.basketball.lobby')}
              buttons={
                <>
                  <Button
                    icon="clipboard-check"
                    tooltipPosition="bottom-start"
                    tooltip={`
                    ${t('ui.basketball.signup_tooltip')}
                  `}
                    content={t('ui.basketball.sign_up')}
                    onClick={() => act('basketball_signup')}
                  />
                  <Button
                    icon="basketball"
                    disabled={data.total_votes < data.players_min}
                    onClick={() => act('basketball_start')}
                  >
                    {t('ui.common.start')}
                  </Button>
                </>
              }
            >
              <NoticeBox info>
                {t('ui.basketball.lobby_has')} {data.total_votes} {t('ui.basketball.players_signed_up')} {t('ui.basketball.minigame_is_for')} {data.players_min} {t('ui.common.to')} {data.players_max} {t('ui.common.players')}.
              </NoticeBox>

              {data.lobbydata.map((lobbyist) => (
                <Stack
                  key={lobbyist.ckey}
                  className="candystripe"
                  p={1}
                  align="baseline"
                >
                  <Stack.Item grow>{lobbyist.ckey}</Stack.Item>
                  <Stack.Item>{t('ui.common.status')}:</Stack.Item>
                  <Stack.Item
                    color={lobbyist.status === 'Ready' ? 'green' : 'red'}
                  >
                    {lobbyist.status}
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item />
        </Stack>
      </Window.Content>
    </Window>
  );
};
