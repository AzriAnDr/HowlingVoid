// THIS IS A NOVA SECTOR UI FILE
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  Section,
  Stack,
} from 'tgui-core/components';

import { CharacterPreview } from '../../common/CharacterPreview';
import type { PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { usePreferencesLocalization } from './localization';

const getQuirkBalanceLikeQuirksPage = (data, serverData) => {
  let fallbackBalance = -data.quirks_balance;

  if (
    !serverData ||
    !serverData.quirks ||
    !data.selected_quirks ||
    typeof data.default_quirk_balance !== 'number'
  ) {
    return fallbackBalance;
  }

  const quirkInfo = serverData.quirks.quirk_info || {};
  let balance = -data.default_quirk_balance;

  for (const quirkKey of data.selected_quirks) {
    const selectedQuirk = quirkInfo[quirkKey];
    if (!selectedQuirk) {
      continue;
    }
    balance += selectedQuirk.value || 0;
  }

  return balance;
};

const getAugmentsBudgetBalance = (data, serverData) => {
  let balance = getQuirkBalanceLikeQuirksPage(data, serverData);

  // Add currently selected augment costs for purchase validation logic.
  for (const limb of data.limbs_data || []) {
    const chosen = limb?.chosen_aug;
    if (!chosen || chosen === 'None') {
      continue;
    }
    balance += limb?.costs?.[chosen] || 0;
  }
  for (const organ of data.organs_data || []) {
    const chosen = organ?.chosen_organ;
    if (!chosen || chosen === 'Default') {
      continue;
    }
    balance += organ?.costs?.[chosen] || 0;
  }

  return balance;
};

export const RotateCharacterButtons = (props) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization();
  return (
    <Box mt={1}>
      <Button
        className="PreferencesMenu__Augments__ActionButton"
        onClick={() => act('rotate', { backwards: false })}
        fontSize="22px"
        icon="redo"
        tooltip={t('limbs_rotate_clockwise')}
        tooltipPosition="bottom"
      />
      <Button
        className="PreferencesMenu__Augments__ActionButton"
        onClick={() => act('rotate', { backwards: true })}
        fontSize="22px"
        icon="undo"
        tooltip={t('limbs_rotate_counter_clockwise')}
        tooltipPosition="bottom"
      />
    </Box>
  );
};

