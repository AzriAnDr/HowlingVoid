import { Box, Button, Flex, Icon } from 'tgui-core/components';
import { usePreferencesLocalization } from '../localization';

export function LockedExperiment(props) {
  const { t } = usePreferencesLocalization(undefined, 'rnd');
  return (
    <Box m={1} className="ExperimentConfigure__ExperimentPanel">
      <Button
        fluid
        backgroundColor="#40628a"
        className="ExperimentConfigure__ExperimentName"
        disabled
      >
        <Flex align="center" justify="space-between">
          <Flex.Item color="rgba(0, 0, 0, 0.6)">
            <Icon name="lock" />
            {t('ui.techweb.undiscovered_experiment')}
          </Flex.Item>
          <Flex.Item color="rgba(0, 0, 0, 0.5)">
            {t('ui.techweb.unknown_placeholder')}
          </Flex.Item>
        </Flex>
      </Button>
      <Box className="ExperimentConfigure__ExperimentContent">
        {t('ui.techweb.experiment_not_discovered_yet')}
      </Box>
    </Box>
  );
}
