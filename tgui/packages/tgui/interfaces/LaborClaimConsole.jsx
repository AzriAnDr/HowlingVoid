import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const LaborClaimConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { can_go_home, id_points, ores, status_info, unclaimed_points } = data;
  return (
    <Window width={315} height={440}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.status')}>
              {status_info}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.labor_claim_console.shuttle_controls')}>
              <Button
                content={t('ui.labor_claim_console.move_shuttle')}
                disabled={!can_go_home}
                onClick={() => act('move_shuttle')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.labor_claim_console.points')}>
              {id_points}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.labor_claim_console.unclaimed_points')}
              buttons={
                <Button
                  content={t('ui.labor_claim_console.claim_points')}
                  disabled={!unclaimed_points}
                  onClick={() => act('claim_points')}
                />
              }
            >
              {unclaimed_points}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.labor_claim_console.directions')}>
          {t('ui.labor_claim_console.directions_line_1')}
          <br />
          {t('ui.labor_claim_console.directions_line_2')}
        </Section>
      </Window.Content>
    </Window>
  );
};
