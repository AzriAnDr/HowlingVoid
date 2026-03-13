import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { Experiment, TechwebServer } from '../ExperimentConfigure';
import type { OperatingComputerData } from './types';

export const ExperimentView = () => {
  const { act, data } = useBackend<OperatingComputerData>();
  const { techwebs, experiments } = data;
  const { t } = usePreferencesLocalization(data);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title={t('ui.operating_computer.servers')}
          fill
          buttons={
            <Button onClick={() => act('open_experiments')}>
              {t('ui.operating_computer.open_config')}
            </Button>
          }
        >
          <TechwebServer techwebs={techwebs} can_select={false} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill>
          {techwebs.some((e) => e.selected) && (
            <Stack.Item grow>
              <Section title={t('ui.operating_computer.experiments')} scrollable fill>
                {experiments.length > 0 ? (
                  experiments
                    .sort((a, b) => (a.name > b.name ? 1 : -1))
                    .map((exp, i) => (
                      <Experiment key={i} exp={exp} can_select={false} />
                    ))
                ) : (
                  <NoticeBox color="yellow">
                    {t('ui.operating_computer.no_experiments_found')}
                  </NoticeBox>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
