import { Box, Button, Icon, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosSpectreMeter = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { auto_mode, spook_value, on_cooldown } = data;
  return (
    <NtosWindow width={400} height={180}>
      <NtosWindow.Content>
        <Section title={t('ui.ntos_spectre_meter.title')}>
          <Box>
            <Button
              inline
              icon="cog"
              content={auto_mode ? t('ui.common.auto') : t('ui.common.manual')}
              onClick={() => act('toggle_mode')}
              selected={auto_mode}
              tooltip={t('ui.ntos_spectre_meter.toggle_automatic_scanning')}
            />
            <Button
              inline
              icon="magnifying-glass"
              content={t('ui.common.scan')}
              disabled={auto_mode || on_cooldown}
              tooltip={t('ui.ntos_spectre_meter.has_cooldown_about_2_seconds')}
              onClick={() => act('manual_scan')}
            />
          </Box>
          <ProgressBar
            value={spook_value}
            maxValue={100}
            ranges={{
              good: [0, 33],
              average: [33, 66],
              bad: [66, 100],
              purple: [100, Infinity],
            }}
          >
            <Box
              lineHeight={1.6}
              fontSize={1.5}
              textAlign="center"
              fontFamily="Comic Sans MS"
              fluid
            >
              <Icon spin name="ghost" />
              {` ${t('ui.ntos_spectre_meter.spookiness')}: ${spook_value}% `}
              <Icon spin name="ghost" />
            </Box>
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
