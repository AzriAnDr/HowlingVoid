import { BlockQuote, Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { Rules } from './AntagInfoRules'; // NOVA EDIT ADDITION
import { usePreferencesLocalization } from './localization';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'red',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoMorph = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Window width={620} height={170} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">
            {t('ui.antag_info_morph.you_are_a_morph')}
          </Stack.Item>
          <Stack.Item>
            <BlockQuote>
              ...a shapeshifting abomination that can eat almost anything. You
              may take the form of anything you can see by{' '}
              <span style={noticestyle}>
                using your &quot;Assume Form&quot; ability on it. Shift-clicking
                the object in question will also work.
              </span>{' '}
              <span style={badstyle}>
                &ensp;This process will alert any nearby observers.
              </span>{' '}
              While morphed, you move faster, but are unable to attack creatures
              or eat anything. In addition,
              <span style={badstyle}>
                &ensp;anyone within three tiles will note an uncanny wrongness
                if examining you.
              </span>{' '}
              You can attack any item or dead creature to consume it -
              <span style={goodstyle}>
                &ensp;corpses will restore your health.
              </span>{' '}
              Finally, you can restore yourself to your original form while
              morphed by{' '}
              <span style={noticestyle}>
                using the &quot;Assume Form&quot; ability on yourself. You can
                also shift-click yourself.
              </span>{' '}
            </BlockQuote>
          </Stack.Item>
          {/* NOVA EDIT ADDITION START */}
          <Stack.Item>
            <Rules />
          </Stack.Item>
          {/* NOVA EDIT ADDITION END */}
        </Stack>
      </Window.Content>
    </Window>
  );
};
