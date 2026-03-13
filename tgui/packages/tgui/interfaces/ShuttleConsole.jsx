import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  LabeledList,
  Modal,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const ShuttleConsole = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { type = 'shuttle', blind_drop } = props;
  const { authorization_required } = data;
  return (
    <Window width={350} height={230}>
      {!!authorization_required && (
        <Modal
          ml={1}
          mt={1}
          width={26}
          height={12}
          fontSize="28px"
          fontFamily="monospace"
          textAlign="center"
        >
          <Flex>
            <Flex.Item mt={2}>
              <Icon name="minus-circle" />
            </Flex.Item>
            <Flex.Item mt={2} ml={2} color="bad">
              {type === 'shuttle'
                ? t('ui.shuttle_console.shuttle_locked')
                : t('ui.shuttle_console.base_locked')}
            </Flex.Item>
          </Flex>
          <Box fontSize="18px" mt={4}>
            <Button
              lineHeight="40px"
              icon="arrow-circle-right"
              content={t('ui.shuttle_console.request_authorization')}
              color="bad"
              onClick={() => act('request')}
            />
          </Box>
        </Modal>
      )}
      <Window.Content>
        <ShuttleConsoleContent type={type} blind_drop={blind_drop} />
      </Window.Content>
    </Window>
  );
};

const getLocationNameById = (locations, id) => {
  return locations?.find((location) => location.id === id)?.name;
};

const getLocationIdByName = (locations, name) => {
  return locations?.find((location) => location.name === name)?.id;
};

const STATUS_COLOR_KEYS = {
  'In Transit': 'good',
  Idle: 'average',
  Igniting: 'average',
  Recharging: 'average',
  Missing: 'bad',
  'Unauthorized Access': 'bad',
  Locked: 'bad',
};

export const ShuttleConsoleContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { type, blind_drop } = props;
  const {
    status,
    locked,
    authorization_required,
    destination,
    docked_location,
    timer_str,
    locations = [],
  } = data;
  return (
    <Section>
      <Box bold fontSize="26px" textAlign="center" fontFamily="monospace">
        {timer_str || t('ui.shuttle_console.default_timer')}
      </Box>
      <Box textAlign="center" fontSize="14px" mb={1}>
        <Box inline bold>
          {t('ui.common.status')}:
        </Box>
        <Box inline color={STATUS_COLOR_KEYS[status] || 'bad'} ml={1}>
          {status || t('ui.common.not_available')}
        </Box>
      </Box>
      <Section
        title={
          type === 'shuttle'
            ? t('ui.shuttle_console.shuttle_controls')
            : t('ui.shuttle_console.base_launch_controls')
        }
        level={2}
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.shuttle_console.location')}>
            {docked_location || t('ui.common.not_available')}
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.shuttle_console.destination')}
            buttons={
              type !== 'shuttle' &&
              locations.length === 0 &&
              !!blind_drop && (
                <Button
                  color="bad"
                  icon="exclamation-triangle"
                  disabled={authorization_required || !blind_drop}
                  content={t('ui.shuttle_console.blind_drop')}
                  onClick={() => act('random')}
                />
              )
            }
          >
            {(locations.length === 0 && (
              <Box mb={1.7} color="bad">
                {t('ui.common.not_available')}
              </Box>
            )) ||
              (locations.length === 1 && (
                <Box mb={1.7} color="average">
                  {getLocationNameById(locations, destination)}
                </Box>
              )) || (
                <Dropdown
                  mb={1.7}
                  over
                  width="240px"
                  options={locations.map((location) => location.name)}
                  disabled={locked || authorization_required}
                  selected={
                    getLocationNameById(locations, destination) ||
                    t('ui.shuttle_console.select_destination')
                  }
                  onSelected={(value) =>
                    act('set_destination', {
                      destination: getLocationIdByName(locations, value),
                    })
                  }
                />
              )}
          </LabeledList.Item>
        </LabeledList>
        <Button
          fluid
          content={t('ui.shuttle_console.depart')}
          disabled={
            !getLocationNameById(locations, destination) ||
            locked ||
            authorization_required
          }
          icon="arrow-up"
          textAlign="center"
          onClick={() =>
            act('move', {
              shuttle_id: destination,
            })
          }
        />
      </Section>
    </Section>
  );
};
