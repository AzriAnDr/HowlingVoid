import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const TransferValve = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { tank_one, tank_two, attached_device, valve } = data;
  return (
    <Window width={310} height={300}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.transfer_valve.valve_status')}>
              <Button
                icon={valve ? 'unlock' : 'lock'}
                content={valve ? t('ui.common.open') : t('ui.common.closed')}
                disabled={!tank_one || !tank_two}
                onClick={() => act('toggle')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.transfer_valve.valve_attachment')}
          buttons={
            <Button
              content={t('ui.common.configure')}
              icon={'cog'}
              disabled={!attached_device}
              onClick={() => act('device')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.transfer_valve.attachment')}>
              {attached_device ? (
                <Button
                  icon={'eject'}
                  content={attached_device}
                  disabled={!attached_device}
                  onClick={() => act('remove_device')}
                />
              ) : (
                <Box color="average">{t('ui.transfer_valve.no_assembly')}</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.transfer_valve.attachment_one')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.transfer_valve.attachment')}>
              {tank_one ? (
                <Button
                  icon={'eject'}
                  content={tank_one}
                  disabled={!tank_one}
                  onClick={() => act('tankone')}
                />
              ) : (
                <Box color="average">{t('ui.transfer_valve.no_tank')}</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.transfer_valve.attachment_two')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.transfer_valve.attachment')}>
              {tank_two ? (
                <Button
                  icon={'eject'}
                  content={tank_two}
                  disabled={!tank_two}
                  onClick={() => act('tanktwo')}
                />
              ) : (
                <Box color="average">{t('ui.transfer_valve.no_tank')}</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
