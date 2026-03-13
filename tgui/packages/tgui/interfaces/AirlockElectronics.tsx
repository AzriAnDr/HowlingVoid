import {
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessConfig, type Region } from './common/AccessConfig';
import { usePreferencesLocalization } from './localization';

type Data = {
  accesses: string[];
  oneAccess: BooleanLike;
  passedCycleId: string;
  passedName: string;
  regions: Region[];
  shell: BooleanLike;
  unres_direction: number;
};

export function AirlockElectronics(props) {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  return (
    <Window title={t('ui.airlock_electronics.title')} width={420} height={485}>
      <Window.Content>
        <AirLockMainSection />
      </Window.Content>
    </Window>
  );
}

export function AirLockMainSection(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    accesses = [],
    oneAccess,
    passedName,
    passedCycleId,
    regions = [],
    unres_direction,
    shell,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill>
          <LabeledList>
            <LabeledList.Item label={t('ui.airlock_electronics.integrated_circuit_shell')}>
              <Button.Checkbox
                checked={shell}
                onClick={() => {
                  act('set_shell', { on: !shell });
                }}
                tooltip={t('ui.airlock_electronics.shell_tooltip')}
              >
                {t('ui.airlock_electronics.shell')}
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_electronics.access_required')}>
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                onClick={() => act('one_access')}
              >
                {oneAccess
                  ? t('ui.airlock_electronics.one')
                  : t('ui.airlock_electronics.all')}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_electronics.unrestricted_access')}>
              <Button
                icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 1}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '1',
                  })
                }
              >
                {t('ui.common.direction_north')}
              </Button>
              <Button
                icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 2}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '2',
                  })
                }
              >
                {t('ui.common.direction_south')}
              </Button>
              <Button
                icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 4}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '4',
                  })
                }
              >
                {t('ui.common.direction_east')}
              </Button>
              <Button
                icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 8}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '8',
                  })
                }
              >
                {t('ui.common.direction_west')}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_electronics.airlock_name')}>
              <Input
                fluid
                maxLength={30}
                value={passedName}
                onBlur={(value) =>
                  act('passedName', {
                    passedName: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.airlock_electronics.cycling_id')}>
              <Input
                fluid
                maxLength={30}
                value={passedCycleId}
                onBlur={(value) =>
                  act('passedCycleId', {
                    passedCycleId: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <AccessConfig
          accesses={regions}
          selectedList={accesses}
          accessMod={(ref) =>
            act('set', {
              access: ref,
            })
          }
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) =>
            act('grant_region', {
              region: ref,
            })
          }
          denyDep={(ref) =>
            act('deny_region', {
              region: ref,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}
