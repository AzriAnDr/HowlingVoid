import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { usePreferencesLocalization } from '../localization';
import type { Data } from './types';

/** Displays loaded container info, if it exists */
export const BeakerDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { has_beaker, beaker, has_blood } = data;
  const cant_empty = !has_beaker || !beaker?.volume;
  let content;
  if (!has_beaker) {
    content = <NoticeBox>{t('ui.pandemic.no_beaker_loaded')}</NoticeBox>;
  } else if (!beaker?.volume) {
    content = <NoticeBox>{t('ui.pandemic.beaker_is_empty')}</NoticeBox>;
  } else if (!has_blood) {
    content = <NoticeBox>{t('ui.pandemic.no_blood_sample_loaded')}</NoticeBox>;
  } else {
    content = (
      <Stack vertical>
        <Stack.Item>
          <Info />
        </Stack.Item>
        <Stack.Item>
          <Antibodies />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Section
      title={t('ui.common.beaker')}
      buttons={
        <>
          <Button
            icon="times"
            content={t('ui.pandemic.empty_and_eject')}
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content={t('ui.common.empty')}
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content={t('ui.common.eject')}
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }
    >
      {content}
    </Section>
  );
};

/** Displays info about the blood type, beaker capacity - volume */
const Info = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { beaker, blood } = data;
  if (!beaker || !blood) {
    return <NoticeBox>{t('ui.pandemic.no_beaker_loaded')}</NoticeBox>;
  }

  return (
    <Stack>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label={t('ui.common.dna')}>
            {capitalizeFirst(blood.dna)}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.type')}>
            {capitalizeFirst(blood.type)}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label={t('ui.common.container')}>
            <ProgressBar
              color="darkred"
              value={beaker.volume}
              minValue={0}
              maxValue={beaker.capacity}
              ranges={{
                good: [beaker.capacity * 0.85, beaker.capacity],
                average: [beaker.capacity * 0.25, beaker.capacity * 0.85],
                bad: [0, beaker.capacity * 0.25],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

/** If antibodies are present, returns buttons to create vaccines */
const Antibodies = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { is_ready, resistances = [] } = data;
  if (!resistances) {
    return <NoticeBox>{t('ui.common.nothing_detected')}</NoticeBox>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label={t('ui.pandemic.antibodies')}>
        {!resistances.length
          ? t('ui.common.none')
          : resistances.map((resistance) => {
              return (
                <Button
                  key={resistance.name}
                  icon="eye-dropper"
                  disabled={!is_ready}
                  tooltip={t('ui.pandemic.creates_vaccine_bottle')}
                  onClick={() =>
                    act('create_vaccine_bottle', {
                      index: resistance.id,
                    })
                  }
                >
                  {`${resistance.name}`}
                </Button>
              );
            })}
      </LabeledList.Item>
    </LabeledList>
  );
};
