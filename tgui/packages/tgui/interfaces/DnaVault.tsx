import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  animals_max: number;
  animals: number;
  choiceA: string;
  choiceB: string;
  completed: BooleanLike;
  dna_max: number;
  dna: number;
  plants_max: number;
  plants: number;
  used: BooleanLike;
};

export function DnaVault(props) {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const {
    animals_max,
    animals,
    choiceA,
    choiceB,
    completed,
    dna_max,
    dna,
    plants_max,
    plants,
    used,
  } = data;

  return (
    <Window width={350} height={400}>
      <Window.Content>
        <Section title={t('ui.dna_vault.database')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.dna_vault.human_dna')}>
              <ProgressBar value={dna / dna_max}>
                {`${dna} / ${dna_max} ${t('ui.dna_vault.samples')}`}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.dna_vault.plant_dna')}>
              <ProgressBar value={plants / plants_max}>
                {`${plants} / ${plants_max} ${t('ui.dna_vault.samples')}`}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.dna_vault.animal_dna')}>
              <ProgressBar value={animals / animals_max}>
                {`${animals} / ${animals_max} ${t('ui.dna_vault.samples')}`}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!(completed && !used) && (
          <Section title={t('ui.dna_vault.personal_gene_therapy')}>
            <Box bold textAlign="center" mb={1}>
              {t('ui.dna_vault.applicable_treatments')}
            </Box>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  bold
                  textAlign="center"
                  onClick={() =>
                    act('gene', {
                      choice: choiceA,
                    })
                  }
                >
                  {choiceA}
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  bold
                  textAlign="center"
                  onClick={() =>
                    act('gene', {
                      choice: choiceB,
                    })
                  }
                >
                  {choiceB}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}
