import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const statusMap = {
  Dead: 'bad',
  Unconscious: 'average',
  Conscious: 'good',
};

export const BodyEntry = (props) => {
  const { body, swapFunc } = props;
  const { t } = usePreferencesLocalization();
  const occupiedMap = {
    owner: t('ui.slime_body_swapper.you_are_here'),
    stranger: t('ui.slime_body_swapper.occupied'),
    available: t('ui.slime_body_swapper.swap'),
  };
  const statusTextMap = {
    Dead: t('ui.common.dead'),
    Unconscious: t('ui.slime_body_swapper.unconscious'),
    Conscious: t('ui.slime_body_swapper.conscious'),
  };
  return (
    <Section
      title={
        <Box inline color={body.htmlcolor}>
          {body.name}
        </Box>
      }
      level={2}
      buttons={
        <Button
          content={occupiedMap[body.occupied]}
          selected={body.occupied === 'owner'}
          color={body.occupied === 'stranger' && 'bad'}
          onClick={() => swapFunc()}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item
          label={t('ui.slimebodyswapper.status')}
          bold
          color={statusMap[body.status]}
        >
          {statusTextMap[body.status] || body.status}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.slimebodyswapper.jelly')}>
          {body.exoticblood}
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.slimebodyswapper.location')}>
          {body.area}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const SlimeBodySwapper = (props) => {
  const { act, data } = useBackend();
  const { bodies = [] } = data;
  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        <Section>
          {bodies.map((body) => (
            <BodyEntry
              key={body.name}
              body={body}
              swapFunc={() => act('swap', { ref: body.ref })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
