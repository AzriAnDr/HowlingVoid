import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

export function KnownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeServerTextById } = usePreferencesLocalization(data);

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
              {localizeServerTextById(props.language.name_id, props.language.name)}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {localizeServerTextById(
            props.language.description_id,
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color="bad"
          icon="brain"
          tooltip={t(
            'language_forget_understand_warning',
            'Forgetting how to understand the language will also prevent you from speaking it.',
          )}
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          {t('forget', 'Forget')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={props.language.speaking ? 'good' : 'default'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? t(
                  'language_forget_speak_keep_understand',
                  'Forget how to speak the language, but you keep your understanding of it.',
                )
              : t('language_learn_speak', 'Learn to speak the language.')
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
          {t('language_can', 'Can')}{' '}
          {props.language.speaking
            ? t('language_speak_inline', 'speak')
            : t('language_only_understand', 'only understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function UnknownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t, localizeServerTextById } = usePreferencesLocalization(data);
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
              {localizeServerTextById(props.language.name_id, props.language.name)}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {localizeServerTextById(
            props.language.description_id,
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!noPoints ? 'good' : 'grey'}
          icon="comment"
          tooltip={t(
            'language_learn_speak_understand',
            'Learn to speak and understand the language.',
          )}
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          {t('language_speak_action', 'Speak')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip={t(
            'language_learn_understand_only',
            'Learn to understand the language but not speak it.',
          )}
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          {t('language_understand', 'Understand')}
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
          'Here, you can learn languages using a point system.',
        )}{' '}
        <b>{t('linguist', 'Linguist')}</b>{' '}
        {t(
          'neutral_quirk_extra_point',
          'neutral quirk will give you one extra point.',
        )}
        <br />
        {t('languages_may_be_either', 'Languages may be either')}{' '}
        <b>{t('spoken_and_understood', 'spoken and understood')}</b>{' '}
        {t('language_or', 'or')} <b>{t('just_understood', 'just understood.')}</b>
        <br />
        {t('one_language_is_worth', 'One language is worth')}{' '}
        <b>{t('one_point', '1 point,')}</b>{' '}
        {t(
          'language_points_even_if_understood_only',
          'even if that language is only understood and not spoken.',
        )}
        <br />
        {t(
          'languages_sol_common_requirement',
          'You must have at least one known language, and you must understand Sol Common to play most station jobs.',
        )}{' '}
        <br />
        {t(
          'language_toggle_speech_free',
          'It does not cost points to toggle speech of a language - it only costs points to add an entirely new language.',
        )}
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length}{' '}
                {t('available_languages', 'available languages')}
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
                {t('known_languages', 'known languages')}
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
