import {
  AnimatedNumber,
  BlockQuote,
  Button,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosSkillTracker = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { skills = {} } = data;
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
        <Section title={t('ui.ntosskilltracker.skill_tracker')}>
          {skills.map((skill, idx) => (
            <Section key={idx} level={2} title={skill.name}>
              <BlockQuote>{skill.desc}</BlockQuote>
              <Section>
                <Table>
                  <Table.Row header>
                    <Table.Cell textAlign="center" collapsing>
                      {t('ui.common.level')}
                    </Table.Cell>
                    <Table.Cell textAlign="center">{t('ui.ntosskilltracker.level_progress')}</Table.Cell>
                    <Table.Cell textAlign="center">{t('ui.ntosskilltracker.overall_progress')}</Table.Cell>
                  </Table.Row>
                  <Table.Row className="candystripe">
                    <Table.Cell textAlign="center" collapsing>
                      {skill.lvl_name}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {skill.progress_percent ? (
                        <ProgressBar
                          value={skill.progress_percent}
                          ranges={{
                            good: [0.75, 1.0],
                          }}
                        >
                          <AnimatedNumber
                            value={Math.round(skill.progress_percent * 100)}
                          />
                          %
                        </ProgressBar>
                      ) : (
                        '—'
                      )}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {skill.overall_percent ? (
                        <ProgressBar
                          value={skill.overall_percent}
                          ranges={{
                            good: [0.75, 1.0],
                          }}
                        >
                          <AnimatedNumber
                            value={Math.round(skill.overall_percent * 100)}
                          />
                          %
                        </ProgressBar>
                      ) : (
                        '—'
                      )}
                    </Table.Cell>
                  </Table.Row>
                  {!!skill.reward && (
                    <Table.Row className="candystripe">
                      <Table.Cell textAlign="center" colSpan={3}>
                        <Button
                          icon="trophy"
                          style={{ margin: '8px' }}
                          onClick={() =>
                            act('PRG_reward', { skill: skill.name })
                          }
                        >
                          {t('ui.ntos_skill_tracker.contact_professional_association').replace(
                            '{title}',
                            skill.title,
                          )}
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Section>
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
