import {
  Box,
  Button,
  Collapsible,
  Divider,
  Dropdown,
  NumberInput,
  Section,
  Stack,
  Input,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  id: string;
  using_instrument: string;
  note_shift_min: number;
  note_shift_max: number;
  note_shift: number;
  octaves: number;
  sustain_modes: string[];
  sustain_mode: string;
  sustain_mode_button: string;
  sustain_mode_duration: number;
  instrument_ready: BooleanLike;
  volume: number;
  volume_dropoff_threshold: number;
  min_volume: number;
  max_volume: number;
  sustain_indefinitely: BooleanLike;
  sustain_mode_min: number;
  sustain_mode_max: number;
  playing: BooleanLike;
  max_repeats: number;
  repeat: number;
  bpm: number;
  lines: LineData[];
  can_switch_instrument: BooleanLike;
  possible_instruments: InstrumentData[];
  max_line_chars: number;
  max_lines: number;
};

type InstrumentData = {
  name: string;
  id: string;
};

type LineData = {
  line_count: number;
  line_text: string;
};

export const InstrumentEditor = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Window width={750} height={500}>
      <Window.Content scrollable>
        <InstrumentSettings />
        <Collapsible open title={t('ui.instrument_editor.music_editor')} icon="pencil">
          <EditingSettings />
        </Collapsible>
        <Collapsible title={t('ui.instrument_editor.help_section')} icon="question">
          <HelpSection />
        </Collapsible>
      </Window.Content>
    </Window>
  );
};

const InstrumentSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    id,
    playing,
    repeat,
    max_repeats,
    can_switch_instrument,
    possible_instruments = [],
    instrument_ready,
    using_instrument,
    note_shift_min,
    note_shift_max,
    note_shift,
    octaves,
    sustain_modes,
    sustain_mode,
    sustain_mode_button,
    sustain_mode_duration,
    sustain_indefinitely,
    sustain_mode_min,
    sustain_mode_max,
    volume,
    min_volume,
    max_volume,
    volume_dropoff_threshold,
    lines,
  } = data;

  const instrument_id_by_name = (name) => {
    return possible_instruments.find((instrument) => instrument.name === name)
      ?.id;
  };

  return (
    <Section title={t('ui.instrument_editor.settings')}>
      {lines.length > 0 && (
        <Box fontSize="16px" mb={1}>
          <Button onClick={() => act('play_music')}>
            {playing ? 'Stop Music' : 'Start Playing'}
          </Button>
        </Box>
      )}
      <Box>
        <Box
          inline
          style={{
            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
          }}
          mr={1}
        >
          <Tooltip
            content="All nearby instruments with the same ID will
               start playing the same song when any one starts playing."
          >
            ID:
          </Tooltip>
        </Box>
        <Input
          value={id}
          maxLength={20}
          onChange={(value) => act('set_instrument_id', { id: value })}
        />
      </Box>
      <Box>
        Repeats Left:
        <NumberInput
          ml={1}
          step={1}
          minValue={0}
          disabled={!!playing}
          maxValue={max_repeats}
          value={repeat}
          onChange={(value) =>
            act('set_repeat_amount', {
              amount: value,
            })
          }
        />
      </Box>
      <Box>
        {!!can_switch_instrument && (
          <Stack fill>
            <Stack.Item mt={0.5}>{t('ui.instrument_editor.instrument_using')}</Stack.Item>
            <Stack.Item grow>
              <Dropdown
                width="40%"
                selected={using_instrument}
                disabled={!can_switch_instrument}
                options={possible_instruments.map(
                  (instrument) => instrument.name,
                )}
                onSelected={(value) =>
                  act('change_instrument', {
                    new_instrument: instrument_id_by_name(value),
                  })
                }
              />
            </Stack.Item>
          </Stack>
        )}
      </Box>
      <Stack mt={1}>
        <Stack.Item>
          Playback Settings:
          <Box>
            <NumberInput
              minValue={note_shift_min}
              maxValue={note_shift_max}
              step={1}
              value={note_shift}
              onChange={(value) =>
                act('set_note_shift', {
                  amount: value,
                })
              }
            />
            keys / {octaves} octaves
          </Box>
          <Stack>
            <Stack.Item mt={0.5}>{t('ui.instrument_editor.mode')}</Stack.Item>
            <Stack.Item grow>
              <Dropdown
                width="100%"
                selected={sustain_mode}
                options={sustain_modes}
                onSelected={(value) =>
                  act('set_sustain_mode', {
                    new_mode: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
          <Box>
            {sustain_mode_button}:
            <NumberInput
              ml={1}
              step={1}
              minValue={sustain_mode_min}
              maxValue={sustain_mode_max}
              value={sustain_mode_duration}
              onChange={(value) =>
                act('edit_sustain_mode', {
                  amount: value,
                })
              }
            />
          </Box>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item>
          <Box>
            Status:
            {instrument_ready ? (
              <span style={{ color: '#5EFB6E' }}> {t('ui.common.ready')}</span>
            ) : (
              <span style={{ color: '#FF0000' }}>
                {' '}
                Instrument Definition Error!
              </span>
            )}
          </Box>
          <Box>
            Volume:
            <NumberInput
              step={1}
              minValue={min_volume}
              maxValue={max_volume}
              value={volume}
              onChange={(value) =>
                act('set_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            Volume Dropoff Threshold:
            <NumberInput
              step={1}
              minValue={1}
              maxValue={100}
              value={volume_dropoff_threshold}
              onChange={(value) =>
                act('set_dropoff_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            <Button onClick={() => act('toggle_sustain_hold_indefinitely')}>
              {sustain_indefinitely
                ? 'Sustaining last held note indefinitely'
                : 'Not sustaining last held note indefinitely'}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EditingSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { bpm, lines } = data;

  return (
    <Section>
      <Box>
        <Button onClick={() => act('start_new_song')}>{t('ui.instrument_editor.start_new_song')}</Button>
        <Button onClick={() => act('import_song')}>{t('ui.instrument_editor.import_song')}</Button>
      </Box>
      <Box>
        Tempo:{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'increase_speed' })}
        >
          -
        </Button>{' '}
        {bpm} BPM{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'decrease_speed' })}
        >
          +
        </Button>
      </Box>
      <Box>
        {lines.map((line, index) => (
          <Box key={index} fontSize="11px">
            Line {index}:
            <Button
              onClick={() =>
                act('modify_line', { line_editing: line.line_count })
              }
            >
              Edit
            </Button>
            <Button
              onClick={() =>
                act('delete_line', { line_deleted: line.line_count })
              }
            >
              X
            </Button>
            {line.line_text}
          </Box>
        ))}
      </Box>
      <Box>
        <Button onClick={() => act('add_new_line')}>{t('ui.instrument_editor.add_line')}</Button>
      </Box>
    </Section>
  );
};

const HelpSection = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { max_line_chars, max_lines } = data;

  return (
    <Section>
      <Box>
        Lines are a series of chords, separated by commas (,), each with notes
        separated by hyphens (-).
        <br />
        Every note in a chord will play together, with chord timed by the tempo.
        <br />
        Notes are played by the names of the note, and optionally, the
        accidental, and/or the octave number.
        <br />
        By default, every note is natural and in octave 3. Defining otherwise is
        remembered for each note.
        <br />
        {t('ui.instrument_editor.example')}: <i>{t('ui.instrument_editor.example_scale')}</i> {t('ui.instrument_editor.will_play_c_major_scale')}
        <br />
        {t('ui.instrument_editor.accidental_remembered')}{' '}
        <i>{t('ui.instrument_editor.example_accidental_input')}</i> {t('ui.instrument_editor.is')}{' '}
        <i>{t('ui.instrument_editor.example_accidental_output')}</i>
        <br />
        {t('ui.instrument_editor.chords_by_hyphen')}{' '}
        <i>{t('ui.instrument_editor.example_chords')}</i>
        <br />{t('ui.instrument_editor.pause_empty_chord')} <i>{t('ui.instrument_editor.example_pause')}</i>
        <br />
        To make a chord be a different time, end it with /x, where the chord
        length will be length
        <br />{t('ui.instrument_editor.defined_by_tempo')}{' '}
        <i>{t('ui.instrument_editor.example_tempo')}</i>
        <br />{t('ui.instrument_editor.combined_example')}{' '}
        <i>{t('ui.instrument_editor.example_combined')}</i>
        <br />
        Lines may be up to {max_line_chars} characters.
        <br />A song may only contain up to {max_lines} lines.
        <br />
      </Box>
    </Section>
  );
};
