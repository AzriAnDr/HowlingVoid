import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  loud: BooleanLike;
  name: string;
  on: BooleanLike;
  say_verb: string;
  selected: string;
  voices: string[];
};

export function AiVoiceChanger(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { loud, name, on, say_verb, voices, selected } = data;

  return (
    <Window title={t('ui.ai_voice_changer.title')} width={400} height={200}>
      <Section fill>
        <LabeledList>
          <LabeledList.Item label={t('ui.common.power')}>
            <Button
              icon={on ? 'power-off' : 'times'}
              selected={!!on}
              onClick={() => act('power')}
            >
              {on ? t('ui.common.on') : t('ui.common.off')}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ai_voice_changer.accent')}>
            <Dropdown
              options={voices}
              onSelected={(value) => {
                act('look', {
                  look: value,
                });
              }}
              selected={selected}
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ai_voice_changer.verb')}>
            <Input
              value={say_verb}
              onBlur={(value) =>
                act('verb', {
                  verb: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.volume')}>
            <Button
              icon={loud ? 'power-off' : 'times'}
              selected={!!loud}
              onClick={() => act('loud')}
            >
              {loud
                ? t('ui.ai_voice_changer.loudmode_on')
                : t('ui.ai_voice_changer.loudmode_off')}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ai_voice_changer.fake_name')}>
            <Input
              value={name}
              onBlur={(value) =>
                act('name', {
                  name: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
}
