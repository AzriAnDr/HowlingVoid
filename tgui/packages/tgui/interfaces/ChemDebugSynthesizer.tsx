import { Button, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Beaker, BeakerDisplay } from './common/BeakerDisplay';
import { usePreferencesLocalization } from './localization';

type Data = {
  amount: number;
  temp: number;
  purity: number;
  beaker: Beaker;
};

export const ChemDebugSynthesizer = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { amount, temp, purity, beaker } = data;

  return (
    <Window width={390} height={330}>
      <Window.Content scrollable>
        <Section
          title={t('ui.chemdebugsynthesizer.recipient')}
          buttons={
            beaker ? (
              <>
                <NumberInput
                  value={amount}
                  unit="u"
                  minValue={1}
                  maxValue={beaker.maxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={temp}
                  unit="K"
                  minValue={0}
                  maxValue={1000}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('temp', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={purity}
                  unit="%"
                  minValue={0}
                  maxValue={120}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('purity', {
                      amount: value,
                    })
                  }
                />
                <Button
                  icon="plus"
                  content={t('ui.chemdebugsynthesizer.input')}
                  onClick={() => act('input')}
                />
              </>
            ) : (
              <Button
                icon="plus"
                content={t('ui.chemdebugsynthesizer.create_beaker')}
                onClick={() => act('makecup')}
              />
            )
          }
        >
          <BeakerDisplay beaker={beaker} showpH />
        </Section>
      </Window.Content>
    </Window>
  );
};
