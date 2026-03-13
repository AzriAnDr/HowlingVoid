import {
  Box,
  Button,
  Dimmer,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosJobManager = (props) => {
  return (
    <NtosWindow width={400} height={620}>
      <NtosWindow.Content scrollable>
        <NtosJobManagerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosJobManagerContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { authed, cooldown, slots = [], prioritized = [] } = data;
  if (!authed) {
    return (
      <NoticeBox>
        {t('ui.ntos_job_manager.no_access_to_change_job_slots')}
      </NoticeBox>
    );
  }
  return (
    <Section>
      {cooldown > 0 && (
        <Dimmer>
          <Box bold textAlign="center" fontSize="20px">
            {t('ui.ntos_job_manager.on_cooldown')}: {cooldown}s
          </Box>
        </Dimmer>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>{t('ui.ntos_job_manager.prioritized')}</Table.Cell>
          <Table.Cell>{t('ui.ntos_job_manager.slots')}</Table.Cell>
        </Table.Row>
        {slots.map((slot) => (
          <Table.Row key={slot.title} className="candystripe">
            <Table.Cell bold>
              <Button.Checkbox
                fluid
                content={slot.title}
                disabled={slot.total <= 0}
                checked={slot.total > 0 && prioritized.includes(slot.title)}
                onClick={() =>
                  act('PRG_priority', {
                    target: slot.title,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell collapsing>
              {slot.current} / {slot.total}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content={t('ui.common.open')}
                disabled={!slot.status_open}
                onClick={() =>
                  act('PRG_open_job', {
                    target: slot.title,
                  })
                }
              />
              <Button
                content={t('ui.common.close')}
                disabled={!slot.status_close}
                onClick={() =>
                  act('PRG_close_job', {
                    target: slot.title,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
