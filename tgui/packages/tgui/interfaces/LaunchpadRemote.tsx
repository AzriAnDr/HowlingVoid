import { NoticeBox } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LaunchpadControl } from './LaunchpadConsole';
import { usePreferencesLocalization } from './localization';

type Data = {
  has_pad: BooleanLike;
  pad_closed: BooleanLike;
};

export const LaunchpadRemote = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { has_pad, pad_closed } = data;

  return (
    <Window
      title={t('ui.launchpadremote.briefcase_launchpad_remote')}
      width={300}
      height={240}
      theme="syndicate"
    >
      <Window.Content>
        {(!has_pad && (
          <NoticeBox>{t('ui.launchpadremote.no_launchpad_connected')}</NoticeBox>
        )) ||
          (pad_closed && (
            <NoticeBox>{t('ui.launchpadremote.launchpad_closed')}</NoticeBox>
          )) || (
            <LaunchpadControl topLevel />
          )}
      </Window.Content>
    </Window>
  );
};
