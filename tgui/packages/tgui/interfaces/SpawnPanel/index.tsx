import { useEffect, useState } from 'react';
import { Button, Modal, Section, Stack } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { usePreferencesLocalization } from '../localization';
import { CreateObject } from './CreateObject';
import { CreateObjectAdvancedSettings } from './CreateObjectAdvancedSettings';
import type { CreateObjectData } from './types';

export interface IconSettings {
  icon: string | null;
  iconState: string | null;
  iconSize: number;
  applyIcon?: boolean;
}

export function SpawnPanel() {
  const { t } = usePreferencesLocalization();
  const [data, setData] = useState<CreateObjectData | undefined>();
  const [advancedSettings, setAdvancedSettings] = useState(false);
  const [iconSettings, setIconSettings] = useState<IconSettings>({
    icon: null,
    iconState: null,
    iconSize: 100,
    applyIcon: false,
  });

  useEffect(() => {
    fetchRetry(resolveAsset('spawnpanel_atom_data.json'))
      .then((response) => response.json())
      .then(setData)
      .catch((error) => {
        logger.log(
          'Failed to fetch spawnpanel_atom_data.json',
          JSON.stringify(error),
        );
      });
  }, []);

  const handleIconSettingsChange = (newSettings: Partial<IconSettings>) => {
    setIconSettings((current) => ({
      ...current,
      ...newSettings,
    }));
  };

  return (
    <Window
      height={550}
      title={t('ui.spawn_panel.title')}
      width={530}
      theme="admin"
    >
      <Window.Content>
        {advancedSettings && (
          <Modal
            style={{
              padding: '6px',
              width: '30em',
              marginTop: '-15em',
            }}
          >
            <Section
              title={t('ui.spawn_panel.advanced_settings')}
              buttons={
                <Button
                  color="transparent"
                  icon="close"
                  onClick={() => setAdvancedSettings(false)}
                />
              }
            >
              <CreateObjectAdvancedSettings
                iconSettings={iconSettings}
                onIconSettingsChange={handleIconSettingsChange}
              />
            </Section>
          </Modal>
        )}
        <Stack vertical fill>
          <Stack.Item grow>
            {data && (
              <CreateObject
                objList={data}
                setAdvancedSettings={setAdvancedSettings}
                iconSettings={iconSettings}
                onIconSettingsChange={handleIconSettingsChange}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
