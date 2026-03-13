import { LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

export const GeneticMakeupInfo = (props) => {
  const { makeup } = props;
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);

  return (
    <Section title={t('ui.dna.enzyme_information')}>
      <LabeledList>
        <LabeledList.Item label={t('ui.common.name')}>
          {makeup.name || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.medical_records.blood_type')}>
          {makeup.blood_type || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.dna.unique_enzyme')}>
          {makeup.UE || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.dna.unique_identifier')}>
          {makeup.UI || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.dna.unique_features')}>
          {makeup.UF || 'None'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
