import { Box, Button, Section, Table } from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Material = {
  name: string;
  amount: number;
};

type Data = {
  materials: Material[];
};

export const OreBox = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { materials } = data;

  return (
    <Window width={335} height={415}>
      <Window.Content scrollable>
        <Section
          title={t('ui.ore_box.ores_and_boulders')}
          buttons={
            <Button
              disabled={materials.length === 0}
              onClick={() => act('removeall')}
            >
              Empty
            </Button>
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>{t('ui.common.item')}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                Amount
              </Table.Cell>
            </Table.Row>
            {materials.map((material, id) => (
              <Table.Row key={id}>
                <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  <Box color="label" inline>
                    {material.amount}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        <Section>
          <Box>
            Ores can be loaded here via a mining satchel or by hand. Boulders
            can also be stored here
            <br />
            Gibtonite is not accepted.
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
