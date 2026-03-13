import { useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  announce_contents: string;
  announcement_color: string;
  announcement_colors: string[];
  announcer_sounds: string[];
  command_name_presets: string[];
  command_name: string;
  command_report_content: string;
  custom_name: string;
  played_sound: string;
  print_report: string;
  subheader: string;
};

export function CommandReport() {
  const { t } = usePreferencesLocalization();
  return (
    <Window
      title={t('ui.command_report.create_command_report')}
      width={325}
      height={685}
      theme="admin"
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <CentComName />
            <AnnouncementColor />
            <AnnouncementSound />
          </Stack.Item>
          <Stack.Item>
            <SubHeader />
          </Stack.Item>
          <Stack.Item grow>
            <ReportText />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

/** Allows the user to set the "sender" of the message via dropdown */
function CentComName(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { command_name, command_name_presets = [], custom_name } = data;

  const [name, setName] = useState(command_name);

  function sendName(value) {
    setName(value);
    act('update_command_name', {
      updated_name: value,
    });
  }

  return (
    <Section title={t('ui.command_report.set_central_command_name')} textAlign="center">
      <Dropdown
        width="100%"
        selected={name}
        options={command_name_presets}
        onSelected={sendName}
      />
      {!!custom_name && (
        <Input fluid mt={1} value={name} onChange={setName} onBlur={sendName} />
      )}
    </Section>
  );
}

/** Allows the user to set the "sender" of the message via dropdown */
function SubHeader(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { subheader } = data;

  return (
    <Section title={t('ui.command_report.set_report_subheader')} textAlign="center">
      <Input
        fluid
        mt={1}
        value={subheader}
        placeholder={t('ui.command_report.keep_blank_no_subheader')}
        onBlur={(value) =>
          act('set_subheader', {
            new_subheader: value,
          })
        }
      />
    </Section>
  );
}

/** Features a section with dropdown for the announcement colour. */
function AnnouncementColor(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { announcement_colors = [], announcement_color } = data;

  return (
    <Section title={t('ui.command_report.set_announcement_color')} textAlign="center">
      <Dropdown
        width="100%"
        selected={announcement_color}
        options={announcement_colors}
        onSelected={(value) =>
          act('update_announcement_color', {
            updated_announcement_color: value,
          })
        }
      />
    </Section>
  );
}

/** Features a section with dropdown for sounds. */
function AnnouncementSound(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { announcer_sounds = [], played_sound } = data;

  return (
    <Section title={t('ui.command_report.set_announcement_sound')} textAlign="center">
      <Dropdown
        width="100%"
        selected={played_sound}
        options={announcer_sounds}
        onSelected={(value) =>
          act('set_report_sound', {
            picked_sound: value,
          })
        }
      />
    </Section>
  );
}

/** Creates the report textarea with a submit button. */
function ReportText(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { announce_contents, print_report, command_report_content } = data;
  const [commandReport, setCommandReport] = useState(command_report_content);

  return (
    <Section fill title={t('ui.command_report.set_report_text')} textAlign="center">
      <Stack fill vertical>
        <Stack.Item grow>
          <TextArea
            height="100%"
            fluid
            onBlur={setCommandReport}
            value={commandReport}
            placeholder={t('ui.command_report.enter_report_text_here_placeholder')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!announce_contents}
            onClick={() => act('toggle_announce')}
          >
            {t('ui.command_report.announce_contents')}
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!print_report || !announce_contents}
            disabled={!announce_contents}
            onClick={() => act('toggle_printing')}
            tooltip={
              !announce_contents &&
              t('ui.command_report.printing_required_tooltip')
            }
            tooltipPosition="top"
          >
            {t('ui.command_report.print_report')}
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            fluid
            icon="check"
            textAlign="center"
            onClick={() => act('submit_report', { report: commandReport })}
          >
            {t('ui.command_report.submit_report')}
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
