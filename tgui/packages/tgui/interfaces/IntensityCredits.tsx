// THIS IS A NOVA SECTOR UI FILE
import { Flex, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type ICESData = {
  current_credits: number;
  next_run: string;
  active_players: number;
  lowpop_players: number;
  lowpop_multiplier: number;
  midpop_players: number;
  midpop_multiplier: number;
  highpop_players: number;
  highpop_multiplier: number;
};

type Props = {
  context: any;
};

export const IntensityCredits = (props) => {
  const { act, data } = useBackend<ICESData>();
  const { t } = usePreferencesLocalization(data);

  const {
    current_credits,
    next_run,
    active_players,
    lowpop_players,
    lowpop_multiplier,
    midpop_players,
    midpop_multiplier,
    highpop_players,
    highpop_multiplier,
  } = data;

  return (
    <Window title={t('ui.intensitycredits.ices_events_panel')} width={480} height={320} theme="admin">
      <Window.Content>
        <Section title={t('ui.intensitycredits.status')}>
          <Flex direction="column">
            <Flex.Item>{t('ui.intensity_credits.intensity_credits')}: {current_credits}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.next_event')}: {next_run}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.active_players')}: {active_players}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.highpop_threshold')}: {highpop_players}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.highpop_multiplier')}: {highpop_multiplier}x</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.midpop_threshold')}: {midpop_players}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.midpop_multiplier')}: {midpop_multiplier}x</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.lowpop_threshold')}: {lowpop_players}</Flex.Item>
            <Flex.Item>{t('ui.intensity_credits.lowpop_multiplier')}: {lowpop_multiplier}x</Flex.Item>
          </Flex>
        </Section>
        <Section title={t('ui.intensitycredits.configuration')}>
          <NoticeBox>
            {t('ui.intensity_credits.config_notice_line_1')}
            <br />
            {t('ui.intensity_credits.config_notice_line_2')}
          </NoticeBox>
        </Section>
      </Window.Content>
    </Window>
  );
};
