import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  orphaned_keys: string[];
  archived_keys: string[];
};

export const AchievementsAdminPanel = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend<Data>();
  const { orphaned_keys, archived_keys } = data;
  return (
    <Window title={t('ui.achievements_admin_panel.title')} width={540} height={680}>
      <Window.Content scrollable>
        <Section title={t('ui.achievements_admin_panel.orphaned_achievements')}>
          <NoticeBox>
            {t('ui.achievements_admin_panel.orphaned_help')}
          </NoticeBox>
          <LabeledList>
            {orphaned_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={
                  <>
                    <Button.Confirm
                      onClick={() => act('archive', { key: key })}
                    >
                      {t('ui.common.archive')}
                    </Button.Confirm>
                    <Button.Confirm
                      onClick={() => act('cleanup_orphan', { key: key })}
                    >
                      {t('ui.common.cleanup')}
                    </Button.Confirm>
                  </>
                }
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title={t('ui.achievements_admin_panel.archived_achievements')}>
          <NoticeBox>{t('ui.achievements_admin_panel.archived_help')}</NoticeBox>
          <LabeledList>
            {archived_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={
                  <Button.Confirm
                    onClick={() => act('cleanup_orphan', { key: key })}
                  >
                    {t('ui.common.cleanup')}
                  </Button.Confirm>
                }
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
