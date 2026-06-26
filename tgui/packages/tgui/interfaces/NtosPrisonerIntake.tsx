import type { ReactNode } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type IntakeTarget = {
  name: string;
  gender: string;
  rank: string;
  species: string;
  wanted_status: string;
  rewarded: BooleanLike;
  sentence_duration_display: string | null;
  sentence_remaining_display: string | null;
  photo_path: string | null;
};

type PrisonerId = {
  name: string;
  registered_name: string;
  timed: BooleanLike;
  time_to_assign: number;
  time_display: string | null;
};

type Data = {
  operator_name: string | null;
  operator_has_access: BooleanLike;
  operator_has_account: BooleanLike;
  reward: number;
  sentence_time: number | null;
  sentence_display: string | null;
  record_status: string;
  target: IntakeTarget | null;
  prisoner_id: PrisonerId | null;
  can_process: BooleanLike;
};

const colors = {
  bg: '#07090b',
  panel: '#101418',
  panelDark: '#0b0f12',
  panelSoft: '#141a1f',
  border: '#2d3841',
  borderRed: '#6a2826',
  text: '#d4dde2',
  muted: '#76838c',
  dim: '#4d5b65',
  red: '#d74b42',
  redDark: '#852f2b',
  green: '#64c878',
  amber: '#d2a956',
  blue: '#8aa7c4',
};

const terminalFont = 'Consolas, monospace';

