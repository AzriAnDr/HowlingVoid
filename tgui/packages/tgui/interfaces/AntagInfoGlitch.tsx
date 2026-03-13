import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import type { Objective } from './common/Objectives';

type Data = {
  antag_name: string;
  objectives: Objective[];
};

const textStyles = {
  variable: {
    color: 'white',
  },
  danger: {
    color: 'red',
  },
} as const;

export const AntagInfoGlitch = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { antag_name, objectives = [] } = data;

  return (
    <Window width={350} height={450} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack fill vertical>
            <Stack.Item>{t('ui.antaginfoglitch.fn_terminate_intruders_ref')}</Stack.Item>
            <Stack.Divider />
            <Stack.Item bold fontSize="16px">
              <span style={textStyles.variable}>Initialize({antag_name})</span>
            </Stack.Item>
            <Stack.Item mb={1}>
              <span style={textStyles.danger}>{t('ui.antaginfoglitch.bitrunning')}</span> is a crime. Your
              mission: <span style={textStyles.variable}>{t('ui.antaginfoglitch.eliminate')}</span>{' '}
              organic intruders to maintain the integrity of the system.
            </Stack.Item>
            <SpecificInfo />

            <Stack.Divider />
            <Stack.Item>
              <span style={{ opacity: 0.6 }}>
                &#47;&#47; {objectives[0]?.explanation}
              </span>
            </Stack.Item>
            <Stack.Item>
              const <span style={textStyles.variable}>{t('ui.antaginfoglitch.targets')}</span> ={' '}
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>{t('ui.antaginfoglitch.system')}</span>
              <span style={textStyles.danger}>{t('ui.antaginfoglitch.intruders')}</span>
            </Stack.Item>
            <Stack.Item>
              while <span style={textStyles.variable}>{t('ui.antaginfoglitch.targets')}</span>.LIFE !={' '}
              <span style={textStyles.variable}>{t('ui.antaginfoglitch.stat')}</span>DEAD
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>{t('ui.antaginfoglitch.action')}</span>
              <span style={textStyles.danger}>{t('ui.antaginfoglitch.kill')}</span>
            </Stack.Item>
            <Stack.Item>{t('ui.antaginfoglitch.terminate_intruders_0x70cf4020')}</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SpecificInfo = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { antag_name } = data;

  switch (antag_name) {
    case 'Cyber Police':
      return (
        <>
          <Stack.Item mb={1}>
            To assist your task, your program has been loaded with cutting edge{' '}
            <span style={textStyles.variable}>{t('ui.antaginfoglitch.martial_arts')}</span> skills.
          </Stack.Item>
          <Stack.Item grow>
            Ranged weaponry is <span style={textStyles.danger}>{t('ui.antaginfoglitch.forbidden')}</span>.
            Ballistic defense is frowned upon. Style is paramount.
          </Stack.Item>
        </>
      );
    case 'Cyber Tac':
      return (
        <>
          <Stack.Item mb={1}>
            You are an advanced combat unit. You have been outfitted with{' '}
            <span style={textStyles.variable}>{t('ui.antaginfoglitch.lethal_weaponry')}</span>.
          </Stack.Item>
          <Stack.Item grow>
            <span style={textStyles.danger}>{t('ui.antaginfoglitch.terminate')}</span> organic life at any
            cost.
          </Stack.Item>
        </>
      );
    case 'NetGuardian Prime':
      return (
        <Stack.Item grow>
          <span style={{ ...textStyles.danger, fontSize: '16px' }}>
            ORGANIC LIFE MUST BE TERMINATED.
          </span>
        </Stack.Item>
      );
    default:
      return null;
  }
};
