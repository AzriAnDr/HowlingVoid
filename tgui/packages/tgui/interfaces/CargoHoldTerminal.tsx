import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  points: number;
  pad: string;
  sending: BooleanLike;
  status_report: string;
};

export const CargoHoldTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { points, pad, sending, status_report } = data;

  return (
    <Window width={600} height={230}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.cargo_hold_terminal.current_cargo_value')}>
              <Box inline bold>
                <AnimatedNumber value={Math.round(points)} /> {t('ui.common.credits')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.cargo_hold_terminal.cargo_pad')}
          buttons={
            <>
              <Button
                icon={'sync'}
                content={t('ui.cargo_hold_terminal.recalculate_value')}
                disabled={!pad}
                onClick={() => act('recalc')}
              />
              <Button
                icon={sending ? 'times' : 'arrow-up'}
                content={
                  sending
                    ? t('ui.cargo_hold_terminal.stop_sending')
                    : t('ui.cargo_hold_terminal.send_goods')
                }
                selected={sending}
                disabled={!pad}
                onClick={() => act(sending ? 'stop' : 'send')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.status')} color={pad ? 'good' : 'bad'}>
              {pad ? t('ui.common.online') : t('ui.common.not_found')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.cargo_hold_terminal.cargo_report')}>
              {status_report}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
