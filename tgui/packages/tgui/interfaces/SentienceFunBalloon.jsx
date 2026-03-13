import {
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const SentienceFunBalloon = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const { group_name, range, antag } = data;
  return (
    <Window title={t('ui.sentience_balloon.title')} width={400} height={200}>
      <Window.Content>
        <Stack vertical>
          <Section title={t('ui.sentience_balloon.configure_effect')}>
            <LabeledList>
              <LabeledList.Item label={t('ui.sentience_balloon.group_name')}>
                <Input
                  fluid
                  value={group_name}
                  onBlur={(value) =>
                    act('group_name', {
                      updated_name: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.sentience_balloon.effect_range')}>
                <NumberInput
                  tickWhileDragging
                  width="84px"
                  value={range}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  stepPixelSize={15}
                  onChange={(value) =>
                    act('effect_range', {
                      updated_range: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label={t('ui.sentience_balloon.make_group_antags')}>
                <Button.Checkbox
                  icon={data.antag ? 'user-secret' : 'times'}
                  content={data.antag ? t('ui.common.yes') : t('ui.common.no')}
                  selected={data.antag}
                  onClick={() => act('select_antag')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section>
            <Button.Confirm
              fluid
              icon="magic"
              color="good"
              textAlign="center"
              content={t('ui.sentience_balloon.pop_balloon')}
              onClick={() => act('pop')}
            />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
