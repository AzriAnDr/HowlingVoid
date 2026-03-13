import {
  Image,
  LabeledList,
  Modal,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, capitalizeFirst } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  raptor_scan: boolean;
  raptor_attack: number;
  raptor_health: number;
  raptor_max_health: number;
  raptor_speed: number;
  can_grow: boolean;
  raptor_growth: number;
  raptor_color: string;
  raptor_image: string;
  raptor_gender: string;
  raptor_happiness: string;
  raptor_description: string;
  inherited_attack: number;
  inherited_attack_max: number;
  inherited_health: number;
  inherited_health_max: number;
  inherited_speed: number;
  inherited_speed_max: number;
  inherited_ability: number;
  inherited_ability_max: number;
  inherited_growth: number;
  inherited_growth_max: number;
  inherited_traits: string[];
};

export const RaptorDex = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window title={t('ui.raptordex.raptor_data')} width={770} height={370} theme="hackerman">
      <Window.Content>
        <RaptorDexContent />
      </Window.Content>
    </Window>
  );
};

export const RaptorDexContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    raptor_scan,
    raptor_attack,
    raptor_health,
    raptor_max_health,
    raptor_speed,
    raptor_image,
    raptor_gender,
    can_grow,
    raptor_growth,
    inherited_attack,
    inherited_attack_max,
    inherited_health,
    inherited_health_max,
    inherited_speed,
    inherited_speed_max,
    inherited_ability,
    inherited_ability_max,
    inherited_growth,
    inherited_growth_max,
    raptor_happiness,
    inherited_traits,
    raptor_description,
    raptor_color,
  } = data;

  if (!raptor_scan) {
    return <Modal textAlign="center">{t('ui.raptordex.no_scan_data')}</Modal>;
  }

  return (
    <Stack>
      {' '}
      <Stack.Item width="33%">
        <Section textAlign="center" title={capitalizeAll(raptor_color)}>
          <Image
            src={`data:image/jpeg;base64,${raptor_image}`}
            height="128px"
            width="224px"
            style={{
              verticalAlign: 'middle',
              borderRadius: '1em',
              border: '1px solid green',
            }}
          />
        </Section>
        <Section fill title={t('ui.common.description')}>
          {raptor_description}
        </Section>
      </Stack.Item>
      <Stack.Item width="33%" textAlign="center">
        <Section title={t('ui.raptordex.stats')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.health')}>
              {raptor_health} / {raptor_max_health}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.attack')}>{raptor_attack}</LabeledList.Item>
            <LabeledList.Item label={t('ui.common.speed')}>
              {Math.round(10 / Math.max(raptor_speed, 0.5))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.gender')}>
              {capitalizeFirst(raptor_gender)}
            </LabeledList.Item>
            {!!can_grow && (
              <LabeledList.Item label={t('ui.raptordex.growth')}>
                <ProgressBar value={raptor_growth} maxValue={100} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title={t('ui.raptordex.inherit_modifiers')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.health')}>
              <ProgressBar
                value={inherited_health}
                maxValue={inherited_health_max}
                ranges={{
                  good: [0.5 * inherited_health_max, Infinity],
                  average: [0, inherited_health_max * 0.5],
                  bad: [-Infinity, 0],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.attack')}>
              <ProgressBar
                value={inherited_attack}
                maxValue={inherited_attack_max}
                ranges={{
                  good: [0.5 * inherited_attack_max, Infinity],
                  average: [0, inherited_attack_max * 0.5],
                  bad: [-Infinity, 0],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.speed')}>
              <ProgressBar
                value={inherited_speed}
                maxValue={inherited_speed_max}
                ranges={{
                  good: [0.5 * inherited_speed_max, Infinity],
                  average: [0, inherited_speed_max * 0.5],
                  bad: [-Infinity, 0],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.raptordex.capability')}>
              <ProgressBar
                value={inherited_ability}
                maxValue={inherited_ability_max}
                ranges={{
                  good: [0.5 * inherited_ability_max, Infinity],
                  average: [0, inherited_ability_max * 0.5],
                  bad: [-Infinity, 0],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.raptordex.growth_speed')}>
              <ProgressBar
                value={inherited_growth}
                maxValue={inherited_growth_max}
                ranges={{
                  good: [0.5 * inherited_growth_max, Infinity],
                  average: [0, inherited_growth_max * 0.5],
                  bad: [-Infinity, 0],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item width="33%">
        <Section textAlign="center" title={t('ui.raptordex.friendship_bond')}>
          <Image
            mt={-9.5}
            src={`data:image/jpeg;base64,${raptor_happiness}`}
            height="72px"
            width="72px"
          />
        </Section>
        <Section textAlign="center" title={t('ui.raptordex.inherited_traits')}>
          <Stack vertical>
            {inherited_traits.map((trait, index) => (
              <Stack.Item key={index}>{trait}</Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
