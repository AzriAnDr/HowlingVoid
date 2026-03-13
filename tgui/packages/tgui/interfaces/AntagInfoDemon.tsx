import { Box, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const jauntstyle = {
  color: 'lightblue',
};

const injurestyle = {
  color: 'yellow',
};

type Info = {
  fluff: string;
  explain_attack: BooleanLike;
  objectives: Objective[];
};

export const AntagInfoDemon = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { fluff, objectives, explain_attack } = data;
  return (
    <Window width={620} height={356} theme="syndicate">
      <Window.Content style={{ backgroundImage: 'none' }}>
        <Stack fill>
          <Stack.Item>
            <DemonRunes />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical width="544px" fill>
              <Stack.Item grow>
                <Section fill scrollable={objectives.length > 2}>
                  <Stack vertical>
                    <Stack.Item
                      textAlign="center"
                      textColor="red"
                      fontSize="20px"
                    >
                      {fluff}
                    </Stack.Item>
                    <Stack.Item>
                      <ObjectivePrintout
                        titleMessage={t('ui.antaginfodemon.objectives_title')}
                        objectiveTextSize="20px"
                        objectives={objectives}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              {!!explain_attack && (
                <Stack.Item>
                  <Section fill title={t('ui.antaginfodemon.demonic_powers')}>
                    <Stack vertical>
                      <Stack.Item>
                        <span style={jauntstyle}>{t('ui.antaginfodemon.blood_jaunt')}</span>{' '}
                        {t('ui.antaginfodemon.blood_jaunt_description')}
                      </Stack.Item>
                      <Stack.Divider />
                      <Stack.Item>
                        <span style={injurestyle}>
                          {t('ui.antaginfodemon.monstrous_strike')}
                        </span>{' '}
                        {t('ui.antaginfodemon.monstrous_strike_description')}
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <DemonRunes />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DemonRunes = (props) => {
  const runeWord = 'YUKTOPUS';
  return (
    <Section height="102%" mt="-6px" fill>
      {/*
      shoutout to my boy Yuktopus from Crash Bandicoot: Crash of the Titans.
      Damn, that was such a good game.
      */}
      <Box className="HellishRunes__demonrune">
        {Array.from({ length: 4 }).map((_, row) => (
          <span key={row}>
            {runeWord.split('').map((ch, idx) => (
              <span key={`${row}-${idx}`}>
                {ch}
                <br />
              </span>
            ))}
          </span>
        ))}
      </Box>
    </Section>
  );
};
