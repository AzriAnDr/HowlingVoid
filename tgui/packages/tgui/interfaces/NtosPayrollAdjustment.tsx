import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

type AdjustmentMode = 'amount' | 'percent';
type PayrollTab = 'adjustment' | 'history' | 'overview' | 'budgets';

type PayrollAccount = {
  id: string;
  name: string;
  job: string;
  department: string;
  balance: number;
  base_paycheck: number;
  adjustment: number;
  current_paycheck: number;
  basis: string | null;
  reason: string | null;
  authorized_by: string | null;
};

type PayrollLog = {
  time: string;
  employee: string;
  job: string;
  adjustment: number;
  new_paycheck: number;
  basis: string;
  reason: string;
  authorized_by: string;
};

type DepartmentBudget = {
  id: string;
  name: string;
  balance: number;
  role: string;
  is_station: BooleanLike;
  is_cargo: BooleanLike;
};

type PayrollData = {
  authed: BooleanLike;
  station_budget: number;
  total_department_budget: number;
  visible_station_budget: number;
  max_adjustment: number;
  positive_adjustments: number;
  basis_options: string[];
  accounts: PayrollAccount[];
  department_budgets: DepartmentBudget[];
  payroll_log: PayrollLog[];
};

const formatCredits = (value: number) => `${value} cr`;

const payrollKey = (key: string) => `ui.ntos_payroll_adjustment.${key}`;

const basisLabel = (
  t: (key: string, fallback?: string) => string,
  basis: string,
) => t(payrollKey(`basis_${basis.toLowerCase().replaceAll(' ', '_')}`), basis);

const clamp = (value: number, min: number, max: number) =>
  Math.min(Math.max(value, min), max);

const panelStyle = {
  background: 'rgba(4, 18, 30, 0.86)',
  border: '1px solid rgba(88, 142, 181, 0.32)',
  borderRadius: '4px',
  boxShadow: 'inset 0 0 18px rgba(55, 139, 210, 0.08)',
};

