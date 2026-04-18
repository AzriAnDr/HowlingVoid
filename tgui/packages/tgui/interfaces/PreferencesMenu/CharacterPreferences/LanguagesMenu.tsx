import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../types';
import { usePreferencesLocalization } from './localization';

function normalizeLanguageDataId(value: string) {
  return (value ?? '')
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[:]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function getLanguageDataKeyCandidates(
  language: Language,
  suffix: 'name' | 'description',
) {
  const explicitId = language[`${suffix}_id` as 'name_id' | 'description_id'];
  if (explicitId) {
    return [explicitId];
  }

  const normalizedName = normalizeLanguageDataId(language.name);
  const normalizedIcon = normalizeLanguageDataId(language.icon);

  return [
    `language_${normalizedName}_${suffix}`,
    `language_${normalizedIcon}_${suffix}`,
    `language_${language.icon}_${suffix}`,
  ];
}

function getLocalizedLanguageField(
  t: (key: string, fallback?: string) => string,
  localizeDataLabelById: (id: string, fallback?: string) => string,
  language: Language,
  suffix: 'name' | 'description',
  fallback: string,
) {
  const missing = '__HOWLING_MISSING_TRANSLATION__';

  for (const key of getLanguageDataKeyCandidates(language, suffix)) {
    const translated = t(`ui.character.data.${key}`, missing);
    if (translated !== missing) {
      return translated;
    }

    const localized = localizeDataLabelById(key, missing);
    if (localized !== missing) {
      return localized;
    }
  }

  const localizedFallback = localizeDataLabelById(fallback, missing);
  if (localizedFallback !== missing) {
    return localizedFallback;
  }

  return fallback;
}

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
              {getLocalizedLanguageField(
                t,
                localizeDataLabelById,
                props.language,
                'name',
                props.language.name,
              )}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {getLocalizedLanguageField(
            t,
            localizeDataLabelById,
            props.language,
            'description',
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color="bad"
          icon="brain"
          tooltip={t(
            'ui.character.language_forget_understand_warning',
          )}
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          {t('ui.character.language_understand')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={props.language.speaking ? 'good' : 'default'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? t(
                  'ui.character.language_forget_speak_keep_understand',
                )
              : t('ui.character.language_learn_speak')
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
          {t('ui.character.language_can')}{' '}
          {props.language.speaking
            ? t('ui.character.language_speak_inline')
            : t('ui.character.language_only_understand')}
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
              {getLocalizedLanguageField(
                t,
                localizeDataLabelById,
                props.language,
                'name',
                props.language.name,
              )}
            </Box>
          </>
        }
      >
        <BlockQuote>
          {getLocalizedLanguageField(
            t,
            localizeDataLabelById,
            props.language,
            'description',
            props.language.description,
          )}
        </BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!noPoints ? 'good' : 'grey'}
          icon="comment"
          tooltip={t(
            'ui.character.language_learn_speak_understand',
          )}
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          {t('ui.character.language_speak_action')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip={t(
            'ui.character.language_learn_understand_only',
          )}
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          {t('ui.character.language_understand')}
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
          'ui.character.languages_intro_learn_points',
        )}{' '}
        <b>{t('ui.character.linguist')}</b>{' '}
        {t(
          'ui.character.neutral_quirk_extra_point',
        )}
        <br />
        {t('ui.character.languages_may_be_either')}{' '}
        <b>{t('ui.character.spoken_and_understood')}</b>{' '}
        {t('ui.character.language_or')}{' '}
        <b>{t('ui.character.just_understood')}</b>
        <br />
        {t('ui.character.one_language_is_worth')}{' '}
        <b>{t('ui.character.one_point')}</b>{' '}
        {t(
          'ui.character.language_points_even_if_understood_only',
        )}
        <br />
        {t(
          'ui.character.languages_sol_common_requirement',
        )}{' '}
        <br />
        {t(
          'ui.character.language_toggle_speech_free',
        )}
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length}{' '}
                {t('ui.character.available_languages')}
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
                {t('ui.character.known_languages')}
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
