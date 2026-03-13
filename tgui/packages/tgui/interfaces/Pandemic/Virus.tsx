import { useBackend } from 'tgui/backend';
import {
  Box,
  Input,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst, decodeHtmlEntities } from 'tgui-core/string';

import { usePreferencesLocalization } from '../localization';
import { getColor } from './helpers';
import type { Data } from './types';

/**
 * Displays info about the virus. Child elements display
 * the virus's traits and descriptions.
 */
export const VirusDisplay = (props) => {
  const { virus } = props;

  return (
    <Stack fill>
      <Stack.Item grow={3}>
        <Info virus={virus} />
      </Stack.Item>
      {virus.is_adv && (
        <>
          <Stack.Divider />
          <Stack.Item grow={1}>
            <Traits virus={virus} />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

/** Displays the description, name and other info for the virus. */
const Info = (props) => {
  const { act } = useBackend<Data>();
  const { t } = usePreferencesLocalization();
  const {
    virus: { agent, can_rename, description, index, name, spread },
  } = props;

  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.common.name')}>
        {can_rename ? (
          <Input
            placeholder={t('ui.pandemic.input_name')}
            value={name === 'Unknown' ? '' : name}
            onBlur={(value) =>
              act('rename_disease', {
                index: index,
                name: value,
              })
            }
          />
        ) : (
          <Box color="bad">{decodeHtmlEntities(name)}</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.description')}>{description}</LabeledList.Item>
      <LabeledList.Item label={t('ui.pandemic.agent')}>
        {capitalizeFirst(agent)}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.spread')}>{spread}</LabeledList.Item>
    </LabeledList>
  );
};

/**
 * Displays the traits of the virus. This could be iterated over
 * with object.keys but you would need a helper function for the tooltips.
 * I would rather hard code it here.
 */
const Traits = (props) => {
  const { t } = usePreferencesLocalization();
  const {
    virus: { resistance, stage_speed, stealth, transmission, severity },
  } = props;

  return (
    <Section title={t('ui.common.statistics')}>
      <LabeledList>
        <Tooltip content={t('ui.pandemic.tooltip_resistance')}>
          <LabeledList.Item color={getColor(resistance)} label={t('ui.pandemic.resistance')}>
            {resistance}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content={t('ui.pandemic.tooltip_stage_speed')}>
          <LabeledList.Item color={getColor(stage_speed)} label={t('ui.pandemic.stage_speed')}>
            {stage_speed}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content={t('ui.pandemic.tooltip_stealth')}>
          <LabeledList.Item color={getColor(stealth)} label={t('ui.pandemic.stealth')}>
            {stealth}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content={t('ui.pandemic.tooltip_transmission')}>
          <LabeledList.Item
            color={getColor(transmission)}
            label={t('ui.pandemic.transmissibility')}
          >
            {transmission}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content={t('ui.pandemic.tooltip_severity')}>
          <LabeledList.Item
            color={getColor(severity)}
            label={t('ui.pandemic.severity')}
          >
            {severity}
          </LabeledList.Item>
        </Tooltip>
      </LabeledList>
    </Section>
  );
};
