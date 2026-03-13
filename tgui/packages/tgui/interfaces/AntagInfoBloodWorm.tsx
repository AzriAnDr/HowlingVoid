import { Section, Stack, LabeledList } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  objectives: Objective[];
  team: Team;
};

type Team = {
  blood_consumed_total: number;
  times_reproduced_total: number;
};

export const AntagInfoBloodWorm = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { objectives, team } = data;
  return (
    <Window width={800} height={500}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              {t('ui.antaginfobloodworm.you_are_a_blood_worm')}
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item bold>{t('ui.antaginfobloodworm.team_status')}</Stack.Item>
                <Stack.Item>
                  - {t('ui.antaginfobloodworm.total_blood_consumed')}: {team.blood_consumed_total}{' '}
                  {t('ui.common.units')}
                  <br />
                  - {t('ui.antaginfobloodworm.total_times_reproduced')}:{' '}
                  {team.times_reproduced_total} {t('ui.common.times')}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Section fill title={t('ui.antaginfobloodworm.powers')}>
                <LabeledList>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.space_immunity')}>
                  {t('ui.antaginfobloodworm.space_immunity_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.blood_consumption')}>
                  {t('ui.antaginfobloodworm.blood_consumption_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.growth_stages')}>
                  {t('ui.antaginfobloodworm.growth_stages_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.ventcrawling')}>
                  {t('ui.antaginfobloodworm.ventcrawling_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.doorcrawling')}>
                  {t('ui.antaginfobloodworm.doorcrawling_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.reproduction')}>
                  {t('ui.antaginfobloodworm.reproduction_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.parasitism')}>
                  {t('ui.antaginfobloodworm.parasitism_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.regeneration')}>
                  {t('ui.antaginfobloodworm.regeneration_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.life_support')}>
                  {t('ui.antaginfobloodworm.life_support_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.alien_mind')}>
                  {t('ui.antaginfobloodworm.alien_mind_desc')}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title={t('ui.antaginfobloodworm.weaknesses')}>
                <LabeledList>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.high_heat')}>
                  {t('ui.antaginfobloodworm.high_heat_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.bleeding')}>
                  {t('ui.antaginfobloodworm.bleeding_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.inferior_biology')}>
                  {t('ui.antaginfobloodworm.inferior_biology_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.testing')}>
                  {t('ui.antaginfobloodworm.testing_desc')}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title={t('ui.antaginfobloodworm.tips')}>
                <LabeledList>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.stealthy_healing')}>
                  {t('ui.antaginfobloodworm.stealthy_healing_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.surprise_worms')}>
                  {t('ui.antaginfobloodworm.surprise_worms_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.door_stalking')}>
                  {t('ui.antaginfobloodworm.door_stalking_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.meatshields')}>
                  {t('ui.antaginfobloodworm.meatshields_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.life_insurance')}>
                  {t('ui.antaginfobloodworm.life_insurance_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.medbay_buffet')}>
                  {t('ui.antaginfobloodworm.medbay_buffet_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.fast_food')}>
                  {t('ui.antaginfobloodworm.fast_food_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.nomadic')}>
                  {t('ui.antaginfobloodworm.nomadic_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.team_up')}>
                  {t('ui.antaginfobloodworm.team_up_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.jail_time')}>
                  {t('ui.antaginfobloodworm.jail_time_desc')}
                  </LabeledList.Item>
                  <LabeledList.Item label={t('ui.antaginfobloodworm.jumpstart')}>
                  {t('ui.antaginfobloodworm.jumpstart_desc')}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
