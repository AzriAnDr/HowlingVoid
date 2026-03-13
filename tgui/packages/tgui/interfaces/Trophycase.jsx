import {
  Box,
  Button,
  Dimmer,
  Icon,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const Trophycase = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={300} height={380}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <ShowpieceName />
          </Stack.Item>
          <Stack.Item>
            <ShowpieceImage />
          </Stack.Item>
          <Stack.Item grow>
            <ShowpieceDescription />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item>
            <HistorianPanel />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HistorianPanel = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const {
    has_showpiece,
    historian_mode,
    holographic_showpiece,
    showpiece_description,
  } = data;

  return (
    <Section align="left">
      {!historian_mode && (
        <Button
          icon="key"
          content={t('ui.trophycase.insert_key_for_historian_mode')}
          onClick={() => act('insert_key')}
        />
      )}
      {!!historian_mode && (
        <div>
          <Button
            icon="times"
            content={t('ui.trophycase.lock_historian_mode')}
            onClick={() => act('lock')}
          />
          <Button
            icon="pencil"
            content={t('ui.trophycase.edit_description')}
            disabled={!has_showpiece || holographic_showpiece}
            onClick={() => act('change_message')}
          />
        </div>
      )}
      {!!historian_mode && !!holographic_showpiece && (
        <Box>
          {t('ui.trophycase.holographic_trophy_present')}
        </Box>
      )}
      {!!historian_mode && !has_showpiece && <Box>{t('ui.trophycase.no_trophies_located')}</Box>}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !!showpiece_description && (
          <Box>{t('ui.trophycase.recording_has_begun')}</Box>
        )}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !showpiece_description && (
          <Box>{t('ui.trophycase.new_trophy_detected')}</Box>
        )}
    </Section>
  );
};

const ShowpieceDescription = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const {
    has_showpiece,
    holographic_showpiece,
    historian_mode,
    max_length,
    showpiece_description,
  } = data;
  return (
    <Section fill align="center">
      {!has_showpiece && (
        <Box fill className="Trophycase-description">
          <b>{t('ui.trophycase.exhibit_empty')}</b>
        </Box>
      )}
      {!!holographic_showpiece && <b>{showpiece_description}</b>}
      {!holographic_showpiece && !!has_showpiece && (
        <Box fill className="Trophycase-description">
          {showpiece_description
            ? decodeHtmlEntities(showpiece_description)
            : t('ui.trophycase.exhibit_under_construction')}
        </Box>
      )}
    </Section>
  );
};

const ShowpieceImage = (props) => {
  const { data } = useBackend();
  const { showpiece_icon } = data;
  return showpiece_icon ? (
    <Section align="center">
      <Image
        m={1}
        src={`data:image/jpeg;base64,${showpiece_icon}`}
        height="96px"
        width="96px"
      />
    </Section>
  ) : (
    <Section align="center">
      <Box height="96px" width="96px">
        <Dimmer fontSize="32px">
          <Icon name="landmark" />
        </Dimmer>
      </Box>
    </Section>
  );
};

const ShowpieceName = (props) => {
  const { t } = usePreferencesLocalization();
  const { data } = useBackend();
  const { showpiece_name } = data;
  return (
    <Section align="center">
      <b>
        {showpiece_name
          ? decodeHtmlEntities(showpiece_name)
          : t('ui.trophycase.under_construction')}
      </b>
    </Section>
  );
};
