import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Dropdown,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Song = {
  name: string;
  length: number;
  beat: number;
};

type Data = {
  active: BooleanLike;
  looping: BooleanLike;
  volume: number;
  track_selected: string | null;
  songs: Song[];
};

export const Jukebox = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { active, looping, track_selected, volume, songs } = data;

  const songs_sorted: Song[] = sortBy(songs, [(song: Song) => song.name]);
  const song_selected: Song | undefined = songs.find(
    (song) => song.name === track_selected,
  );

  return (
    <Window width={370} height={313}>
      <Window.Content>
        <Section
          title={t('ui.jukebox.song_player')}
          buttons={
            <>
              <Button
                icon={active ? 'pause' : 'play'}
                content={active ? t('ui.common.stop') : t('ui.common.play')}
                selected={active}
                onClick={() => act('toggle')}
              />
              <Button.Checkbox
                icon={'arrow-rotate-left'}
                content={t('ui.common.repeat')}
                disabled={active}
                checked={looping}
                onClick={() => act('loop', { looping: !looping })}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.jukebox.track_selected')}>
              <Dropdown
                width="240px"
                options={songs_sorted.map((song) => song.name)}
                disabled={!!active}
                selected={song_selected?.name || t('ui.jukebox.select_track')}
                onSelected={(value) =>
                  act('select_track', {
                    track: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.jukebox.track_length')}>
              {song_selected?.length || t('ui.jukebox.no_track_selected')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.jukebox.track_beat')}>
              {song_selected?.beat || t('ui.jukebox.no_track_selected')}
              {song_selected?.beat === 1
                ? ` ${t('ui.jukebox.beat')}`
                : ` ${t('ui.jukebox.beats')}`}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.common.settings')}>
          <LabeledControls justify="center">
            <LabeledControls.Item label={t('ui.common.volume')}>
              <Box position="relative">
                <Knob
                  size={3.2}
                  color={volume >= 25 ? 'red' : 'green'}
                  value={volume}
                  unit="%"
                  minValue={0}
                  maxValue={50}
                  step={1}
                  stepPixelSize={1}
                  onChange={(e, value) =>
                    act('set_volume', {
                      volume: value,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-22px"
                  color="transparent"
                  icon="fast-backward"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'min',
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-22px"
                  color="transparent"
                  icon="fast-forward"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'max',
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="34px"
                  right="-22px"
                  color="transparent"
                  icon="undo"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'reset',
                    })
                  }
                />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
