import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  AI_present: BooleanLike;
  error: BooleanLike;
  name: string;
  laws: string[];
  isDead: BooleanLike;
  restoring: BooleanLike;
  health: number;
  ejectable: BooleanLike;
};

export const AiRestorer = () => {
  return (
    <Window width={370} height={360}>
      <Window.Content scrollable>
        <AiRestorerContent />
      </Window.Content>
    </Window>
  );
};

export const AiRestorerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    AI_present,
    error,
    name,
    laws,
    isDead,
    restoring,
    health,
    ejectable,
  } = data;

  return (
    <>
      {error && <NoticeBox textAlign="center">{error}</NoticeBox>}
      {!!ejectable && (
        <Button
          fluid
          icon="eject"
          content={AI_present ? name : t('ui.ai_restorer.no_name_placeholder')}
          disabled={!AI_present}
          onClick={() => act('PRG_eject')}
        />
      )}
      {!!AI_present && (
        <Section
          title={ejectable ? t('ui.ai_restorer.system_status') : name}
          buttons={
            <Box inline bold color={isDead ? 'bad' : 'good'}>
              {isDead
                ? t('ui.ai_restorer.nonfunctional')
                : t('ui.ai_restorer.functional')}
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.integrity')}>
              <ProgressBar
                value={health}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, Infinity],
                  average: [50, 70],
                  bad: [-Infinity, 50],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
          {!!restoring && (
            <Box bold textAlign="center" fontSize="20px" color="good" mt={1}>
              {t('ui.ai_restorer.reconstruction_in_progress')}
            </Box>
          )}
          <Button
            fluid
            icon="plus"
            content={t('ui.ai_restorer.begin_reconstruction')}
            disabled={restoring}
            mt={1}
            onClick={() => act('PRG_beginReconstruction')}
          />
          <Section title={t('ui.common.laws')}>
            {laws.map((law) => (
              <Box key={law} className="candystripe">
                {law}
              </Box>
            ))}
          </Section>
        </Section>
      )}
    </>
  );
};
