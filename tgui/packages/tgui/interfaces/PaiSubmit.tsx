import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  comments: string;
  description: string;
  name: string;
};

export const PaiSubmit = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { comments, description, name } = data;
  const [input, setInput] = useState({
    comments,
    description,
    name,
  });

  return (
    <Window width={400} height={460} title={t('ui.pai_submit.candidacy_menu')}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay input={input} setInput={setInput} />
          </Stack.Item>
          <Stack.Item>
            <ButtonsDisplay input={input} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays basic info about playing pAI */
const DetailsDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Section fill scrollable title={t('ui.common.details')}>
      <Box color="label">
        {t('ui.pai_submit.description')}
        <br />
        <br />
        {t('ui.pai_submit.rules')}
      </Box>
    </Section>
  );
};

/** Input boxes for submission details */
const InputDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { input, setInput } = props;
  const { name, description, comments } = input;

  return (
    <Section fill title={t('ui.common.input')}>
      <Stack fill vertical>
        <Stack.Item>
          <Box bold color="label">
            {t('ui.common.name')}
          </Box>
          <Input
            fluid
            maxLength={41}
            value={name}
            onChange={(value) => setInput({ ...input, name: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            {t('ui.common.description')}
          </Box>
          <Input
            fluid
            maxLength={500} /* NOVA EDIT: ORIGINAL 100 */
            value={description}
            onChange={(value) => setInput({ ...input, description: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            {t('ui.pai_submit.ooc_comments')}
          </Box>
          <Input
            fluid
            maxLength={500} /* NOVA EDIT: ORIGINAL 100 */
            value={comments}
            onChange={(value) => setInput({ ...input, comments: value })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Gives the user a submit button */
const ButtonsDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { input } = props;
  const { comments, description, name } = input;

  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Button
            onClick={() => act('save', { comments, description, name })}
            tooltip={t('ui.pai_submit.save_tooltip')}
          >
            {t('ui.pai_submit.save')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('load')}
            tooltip={t('ui.pai_submit.load_tooltip')}
          >
            {t('ui.pai_submit.load')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('submit', {
                comments,
                description,
                name,
              })
            }
          >
            {t('ui.pai_submit.submit')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('withdraw')}
            tooltip={t('ui.pai_submit.withdraw_tooltip')}
          >
            {t('ui.pai_submit.withdraw')}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
