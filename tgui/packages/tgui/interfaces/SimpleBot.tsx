import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Button,
  Icon,
  LabeledControls,
  NoticeBox,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';
import { usePreferencesLocalization } from './localization';

type Data = {
  can_hack: BooleanLike;
  custom_controls: Record<string, number>;
  emagged: BooleanLike;
  has_access: BooleanLike;
  locked: BooleanLike;
  settings: Settings;
};

type Settings = {
  airplane_mode: BooleanLike;
  allow_possession: BooleanLike;
  has_personality: BooleanLike;
  maintenance_lock: BooleanLike;
  pai_inserted: boolean;
  patrol_station: BooleanLike;
  possession_enabled: BooleanLike;
  power: BooleanLike;
};

export function SimpleBot(props) {
  const { data } = useBackend<Data>();
  const { can_hack, locked } = data;
  const access = !locked || !!can_hack;

  return (
    <Window width={450} height={300}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BotSettings />
          </Stack.Item>
          {!!access && (
            <Stack.Item grow>
              <BotControl />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

export function BotSettings(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { can_hack, locked } = data;
  const access = !locked || !!can_hack;
  return (
    <Section title={t('ui.common.settings')} buttons={<TabDisplay />}>
      {!access ? <NoticeBox>{t('ui.common.locked')}</NoticeBox> : <SettingsDisplay />}
    </Section>
  );
}

export function BotControl(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { custom_controls } = data;
  return (
    <Section fill scrollable title={t('ui.common.controls')}>
      <LabeledControls wrap>
        {Object.entries(custom_controls).map((control) => (
          <LabeledControls.Item
            pb={2}
            key={control[0]}
            label={capitalizeAll(control[0].replace('_', ' '))}
          >
            <ControlHelper control={control} />
          </LabeledControls.Item>
        ))}
      </LabeledControls>
    </Section>
  );
}
/** Creates a lock button at the top of the controls */
function TabDisplay(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    can_hack,
    emagged,
    has_access,
    locked,
    settings: { allow_possession },
  } = data;

  return (
    <>
      {!!can_hack && (
        <Button
          color="danger"
          disabled={!can_hack}
          icon={emagged ? 'bug' : 'lock'}
          onClick={() => act('hack')}
          selected={!emagged}
          tooltip={
            !emagged
              ? t('ui.simple_bot.unlocks_safety_protocols')
              : t('ui.simple_bot.resets_bot_operating_system')
          }
        >
          {emagged ? t('ui.simple_bot.malfunctional') : t('ui.simple_bot.safety_lock')}
        </Button>
      )}
      {!!allow_possession && <PaiButton />}
      <Button
        color="transparent"
        icon="fa-poll-h"
        onClick={() => act('rename')}
        tooltip={t('ui.simple_bot.update_name_registration')}
      >
        {t('ui.common.rename')}
      </Button>
      <Button
        color="transparent"
        disabled={!has_access && !can_hack}
        icon={locked ? 'lock' : 'lock-open'}
        onClick={() => act('lock')}
        selected={locked}
        tooltip={`${locked ? t('ui.common.unlock') : t('ui.common.lock')} ${t('ui.simple_bot.control_panel')}.`}
      >
        {t('ui.simple_bot.controls_lock')}
      </Button>
    </>
  );
}

/** Creates a button indicating PAI status and offers the eject action */
function PaiButton(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    settings: { pai_inserted },
  } = data;

  if (!pai_inserted) {
    return (
      <Button
        color="transparent"
        icon="robot"
        tooltip={t('ui.simple_bot.insert_active_pai_card')}
      >
        {t('ui.simple_bot.no_pai_inserted')}
      </Button>
    );
  }

  return (
    <Button
      disabled={!pai_inserted}
      icon="eject"
      onClick={() => act('eject_pai')}
      tooltip={t('ui.simple_bot.ejects_current_pai')}
    >
      {t('ui.simple_bot.eject_pai')}
    </Button>
  );
}

/** Displays the bot's standard settings: Power, patrol, etc. */
function SettingsDisplay(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    settings: {
      airplane_mode,
      patrol_station,
      power,
      maintenance_lock,
      allow_possession,
      possession_enabled,
    },
  } = data;

  return (
    <LabeledControls>
      <LabeledControls.Item label={t('ui.common.power')}>
        <Tooltip
          content={
            power
              ? t('ui.simple_bot.powers_off_bot')
              : t('ui.simple_bot.powers_on_bot')
          }
        >
          <Icon
            size={2}
            name="power-off"
            color={power ? 'good' : 'gray'}
            onClick={() => act('power')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label={t('ui.simple_bot.airplane_mode')}>
        <Tooltip
          content={
            !airplane_mode
              ? t('ui.simple_bot.disables_remote_access')
              : t('ui.simple_bot.enables_remote_access')
          }
        >
          <Icon
            size={2}
            name="plane"
            color={airplane_mode ? 'yellow' : 'gray'}
            onClick={() => act('airplane')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label={t('ui.simple_bot.patrol_station')}>
        <Tooltip
          content={
            patrol_station
              ? t('ui.simple_bot.disables_automatic_patrol')
              : t('ui.simple_bot.enables_automatic_patrol')
          }
        >
          <Icon
            size={2}
            name="map-signs"
            color={patrol_station ? 'good' : 'gray'}
            onClick={() => act('patrol')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label={t('ui.simple_bot.maintenance_lock')}>
        <Tooltip
          content={
            maintenance_lock
              ? t('ui.simple_bot.opens_maintenance_hatch')
              : t('ui.simple_bot.closes_maintenance_hatch')
          }
        >
          <Icon
            size={2}
            name="toolbox"
            color={maintenance_lock ? 'yellow' : 'gray'}
            onClick={() => act('maintenance')}
          />
        </Tooltip>
      </LabeledControls.Item>
      {!!allow_possession && (
        <LabeledControls.Item label={t('ui.simple_bot.personality')}>
          <Tooltip
            content={
              possession_enabled
                ? t('ui.simple_bot.resets_personality_factory_default')
                : t('ui.simple_bot.enables_personality_download')
            }
          >
            <Icon
              size={2}
              name="robot"
              color={possession_enabled ? 'good' : 'gray'}
              onClick={() => act('toggle_personality')}
            />
          </Tooltip>
        </LabeledControls.Item>
      )}
    </LabeledControls>
  );
}

enum ControlType {
  MedbotThreshold = 'heal_threshold',
  FloorbotTiles = 'tile_stack',
  FloorbotLine = 'line_mode',
}

type ControlProps = {
  control: [string, number];
};

/** Helper function which identifies which button to create.
 * Might need some fine tuning if you are using more advanced controls.
 */
function ControlHelper(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { control } = props;

  switch (control[0]) {
    case ControlType.MedbotThreshold:
      return <MedbotThreshold control={control} />;
    case ControlType.FloorbotTiles:
      return <FloorbotTiles control={control} />;
    case ControlType.FloorbotLine:
      return <FloorbotLine control={control} />;
    default:
      return (
        <Icon
          color={control[1] ? 'good' : 'gray'}
          name={control[1] ? 'toggle-on' : 'toggle-off'}
          size={2}
          onClick={() => act(control[0])}
        />
      );
  }
}

/** Slider button for medbot healing thresholds */
function MedbotThreshold(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const { control } = props;

  return (
    <Tooltip content={t('ui.simple_bot.adjusts_damage_treatment_sensitivity')}>
      <Slider
        minValue={5}
        maxValue={75}
        ranges={{
          good: [-Infinity, 15],
          average: [15, 55],
          bad: [55, Infinity],
        }}
        step={5}
        unit="%"
        value={control[1]}
        onChange={(_, value) => act(control[0], { threshold: value })}
      />
    </Tooltip>
  );
}

/** Tile stacks for floorbots - shows number and eject button */
function FloorbotTiles(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const { control } = props;

  return (
    <Button
      disabled={!control[1]}
      icon={control[1] ? 'eject' : ''}
      onClick={() => act('eject_tiles')}
      tooltip={t('ui.simple_bot.floor_tiles_count_tooltip')}
    >
      {control[1] ? `${control[1]}` : t('ui.common.empty')}
    </Button>
  );
}

/** Direction indicator for floorbot when line mode is chosen. */
function FloorbotLine(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const { control } = props;

  return (
    <Tooltip content={t('ui.simple_bot.enables_straight_line_tiling')}>
      <Icon
        color={control[1] ? 'good' : 'gray'}
        name={control[1] ? 'compass' : 'toggle-off'}
        onClick={() => act('line_mode')}
        size={!control[1] ? 2 : 1.5}
      />
      {control[1] ? control[1].toString().charAt(0).toUpperCase() : ''}
    </Tooltip>
  );
}
