import { useState } from 'react';
import {
  BlockQuote,
  Dropdown,
  Flex,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  policy: Record<string, string>;
};

function searchForPolicy(policy: Record<string, string>, token: string) {
  return Object.keys(policy).filter((key) =>
    key.toLowerCase().includes(token.toLowerCase()),
  );
}

export const Policypanel = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { policy } = data;

  const [currentPolicy, setCurrentPolicy] = useState<string>('');

  return (
    <Window title={t('ui.policypanel.policy_panel')} theme="admin" width={400} height={300}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Flex>
              <Flex.Item width="50%">
                <Dropdown
                  options={Object.keys(policy)}
                  selected={currentPolicy}
                  onSelected={setCurrentPolicy}
                />
              </Flex.Item>
              <Flex.Item width="50%">
                <Input
                  placeholder={t('ui.policypanel.search')}
                  fluid
                  onEnter={(value) => {
                    const results = searchForPolicy(policy, value);
                    if (results.length === 1) {
                      setCurrentPolicy(results[0]);
                    }
                  }}
                />
              </Flex.Item>
            </Flex>
          </Stack.Item>
          <Stack.Item height="100%">
            <Section scrollable fill>
              <BlockQuote fontSize="16px">
                {policy[currentPolicy] ||
                  `Select a policy to view. These policies are displayed
                    to players upon gaining the relevant role.`}
              </BlockQuote>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
