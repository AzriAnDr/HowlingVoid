import { Component, createRef, type RefObject } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Section,
  TextArea,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { getPreferencesLocalization } from '../localization';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { getPaperFields } from './helpers';
import { PreviewView } from './Preview';
import { PaperSheetStamper } from './Stamper';
import { InteractionType, type PaperContext, type PaperInput } from './types';

const FORMAT_SNIPPETS = [
  {
    id: 'bold',
    labelKey: 'ui.paper_sheet.quick_insert.bold',
    value: '**Text**',
  },
  {
    id: 'italic',
    labelKey: 'ui.paper_sheet.quick_insert.italic',
    value: '*Text*',
  },
  {
    id: 'underline',
    labelKey: 'ui.paper_sheet.quick_insert.underline',
    value: '<u>Text</u>',
  },
  {
    id: 'strike',
    labelKey: 'ui.paper_sheet.quick_insert.strike',
    value: '<s>Text</s>',
  },
  {
    id: 'h1',
    labelKey: 'ui.paper_sheet.quick_insert.h1',
    value: '# Heading',
  },
  {
    id: 'h2',
    labelKey: 'ui.paper_sheet.quick_insert.h2',
    value: '## Heading',
  },
  {
    id: 'h3',
    labelKey: 'ui.paper_sheet.quick_insert.h3',
    value: '### Heading',
  },
  {
    id: 'center',
    labelKey: 'ui.paper_sheet.quick_insert.center',
    value: '<center>Text</center>',
  },
  {
    id: 'line',
    labelKey: 'ui.paper_sheet.quick_insert.line',
    value: '---',
  },
  {
    id: 'list',
    labelKey: 'ui.paper_sheet.quick_insert.list',
    value: '- Item 1\n- Item 2',
  },
  {
    id: 'numbered',
    labelKey: 'ui.paper_sheet.quick_insert.numbered',
    value: '1. Item 1\n2. Item 2',
  },
];

const INSERT_SNIPPETS = [
  {
    id: 'date',
    labelKey: 'ui.paper_sheet.quick_insert.date',
    value: '%date',
  },
  {
    id: 'time',
    labelKey: 'ui.paper_sheet.quick_insert.time',
    value: '%time',
  },
  {
    id: 'sign_block',
    labelKey: 'ui.paper_sheet.quick_insert.sign_block',
    value: '[%sign]\n[%date]',
  },
  {
    id: 'sign_field',
    labelKey: 'ui.paper_sheet.quick_insert.sign_field',
    value: '[%sign]',
  },
  {
    id: 'date_field',
    labelKey: 'ui.paper_sheet.quick_insert.date_field',
    value: '[%date]',
  },
  {
    id: 'time_field',
    labelKey: 'ui.paper_sheet.quick_insert.time_field',
    value: '[%time]',
  },
  {
    id: 'field',
    labelKey: 'ui.paper_sheet.quick_insert.field',
    value: '[___________________]',
  },
];

const LETTERHEAD_TEMPLATES = {
  cargo: '<center><h1>CARGO</h1>Supply and Logistics</center>\n---',
  command: '<center><h1>COMMAND</h1>Command Staff</center>\n---',
  engineering:
    '<center><h1>ENGINEERING</h1>Power and Maintenance</center>\n---',
  medical: '<center><h1>MEDICAL</h1>Medical Department</center>\n---',
  science: '<center><h1>SCIENCE</h1>Research and Development</center>\n---',
  security: '<center><h1>SECURITY</h1>Brig and Patrol</center>\n---',
  service: '<center><h1>SERVICE</h1>Civilian Services</center>\n---',
} as const;

// Overarching component that holds the primary view for papercode.
export class PrimaryView extends Component {
  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  scrollableRef: RefObject<HTMLDivElement | null>;

  // The last recorded distance the scrollbar was from the bottom.
  // Used to implement "text scrolls up instead of down" behaviour.
  lastDistanceFromBottom: number;

  // Event handler for the onscroll event. Also gets passed to the <Section>
  // holding the main preview. Updates lastDistanceFromBottom.
  onScrollHandler: (this: GlobalEventHandlers, ev: Event) => any;
  textAreaRef: RefObject<HTMLTextAreaElement | null>;

