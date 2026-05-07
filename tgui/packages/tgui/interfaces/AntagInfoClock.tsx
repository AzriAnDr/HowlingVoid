// THIS IS A NOVA SECTOR UI FILE
import { Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Rules } from './AntagInfoRules';
import { usePreferencesLocalization } from './localization';

type Info = {
  antag_name: string;
};

export const AntagInfoClock = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { antag_name } = data;
  return (
    <Window width={620} height={350} theme="clockwork">
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item fontSize="20px" color={'good'}>
              <Icon name={'cog'} rotation={0} spin />
              {` ${t('ui.antag_info_clock.you_are_the').replace(
                '{antag}',
                antag_name,
              )} `}
              <Icon name={'cog'} rotation={35} spin />
            </Stack.Item>
            <Stack.Item>
              <Rules />
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Stack vertical>
      <Stack.Item bold>{t('ui.antag_info_clock.your_goals')}</Stack.Item>
      <Stack.Item>{t('ui.antag_info_clock.goal_other_organizations')}</Stack.Item>
      <Stack.Item>{t('ui.antag_info_clock.goal_ratvar')}</Stack.Item>
    </Stack>
  );
};
