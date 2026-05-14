import { useMemo, useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type KnownReagent = {
  id: string;
  name: string;
  description: string;
  color?: string;
  selected: BooleanLike;
};

type ReservoirReagent = {
  id: string;
  name: string;
  volume: number;
  color?: string;
};

type SavedProfile = {
  name: string;
  summary: string;
};

type MODInjectorData = {
  currentVolume: number;
  maxVolume: number;
  dose: number;
  synthesisAmount: number;
  autoRefill: BooleanLike;
  sampleVolume: number;
  knownReagentCount: number;
  maxKnownReagents: number;
  power: number;
  maxPower: number;
  synthesisCostPerUnit: number;
  selectedReagent?: string | null;
  knownReagents: KnownReagent[];
  reservoirContents: ReservoirReagent[];
  profiles: SavedProfile[];
};

type ArchiveSectionProps = {
  filteredReagents: KnownReagent[];
  searchText: string;
  setSearchText: (value: string) => void;
  synthesisAmount: number;
  synthesisCostPerUnit: number;
};

type InjectorSectionProps = {
  currentVolume: number;
  maxVolume: number;
  dose: number;
  synthesisAmount: number;
  autoRefill: BooleanLike;
  selectedReagentData: KnownReagent | null;
  sortedReservoirContents: ReservoirReagent[];
};

type ProfilesSectionProps = {
  profiles: SavedProfile[];
};

type PresetButtonsProps = {
  currentValue: number;
  values: number[];
  onSelect: (value: number) => void;
};

const STRINGS = {
  english: {
    windowTitle: 'MOD Injector Console',
    status: 'Status',
    workflow: 'Workflow',
    workflowText:
      'Load 50u of a reagent into the injector to archive it automatically, then select it, synthesize it into the reservoir, and inject the chosen dose.',
    archiveRule:
      'The archive fills automatically once the injector itself contains 50u of a reagent. Saving below stores only a cocktail profile, not the reagent archive.',
    archiveAndSynthesis: 'Archive and Synthesis',
    injectionControl: 'Injection Control',
    cocktailProfiles: 'Cocktail Profiles',
    profilesHint:
      'This stores only the current reservoir mix as a reusable emergency cocktail. Reagent archiving is automatic.',
    reagent: 'Reagent',
    actions: 'Actions',
    name: 'Name',
    summary: 'Composition',
    selectedReagent: 'Selected reagent',
    noneSelected: 'No reagent selected',
    noSelectionHint:
      'Select an archived reagent on the left to synthesize or fill the reservoir.',
    noDescription: 'No description.',
    dose: 'Dose per injection',
    doseHint: 'How many units the injector tries to deliver per use.',
    dosePresets: 'Dose presets',
    synthesisAmount: 'Batch size',
    synthesisHint: 'How many units are created when you press synthesize.',
    batchPresets: 'Batch presets',
    autoRefill: 'Auto-refill before injection',
    autoRefillHint:
      'If the reservoir is short, the injector will synthesize only the missing units for the current dose.',
    readyDoses: 'Ready doses',
    archiveThreshold: 'Archive sample',
    batchCost: 'Batch cost',
    doseCost: 'Auto-refill cost',
    archiveSlots: 'Archive slots',
    reservoirLoad: 'Reservoir load',
    reservoirContents: 'Reservoir contents',
    modCharge: 'MOD charge',
    searchPlaceholder: 'Search archived reagents...',
    noKnownReagents:
      'No archived reagents yet. Load 50u of a reagent into the injector to learn it automatically.',
    noReservoirContents: 'Reservoir is empty.',
    noProfiles: 'No saved cocktail profiles.',
    select: 'Select',
    selected: 'Selected',
    synthesize: 'Add batch',
    fillReservoir: 'Fill reservoir',
    injectSelf: 'Inject self',
    saveProfile: 'Save cocktail profile',
    flushReservoir: 'Flush reservoir',
    purge: 'Purge',
    load: 'Load',
    delete: 'Delete',
    enabled: 'Enabled',
    disabled: 'Disabled',
    chargeEstimate: 'estimated from MOD reserves',
  },
  russian: {
    windowTitle: 'Консоль инъектора MOD',
    status: 'Статус',
    workflow: 'Как пользоваться',
    workflowText:
      'Внесите 50u реагента в инъектор, чтобы он сам попал в архив, затем выберите его, синтезируйте в резервуар и введите нужную дозу.',
    archiveRule:
      'Архив пополняется автоматически, как только внутри самого инъектора накапливается 50u реагента. Кнопка сохранения ниже сохраняет только профиль коктейля, а не архив реагентов.',
    archiveAndSynthesis: 'Архив и синтез',
    injectionControl: 'Управление инъектором',
    cocktailProfiles: 'Профили коктейлей',
    profilesHint:
      'Это сохраняет только текущую смесь из резервуара как готовый аварийный коктейль. Архив реагентов пополняется автоматически.',
    reagent: 'Реагент',
    actions: 'Действия',
    name: 'Название',
    summary: 'Состав',
    selectedReagent: 'Выбранный реагент',
    noneSelected: 'Реагент не выбран',
    noSelectionHint:
      'Выберите реагент слева, чтобы синтезировать его или полностью заполнить им резервуар.',
    noDescription: 'Описание отсутствует.',
    dose: 'Доза за инъекцию',
    doseHint: 'Сколько юнитов инъектор пытается ввести за одно применение.',
    dosePresets: 'Быстрые дозы',
    synthesisAmount: 'Размер пакета',
    synthesisHint: 'Сколько юнитов создаётся при нажатии кнопки синтеза.',
    batchPresets: 'Быстрые пакеты',
    autoRefill: 'Автоподкачка перед инъекцией',
    autoRefillHint:
      'Если в резервуаре не хватает вещества, инъектор досинтезирует только недостающий объём для текущей дозы.',
    readyDoses: 'Готовых доз',
    archiveThreshold: 'Образец для архива',
    batchCost: 'Цена пакета',
    doseCost: 'Цена автодозы',
    archiveSlots: 'Ячеек архива',
    reservoirLoad: 'Заполнение резервуара',
    reservoirContents: 'Содержимое резервуара',
    modCharge: 'Заряд MOD',
    searchPlaceholder: 'Поиск по архиву реагентов...',
    noKnownReagents:
      'Архив реагентов пока пуст. Внесите 50u реагента в инъектор, и он сохранится автоматически.',
    noReservoirContents: 'Резервуар пуст.',
    noProfiles: 'Сохранённых профилей коктейлей нет.',
    select: 'Выбрать',
    selected: 'Выбран',
    synthesize: 'Добавить пакет',
    fillReservoir: 'Заполнить резервуар',
    injectSelf: 'Вколоть себе',
    saveProfile: 'Сохранить профиль коктейля',
    flushReservoir: 'Очистить резервуар',
    purge: 'Удалить',
    load: 'Загрузить',
    delete: 'Удалить',
    enabled: 'Включена',
    disabled: 'Выключена',
    chargeEstimate: 'оценка по запасу энергии MOD',
  },
} as const;

const DOSE_PRESETS = [5, 10, 15, 25];
const BATCH_PRESETS = [5, 10, 20, 50];

const formatUnits = (value: number) => `${Math.round(value * 100) / 100}u`;

const formatEnergy = (value: number) => `${formatSiUnit(value, 0)}J`;

const useInjectorLocale = () => {
  const { language } = usePreferencesLocalization();
  return language === 'russian' ? STRINGS.russian : STRINGS.english;
};

const PresetButtons = (props: PresetButtonsProps) => {
  const { currentValue, values, onSelect } = props;

  return (
    <Box mt={0.5}>
      {values.map((value) => (
        <Button
          key={value}
          mr={0.5}
          mb={0.5}
          selected={currentValue === value}
          content={formatUnits(value)}
          onClick={() => onSelect(value)}
        />
      ))}
    </Box>
  );
};

export const MODInjector = () => {
  const { data } = useBackend<MODInjectorData>();
  const strings = useInjectorLocale();
  const [searchText, setSearchText] = useState('');

  const {
    currentVolume,
    maxVolume,
    dose,
    synthesisAmount,
    autoRefill,
    sampleVolume,
    knownReagentCount,
    maxKnownReagents,
    power,
    maxPower,
    synthesisCostPerUnit,
    selectedReagent,
    knownReagents = [],
    reservoirContents = [],
    profiles = [],
  } = data;

  const filteredReagents = useMemo(() => {
    const query = searchText.trim().toLowerCase();
    return [...knownReagents]
      .filter((reagent) => {
        if (!query) {
          return true;
        }
        return (
          reagent.name.toLowerCase().includes(query) ||
          reagent.description?.toLowerCase().includes(query)
        );
      })
      .sort((a, b) => {
        if (!!a.selected !== !!b.selected) {
          return a.selected ? -1 : 1;
        }
        return a.name.localeCompare(b.name);
      });
  }, [knownReagents, searchText]);

  const sortedReservoirContents = useMemo(
    () => [...reservoirContents].sort((a, b) => b.volume - a.volume),
    [reservoirContents],
  );

  const selectedReagentData =
    knownReagents.find((reagent) => reagent.id === selectedReagent) || null;
  const readyDoses = dose > 0 ? Math.floor(currentVolume / dose) : 0;
  const batchCost = synthesisAmount * synthesisCostPerUnit;
  const doseCost = dose * synthesisCostPerUnit;

  return (
    <Window width={900} height={760} title={strings.windowTitle}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <NoticeBox mb={1}>
              <Box bold>{strings.workflow}</Box>
              <Box mt={0.5}>{strings.workflowText}</Box>
              <Box mt={0.5} color="label">
                {strings.archiveRule}
              </Box>
            </NoticeBox>
          </Stack.Item>

          <Stack.Item>
            <Section title={strings.status}>
              <Stack>
                <Stack.Item grow basis="52%">
                  <LabeledList>
                    <LabeledList.Item label={strings.selectedReagent}>
                      {selectedReagentData?.name || strings.noneSelected}
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.archiveThreshold}>
                      {formatUnits(sampleVolume)}
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.archiveSlots}>
                      {`${knownReagentCount} / ${maxKnownReagents}`}
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.readyDoses}>
                      {readyDoses}
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.batchCost}>
                      {`${formatEnergy(batchCost)} (${strings.chargeEstimate})`}
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.doseCost}>
                      {`${formatEnergy(doseCost)} (${strings.chargeEstimate})`}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item grow basis="48%">
                  <LabeledList>
                    <LabeledList.Item label={strings.reservoirLoad}>
                      <ProgressBar
                        value={maxVolume ? currentVolume / maxVolume : 0}
                        ranges={{
                          good: [0.6, Infinity],
                          average: [0.25, 0.6],
                          bad: [-Infinity, 0.25],
                        }}
                      >
                        {`${formatUnits(currentVolume)} / ${formatUnits(maxVolume)}`}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.modCharge}>
                      <ProgressBar
                        value={maxPower ? power / maxPower : 0}
                        ranges={{
                          good: [0.5, Infinity],
                          average: [0.2, 0.5],
                          bad: [-Infinity, 0.2],
                        }}
                      >
                        {`${formatEnergy(power)} / ${formatEnergy(maxPower)}`}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label={strings.autoRefill}>
                      {autoRefill ? strings.enabled : strings.disabled}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis="56%">
                <ArchiveSection
                  filteredReagents={filteredReagents}
                  searchText={searchText}
                  setSearchText={setSearchText}
                  synthesisAmount={synthesisAmount}
                  synthesisCostPerUnit={synthesisCostPerUnit}
                />
              </Stack.Item>

              <Stack.Item grow basis="44%">
                <InjectorSection
                  currentVolume={currentVolume}
                  maxVolume={maxVolume}
                  dose={dose}
                  synthesisAmount={synthesisAmount}
                  autoRefill={autoRefill}
                  selectedReagentData={selectedReagentData}
                  sortedReservoirContents={sortedReservoirContents}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <ProfilesSection profiles={profiles} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ArchiveSection = (props: ArchiveSectionProps) => {
  const { act } = useBackend();
  const strings = useInjectorLocale();
  const {
    filteredReagents,
    searchText,
    setSearchText,
    synthesisAmount,
    synthesisCostPerUnit,
  } = props;

  return (
    <Section
      title={strings.archiveAndSynthesis}
      fill
      buttons={
        <Input
          value={searchText}
          width="230px"
          placeholder={strings.searchPlaceholder}
          onChange={(value) => setSearchText(String(value))}
        />
      }
    >
      {!filteredReagents.length ? (
        <NoticeBox>{strings.noKnownReagents}</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell />
            <Table.Cell>{strings.reagent}</Table.Cell>
            <Table.Cell width={1}>{strings.actions}</Table.Cell>
            <Table.Cell width={1} />
            <Table.Cell width={1} />
          </Table.Row>
          {filteredReagents.map((reagent) => (
            <Table.Row key={reagent.id}>
              <Table.Cell width={1}>
                <ColorBox color={reagent.color || 'white'} />
              </Table.Cell>
              <Table.Cell>
                <Box bold color={reagent.selected ? 'good' : undefined}>
                  {reagent.name}
                </Box>
                <Box fontSize="12px" opacity={0.8}>
                  {reagent.description || strings.noDescription}
                </Box>
              </Table.Cell>
              <Table.Cell width={1} textAlign="right">
                <Button
                  icon={reagent.selected ? 'check' : 'crosshairs'}
                  selected={reagent.selected}
                  content={reagent.selected ? strings.selected : strings.select}
                  onClick={() =>
                    act('select_reagent', {
                      id: reagent.id,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1} textAlign="right">
                <Button
                  icon="flask"
                  color="good"
                  content={`+${synthesisAmount}u`}
                  tooltip={`${strings.synthesize}: ${formatEnergy(
                    synthesisAmount * synthesisCostPerUnit,
                  )}`}
                  onClick={() =>
                    act('synthesize', {
                      id: reagent.id,
                      amount: synthesisAmount,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell width={1} textAlign="right">
                <Button.Confirm
                  icon="trash"
                  color="bad"
                  content={strings.delete}
                  onClick={() =>
                    act('delete_known_reagent', {
                      id: reagent.id,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const InjectorSection = (props: InjectorSectionProps) => {
  const { act } = useBackend();
  const strings = useInjectorLocale();
  const {
    currentVolume,
    maxVolume,
    dose,
    synthesisAmount,
    autoRefill,
    selectedReagentData,
    sortedReservoirContents,
  } = props;

  return (
    <Section title={strings.injectionControl} fill>
      {selectedReagentData ? (
        <Section title={strings.selectedReagent} mb={1}>
          <Stack align="center">
            <Stack.Item>
              <ColorBox color={selectedReagentData.color || 'white'} />
            </Stack.Item>
            <Stack.Item grow>
              <Box bold>{selectedReagentData.name}</Box>
              <Box fontSize="12px" opacity={0.8}>
                {selectedReagentData.description || strings.noDescription}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      ) : (
        <NoticeBox mb={1}>{strings.noSelectionHint}</NoticeBox>
      )}

      <LabeledList>
        <LabeledList.Item label={strings.dose}>
          <NumberInput
            value={dose}
            minValue={1}
            maxValue={50}
            step={1}
            stepPixelSize={6}
            width="80px"
            onChange={(value) => act('set_dose', { value })}
          />
          <Box mt={0.5} color="label" fontSize="12px">
            {strings.doseHint}
          </Box>
          <Box mt={0.5}>{strings.dosePresets}</Box>
          <PresetButtons
            currentValue={dose}
            values={DOSE_PRESETS}
            onSelect={(value) => act('set_dose', { value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label={strings.synthesisAmount}>
          <NumberInput
            value={synthesisAmount}
            minValue={1}
            maxValue={50}
            step={1}
            stepPixelSize={6}
            width="80px"
            onChange={(value) => act('set_synthesis_amount', { value })}
          />
          <Box mt={0.5} color="label" fontSize="12px">
            {strings.synthesisHint}
          </Box>
          <Box mt={0.5}>{strings.batchPresets}</Box>
          <PresetButtons
            currentValue={synthesisAmount}
            values={BATCH_PRESETS}
            onSelect={(value) => act('set_synthesis_amount', { value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label={strings.autoRefill}>
          <Button.Checkbox
            checked={!!autoRefill}
            onClick={() => act('toggle_auto_refill')}
          />
          <Box mt={0.5} color="label" fontSize="12px">
            {strings.autoRefillHint}
          </Box>
        </LabeledList.Item>
      </LabeledList>

      <Stack mt={1} mb={1}>
        <Stack.Item grow>
          <Button
            fluid
            icon="plus"
            color="good"
            disabled={!selectedReagentData}
            content={strings.synthesize}
            onClick={() =>
              selectedReagentData &&
              act('synthesize', {
                id: selectedReagentData.id,
                amount: synthesisAmount,
              })
            }
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="flask"
            color="average"
            disabled={!selectedReagentData}
            content={strings.fillReservoir}
            onClick={() => act('prime_selected')}
          />
        </Stack.Item>
      </Stack>

      <Stack mb={1}>
        <Stack.Item grow>
          <Button
            fluid
            icon="syringe"
            disabled={currentVolume <= 0}
            content={strings.injectSelf}
            onClick={() => act('self_inject')}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="save"
            disabled={currentVolume <= 0}
            content={strings.saveProfile}
            onClick={() => act('save_profile')}
          />
        </Stack.Item>
      </Stack>

      <Button.Confirm
        fluid
        icon="trash"
        color="bad"
        disabled={currentVolume <= 0}
        mb={1}
        onClick={() => act('flush')}
      >
        {strings.flushReservoir}
      </Button.Confirm>

      <Section
        title={`${strings.reservoirContents} (${formatUnits(currentVolume)} / ${formatUnits(maxVolume)})`}
      >
        {!sortedReservoirContents.length ? (
          <NoticeBox>{strings.noReservoirContents}</NoticeBox>
        ) : (
          <Table>
            <Table.Row header>
              <Table.Cell />
              <Table.Cell>{strings.reagent}</Table.Cell>
              <Table.Cell width={1}>u</Table.Cell>
              <Table.Cell width={1} />
            </Table.Row>
            {sortedReservoirContents.map((reagent) => (
              <Table.Row key={reagent.id}>
                <Table.Cell width={1}>
                  <ColorBox color={reagent.color || 'white'} />
                </Table.Cell>
                <Table.Cell>{reagent.name}</Table.Cell>
                <Table.Cell width={1} textAlign="center">
                  {Math.round(reagent.volume * 100) / 100}
                </Table.Cell>
                <Table.Cell width={1} textAlign="right">
                  <Button
                    icon="minus-circle"
                    color="bad"
                    content={strings.purge}
                    onClick={() => act('purge_reagent', { id: reagent.id })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
    </Section>
  );
};

const ProfilesSection = (props: ProfilesSectionProps) => {
  const { act } = useBackend();
  const strings = useInjectorLocale();
  const { profiles } = props;

  return (
    <Section title={strings.cocktailProfiles}>
      <Box mb={1} color="label">
        {strings.profilesHint}
      </Box>
      {!profiles.length ? (
        <NoticeBox>{strings.noProfiles}</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>{strings.name}</Table.Cell>
            <Table.Cell>{strings.summary}</Table.Cell>
            <Table.Cell width={1} />
            <Table.Cell width={1} />
          </Table.Row>
          {profiles.map((profile) => (
            <Table.Row key={profile.name}>
              <Table.Cell width={18}>
                <Box bold>{profile.name}</Box>
              </Table.Cell>
              <Table.Cell>
                <Box
                  style={{
                    wordBreak: 'break-word',
                  }}
                >
                  {profile.summary}
                </Box>
              </Table.Cell>
              <Table.Cell width={1} textAlign="right">
                <Button
                  icon="upload"
                  color="good"
                  content={strings.load}
                  onClick={() => act('load_profile', { name: profile.name })}
                />
              </Table.Cell>
              <Table.Cell width={1} textAlign="right">
                <Button.Confirm
                  icon="trash"
                  color="bad"
                  onClick={() =>
                    act('delete_profile', {
                      name: profile.name,
                    })
                  }
                >
                  {strings.delete}
                </Button.Confirm>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
