import { useEffect } from 'react';
import {
  getRememberedInterfaceLanguage,
  getRememberedUIElementLanguage,
  isPanelLanguage,
  rememberUIElementLanguage,
  setInterfaceLanguage,
  setUIElementLanguage,
  type PanelLanguage,
  type UIElementType,
} from 'common/panelLocalization';
import { useBackend } from 'tgui/backend';
import { Box, Button, Stack } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../../../localization';
import type { PreferencesMenuData } from '../../../../types';
import type { Feature, FeatureValueProps } from '../../base';

type PanelLanguageSettingsData = PreferencesMenuData;

const languageChoices: Array<{
  value: PanelLanguage;
  label: string;
}> = [
  { value: 'english', label: 'English' },
  { value: 'russian', label: 'Russian' },
];

const categories: Array<{
  id: UIElementType;
  en: {
    name: string;
    description: string;
  };
  ru: {
    name: string;
    description: string;
  };
}> = [
  {
    id: 'preferences',
    en: {
      name: 'Character preferences',
      description: 'Character editor, jobs, loadout, quirks, and related menus.',
    },
    ru: {
      name: 'Настройки персонажа',
      description:
        'Редактор персонажа, профессии, лодаут, квирки и связанные меню.',
    },
  },
  {
    id: 'game_preferences',
    en: {
      name: 'Game settings',
      description: 'Tabs and options inside this settings window.',
    },
    ru: {
      name: 'Игровые настройки',
      description: 'Вкладки и параметры внутри этого окна настроек.',
    },
  },
  {
    id: 'interaction',
    en: {
      name: 'Interaction panel',
      description: 'Mob interaction menu and its tabs.',
    },
    ru: {
      name: 'Панель взаимодействия',
      description: 'Меню взаимодействия с мобами и его вкладки.',
    },
  },
  {
    id: 'antag_info',
    en: {
      name: 'Antagonist panels',
      description:
        'Antag briefings, objectives, heretic panel, and similar popups.',
    },
    ru: {
      name: 'Панели антагонистов',
      description:
        'Брифинги антагонистов, цели, панель еретика и похожие окна.',
    },
  },
  {
    id: 'rnd',
    en: {
      name: 'R&D',
      description: 'Research tree and science consoles.',
    },
    ru: {
      name: 'R&D',
      description: 'Дерево исследований и научные консоли.',
    },
  },
  {
    id: 'announce',
    en: {
      name: 'Announcements',
      description: 'Station alerts, event announcements, and command notices.',
    },
    ru: {
      name: 'Оповещения',
      description:
        'Станционные тревоги, анонсы событий и служебные объявления.',
    },
  },
  {
    id: 'storyteller',
    en: {
      name: 'Storyteller panel',
      description:
        'Storyteller control, pacing overview, queued antagonists, and diagnostic tabs.',
    },
    ru: {
      name: 'Панель сторителлера',
      description:
        'Управление сторителлером, обзор темпа раунда, очередь антагонистов и диагностические вкладки.',
    },
  },
];

function InterfaceLanguageControl(
  props: FeatureValueProps<string, string>,
) {
  const { act, data } = useBackend<PanelLanguageSettingsData>();
  const { language } = usePreferencesLocalization(data, 'game_preferences');
  const isRussian = language === 'russian';
  const panelLanguages = data.panel_languages || {};
  const selectedPrimaryLanguage =
    getRememberedInterfaceLanguage() ||
    (isPanelLanguage(props.value) ? props.value : null) ||
    language;

  useEffect(() => {
    for (const category of categories) {
      const storedLanguage = panelLanguages[category.id];
      if (isPanelLanguage(storedLanguage)) {
        rememberUIElementLanguage(category.id, storedLanguage);
      }
    }
  }, [panelLanguages]);

  const setPrimaryLanguage = (nextLanguage: PanelLanguage) => {
    props.handleSetValue(nextLanguage);
    void setInterfaceLanguage(nextLanguage);
  };

  const setCategoryLanguage = (
    element: UIElementType,
    nextLanguage: PanelLanguage,
  ) => {
    act('set_ui_language', {
      element,
      language: nextLanguage,
    });
    void setUIElementLanguage(element, nextLanguage);
  };

  return (
    <Stack vertical fill g={1}>
      <Stack vertical g={0.5}>
        <Box bold>
          {isRussian
            ? 'Основной язык интерфейса'
            : 'Primary interface language'}
        </Box>
        <Box color="label" fontSize="0.95em">
          {isRussian
            ? 'Используется как язык по умолчанию для интерфейсов без отдельной категории.'
            : 'Used as the fallback language for interfaces without a separate category.'}
        </Box>
        <Stack g={0.5}>
          {languageChoices.map((choice) => (
            <Stack.Item key={choice.value}>
              <Button
                minWidth="96px"
                selected={selectedPrimaryLanguage === choice.value}
                onClick={() => setPrimaryLanguage(choice.value)}
              >
                {choice.label}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack>

      <Stack.Divider />

      {categories.map((category) => {
        const localized = isRussian ? category.ru : category.en;
        const selectedLanguage =
          getRememberedUIElementLanguage(category.id) ||
          panelLanguages[category.id] ||
          selectedPrimaryLanguage;

        return (
          <Stack key={category.id} align="center" fill>
            <Stack.Item grow basis={0} mr={1.5}>
              <Box bold>{localized.name}</Box>
              <Box color="label" fontSize="0.95em">
                {localized.description}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Stack g={0.5}>
                {languageChoices.map((choice) => (
                  <Stack.Item key={`${category.id}-${choice.value}`}>
                    <Button
                      minWidth="96px"
                      selected={selectedLanguage === choice.value}
                      onClick={() =>
                        setCategoryLanguage(category.id, choice.value)
                      }
                    >
                      {choice.label}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        );
      })}
    </Stack>
  );
}

export const interface_language: Feature<string> = {
  name: 'Translation Categories',
  category: 'LANGUAGE',
  description:
    'Set the global interface language and separate languages for specific interface groups.',
  component: InterfaceLanguageControl,
};
