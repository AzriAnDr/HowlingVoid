type SortType = {
  key: string;
  label: string;
  propName: string;
  inDeciseconds: boolean;
};

export const SORTING_TYPES: readonly SortType[] = [
  {
    key: 'alphabetical',
    label: 'Alphabetical',
    propName: 'name',
    inDeciseconds: false,
  },
  {
    key: 'cost',
    label: 'Cost',
    propName: 'cost_ms',
    inDeciseconds: true,
  },
  {
    key: 'init_order',
    label: 'Init Order',
    propName: 'init_order',
    inDeciseconds: false,
  },
  {
    key: 'last_fire',
    label: 'Last Fire',
    propName: 'last_fire',
    inDeciseconds: false,
  },
  {
    key: 'next_fire',
    label: 'Next Fire',
    propName: 'next_fire',
    inDeciseconds: false,
  },
  {
    key: 'tick_usage',
    label: 'Tick Usage',
    propName: 'tick_usage',
    inDeciseconds: true,
  },
  {
    key: 'avg_usage_per_tick',
    label: 'Avg Usage Per Tick',
    propName: 'usage_per_tick',
    inDeciseconds: true,
  },
  {
    key: 'subsystem_overtime',
    label: 'Subsystem Overtime',
    propName: 'overtime',
    inDeciseconds: true,
  },
];
