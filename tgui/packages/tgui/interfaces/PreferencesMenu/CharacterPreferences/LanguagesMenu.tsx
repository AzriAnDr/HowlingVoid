import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../types';
import { getCharacterPreferencesLanguage, localize } from './localization';

export function KnownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const lang = getCharacterPreferencesLanguage(data);
  const t = (text: string) => localize(lang, text);

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
            <Box inline>{props.language.name}</Box>
          </>
        }
      >
        <BlockQuote>{props.language.description}</BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color="bad"
          icon="brain"
          tooltip={t(
            'Forgetting how to understand the language will also prevent you from speaking it.',
          )}
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          {t('Forget')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={props.language.speaking ? 'good' : 'default'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? t(
                  'Forget how to speak the language, but you keep your understanding of it.',
                )
              : t('Learn to speak the language.')
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
          {t('Can')} {props.language.speaking ? t('speak') : t('only understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function UnknownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const lang = getCharacterPreferencesLanguage(data);
  const t = (text: string) => localize(lang, text);
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
            <Box inline>{props.language.name}</Box>
          </>
        }
      >
        <BlockQuote>{props.language.description}</BlockQuote>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!noPoints ? 'good' : 'grey'}
          icon="comment"
          tooltip={t('Learn to speak and understand the language.')}
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          {t('Speak')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip={t('Learn to understand the language but not speak it.')}
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          {t('Understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const lang = getCharacterPreferencesLanguage(data);
  const t = (text: string) => localize(lang, text);

  return (
    <Box className="PreferencesMenu__Languages">
      <Section textAlign="center">
        {t('Here, you can learn languages using a point system.')} <b>{t('Linguist')}</b>{' '}
        {t('neutral quirk will give you one extra point.')}
        <br />
        {t('Languages may be either')} <b>{t('spoken and understood')}</b> {t('or')}{' '}
        <b>{t('just understood.')}</b>
        <br />
        {t('One language is worth')} <b>{t('1 point,')}</b>{' '}
        {t('even if that language is only understood and not spoken.')}
        <br />
        {t(
          'You must have at least one known language, and you must understand Sol Common to play most station jobs.',
        )}{' '}
        <br />
        {t(
          'It does not cost points to toggle speech of a language - it only costs points to add an entirely new language.',
        )}
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length} {t('available languages')}
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
                {t('known languages')}
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