export const Markings = (props) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabel } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>{t('limbs_markings_label')}</Stack.Item>
      {props.limb.markings.markings_list.map((marking, index) => (
        <Stack.Item key={marking.marking_id}>
          <Stack fill>
            <Stack.Item grow>
              <Dropdown
                className="PreferencesMenu__Augments__Dropdown"
                width="100%"
                options={props.limb.markings.marking_choices.map((choice) => ({
                  value: choice,
                  displayText: localizeDataLabel(choice),
                }))}
                selected={marking.name}
                onSelected={(shit) =>
                  act('change_marking', {
                    limb_slot: props.limb.slot,
                    marking_id: marking.marking_id,
                    marking_name: shit,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                className="PreferencesMenu__Augments__ActionButton"
                onClick={() =>
                  act('color_marking', {
                    limb_slot: props.limb.slot,
                    marking_id: marking.marking_id,
                  })
                }
              >
                <ColorBox color={marking.color} />
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                className="PreferencesMenu__Augments__ActionButton"
                color={marking.emissive ? 'good' : 'bad'}
                tooltip={t('limbs_emissive_tooltip')}
                onClick={() =>
                  act('change_emissive', {
                    limb_slot: props.limb.slot,
                    marking_id: marking.marking_id,
                    emissive: marking.emissive,
                  })
                }
              >
                E
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                className="PreferencesMenu__Augments__ActionButton"
                color="bad"
                onClick={() =>
                  act('remove_marking', {
                    limb_slot: props.limb.slot,
                    marking_id: marking.marking_id,
                  })
                }
              >
                -
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
      <Stack.Item>
        <Button
          className="PreferencesMenu__Augments__ActionButton"
          color="good"
          onClick={() => act('add_marking', { limb_slot: props.limb.slot })}
        >
          +
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const LimbPage = (props) => {
  const { localizeDataLabel } = usePreferencesLocalization();
  return (
    <div>
      <Section
        className="PreferencesMenu__Augments__Card"
        fill
        title={localizeDataLabel(props.limb.name)}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Markings limb={props.limb} />
          </Stack.Item>
        </Stack>
      </Section>
    </div>
  );
};

export const AugmentationPage = (props) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { data } = useBackend<PreferencesMenuData>();
  const { t, localizeDataLabel } = usePreferencesLocalization(data);
  const serverData = useServerPrefs();
  const balance = getAugmentsBudgetBalance(data, serverData);
  if (props.limb.can_augment) {
    return (
      <div style={{ marginBottom: '1.5em' }}>
        <Section
          className="PreferencesMenu__Augments__Card"
          fill
          title={localizeDataLabel(props.limb.name)}
        >
          <Stack fill vertical>
            <Stack.Item>
              <Stack fill>
                <Stack.Item>{t('limbs_augmentation_label')}</Stack.Item>
                <Stack.Item grow>
                  <Dropdown
                    className="PreferencesMenu__Augments__Dropdown"
                    width="100%"
                    options={(Object.values(props.limb.aug_choices) as string[]).map(
                      (choice) => ({
                        value: choice,
                        displayText: localizeDataLabel(choice),
                      }),
                    )}
                    selected={props.limb.chosen_aug}
                    onSelected={(value) => {
                      // Since the costs are positive,
                      // it's added and not substracted
                      if (
                        data.quirk_points_enabled &&
                        balance + props.limb.costs[value] > 0
                      ) {
                        return;
                      }
                      act('set_limb_aug', {
                        limb_slot: props.limb.slot,
                        augment_name: value,
                      });
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack fill vertical>
                <Stack.Item>{t('limbs_style_label')}</Stack.Item>
                <Stack.Item grow>
                  <Dropdown
                    className="PreferencesMenu__Augments__Dropdown"
                    width="100%"
                    options={props.data.robotic_styles.map((style) => ({
                      value: style,
                      displayText: localizeDataLabel(style),
                    }))}
                    selected={props.limb.chosen_style}
                    onSelected={(value) =>
                      act('set_limb_aug_style', {
                        limb_slot: props.limb.slot,
                        style_name: value,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </div>
    );
  }
  return null;
};

export const OrganPage = (props) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { data } = useBackend<PreferencesMenuData>();
  const { localizeDataLabel } = usePreferencesLocalization(data);
  const serverData = useServerPrefs();
  const balance = getAugmentsBudgetBalance(data, serverData);
  return (
    <Stack.Item>
      <Stack fill>
        <Stack.Item>{`${localizeDataLabel(props.organ.name)}: `}</Stack.Item>
        <Stack.Item grow>
          <Dropdown
            className="PreferencesMenu__Augments__Dropdown"
            width="100%"
            options={(Object.values(props.organ.organ_choices) as string[]).map(
              (choice) => ({
                value: choice,
                displayText: localizeDataLabel(choice),
              }),
            )}
            selected={props.organ.chosen_organ}
            onSelected={(value) => {
              // Since the costs are positive, it's added and not substracted
              if (
                data.quirk_points_enabled &&
                balance + props.organ.costs[value] > 0
              ) {
                return;
              }
              act('set_organ_aug', {
                organ_slot: props.organ.slot,
                augment_name: value,
              });
            }}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const LimbsPage = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { act } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const serverData = useServerPrefs();
  const markings = data.marking_presets ? data.marking_presets : [];
  const displayBalance = getAugmentsBudgetBalance(data, serverData);
  return (
    <Stack minHeight="100%" className="PreferencesMenu__Augments">
      <Stack.Item minWidth="33%" minHeight="100%">
        <Section
          className="PreferencesMenu__Augments__Panel"
          fill
          scrollable
          title={t('limbs_markings_title')}
          height="197%"
        >
          <div>
            <Dropdown
              className="PreferencesMenu__Augments__Dropdown"
              width="100%"
              options={Object.values(markings)}
              selected={Object.values(markings)[1]}
              placeholder={t('limbs_pick_preset')}
              onSelected={(value) => act('set_preset', { preset: value })}
            />
          </div>
          <div>
            {data.limbs_data.map((val) => (
              <LimbPage key={val.slot} limb={val} data={data} />
            ))}
          </div>
        </Section>
      </Stack.Item>
      <Stack.Item minWidth="33%">
        <Section
          className="PreferencesMenu__Augments__Panel"
          title={t('limbs_character_preview')}
          fill
          align="center"
          height="197%"
        >
          <CharacterPreview
            id={data.character_preview_view}
            height="25%"
            width="100%"
          />
          <RotateCharacterButtons />
          {data.quirk_points_enabled ? (
            <Section
              className="PreferencesMenu__Augments__PointsSection"
              fill
              align="center"
              title={t('limbs_quirk_points_balance')}
              style={{
                marginTop: '3em',
              }}
            >
              <Stack justify="center">
                <Box
                  className="PreferencesMenu__Augments__PointsValue"
                  bold
                  fontSize="1.2em"
                  py={0.5}
                  style={{
                    width: '20%',
                    alignItems: 'center',
                  }}
                >
                  {displayBalance}
                </Box>
              </Stack>
            </Section>
          ) : (
            ''
          )}
        </Section>
      </Stack.Item>
      <Stack.Item minWidth="33%">
        <Section
          className="PreferencesMenu__Augments__Panel"
          fill
          title={t('limbs_organs')}
          height="87%"
        >
          <Stack fill vertical>
            {data.organs_data.map((val) => (
              <OrganPage key={val.slot} organ={val} data={data} />
            ))}
          </Stack>
        </Section>
        <Section
          className="PreferencesMenu__Augments__Panel"
          fill
          scrollable
          title={t('limbs_augmentations')}
          height="107%"
        >
          {data.limbs_data.map((val) => (
            <AugmentationPage key={val.slot} limb={val} data={data} />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
