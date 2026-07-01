// THIS IS A NOVA SECTOR UI FILE
import { type ReactNode, useState } from 'react';
import { Button, ByondUi, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import type { ExaminePanelData } from './data';

function formatURLs(text: string) {
  if (!text) return;
  const parts: ReactNode[] = [];
  const regex = /https?:\/\/[^\s/$.?#].[^\s]*/gi;
  let lastIndex = 0;

  text.replace(regex, (url, index) => {
    parts.push(text.substring(lastIndex, index));
    parts.push(
      <a
        style={{
          color: '#0591e3',
          textDecoration: 'none',
          borderBottom: 'solid 1.25px',
        }}
        href={url}
      >
        {url}
      </a>,
    );
    lastIndex = index + url.length;
    return url;
  });

  parts.push(text.substring(lastIndex));

  return <div>{parts}</div>;
}

export function ExaminePanel(props) {
  const { act, data } = useBackend<ExaminePanelData>();
  const { t } = usePreferencesLocalization(data);
  const {
    character_name,
    assigned_map,
    flavor_text,
    flavor_text_nsfw,
    ooc_notes,
    ooc_notes_nsfw,
    custom_species,
    custom_species_lore,
    headshot,
    nova_star_status,
    ideal_antag_optin_status,
    current_antag_optin_status,
    opt_in_colors,
  } = data;
  const [oocNotesIndex, setOocNotesIndex] = useState('SFW');
  const [flavorTextIndex, setFlavorTextIndex] = useState('SFW');
  const previewControls = (
    <Stack justify="center">
      <Stack.Item>
        <Button
          icon="chevron-left"
          tooltip="Rotate left"
          tooltipPosition="bottom"
          onClick={() => act('rotate', { dir: 'left' })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="chevron-right"
          tooltip="Rotate right"
          tooltipPosition="bottom"
          onClick={() => act('rotate', { dir: 'right' })}
        />
      </Stack.Item>
    </Stack>
  );
  return (
    <Window title={character_name} width={900} height={740} theme="ntos">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="30%">
            {!headshot ? (
              <Stack fill vertical>
                <Stack.Item grow>
                  <Section fill title={t('ui.examine_panel.character_preview')}>
                    <ByondUi
                      height="100%"
                      width="100%"
                      className="ExaminePanel__map"
                      params={{
                        id: assigned_map,
                        type: 'map',
                      }}
                    />
                  </Section>
                </Stack.Item>
                <Stack.Item align="center" mt={1}>
                  {previewControls}
                </Stack.Item>
              </Stack>
            ) : (
              <Stack fill vertical>
                <Stack.Item>
                  <Section
                    height="310px"
                    title={t('ui.examine_panel.character_preview')}
                  >
                    <ByondUi
                      height="260px"
                      width="100%"
                      className="ExaminePanel__map"
                      params={{
                        id: assigned_map,
                        type: 'map',
                      }}
                    />
                  </Section>
                </Stack.Item>
                <Stack.Item align="center">{previewControls}</Stack.Item>
                <Stack.Item>
                  <Section height="310px" title={t('ui.examine_panel.headshot')}>
                    <img
                      src={resolveAsset(headshot)}
                      height="250px"
                      width="250px"
                    />
                  </Section>
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section
                  scrollable
                  fill
                  preserveWhitespace
                  title={t('ui.examine_panel.flavor_text')}
                  buttons={
                    <>
                      <Button
                        selected={flavorTextIndex === 'SFW'}
                        bold={flavorTextIndex === 'SFW'}
                        onClick={() => setFlavorTextIndex('SFW')}
                        textAlign="center"
                        width="150px"
                      >
                        SFW
                      </Button>
                      <Button
                        selected={flavorTextIndex === 'NSFW'}
                        disabled={!flavor_text_nsfw}
                        bold={flavorTextIndex === 'NSFW'}
                        onClick={() => setFlavorTextIndex('NSFW')}
                        textAlign="center"
                        width="150px"
                      >
                        NSFW
                      </Button>
                    </>
                  }
                >
                  {flavorTextIndex === 'SFW' && formatURLs(flavor_text)}
                  {flavorTextIndex === 'NSFW' && formatURLs(flavor_text_nsfw)}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      title={t('ui.examine_panel.ooc_notes')}
                      preserveWhitespace
                      buttons={
                        <>
                          <Button
                            selected={oocNotesIndex === 'SFW'}
                            bold={oocNotesIndex === 'SFW'}
                            onClick={() => setOocNotesIndex('SFW')}
                            textAlign="center"
                            minWidth="60px"
                          >
                            SFW
                          </Button>
                          <Button
                            selected={oocNotesIndex === 'NSFW'}
                            disabled={!ooc_notes_nsfw}
                            bold={oocNotesIndex === 'NSFW'}
                            onClick={() => setOocNotesIndex('NSFW')}
                            textAlign="center"
                            minWidth="60px"
                          >
                            NSFW
                          </Button>
                        </>
                      }
                    >
                      {!!nova_star_status && (
                        <Stack.Item mb="8px">
                          <span
                            style={{
                              color: 'gold',
                              fontWeight: 'bold',
                            }}
                          >
                            {t('ui.examine_panel.nova_star')}
                          </span>
                        </Stack.Item>
                      )}
                      {oocNotesIndex === 'SFW' && (
                        <Stack.Item>
                          {ideal_antag_optin_status && (
                            <Stack.Item>
                              {t('ui.examine_panel.current_antag_opt_in_status')}
                              :{' '}
                              <span
                                style={{
                                  fontWeight: 'bold',
                                  color:
                                    opt_in_colors[current_antag_optin_status],
                                }}
                              >
                                {current_antag_optin_status}
                              </span>
                              {'\n'}
                              {t(
                                'ui.examine_panel.antag_opt_in_status_preferences',
                              )}
                              :{' '}
                              <span
                                style={{
                                  color:
                                    opt_in_colors[ideal_antag_optin_status],
                                }}
                              >
                                {ideal_antag_optin_status}
                              </span>
                              {'\n\n'}
                            </Stack.Item>
                          )}
                          {formatURLs(ooc_notes)}
                        </Stack.Item>
                      )}
                      {oocNotesIndex === 'NSFW' && formatURLs(ooc_notes_nsfw)}
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      preserveWhitespace
                      title={
                        custom_species
                          ? `${t('ui.examine_panel.species')}: ${custom_species}`
                          : t('ui.examine_panel.no_custom_species')
                      }
                    >
                      {custom_species
                        ? formatURLs(custom_species_lore)
                        : t('ui.examine_panel.just_a_normal_space_dweller')}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
