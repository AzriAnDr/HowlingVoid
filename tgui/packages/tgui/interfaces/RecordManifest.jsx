// THIS IS A NOVA SECTOR UI FILE
import { Button, Icon, Section, Table, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const commandJobs = [
  'Head of Personnel',
  'Head of Security',
  'Chief Engineer',
  'Research Director',
  'Chief Medical Officer',
];

export const RecordManifest = (props) => {
  const { t } = usePreferencesLocalization();
  const {
    data: { manifest, positions },
  } = useBackend();
  const { act } = useBackend();

  return (
    <Window title={t('ui.record_manifest.all_crew_with_information')} width={450} height={500}>
      <Window.Content scrollable>
        {Object.entries(manifest).map(([dept, crew]) => (
          <Section className={`CrewManifest--${dept}`} key={dept} title={dept}>
            <Table>
              {Object.entries(crew).map(([crewIndex, crewMember]) => (
                <Table.Row key={crewIndex}>
                  <Table.Cell className={'CrewManifest__Cell'}>
                    {crewMember.name}
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      content={t('ui.record_manifest.show_exploitables')}
                      onClick={() =>
                        act('show_exploitables', {
                          exploitable_id: crewMember.name,
                        })
                      }
                    />
                    <Button
                      content={t('ui.record_manifest.show_background')}
                      onClick={() =>
                        act('show_background', {
                          background_id: crewMember.name,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell
                    className={classes([
                      'CrewManifest__Cell',
                      'CrewManifest__Icons',
                    ])}
                    collapsing
                  >
                    {positions[dept].exceptions.includes(crewMember.rank) && (
                      <Tooltip content={t('ui.record_manifest.no_position_limit')} position="bottom">
                        <Icon className="CrewManifest__Icon" name="infinity" />
                      </Tooltip>
                    )}
                    {crewMember.rank === 'Captain' && (
                      <Tooltip content={t('ui.record_manifest.captain')} position="bottom">
                        <Icon
                          className={classes([
                            'CrewManifest__Icon',
                            'CrewManifest__Icon--Command',
                          ])}
                          name="star"
                        />
                      </Tooltip>
                    )}
                    {commandJobs.includes(crewMember.rank) && (
                      <Tooltip content={t('ui.record_manifest.member_of_command')} position="bottom">
                        <Icon
                          className={classes([
                            'CrewManifest__Icon',
                            'CrewManifest__Icon--Command',
                            'CrewManifest__Icon--Chevron',
                          ])}
                          name="chevron-up"
                        />
                      </Tooltip>
                    )}
                  </Table.Cell>
                  <Table.Cell
                    className={classes([
                      'CrewManifest__Cell',
                      'CrewManifest__Cell--Rank',
                    ])}
                    collapsing
                  >
                    {crewMember.rank}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
