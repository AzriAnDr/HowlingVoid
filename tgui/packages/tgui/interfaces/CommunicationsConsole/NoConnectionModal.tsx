import { Blink, Dimmer, Flex, Icon } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';

export function NoConnectionModal() {
  const { t } = usePreferencesLocalization();
  return (
    <Dimmer>
      <Flex direction="column" textAlign="center" width="300px">
        <Flex.Item>
          <Icon color="red" name="wifi" size={10} />

          <Blink>
            <div
              style={{
                background: '#db2828',
                bottom: '60%',
                left: '25%',
                height: '10px',
                position: 'relative',
                transform: 'rotate(45deg)',
                width: '150px',
              }}
            />
          </Blink>
        </Flex.Item>

        <Flex.Item fontSize="16px">
          {t('ui.communications_console.connection_to_station_cannot_be_established')}
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
}
