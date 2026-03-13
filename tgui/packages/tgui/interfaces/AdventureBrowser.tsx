import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { type AdventureDataProvider, AdventureScreen } from './ExodroneConsole';

type Adventure = {
  ref: string;
  name: string;
  filename: string;
  approved: boolean;
  uploader: string;
  version: number;
  json_status: string;
};

type AdventureBrowserData = AdventureDataProvider & {
  adventures: Array<Adventure>;
  feedback_message: string;
  play_mode: boolean;
  adventure_data: any;
  delay_time: number;
  delay_message: string;
};

const AdventureList = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Table>
      <Table.Row>
        <Table.Cell color="label">{t('ui.adventure_browser.filename')}</Table.Cell>
        <Table.Cell color="label">{t('ui.common.title')}</Table.Cell>
        <Table.Cell color="label">{t('ui.common.author')}</Table.Cell>
        <Table.Cell color="label">{t('ui.adventure_browser.playtest')}</Table.Cell>
      </Table.Row>
      {data.adventures.map((adventure) => (
        <Table.Row key={adventure.ref} className="candystripe">
          <Table.Cell>{adventure.filename}</Table.Cell>
          <Table.Cell>{adventure.name}</Table.Cell>
          <Table.Cell>{adventure.uploader}</Table.Cell>
          <Table.Cell>
            <Button
              color="good"
              onClick={() => act('play', { ref: adventure.ref })}
              content={t('ui.common.play')}
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const DebugPlayer = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Section
      title={t('ui.adventure_browser.playtest')}
      buttons={
        <Button onClick={() => act('end_play')}>
          {t('ui.adventure_browser.end_playtest')}
        </Button>
      }
    >
      {data.delay_time > 0 ? (
        <Box>
          {t('ui.adventure_browser.delay')} {formatTime(data.delay_time)} /{' '}
          {data.delay_message}
        </Box>
      ) : (
        <AdventureScreen
          adventure_data={data.adventure_data}
          drone_integrity={100}
          drone_max_integrity={100}
          hide_status
        />
      )}
    </Section>
  );
};

export const AdventureBrowser = (props) => {
  const { data } = useBackend<AdventureBrowserData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Window
      width={600}
      height={400}
      title={t('ui.adventure_browser.adventure_overview')}
    >
      <Window.Content>
        {!!data.feedback_message && (
          <NoticeBox>{data.feedback_message}</NoticeBox>
        )}
        {data.play_mode ? <DebugPlayer /> : <AdventureList />}
      </Window.Content>
    </Window>
  );
};