export const NtosPayrollAdjustment = () => {
  const { t } = usePreferencesLocalization();

  return (
    <NtosWindow title={t(payrollKey('window_title'))} width={980} height={620}>
      <NtosWindow.Content scrollable>
        <PayrollAdjustmentContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const PayrollAdjustmentContent = () => {
  const { data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const { authed, accounts = [] } = data;

  if (!authed) {
    return <NoticeBox danger>{t(payrollKey('access_required'))}</NoticeBox>;
  }

  if (!accounts.length) {
    return <NoticeBox>{t(payrollKey('no_payable_accounts'))}</NoticeBox>;
  }

  return <PayrollConsole />;
};

const PayrollConsole = () => {
  const { data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const { accounts = [], station_budget, positive_adjustments } = data;
  const [tab, setTab] = useState<PayrollTab>('adjustment');
  const [selectedId, setSelectedId] = useState(accounts[0]?.id);

  const selectedAccount =
    accounts.find((account) => account.id === selectedId) || accounts[0];

  return (
    <Stack fill vertical>
      <Stack.Item>
        <PayrollHeader />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width="300px">
            <Stack fill vertical>
              <Stack.Item grow>
                <Section fill style={panelStyle}>
                  <Button
                    fluid
                    icon="sliders"
                    selected={tab === 'adjustment'}
                    onClick={() => setTab('adjustment')}
                  >
                    {t(payrollKey('tab_adjustment'))}
                  </Button>
                  <Button
                    fluid
                    icon="clock-rotate-left"
                    selected={tab === 'history'}
                    onClick={() => setTab('history')}
                  >
                    {t(payrollKey('tab_history'))}
                  </Button>
                  <Button
                    fluid
                    icon="users"
                    selected={tab === 'overview'}
                    onClick={() => setTab('overview')}
                  >
                    {t(payrollKey('tab_overview'))}
                  </Button>
                  <Button
                    fluid
                    icon="building-columns"
                    selected={tab === 'budgets'}
                    onClick={() => setTab('budgets')}
                  >
                    {t(payrollKey('tab_budgets'), 'Budgets')}
                  </Button>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <BudgetCard
                  stationBudget={station_budget}
                  positiveAdjustments={positive_adjustments}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'adjustment' && (
              <AdjustmentTab
                selectedAccount={selectedAccount}
                selectedId={selectedId}
                setSelectedId={setSelectedId}
              />
            )}
            {tab === 'history' && <HistoryTab />}
            {tab === 'overview' && <OverviewTab />}
            {tab === 'budgets' && <BudgetsTab />}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PayrollHeader = () => {
  const { t } = usePreferencesLocalization();

  return (
    <Box
      p={2}
      style={{
        background: 'linear-gradient(90deg, #06345d, #041b31 70%)',
        border: '1px solid rgba(80, 155, 220, 0.38)',
        borderRadius: '4px',
      }}
    >
      <Stack align="center">
        <Stack.Item>
          <Box
            p={1.5}
            style={{
              background: '#4ba0ff',
              borderRadius: '50%',
              color: '#061625',
              width: '42px',
              height: '42px',
              textAlign: 'center',
            }}
          >
            <Icon name="dollar-sign" size={2} />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Box fontSize="22px" bold>
            {t(payrollKey('header_title'))}
          </Box>
          <Box color="label">{t(payrollKey('header_subtitle'))}</Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const BudgetCard = (props: {
  stationBudget: number;
  positiveAdjustments: number;
}) => {
  const { t } = usePreferencesLocalization();
  const { stationBudget, positiveAdjustments } = props;
  const projected = stationBudget - positiveAdjustments;

  return (
    <Section title={t(payrollKey('station_budget'))} style={panelStyle}>
      <Stack vertical>
        <Stack.Item>
          <Box color="label">{t(payrollKey('current_balance'))}</Box>
          <Box
            color={stationBudget > 0 ? 'green' : 'red'}
            fontSize="18px"
            bold
            nowrap
          >
            {formatCredits(stationBudget)}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box color="label">{t(payrollKey('payroll_uplift'))}</Box>
          <Box color={positiveAdjustments > 0 ? 'red' : 'label'} nowrap>
            {formatCredits(positiveAdjustments)} / {t(payrollKey('payday'))}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box color="label">{t(payrollKey('available_after_payroll'))}</Box>
          <Box
            color={projected >= 0 ? 'green' : 'red'}
            fontSize="18px"
            bold
            nowrap
          >
            {formatCredits(projected)}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AdjustmentTab = (props: {
  selectedAccount: PayrollAccount;
  selectedId: string;
  setSelectedId: (id: string) => void;
}) => {
  const { act, data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const { accounts = [], basis_options = [], max_adjustment } = data;
  const { selectedAccount, selectedId, setSelectedId } = props;
  const [direction, setDirection] = useState(
    selectedAccount.adjustment < 0 ? -1 : 1,
  );
  const [mode, setMode] = useState<AdjustmentMode>('amount');
  const [amount, setAmount] = useState(Math.abs(selectedAccount.adjustment));
  const [percent, setPercent] = useState(
    selectedAccount.base_paycheck
      ? Math.round(
          (Math.abs(selectedAccount.adjustment) /
            selectedAccount.base_paycheck) *
            100,
        )
      : 0,
  );
  const [basis, setBasis] = useState(
    selectedAccount.basis || basis_options[0] || 'Performance',
  );
  const [reason, setReason] = useState(
    selectedAccount.basis === 'Other' ? selectedAccount.reason || '' : '',
  );

  const signedAmount = direction * Math.abs(amount);
  const signedPercent = direction * Math.abs(percent);
  const rawAdjustment =
    mode === 'percent'
      ? Math.round((selectedAccount.base_paycheck * signedPercent) / 100)
      : signedAmount;
  const adjustment = clamp(
    rawAdjustment,
    -selectedAccount.base_paycheck,
    max_adjustment,
  );
  const projectedPaycheck = selectedAccount.base_paycheck + adjustment;
  const budgetImpact = Math.max(0, adjustment);
  const maxPercent = selectedAccount.base_paycheck
    ? Math.max(
        0,
        Math.round((max_adjustment / selectedAccount.base_paycheck) * 100),
      )
    : 0;
  const reasonRequired = basis === 'Other';
  const submittedReason = reasonRequired ? reason.trim() : basis;
  const canSubmit = !!basis && (!reasonRequired || reason.trim().length > 0);

  const resetForAccount = (account: PayrollAccount) => {
    setSelectedId(account.id);
    setDirection(account.adjustment < 0 ? -1 : 1);
    setMode('amount');
    setAmount(Math.abs(account.adjustment));
    setPercent(
      account.base_paycheck
        ? Math.round(
            (Math.abs(account.adjustment) / account.base_paycheck) * 100,
          )
        : 0,
    );
    setBasis(account.basis || basis_options[0] || 'Performance');
    setReason(account.basis === 'Other' ? account.reason || '' : '');
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title={t(payrollKey('employee_selection'))} style={panelStyle}>
          <Dropdown
            fluid
            options={accounts.map((account) => account.name)}
            selected={selectedAccount.name}
            onSelected={(name) => {
              const account = accounts.find((entry) => entry.name === name);
              if (account) {
                resetForAccount(account);
              }
            }}
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section style={panelStyle}>
          <Stack align="center">
            <Stack.Item width="44px">
              <Box
                textAlign="center"
                py={1}
                style={{
                  border: '1px solid rgba(85, 141, 186, 0.42)',
                  borderRadius: '4px',
                  background: 'rgba(14, 36, 56, 0.9)',
                }}
              >
                <Icon name="id-card" size={2} />
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box fontSize="18px" bold>
                {selectedAccount.name}
              </Box>
              <Box color="label">{selectedAccount.job}</Box>
              <Box color="label">
                {t(payrollKey('id_label'))}: {selectedAccount.id}
              </Box>
            </Stack.Item>
            <Stack.Item width="145px">
              <Box color="label">{t(payrollKey('current_paycheck'))}</Box>
              <Box fontSize="16px" bold>
                {formatCredits(selectedAccount.current_paycheck)}
              </Box>
            </Stack.Item>
            <Stack.Item width="130px">
              <Box color="label">{t(payrollKey('base_paycheck'))}</Box>
              <Box fontSize="16px" color="blue" bold>
                {formatCredits(selectedAccount.base_paycheck)}
              </Box>
            </Stack.Item>
            <Stack.Item width="130px">
              <Box color="label">{t(payrollKey('account_balance'))}</Box>
              <Box fontSize="16px">
                {formatCredits(selectedAccount.balance)}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={t(payrollKey('adjustment_type'))} style={panelStyle}>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="arrow-up"
                color="green"
                selected={direction > 0}
                onClick={() => setDirection(1)}
              >
                {t(payrollKey('increase_salary'))}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="arrow-down"
                color="red"
                selected={direction < 0}
                onClick={() => setDirection(-1)}
              >
                {t(payrollKey('decrease_salary'))}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width="40%">
            <Section fill title={t(payrollKey('basis'))} style={panelStyle}>
              <Stack vertical>
                {basis_options.map((option) => (
                  <Stack.Item key={option}>
                    <Button
                      fluid
                      icon={basis === option ? 'circle-dot' : 'circle'}
                      selected={basis === option}
                      onClick={() => {
                        setBasis(option);
                        setReason(option === 'Other' ? '' : option);
                      }}
                    >
                      {basisLabel(t, option)}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              title={t(payrollKey('adjustment_parameters'))}
              style={panelStyle}
            >
              <Stack vertical>
                <Stack.Item>
                  <Button
                    icon="coins"
                    selected={mode === 'amount'}
                    onClick={() => setMode('amount')}
                  >
                    {t(payrollKey('amount_mode'))}
                  </Button>
                  <Button
                    icon="percent"
                    selected={mode === 'percent'}
                    onClick={() => setMode('percent')}
                  >
                    {t(payrollKey('percent_mode'))}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  {mode === 'amount' ? (
                    <LabeledList>
                      <LabeledList.Item label={t(payrollKey('amount_label'))}>
                        <NumberInput
                          width="90px"
                          minValue={0}
                          maxValue={
                            direction > 0
                              ? max_adjustment
                              : selectedAccount.base_paycheck
                          }
                          step={1}
                          value={Math.abs(amount)}
                          onChange={setAmount}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  ) : (
                    <LabeledList>
                      <LabeledList.Item label={t(payrollKey('percent_label'))}>
                        <NumberInput
                          width="90px"
                          minValue={0}
                          maxValue={direction > 0 ? maxPercent : 100}
                          step={1}
                          value={Math.abs(percent)}
                          onChange={setPercent}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label={t(payrollKey('new_paycheck'))}>
                      <Box
                        color={
                          projectedPaycheck > selectedAccount.base_paycheck
                            ? 'green'
                            : projectedPaycheck < selectedAccount.base_paycheck
                              ? 'red'
                              : 'label'
                        }
                        fontSize="20px"
                        bold
                      >
                        {formatCredits(projectedPaycheck)}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label={t(payrollKey('delta'))}>
                      <Box color={adjustment >= 0 ? 'green' : 'red'}>
                        {adjustment >= 0 ? '+' : ''}
                        {formatCredits(adjustment)}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={t(payrollKey('station_budget_cost'))}
                    >
                      <Box color={budgetImpact > 0 ? 'red' : 'label'}>
                        {formatCredits(budgetImpact)} /{' '}
                        {t(payrollKey('payday'))}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section title={t(payrollKey('reason'))} style={panelStyle}>
          <TextArea
            fluid
            height="86px"
            disabled={!reasonRequired}
            value={reasonRequired ? reason : basisLabel(t, basis)}
            onChange={setReason}
            placeholder={
              reasonRequired
                ? t(payrollKey('reason_required_placeholder'))
                : t(payrollKey('reason_basis_placeholder'))
            }
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow />
          <Stack.Item width="180px">
            <Button
              fluid
              icon="rotate-left"
              onClick={() => resetForAccount(selectedAccount)}
            >
              {t(payrollKey('cancel'))}
            </Button>
          </Stack.Item>
          <Stack.Item width="250px">
            <Button
              fluid
              color="green"
              icon="check"
              disabled={!canSubmit}
              onClick={() =>
                act('set_adjustment', {
                  account_id: selectedId,
                  mode,
                  amount: signedAmount,
                  percent: signedPercent,
                  basis,
                  reason: submittedReason,
                })
              }
            >
              {t(payrollKey('confirm_adjustment'))}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const HistoryTab = () => {
  const { data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const { payroll_log = [] } = data;

  return (
    <Section
      fill
      scrollable
      title={t(payrollKey('change_history'))}
      style={panelStyle}
    >
      {!payroll_log.length && (
        <NoticeBox info>{t(payrollKey('no_changes'))}</NoticeBox>
      )}
      <Table>
        {payroll_log.map((entry, index) => (
          <Table.Row key={index} className="candystripe">
            <Table.Cell collapsing color="label">
              {entry.time}
            </Table.Cell>
            <Table.Cell>
              <Box bold>{entry.employee}</Box>
              <Box color="label">
                {entry.job} | {basisLabel(t, entry.basis)} |{' '}
                {t(payrollKey('by_author'))} {entry.authorized_by}
              </Box>
              <Box>{entry.reason}</Box>
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Box color={entry.adjustment >= 0 ? 'green' : 'red'}>
                {entry.adjustment >= 0 ? '+' : ''}
                {formatCredits(entry.adjustment)}
              </Box>
              <Box color="label">{formatCredits(entry.new_paycheck)}</Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BudgetsTab = () => {
  const { data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const {
    department_budgets = [],
    total_department_budget = 0,
    visible_station_budget = 0,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={t(payrollKey('budget_summary'), 'Budget Summary')}
          style={panelStyle}
        >
          <Stack>
            <Stack.Item grow>
              <Box color="label">
                {t(payrollKey('department_total'), 'Department Total')}
              </Box>
              <Box fontSize="20px" bold>
                {formatCredits(total_department_budget)}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box color="label">
                {t(
                  payrollKey('visible_station_budget'),
                  'Visible Station Budget',
                )}
              </Box>
              <Box fontSize="20px" bold>
                {formatCredits(visible_station_budget)}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={t(payrollKey('department_budgets'), 'Department Budgets')}
          style={panelStyle}
        >
          <Table>
            <Table.Row header>
              <Table.Cell>
                {t(payrollKey('department'), 'Department')}
              </Table.Cell>
              <Table.Cell>{t(payrollKey('role'), 'Role')}</Table.Cell>
              <Table.Cell textAlign="right">
                {t(payrollKey('balance'), 'Balance')}
              </Table.Cell>
            </Table.Row>
            {department_budgets.map((budget) => (
              <Table.Row key={budget.id} className="candystripe">
                <Table.Cell>
                  <Box bold>{budget.name}</Box>
                  <Box color="label">{budget.id}</Box>
                </Table.Cell>
                <Table.Cell>
                  <Box
                    color={
                      budget.is_station
                        ? 'blue'
                        : budget.is_cargo
                          ? 'orange'
                          : 'label'
                    }
                  >
                    {budget.role}
                  </Box>
                </Table.Cell>
                <Table.Cell textAlign="right">
                  <Box color={budget.balance > 0 ? 'green' : 'red'} bold>
                    {formatCredits(budget.balance)}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const OverviewTab = () => {
  const { data } = useBackend<PayrollData>();
  const { t } = usePreferencesLocalization(data);
  const { accounts = [] } = data;

  return (
    <Section
      fill
      scrollable
      title={t(payrollKey('payroll_overview'))}
      style={panelStyle}
    >
      <Table>
        <Table.Row header>
          <Table.Cell>{t(payrollKey('name'))}</Table.Cell>
          <Table.Cell>{t(payrollKey('assignment'))}</Table.Cell>
          <Table.Cell textAlign="right">{t(payrollKey('base'))}</Table.Cell>
          <Table.Cell textAlign="right">
            {t(payrollKey('adjustment'))}
          </Table.Cell>
          <Table.Cell textAlign="right">{t(payrollKey('current'))}</Table.Cell>
        </Table.Row>
        {accounts.map((account) => (
          <Table.Row key={account.id} className="candystripe">
            <Table.Cell>
              <Box bold>{account.name}</Box>
              <Box color="label">
                {t(payrollKey('id_label'))}: {account.id}
              </Box>
            </Table.Cell>
            <Table.Cell>{account.job}</Table.Cell>
            <Table.Cell textAlign="right">
              {formatCredits(account.base_paycheck)}
            </Table.Cell>
            <Table.Cell textAlign="right">
              <Box
                color={
                  account.adjustment > 0
                    ? 'green'
                    : account.adjustment < 0
                      ? 'red'
                      : 'label'
                }
              >
                {account.adjustment > 0 ? '+' : ''}
                {formatCredits(account.adjustment)}
              </Box>
            </Table.Cell>
            <Table.Cell textAlign="right">
              {formatCredits(account.current_paycheck)}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