export const NtosPrisonerIntake = () => {
  return (
    <NtosWindow width={910} height={560}>
      <NtosWindow.Content
        backgroundColor={colors.bg}
        style={{
          boxSizing: 'border-box',
          fontFamily: terminalFont,
          height: '100%',
          overflow: 'hidden',
          padding: '8px',
        }}
      >
        <PrisonerIntakeContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const PrisonerIntakeContent = () => {
  const { act, data } = useBackend<Data>();
  const {
    operator_name,
    operator_has_access,
    operator_has_account,
    reward,
    sentence_time,
    sentence_display,
    record_status,
    target,
    prisoner_id,
    can_process,
  } = data;

  if (!operator_name) {
    return <NoticeBox>Insert an operator ID card.</NoticeBox>;
  }

  if (!operator_has_access) {
    return <NoticeBox danger>Brig access required.</NoticeBox>;
  }

  if (!operator_has_account) {
    return <NoticeBox danger>Personal bank account required.</NoticeBox>;
  }

  const caseId = target ? makeCaseId(target.name) : 'SR-0000-00';
  const numericSentenceTime =
    sentence_time && sentence_time > 0 ? sentence_time : 900;
  const sentenceMinutes = numericSentenceTime
    ? Math.max(Math.round(numericSentenceTime / 60), 1)
    : 15;
  const isPermanentSentence = sentence_time === -1;
  const hasPaid = !!target?.rewarded;

  return (
    <Box
      style={{
        color: colors.text,
        display: 'grid',
        gridTemplateRows: '42px minmax(0, 1fr) 58px',
        gap: '8px',
        boxSizing: 'border-box',
        height: 'calc(100% - 12px)',
        minHeight: 0,
        overflow: 'hidden',
      }}
    >
      <Header operatorName={operator_name} />
      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: '255px minmax(360px, 1fr) 235px',
          gap: '8px',
          minHeight: 0,
        }}
      >
        <Panel title="PRISONER IDENTITY">
          <CrewSelectLine
            active={!!target}
            text={target ? target.name : 'Select crew member'}
            onClick={() => act('select_crew')}
          />
          <Box
            mt={1}
            style={{
              display: 'grid',
              gridTemplateColumns: '82px 1fr',
              gap: '10px',
            }}
          >
            <Mugshot active={!!target} photoPath={target?.photo_path || null} />
            <Box>
              <InfoLine label="Name" value={target?.name || 'Unknown'} />
              <InfoLine
                label="Status"
                value={target?.wanted_status || 'No record'}
                alert
              />
              <InfoLine label="Case" value={caseId} />
              <InfoLine
                label="Charges"
                value={target ? 'Active intake' : 'Pending'}
              />
            </Box>
          </Box>
          <PanelDivider />
          <RecordGrid
            rows={[
              ['Species', target?.species || 'Unknown'],
              ['Gender', target?.gender || 'Unknown'],
              ['Rank', target?.rank || 'Unassigned'],
              ['Rewarded', hasPaid ? 'Yes' : 'No'],
            ]}
          />
          <Box mt={1.2}>
            <Button
              fluid
              icon="file-alt"
              disabled={!target}
              onClick={() => act('open_security_records')}
            >
              View Security Records
            </Button>
          </Box>
        </Panel>

        <Panel title="INTAKE FORM">
          <Block title="SENTENCE DURATION">
            <Box
              style={{
                display: 'grid',
                gridTemplateColumns: '34px 1fr 34px',
                gap: '7px',
              }}
            >
              <SentenceStepButton
                icon="minus"
                onClick={() =>
                  act('set_sentence', {
                    seconds: Math.max(numericSentenceTime - 300, 60),
                  })
                }
              />
              <Box
                textAlign="center"
                bold
                fontSize="18px"
                style={{
                  backgroundColor: '#182129',
                  border: `1px solid ${colors.border}`,
                  padding: '7px',
                }}
              >
                {sentence_display || '15 minutes'}
              </Box>
              <SentenceStepButton
                icon="plus"
                onClick={() =>
                  act('set_sentence', { seconds: numericSentenceTime + 300 })
                }
              />
            </Box>
            <Box
              mt={0.7}
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(5, 1fr)',
                gap: '6px',
              }}
            >
              <PresetButton
                active={!isPermanentSentence && sentenceMinutes === 5}
                label="5 min"
                seconds={300}
              />
              <PresetButton
                active={!isPermanentSentence && sentenceMinutes === 10}
                label="10 min"
                seconds={600}
              />
              <PresetButton
                active={!isPermanentSentence && sentenceMinutes === 15}
                label="15 min"
                seconds={900}
              />
              <PresetButton
                active={!isPermanentSentence && sentenceMinutes === 60}
                label="1 hour"
                seconds={3600}
              />
              <PresetButton
                active={isPermanentSentence}
                label="Perma"
                seconds={-1}
              />
            </Box>
          </Block>

          <Block title="RECORD STATUS">
            <Box
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: '7px',
              }}
            >
              <Mode
                active={record_status === 'Incarcerated'}
                icon="lock"
                label="Incarcerated"
                status="Incarcerated"
              />
              <Mode
                active={record_status === 'Parole'}
                icon="person-walking"
                label="Parole"
                status="Parole"
              />
              <Mode
                active={record_status === 'Discharged'}
                icon="gavel"
                label="Discharged"
                status="Discharged"
              />
            </Box>
          </Block>

          <Block title="CUSTODY INFO">
            <LabeledList>
              <LabeledList.Item label="Prisoner ID">
                {prisoner_id?.registered_name || 'No prisoner ID scanned'}
              </LabeledList.Item>
              <LabeledList.Item label="Timer">
                {prisoner_id?.time_display ||
                  sentence_display ||
                  'Not assigned'}
              </LabeledList.Item>
              <LabeledList.Item label="Remaining">
                {target?.sentence_remaining_display || 'No active sentence'}
              </LabeledList.Item>
              <LabeledList.Item label="Record">
                {target?.name || 'No crew record selected'}
              </LabeledList.Item>
              <LabeledList.Item label="Status">{record_status}</LabeledList.Item>
            </LabeledList>
          </Block>
        </Panel>

        <Panel title="VALIDATION CHECKLIST">
          <CheckLine
            enabled={!!target}
            text="Valid security record"
            detail={target ? `Record: ${target.name}` : 'No crew selected'}
          />
          <CheckLine
            enabled
            text="Active brig authority"
            detail="Operator access confirmed"
          />
          <CheckLine
            enabled={!hasPaid}
            text="Intake reward"
            detail={
              hasPaid ? 'Payment already issued' : 'No existing intake found'
            }
          />
          <Box
            mt={1}
            p={1}
            style={{
              backgroundColor: colors.panelDark,
              border: `1px solid ${can_process ? colors.green : colors.border}`,
            }}
          >
            <Box color={can_process ? colors.green : colors.amber} bold>
              {can_process ? 'ALL CHECKS PASSED' : 'CHECKS PENDING'}
            </Box>
            <Box color={colors.muted}>Ready state updates automatically.</Box>
          </Box>
        </Panel>
      </Box>
      <FooterBar
        canProcess={!!can_process}
        reward={reward}
        onClear={() => act('clear_selection')}
        onCustomSentence={() => act('set_sentence')}
        onProcess={() => act('process_intake')}
      />
    </Box>
  );
};