  constructor(props) {
    super(props);
    this.scrollableRef = createRef();
    this.textAreaRef = createRef();
    this.lastDistanceFromBottom = 0;

    this.onScrollHandler = (ev) => {
      const scrollable = ev.currentTarget as HTMLDivElement;
      if (scrollable) {
        this.lastDistanceFromBottom =
          scrollable.scrollHeight - scrollable.scrollTop;
      }
    };
  }

  render() {
    const { act, data } = useBackend<PaperContext>();
    const { t } = getPreferencesLocalization(data);
    const {
      raw_text_input,
      raw_field_input,
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
      max_length,
      user_name,
    } = data;

    const useFont = held_item_details?.font || default_pen_font;
    const useColor = held_item_details?.color || default_pen_color;
    const useBold = held_item_details?.use_bold || false;

    const [inputFieldData, setInputFieldData] = useLocalState(
      'inputFieldData',
      {},
    );

    const [textAreaText, setTextAreaText] = useLocalState('textAreaText', '');

    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const savableData =
      textAreaText.length || Object.keys(inputFieldData).length;

    const dmCharacters =
      raw_text_input?.reduce((lhs: number, rhs: PaperInput) => {
        return lhs + rhs.raw_text.length;
      }, 0) || 0;

    const usedCharacters = dmCharacters + textAreaText.length;

    const tooManyCharacters = usedCharacters > max_length;

    const canEdit = interactMode === InteractionType.writing;

    const appendSnippet = (snippet: string) => {
      const textArea = this.textAreaRef.current;
      const selectionStart = textArea?.selectionStart ?? textAreaText.length;
      const selectionEnd = textArea?.selectionEnd ?? textAreaText.length;
      const nextText =
        textAreaText.slice(0, selectionStart) +
        snippet +
        textAreaText.slice(selectionEnd);

      setTextAreaText(nextText);

      window.requestAnimationFrame(() => {
        const updatedTextArea = this.textAreaRef.current;
        if (!updatedTextArea) {
          return;
        }

        const nextCaretPosition = selectionStart + snippet.length;
        updatedTextArea.focus();
        updatedTextArea.setSelectionRange(
          nextCaretPosition,
          nextCaretPosition,
        );
      });
    };

    const existingFieldCount =
      raw_text_input?.reduce((count: number, input: PaperInput) => {
        return count + getPaperFields(input.raw_text).length;
      }, 0) || 0;

    const textAreaFieldPlaceholders = getPaperFields(textAreaText);
    const autoFilledFieldData: Record<string, string> = {};

    textAreaFieldPlaceholders.forEach((field, index) => {
      if (field.startsWith('%')) {
        autoFilledFieldData[`${existingFieldCount + index}`] = field;
      }
    });

    const letterheadOptions: Array<{
      id: keyof typeof LETTERHEAD_TEMPLATES;
      label: string;
    }> = [
      {
        id: 'cargo',
        label: t('ui.paper_sheet.quick_insert.letterhead.cargo'),
      },
      {
        id: 'command',
        label: t('ui.paper_sheet.quick_insert.letterhead.command'),
      },
      {
        id: 'engineering',
        label: t('ui.paper_sheet.quick_insert.letterhead.engineering'),
      },
      {
        id: 'medical',
        label: t('ui.paper_sheet.quick_insert.letterhead.medical'),
      },
      {
        id: 'science',
        label: t('ui.paper_sheet.quick_insert.letterhead.science'),
      },
      {
        id: 'security',
        label: t('ui.paper_sheet.quick_insert.letterhead.security'),
      },
      {
        id: 'service',
        label: t('ui.paper_sheet.quick_insert.letterhead.service'),
      },
    ];

    return (
      <>
        <PaperSheetStamper scrollableRef={this.scrollableRef} />
        <Flex direction="column" fillPositionedParent>
          <Flex.Item grow={3} basis={1}>
            <PreviewView
              key={`${raw_field_input?.length || 0}_${
                raw_text_input?.length || 0
              }`}
              scrollableRef={this.scrollableRef}
              handleOnScroll={this.onScrollHandler}
              textArea={textAreaText}
              canEdit={canEdit}
            />
          </Flex.Item>
          {canEdit && (
            <Flex.Item shrink={1} height={`${TEXTAREA_INPUT_HEIGHT}px`}>
              <Section
                title={t('ui.paper_sheet.insert_text')}
                fitted
                fill
                buttons={
                  <>
                    <Box
                      inline
                      pr={'5px'}
                      color={tooManyCharacters ? 'bad' : 'default'}
                    >
                      {`${usedCharacters} / ${max_length}`}
                    </Box>
                    <Button.Confirm
                      disabled={!savableData || tooManyCharacters}
                      color="good"
                      onClick={() => {
                        const mergedFieldData = {
                          ...autoFilledFieldData,
                          ...inputFieldData,
                        };

                        if (textAreaText.length) {
                          act('add_text', { text: textAreaText });
                          setTextAreaText('');
                        }
                        if (Object.keys(mergedFieldData).length) {
                          act('fill_input_field', {
                            field_data: mergedFieldData,
                          });
                          setInputFieldData({});
                        }
                      }}
                    >
                      Save
                    </Button.Confirm>
                  </>
                }
              >
                <Flex direction="column" height="100%">
                  <Flex.Item shrink={0} mb={0.5}>
                    <Box className="Paper__QuickInsertPanel" p={0.75}>
                      <Box className="Paper__QuickInsertTitle" mb={0.5}>
                        {t('ui.paper_sheet.quick_insert')}
                      </Box>
                      <Box className="Paper__QuickInsertRow" mb={0.5}>
                        <Box className="Paper__QuickInsertLabel">
                          {t('ui.paper_sheet.quick_insert.format')}
                        </Box>
                        <Flex style={{ flexWrap: 'wrap', gap: '0.35rem' }}>
                          {FORMAT_SNIPPETS.map((snippet) => (
                            <Flex.Item key={snippet.id}>
                              <Button
                                className="Paper__QuickInsertButton"
                                compact
                                onClick={() => appendSnippet(snippet.value)}
                              >
                                {t(snippet.labelKey)}
                              </Button>
                            </Flex.Item>
                          ))}
                        </Flex>
                      </Box>
                      <Box className="Paper__QuickInsertDivider" my={0.5} />
                      <Box className="Paper__QuickInsertRow">
                        <Box className="Paper__QuickInsertLabel">
                          {t('ui.paper_sheet.quick_insert.insert')}
                        </Box>
                        <Flex style={{ flexWrap: 'wrap', gap: '0.35rem' }}>
                          {INSERT_SNIPPETS.map((snippet) => (
                            <Flex.Item key={snippet.id}>
                              <Button
                                className="Paper__QuickInsertButton"
                                compact
                                onClick={() => appendSnippet(snippet.value)}
                              >
                                {t(snippet.labelKey)}
                              </Button>
                            </Flex.Item>
                          ))}
                          <Flex.Item>
                            <Button
                              className="Paper__QuickInsertButton"
                              compact
                              onClick={() => appendSnippet(user_name)}
                            >
                              {t('ui.paper_sheet.quick_insert.sign_as_me')}
                            </Button>
                          </Flex.Item>
                          <Flex.Item grow={1}>
                            <Dropdown
                              className="Paper__QuickInsertDropdown"
                              selected={null}
                              placeholder={t(
                                'ui.paper_sheet.quick_insert.letterhead',
                              )}
                              options={letterheadOptions.map((option) => ({
                                displayText: option.label,
                                value: option.id,
                              }))}
                              onSelected={(selected) => {
                                if (!(selected in LETTERHEAD_TEMPLATES)) {
                                  return;
                                }
                                appendSnippet(
                                  LETTERHEAD_TEMPLATES[
                                    selected as keyof typeof LETTERHEAD_TEMPLATES
                                  ],
                                );
                              }}
                            />
                          </Flex.Item>
                        </Flex>
                      </Box>
                    </Box>
                  </Flex.Item>
                  <Flex.Item grow={1} basis={0} minHeight="7rem">
                    <TextArea
                      ref={this.textAreaRef}
                      style={{ border: 'none' }}
                      value={textAreaText}
                      textColor={useColor}
                      fontFamily={useFont}
                      bold={useBold}
                      height="100%"
                      fluid
                      backgroundColor={paper_color}
                      onChange={(value) => {
                        setTextAreaText(value);

                        if (this.scrollableRef.current) {
                          const thisDistFromBottom =
                            this.scrollableRef.current.scrollHeight -
                            this.scrollableRef.current.scrollTop;
                          this.scrollableRef.current.scrollTop +=
                            thisDistFromBottom - this.lastDistanceFromBottom;
                        }
                      }}
                    />
                  </Flex.Item>
                </Flex>
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </>
    );
  }
}
