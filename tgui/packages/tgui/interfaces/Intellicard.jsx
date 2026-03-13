import {
  BlockQuote,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Intellicard = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const {
    name,
    isDead,
    isBraindead,
    health,
    wireless,
    radio,
    wiping,
    laws = [],
  } = data;
  const offline = isDead || isBraindead;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <Section
          title={name || t('ui.intellicard.empty_card')}
          buttons={
            !!name && (
              <Button
                icon="trash"
                content={
                  wiping ? t('ui.intellicard.stop_wiping') : t('ui.intellicard.wipe')
                }
                disabled={isDead}
                onClick={() => act('wipe')}
              />
            )
          }
        >
          {!!name && (
            <LabeledList>
              <LabeledList.Item label={t('ui.common.status')} color={offline ? 'bad' : 'good'}>
                {offline ? t('ui.common.offline') : t('ui.intellicard.operational')}
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.intellicard.software_integrity')}>
                <ProgressBar
                  value={health}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    good: [70, Infinity],
                    average: [50, 70],
                    bad: [-Infinity, 50],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.common.settings')}>
                <Button
                  icon="signal"
                  content={t('ui.intellicard.wireless_activity')}
                  selected={wireless}
                  onClick={() => act('wireless')}
                />
                <Button
                  icon="microphone"
                  content={t('ui.intellicard.subspace_radio')}
                  selected={radio}
                  onClick={() => act('radio')}
                />
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.common.laws')}>
                {laws.map((law) => (
                  <BlockQuote key={law}>{law}</BlockQuote>
                ))}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
