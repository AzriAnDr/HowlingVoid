import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type AdminhelpData = {
  adminCount: number;
  urgentAhelpEnabled: BooleanLike;
  bannedFromUrgentAhelp: BooleanLike;
  urgentAhelpPromptMessage: string;
};

export const Adminhelp = (props) => {
  const { act, data } = useBackend<AdminhelpData>();
  const { t } = usePreferencesLocalization(data);
  const {
    adminCount,
    urgentAhelpEnabled,
    bannedFromUrgentAhelp,
    urgentAhelpPromptMessage,
  } = data;
  const [requestForAdmin, setRequestForAdmin] = useState(false);
  const [currentlyInputting, setCurrentlyInputting] = useState(false);
  const [ahelpMessage, setAhelpMessage] = useState('');

  const confirmationText = 'alert admins';
  return (
    <Window
      title={t('ui.adminhelp.window_title')}
      theme="admin"
      height={300}
      width={500}
    >
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item grow>
            <TextArea
              autoFocus
              height="100%"
              fluid
              placeholder={t('ui.adminhelp.placeholder')}
              onChange={setAhelpMessage}
            />
          </Stack.Item>
          {urgentAhelpEnabled && adminCount <= 0 && (
            <Stack.Item>
              <NoticeBox info>
                {urgentAhelpPromptMessage}
                {currentlyInputting ? (
                  <Box
                    mt={1}
                    width="100%"
                    fontFamily="arial"
                    backgroundColor="grey"
                    style={{
                      fontStyle: 'normal',
                    }}
                  >
                    {t('ui.adminhelp.confirmation_hint').replace(
                      '{text}',
                      confirmationText,
                    )}
                    <Input
                      placeholder={t('ui.adminhelp.confirmation_input')}
                      autoFocus
                      fluid
                      onChange={(value) => {
                        if (value === confirmationText) {
                          setRequestForAdmin(true);
                          setCurrentlyInputting(false);
                        }
                      }}
                    />
                  </Box>
                ) : (
                  <Button
                    mt={1}
                    onClick={() => {
                      if (requestForAdmin) {
                        setRequestForAdmin(false);
                      } else {
                        setCurrentlyInputting(true);
                      }
                    }}
                    color={requestForAdmin ? 'orange' : 'blue'}
                    icon={requestForAdmin ? 'check-square-o' : 'square-o'}
                    disabled={bannedFromUrgentAhelp}
                    tooltip={
                      bannedFromUrgentAhelp
                        ? t('ui.adminhelp.urgent_banned')
                        : undefined
                    }
                    fluid
                    textAlign="center"
                  >
                    {t('ui.adminhelp.alert_admins')}
                  </Button>
                )}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              color="good"
              fluid
              textAlign="center"
              onClick={() =>
                act('ahelp', {
                  urgent: requestForAdmin,
                  message: ahelpMessage,
                })
              }
            >
              {t('ui.adminhelp.submit')}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
