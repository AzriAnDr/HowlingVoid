// THIS IS A NOVA SECTOR UI FILE
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const BorerChem = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const borerTransferAmounts = data.borerTransferAmounts || [];
  return (
    <Window
      width={565}
      height={400}
      title={t('ui.borerchem.injector')}
      theme="wizard"
    >
      <Window.Content scrollable>
        <Section title={t('ui.borerchem.status')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.borerchem.storage')}>
              <ProgressBar value={data.energy / data.maxEnergy}>
                {`${toFixed(data.energy)} ${t('ui.common.units')}`}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.borerchem.inject')}
          buttons={borerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}
        >
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={chemical.title}
                disabled={data.onCooldown || data.notEnoughChemicals}
                onClick={() =>
                  act('inject', {
                    reagent: chemical.title,
                  })
                }
              />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
