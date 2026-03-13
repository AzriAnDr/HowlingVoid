import { Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type BorgShakerContext = {
  minVolume: number;
  theme: string;
  sodas: Reagent[];
  alcohols: Reagent[];
  selectedReagent: string;
  reagentSearchContainer: ContainerPreference;
  apparatusHasItem: boolean;
};

type Reagent = {
  name: string;
  volume: number;
  description: string;
};

enum ContainerPreference {
  BeverageApparatus = 'beverage_apparatus',
  InternalBeaker = 'internal_beaker',
}

export const BorgShaker = (props) => {
  const { act, data } = useBackend<BorgShakerContext>();
  const { t } = usePreferencesLocalization(data);
  const { theme, minVolume, sodas, alcohols, selectedReagent } = data;

  const dynamicHeight =
    Math.ceil(sodas.length / 4) * 23 +
    Math.ceil(alcohols.length / 4) * 23 +
    140;

  return (
    <Window width={650} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section
          title={t('ui.borg_shaker.non_alcoholic')}
          buttons={
            <>
              <Button
                icon="book"
                content={t('ui.borg_shaker.reaction_search')}
                disabled={
                  data.reagentSearchContainer !==
                    ContainerPreference.InternalBeaker && !data.apparatusHasItem
                }
                tooltip={
                  t('ui.borg_shaker.reaction_search_tooltip')
                }
                tooltipPosition="bottom-start"
                onClick={() => act('reaction_lookup')}
              />
              <Button
                icon="flask"
                width="23px"
                color={
                  data.reagentSearchContainer ===
                  ContainerPreference.InternalBeaker
                    ? 'green'
                    : 'default'
                }
                tooltip={t('ui.borg_shaker.search_source_internal_beaker')}
                onClick={() => {
                  act('set_preferred_container', {
                    value: ContainerPreference.InternalBeaker,
                  });
                }}
              />
              <Button
                icon="vial"
                width="24px"
                tooltip={t('ui.borg_shaker.search_source_beverage_apparatus')}
                color={
                  data.reagentSearchContainer ===
                  ContainerPreference.BeverageApparatus
                    ? 'green'
                    : 'default'
                }
                onClick={() => {
                  act('set_preferred_container', {
                    value: ContainerPreference.BeverageApparatus,
                  });
                }}
              />
            </>
          }
        >
          <ReagentDisplay
            reagents={sodas}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
        <Section title={t('ui.borg_shaker.alcoholic')}>
          <ReagentDisplay
            reagents={alcohols}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

const ReagentDisplay = (props) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const { reagents, selected, minimum } = props;
  if (reagents.length === 0) {
    return <NoticeBox>{t('ui.borg_shaker.no_reagents_available')}</NoticeBox>;
  }
  return reagents.map((reagent) => (
    <Button
      key={reagent.id}
      icon="tint"
      width="150px"
      lineHeight={1.75}
      content={reagent.name}
      color={reagent.name === selected ? 'green' : 'default'}
      disabled={reagent.volume < minimum}
      onClick={() => act(reagent.name)}
    />
  ));
};
