import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

export const PortableBasicInfo = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    connected,
    holding,
    on,
    pressure,
    hasHypernobCrystal,
    reactionSuppressionEnabled,
  } = data;
  return (
    <>
      <Section
        title={t('ui.common.status')}
        buttons={
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? t('ui.common.on') : t('ui.common.off')}
            selected={on}
            onClick={() => act('power')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.common.pressure')}>
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.common.port')}
            color={connected ? 'good' : 'average'}
          >
            {connected ? t('ui.common.connected') : t('ui.common.not_connected')}
          </LabeledList.Item>
          {!!hasHypernobCrystal && (
            <LabeledList.Item label={t('ui.gasmix.reaction_suppression')}>
              <Button
                icon={data.reactionSuppressionEnabled ? 'snowflake' : 'times'}
                content={
                  data.reactionSuppressionEnabled
                    ? t('ui.common.enabled')
                    : t('ui.common.disabled')
                }
                selected={data.reactionSuppressionEnabled}
                onClick={() => act('reaction_suppression')}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title={t('ui.gasmix.holding_tank')}
        minHeight="82px"
        buttons={
          <Button
            icon="eject"
            content={t('ui.common.eject')}
            disabled={!holding}
            onClick={() => act('eject')}
          />
        }
      >
        {holding ? (
          <LabeledList>
            <LabeledList.Item label={t('ui.common.label')}>
              {holding.name}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.pressure')}>
              <AnimatedNumber value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">{t('ui.gasmix.no_holding_tank')}</Box>
        )}
      </Section>
    </>
  );
};
