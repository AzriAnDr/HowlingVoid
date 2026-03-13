import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const dangerMap = {
  2: {
    color: 'good',
    localStatusText: 'Offline',
  },
  1: {
    color: 'average',
    localStatusText: 'Caution',
  },
  0: {
    color: 'bad',
    localStatusText: 'Optimal',
  },
};

export const AiAirlock = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const statusMain = dangerMap[data.power.main] || dangerMap[0];
  const statusBackup = dangerMap[data.power.backup] || dangerMap[0];
  const statusElectrify = dangerMap[data.shock] || dangerMap[0];
  return (
    <Window width={500} height={390}>
      <Window.Content>
        <Section title={t('ui.ai_airlock.power_status')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.common.main')}
              color={statusMain.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.main}
                  content={t('ui.ai_airlock.disrupt')}
                  onClick={() => act('disrupt-main')}
                />
              }
            >
              {data.power.main ? t('ui.common.online') : t('ui.common.offline')}{' '}
              {((!data.wires.main_1 || !data.wires.main_2) &&
                '[Wires have been cut!]') ||
                (data.power.main_timeleft > 0 &&
                  `[${data.power.main_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.common.backup')}
              color={statusBackup.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.backup}
                  content={t('ui.ai_airlock.disrupt')}
                  onClick={() => act('disrupt-backup')}
                />
              }
            >
              {data.power.backup ? t('ui.common.online') : t('ui.common.offline')}{' '}
              {((!data.wires.backup_1 || !data.wires.backup_2) &&
                '[Wires have been cut!]') ||
                (data.power.backup_timeleft > 0 &&
                  `[${data.power.backup_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.ai_airlock.electrify')}
              color={statusElectrify.color}
              buttons={
                <>
                  <Button
                    icon="wrench"
                    disabled={!(data.wires.shock && data.shock === 0)}
                    content={t('ui.common.restore')}
                    onClick={() => act('shock-restore')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content={t('ui.common.temporary')}
                    onClick={() => act('shock-temp')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content={t('ui.common.permanent')}
                    onClick={() => act('shock-perm')}
                  />
                </>
              }
            >
              {data.shock === 2 ? t('ui.common.safe') : t('ui.ai_airlock.electrified')}{' '}
              {(!data.wires.shock && '[Wires have been cut!]') ||
                (data.shock_timeleft > 0 && `[${data.shock_timeleft}s]`) ||
                (data.shock_timeleft === -1 && '[Permanent]')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={t('ui.ai_airlock.access_door_control')}>
          <LabeledList>
            <LabeledList.Item
              label={t('ui.ai_airlock.id_scan')}
              color="bad"
              buttons={
                <Button
                  icon={data.id_scanner ? 'power-off' : 'times'}
                  content={data.id_scanner ? t('ui.common.enabled') : t('ui.common.disabled')}
                  selected={data.id_scanner}
                  disabled={!data.wires.id_scanner}
                  onClick={() => act('idscan-toggle')}
                />
              }
            >
              {!data.wires.id_scanner && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.ai_airlock.emergency_access')}
              buttons={
                <Button
                  icon={data.emergency ? 'power-off' : 'times'}
                  content={data.emergency ? t('ui.common.enabled') : t('ui.common.disabled')}
                  selected={data.emergency}
                  onClick={() => act('emergency-toggle')}
                />
              }
            />
            <LabeledList.Divider />
            <LabeledList.Item
              label={t('ui.ai_airlock.door_bolts')}
              color="bad"
              buttons={
                <Button
                  icon={data.locked ? 'lock' : 'unlock'}
                  content={data.locked ? t('ui.ai_airlock.lowered') : t('ui.ai_airlock.raised')}
                  selected={data.locked}
                  disabled={!data.wires.bolts}
                  onClick={() => act('bolt-toggle')}
                />
              }
            >
              {!data.wires.bolts && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.ai_airlock.door_feedback')}
              color="bad"
              buttons={
                <Button
                  icon={data.feedback ? 'power-off' : 'times'}
                  content={data.feedback ? t('ui.common.enabled') : t('ui.common.disabled')}
                  selected={data.feedback}
                  disabled={!data.wires.feedback}
                  onClick={() => act('light-toggle')}
                />
              }
            >
              {!data.wires.feedback && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.ai_airlock.door_force_sensors')}
              color="bad"
              buttons={
                <Button
                  icon={data.safe ? 'power-off' : 'times'}
                  content={data.safe ? t('ui.common.enabled') : t('ui.common.disabled')}
                  selected={data.safe}
                  disabled={!data.wires.safe}
                  onClick={() => act('safe-toggle')}
                />
              }
            >
              {!data.wires.safe && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label={t('ui.ai_airlock.door_timing_safety')}
              color="bad"
              buttons={
                <Button
                  icon={data.speed ? 'power-off' : 'times'}
                  content={data.speed ? t('ui.common.enabled') : t('ui.common.disabled')}
                  selected={data.speed}
                  disabled={!data.wires.timing}
                  onClick={() => act('speed-toggle')}
                />
              }
            >
              {!data.wires.timing && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item
              label={t('ui.ai_airlock.door_control')}
              color="bad"
              buttons={
                <Button
                  icon={data.opened ? 'sign-out-alt' : 'sign-in-alt'}
                  content={data.opened ? t('ui.common.open') : t('ui.common.closed')}
                  selected={data.opened}
                  disabled={data.locked || data.welded}
                  onClick={() => act('open-close')}
                />
              }
            >
              {!!(data.locked || data.welded) && (
                <span>
                  [{t('ui.ai_airlock.door_is')} {data.locked ? t('ui.ai_airlock.bolted') : ''}
                  {data.locked && data.welded ? ' and ' : ''}
                  {data.welded ? t('ui.ai_airlock.welded') : ''}!]
                </span>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
