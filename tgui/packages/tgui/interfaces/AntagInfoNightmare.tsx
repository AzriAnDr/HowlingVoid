import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { Rules } from './AntagInfoRules'; // NOVA EDIT ADDITION
import { useBackend } from '../backend';
import { usePreferencesLocalization } from './localization';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoNightmare = (props) => {
  const { data } = useBackend<Record<string, unknown>>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window width={620} height={380}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">{t('ui.antaginfonightmare.you_are_a_nightmare')}</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature from beyond the stars that has incredibly
                    strong powers in the darkness, becoming nigh unbeatable.
                    Unfortunately, you wither and burn away in the light. You
                    must use your
                    <span style={noticestyle}>{t('ui.antaginfonightmare.light_eater_and_ensp')}</span> to dim
                    the station, making hunting easier.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>{t('ui.antaginfonightmare.tip_1_and_ensp')}</span>
                  Move often. The station will be hunting you after you are
                  discovered, so don&apos;t stay in one area for long.
                  <br />
                  <span style={tipstyle}>{t('ui.antaginfonightmare.tip_2_and_ensp')}</span>
                  Pick unfair fights. You are incredibly strong in one versus
                  one situations, use it. The more you fight, the harder it will
                  be to keep it dark.
                  <br />
                  <span style={tipstyle}>{t('ui.antaginfonightmare.tip_3_and_ensp')}</span>
                  Fully destroy APCs when possible. Instead of hunting lights
                  that can be fixed, hunt the APCs which are harder to repair.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title={t('ui.antaginfonightmare.powers')}>
              <LabeledList>
                <LabeledList.Item label={t('ui.antaginfonightmare.shadow_dance')}>
                  Whilst in the shadows, you are immune to all ranged attacks,
                  whilst also rapidly regenerating health.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfonightmare.shadow_walk')}>
                  You are allowed unlimited, unrestricted movement in the dark.
                  Light will pull you out of this.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfonightmare.heart_of_darkness')}>
                  Your heart invites the shadows. If you die in the darkness,
                  you will eventually revive if left alone.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfonightmare.light_eater')}>
                  Your twisted appendage. It will consume the light of what it
                  touches, be it victim or object. After 7 seconds of being in
                  jaunt, stabbing a foe will stun them or do extra damage.
                </LabeledList.Item>
              </LabeledList>
            </Section>
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
