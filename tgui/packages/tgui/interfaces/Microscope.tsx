import {
  Box,
  Button,
  Divider,
  DmIcon,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  has_dish: BooleanLike;
  cell_lines: CellLine[];
};

type CellLine = {
  type: string;
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  consumption_rate: number;
  growth_rate: number;
  suspectibility: number;
  requireds: Record<string, number>;
  supplementaries: Record<string, number>;
  suppressives: Record<string, number>;
};

export const Microscope = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { has_dish, cell_lines = [] } = data;

  return (
    <Window width={620} height={620}>
      <Window.Content scrollable>
        <Section
          title={has_dish ? t('ui.microscope.petri_dish_sample') : t('ui.microscope.no_petri_dish')}
          buttons={
            !!has_dish && (
              <Button
                icon="eject"
                disabled={!has_dish}
                onClick={() => act('eject_petridish')}
              >
                {t('ui.microscope.take_dish')}
              </Button>
            )
          }
        >
          <CellList cell_lines={cell_lines} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CellList = (props) => {
  const { t } = usePreferencesLocalization();
  const { cell_lines } = props;
  const fallback = (
    <Icon name="spinner" size={5} height="64px" width="64px" spin />
  );
  if (!cell_lines.length) {
    return <NoticeBox>{t('ui.microscope.no_micro_organisms_found')}</NoticeBox>;
  }

  return cell_lines.map((cell_line) => {
    return cell_line.type !== 'virus' ? (
      <Stack key={cell_line.desc} mt={2}>
        <Stack.Item>
          <DmIcon
            fallback={fallback}
            icon={cell_line.icon}
            icon_state={cell_line.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item grow pl={1}>
          <Section
            title={cell_line.desc}
            buttons={
              <Button
                color="transparent"
                icon="circle-question"
                tooltip={t('ui.microscope.growing_vat_tooltip')}
              />
            }
          >
            <Box my={1}>
              {t('ui.microscope.consume_prefix')} {cell_line.consumption_rate} {t('ui.microscope.consume_middle')}
              {cell_line.growth_rate}%.
            </Box>
            {cell_line.suspectibility > 0 && (
              <Box my={1}>
                {t('ui.microscope.reduced_by')} {cell_line.suspectibility}% {t('ui.microscope.when_infected_with_viruses')}
              </Box>
            )}
            <Stack fill>
              <Stack.Item grow>
                <GroupTitle title={t('ui.microscope.required_reagents')} />
                {Object.keys(cell_line.requireds).map((reagent) => (
                  <Button fluid key={reagent}>
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <GroupTitle title={t('ui.microscope.supplements')} />
                {Object.keys(cell_line.supplementaries).map((reagent) => (
                  <Button
                    fluid
                    color="good"
                    key={reagent}
                    tooltip={`+${cell_line.supplementaries[reagent]}% ${t('ui.microscope.growth_per_sec')}`}
                  >
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <GroupTitle title={t('ui.microscope.supressives')} />
                {Object.keys(cell_line.suppressives).map((reagent) => (
                  <Button
                    fluid
                    color="bad"
                    key={reagent}
                    tooltip={`${cell_line.suppressives[reagent]}% ${t('ui.microscope.growth_per_sec')}`}
                  >
                    {reagent}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    ) : (
      <Stack key={cell_line.desc} mt={2}>
        <Stack.Item>
          <Icon name="viruses" color="bad" size={4} mr={1} />
        </Stack.Item>
        <Stack.Item grow pl={1}>
          <Section title={cell_line.desc}>
            <Box my={1}>
              {t('ui.microscope.virus_reduces_growth')}
            </Box>
          </Section>
        </Stack.Item>
      </Stack>
    );
  });
};

const GroupTitle = (props) => {
  const { title } = props;
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item
        style={{
          textTransform: 'capitalize',
        }}
        color={'gray'}
      >
        {title}
      </Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
