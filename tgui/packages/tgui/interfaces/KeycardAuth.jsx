import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const KeycardAuth = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  return (
    // NOVA EDIT: height 125 -> 190, eng override/firing pin
    <Window width={375} height={190}>
      <Window.Content>
        <Section>
          <Box>
            {data.waiting === 1 && (
              <span>{t('ui.keycard_auth.waiting_for_confirmation')}</span>
            )}
          </Box>
          <Box>
            {data.waiting === 0 && (
              <>
                {!!data.auth_required && (
                  <Button
                    icon="check-square"
                    color="red"
                    textAlign="center"
                    lineHeight="60px"
                    fluid
                    onClick={() => act('auth_swipe')}
                    content={t('ui.keycard_auth.authorize')}
                  />
                )}
                {data.auth_required === 0 && (
                  <>
                    <Button
                      icon="exclamation-triangle"
                      fluid
                      onClick={() => {
                        return act('red_alert');
                      }}
                      content={t('ui.keycard_auth.red_alert')}
                    />
                    <Button
                      icon="id-card-o"
                      fluid
                      onClick={() => act('emergency_maint')}
                      content={t('ui.keycard_auth.emergency_maintenance_access')}
                    />
                    {/* NOVA EDIT ADDITION START - Engineering Override */}
                    <Button
                      icon="wrench"
                      fluid
                      onClick={() => act('eng_override')}
                      content={t('ui.keycard_auth.engineering_override_access')}
                    />
                    {/* NOVA EDIT ADDITION END */}
                    <Button
                      icon="meteor"
                      fluid
                      onClick={() => act('bsa_unlock')}
                      content={t('ui.keycard_auth.bluespace_artillery_unlock')}
                    />
                    {/* NOVA EDIT ADDITION START - Permit Pins */}
                    {!!data.permit_pins && (
                      <Button
                        icon="key"
                        fluid
                        onClick={() => act('pin_unrestrict')}
                        content={t(
                          'ui.keycard_auth.permit_locked_firing_pin_unrestriction',
                        )}
                      />
                    )}
                    {/* NOVA EDIT ADDITION END */}
                    <Button
                      icon="key"
                      fluid
                      onClick={() => act('give_janitor_access')}
                      content={t('ui.keycard_auth.grant_janitor_access')}
                    />
                  </>
                )}
              </>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
