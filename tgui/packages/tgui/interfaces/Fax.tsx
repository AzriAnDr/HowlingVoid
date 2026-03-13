import { sortBy } from 'es-toolkit';
import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type FaxData = {
  faxes: FaxInfo[];
  fax_id: string;
  fax_name: string;
  visible: boolean;
  has_paper: string;
  syndicate_network: boolean;
  fax_history: FaxHistory[];
  special_faxes: FaxSpecial[];
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  visible: boolean;
  has_paper: boolean;
  syndicate_network: boolean;
};

type FaxHistory = {
  history_type: string;
  history_fax_name: string;
  history_time: string;
};

type FaxSpecial = {
  fax_name: string;
  fax_id: string;
  color: string;
  emag_needed: boolean;
};

export const Fax = (props) => {
  const { act } = useBackend();
  const { data } = useBackend<FaxData>();
  const { t } = usePreferencesLocalization(data);
  const faxes = data.faxes
    ? sortBy(
        data.syndicate_network
          ? data.faxes.filter((filterFax: FaxInfo) => filterFax.visible)
          : data.faxes.filter(
              (filterFax: FaxInfo) =>
                filterFax.visible && !filterFax.syndicate_network,
            ),
        [(sortFax: FaxInfo) => sortFax.fax_name],
      )
    : [];
  const special_networks = data.syndicate_network
    ? data.special_faxes
    : data.special_faxes.filter((fax: FaxSpecial) => !fax.emag_needed);
  return (
    <Window width={340} height={540}>
      <Window.Content scrollable>
        <Section title={t('ui.fax.about_fax')}>
          <LabeledList.Item label={t('ui.fax.network_name')}>
            {data.fax_name}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.fax.network_id')}>
            {data.fax_id}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.fax.visible_to_network')}>
            {data.visible ? t('ui.common.true') : t('ui.common.false')}
          </LabeledList.Item>
        </Section>
        <Section
          title={t('ui.common.paper')}
          buttons={
            <Button onClick={() => act('remove')} disabled={!data.has_paper}>
              {t('ui.common.remove')}
            </Button>
          }
        >
          <LabeledList.Item label={t('ui.common.paper')}>
            {data.has_paper ? (
              <Box color="green">{t('ui.fax.paper_in_tray')}</Box>
            ) : (
              <Box color="red">{t('ui.fax.no_paper')}</Box>
            )}
          </LabeledList.Item>
        </Section>
        <Section title={t('ui.common.send')}>
          {faxes.length === 0 && special_networks.length === 0 ? (
            t('ui.fax.no_other_faxes_detected')
          ) : (
            <Box mt={0.4}>
              {special_networks.map((special: FaxSpecial) => (
                <Button
                  key={special.fax_id}
                  tooltip={special.fax_name}
                  disabled={!data.has_paper}
                  color={special.color}
                  onClick={() =>
                    act('send_special', {
                      id: special.fax_id,
                      name: special.fax_name,
                    })
                  }
                >
                  {special.fax_name}
                </Button>
              ))}
              {faxes.length !== 0
                ? faxes.map((fax: FaxInfo) => (
                    <Button
                      key={fax.fax_id}
                      tooltip={fax.fax_name}
                      disabled={!data.has_paper}
                      color={fax.syndicate_network ? 'red' : 'blue'}
                      onClick={() =>
                        act('send', {
                          id: fax.fax_id,
                          name: fax.fax_name,
                        })
                      }
                    >
                      {fax.fax_name}
                    </Button>
                  ))
                : null}
            </Box>
          )}
        </Section>
        <Section
          title={t('ui.common.history')}
          buttons={
            <Button
              onClick={() => act('history_clear')}
              disabled={!data.fax_history}
            >
              {t('ui.common.clear')}
            </Button>
          }
        >
          <Table>
            <Table.Cell>
              {data.fax_history !== null
                ? data.fax_history.map((history: FaxHistory) => (
                    <Table.Row key={history.history_type}>
                      {
                        <Box
                          color={
                            history.history_type === 'Send' ? 'Green' : 'Red'
                          }
                        >
                          {history.history_type}
                        </Box>
                      }
                      {history.history_fax_name} - {history.history_time}
                    </Table.Row>
                  ))
                : null}
            </Table.Cell>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
