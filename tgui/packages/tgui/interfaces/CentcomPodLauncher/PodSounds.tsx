import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { SOUNDS } from './constants';
import type { PodLauncherData } from './types';

export function PodSounds(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { t } = usePreferencesLocalization(data);
  const { defaultSoundVolume, soundVolume } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          icon="volume-up"
          onClick={() => act('soundVolume')}
          selected={soundVolume !== defaultSoundVolume}
          tooltip={t('ui.centcom_pod_launcher.sound_volume').replace(
            '{volume}',
            String(soundVolume),
          )}
          tooltipPosition="top-start"
        />
      }
      fill
      title={t('ui.centcom_pod_launcher.sounds')}
    >
      {SOUNDS.map((sound, i) => (
        <Button
          key={i}
          onClick={() => act(sound.act)}
          selected={data[sound.act]}
          tooltip={sound.tooltip}
          tooltipPosition="top-start"
        >
          {sound.title}
        </Button>
      ))}
    </Section>
  );
}
