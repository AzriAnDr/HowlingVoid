import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasColor } from '../constants';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  on: BooleanLike;
  requirements: string;
  internal_temperature: number;
  progress_bar: number;
  gas_input: number;
  selected: string;
  selected_recipes: Recipe[];
  internal_gas_data: Gas[];
};

type Recipe = {
  name: string;
  id: string;
};

type Gas = {
  name: string;
  id: string;
  amount: number;
};

const logScale = (value) => Math.log2(16 + Math.max(0, value)) - 4;

export const Crystallizer = (props) => {
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Controls />
        <Requirements />
        <Gases />
      </Window.Content>
    </Window>
  );
};

const Controls = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { gas_input, on, selected, selected_recipes = [] } = data;

  return (
    <Section title={t('ui.common.controls')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.power')}>
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? t('ui.common.on') : t('ui.common.off')}
            selected={on}
            onClick={() => act('power')}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.recipe')}>
          {selected_recipes.map(({ id, name }) => (
            <Button
              key={id}
              selected={id === selected}
              content={name}
              onClick={() =>
                act('recipe', {
                  mode: id,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.crystallizer.gas_input')}>
          <NumberInput
            animated
            tickWhileDragging
            step={0.1}
            value={gas_input}
            width="63px"
            unit="moles/s"
            minValue={0}
            maxValue={250}
            onChange={(value) =>
              act('gas_input', {
                gas_input: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Requirements = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { requirements, internal_temperature, progress_bar } = data;

  return (
    <Section title={t('ui.crystallizer.requirements_and_progress')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.progress')}>
          <ProgressBar
            value={progress_bar / 100}
            ranges={{
              good: [0.67, 1],
              average: [0.34, 0.66],
              bad: [0, 0.33],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.recipe')}>
          <Box m={1} preserveWhitespace>
            {requirements}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.temperature')}>
          <ProgressBar
            value={logScale(internal_temperature)}
            minValue={0}
            maxValue={logScale(10000)}
            ranges={{
              teal: [-Infinity, logScale(80)],
              good: [logScale(80), logScale(600)],
              average: [logScale(600), logScale(5000)],
              bad: [logScale(5000), Infinity],
            }}
          >
            {`${toFixed(internal_temperature)} K`}
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Gases = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { internal_gas_data = [] } = data;

  return (
    <Section title={t('ui.common.gases')}>
      <LabeledList>
        {internal_gas_data.map(({ id, name, amount }) => (
          <LabeledList.Item key={name} label={name}>
            <ProgressBar
              color={getGasColor(id)}
              value={amount}
              minValue={0}
              maxValue={1000}
            >
              {`${toFixed(amount, 2)} moles`}
            </ProgressBar>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
