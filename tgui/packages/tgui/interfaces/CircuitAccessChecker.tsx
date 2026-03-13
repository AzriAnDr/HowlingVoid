import { Button, LabeledList } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessConfig, type Region } from './common/AccessConfig';
import { usePreferencesLocalization } from './localization';

type Data = {
  oneAccess: BooleanLike;
  regions: Region[];
  accesses: string[];
};

export const CircuitAccessChecker = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { oneAccess, regions = [], accesses = [] } = data;

  return (
    <Window width={420} height={360}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label={t('ui.circuit_access_checker.access_required')}>
            <Button
              icon={oneAccess ? 'unlock' : 'lock'}
              content={oneAccess ? 'One' : 'All'}
              onClick={() => act('one_access')}
            />
          </LabeledList.Item>
        </LabeledList>
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
      </Window.Content>
    </Window>
  );
};
