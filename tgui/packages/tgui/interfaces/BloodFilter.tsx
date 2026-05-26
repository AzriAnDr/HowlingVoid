import { Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';
import { ChemFilterPane } from './ChemFilter';

type Data = {
  whitelist: string[];
};

export const BloodFilter = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { whitelist = [] } = data;

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane
              title={t('ui.blood_filter.whitelist')}
              filterId="whitelist"
              list={whitelist}
              buttonColor="green"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
