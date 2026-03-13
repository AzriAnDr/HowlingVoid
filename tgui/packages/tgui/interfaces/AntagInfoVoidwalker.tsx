import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { useBackend } from '../backend';
import { usePreferencesLocalization } from './localization';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoVoidwalker = (props) => {
  const { data } = useBackend<Record<string, unknown>>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window width={660} height={660}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">{t('ui.antaginfovoidwalker.you_are_the_voidwalker')}</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature from the void between stars. You were
                    attracted to the radio signals being broadcasted by this
                    station.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>{t('ui.antaginfovoidwalker.survive_and_ensp')}</span>
                  You have unrivaled freedom. Remain in space and no one can
                  stop you. You can move through windows, so stay near them to
                  always have a way out.
                  <br />
                  <br />
                  <span style={tipstyle}>{t('ui.antaginfovoidwalker.hunt_and_ensp')}</span>
                  Pick unfair fights. Look for inattentive targets and strike at
                  them when they don&apos;t expect you.
                  <br />
                  <br />
                  <span style={tipstyle}>{t('ui.antaginfovoidwalker.abduct_and_ensp')}</span>
                  Your Unsettle ability stuns and drains your targets. Knock
                  them out with your draining slash, take them to space (or
                  nebula vomit) and enlighten them.
                  <br />
                  <br />
                  <span style={tipstyle}>{t('ui.antaginfovoidwalker.reap_and_ensp')}</span>
                  Our students expell our essence regularly. We can use this to
                  go where we could otherwise not, but we reabsorb this when we
                  use it to leave. (You can dive in space vomit.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section fill title={t('ui.antaginfovoidwalker.powers')}>
              <LabeledList>
                <LabeledList.Item label={t('ui.antaginfosunwalker.space_dive')}>
                  You can move under the station from space, use this to hunt
                  and get to isolated sections of space.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfovoidwalker.draining_slash')}>
                  You take the breath right from their lungs and quickly take
                  down even the strongest opponents. Should they resist,
                  right-click allows you to do some raw damage. Your arms are
                  otherwise not very sophisticated, and are not good for much
                  more than just grabbing things.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfovoidwalker.cosmic_physiology')}>
                  Your natural camouflage makes you invisible in space, as well
                  as mending any wounds your body might have sustained. You can
                  move through glass freely, but are slowed in gravity.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfovoidwalker.unsettle')}>
                  Target a victim while remaining only partially in their view
                  to stun and weaken them, but also announce them your presence.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfovoidwalker.cosmic_dash')}>
                  With a short range and negligible damage, it makes for a poor
                  offensive tool, but great for quick escapes and repositions.
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.antaginfovoidwalker.expand')}>
                  For every lesson we teach, we grow in power. We can convert
                  walls into glass to allow us to reach even further.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
