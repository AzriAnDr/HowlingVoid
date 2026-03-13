import { useReducer, useState } from 'react';
import { Button, Dropdown, Input, Section, Stack } from 'tgui-core/components';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import { SORTING_TYPES } from './contants';
import { FilterAction, type FilterState, filterReducer } from './filters';
import { OverviewSection } from './OverviewSection';
import { SubsystemDialog } from './SubsystemDialog';
import { SubsystemViews } from './SubsystemViews';
import { SortType, type SubsystemData } from './types';

export function ControllerOverview(props) {
  const { t } = usePreferencesLocalization();
  return (
    <Window title={t('ui.controller_overview.title')} height={600} width={500}>
      <Window.Content>
        <ControllerContent />
      </Window.Content>
    </Window>
  );
}

export function ControllerContent(props) {
  const { t } = usePreferencesLocalization();
  const [state, dispatch] = useReducer(filterReducer, {
    ascending: true,
    inactive: true,
    query: '',
    smallValues: false,
    sortType: SortType.Name,
  });

  const [selected, setSelected] = useState<SubsystemData>();

  const { label, key, inDeciseconds } =
    SORTING_TYPES?.[state.sortType] || SORTING_TYPES[0];

  function onSelectionHandler(value: string) {
    const updates: Partial<FilterState> = {
      sortType: SORTING_TYPES.findIndex(
        (type) => t(`ui.controller_overview.sort.${type.key}`) === value,
      ),
    };

    if (updates.sortType === undefined) return;

    const { inDeciseconds } = SORTING_TYPES[updates.sortType];

    updates.ascending = !inDeciseconds;
    updates.smallValues = inDeciseconds;

    dispatch({ type: FilterAction.Update, payload: updates });
  }

  return (
    <Stack fill vertical>
      {selected && (
        <SubsystemDialog
          onClose={() => setSelected(undefined)}
          subsystem={selected}
        />
      )}
      <Stack.Item height="15%">
        <OverviewSection />
      </Stack.Item>
      <Stack.Item height="12%">
        <Section fill>
          <Stack justify="space-between">
            <Stack.Item grow mb={4}>
              <Stack fill vertical>
                <Stack.Item height="50%">
                  <Input
                    onChange={(value) =>
                      dispatch({ type: FilterAction.Query, payload: value })
                    }
                    placeholder={t('ui.controller_overview.by_name')}
                    value={state.query}
                    width="85%"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    disabled={!inDeciseconds}
                    selected={state.smallValues}
                    tooltip={t('ui.controller_overview.hide_values_under_1')}
                    icon={state.smallValues ? 'eye-slash' : 'eye'}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.SmallValues,
                        payload: !state.smallValues,
                      })
                    }
                  >
                    {t('ui.controller_overview.small')}
                  </Button>
                  <Button
                    icon={state.inactive ? 'eye-slash' : 'eye'}
                    tooltip={t('ui.controller_overview.hide_offline_paused')}
                    selected={state.inactive}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Inactive,
                        payload: !state.inactive,
                      })
                    }
                  >
                    {t('ui.controller_overview.inactive')}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Dropdown
                    options={SORTING_TYPES.map((type) =>
                      t(`ui.controller_overview.sort.${type.key}`),
                    )}
                    selected={t(`ui.controller_overview.sort.${key}`)}
                    displayText={t(`ui.controller_overview.sort.${key}`)}
                    onSelected={onSelectionHandler}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={state.ascending}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Ascending,
                        payload: !state.ascending,
                      })
                    }
                  >
                    {t('ui.common.ascending')}
                  </Button>
                  <Button
                    selected={!state.ascending}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Ascending,
                        payload: !state.ascending,
                      })
                    }
                  >
                    {t('ui.common.descending')}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <SubsystemViews setSelected={setSelected} filterOpts={state} />
      </Stack.Item>
    </Stack>
  );
}
