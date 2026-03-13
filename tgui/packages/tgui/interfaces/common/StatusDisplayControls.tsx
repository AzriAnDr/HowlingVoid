import { Button, Flex, Input, Section } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { usePreferencesLocalization } from '../localization';

type Data = {
  upperText: string;
  lowerText: string;
  maxStatusLineLength: number;
};

export function StatusDisplayControls(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    upperText: initialUpper,
    lowerText: initialLower,
    maxStatusLineLength,
  } = data;

  const [upperText, setUpperText] = useSharedState(
    'statusUpperText',
    initialUpper,
  );
  const [lowerText, setLowerText] = useSharedState(
    'statusLowerText',
    initialLower,
  );

  return (
    <>
      <Section>
        <Button
          icon="toggle-off"
          color="bad"
          onClick={() => act('setStatusPicture', { picture: 'blank' })}
        >
          {t('ui.common.off')}
        </Button>
        <Button
          icon="space-shuttle"
          color=""
          onClick={() => act('setStatusPicture', { picture: 'shuttle' })}
        >
          {t('ui.status_display.shuttle_eta_off')}
        </Button>
      </Section>

      <Section title={t('ui.status_display.graphics')}>
        <Button
          icon="flag"
          onClick={() => act('setStatusPicture', { picture: 'default' })}
        >
          {t('ui.status_display.logo')}
        </Button>

        <Button
          icon="exclamation"
          onClick={() => act('setStatusPicture', { picture: 'currentalert' })}
        >
          {t('ui.status_display.security_alert_level')}
        </Button>

        <Button
          icon="exclamation-triangle"
          onClick={() => act('setStatusPicture', { picture: 'lockdown' })}
        >
          {t('ui.status_display.lockdown')}
        </Button>

        <Button
          icon="biohazard"
          onClick={() => act('setStatusPicture', { picture: 'biohazard' })}
        >
          {t('ui.status_display.biohazard')}
        </Button>

        <Button
          icon="radiation"
          onClick={() => act('setStatusPicture', { picture: 'radiation' })}
        >
          {t('ui.status_display.radiation')}
        </Button>
      </Section>

      <Section title={t('ui.common.message')}>
        <Flex direction="column" align="stretch">
          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={upperText}
              onChange={setUpperText}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={lowerText}
              onChange={setLowerText}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              onClick={() => act('setStatusMessage', { upperText, lowerText })}
            >
              {t('ui.common.send')}
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </>
  );
}
