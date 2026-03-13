import {
  Button,
  Divider,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  linked_scanner: BooleanLike;
  linked_pod: BooleanLike;
  is_scanning: BooleanLike;
  is_cloning: BooleanLike;
  record_name?: string;
  record_species?: string;
  scanner_occupant?: string;
  scanner_species?: string;
  cloning_name?: string;
  cloning_species?: string;
  cloning_progress?: number;
};

export const ExperimentalCloner = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    linked_scanner,
    linked_pod,
    record_name,
    record_species,
    scanner_occupant,
    scanner_species,
    is_scanning,
    is_cloning,
    cloning_name,
    cloning_species,
    cloning_progress,
  } = data;

  return (
    <Window
      title={t('ui.experimental_cloner.title')}
      width={500}
      height={300}
      theme="ntOS95"
    >
      <Window.Content>
        <Section
          title={t('ui.experimental_cloner.stored_subject')}
          buttons={
            <Button
              icon="x"
              color="bad"
              tooltip={t('ui.experimental_cloner.clear_stored_record')}
              onClick={() => act('clear_record')}
              disabled={!record_name}
              tooltipPosition="bottom-start"
            >
              {t('ui.common.clear')}
            </Button>
          }
        >
          {record_name ? (
            <Stack.Item>
              {record_name} ({record_species ?? t('ui.common.unknown')})
            </Stack.Item>
          ) : (
            t('ui.experimental_cloner.no_stored_dna')
          )}
        </Section>
        <Stack fill>
          <Stack.Item width="50%" mb={13}>
            <Section fill title={t('ui.experimental_cloner.scanner')}>
              {linked_scanner ? (
                <Stack.Item textAlign="center">
                  <Stack vertical>
                    <Stack.Item bold>
                      {t('ui.experimental_cloner.current_occupant')}:
                    </Stack.Item>
                    <Stack.Item>{scanner_occupant ?? t('ui.common.none')}</Stack.Item>
                    {scanner_occupant && (
                      <Stack vertical>
                        <Stack.Item bold>
                          {t('ui.experimental_cloner.occupant_species')}:
                        </Stack.Item>
                        <Stack.Item>
                          {scanner_species ?? t('ui.common.unknown')}
                        </Stack.Item>
                        <Divider />
                        <Button
                          color="good"
                          onClick={() => act('start_scan')}
                          content={
                            is_scanning
                              ? t('ui.experimental_cloner.scanning')
                              : t('ui.experimental_cloner.scan_now')
                          }
                          disabled={is_scanning}
                        />
                      </Stack>
                    )}
                  </Stack>
                </Stack.Item>
              ) : (
                <Stack.Item textAlign="center">
                  {t('ui.experimental_cloner.no_scanner_connected')}
                </Stack.Item>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item width="50%" mb={13}>
            <Section fill title={t('ui.experimental_cloner.cloning_pod')}>
              {linked_pod ? (
                <Stack.Item textAlign="center">
                  {is_cloning ? (
                    <Stack vertical>
                      <Stack.Item bold>
                        {t('ui.experimental_cloner.currently_cloning')}:
                      </Stack.Item>
                      <Stack.Item>
                        {cloning_name} ({cloning_species ?? t('ui.common.unknown')})
                      </Stack.Item>
                      <Stack.Item>
                        <ProgressBar
                          value={cloning_progress ?? 0}
                          minValue={0}
                          maxValue={100}
                          color="good"
                        />
                      </Stack.Item>
                      {cloning_progress === 100 && (
                        <Stack.Item>
                          {t('ui.experimental_cloner.beginning_neural_kickstart')}
                        </Stack.Item>
                      )}
                    </Stack>
                  ) : (
                    <Stack vertical>
                      <Button
                        color="good"
                        onClick={() => act('start_clone')}
                        content={
                          is_cloning
                            ? t('ui.experimental_cloner.cloning')
                            : t('ui.experimental_cloner.begin_cloning')
                        }
                        disabled={is_cloning || !record_name}
                        tooltip={!record_name && t('ui.experimental_cloner.no_dna_on_record')}
                      />
                    </Stack>
                  )}
                </Stack.Item>
              ) : (
                <Stack.Item textAlign="center">
                  {t('ui.experimental_cloner.no_pod_connected')}
                </Stack.Item>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
