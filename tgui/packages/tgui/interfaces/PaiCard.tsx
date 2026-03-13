import {
  BlockQuote,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  candidates: ReadonlyArray<Candidate>;
  pai: Pai;
  range_max: number;
  range_min: number;
};

type Candidate = Readonly<{
  comments: string;
  ckey: string;
  description: string;
  name: string;
}>;

type Pai = {
  can_holo: BooleanLike;
  dna: string;
  emagged: BooleanLike;
  laws: string;
  master: string;
  name: string;
  transmit: BooleanLike;
  receive: BooleanLike;
  leashed: BooleanLike;
  range: number;
  leash_enabled: BooleanLike; // NOVA EDIT ADDITION
};

export const PaiCard = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { pai } = data;

  return (
    <Window width={400} height={400} title={t('ui.pai_card.options_menu')}>
      <Window.Content scrollable>
        {!pai ? <PaiDownload /> : <PaiOptions />}
      </Window.Content>
    </Window>
  );
};

/** Gives a list of candidates as cards */
const PaiDownload = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { candidates = [] } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox info>
          <Stack fill>
            <Stack.Item grow fontSize="16px">
              {t('ui.pai_card.candidates')}
            </Stack.Item>
            <Stack.Item>
              <Button
                color="good"
                icon="bell"
                onClick={() => act('request')}
                tooltip={t('ui.pai_card.request_more_candidates')}
              >
                {t('ui.pai_card.request')}
              </Button>
            </Stack.Item>
          </Stack>
        </NoticeBox>
      </Stack.Item>
      {candidates.map((candidate, index) => {
        return (
          <Stack.Item key={index}>
            <CandidateDisplay candidate={candidate} index={index + 1} />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

/**
 * Renders a custom section that displays a candidate.
 */
const CandidateDisplay = (props: { candidate: Candidate; index: number }) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    candidate: { comments, ckey, description, name },
    index,
  } = props;

  return (
    <Section
      buttons={
        <Button icon="save" onClick={() => act('download', { ckey })}>
          {t('ui.common.download')}
        </Button>
      }
      overflow="hidden"
      title={`${t('ui.pai_card.candidate')} ${index}`}
    >
      <Stack vertical>
        <Stack.Item>
            <Box color="label" mb={1}>
              {t('ui.common.name')}:
            </Box>
            {name ? (
              <Box color="green">{name}</Box>
            ) : (
              t('ui.pai_card.none_provided_name_randomized')
            )}
        </Stack.Item>
        {!!description && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                {t('ui.pai_card.ic_description')}:
              </Box>
              {description}
            </Stack.Item>
          </>
        )}
        {!!comments && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                {t('ui.pai_card.ooc_notes')}:
              </Box>
              {comments}
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

/** Once a pAI has been loaded, you can alter its settings here */
const PaiOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    range_max,
    range_min,
    pai: {
      can_holo,
      dna,
      emagged,
      laws,
      master,
      name,
      transmit,
      receive,
      leashed,
      range,
      leash_enabled /* NOVA EDIT ADDITION */,
    },
  } = data;
  const suppliedLaws = laws[0]
    ? decodeHtmlEntities(laws[0])
    : t('ui.common.none');

  return (
    <Section
      fill
      scrollable
      title={`${t('ui.pai_card.settings')}: ${name.toUpperCase()}`}
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.pai_card.master')}>
          {master || (
            <Button icon="dna" onClick={() => act('set_dna')}>
              {t('ui.pai_card.imprint')}
            </Button>
          )}
        </LabeledList.Item>
        {!!master && (
          <LabeledList.Item color="red" label={t('ui.pai_card.dna')}>
            {dna}
          </LabeledList.Item>
        )}
        <LabeledList.Item label={t('ui.pai_card.laws')}>
          <BlockQuote>{suppliedLaws}</BlockQuote>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.holoform')}>
          <Button
            icon={can_holo ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_holo')}
            selected={can_holo}
          >
            {t('ui.common.toggle')}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.leash')}>
          <Button
            icon={leashed ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_leash')}
            selected={leashed}
          >
            {leashed ? t('ui.pai_card.unleash') : t('ui.pai_card.leash')}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.holoform_range')}>
          <Stack>
            <Stack.Item>
              <Button
                icon="fa-circle-minus"
                onClick={() => act('decrease_range')}
                /* NOVA EDIT CHANGE ORIGINAL: disabled={range === range_max} */
                disabled={!leash_enabled || range === range_min}
              />
            </Stack.Item>
            <Stack.Item mt={0.5}>{range}</Stack.Item>
            <Stack.Item>
              <Button
                icon="fa-circle-plus"
                onClick={() => act('increase_range')}
                /* NOVA EDIT CHANGE ORIGINAL: disabled={range === range_max} */
                disabled={!leash_enabled || range === range_max}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.transmit')}>
          <Button
            icon={transmit ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'transmit' })}
            selected={transmit}
          >
            {t('ui.common.toggle')}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.receive')}>
          <Button
            icon={receive ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'receive' })}
            selected={receive}
          >
            {t('ui.common.toggle')}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.troubleshoot')}>
          <Button icon="comment" onClick={() => act('fix_speech')}>
            {t('ui.pai_card.fix_speech')}
          </Button>
          <Button icon="edit" onClick={() => act('set_laws')}>
            {t('ui.pai_card.set_laws')}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.pai_card.personality')}>
          <Button icon="trash" onClick={() => act('wipe_pai')}>
            {t('ui.common.erase')}
          </Button>
        </LabeledList.Item>
      </LabeledList>
      {!!emagged && (
        <Button
          color="bad"
          icon="bug"
          mt={1}
          onClick={() => act('reset_software')}
        >
          {t('ui.pai_card.reset_software')}
        </Button>
      )}
    </Section>
  );
};
