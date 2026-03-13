import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const BorgPanel = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const borg = data.borg || {};
  const cell = data.cell || {};
  const cellPercent = cell.charge / cell.maxcharge;
  const channels = data.channels || [];
  const modules = data.modules || [];
  const upgrades = data.upgrades || [];
  const ais = data.ais || [];
  const laws = data.laws || [];
  return (
    <Window title={t('ui.borg_panel.title')} theme="admin" width={700} height={700}>
      <Window.Content scrollable>
        <Section
          title={borg.name}
          buttons={
            <Button
              icon="pencil-alt"
              content={t('ui.common.rename')}
              onClick={() => act('rename')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label={t('ui.common.status')}>
              <Button
                icon={borg.emagged ? 'check-square-o' : 'square-o'}
                content={t('ui.borg_panel.emagged')}
                selected={borg.emagged}
                onClick={() => act('toggle_emagged')}
              />
              <Button
                icon={borg.lockdown ? 'check-square-o' : 'square-o'}
                content={t('ui.borg_panel.locked_down')}
                selected={borg.lockdown}
                onClick={() => act('toggle_lockdown')}
              />
              <Button
                icon={borg.scrambledcodes ? 'check-square-o' : 'square-o'}
                content={t('ui.borg_panel.scrambled_codes')}
                selected={borg.scrambledcodes}
                onClick={() => act('toggle_scrambledcodes')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.borg_panel.charge')}>
              {!cell.missing ? (
                <ProgressBar value={cellPercent}>
                  {`${cell.charge} / ${cell.maxcharge}`}
                </ProgressBar>
              ) : (
                <span className="color-bad">{t('ui.borg_panel.no_cell_installed')}</span>
              )}
              <br />
              <Button
                icon="pencil-alt"
                content={t('ui.common.set')}
                onClick={() => act('set_charge')}
              />
              <Button
                icon="eject"
                content={t('ui.common.change')}
                onClick={() => act('change_cell')}
              />
              <Button
                icon="trash"
                content={t('ui.common.remove')}
                color="bad"
                onClick={() => act('remove_cell')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.borg_panel.radio_channels')}>
              {channels.map((channel) => (
                <Button
                  key={channel.name}
                  icon={channel.installed ? 'check-square-o' : 'square-o'}
                  content={channel.name}
                  selected={channel.installed}
                  onClick={() =>
                    act('toggle_radio', {
                      channel: channel.name,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.model')}>
              {modules.map((module) => (
                <Button
                  key={module.type}
                  icon={
                    borg.active_module === module.type
                      ? 'check-square-o'
                      : 'square-o'
                  }
                  content={module.name}
                  selected={borg.active_module === module.type}
                  onClick={() =>
                    act('setmodule', {
                      module: module.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.upgrades')}>
              {upgrades.map((upgrade) => (
                <Button
                  key={upgrade.type}
                  icon={upgrade.installed ? 'check-square-o' : 'square-o'}
                  content={upgrade.name}
                  selected={upgrade.installed}
                  onClick={() =>
                    act('toggle_upgrade', {
                      upgrade: upgrade.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.borg_panel.master_ai')}>
              {ais.map((ai) => (
                <Button
                  key={ai.ref}
                  icon={ai.connected ? 'check-square-o' : 'square-o'}
                  content={ai.name}
                  selected={ai.connected}
                  onClick={() =>
                    act('slavetoai', {
                      slavetoai: ai.ref,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={t('ui.common.laws')}
          buttons={
            <Button
              icon={borg.lawupdate ? 'check-square-o' : 'square-o'}
              content={t('ui.borg_panel.lawsync')}
              selected={borg.lawupdate}
              onClick={() => act('toggle_lawupdate')}
            />
          }
        >
          {laws.map((law) => (
            <Box key={law}>{law}</Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
