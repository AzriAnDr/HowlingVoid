import { Box, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { Data, SourceBreakdown } from './types';

const formatCredits = (value: number) => `${Math.round(value || 0)} cr`;

const formatPercent = (value: number) => `${((value || 0) * 100).toFixed(1)}%`;

const macroKey = (key: string) => `ui.accounting_macro.${key}`;

const normalizeKey = (value: string | undefined) =>
  (value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');

const SourceTable = (props: {
  title: string;
  rows: SourceBreakdown[];
  emptyLabel: string;
}) => {
  const { title, rows, emptyLabel } = props;

  return (
    <Section title={title} fill>
      <Table>
        {(rows || []).map((row, index) => (
          <Table.Row key={`${title}_${row.source}_${index}`}>
            <Table.Cell>{row.source}</Table.Cell>
            <Table.Cell textAlign="right">{formatCredits(row.amount)}</Table.Cell>
          </Table.Row>
        ))}
        {!rows?.length && (
          <Table.Row>
            <Table.Cell color="label">{emptyLabel}</Table.Cell>
          </Table.Row>
        )}
      </Table>
    </Section>
  );
};

export const MacroScreen = () => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { macro } = data;
  const hardshipKey = normalizeKey(macro.hardship_status);
  const shockKey = normalizeKey(macro.economic_shock_name);
  const hardshipStatus =
    macro.hardship_status &&
    t(macroKey(`hardship_status_${hardshipKey}`), macro.hardship_status);
  const hardshipCommentary =
    macro.hardship_status &&
    t(
      macroKey(`hardship_commentary_${hardshipKey}`),
      macro.hardship_commentary,
    );
  const shockName =
    macro.economic_shock_name &&
    t(macroKey(`shock_name_${shockKey}`), macro.economic_shock_name);
  const shockReport =
    macro.economic_shock_name &&
    t(macroKey(`shock_report_${shockKey}`), macro.economic_shock_report);

  return (
    <Section scrollable fill>
      <Stack vertical>
        <Stack.Item>
          <Box bold>{t(macroKey('projection'))}</Box>
          <Box color="label">
            {t(macroKey('austerity_parameters'))}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Table>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('gross_station_product'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.gross_station_product)}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('real_gsp'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.real_station_product)}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('corporate_surplus'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.corporate_surplus)}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('wage_share'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatPercent(macro.wage_share)}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('employee_wage_pool'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.employee_wage_pool)}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('crew_consumption'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.crew_consumption)}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('basket_price'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.basket_price)}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('price_index'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {(macro.price_index || 0).toFixed(2)}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('average_paycheck'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {formatCredits(macro.average_paycheck)}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('paycheck_baskets'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {(macro.paycheck_pps || 0).toFixed(2)}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>{t(macroKey('poverty_signal'))}</Table.Cell>
              <Table.Cell textAlign="right">
                {macro.poverty_count}/{macro.crew_account_count}
              </Table.Cell>
              <Table.Cell bold>{t(macroKey('status'))}</Table.Cell>
              <Table.Cell textAlign="right">{t(macroKey('efficient'))}</Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>
        <Stack.Item>
          <Section title={t(macroKey('crew_hardship_index'))}>
            <Stack vertical>
              <Stack.Item>
                <Box bold>
                  {hardshipStatus || t(macroKey('hardship_status_contained'))}
                </Box>
                <Box color="label">
                  {hardshipCommentary ||
                    t(macroKey('hardship_commentary_contained'))}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Table>
                  <Table.Row>
                    <Table.Cell bold>{t(macroKey('average_paycheck'))}</Table.Cell>
                    <Table.Cell textAlign="right">
                      {formatCredits(macro.average_paycheck)}
                    </Table.Cell>
                    <Table.Cell bold>{t(macroKey('basket_price'))}</Table.Cell>
                    <Table.Cell textAlign="right">
                      {formatCredits(macro.basket_price)}
                    </Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell bold>
                      {t(macroKey('paycheck_purchasing_power'))}
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      {(macro.paycheck_pps || 0).toFixed(2)}{' '}
                      {t(macroKey('baskets'))}
                    </Table.Cell>
                    <Table.Cell bold>{t(macroKey('poverty_count'))}</Table.Cell>
                    <Table.Cell textAlign="right">
                      {macro.poverty_count}/{macro.crew_account_count}
                    </Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell bold>{t(macroKey('wage_share'))}</Table.Cell>
                    <Table.Cell textAlign="right">
                      {formatPercent(macro.wage_share)}
                    </Table.Cell>
                    <Table.Cell bold>{t(macroKey('corporate_finding'))}</Table.Cell>
                    <Table.Cell textAlign="right">
                      {t(macroKey('acceptable'))}
                    </Table.Cell>
                  </Table.Row>
                </Table>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        {!!macro.economic_shock_report && (
          <Stack.Item>
            <Section title={shockName || t(macroKey('economic_shock'))}>
              <Box>{shockReport || macro.economic_shock_report}</Box>
            </Section>
          </Stack.Item>
        )}
        <Stack.Item>
          <Box italic>{t(macroKey('poverty_efficiency_signal'))}</Box>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <SourceTable
                emptyLabel={t(macroKey('no_reportable_value'))}
                title={t(macroKey('gsp_sources'))}
                rows={macro.gsp_by_source}
              />
            </Stack.Item>
            <Stack.Item grow>
              <SourceTable
                emptyLabel={t(macroKey('no_reportable_value'))}
                title={t(macroKey('surplus_sources'))}
                rows={macro.corporate_surplus_by_source}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
