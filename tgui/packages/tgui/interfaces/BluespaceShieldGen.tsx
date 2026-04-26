import { useState } from 'react';

import {
	Box,
	Button,
	Divider,
	LabeledList,
	NumberInput,
	ProgressBar,
	Section,
	Stack,
	Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ShieldMode = {
	name: string;
	desc: string;
	flag: number;
	status: BooleanLike;
	hacked: BooleanLike;
	multiplier: number;
};

type BluespaceShieldGenData = {
	running: number;
	modes: ShieldMode[];
	overloaded: BooleanLike;
	mitigation_max: number;
	mitigation_physical: number;
	mitigation_em: number;
	mitigation_heat: number;
	field_integrity: number;
	max_energy: number;
	current_energy: number;
	percentage_energy: number;
	total_segments: number;
	functional_segments: number;
	input_cap_kw: number;
	upkeep_power_usage: number;
	power_usage: number;
	grid_connected: BooleanLike;
	hacked: BooleanLike;
	offline_for: number;
	full_stop: BooleanLike;
	idle_multiplier: number;
	idle_valid_values: number[];
	broken: BooleanLike;
};

function getStateLabel(running: number): string {
	switch (running) {
		case 0:
			return 'OFFLINE';
		case 1:
			return 'DISCHARGING';
		case 2:
			return 'ACTIVE';
		case 3:
			return 'IDLE';
		case 4:
			return 'SPINNING UP';
		default:
			return 'UNKNOWN';
	}
}

function getStateColor(running: number): string {
	switch (running) {
		case 0:
			return 'bad';
		case 1:
			return 'average';
		case 2:
			return 'good';
		case 3:
			return 'average';
		case 4:
			return 'average';
		default:
			return 'bad';
	}
}

export const BluespaceShieldGen = () => {
	const { act, data } = useBackend<BluespaceShieldGenData>();
	const [inputCap, setInputCap] = useState<number | undefined>(undefined);

	const {
		running,
		modes,
		overloaded,
		mitigation_max,
		mitigation_physical,
		mitigation_em,
		mitigation_heat,
		field_integrity,
		max_energy,
		current_energy,
		percentage_energy,
		total_segments,
		functional_segments,
		input_cap_kw,
		upkeep_power_usage,
		power_usage,
		grid_connected,
		offline_for,
		full_stop,
		idle_multiplier,
		idle_valid_values,
		broken,
	} = data;

	const mitigationCap = mitigation_max || 100;
	const currentInputCap = inputCap ?? input_cap_kw;

	return (
		<Window title="Bluespace Shield Field Generator" width={580} height={720}>
			<Window.Content scrollable>
				{broken ? (
					<Section title="Shield Status">
						<Box color="red" bold fontSize={1.4} textAlign="center" mb={1}>
							CONTAINMENT FAILURE
						</Box>
						<Box color="label" textAlign="center">
							Core destroyed. Repair required.
						</Box>
					</Section>
				) : (
					<Stack vertical fill>
						<Stack.Item>
							<Section title="Shield Status">
								<LabeledList>
									<LabeledList.Item label="Status" color={getStateColor(running)}>
										{overloaded ? (
											<Box color="red" bold>
												OVERLOADED
											</Box>
										) : offline_for > 0 ? (
											<Box color={full_stop ? 'yellow' : 'orange'}>
												{full_stop ? 'FULL STOP' : 'COOLDOWN'} - {offline_for}s
											</Box>
										) : (
											getStateLabel(running)
										)}
									</LabeledList.Item>
									<LabeledList.Item label="Field Integrity">
										<ProgressBar
											value={field_integrity}
											maxValue={100}
											ranges={{
												good: [75, 100],
												average: [25, 75],
												bad: [0, 25],
											}}
										>
											{field_integrity}%
										</ProgressBar>
									</LabeledList.Item>
									<LabeledList.Item label="Energy Reserve">
										<ProgressBar
											value={percentage_energy}
											maxValue={100}
											ranges={{
												good: [60, 100],
												average: [20, 60],
												bad: [0, 20],
											}}
										>
											{current_energy} / {max_energy} MJ ({percentage_energy}%)
										</ProgressBar>
									</LabeledList.Item>
									<LabeledList.Item label="Field Segments">
										{functional_segments} / {total_segments} active
									</LabeledList.Item>
									<LabeledList.Item label="Power Draw">
										{power_usage} kW
									</LabeledList.Item>
									<LabeledList.Item label="Upkeep">
										{upkeep_power_usage} kW
									</LabeledList.Item>
									<LabeledList.Item label="Grid">
										<Box color={grid_connected ? 'green' : 'red'} bold>
											{grid_connected ? 'CONNECTED' : 'NO CONNECTION'}
										</Box>
									</LabeledList.Item>
								</LabeledList>
							</Section>
						</Stack.Item>

						<Stack.Item>
							<Section title="Controls">
								<Stack>
									<Stack.Item grow>
										<Button
											fluid
											icon="power-off"
											color="green"
											disabled={running !== 0 || offline_for > 0}
											content="Start Generator"
											onClick={() => act('start_generator')}
										/>
									</Stack.Item>
									<Stack.Item grow>
										<Button
											fluid
											icon="stop"
											color="orange"
											disabled={running < 2}
											content="Shutdown"
											onClick={() => act('begin_shutdown')}
										/>
									</Stack.Item>
									<Stack.Item grow>
										<Button
											fluid
											icon="exclamation-triangle"
											color="red"
											disabled={!running}
											content="Emergency Stop"
											onClick={() => act('emergency_shutdown')}
										/>
									</Stack.Item>
								</Stack>
								<Divider />
								<LabeledList>
									<LabeledList.Item label="Idle State">
										<Button
											icon={running === 3 ? 'pause' : 'play'}
											selected={running === 3}
											disabled={running < 2 && running !== 3}
											content={running === 3 ? 'IDLE' : 'ACTIVE'}
											onClick={() => act('toggle_idle')}
										/>
									</LabeledList.Item>
									<LabeledList.Item label="Input Cap (kW)">
										<NumberInput
											fluid
											step={100}
											value={currentInputCap}
											minValue={0}
											maxValue={100000}
											onChange={(value) => {
												setInputCap(value);
												act('set_input_cap', { cap: value });
											}}
										/>
									</LabeledList.Item>
									<LabeledList.Item label="Idle Rate">
										{idle_valid_values.map((value) => (
											<Button
												key={value}
												selected={idle_multiplier === value}
												content={`x${value}`}
												onClick={() => act('switch_idle', { value })}
											/>
										))}
									</LabeledList.Item>
								</LabeledList>
							</Section>
						</Stack.Item>

						<Stack.Item>
							<Section title="Damage Mitigation">
								<LabeledList>
									<LabeledList.Item label="Physical">
										<ProgressBar
											value={mitigation_physical}
											maxValue={mitigationCap}
											ranges={{
												good: [mitigationCap * 0.6, mitigationCap],
												average: [mitigationCap * 0.3, mitigationCap * 0.6],
												bad: [0, mitigationCap * 0.3],
											}}
										>
											{mitigation_physical}% / {mitigationCap}%
										</ProgressBar>
									</LabeledList.Item>
									<LabeledList.Item label="EM">
										<ProgressBar
											value={mitigation_em}
											maxValue={mitigationCap}
											ranges={{
												good: [mitigationCap * 0.6, mitigationCap],
												average: [mitigationCap * 0.3, mitigationCap * 0.6],
												bad: [0, mitigationCap * 0.3],
											}}
										>
											{mitigation_em}% / {mitigationCap}%
										</ProgressBar>
									</LabeledList.Item>
									<LabeledList.Item label="Heat">
										<ProgressBar
											value={mitigation_heat}
											maxValue={mitigationCap}
											ranges={{
												good: [mitigationCap * 0.6, mitigationCap],
												average: [mitigationCap * 0.3, mitigationCap * 0.6],
												bad: [0, mitigationCap * 0.3],
											}}
										>
											{mitigation_heat}% / {mitigationCap}%
										</ProgressBar>
									</LabeledList.Item>
								</LabeledList>
							</Section>
						</Stack.Item>

						<Stack.Item>
							<Section title="Shield Modes">
								{modes.map((mode) => (
									<Box key={mode.flag} mb={0.5}>
										<Tooltip content={mode.desc}>
											<Button
												fluid
												icon={mode.status ? 'toggle-on' : 'toggle-off'}
												selected={!!mode.status}
												color={mode.hacked ? 'red' : mode.status ? 'green' : 'default'}
												onClick={() => act('toggle_mode', { flag: mode.flag })}
											>
												{mode.name}
												<Box as="span" color="label" ml={1}>
													(Cost: x{mode.multiplier})
													{mode.hacked ? ' [HACKED]' : ''}
												</Box>
											</Button>
										</Tooltip>
									</Box>
								))}
							</Section>
						</Stack.Item>
					</Stack>
				)}
			</Window.Content>
		</Window>
	);
};