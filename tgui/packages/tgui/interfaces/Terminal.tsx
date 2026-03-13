import { Box, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  uppertext: string;
  messages: { key: string }[];
  tguitheme: string;
};

export const Terminal = (props) => {
  const { data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { messages = [], uppertext } = data;

  return (
    <Window
      theme={data.tguitheme}
      title={t('ui.terminal.title')}
      width={480}
      height={520}
    >
      <Window.Content scrollable>
        <NoticeBox textAlign="left">{uppertext}</NoticeBox>
        {messages.map((message) => {
          return (
            <Box
              key={message.key}
              dangerouslySetInnerHTML={{ __html: message }}
            />
          );
        })}
      </Window.Content>
    </Window>
  );
};
