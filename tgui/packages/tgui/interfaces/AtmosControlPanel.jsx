import { sortBy } from 'es-toolkit';
import { map } from 'es-toolkit/compat';
import { Box, Button, Flex, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const AtmosControlPanel = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const groups = sortBy(
    map(data.excited_groups, (group, i) => ({
      ...group,
      // Generate a unique id
      id: group.area + i,
    })),
    [(group) => group.id],
  );
  return (
    <Window title={t('ui.atmos_control_panel.title')} width={900} height={500}>
      <Section m={1}>
        <Flex justify="space-between" align="baseline">
          <Flex.Item>
            <Button
              onClick={() => act('toggle-freeze')}
              color={data.frozen === 1 ? 'good' : 'bad'}
            >
              {data.frozen === 1
                ? t('ui.atmos_control_panel.freeze_subsystem')
                : t('ui.atmos_control_panel.unfreeze_subsystem')}
            </Button>
          </Flex.Item>
          <Flex.Item>
            {t('ui.atmos_control_panel.fire_count')}: {data.fire_count}
          </Flex.Item>
          <Flex.Item>
            {t('ui.atmos_control_panel.active_turfs')}: {data.active_size}
          </Flex.Item>
          <Flex.Item>
            {t('ui.atmos_control_panel.excited_groups')}: {data.excited_size}
          </Flex.Item>
          <Flex.Item>
            {t('ui.atmos_control_panel.hotspots')}: {data.hotspots_size}
          </Flex.Item>
          <Flex.Item>
            {t('ui.atmos_control_panel.superconductors')}: {data.conducting_size}
          </Flex.Item>
          <Flex.Item>
            <Button.Checkbox
              checked={data.showing_user}
              onClick={() => act('toggle_user_display')}
            >
              {t('ui.atmos_control_panel.personal_view')}
            </Button.Checkbox>
          </Flex.Item>
          <Flex.Item>
            <Button.Checkbox
              checked={data.show_all}
              onClick={() => act('toggle_show_all')}
            >
              {t('ui.atmos_control_panel.display_all')}
            </Button.Checkbox>
          </Flex.Item>
        </Flex>
      </Section>
      <Box fillPositionedParent top="45px">
        <Window.Content scrollable>
          <Section>
            <Table>
              <Table.Row header>
                <Table.Cell>{t('ui.atmos_control_panel.area_name')}</Table.Cell>
                <Table.Cell collapsing>{t('ui.atmos_control_panel.breakdown')}</Table.Cell>
                <Table.Cell collapsing>{t('ui.atmos_control_panel.dismantle')}</Table.Cell>
                <Table.Cell collapsing>{t('ui.atmos_control_panel.turfs')}</Table.Cell>
                <Table.Cell collapsing>
                  {data.display_max === 1 &&
                    t('ui.atmos_control_panel.max_share')}
                </Table.Cell>
                <Table.Cell collapsing>{t('ui.atmos_control_panel.display')}</Table.Cell>
              </Table.Row>
              {groups.map((group) => (
                <tr key={group.id}>
                  <td>
                    <Button
                      content={group.area}
                      onClick={() =>
                        act('move-to-target', {
                          spot: group.jump_to,
                        })
                      }
                    />
                  </td>
                  <td>{group.breakdown}</td>
                  <td>{group.dismantle}</td>
                  <td>{group.size}</td>
                  <td>{data.display_max === 1 && group.max_share}</td>
                  <td>
                    <Button.Checkbox
                      checked={group.should_show}
                      onClick={() =>
                        act('toggle_show_group', {
                          group: group.group,
                        })
                      }
                    />
                  </td>
                </tr>
              ))}
            </Table>
          </Section>
        </Window.Content>
      </Box>
    </Window>
  );
};
