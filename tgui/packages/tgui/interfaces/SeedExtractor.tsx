import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type TraitData = {
  path: string;
  name: string;
  icon: string;
  description: string;
};

type ReagentData = {
  name: string;
  rate: number;
};

type SeedData = {
  key: string;
  amount: number;
  name: string;
  lifespan: number;
  endurance: number;
  maturation: number;
  production: number;
  yield: number;
  potency: number;
  instability: number;
  icon: string;
  volume_mod: number;
  volume_units: number;
  traits: string[];
  reagents: ReagentData[];
  mutatelist: string[];
  grind_results: string[];
  distill_reagent: string;
  juice_name: string;
};

type SeedExtractorData = {
  // Dynamic
  seeds: SeedData[];
  // Static
  trait_db: TraitData[];
  cycle_seconds: number;
};

export const SeedExtractor = (props) => {
  const { act, data } = useBackend<SeedExtractorData>();
  const { t } = usePreferencesLocalization();
  const [searchText, setSearchText] = useState('');
  const [sortField, setSortField] = useState('name');
  const [action, toggleAction] = useState(true);
  const search = createSearch(searchText, (item: SeedData) => item.name);
  const seeds_filtered =
    searchText.length > 0 ? data.seeds.filter(search) : data.seeds;
  const seeds = sortBy(seeds_filtered || [], [
    (item: SeedData) => item[sortField as keyof SeedData],
  ]);
  sortField !== 'name' && seeds.reverse();

  return (
    <Window width={800} height={500}>
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Row header>
              <Table.Cell colSpan={3} px={1} py={2}>
                <Input
                  autoFocus
                  placeholder={t('ui.common.search_placeholder')}
                  value={searchText}
                  onChange={setSearchText}
                  fluid
                />
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    t('ui.seed_extractor.potency_tooltip')
                  }
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('potency')}
                  >
                    PTN
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    t('ui.seed_extractor.yield_tooltip')
                  }
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('yield')}
                  >
                    YLD
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    t('ui.seed_extractor.instability_tooltip')
                  }
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('instability')}
                  >
                    INS
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={
                    t('ui.seed_extractor.endurance_tooltip')
                  }
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('endurance')}
                  >
                    END
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={`Lifespan: The age at which the plant starts decaying, in ${data.cycle_seconds} second long cycles. Improves quality of resulting food & drinks.`}
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('lifespan')}
                  >
                    LFS
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={`Maturation: The age required for the first harvest, in ${data.cycle_seconds} second long cycles.`}
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('maturation')}
                  >
                    MTR
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1}>
                <Tooltip
                  content={`Production: The period of product regrowth, in ${data.cycle_seconds} second long cycles.`}
                >
                  <Box
                    style={{ cursor: 'pointer' }}
                    onClick={(e) => setSortField('production')}
                  >
                    PRD
                  </Box>
                </Tooltip>
              </Table.Cell>
              <Table.Cell collapsing p={1} textAlign="right">
                {sortField !== 'name' && (
                    <Tooltip content={t('ui.seed_extractor.reset_sorting')}>
                    <Button
                      color="transparent"
                      icon="refresh"
                      onClick={(e) => setSortField('name')}
                    />
                  </Tooltip>
                )}
                <Box align="right" />
              </Table.Cell>
              <Table.Cell collapsing p={1} textAlign="right">
                <Tooltip
                  content={
                    action
                      ? t('ui.seed_extractor.scrap_seeds')
                      : t('ui.seed_extractor.take_seeds')
                  }
                >
                  <Button
                    icon={action ? 'trash' : 'eject'}
                    color={action ? 'bad' : ''}
                    onClick={(e) => toggleAction(!action)}
                  />
                </Tooltip>
              </Table.Cell>
            </Table.Row>
            {seeds.length > 0 &&
              seeds.map((item) => (
                <Table.Row
                  key={item.key}
                  style={{ borderTop: '2px solid #222' }}
                >
                  <Table.Cell collapsing>
                    <Box
                      mb={-2}
                      className={classes(['seeds32x32', item.icon])}
                    />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1}>
                    {`${item.amount}x ${item.name}`}
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing textAlign={'right'}>
                    {item.traits?.map((trait) => (
                      <TraitTooltip
                        key=""
                        path={trait}
                        trait_db={data.trait_db}
                      />
                    ))}
                    {!!item.mutatelist.length && (
                      <Tooltip
                        content={`${t('ui.seed_extractor.mutates_into')}: ${item.mutatelist.join(', ')}`}
                      >
                        <Icon name="dna" m={0.5} />
                      </Tooltip>
                    )}
                    {item.reagents.length > 0 && (
                      <Tooltip
                        content={
                          <ReagentTooltip
                            reagents={item.reagents}
                            grind_results={item.grind_results}
                            potency={item.potency}
                            volume_mod={item.volume_mod}
                            volume_units={item.volume_units}
                          />
                        }
                      >
                        <Icon name="blender" m={0.5} />
                      </Tooltip>
                    )}
                    {!!item.juice_name && (
                      <Tooltip
                        content={`${t('ui.seed_extractor.juicing_result')}: ${item.juice_name}`}
                      >
                        <Icon name="glass-water" m={0.5} />
                      </Tooltip>
                    )}
                    {!!item.distill_reagent && (
                      <Tooltip
                        content={`${t('ui.seed_extractor.ferments_into')}: ${item.distill_reagent}`}
                      >
                        <Icon name="wine-bottle" m={0.5} />
                      </Tooltip>
                    )}
                  </Table.Cell>
                  <Table.Cell px={1} collapsing>
                    <Level value={item.potency} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.yield} max={10} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.instability} max={100} reverse />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.endurance} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Level value={item.lifespan} max={100} />
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="center">{item.maturation}</Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} px={1} collapsing>
                    <Box textAlign="center">{item.production}</Box>
                  </Table.Cell>
                  <Table.Cell
                    py={0.5}
                    px={1}
                    collapsing
                    colSpan={2}
                    textAlign="right"
                  >
                    {action ? (
                      <Button
                        icon="eject"
                        content={t('ui.common.take')}
                        onClick={() =>
                          act('take', {
                            item: item.key,
                          })
                        }
                      />
                    ) : (
                      <Button
                        icon="trash"
                        content={t('ui.common.scrap')}
                        color="bad"
                        onClick={() =>
                          act('scrap', {
                            item: item.key,
                          })
                        }
                      />
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
          </Table>
          {seeds.length === 0 && (
            <NoticeBox m={1} p={1}>
              {t('ui.seed_extractor.no_seeds_found')}
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

export const Level = (props) => {
  return (
    <ProgressBar
      value={props.value}
      maxValue={props.max}
      ranges={
        props.reverse
          ? {
              good: [0, props.max * 0.2],
              average: [props.max * 0.2, props.max * 0.6],
              bad: [props.max * 0.6, props.max],
            }
          : {
              bad: [0, props.max * 0.2],
              good: [props.max * 0.8, props.max],
            }
      }
    >
      <span
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {props.value}
      </span>
    </ProgressBar>
  );
};

export const ReagentTooltip = (props) => {
  const { t } = usePreferencesLocalization();
  let rate_total = 0;
  props.reagents.forEach((reagent) => {
    rate_total += reagent.rate;
  });
  const reagent_volumes: number[] = [];
  const reagent_percentages: number[] = [];
  props.reagents.forEach((reagent) => {
    reagent_percentages.push(reagent.rate / Math.max(1, rate_total));
    reagent_volumes.push(
      Math.max(
        Math.round(
          props.volume_units *
            (props.potency / 100) *
            (reagent.rate / Math.max(1, rate_total)) *
            props.volume_mod,
        ),
        1,
      ),
    );
  });
  return (
    <Table>
      <Table.Row header>
        <Table.Cell colSpan={3}>{t('ui.seed_extractor.reagents_on_grind')}</Table.Cell>
      </Table.Row>
      {props.reagents?.map((reagent, i) => (
        <Table.Row key={i}>
          <Table.Cell>{reagent.name}</Table.Cell>
          <Table.Cell py={0.5} pl={2} textAlign={'right'}>
            {reagent_volumes[i]}u
          </Table.Cell>
          <Table.Cell py={0.5} pl={2} textAlign={'right'}>
            {rate_total > 1 && '~'}
            {Math.round(reagent_percentages[i] * 100)}%
          </Table.Cell>
        </Table.Row>
      ))}
      <Table.Row>
        <Table.Cell colSpan={3} style={{ borderTop: '1px dotted gray' }} />
      </Table.Row>
      <Table.Row header>
        <Table.Cell pt={1.5}>{t('ui.common.total')}</Table.Cell>
        <Table.Cell py={0.5} pl={2} textAlign={'right'}>
          {Math.round(reagent_volumes.reduce((a, b) => a + b))}u
        </Table.Cell>
        <Table.Cell py={0.5} pl={2} textAlign={'right'}>
          {Math.round(rate_total * 100)}%
        </Table.Cell>
      </Table.Row>
      <Table.Row header>
        <Table.Cell>{t('ui.common.capacity')}</Table.Cell>
        <Table.Cell py={0.5} pl={2} textAlign={'right'}>
          {props.volume_units}u
        </Table.Cell>
        <Table.Cell />
      </Table.Row>
      {!!props.grind_results.length && (
        <>
          <Table.Row>
            <Table.Cell colSpan={3} style={{ borderTop: '1px dotted gray' }} />
          </Table.Row>
          <Table.Row header>
            <Table.Cell colSpan={3} pt={1}>
              {t('ui.seed_extractor.nutriments_turn_into')}
            </Table.Cell>
          </Table.Row>
          {props.grind_results?.map((reagent, i) => (
            <Table.Row key={i}>
              <Table.Cell colSpan={3}>{reagent}</Table.Cell>
            </Table.Row>
          ))}
        </>
      )}
    </Table>
  );
};

export const TraitTooltip = (props) => {
  const { t } = usePreferencesLocalization();
  const trait = props.trait_db.find((t) => {
    return t.path === props.path;
  });
  if (!trait) {
    return;
  }
  return (
    <Tooltip
      content={
        <Table>
          {!!props.grafting && (
            <Table.Row>
              <Table.Cell pb={1}>
                {t('ui.seed_extractor.graft_gains_trait')}
              </Table.Cell>
            </Table.Row>
          )}
          <Table.Row header>
            <Table.Cell>
              <Icon name={trait.icon} mr={1} />
              {trait.name}
            </Table.Cell>
          </Table.Row>
          {!!props.removable && (
            <Table.Row>
              <Table.Cell pb={1}>{t('ui.seed_extractor.removable_trait')}</Table.Cell>
            </Table.Row>
          )}
          {!!trait.description && (
            <Table.Row>
              <Table.Cell>{trait.description}</Table.Cell>
            </Table.Row>
          )}
        </Table>
      }
    >
      <Icon name={props.grafting ? 'scissors' : trait.icon} m={0.5} />
    </Tooltip>
  );
};
