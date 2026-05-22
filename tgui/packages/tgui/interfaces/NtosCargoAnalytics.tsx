import { Box, LabeledList, NoticeBox, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type BreakdownEntry = {
  source: string;
  amount: number;
};

type EconomySnapshot = {
  time: string;
  cargo_balance: number;
  gross_station_product: number;
  corporate_surplus: number;
  crew_consumption: number;
  price_index: number;
  station_total: number;
  wage_share: number;
  cargo_exports: number;
  cargo_import_costs: number;
  cargo_income: number;
};

type CargoAnalyticsData = {
  cargo_budget: number;
  gross_station_product: number;
  corporate_surplus: number;
  crew_consumption: number;
  price_index: number;
  soft_price_index: number;
  price_reason: string;
  money_pressure: number;
  spending_pressure: number;
  wage_share: number;
  employee_wage_pool: number;
  station_total: number;
  cargo_exports: number;
  bounty_exports: number;
  cargo_import_costs: number;
  cargo_income: number;
  economic_shock_name: string;
  economic_shock_report: string;
  history: EconomySnapshot[];
  event_breakdown: BreakdownEntry[];
  source_breakdown: BreakdownEntry[];
  department_income: BreakdownEntry[];
};

const formatPercent = (value: number) => `${Math.round((value || 0) * 1000) / 10}%`;
const formatIndex = (value: number) => `${Math.round((value || 0) * 100) / 100}x`;

const analyticsKey = (key: string) => `ui.ntos_cargo_analytics.${key}`;

const normalizeKey = (value: string | undefined) =>
  (value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');

const Sparkline = (props: {
  data: EconomySnapshot[];
  field: keyof EconomySnapshot;
  color?: string;
  waitingLabel: string;
}) => {
  const { data, field, color = '#6aa9ff', waitingLabel } = props;
  const values = data
    .map((entry) => Number(entry[field]) || 0)
    .filter((value) => Number.isFinite(value));

  if (values.length < 2) {
    return <Box color="label">{waitingLabel}</Box>;
  }

  const width = 220;
  const height = 48;
  const min = Math.min(...values);
  const max = Math.max(...values);
  const span = Math.max(max - min, 1);
  const points = values
    .map((value, index) => {
      const x = (index / Math.max(values.length - 1, 1)) * width;
      const y = height - ((value - min) / span) * (height - 8) - 4;
      return `${x},${y}`;
    })
    .join(' ');

  return (
    <svg width="100%" height={height} viewBox={`0 0 ${width} ${height}`}>
      <polyline
        fill="none"
        points={points}
        stroke={color}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="2"
      />
    </svg>
  );
};

const BreakdownTable = (props: {
  title: string;
  entries: BreakdownEntry[];
  emptyLabel: string;
  formatCredits: (value: number) => string;
}) => {
  const { title, entries = [], emptyLabel, formatCredits } = props;
  return (
    <Section title={title}>
      {entries.length === 0 ? (
        <Box color="label">{emptyLabel}</Box>
      ) : (
        <Table>
          {entries.slice(0, 8).map((entry) => (
            <Table.Row key={entry.source} className="candystripe">
              <Table.Cell>{entry.source}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatCredits(entry.amount)}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

export const NtosCargoAnalytics = () => {
  const { data } = useBackend<CargoAnalyticsData>();
  const { t } = usePreferencesLocalization(data);
  const history = data.history || [];
  const creditsShort = t('ui.common.credits_short', 'cr');
  const formatCredits = (value: number) =>
    `${Math.round(value || 0)} ${creditsShort}`;
  const priceReasonKey = normalizeKey(data.price_reason);
  const priceReason =
    data.price_reason &&
    t(analyticsKey(`reason_${priceReasonKey}`), data.price_reason);
  const shockKey = normalizeKey(data.economic_shock_name);
  const shockName =
    data.economic_shock_name &&
    t(analyticsKey(`shock_name_${shockKey}`), data.economic_shock_name);
  const shockReport =
    data.economic_shock_name &&
    t(analyticsKey(`shock_report_${shockKey}`), data.economic_shock_report);

  return (
    <NtosWindow title={t(analyticsKey('window_title'))} width={760} height={640}>
      <NtosWindow.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <NoticeBox>{t(analyticsKey('notice'))}</NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Section title={t(analyticsKey('cargo_position'))}>
                  <LabeledList>
                    <LabeledList.Item label={t(analyticsKey('cargo_budget'))}>
                      {formatCredits(data.cargo_budget)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('cargo_exports'))}>
                      {formatCredits(data.cargo_exports)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('cargo_import_costs'))}>
                      {formatCredits(data.cargo_import_costs)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('cargo_income'))}>
                      {formatCredits(data.cargo_income)}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section title={t(analyticsKey('station_economy'))}>
                  <LabeledList>
                    <LabeledList.Item label={t(analyticsKey('gsp'))}>
                      {formatCredits(data.gross_station_product)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('corporate_surplus'))}>
                      {formatCredits(data.corporate_surplus)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('consumption'))}>
                      {formatCredits(data.crew_consumption)}
                    </LabeledList.Item>
                    <LabeledList.Item label={t(analyticsKey('wage_share'))}>
                      {formatPercent(data.wage_share)}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section title={t(analyticsKey('price_pressure'))}>
              <LabeledList>
                <LabeledList.Item label={t(analyticsKey('effective_index'))}>
                  {formatIndex(data.price_index)}
                </LabeledList.Item>
                <LabeledList.Item label={t(analyticsKey('soft_index'))}>
                  {formatIndex(data.soft_price_index)}
                </LabeledList.Item>
                <LabeledList.Item label={t(analyticsKey('reason'))}>
                  {priceReason || t(analyticsKey('reason_stable'))}
                </LabeledList.Item>
                <LabeledList.Item label={t(analyticsKey('money_pressure'))}>
                  {formatIndex(data.money_pressure)}
                </LabeledList.Item>
                <LabeledList.Item label={t(analyticsKey('spending_pressure'))}>
                  {formatIndex(data.spending_pressure)}
                </LabeledList.Item>
              </LabeledList>
              {!!data.economic_shock_report && (
                <Box mt={1} color="average">
                  {shockName || data.economic_shock_name}:{' '}
                  {shockReport || data.economic_shock_report}
                </Box>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Section title={t(analyticsKey('cargo_budget_trend'))}>
                  <Sparkline
                    data={history}
                    field="cargo_balance"
                    waitingLabel={t(analyticsKey('waiting_for_ticks'))}
                  />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section title={t(analyticsKey('gsp_trend'))}>
                  <Sparkline
                    color="#7fd17f"
                    data={history}
                    field="gross_station_product"
                    waitingLabel={t(analyticsKey('waiting_for_ticks'))}
                  />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section title={t(analyticsKey('price_index_trend'))}>
                  <Sparkline
                    color="#ffd166"
                    data={history}
                    field="price_index"
                    waitingLabel={t(analyticsKey('waiting_for_ticks'))}
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <BreakdownTable
                  emptyLabel={t(analyticsKey('no_activity'))}
                  entries={data.event_breakdown}
                  formatCredits={formatCredits}
                  title={t(analyticsKey('activity_by_category'))}
                />
              </Stack.Item>
              <Stack.Item grow>
                <BreakdownTable
                  emptyLabel={t(analyticsKey('no_activity'))}
                  entries={data.source_breakdown}
                  formatCredits={formatCredits}
                  title={t(analyticsKey('activity_by_source'))}
                />
              </Stack.Item>
              <Stack.Item grow>
                <BreakdownTable
                  emptyLabel={t(analyticsKey('no_activity'))}
                  entries={data.department_income}
                  formatCredits={formatCredits}
                  title={t(analyticsKey('department_income'))}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
