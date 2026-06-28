import {
  Box,
  Button,
  Dropdown,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type HealthAnalyzerData = {
  scan_type: string;
  scan_type_name: string;
  target_name?: string;
  advanced: boolean;
  verbose: boolean;
  report?: string;
  refresh_interval?: number;
  refresh_options?: number[];
  target_dead?: boolean;
  target_health?: number;
  target_max_health?: number;
  health_percent?: number | null;
  brute_loss?: number;
  burn_loss?: number;
  toxin_loss?: number;
  oxygen_loss?: number;
  irradiated?: boolean;
  radiation_contamination?: string;
  radiation_contamination_activity?: number;
  chemical_reagents?: ChemicalReagent[];
  cybernetics?: CyberneticImplant[];
  insurance_visible?: boolean;
  insurance_has_account?: boolean;
  insurance_balance?: number;
  insurance_money_symbol?: string;
  insurance_status?: string;
  insurance_estimated_payout?: number;
  insurance_raw_total?: number;
  insurance_capped_total?: number;
  insurance_time_left?: string;
  insurance_claim_holder?: string;
  insurance_can_open?: boolean;
  insurance_can_finalize?: boolean;
  insurance_can_calculate?: boolean;
  insurance_show_breakdown?: boolean;
  insurance_breakdown?: InsuranceBreakdownEntry[];
  insurance_blocker?: string;
};

type ChemicalReagent = {
  name: string;
  volume: number;
  source: string;
  category: string;
  overdose_threshold?: number;
  overdosed?: boolean;
};

type CyberneticImplant = {
  name: string;
  slot?: string;
  status?: string;
  icon?: string;
};

type InsuranceBreakdownEntry = {
  label: string;
  value: number;
  detail?: string;
};

type WoundBlock = {
  warning: string;
  type: string;
  severity: string;
  details: string[];
};

export function HealthAnalyzer(props) {
  const { act, data } = useBackend<HealthAnalyzerData>();
  const {
    scan_type,
    scan_type_name,
    target_name,
    advanced,
    verbose,
    report,
    refresh_interval,
    refresh_options,
    target_dead,
    target_health,
    target_max_health,
    health_percent,
    brute_loss = 0,
    burn_loss = 0,
    toxin_loss = 0,
    oxygen_loss = 0,
    irradiated,
    radiation_contamination,
    radiation_contamination_activity,
    chemical_reagents = [],
    cybernetics = [],
    insurance_visible,
    insurance_has_account,
    insurance_balance,
    insurance_money_symbol = '$',
    insurance_status,
    insurance_estimated_payout,
    insurance_raw_total,
    insurance_capped_total,
    insurance_time_left,
    insurance_claim_holder,
    insurance_can_open,
    insurance_can_finalize,
    insurance_can_calculate,
    insurance_show_breakdown,
    insurance_breakdown = [],
    insurance_blocker,
  } = data;
  const reportText = report || '';
  const refreshInterval = refresh_interval || 3;
  const refreshOptions = refresh_options?.length ? refresh_options : [1, 2, 3, 5, 10];
  const healthPercent =
    typeof health_percent === 'number' ? health_percent : getHealthPercent(reportText);
  const warningCount = getWarningCount(reportText);
  const reportSections = getReportSections(reportText);
  const activeTab = scanTabs.find((tab) => tab.id === scan_type);
  const vitalsLabel = target_dead
    ? 'Deceased'
    : healthPercent !== null
      ? `${healthPercent}%`
      : 'Live';
  const windowHeight = getWindowHeight(reportText, reportSections.length);

  return (
    <Window width={940} height={windowHeight}>
      <Window.Content
        scrollable
        className={`HealthAnalyzer HealthAnalyzer--${scan_type}`}
      >
        <Section className="HealthAnalyzer__Header">
          <Stack align="center">
            <Stack.Item>
              <Box
                className={
                  target_dead
                    ? 'HealthAnalyzer__Scope HealthAnalyzer__Scope--dead'
                    : 'HealthAnalyzer__Scope'
                }
              >
                <Icon name={target_dead ? 'skull' : activeTab?.icon || 'heartbeat'} />
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box className="HealthAnalyzer__Eyebrow">Active scan</Box>
              <Box className="HealthAnalyzer__Target">
                {target_name || 'Unknown subject'}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box className="HealthAnalyzer__Pulse">
                <Icon name="satellite-dish" mr={1} />
                <Dropdown
                  selected={`${refreshInterval}s`}
                  options={refreshOptions.map((option) => `${option}s`)}
                  onSelected={(value) =>
                    act('setRefreshInterval', {
                      refresh_interval: Number.parseInt(value, 10),
                    })
                  }
                />
              </Box>
            </Stack.Item>
          </Stack>
          <Box className="HealthAnalyzer__Sweep" />
        </Section>

        <Stack align="start">
          <Stack.Item grow basis={0}>
            {scan_type === 'insurance' ? (
              <InsuranceReport
                visible={insurance_visible}
                hasAccount={insurance_has_account}
                balance={insurance_balance}
                moneySymbol={insurance_money_symbol}
                status={insurance_status}
                estimate={insurance_estimated_payout}
                rawTotal={insurance_raw_total}
                cappedTotal={insurance_capped_total}
                timeLeft={insurance_time_left}
                claimHolder={insurance_claim_holder}
                canOpen={insurance_can_open}
                canFinalize={insurance_can_finalize}
                canCalculate={insurance_can_calculate}
                showBreakdown={insurance_show_breakdown}
                breakdown={insurance_breakdown}
                blocker={insurance_blocker}
                act={act}
              />
            ) : (
              <>
                {reportSections.map((section, index) => (
                  <ReportSection
                    key={index}
                    section={section}
                    index={index}
                    scanTypeName={scan_type_name}
                    chemicalReagents={scan_type === 'chemicals' ? chemical_reagents : []}
                  />
                ))}
                {scan_type === 'health' && cybernetics.length > 0 && (
                  <CyberneticsReport cybernetics={cybernetics} />
                )}
              </>
            )}
          </Stack.Item>

          <Stack.Item width="275px">
            <Section title="Scan Mode">
              <Tabs vertical fluid>
                {scanTabs.map((tab) => (
                  <Tabs.Tab
                    key={tab.id}
                    icon={tab.icon}
                    selected={scan_type === tab.id}
                    onClick={() => act('setScanType', { scan_type: tab.id })}
                  >
                    {tab.label}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>

            <Section title="Subject Status">
              <Stack>
                <Stack.Item grow>
                  <Box color="label">Warnings</Box>
                  <Box
                    className={
                      warningCount
                        ? 'HealthAnalyzer__Metric HealthAnalyzer__Metric--warn'
                        : 'HealthAnalyzer__Metric'
                    }
                  >
                    {warningCount}
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box color="label">Vitals</Box>
                  <Box
                    className={
                      target_dead
                        ? 'HealthAnalyzer__Metric HealthAnalyzer__Metric--bad'
                        : 'HealthAnalyzer__Metric'
                    }
                  >
                    {vitalsLabel}
                  </Box>
                </Stack.Item>
              </Stack>

              {healthPercent !== null && (
                <Box mt={1}>
                  <ProgressBar
                    value={target_dead ? 0 : healthPercent / 100}
                    ranges={{
                      good: [0.8, Infinity],
                      average: [0.45, 0.8],
                      bad: [-Infinity, 0.45],
                    }}
                  >
                    <Box bold>
                      {target_dead
                        ? 'Deceased'
                        : `${healthPercent}% health`}
                    </Box>
                  </ProgressBar>
                </Box>
              )}

              <Box mt={1}>
                <LabeledList>
                  <LabeledList.Item label="Health">
                    {target_health ?? '-'} / {target_max_health ?? '-'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Scanner">
                    {advanced ? 'Advanced' : 'Standard'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Readout">
                    {verbose ? 'Verbose' : 'Condensed'}
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            </Section>

            <Section title="Damage Index">
              <DamageRow label="Brute" value={brute_loss} color="bad" />
              <DamageRow label="Burn" value={burn_loss} color="average" />
              <DamageRow label="Toxin" value={toxin_loss} color="good" />
              <DamageRow label="Oxygen" value={oxygen_loss} color="cyan" />
            </Section>

            <Section title="Radiological">
              <LabeledList>
                <LabeledList.Item label="Irradiated">
                  <Box
                    className={
                      irradiated
                        ? 'HealthAnalyzer__RadBad'
                        : 'HealthAnalyzer__RadGood'
                    }
                  >
                    {irradiated ? 'Detected' : 'Clear'}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Surface">
                  <Box
                    className={
                      radiation_contamination
                        ? 'HealthAnalyzer__RadBad'
                        : 'HealthAnalyzer__RadGood'
                    }
                  >
                    {radiation_contamination
                      ? `${capitalize(radiation_contamination)}${
                          radiation_contamination_activity
                            ? ` (${radiation_contamination_activity})`
                            : ''
                        }`
                      : 'Clear'}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>

          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

const scanTabs = [
  { id: 'health', label: 'Health', icon: 'heartbeat' },
  { id: 'chemicals', label: 'Chemicals', icon: 'flask' },
  { id: 'wounds', label: 'Wounds', icon: 'bandage' },
  { id: 'insurance', label: 'Insurance', icon: 'file-invoice-dollar' },
];

function DamageRow(props: { label: string; value: number; color: string }) {
  const { label, value, color } = props;
  return (
    <Box className="HealthAnalyzer__DamageRow">
      <Box color="label">{label}</Box>
      <Box
        className={`HealthAnalyzer__DamageValue HealthAnalyzer__DamageValue--${color}`}
      >
        {value}
      </Box>
    </Box>
  );
}

function ReportSection(props: {
  section: string;
  index: number;
  scanTypeName: string;
  chemicalReagents: ChemicalReagent[];
}) {
  const { section, index, scanTypeName, chemicalReagents } = props;
  const title = getSectionTitle(section, index, scanTypeName);
  const tone = getSectionTone(section);
  const sectionKind = getSectionKind(section, scanTypeName);

  return (
    <Section
      title={
        <Box className={`HealthAnalyzer__SectionTitle ${tone.className}`}>
          <Icon name={tone.icon} mr={1} />
          {title}
        </Box>
      }
      className={`HealthAnalyzer__ReportSection HealthAnalyzer__ReportSection--${sectionKind}`}
    >
      {sectionKind === 'chemicals' ? (
        <ChemicalReport
          reagents={
            chemicalReagents.length ? chemicalReagents : getChemicalReagents(section)
          }
        />
      ) : sectionKind === 'wounds' ? (
        <WoundReport section={section} />
      ) : sectionKind === 'body' ? (
        <BodyStatusReport section={section} />
      ) : (
        <Box
          className="HealthAnalyzer__Report"
          dangerouslySetInnerHTML={{
            __html: sanitizeText(decorateReportSection(section, scanTypeName)),
          }}
        />
      )}
    </Section>
  );
}

function ChemicalReport(props: { reagents: ChemicalReagent[] }) {
  const { reagents } = props;
  const groupedReagents = groupReagentsBySource(reagents);

  return (
    <Box className="HealthAnalyzer__Report">
      {Object.entries(groupedReagents).map(([source, sourceReagents]) => (
        <Box key={source} mb={1}>
          <Box className="HealthAnalyzer__ChemHeader">
            Subject contains the following reagents in their {source.toLowerCase()}:
          </Box>
          {sourceReagents.map((reagent, index) => (
            <Box
              key={`${source}-${reagent.name}-${index}`}
              className={`HealthAnalyzer__ChemLine HealthAnalyzer__ChemLine--${reagent.category}`}
            >
              <span className="HealthAnalyzer__ChemAmount">
                {formatVolume(reagent.volume)}u
              </span>
              <span className="HealthAnalyzer__ChemName">{reagent.name}</span>
              {!!reagent.overdosed && (
                <span className="HealthAnalyzer__ChemOverdose">
                  OVERDOSING
                  {!!reagent.overdose_threshold &&
                    ` >${formatVolume(reagent.overdose_threshold)}u`}
                </span>
              )}
            </Box>
          ))}
        </Box>
      ))}
      {!Object.keys(groupedReagents).length && (
        <Box className="HealthAnalyzer__ChemHeader">
          Subject contains no visible reagents.
        </Box>
      )}
      {!!Object.keys(groupedReagents).length && !groupedReagents.Stomach && (
        <Box className="HealthAnalyzer__ChemHeader">
          Subject contains no reagents in their stomach.
        </Box>
      )}
    </Box>
  );
}

function BodyStatusReport(props: { section: string }) {
  const rows = getTableRows(props.section);
  if (!rows.length) {
    return <PlainReport section={props.section} />;
  }

  return (
    <Box className="HealthAnalyzer__Report">
      {rows.map((row, index) => {
        const isDamageHeader = row.includes('Damage:');
        const isTrauma = row.some((cell) => /Physical trauma|Foreign object|Dismembered/i.test(cell));

        if (isTrauma) {
          return (
            <Box key={index} className="HealthAnalyzer__BodyTrauma">
              {normalizeBodyText(row.join(' '))}
            </Box>
          );
        }

        return (
          <Box
            key={index}
            className={
              isDamageHeader
                ? 'HealthAnalyzer__BodyRow HealthAnalyzer__BodyRow--header'
                : 'HealthAnalyzer__BodyRow'
            }
          >
            {row.map((cell, cellIndex) => (
              <span
                key={cellIndex}
                className={getBodyDamageCellClass(isDamageHeader, cellIndex)}
              >
                {normalizeBodyText(cell)}
              </span>
            ))}
          </Box>
        );
      })}
    </Box>
  );
}

function PlainReport(props: { section: string }) {
  return (
    <Box className="HealthAnalyzer__Report">
      {htmlToLines(props.section).map((line, index) => (
        <Box key={index}>{line}</Box>
      ))}
    </Box>
  );
}

function getBodyDamageCellClass(isHeader: boolean, cellIndex: number) {
  if (isHeader || cellIndex === 0) {
    return undefined;
  }
  if (cellIndex === 1) {
    return 'HealthAnalyzer__BodyDamageValue HealthAnalyzer__BodyDamageValue--brute';
  }
  if (cellIndex === 2) {
    return 'HealthAnalyzer__BodyDamageValue HealthAnalyzer__BodyDamageValue--burn';
  }
  if (cellIndex === 3) {
    return 'HealthAnalyzer__BodyDamageValue HealthAnalyzer__BodyDamageValue--toxin';
  }
  if (cellIndex === 4) {
    return 'HealthAnalyzer__BodyDamageValue HealthAnalyzer__BodyDamageValue--oxygen';
  }
  return undefined;
}

function WoundReport(props: { section: string }) {
  const woundBlocks = getWoundBlocks(props.section);

  return (
    <Box className="HealthAnalyzer__Report">
      {woundBlocks.map((block, index) => {
        const severityClass = getWoundSeverityClass(block.severity);
        return (
          <Box key={index} className="HealthAnalyzer__WoundBlock">
            {!!block.warning && (
              <Box className="HealthAnalyzer__WoundWarning">{block.warning}</Box>
            )}
            {!!block.type && (
              <Box>
                <span className="HealthAnalyzer__WoundLabel">Type:</span>{' '}
                <span className={`HealthAnalyzer__WoundValue ${severityClass}`}>
                  {block.type}
                </span>
              </Box>
            )}
            {!!block.severity && (
              <Box>
                <span className="HealthAnalyzer__WoundLabel">Severity:</span>{' '}
                <span className={`HealthAnalyzer__WoundValue ${severityClass}`}>
                  {block.severity}
                </span>
              </Box>
            )}
            {block.details.map((line, lineIndex) => (
              <WoundDetailLine key={lineIndex} line={line} />
            ))}
          </Box>
        );
      })}
    </Box>
  );
}

function WoundDetailLine(props: { line: string }) {
  const match = props.line.match(/^([^:]+):\s*(.*)$/);
  if (!match) {
    return <Box>{props.line}</Box>;
  }

  return (
    <Box>
      <span className="HealthAnalyzer__WoundLabel">{match[1]}:</span>{' '}
      <span>{match[2]}</span>
    </Box>
  );
}

function InsuranceReport(props: {
  visible?: boolean;
  hasAccount?: boolean;
  balance?: number;
  moneySymbol: string;
  status?: string;
  estimate?: number;
  rawTotal?: number;
  cappedTotal?: number;
  timeLeft?: string;
  claimHolder?: string;
  canOpen?: boolean;
  canFinalize?: boolean;
  canCalculate?: boolean;
  showBreakdown?: boolean;
  breakdown?: InsuranceBreakdownEntry[];
  blocker?: string;
  act: (action: string, payload?: Record<string, unknown>) => void;
}) {
  const {
    visible,
    hasAccount,
    balance,
    moneySymbol,
    status,
    estimate,
    rawTotal,
    cappedTotal,
    timeLeft,
    claimHolder,
    canOpen,
    canFinalize,
    canCalculate,
    showBreakdown,
    breakdown = [],
    blocker,
    act,
  } = props;

  if (!visible) {
    return (
      <Section
        title={
          <Box className="HealthAnalyzer__SectionTitle HealthAnalyzer__ToneWarn">
            <Icon name="file-invoice-dollar" mr={1} />
            Insurance
          </Box>
        }
        className="HealthAnalyzer__ReportSection HealthAnalyzer__ReportSection--insurance"
      >
        <Box color="label">No medical insurance access.</Box>
      </Section>
    );
  }

  return (
    <Section
      title={
        <Box className="HealthAnalyzer__SectionTitle HealthAnalyzer__ToneInfo">
          <Icon name="file-invoice-dollar" mr={1} />
          Insurance
        </Box>
      }
      className="HealthAnalyzer__ReportSection HealthAnalyzer__ReportSection--insurance"
    >
      <Stack vertical>
        <Stack.Item>
          <Box className="HealthAnalyzer__InsuranceHero">
            <Box>
              <Box color="label">Balance</Box>
              <Box className="HealthAnalyzer__InsuranceValue">
                {hasAccount ? `${balance ?? 0} ${moneySymbol}` : 'No account'}
              </Box>
            </Box>
            <Box>
              <Box color="label">Status</Box>
              <Box
                className={
                  canOpen || canFinalize
                    ? 'HealthAnalyzer__RadGood'
                    : 'HealthAnalyzer__RadBad'
                }
              >
                {status || 'Unavailable'}
              </Box>
            </Box>
          </Box>
        </Stack.Item>

        <Stack.Item>
          <Section title="Calculation">
            <LabeledList>
              <LabeledList.Item label="Estimated payout">
                {estimate ? `${estimate} ${moneySymbol}` : '-'}
              </LabeledList.Item>
              <LabeledList.Item label="Raw billable value">
                {rawTotal ? `${rawTotal} ${moneySymbol}` : '-'}
              </LabeledList.Item>
              <LabeledList.Item label="After claim caps">
                {cappedTotal ? `${cappedTotal} ${moneySymbol}` : '-'}
              </LabeledList.Item>
              {!!timeLeft && (
                <LabeledList.Item label="Claim expires">
                  {timeLeft}
                </LabeledList.Item>
              )}
              {!!claimHolder && (
                <LabeledList.Item label="Claim holder">
                  {claimHolder}
                </LabeledList.Item>
              )}
              {!!blocker && (
                <LabeledList.Item label="Blocker">
                  <Box color="label">{blocker}</Box>
                </LabeledList.Item>
              )}
            </LabeledList>
            {showBreakdown ? (
              <Box className="HealthAnalyzer__InsuranceBreakdown" mt={1}>
                {breakdown.length ? (
                  breakdown.map((entry, index) => (
                    <Box key={`${entry.label}-${index}`} className="HealthAnalyzer__InsuranceBreakdownRow">
                      <Box>
                        <Box className="HealthAnalyzer__InsuranceBreakdownLabel">
                          {entry.label}
                        </Box>
                        {!!entry.detail && (
                          <Box color="label">{entry.detail}</Box>
                        )}
                      </Box>
                      <Box className="HealthAnalyzer__InsuranceBreakdownValue">
                        {entry.value} {moneySymbol}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box color="label">No billable medical parameters detected.</Box>
                )}
              </Box>
            ) : (
              <Box mt={1} color="label">
                Click calculate to show itemized billable parameters.
              </Box>
            )}
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="file-invoice-dollar"
                color="good"
                disabled={!canCalculate}
                onClick={() => act('insuranceCalculate')}
              >
                Calculate insurance
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="folder-open"
                color="average"
                disabled={!canOpen}
                onClick={() => act('insuranceOpen')}
              >
                Open claim
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="check"
                color="good"
                disabled={!canFinalize}
                onClick={() => act('insuranceFinalize')}
              >
                Finalize claim
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function CyberneticsReport(props: { cybernetics: CyberneticImplant[] }) {
  return (
    <Section
      title={
        <Box className="HealthAnalyzer__SectionTitle HealthAnalyzer__ToneInfo">
          <Icon name="microchip" mr={1} />
          Cybernetics
        </Box>
      }
      className="HealthAnalyzer__ReportSection HealthAnalyzer__ReportSection--cybernetics"
    >
      <Box className="HealthAnalyzer__CyberGrid">
        {props.cybernetics.map((implant, index) => (
          <Box key={`${implant.name}-${index}`} className="HealthAnalyzer__CyberItem">
            <Box
              className="HealthAnalyzer__CyberIcon"
              dangerouslySetInnerHTML={{
                __html: implant.icon ? sanitizeText(implant.icon, true) : '',
              }}
            />
            <Box className="HealthAnalyzer__CyberText">
              <Box className="HealthAnalyzer__CyberName">{implant.name}</Box>
              <Box color="label">
                {implant.slot || 'implant'} / {implant.status || 'Unknown'}
              </Box>
            </Box>
          </Box>
        ))}
      </Box>
    </Section>
  );
}

function getReportSections(report: string) {
  return report
    .split(/<hr\s*\/?>/i)
    .map((section) => section.trim())
    .filter(Boolean);
}

function getHealthPercent(report: string) {
  const match = report.match(/Overall status:[\s\S]*?(\d+(?:\.\d+)?)%\s*healthy/i);
  if (!match) {
    return null;
  }

  return Math.round(Number(match[1]));
}

function getWarningCount(report: string) {
  const warningWords = report.match(
    /warning|critical|deceased|missing|lacks|husked|addicted|allergic|trauma|foreign object|irradiated|contamination|claim unavailable/gi,
  );
  return warningWords?.length || 0;
}

function getSectionTitle(section: string, index: number, scanTypeName: string) {
  if (index === 0) {
    return `${scanTypeName} Summary`;
  }
  if (/Body status/i.test(section)) {
    return 'Body Status';
  }
  if (/Organ status/i.test(section)) {
    return 'Organ Status';
  }
  if (/cybernetic/i.test(section)) {
    return 'Cybernetics';
  }
  if (/Species|temperature|blood level|alcohol/i.test(section)) {
    return 'Physiology';
  }
  if (/reagent|stomach|bloodstream|neuroware/i.test(section)) {
    return 'Chemical Trace';
  }
  if (/Insurance balance|insurance claim|Claim unavailable/i.test(section)) {
    return 'Medical Insurance';
  }
  if (/Warning:|trauma|wound/i.test(section)) {
    return 'Clinical Alerts';
  }
  if (/Time of Death/i.test(section)) {
    return 'Mortality';
  }

  return `Readout ${index + 1}`;
}

function getSectionKind(section: string, scanTypeName: string) {
  if (/Body status/i.test(section)) {
    return 'body';
  }
  if (/Organ status/i.test(section)) {
    return 'vitals';
  }
  if (/Chemical/i.test(scanTypeName) || /reagent|stomach|bloodstream|neuroware/i.test(section)) {
    return 'chemicals';
  }
  if (/Wounds/i.test(scanTypeName) || /trauma|wound|Recommended Treatment/i.test(section)) {
    return 'wounds';
  }
  if (/Insurance balance|insurance claim|Claim unavailable/i.test(section)) {
    return 'insurance';
  }
  if (/Species|temperature|blood level|alcohol/i.test(section)) {
    return 'vitals';
  }

  return 'health';
}

function getSectionTone(section: string) {
  if (/critical|deceased|husked|lacks|missing|irradiated|contamination|claim unavailable/i.test(section)) {
    return { icon: 'triangle-exclamation', className: 'HealthAnalyzer__ToneBad' };
  }
  if (/warning|trauma|foreign object|addicted|allergic/i.test(section)) {
    return { icon: 'circle-exclamation', className: 'HealthAnalyzer__ToneWarn' };
  }
  if (/cybernetic|neuroware|reagent/i.test(section)) {
    return { icon: 'flask', className: 'HealthAnalyzer__ToneInfo' };
  }

  return { icon: 'clipboard-check', className: 'HealthAnalyzer__ToneGood' };
}

function getWindowHeight(report: string, sectionCount: number) {
  return clamp(600 + sectionCount * 34 + Math.round(report.length / 180) * 16, 640, 820);
}

function groupReagentsBySource(reagents: ChemicalReagent[]) {
  return reagents.reduce<Record<string, ChemicalReagent[]>>((groups, reagent) => {
    const source = reagent.source || 'Bloodstream';
    groups[source] ||= [];
    groups[source].push(reagent);
    return groups;
  }, {});
}

function getChemicalReagents(section: string) {
  const reagents: ChemicalReagent[] = [];
  let source = 'Bloodstream';

  for (const line of htmlToLines(section)) {
    if (/stomach/i.test(line)) {
      source = 'Stomach';
    } else if (/bloodstream/i.test(line)) {
      source = 'Bloodstream';
    } else if (/brain|neuroware/i.test(line)) {
      source = 'Brain';
    }

    const match = line.match(
      /^(\d+(?:\.\d+)?)\s+units?\s+of\s+(.+?)(?:\s+-\s+(OVERDOSING|OVERLOADING))?\.?$/i,
    );
    if (!match) {
      continue;
    }

    const name = match[2].replace(/\.$/, '').trim();
    reagents.push({
      name,
      volume: Number(match[1]),
      source,
      category: guessReagentCategory(name),
      overdosed: !!match[3],
    });
  }

  return reagents;
}

function guessReagentCategory(name: string) {
  const normalized = name.toLowerCase();
  if (
    /salve|morphine|salicylic|atropine|libital|aiuri|oxandrolone|regenerative|bicaridine|kelotane|tricord|charcoal|salbutamol|epinephrine|mannitol|saline|omnizine|rezadone|synthflesh|mine/.test(
      normalized,
    )
  ) {
    return 'medicine';
  }
  if (/toxin|acid|poison|venom|plasma|chloral|lexorin|cyanide|formaldehyde|polonium/.test(normalized)) {
    return 'toxin';
  }
  if (/drug|space drugs|meth|crank|krokodil|bath salts|lsd|nicotine|aranesp/.test(normalized)) {
    return 'drug';
  }
  if (/ethanol|beer|wine|vodka|rum|whiskey|gin|tequila|hooch/.test(normalized)) {
    return 'alcohol';
  }
  if (/nutriment|sugar|coffee|tea|juice|milk|water|soda|capsaicin/.test(normalized)) {
    return 'consumable';
  }
  return 'standard';
}

function formatVolume(value: number) {
  return Number.isInteger(value) ? `${value}` : `${Math.round(value * 1000) / 1000}`;
}

function getWoundBlocks(section: string) {
  const blocks: WoundBlock[] = [];
  let currentBlock: WoundBlock | null = null;
  let currentWarning = '';

  for (const line of htmlToLines(section)) {
    if (/^Warning:/i.test(line)) {
      if (currentBlock) {
        blocks.push(currentBlock);
        currentBlock = null;
      }
      currentWarning = line;
      continue;
    }

    const typeMatch = line.match(/^Type:\s*(.*)$/i);
    if (typeMatch) {
      if (currentBlock) {
        blocks.push(currentBlock);
      }
      currentBlock = {
        warning: currentWarning,
        type: typeMatch[1],
        severity: '',
        details: [],
      };
      currentWarning = '';
      continue;
    }

    if (!currentBlock) {
      currentBlock = {
        warning: currentWarning,
        type: '',
        severity: '',
        details: [],
      };
      currentWarning = '';
    }

    const severityMatch = line.match(/^Severity:\s*(.*)$/i);
    if (severityMatch) {
      currentBlock.severity = severityMatch[1];
      continue;
    }

    currentBlock.details.push(line);
  }

  if (currentBlock) {
    blocks.push(currentBlock);
  }

  return blocks;
}

function htmlToLines(section: string) {
  return section
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<div[^>]*>/gi, '\n')
    .replace(/<\/div>/gi, '\n')
    .replace(/<[^>]+>/g, '')
    .replace(/(Warning:[^\n]*?)(Type:)/gi, '$1\n$2')
    .replace(/([^\n])(Type:)/g, '$1\n$2')
    .replace(/([^\n])(Severity:)/g, '$1\n$2')
    .replace(/([^\n])(Description:)/g, '$1\n$2')
    .replace(/([^\n])(Recommended Treatment:)/g, '$1\n$2')
    .replace(/([^\n])(Alternative Treatment:)/g, '$1\n$2')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&rdsh;|↳/g, '↳')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean);
}

function getTableRows(section: string) {
  const rows: string[][] = [];
  const rowMatches = section.matchAll(/<tr[^>]*>([\s\S]*?)<\/tr>/gi);

  for (const rowMatch of rowMatches) {
    const cells = [...rowMatch[1].matchAll(/<td[^>]*>([\s\S]*?)<\/td>/gi)].map(
      (cellMatch) => cleanHtmlText(cellMatch[1]),
    );
    if (cells.length) {
      rows.push(cells);
    }
  }

  return rows;
}

function cleanHtmlText(value: string) {
  return normalizeBodyText(
    value
      .replace(/<br\s*\/?>/gi, ' ')
      .replace(/<[^>]+>/g, '')
      .replace(/&nbsp;/g, ' ')
      .replace(/&amp;/g, '&'),
  );
}

function normalizeBodyText(value: string) {
  return value
    .replace(/&rdsh;|↳/g, '↳')
    .replace(/\s+/g, ' ')
    .replace(/Damage:\s*Brute\s*Burn\s*Toxin\s*Suffocation/i, 'Damage')
    .trim();
}

function decorateReportSection(section: string, scanTypeName: string) {
  let decorated = section;
  const sectionKind = getSectionKind(section, scanTypeName);

  if (sectionKind === 'chemicals') {
    decorated = decorated
      .replace(
        /(\d+(?:\.\d+)?)\s+units?\s+of\s+([^.<]+)(\.)/gi,
        '<font color="#ffdf7e"><b>$1u</b></font> <font color="#63cce0"><b>$2</b></font>$3',
      )
      .replace(
        /(OVERDOSING)/gi,
        '<font color="#ff4c55"><b>$1</b></font>',
      )
      .replace(
        /(bloodstream|stomach|brain|neuroware)/gi,
        '<font color="#63cce0"><b>$1</b></font>',
      );
  }

  if (sectionKind === 'wounds') {
    decorated = decorateWoundReport(decorated);
  }

  return decorated;
}

function decorateWoundReport(section: string) {
  return section
    .replace(
      /(Warning: Physical trauma[^<]*)/gi,
      '<font color="#ff6b70"><b>$1</b></font>',
    )
    .replace(
      /Type:\s*([^<]+)<br>\s*Severity:\s*(Critical|Severe|Moderate|Trivial|Minor|Low)/gi,
      (_match, woundType: string, severity: string) => {
        const severityColor = getWoundSeverityColor(severity);
        return `<font color="#ffcc66"><b>Type:</b></font> <font color="${severityColor}"><b>${woundType}</b></font><br><font color="#ffcc66"><b>Severity:</b></font> <font color="${severityColor}"><b>${severity}</b></font>`;
      },
    )
    .replace(
      /\b(Description|Recommended Treatment|Alternative Treatment):/g,
      '<font color="#ffcc66"><b>$1:</b></font>',
    );
}

function getWoundSeverityColor(severity: string) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return '#ff4c55';
    case 'severe':
      return '#ff9f43';
    case 'moderate':
      return '#ffdf7e';
    default:
      return '#80e69c';
  }
}

function getWoundSeverityClass(severity: string) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return 'HealthAnalyzer__WoundSeverity--critical';
    case 'severe':
      return 'HealthAnalyzer__WoundSeverity--severe';
    case 'moderate':
      return 'HealthAnalyzer__WoundSeverity--moderate';
    default:
      return 'HealthAnalyzer__WoundSeverity--low';
  }
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(value, max));
}

function capitalize(value: string) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}