const Header = (props: { operatorName: string }) => (
  <Box
    style={{
      display: 'grid',
      gridTemplateColumns: '44px 1fr 220px',
      alignItems: 'center',
      border: `1px solid ${colors.border}`,
      backgroundColor: colors.panelDark,
      minHeight: 0,
    }}
  >
    <Box textAlign="center">
      <Icon name="bars" color={colors.muted} />
    </Box>
    <Box textAlign="center">
      <Box bold fontSize="15px">
        CORRECTIONS PROCESSING
      </Box>
      <Box color={colors.muted} fontSize="10px">
        SECURE BRIG INTAKE TERMINAL
      </Box>
    </Box>
    <Box pr={1} textAlign="right">
      <Box color={colors.red} fontSize="10px" bold>
        SEC-NET TERMINAL
      </Box>
      <Box color={colors.muted} fontSize="10px">
        USER: {props.operatorName}
      </Box>
    </Box>
  </Box>
);

const Panel = (props: { title: string; children: ReactNode }) => (
  <Box
    p={1}
    style={{
      backgroundColor: colors.panel,
      border: `1px solid ${colors.border}`,
      minHeight: 0,
      overflow: 'hidden',
    }}
  >
    <Box color={colors.red} fontSize="10px" bold mb={0.8}>
      {props.title}
    </Box>
    {props.children}
  </Box>
);

const Block = (props: { title: string; children: ReactNode }) => (
  <Box mb={1}>
    <Box color={colors.muted} fontSize="10px" bold mb={0.4}>
      {props.title}
    </Box>
    <Box
      p={0.8}
      style={{
        backgroundColor: colors.panelDark,
        border: `1px solid ${colors.border}`,
      }}
    >
      {props.children}
    </Box>
  </Box>
);

const PanelDivider = () => (
  <Box my={1} style={{ borderTop: `1px solid ${colors.border}` }} />
);

const CrewSelectLine = (props: {
  active: boolean;
  text: string;
  onClick: () => void;
}) => (
  <Button
    fluid
    onClick={props.onClick}
    style={{
      minHeight: '40px',
      backgroundColor: colors.panelDark,
      border: `1px solid ${props.active ? colors.borderRed : colors.border}`,
      color: props.active ? colors.red : colors.muted,
      display: 'grid',
      gridTemplateColumns: '1fr 22px',
      alignItems: 'center',
      padding: '8px',
      textAlign: 'left',
    }}
  >
    <Box>{props.text}</Box>
    <Icon name={props.active ? 'check' : 'users'} />
  </Button>
);

const Mugshot = (props: { active: boolean; photoPath: string | null }) => (
  <Box
    style={{
      height: '112px',
      backgroundColor: '#15191d',
      border: `1px solid ${colors.border}`,
      position: 'relative',
      overflow: 'hidden',
    }}
  >
    {props.photoPath ? (
      <img
        alt=""
        src={props.photoPath}
        style={{
          display: 'block',
          width: '100%',
          height: '100%',
          objectFit: 'contain',
          imageRendering: 'pixelated',
        }}
      />
    ) : (
      <>
        <Box
          style={{
            position: 'absolute',
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            left: '18px',
            top: '20px',
            backgroundColor: props.active ? '#26313a' : '#171d22',
          }}
        />
        <Box
          style={{
            position: 'absolute',
            width: '64px',
            height: '48px',
            borderRadius: '22px 22px 0 0',
            left: '8px',
            top: '64px',
            backgroundColor: props.active ? '#222c33' : '#151b20',
          }}
        />
      </>
    )}
  </Box>
);

const InfoLine = (props: { label: string; value: string; alert?: boolean }) => (
  <Box mb={0.45}>
    <Box color={colors.muted} fontSize="9px">
      {props.label}
    </Box>
    <Box
      color={props.alert ? colors.red : colors.text}
      bold={props.alert}
      fontSize="11px"
    >
      {props.value}
    </Box>
  </Box>
);

const RecordGrid = (props: { rows: Array<[string, string]> }) => (
  <Box>
    {props.rows.map(([label, value]) => (
      <Box
        key={label}
        style={{
          display: 'grid',
          gridTemplateColumns: '70px 1fr',
          gap: '8px',
          marginBottom: '4px',
        }}
      >
        <Box color={colors.muted} fontSize="10px">
          {label}
        </Box>
        <Box color={colors.text} fontSize="10px" bold>
          {value}
        </Box>
      </Box>
    ))}
  </Box>
);

