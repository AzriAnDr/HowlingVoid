// THIS IS A NOVA SECTOR UI FILE
import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const MicrofusionGunControl = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { current_players, servers = [] } = data;
  return (
    <Window title={t('ui.server_control_panel.title')} width={500} height={700}>
      <Window.Content>
        {servers.len === 0 ? (
          <NoticeBox>{t('ui.server_control_panel.no_server_online')}</NoticeBox>
        ) : (
          servers.map((server) => (
            <Section
              key={server.name}
              title={server.name}
              buttons={
                <Button
                  icon="connect"
                  content={t('ui.server_control_panel.connect')}
                  onClick={() =>
                    act('connect', {
                      server_ref: server.name,
                    })
                  }
                />
              }
            >
              <LabeledList>
                <LabeledList.Item label={t('ui.common.players')}>
                  {server.players}/{server.max_players}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))
        )}
      </Window.Content>
    </Window>
  );
};
