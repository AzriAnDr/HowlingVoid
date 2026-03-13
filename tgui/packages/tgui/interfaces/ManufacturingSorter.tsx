import {
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  filters: Filter[];
  unmet_dir: number;
};

function dir2icon(dir) {
  switch (dir) {
    case 1:
      return 'arrow-up';
    case 2:
      return 'arrow-down';
    case 4:
      return 'arrow-right';
    case 8:
      return 'arrow-left';
    default:
      return 'arrow-up';
  }
}

type Filter = {
  name: string;
  ref: string;
  inverted: BooleanLike;
  dir: number;
};

export function ManufacturingSorter(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { filters, unmet_dir } = data;

  return (
    <Window width={450} height={350} title={t('ui.manufacturingsorter.manufacturing_sorter')}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item height="90%">
            <Section
              title={t('ui.manufacturingsorter.filters')}
              height="100%"
              overflowY="auto"
              buttons={
                <Button
                  color="green"
                  icon="plus"
                  onClick={() => act('new_filter')}
                >
                  {t('ui.manufacturing_sorter.new_filter')}
                </Button>
              }
            >
              <LabeledList>
                {filters.map((filter, i) => (
                  <LabeledList.Item
                    label={`${i + 1}. ${filter.name}`}
                    key={filter.ref}
                  >
                    <Button
                      icon={dir2icon(filter.dir)}
                      onClick={() => act('rotate', { ref: filter.ref })}
                    >
                      {t('ui.common.output')}
                    </Button>
                    <Button onClick={() => act('edit', { ref: filter.ref })}>
                      <Icon ml="0.2rem" name="pencil" />
                    </Button>
                    <Button
                      color="red"
                      onClick={() => act('del_filter', { ref: filter.ref })}
                    >
                      <Icon ml="0.2rem" name="trash" />
                    </Button>
                    <Button
                      onClick={() =>
                        act('shift', { ref: filter.ref, amount: -1 })
                      }
                    >
                      <Icon ml="0.2rem" name="arrow-up" />
                    </Button>
                    <Button
                      onClick={() =>
                        act('shift', { ref: filter.ref, amount: 1 })
                      }
                    >
                      <Icon ml="0.2rem" name="arrow-down" />
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Box>{t('ui.manufacturingsorter.if_no_criteria_is_met_outputting_to')}</Box>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('rotate_unmet')}>
                  <Icon ml="0.2rem" name={dir2icon(unmet_dir)} />
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
