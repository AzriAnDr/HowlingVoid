// THIS IS A NOVA SECTOR UI FILE
import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import {
  getCharacterPreferencesLanguage,
  localize,
} from './localization';
import type { Language, PreferencesMenuData } from '../types';

export function KnownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  return (
    <Stack.Item>
      <Section
        className="PreferencesMenu__Languages__LanguageCard"
        title={
          <>
            <Box
              // Manually putting the icon here instead of using the buttons prop cause it looks better
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
          tooltip={localize(
            language,
            'Forgetting how to understand the language will also prevent you from speaking it.',
          )}
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          {localize(language, 'Forget')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={props.language.speaking ? 'good' : 'default'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? localize(
                  language,
                  'Forget how to speak the language, but you keep your understanding of it.',
                )
              : localize(language, 'Learn to speak the language.')
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
          {props.language.speaking
            ? localize(language, 'Can speak')
            : localize(language, 'Can only understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function UnknownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  const noPoints =
    data.selected_languages.length === data.total_language_points;
  return (
    <Stack.Item>
      <Section
        className="PreferencesMenu__Languages__LanguageCard"
        title={
          <>
            <Box
              // Manually putting the icon here instead of using the buttons prop cause it looks better
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
          tooltip={localize(
            language,
            'Learn to speak and understand the language.',
          )}
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          {localize(language, 'Speak')}
        </Button>
        <Button
          className="PreferencesMenu__Languages__ActionButton"
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip={localize(
            language,
            'Learn to understand the language but not speak it.',
          )}
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          {localize(language, 'Understand')}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const language = getCharacterPreferencesLanguage(data);
  return (
    <Stack className="PreferencesMenu__Languages" vertical fill>
      <Stack.Item>
        <Section className="PreferencesMenu__Languages__Info" textAlign="center">
          {localize(
            language,
            'Here, you can learn languages using a point system.',
          )}{' '}<b>{localize(language, 'Linguist')}</b>{' '}
          {localize(language, 'neutral quirk will give you one extra point.')}
          <br />
          {localize(language, 'Languages may be either')}{' '}
          <b>{localize(language, 'spoken and understood')}</b>{' '}
          {localize(language, 'or')}{' '}
          <b>{localize(language, 'just understood.')}</b>
          <br />
          {localize(language, 'One language is worth')}{' '}
          <b>1 {localize(language, 'point,')}</b>{' '}
          {localize(
            language,
            'even if that language is only understood and not spoken.',
          )}
          <br />
          {localize(
            language,
            'You must have at least one known language, and you must understand Sol Common to play most station jobs.',
          )}{' '}
          <br />
          {localize(
            language,
            'It does not cost points to toggle speech of a language - it only costs points to add an entirely new language.',
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item minWidth="50%">
            <Section
              className="PreferencesMenu__Languages__Column"
              title={
                <Box className="PreferencesMenu__Languages__ColumnTitle" fontSize="150%">
                  {data.unselected_languages.length}{' '}
                  {localize(language, 'available languages')}
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
              className="PreferencesMenu__Languages__Column"
              title={
                <Box className="PreferencesMenu__Languages__ColumnTitle" fontSize="150%">
                  {data.selected_languages.length}/{data.total_language_points}{' '}
                  {localize(language, 'known languages')}
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
      </Stack.Item>
    </Stack>
  );
}
