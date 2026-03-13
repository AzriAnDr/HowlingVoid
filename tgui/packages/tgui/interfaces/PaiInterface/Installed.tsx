import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { DOOR_JACK, HOST_SCAN, PHOTO_MODE, SOFTWARE_DESC } from './constants';
import type { PaiData } from './types';

const softwareDescriptionKey = (name: string) =>
  `ui.pai_interface.software_desc_${name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')}`;

const getSoftwareDescription = (
  t: (key: string, fallback?: string) => string,
  name: string,
) =>
  t(
    softwareDescriptionKey(name),
    SOFTWARE_DESC[name as keyof typeof SOFTWARE_DESC] ?? name,
  );

/**
 * Renders two sections: A section of buttons and
 * another section that displays the selected installed
 * software info.
 */
export function InstalledDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { t } = usePreferencesLocalization(data);
  const { installed = [] } = data;

  const [currentSelection, setCurrentSelection] = useState('');

  const title = !currentSelection
    ? t('ui.pai_interface.select_program')
    : currentSelection;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title={title}>
          {currentSelection && (
            <Stack fill vertical>
              <Stack.Item>{getSoftwareDescription(t, currentSelection)}</Stack.Item>
              <Stack.Item grow>
                <SoftwareButtons currentSelection={currentSelection} />
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow={2}>
        <Section fill scrollable title={t('ui.pai_interface.installed_software')}>
          {!installed.length ? (
            <NoticeBox>{t('ui.pai_interface.nothing_installed')}</NoticeBox>
          ) : (
            installed.map((software, index) => {
              return (
                <Button
                  key={index}
                  onClick={() => setCurrentSelection(software)}
                >
                  {software}
                </Button>
              );
            })
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type SoftwareButtonsProps = {
  currentSelection: string;
};

/**
 * Once a software is selected, generates custom buttons or a default
 * power toggle.
 */
function SoftwareButtons(props: SoftwareButtonsProps) {
  const { currentSelection } = props;

  const { act, data } = useBackend<PaiData>();
  const { t } = usePreferencesLocalization(data);
  const { door_jack, languages, master_name } = data;

  switch (currentSelection) {
    case 'Door Jack':
      return (
        <>
          <Button
            disabled={!!door_jack}
            icon="plug"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Cable })}
            tooltip={t('ui.pai_interface.tooltip_drops_cable')}
          >
            {t('ui.pai_interface.extend_cable')}
          </Button>
          <Button
            color="bad"
            disabled={!door_jack}
            icon="door-open"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Hack })}
            tooltip={t('ui.pai_interface.tooltip_override_airlock_protocols')}
          >
            {t('ui.pai_interface.hack_door')}
          </Button>
          <Button
            disabled={!door_jack}
            icon="unlink"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Cancel })}
          >
            {t('ui.common.cancel')}
          </Button>
        </>
      );
    case 'Host Scan':
      return (
        <>
          <Button
            icon="hand-holding-heart"
            onClick={() => act(currentSelection, { mode: HOST_SCAN.Target })}
            tooltip={t('ui.pai_interface.tooltip_must_be_held_to_scan')}
          >
            {t('ui.pai_interface.scan_holder')}
          </Button>
          <Button
            disabled={!master_name}
            icon="user-cog"
            onClick={() => act(currentSelection, { mode: HOST_SCAN.Master })}
            tooltip={t('ui.pai_interface.tooltip_scan_bound_masters')}
          >
            {t('ui.pai_interface.scan_master')}
          </Button>
        </>
      );
    case 'Photography Module':
      return (
        <>
          <Button
            icon="camera-retro"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Camera })}
            tooltip={t('ui.pai_interface.tooltip_toggle_camera')}
          >
            {t('ui.pai_interface.camera')}
          </Button>
          <Button
            icon="print"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Printer })}
            tooltip={t('ui.pai_interface.tooltip_stored_photos')}
          >
            {t('ui.pai_interface.printer')}
          </Button>
          <Button
            icon="search-plus"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Zoom })}
            tooltip={t('ui.pai_interface.tooltip_adjust_zoom')}
          >
            {t('ui.pai_interface.zoom')}
          </Button>
        </>
      );
    case 'Universal Translator':
      return (
        <Button
          icon="download"
          onClick={() => act(currentSelection)}
          disabled={!!languages}
        >
          {!languages ? t('ui.common.install') : t('ui.pai_interface.installed')}
        </Button>
      );
    default:
      return (
        <Button
          icon="power-off"
          onClick={() => act(currentSelection)}
          tooltip={t('ui.pai_interface.tooltip_attempt_enable_module')}
        >
          {t('ui.common.toggle')}
        </Button>
      );
  }
}
