import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Knob,
  NumberInput,
  Section,
  Stack,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

type Data = {
  faxes: string[];
  stamps: string[];
};

const paperNameOptions = [
  'Nanotrasen Official Report',
  'Syndicate Report',
] as const;

const fromWhoOptions = ['Nanotrasen', 'Syndicate'] as const;

export function AdminFax(props) {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { faxes = [], stamps = [] } = data;

  const [fax, setFax] = useState('');
  const [saved, setSaved] = useState(false);
  const [paperName, setPaperName] = useState('');
  const [fromWho, setFromWho] = useState('');
  const [rawText, setRawText] = useState('');
  const [stamp, setStamp] = useState('');
  const [stampCoordX, setStampCoordX] = useState(0);
  const [stampCoordY, setStampCoordY] = useState(0);
  const [stampAngle, setStampAngle] = useState(0);

  if (stamp && stamps[0] !== 'None') {
    stamps.unshift('None');
  }

  return (
    <Window
      title={t('ui.admin_fax.title')}
      width={400}
      height={675}
      theme="admin"
    >
      <Window.Content scrollable>
        <Section
          title={t('ui.admin_fax.fax_menu')}
          buttons={
            <Button
              icon="arrow-up"
              disabled={!fax}
              onClick={() =>
                act('follow', {
                  faxName: fax,
                })
              }
            >
              {t('ui.common.follow')}
            </Button>
          }
        >
          <Dropdown
            placeholder={t('ui.admin_fax.choose_fax_machine_placeholder')}
            fluid
            selected={fax}
            options={faxes}
            onSelected={setFax}
          />
        </Section>
        <Section
          title={t('ui.common.paper')}
          buttons={
            <Button
              icon="eye"
              disabled={!saved}
              onClick={() =>
                act('preview', {
                  faxName: fax,
                })
              }
            >
              {t('ui.common.preview')}
            </Button>
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              <Input
                placeholder={t('ui.admin_fax.paper_name_placeholder')}
                value={paperName}
                fluid
                onChange={setPaperName}
              />
            </Stack.Item>
            <Stack.Item>
              <SourceButtons
                stateSetter={setPaperName}
                options={paperNameOptions}
                tooltip={t('ui.admin_fax.paper_header_tooltip')}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Input
                placeholder={t('ui.admin_fax.from_who_placeholder')}
                value={fromWho}
                fluid
                onChange={setFromWho}
              />
            </Stack.Item>
            <Stack.Item>
              <SourceButtons
                stateSetter={setFromWho}
                options={fromWhoOptions}
                tooltip={t('ui.admin_fax.fax_log_tooltip')}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <TextArea
                placeholder={t('ui.admin_fax.message_placeholder')}
                height="200px"
                fluid
                value={rawText}
                onChange={setRawText}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Dropdown
                fluid
                options={stamps}
                selected="Choose stamp(optional)"
                onSelected={(value) => {
                  if (value === 'None') {
                    setStamp('');
                    stamps.shift();
                  } else {
                    setStamp(value);
                  }
                }}
              />
            </Stack.Item>
            <Stack.Item textAlign="center">
              {stamp && (
                <>
                  <h4>
                    {t('ui.admin_fax.x_coordinate')}:{' '}
                    <NumberInput
                      step={1}
                      width="45px"
                      minValue={0}
                      maxValue={300}
                      value={stampCoordX}
                      onChange={(v) => setStampCoordX(v)}
                    />
                  </h4>

                  <h4>
                    {t('ui.admin_fax.y_coordinate')}:{' '}
                    <NumberInput
                      step={1}
                      width="45px"
                      minValue={0}
                      maxValue={400}
                      value={stampCoordY}
                      onChange={(v) => setStampCoordY(v)}
                    />
                  </h4>

                <Box textAlign="center">
                    <h4>{t('ui.admin_fax.rotation_angle')}</h4>
                    <Knob
                      size={1.5}
                      value={stampAngle}
                      minValue={0}
                      maxValue={360}
                      animated={false}
                      onChange={(_event, value) => setStampAngle(value)}
                    />
                  </Box>
                </>
              )}
            </Stack.Item>
          </Stack>
        </Section>
        <Section title={t('ui.common.actions')}>
          <Button
            disabled={!saved || !fax}
            icon="paper-plane"
            onClick={() =>
              act('send', {
                faxName: fax,
              })
            }
          >
            {t('ui.common.send')}
          </Button>
          <Button
            icon="floppy-disk"
            color="green"
            onClick={() => {
              setSaved(true);
              act('save', {
                faxName: fax,
                paperName: paperName,
                rawText: rawText,
                stamp: stamp,
                stampX: stampCoordX,
                stampY: stampCoordY,
                stampAngle: stampAngle,
                fromWho: fromWho,
              });
            }}
          >
            {t('ui.common.save')}
          </Button>
          <Button
            disabled={!saved}
            icon="circle-plus"
            onClick={() =>
              act('createPaper', {
                faxName: fax,
              })
            }
          >
            {t('ui.admin_fax.create_paper')}
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}

type SourceButtonsProps = {
  stateSetter: (source: string) => void;
  options: readonly string[];
  tooltip: string;
};

function SourceButtons(props: SourceButtonsProps) {
  const { stateSetter, options, tooltip } = props;
  const { t } = usePreferencesLocalization();

  return (
    <Tooltip content={tooltip}>
      <Stack fill>
        <Stack.Item grow>
          <Button fluid icon="n" onClick={() => stateSetter(options[0])}>
            {t('ui.admin_fax.nanotrasen')}
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button fluid icon="s" onClick={() => stateSetter(options[1])}>
            {t('ui.admin_fax.syndicate')}
          </Button>
        </Stack.Item>
      </Stack>
    </Tooltip>
  );
}
