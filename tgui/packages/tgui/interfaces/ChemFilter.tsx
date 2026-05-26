import { Fragment } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import type { CssColor } from '../constants';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  left: string[];
  right: string[];
};

type Props = {
  title: string;
  filterId?: string;
  list: string[];
  buttonColor: CssColor;
};

export const ChemFilterPane = (props: Props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { title, filterId, list, buttonColor } = props;
  const targetFilter = filterId || title.toLowerCase();

  return (
    <Section
      title={title}
      minHeight="240px"
      buttons={
        <Button
          content={t('ui.chem_filter.add_reagent')}
          icon="plus"
          color={buttonColor}
          onClick={() =>
            act('add', {
              which: targetFilter,
            })
          }
        />
      }
    >
      {list.map((filter) => (
        <Fragment key={filter}>
          <Button
            fluid
            icon="minus"
            onClick={() =>
              act('remove', {
                which: targetFilter,
                reagent: filter,
              })
            }
          >
            {filter}
          </Button>
        </Fragment>
      ))}
    </Section>
  );
};

export const ChemFilter = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { left = [], right = [] } = data;

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane
              title={t('ui.common.left')}
              filterId="left"
              list={left}
              buttonColor="yellow"
            />
          </Stack.Item>
          <Stack.Item grow>
            <ChemFilterPane
              title={t('ui.common.right')}
              filterId="right"
              list={right}
              buttonColor="red"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