const PresetButton = (props: {
  active: boolean;
  label: string;
  seconds: number;
}) => {
  const { act } = useBackend<Data>();
  return (
    <Button
      fluid
      selected={props.active}
      color={props.active ? 'red' : undefined}
      onClick={() => act('set_sentence', { seconds: props.seconds })}
    >
      {props.label}
    </Button>
  );
};

const SentenceStepButton = (props: { icon: string; onClick: () => void }) => (
  <Button
    icon={props.icon}
    onClick={props.onClick}
    style={{
      alignItems: 'center',
      display: 'flex',
      height: '38px',
      justifyContent: 'center',
      lineHeight: '38px',
      padding: 0,
      width: '34px',
    }}
  />
);

const Mode = (props: {
  active?: boolean;
  icon: string;
  label: string;
  status: string;
}) => {
  const { act } = useBackend<Data>();

  return (
    <Button
      fluid
      icon={props.icon}
      selected={props.active}
      onClick={() => act('set_record_status', { status: props.status })}
      style={{
        backgroundColor: props.active ? '#2a1616' : colors.panelSoft,
        border: `1px solid ${props.active ? colors.redDark : colors.border}`,
        color: props.active ? colors.red : colors.muted,
        minHeight: '34px',
      }}
    >
      {props.label}
    </Button>
  );
};

const CheckLine = (props: {
  enabled: boolean;
  text: string;
  detail: string;
}) => (
  <Box
    mb={0.8}
    p={0.8}
    style={{
      backgroundColor: colors.panelDark,
      border: `1px solid ${colors.border}`,
      minHeight: '66px',
    }}
  >
    <Box
      style={{ display: 'grid', gridTemplateColumns: '22px 1fr', gap: '7px' }}
    >
      <Icon
        name={props.enabled ? 'check' : 'times'}
        color={props.enabled ? colors.green : colors.redDark}
      />
      <Box>
        <Box color={props.enabled ? colors.green : colors.muted} bold>
          {props.text}
        </Box>
        <Box color={colors.muted} fontSize="10px">
          {props.detail}
        </Box>
      </Box>
    </Box>
  </Box>
);

const FooterBar = (props: {
  canProcess: boolean;
  reward: number;
  onClear: () => void;
  onCustomSentence: () => void;
  onProcess: () => void;
}) => (
  <Box
    style={{
      boxSizing: 'border-box',
      display: 'grid',
      gridTemplateColumns: 'minmax(0, 1fr) 84px 78px 78px 160px',
      gap: '6px',
      alignItems: 'center',
      border: `1px solid ${colors.border}`,
      backgroundColor: colors.panelDark,
      height: '58px',
      minHeight: 0,
      overflow: 'hidden',
      padding: '10px',
    }}
  >
    <Box />
    <FooterButton icon="clock" onClick={props.onCustomSentence}>
      Custom
    </FooterButton>
    <FooterButton icon="coins" disabled>
      {props.reward} cr
    </FooterButton>
    <FooterButton icon="times" onClick={props.onClear}>
      Clear
    </FooterButton>
    <FooterButton
      icon="lock"
      color="red"
      disabled={!props.canProcess}
      onClick={props.onProcess}
    >
      Process Sentence
    </FooterButton>
  </Box>
);

const FooterButton = (props: {
  children?: ReactNode;
  color?: string;
  disabled?: boolean;
  icon: string;
  onClick?: () => void;
  selected?: boolean;
}) => (
  <Button
    color={props.color}
    disabled={props.disabled}
    fluid
    icon={props.icon}
    onClick={props.onClick}
    selected={props.selected}
    style={{
      alignItems: 'center',
      display: 'inline-flex',
      height: '26px',
      justifyContent: 'center',
      lineHeight: '18px',
      overflow: 'hidden',
      paddingLeft: '6px',
      paddingRight: '6px',
      whiteSpace: 'nowrap',
    }}
  >
    {props.children}
  </Button>
);

const makeCaseId = (name: string) => {
  let total = 0;
  for (let index = 0; index < name.length; index++) {
    total += name.charCodeAt(index);
  }
  return `SR-${String(total % 10000).padStart(4, '0')}-${String(name.length % 100).padStart(2, '0')}`;
};
