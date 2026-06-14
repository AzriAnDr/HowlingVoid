import {
  AnimatedNumber,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { type Beaker, BeakerSectionDisplay } from './common/BeakerDisplay';

const damageTypes = [
  {
    label: 'ui.cryo.damage_brute',
    type: 'bruteLoss',
  },
  {
    label: 'ui.cryo.damage_respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'ui.cryo.damage_toxin',
    type: 'toxLoss',
  },
  {
    label: 'ui.cryo.damage_burn',
    type: 'fireLoss',
  },
] as const;

const stat_to_color = {
  Dead: 'bad',
  Conscious: 'bad',
  Unconscious: 'good',
} as const;

const stat_to_label: Record<string, string> = {
  Dead: 'ui.common.dead',
  Conscious: 'ui.common.conscious',
  Unconscious: 'ui.common.unconscious',
};

type Occupant = {
  name: string;
  stat: string;
  bodyTemperature: number;
  health: number;
  maxHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
};

type Data = {
  isOperating: BooleanLike;
  isOpen: BooleanLike;
  autoEject: BooleanLike;
  occupant: Occupant;
  T0C: number;
  cellTemperature: number;
  beaker: Beaker;
};

export const Cryo = () => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { occupant, isOperating, isOpen } = data;

  return (
    <Window title={t('ui.cryo.title')} width={400} height={550}>
      <Window.Content scrollable>
        <Section title={t('ui.cryo.occupant')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.cryo.occupant')}>
              {occupant?.name || t('ui.cryo.no_occupant')}
            </LabeledList.Item>
            {!!occupant && (
              <>
                <LabeledList.Item
                  label={t('ui.cryo.state')}
                  color={stat_to_color[occupant.stat]}
                >
                  {stat_to_label[occupant.stat]
                    ? t(stat_to_label[occupant.stat])
                    : occupant.stat}
                </LabeledList.Item>
                <LabeledList.Item
                  label={t('ui.common.temperature')}
                  color={occupant.bodyTemperature < data.T0C ? 'good' : 'bad'} // Green if the mob can actually be healed by cryoxadone.
                >
                  <AnimatedNumber value={round(occupant.bodyTemperature, 0)} />
                  {' K'}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.common.health')}>
                  <ProgressBar
                    value={round(occupant.health / occupant.maxHealth, 2)}
                    color={occupant.health > 0 ? 'good' : 'average'}
                  >
                    <AnimatedNumber value={round(occupant.health, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                {damageTypes.map((damageType) => (
                  <LabeledList.Item
                    key={damageType.type}
                    label={t(damageType.label)}
                  >
                    <ProgressBar
                      value={round(data.occupant[damageType.type] / 100, 2)}
                    >
                      <AnimatedNumber
                        value={round(data.occupant[damageType.type], 0)}
                      />
                    </ProgressBar>
                  </LabeledList.Item>
                ))}
              </>
            )}
          </LabeledList>
        </Section>
        <Section title={t('ui.cryo.cell')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.cryo.power')}>
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                disabled={isOpen}
                onClick={() => act('power')}
                color={isOperating && 'green'}
              >
                {isOperating ? t('ui.common.on') : t('ui.common.off')}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.temperature')}>
              <AnimatedNumber value={round(data.cellTemperature, 0)} /> K
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.cryo.door')}>
              <Button
                icon={isOpen ? 'unlock' : 'lock'}
                onClick={() => act('door')}
              >
                {isOpen ? t('ui.cryo.open') : t('ui.cryo.closed')}
              </Button>
              <Button
                icon={data.autoEject ? 'sign-out-alt' : 'sign-in-alt'}
                onClick={() => act('autoeject')}
              >
                {data.autoEject ? t('ui.common.auto') : t('ui.common.manual')}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <BeakerSectionDisplay beaker={data.beaker} showpH={false} />
      </Window.Content>
    </Window>
  );
};
