import {
	Box,
	Button,
	LabeledList,
	NoticeBox,
	NumberInput,
	ProgressBar,
	Section,
	Stack,
} from 'tgui-core/components';
import { formatMoney, formatPower, formatSiUnit } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type PTLData = {
	output: number;
	total_earnings: number;
	unsent_earnings: number;
	total_energy: number;
	held_power: number;
	max_capacity: number;
	max_grid_load: number;
	accepting_power: boolean;
	sucking_power: boolean;
	firing: boolean;
	target: string;
	power_format: number;
	input_number: number;
	avalible_input: number;
	output_number: number;
	output_multiplier: number;
	input_total: number;
	output_total: number;
};

export const PowerTransmissionLaser = () => {
	const { data } = useBackend<PTLData>();
	const { t } = usePreferencesLocalization(data);
	const { total_earnings, total_energy } = data;
	const windowWidth = 420;

	return (
		<Window title={t('ui.power_transmission_laser.title')} width={windowWidth} height={500}>
			<Window.Content>
				<Status />
				<InputControls />
				<OutputControls />
				<NoticeBox success>
					{t('ui.power_transmission_laser.earned_credits')}: {total_earnings ? formatMoney(total_earnings) : 0}
				</NoticeBox>
				<NoticeBox success>
					{t('ui.power_transmission_laser.energy_sold')}: {total_energy ? formatSiUnit(total_energy, 0, 'J') : '0 J'}
				</NoticeBox>
			</Window.Content>
		</Window>
	);
};

const Status = () => {
	const { data } = useBackend<PTLData>();
	const { t } = usePreferencesLocalization(data);
	const { max_capacity, held_power, input_total, max_grid_load } = data;
	const reserveFill = max_capacity > 0 ? held_power / max_capacity : 0;
	const gridFill = Math.min(input_total, Math.max(0, max_capacity - held_power)) / (max_grid_load || 1);

	return (
		<Section title={t('ui.common.status')}>
			<LabeledList>
				<LabeledList.Item label={t('ui.power_transmission_laser.reserve_energy')}>
					{held_power ? formatSiUnit(held_power, 0, 'J') : '0 J'}
				</LabeledList.Item>
			</LabeledList>
			<ProgressBar
				mt="0.5em"
				mb="0.5em"
				ranges={{
					good: [0.8, Infinity],
					average: [0.5, 0.8],
					bad: [-Infinity, 0.5],
				}}
				value={reserveFill}
			/>
			<LabeledList>
				<LabeledList.Item label={t('ui.power_transmission_laser.grid_saturation')} />
			</LabeledList>
			<ProgressBar
				mt="0.5em"
				ranges={{
					good: [0.8, Infinity],
					average: [0.5, 0.8],
					bad: [-Infinity, 0.5],
				}}
				value={gridFill}
			/>
		</Section>
	);
};

const InputControls = () => {
	const { act, data } = useBackend<PTLData>();
	const { t } = usePreferencesLocalization(data);
	const {
		input_total,
		accepting_power,
		sucking_power,
		input_number,
		power_format,
	} = data;

	return (
		<Section title={t('ui.power_transmission_laser.input_controls')}>
			<LabeledList>
				<LabeledList.Item
					label={t('ui.power_transmission_laser.input_circuit')}
					buttons={
						<Button
							icon="power-off"
							color={accepting_power ? 'green' : 'red'}
							onClick={() => act('toggle_input')}>
							{accepting_power ? t('ui.common.enabled') : t('ui.common.disabled')}
						</Button>
					}
				>
					<Box
						color={(sucking_power && 'good') || (accepting_power && 'average') || 'bad'}>
						{(sucking_power && t('ui.common.online')) ||
							(accepting_power && t('ui.power_transmission_laser.idle')) ||
							t('ui.common.offline')}
					</Box>
				</LabeledList.Item>
				<LabeledList.Item label={t('ui.power_transmission_laser.input_level')}>
					{input_total ? formatPower(input_total) : '0 W'}
				</LabeledList.Item>
			</LabeledList>
			<Box mt="0.5em">
				<NumberInput
					mr="0.5em"
					animated
					width="80px"
					step={1}
					stepPixelSize={2}
					minValue={0}
					maxValue={999}
					value={input_number}
					onChange={(value) => act('set_input', { set_input: value })}
				/>
				<Button selected={power_format === 1} onClick={() => act('inputW')}>
					W
				</Button>
				<Button selected={power_format === 10 ** 3} onClick={() => act('inputKW')}>
					KW
				</Button>
				<Button selected={power_format === 10 ** 6} onClick={() => act('inputMW')}>
					MW
				</Button>
				<Button selected={power_format === 10 ** 9} onClick={() => act('inputGW')}>
					GW
				</Button>
			</Box>
		</Section>
	);
};

const OutputControls = () => {
	const { act, data } = useBackend<PTLData>();
	const { t } = usePreferencesLocalization(data);
	const {
		output_total,
		firing,
		accepting_power,
		output_number,
		output_multiplier,
		target,
		held_power,
	} = data;

	return (
		<Section title={t('ui.power_transmission_laser.output_controls')}>
			<LabeledList>
				<LabeledList.Item
					label={t('ui.power_transmission_laser.laser_circuit')}
					buttons={
						<Stack fill wrap="wrap">
							<Stack.Item>
								<Button
									fluid
									icon="crosshairs"
									color={target === '' ? 'green' : 'red'}
									onClick={() => act('target')}>
									{target || t('ui.power_transmission_laser.select_target')}
								</Button>
							</Stack.Item>
							<Stack.Item>
								<Button
									fluid
									icon="power-off"
									color={firing ? 'green' : 'red'}
									disabled={!firing && held_power < 10 ** 6}
									onClick={() => act('toggle_output')}>
									{firing ? t('ui.common.enabled') : t('ui.common.disabled')}
								</Button>
							</Stack.Item>
						</Stack>
					}
				>
					<Box color={(firing && 'good') || (accepting_power && 'average') || 'bad'}>
						{(firing && t('ui.common.online')) ||
							(accepting_power && t('ui.power_transmission_laser.idle')) ||
							t('ui.common.offline')}
					</Box>
				</LabeledList.Item>
				<LabeledList.Item label={t('ui.power_transmission_laser.output_level')}>
					{output_total
						? output_total < 0
							? `-${formatPower(Math.abs(output_total))}`
							: formatPower(output_total)
						: '0 W'}
				</LabeledList.Item>
			</LabeledList>
			<Box mt="0.5em">
				<NumberInput
					mr="0.5em"
					width="80px"
					animated
					step={1}
					stepPixelSize={2}
					minValue={0}
					maxValue={999}
					value={output_number}
					onChange={(value) => act('set_output', { set_output: value })}
				/>
				<Button selected={output_multiplier === 10 ** 6} onClick={() => act('outputMW')}>
					MW
				</Button>
				<Button selected={output_multiplier === 10 ** 9} onClick={() => act('outputGW')}>
					GW
				</Button>
			</Box>
		</Section>
	);
};
