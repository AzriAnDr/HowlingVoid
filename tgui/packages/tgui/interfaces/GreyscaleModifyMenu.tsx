import {
  Box,
  Button,
  ColorBox,
  Divider,
  Flex,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import '../styles/interfaces/GreyscaleModifyMenu.scss';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type ColorEntry = {
  index: number;
  value: string;
};

type SpriteData = {
  icon_states: string[];
  finished: string;
  steps: SpriteEntry[];
  time_spent: number;
};

type SpriteEntry = {
  layer: string;
  result: string;
  config_name: string;
};

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: ColorEntry[];
  sprites: SpriteData;
  generate_full_preview: boolean;
  unlocked: boolean;
  monitoring_files: boolean;
  sprites_dir: string;
  icon_state: string;
  refreshing: boolean;
};

enum Direction {
  North = 'north',
  NorthEast = 'northeast',
  East = 'east',
  SouthEast = 'southeast',
  South = 'south',
  SouthWest = 'southwest',
  West = 'west',
  NorthWest = 'northwest',
}

const DirectionAbbreviation: Record<Direction, string> = {
  [Direction.North]: 'N',
  [Direction.NorthEast]: 'NE',
  [Direction.East]: 'E',
  [Direction.SouthEast]: 'SE',
  [Direction.South]: 'S',
  [Direction.SouthWest]: 'SW',
  [Direction.West]: 'W',
  [Direction.NorthWest]: 'NW',
};

const ConfigDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Section title={t('ui.greyscale.designs')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.greyscale.design_type')}>
          <Button icon="cogs" onClick={() => act('select_config')} />
          <Input
            value={data.greyscale_config}
            onBlur={(value) =>
              act('load_config_from_string', { config_string: value })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ColorDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const { t } = usePreferencesLocalization(data);
  const colors = data.colors || [];
  return (
    <Section title={t('ui.common.colors')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.greyscale.full_color_string')}>
          <Button
            icon="dice"
            onClick={() => act('random_all_colors')}
            tooltip={t('ui.greyscale.randomize_all_color_groups')}
          />
          <Input
            value={colors.map((item) => item.value).join('')}
            onBlur={(value) =>
              act('recolor_from_string', { color_string: value })
            }
          />
        </LabeledList.Item>
        {colors.map((item) => (
          <LabeledList.Item
            key={`colorgroup${item.index}${item.value}`}
            label={`Color Group ${item.index}`}
            color={item.value}
          >
            <ColorBox color={item.value} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { color_index: item.index })}
              tooltip={t('ui.greyscale.pick_replace_color_group')}
            />
            <Button
              icon="dice"
              onClick={() => act('random_color', { color_index: item.index })}
              tooltip={t('ui.greyscale.randomize_color_group')}
            />
            <Input
              value={item.value}
              width={7}
              onBlur={(value) =>
                act('recolor', { color_index: item.index, new_color: value })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewCompassSelect = (props) => {
  return (
    <Box>
      <Stack vertical>
        <Flex>
          <SingleDirection dir={Direction.NorthWest} />
          <SingleDirection dir={Direction.North} />
          <SingleDirection dir={Direction.NorthEast} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.West} />
          <Flex.Item grow={1} basis={0}>
            <Button lineHeight={3} m={-0.2} fluid>
              <Icon name="arrows-alt" size={1.5} m="20%" />
            </Button>
          </Flex.Item>
          <SingleDirection dir={Direction.East} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.SouthWest} />
          <SingleDirection dir={Direction.South} />
          <SingleDirection dir={Direction.SouthEast} />
        </Flex>
      </Stack>
    </Box>
  );
};

const SingleDirection = (props) => {
  const { dir } = props;
  const { data, act } = useBackend<GreyscaleMenuData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Flex.Item grow={1} basis={0}>
      <Button
        tooltip={`${t('ui.greyscale.set_preview_direction_prefix')} ${dir}`}
        disabled={`${dir}` === data.sprites_dir}
        textAlign="center"
        onClick={() => act('change_dir', { new_sprite_dir: dir })}
        lineHeight={3}
        m={-0.2}
        fluid
      >
        {DirectionAbbreviation[dir]}
      </Button>
    </Flex.Item>
  );
};

const extractIconSrc = (raw: unknown): string | null => {
  if (!raw) {
    return null;
  }
  const value = String(raw);
  if (!value.includes('<img')) {
    return value;
  }
  const doubleQuoted = value.match(/src="([^"]+)"/i);
  if (doubleQuoted?.[1]) {
    return doubleQuoted[1];
  }
  const singleQuoted = value.match(/src='([^']+)'/i);
  if (singleQuoted?.[1]) {
    return singleQuoted[1];
  }
  return null;
};

const extractIconHtml = (raw: unknown): string | null => {
  if (!raw) {
    return null;
  }
  const value = String(raw);
  return value.includes('<img') ? value : null;
};

const IconStatesDisplay = (props) => {
  const { data, act } = useBackend<GreyscaleMenuData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Section title={t('ui.greyscale.icon_states')}>
      <Flex>
        {data.sprites.icon_states.map((item) => (
          <Flex.Item key={item}>
            <Button
              mx={0.5}
              content={item ? item : 'Blank State'}
              disabled={item === data.icon_state}
              onClick={() => act('select_icon_state', { new_icon_state: item })}
            />
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const PreviewDisplay = (props) => {
  const { data } = useBackend<GreyscaleMenuData>();
  const finishedSrc = extractIconSrc(data.sprites?.finished);
  const finishedHtml = extractIconHtml(data.sprites?.finished);
  return (
    <Section title={`Preview (${data.sprites_dir})`}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <PreviewCompassSelect />
          </Table.Cell>
          {finishedHtml ? (
            <Table.Cell>
              <Box
                m={0}
                mx="10%"
                width="75%"
                dangerouslySetInnerHTML={{ __html: finishedHtml }}
              />
            </Table.Cell>
          ) : finishedSrc ? (
            <Table.Cell>
              <Image m={0} mx="10%" src={finishedSrc} width="75%" />
            </Table.Cell>
          ) : (
            <Table.Cell>
              <Box>
                <Icon name="image" ml="25%" size={5} />
              </Box>
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
      {!!data.unlocked && `Time Spent: ${data.sprites.time_spent}ms`}
      <Divider />
      {!data.refreshing && (
        <Table>
          {!!data.generate_full_preview && data.sprites.steps !== null && (
            <Table.Row header>
              <Table.Cell width="50%" textAlign="center">
                Layer Source
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Step Layer
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Step Result
              </Table.Cell>
            </Table.Row>
          )}
          {!!data.generate_full_preview &&
            data.sprites.steps !== null &&
            data.sprites.steps.map((item) => (
              <Table.Row key={`${item.result}|${item.layer}`}>
                <Table.Cell verticalAlign="middle">
                  {item.config_name}
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.layer} />
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.result} />
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      )}
    </Section>
  );
};

const SingleSprite = (props) => {
  const { source } = props;
  const parsedHtml = extractIconHtml(source);
  const parsedSource = extractIconSrc(source);
  if (parsedHtml) {
    return <Box dangerouslySetInnerHTML={{ __html: parsedHtml }} />;
  }
  if (!parsedSource) {
    return <Icon name="image" />;
  }
  return <Image src={parsedSource} />;
};

const LoadingAnimation = () => {
  return (
    <Box height={0} mt="-100%">
      <Icon name="cog" height={22.7} opacity={0.5} size={25} spin />
    </Box>
  );
};

export const GreyscaleModifyMenu = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window title={t('ui.greyscale.color_configuration')} width={325} height={800}>
      <Window.Content scrollable>
        <Box className="GreyscaleModifyMenu">
          <ConfigDisplay />
          <ColorDisplay />
          <IconStatesDisplay />
          <Flex direction="column">
            {!!data.unlocked && (
              <Flex.Item justify="flex-start">
                <Button
                  className="GreyscaleModifyMenu__ActionButton"
                  content={
                    <Icon name="file-image-o" spin={data.monitoring_files} />
                  }
                  tooltip={t('ui.greyscale.tooltip_toggle_mass_refresh')}
                  selected={data.monitoring_files}
                  onClick={() => act('toggle_mass_refresh')}
                  width={1.9}
                  mr={-0.2}
                />
                <Button
                  className="GreyscaleModifyMenu__ActionButton"
                  content={t('ui.greyscale.refresh_icon_file')}
                  tooltip={t('ui.greyscale.tooltip_refresh_icon_file')}
                  onClick={() => act('refresh_file')}
                />
                <Button
                  className="GreyscaleModifyMenu__ActionButton"
                  content={t('ui.greyscale.save_icon_file')}
                  tooltip={t('ui.greyscale.tooltip_save_icon_file')}
                  onClick={() => act('save_dmi')}
                />
              </Flex.Item>
            )}
            <Flex.Item>
              <Button
                className="GreyscaleModifyMenu__ActionButton"
                content={t('ui.common.apply')}
                tooltip={t('ui.greyscale.tooltip_apply')}
                color="red"
                onClick={() => act('apply')}
              />
              <Button.Checkbox
                className="GreyscaleModifyMenu__ActionButton"
                content={t('ui.greyscale.full_preview')}
                tooltip={t('ui.greyscale.tooltip_full_preview')}
                disabled={!data.generate_full_preview && !data.unlocked}
                checked={data.generate_full_preview}
                onClick={() => act('toggle_full_preview')}
              />
            </Flex.Item>
          </Flex>
          <PreviewDisplay />
          {!!data.refreshing && <LoadingAnimation />}
        </Box>
      </Window.Content>
    </Window>
  );
};
