import {
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { getColor } from './helpers';
import type { Threshold } from './types';

/**
 * Similar to the virus info display.
 * Returns info about symptoms as collapsibles.
 */
export const SymptomDisplay = (props) => {
  const { t } = usePreferencesLocalization();
  const { symptoms = [] } = props;
  if (!symptoms?.length) {
    return <NoticeBox>{t('ui.pandemic.no_symptoms_detected')}</NoticeBox>;
  }

  return (
    <Section fill title={t('ui.common.symptoms')}>
      {symptoms.map((symptom) => {
        const { name, desc, threshold_desc } = symptom;
        return (
          <Collapsible key={name} title={name}>
            <Stack fill>
              <Stack.Item grow={3}>
                {desc}
                <Thresholds thresholds={threshold_desc} />
              </Stack.Item>
              <Stack.Divider />
              <Stack.Item grow={1}>
                <Traits symptom={symptom} />
              </Stack.Item>
            </Stack>
          </Collapsible>
        );
      })}
    </Section>
  );
};

/** Displays threshold data */
const Thresholds = (props) => {
  const { t } = usePreferencesLocalization();
  const { thresholds = [] } = props;
  const convertedThresholds = Object.entries<Threshold>(thresholds);

  return (
    <Section mt={1} title={t('ui.pandemic.thresholds')}>
      {!convertedThresholds.length ? (
        <NoticeBox>{t('ui.common.none')}</NoticeBox>
      ) : (
        <LabeledList>
          {convertedThresholds.map(([label, descr], index) => {
            return (
              <LabeledList.Item key={index} label={label}>
                {String(descr)}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      )}
    </Section>
  );
};

/** Displays the numerical trait modifiers for a virus symptom */
const Traits = (props) => {
  const { t } = usePreferencesLocalization();
  const {
    symptom: { level, resistance, stage_speed, stealth, transmission, symptom_cure, cure_color},
  } = props;

  return (
    <Section title={t('ui.pandemic.modifiers')}>
      <LabeledList>
        <Tooltip content={t('ui.pandemic.tooltip_symptom_rarity')}>
          <LabeledList.Item color={getColor(level)} label={t('ui.common.level')}>
            {level}
          </LabeledList.Item>
        </Tooltip>
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
          <LabeledList.Item color={getColor(transmission)} label={t('ui.pandemic.transmission')}>
            {transmission}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content={t('ui.pandemic.tooltip_cure')}>
          <LabeledList.Item color={cure_color} label={t('ui.pandemic.cure')}>
            {symptom_cure}
          </LabeledList.Item>
        </Tooltip>
      </LabeledList>
    </Section>
  );
};
