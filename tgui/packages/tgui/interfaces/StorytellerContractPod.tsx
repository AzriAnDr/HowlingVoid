import { Box, Button, LabeledList, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RequirementStatus = 'complete' | 'partial' | 'missing';

type ContractRequirement = {
  name: string;
  present: number;
  required: number;
  status: RequirementStatus;
  tier: number;
  unitValue: number;
};

type ContractPodData = {
  complete: BooleanLike;
  departing: BooleanLike;
  department: string;
  ready: BooleanLike;
  requirements: ContractRequirement[];
  reward: number;
  summary: string;
  timeRemaining: number;
  title: string;
};

const statusColor: Record<RequirementStatus, string> = {
  complete: 'green',
  missing: 'red',
  partial: 'yellow',
};

const formatRemaining = (seconds: number) => {
  const safeSeconds = Math.max(seconds || 0, 0);
  const minutes = Math.floor(safeSeconds / 60);
  const remainingSeconds = safeSeconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

export function StorytellerContractPod() {
  const { act, data } = useBackend<ContractPodData>();
  const {
    complete,
    departing,
    ready,
    requirements = [],
    reward,
    summary,
    timeRemaining,
    title,
  } = data;

  return (
    <Window width={540} height={420}>
      <Window.Content scrollable>
        <Section
          title={title || 'Contract Pickup'}
          buttons={
            <Button
              color="green"
              disabled={!ready || !!complete || !!departing}
              icon="paper-plane"
              onClick={() => act('dispatch')}
            >
              Dispatch Pod
            </Button>
          }
        >
          <Stack vertical>
            <Stack.Item>
              <NoticeBox info>{summary || 'Deliver the requested items to this pod.'}</NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Reward">
                  {formatMoney(reward)} credits to Cargo
                </LabeledList.Item>
                <LabeledList.Item label="Pickup Window">
                  {departing ? 'Departing' : formatRemaining(timeRemaining)}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>

        <Section title="Requested Items">
          <Table>
            <Table.Row bold>
              <Table.Cell>Item</Table.Cell>
              <Table.Cell collapsing textAlign="center">
                Present
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                Required
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                Tier
              </Table.Cell>
            </Table.Row>
            {requirements.map((requirement) => (
              <Table.Row
                color={statusColor[requirement.status] || 'red'}
                key={`${requirement.name}-${requirement.required}`}
              >
                <Table.Cell>
                  <Box bold>{requirement.name}</Box>
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {requirement.present}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {requirement.required}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {requirement.tier}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
}
