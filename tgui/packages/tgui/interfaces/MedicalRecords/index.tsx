import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Icon, NoticeBox, Stack } from 'tgui-core/components';

import { MedicalRecordTabs } from './RecordTabs';
import { MedicalRecordView } from './RecordView';
import type { MedicalRecordData } from './types';
import { usePreferencesLocalization } from '../localization';

export const MedicalRecords = (props) => {
  const { data } = useBackend<MedicalRecordData>();
  const { t } = usePreferencesLocalization(data);
  const { authenticated } = data;

  return (
    <Window title={t('ui.medical_records.title')} width={750} height={550}>
      <Window.Content>
        <Stack fill>
          {!authenticated ? <UnauthorizedView /> : <AuthView />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const UnauthorizedView = (props) => {
  const { act, data } = useBackend<MedicalRecordData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Stack.Item grow>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow={2}>
          <Icon color="teal" name="staff-snake" size={15} />
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Box color="good" fontSize="18px" bold mt={5}>
            Nanotrasen HealthPRO
          </Box>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox align="right">
            {t('ui.medical_records.not_logged_in')}
            <Button ml={2} icon="lock-open" onClick={() => act('login')}>
              {t('ui.common.login')}
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const AuthView = (props) => {
  const { act, data } = useBackend<MedicalRecordData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <>
      <Stack.Item grow>
        <MedicalRecordTabs />
      </Stack.Item>
      <Stack.Item grow={2}>
        <Stack fill vertical>
          <Stack.Item grow>
            <MedicalRecordView />
          </Stack.Item>
          <Stack.Item>
            <NoticeBox align="right" info>
              {t('ui.medical_records.secure_workspace')}
              <Button
                align="right"
                icon="lock"
                color="good"
                ml={2}
                onClick={() => act('logout')}
              >
                {t('ui.common.log_out')}
              </Button>
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};
