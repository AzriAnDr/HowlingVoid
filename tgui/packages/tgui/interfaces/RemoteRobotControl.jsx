import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const RemoteRobotControl = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <Window title={t('ui.remote_robot_control.title')} width={500} height={500}>
      <Window.Content scrollable>
        <RemoteRobotControlContent />
      </Window.Content>
    </Window>
  );
};

export const RemoteRobotControlContent = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const { robots = [] } = data;
  if (!robots.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">{t('ui.remote_robot_control.no_robots_detected')}</NoticeBox>
      </Section>
    );
  }
  return robots.map((robot) => {
    return (
      <Section
        key={robot.ref}
        title={`${robot.name} (${robot.model})`}
        buttons={
          <>
            <Button
              icon="tools"
              content={t('ui.remote_robot_control.interface')}
              onClick={() =>
                act('interface', {
                  ref: robot.ref,
                })
              }
            />
            <Button
              icon="phone-alt"
              content={t('ui.remote_robot_control.call')}
              onClick={() =>
                act('callbot', {
                  ref: robot.ref,
                })
              }
            />
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.common.status')}>
            <Box
              inline
              color={
                decodeHtmlEntities(robot.mode) === 'Inactive'
                  ? 'bad'
                  : decodeHtmlEntities(robot.mode) === 'Idle'
                    ? 'average'
                    : 'good'
              }
            >
              {decodeHtmlEntities(robot.mode)}
            </Box>{' '}
            {(robot.hacked && (
              <Box inline color="bad">
                ({t('ui.remote_robot_control.hacked')})
              </Box>
            )) ||
              ''}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.location')}>{robot.location}</LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
