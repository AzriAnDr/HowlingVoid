import { LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  currentTram: Tram[];
  previousTrams: Tram[];
};

type Tram = {
  serialNumber: string;
  mfgDate: string;
  distanceTravelled: number;
  tramCollisions: number;
};

export const TramPlaque = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { currentTram = [], previousTrams = [] } = data;

  return (
    <Window
      title={t('ui.tram_plaque.title')}
      width={600}
      height={360}
      theme="dark"
    >
      <Window.Content>
        <NoticeBox info>{t('ui.tram_plaque.model_notice')}</NoticeBox>
        <Section
          title={
            currentTram.map((serialNumber) => serialNumber.serialNumber) +
            ` - ${t('ui.tram_plaque.constructed')} ` +
            currentTram.map((serialNumber) => serialNumber.mfgDate)
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.tram_plaque.distance_travelled')}>
              {currentTram.map(
                (serialNumber) => serialNumber.distanceTravelled / 1000,
              )}{' '}
              km
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.tram_plaque.collisions')}>
              {currentTram.map((serialNumber) => serialNumber.tramCollisions)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.tram_plaque.tram_history')}>
          <Stack fill g={0}>
            <Stack.Item m={1} grow>
              <b>{t('ui.tram_plaque.serial')}</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>{t('ui.tram_plaque.constructed')}</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>{t('ui.tram_plaque.distance')}</b>
            </Stack.Item>
            <Stack.Item m={1} grow>
              <b>{t('ui.tram_plaque.collisions')}</b>
            </Stack.Item>
          </Stack>
          <Stack vertical fill>
            {previousTrams.map((tram_entry) => (
              <Stack.Item key={tram_entry.serialNumber}>
                <Stack fill g={0}>
                  <Stack.Item m={1} grow>
                    {tram_entry.serialNumber}
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.mfgDate}
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.distanceTravelled / 1000} km
                  </Stack.Item>
                  <Stack.Item m={1} grow>
                    {tram_entry.tramCollisions}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
