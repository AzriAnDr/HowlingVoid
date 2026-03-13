// THIS IS A NOVA SECTOR UI FILE
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const CryopodConsole = (props) => {
  const { t } = usePreferencesLocalization();
  const { data } = useBackend();
  const { account_name } = data;

  const welcomeTitle = `${t('ui.cryopod.hello')}, ${account_name || t('ui.cryopod.redacted')}!`;

  return (
    <Window title={t('ui.cryopod.title')} width={420} height={480}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title={welcomeTitle}>
              {t('ui.cryopod.description')}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <CrewList />
          </Stack.Item>
          <Stack.Item grow>
            <ItemList />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewList = () => {
  const { t } = usePreferencesLocalization();
  const { data } = useBackend();
  const { frozen_crew } = data;

  if (!frozen_crew?.length) {
    return <NoticeBox>{t('ui.cryopod.no_stored_crew')}</NoticeBox>;
  }

  return (
    <Section fill scrollable>
      <Stack vertical>
        {frozen_crew.map((person) => (
          <Stack.Item key={person.name}>
            <Stack fill align="center">
              {/* Label (left) */}
              <Stack.Item grow>
                <span
                  style={{
                    color: 'var(--color-label)', // to match bottom part
                    whiteSpace: 'normal',
                    overflowWrap: 'break-word',
                  }}
                >
                  {person.name}
                </span>
              </Stack.Item>

              {/* Value (right, fixed column like buttons) */}
              <Stack.Item
                style={{
                  minWidth: '90px',
                  textAlign: 'right',
                }}
              >
                {person.job}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const ItemList = () => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const { item_ref_list, item_ref_name, item_retrieval_allowed } = data;

  if (!item_retrieval_allowed) {
    return <NoticeBox>{t('ui.cryopod.not_authorized_item_management')}</NoticeBox>;
  }

  if (!item_ref_list?.length) {
    return <NoticeBox>{t('ui.cryopod.no_stored_items')}</NoticeBox>;
  }

  return (
    <Section fill scrollable>
      <LabeledList>
        {item_ref_list.map((item) => (
          <LabeledList.Item
            key={item}
            label={
              <span
                style={{
                  whiteSpace: 'normal',
                  overflowWrap: 'break-word',
                }}
              >
                {item_ref_name[item]}
              </span>
            }
          >
            <Stack justify="end">
              <Stack.Item>
                <Button
                  icon="exclamation-circle"
                  content={t('ui.common.retrieve')}
                  color="bad"
                  onClick={() => act('item_get', { item_get: item })}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
