import { Box, Button, Flex, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type CTFPanelData =
  | {
      teams: {
        name: string;
        color: string;
        score: number;
        team_size: number;
        refs: string[];
      }[];
    }
  | {
      voters: number;
      voters_required: number;
      voted: BooleanLike;
    };

export const CTFPanel = (props) => {
  const { act, data } = useBackend<CTFPanelData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Window title={t('ui.ctfpanel.ctf_panel')} width={700} height={600}>
      <Window.Content scrollable>
        {'teams' in data ? (
          <Flex align="center" wrap="wrap" textAlign="center" m={-0.5}>
            {data.teams.map((team) => (
              <Flex.Item key={team.name} width="49%" m={0.5} mb={8}>
                <Section
                  key={team.name}
                  title={t('ui.ctfpanel.team_title')
                    .replace('{color}', team.color)}
                >
                  <Stack fill mb={1}>
                    <Stack.Item grow>
                      <Box>
                        <b>{team.team_size}</b>{' '}
                        {team.team_size === 1
                          ? t('ui.ctfpanel.member')
                          : t('ui.ctfpanel.members')}
                      </Box>
                    </Stack.Item>

                    <Stack.Item grow>
                      <Box>
                        <b>{team.score}</b>{' '}
                        {team.score === 1
                          ? t('ui.ctfpanel.point')
                          : t('ui.ctfpanel.points')}
                      </Box>
                    </Stack.Item>
                  </Stack>

                  <Button
                    content={t('ui.ctfpanel.jump')}
                    fontSize="18px"
                    fluid
                    color={team.color.toLowerCase()}
                    onClick={() =>
                      act('jump', {
                        refs: team.refs,
                      })
                    }
                  />

                  <Button
                    content={t('ui.ctfpanel.join')}
                    fontSize="18px"
                    fluid
                    color={team.color.toLowerCase()}
                    onClick={() =>
                      act('join', {
                        refs: team.refs,
                      })
                    }
                  />
                </Section>
              </Flex.Item>
            ))}
          </Flex>
        ) : (
          <Stack fill align="center" justify="center" vertical>
            <Stack.Item mb={5}>
              <Box fontSize="90px" textAlign="center">
                {data.voters}/{data.voters_required}
              </Box>
              <br />
              <Box fontSize="30px" textAlign="center">
                {t('ui.ctfpanel.voters')}
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Button
                fontSize="24px"
                color={data.voted ? 'bad' : 'good'}
                onClick={() => {
                  if (data.voted) {
                    act('unvote');
                  } else {
                    act('vote');
                  }
                }}
              >
                {data.voted
                  ? t('ui.ctfpanel.unvote_for_ctf')
                  : t('ui.ctfpanel.vote_for_ctf')}
              </Button>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
