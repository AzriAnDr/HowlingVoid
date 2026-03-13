import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const PortableGenerator = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { stack_percent } = data;
  const stackPercentState =
    (stack_percent > 50 && 'good') ||
    (stack_percent > 15 && 'average') ||
    'bad';
  return (
    <Window width={450} height={340}>
      <Window.Content scrollable>
        {!data.anchored && (
          <NoticeBox>{t('ui.portable_generator.not_anchored')}</NoticeBox>
        )}
        <Section title={t('ui.portable_generator.status')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.portable_generator.power_switch')}>
              <Button
                icon={data.active ? 'power-off' : 'times'}
                onClick={() => act('toggle_power')}
                disabled={!data.ready_to_boot}
              >
                {data.active
                  ? t('ui.portable_generator.on')
                  : t('ui.portable_generator.off')}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.portable_generator.sheet_count', {
                sheet_name: data.sheet_name,
              })}
            >
              <Box inline color={stackPercentState}>
                {data.sheets}
              </Box>
              {data.sheets >= 1 && (
                <Button
                  ml={1}
                  icon="eject"
                  disabled={data.active}
                  onClick={() => act('eject')}
                >
                  {t('ui.portable_generator.eject')}
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.portable_generator.current_sheet_level')}
            >
              <ProgressBar
                value={data.stack_percent / 100}
                ranges={{
                  good: [0.1, Infinity],
                  average: [0.01, 0.1],
                  bad: [-Infinity, 0.01],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.portable_generator.heat_level')}>
              {data.current_heat < 100 ? (
                <Box inline color="good">
                  {t('ui.portable_generator.nominal')}
                </Box>
              ) : data.current_heat < 200 ? (
                <Box inline color="average">
                  {t('ui.portable_generator.caution')}
                </Box>
              ) : (
                <Box inline color="bad">
                  {t('ui.portable_generator.danger')}
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.portable_generator.output')}>
          <LabeledList>
            <LabeledList.Item label={t('ui.portable_generator.current_output')}>
              {data.power_output}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.portable_generator.adjust_output')}>
              <Button icon="minus" onClick={() => act('lower_power')}>
                {data.power_generated}
              </Button>
              <Button icon="plus" onClick={() => act('higher_power')}>
                {data.power_generated}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.portable_generator.power_available')}
            >
              <Box inline color={!data.connected && 'bad'}>
                {data.connected
                  ? data.power_available
                  : t('ui.portable_generator.unconnected')}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
