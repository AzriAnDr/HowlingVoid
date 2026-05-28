// THIS IS A NOVA SECTOR UI FILE
import {
  Button,
  Collapsible,
  LabeledList,
  Section,
  TextArea,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type StoryManagerData = {
  current_stories?: Story[] | null;
  archived_stories?: Story[] | null;
  current_date: string;
};

type Story = {
  title: string;
  text: string;
  id: string;
  year: string;
  month: string;
  day: string;
};

export const StoryManager = (props) => {
  const { data, act } = useBackend<StoryManagerData>();
  const { t } = usePreferencesLocalization(data);
  const { current_stories, archived_stories, current_date } = data;
  const currentStories = current_stories || [];
  const archivedStories = archived_stories || [];

  const [title, setTitle] = useLocalState('title', '');
  const [text, setText] = useLocalState('text', '');
  const [id, setID] = useLocalState('id', '');

  return (
    <Window width={600} height={800} title={t('ui.story_manager.title')}>
      <Window.Content scrollable>
        <Section textAlign="center">
          {t('ui.story_manager.header')}
          <br />
          <i>{t('ui.story_manager.next_round_notice')}</i>
          <br />
          <span style={{ color: 'red' }}>
            {t('ui.story_manager.do_not_mess_warning')}
          </span>
        </Section>
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.common.title')}>
              <TextArea
                height="20px"
                placeholder={t('ui.story_manager.title_placeholder')}
                onChange={(value) => setTitle(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.story_manager.body_text')}>
              <TextArea
                height="100px"
                placeholder={t('ui.story_manager.body_placeholder')}
                onChange={(value) => setText(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.id')}>
              <TextArea
                height="20px"
                placeholder={t('ui.story_manager.id_placeholder')}
                onChange={(value) => setID(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.date')}>
              <i>{`${t('ui.story_manager.publishing_date')}: ${current_date}`}</i>
            </LabeledList.Item>
          </LabeledList>
          <Button
            icon="arrow-up"
            mr="9px"
            color="blue"
            onClick={() => {
              act('publish_article', {
                title: title,
                text: text,
                id: id,
              });
            }}
          >
            {t('ui.common.publish')}
          </Button>
        </Section>
        <Collapsible title={t('ui.story_manager.current_stories')}>
          {currentStories.map((story) => (
            <Collapsible
              bold
              key={story.id}
              title={
                story.title +
                ' | Published ' +
                story.month +
                '/' +
                story.day +
                '/' +
                story.year
              }
            >
              <Section>
                {story.text}
                <br />
                <Button
                  icon="book"
                  mr="9px"
                  color="red"
                  onClick={() => {
                    act('archive_article', {
                      id: story.id,
                    });
                  }}
                >
                  {t('ui.common.archive')}
                </Button>
              </Section>
            </Collapsible>
          ))}
        </Collapsible>
        <Collapsible title={t('ui.story_manager.archived_stories')}>
          {archivedStories.map((story) => (
            <Collapsible
              bold
              key={story.id}
              title={
                story.title +
                ' | Published ' +
                story.month +
                '/' +
                story.day +
                '/' +
                story.year
              }
            >
              <Section>
                {story.text}
                <br />
                <Button
                  icon="floppy-disk"
                  mr="9px"
                  color="green"
                  onClick={() => {
                    act('circulate_article', {
                      id: story.id,
                    });
                  }}
                >
                  {t('ui.story_manager.circulate')}
                </Button>
              </Section>
            </Collapsible>
          ))}
        </Collapsible>
      </Window.Content>
    </Window>
  );
};
