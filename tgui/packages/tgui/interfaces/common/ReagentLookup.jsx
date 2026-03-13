import { Box, Button, Icon, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

export const ReagentLookup = (props) => {
  const { reagent } = props;
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  if (!reagent) {
    return <Box>{t('ui.chem.no_reagent_selected')}</Box>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.chem.reagent')}>
        <Icon name="circle" mr={1} color={reagent.reagentCol} />
        {reagent.name}
        <Button
          ml={1}
          icon="wifi"
          color="teal"
          tooltip={t('ui.chem.open_reagent_wiki')}
          tooltipPosition="left"
          onClick={() => {
            Byond.command(`wiki Guide_to_chemistry#${reagent.name}`);
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.description')}>{reagent.desc}</LabeledList.Item>
      <LabeledList.Item label={t('ui.chem.ph')}>
        <Icon name="circle" mr={1} color={reagent.pHCol} />
        {reagent.pH}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.chem.properties')}>
        <LabeledList>
          {!!reagent.OD && (
            <LabeledList.Item label={t('ui.chem.overdose')}>{reagent.OD}u</LabeledList.Item>
          )}
          {reagent.addictions[0] && (
            <LabeledList.Item label={t('ui.chem.addiction')}>
              {reagent.addictions.map((addiction) => (
                <Box key={addiction}>{addiction}</Box>
              ))}
            </LabeledList.Item>
          )}
          <LabeledList.Item label={t('ui.chem.metabolization_rate')}>
            {reagent.metaRate}u/s
          </LabeledList.Item>
        </LabeledList>
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.chem.impurities')}>
        <LabeledList>
          {reagent.impureReagent && (
            <LabeledList.Item label={t('ui.chem.impure_reagent')}>
              <Button
                icon="vial"
                tooltip={t('ui.chem.impure_reagent_tooltip')}
                tooltipPosition="left"
                content={reagent.impureReagent}
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.impureId,
                  })
                }
              />
            </LabeledList.Item>
          )}
          {reagent.inverseReagent && (
            <LabeledList.Item label={t('ui.chem.inverse_reagent')}>
              <Button
                icon="vial"
                content={reagent.inverseReagent}
                tooltip={t('ui.chem.inverse_reagent_tooltip')}
                tooltipPosition="left"
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.inverseId,
                  })
                }
              />
            </LabeledList.Item>
          )}
          {reagent.failedReagent && (
            <LabeledList.Item label={t('ui.chem.failed_reagent')}>
              <Button
                icon="vial"
                tooltip={t('ui.chem.failed_reagent_tooltip')}
                tooltipPosition="left"
                content={reagent.failedReagent}
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.failedId,
                  })
                }
              />
            </LabeledList.Item>
          )}
        </LabeledList>
        {reagent.isImpure && <Box>{t('ui.chem.reagent_created_by_impurity')}</Box>}
        {reagent.deadProcess && <Box>{t('ui.chem.reagent_works_on_dead')}</Box>}
        {!reagent.failedReagent &&
          !reagent.inverseReagent &&
          !reagent.impureReagent && (
            <Box>{t('ui.chem.reagent_has_no_impure')}</Box>
          )}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          icon="flask"
          mt={2}
          content={t('ui.chem.find_associated_reaction')}
          color="purple"
          onClick={() =>
            act('find_reagent_reaction', {
              id: reagent.id,
            })
          }
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
