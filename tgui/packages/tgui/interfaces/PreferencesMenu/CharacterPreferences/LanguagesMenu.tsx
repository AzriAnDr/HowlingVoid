import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

export function KnownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabelById } =
    usePreferencesLocalization(data);

  return (
    <Stack.Item>
      <Section
        title={
          <>
            <Box
              mr="2px"
              mb="-4px"
              inline
              className={`languages16x16 ${props.language.icon}`}
            />
            <Box inline>
              {localizeDataLabelById(
                props.language.name_id ??
                  `language_${props.language.icon}_name`,
                props.language.name,
              )}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {localizeDataLabelById(
            props.language.description_id ??
              `language_${props.language.icon}_description`,
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color="bad"
          icon="brain"
          tooltip={t(
            'language_forget_understand_warning',
          )}
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          {t('language_understand')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={props.language.speaking ? 'good' : 'default'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? t(
                  'language_forget_speak_keep_understand',
                )
              : t('language_learn_speak')
          }
          onClick={() =>
            act(
              props.language.speaking
                ? 'forget_speak_language'
                : 'speak_language',
              { language_name: props.language.name },
            )
          }
        >
          {t('language_can')}{' '}
          {props.language.speaking
            ? t('language_speak_inline')
            : t('language_only_understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function UnknownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabelById } =
    usePreferencesLocalization(data);
  const noPoints =
    data.selected_languages.length === data.total_language_points;

  return (
    <Stack.Item>
      <Section
        title={
          <>
            <Box
              mr="2px"
              mb="-3px"
              inline
              className={`languages16x16 ${props.language.icon}`}
            />
            <Box inline>
              {localizeDataLabelById(
                props.language.name_id ??
                  `language_${props.language.icon}_name`,
                props.language.name,
              )}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {localizeDataLabelById(
            props.language.description_id ??
              `language_${props.language.icon}_description`,
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!noPoints ? 'good' : 'grey'}
          icon="comment"
          tooltip={t(
            'language_learn_speak_understand',
          )}
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          {t('language_speak_action')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip={t(
            'language_learn_understand_only',
          )}
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          {t('language_understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);

  return (
    <Box className="PreferencesMenu__Languages">
      <Section textAlign="center">
        {t(
          'languages_intro_learn_points',
        )}{' '}
        <b>{t('linguist')}</b>{' '}
        {t(
          'neutral_quirk_extra_point',
        )}
        <br />
        {t('languages_may_be_either')}{' '}
        <b>{t('spoken_and_understood')}</b>{' '}
        {t('language_or')}{' '}
        <b>{t('just_understood')}</b>
        <br />
        {t('one_language_is_worth')}{' '}
        <b>{t('one_point')}</b>{' '}
        {t(
          'language_points_even_if_understood_only',
        )}
        <br />
        {t(
          'languages_sol_common_requirement',
        )}{' '}
        <br />
        {t(
          'language_toggle_speech_free',
        )}
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length}{' '}
                {t('available_languages')}
              </Box>
            }
          >
            <Stack vertical>
              {data.unselected_languages.map((val) => (
                <UnknownLanguage key={val.icon} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.selected_languages.length}/{data.total_language_points}{' '}
                {t('known_languages')}
              </Box>
            }
          >
            <Stack vertical>
              {data.selected_languages.map((val) => (
                <KnownLanguage key={val.icon} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Box>
  );
}

