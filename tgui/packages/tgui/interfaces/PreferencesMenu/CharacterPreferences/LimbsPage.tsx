// THIS IS A NOVA SECTOR UI FILE
import { useMemo, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Dropdown,
  Icon,
  Modal,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { CharacterPreview } from '../../common/CharacterPreview';
import type {
  AugmentItem,
  AugmentSlot,
  Marking,
  PreferencesMenuData,
  RoboticStyle,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';
import { usePreferencesLocalization } from './localization';
import { getCombinedQuirkAugmentBalance } from './quirkBalance';

/** AugmentSlot with selected augment */
type AugmentData = AugmentSlot & {
  selectedAug: AugmentItem;
};

/** All the ui_data needed to populate the columns */
type BodypartData = AugmentData & {
  chosen_markings: Marking[] | null;
  chosen_style: RoboticStyle | null;
  marking_choices: string[];
  selectedImplant: AugmentItem | null;
};

type ColumnData = {
  left: BodypartData[];
  right: BodypartData[];
  center: BodypartData[];
  internalImplants: {
    left: AugmentData[];
    right: AugmentData[];
  };
  filteredMarkingPresets: string[];
};

// On hover, used to display extra_info tooltips.
// Uses visibility/opacity toggle instead of conditional rendering to avoid
// DOM node insertion/removal
const HoverText = (props: { text: string; children: any }) => {
  const [visible, setVisible] = useState(false);
  return (
    <div
      className="LimbsPage__hover-text"
      onMouseEnter={() => setVisible(true)}
      onMouseLeave={() => setVisible(false)}
      onMouseDown={() => setVisible(false)}
    >
      {props.children}
      <div
        className={`LimbsPage__hover-text--tooltip-wrapper${visible && props.text ? ' visible' : ''}`}
      >
        <div className="LimbsPage__hover-text--tooltip">{props.text}</div>
      </div>
    </div>
  );
};

// The dropdown components with fancy HoverText

const LabeledDropdown = (
  props: {
    label: string;
    options: string[];
    selected: string | undefined;
    onSelected: (value: string) => void;
  } & Partial<{
    displayText: string;
    searchInput: boolean;
    maxItems: number;
    tooltip: string;
    disabled: boolean;
  }>,
) => {
  const dropdown = (
    <Dropdown
      className="PreferencesMenu__AugmentsDropdown"
      width="100%"
      options={props.options}
      selected={props.selected}
      displayText={props.displayText}
      disabled={props.disabled}
      onSelected={props.onSelected}
      //maxItems={props.maxItems}
      //searchInput={props.searchInput}
      //styledInput
    />
  );
  return (
    <Stack.Item>
      <Box className="PreferencesMenu__AugmentsDropdownLabel">
        {props.label}
      </Box>
      {props.tooltip ? (
        <HoverText text={props.tooltip}>{dropdown}</HoverText>
      ) : (
        dropdown
      )}
    </Stack.Item>
  );
};

// Popup to stop users from resetting all their markings accidentally via the preset dropdown

const PresetConfirmPopup = (props: {
  preset: string;
  onConfirm: () => void;
  onCancel: () => void;
}) => {
  const { t } = usePreferencesLocalization();
  return (
    <Modal>
      <Stack vertical textAlign="center" align="center">
        <Stack.Item>
          <Box fontSize="2em">
            {t('ui.character.limbs_replace_markings_title')}
          </Box>
        </Stack.Item>
        <Stack.Item maxWidth="300px">
          <Box>
            {t('ui.character.limbs_replace_markings_prefix')}{' '}
            <b>{props.preset}</b>{' '}
            {t('ui.character.limbs_replace_markings_suffix')}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Stack fill>
            <Stack.Item>
              <Button color="danger" onClick={props.onConfirm}>
                {t('ui.character.limbs_apply_preset')}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={props.onCancel}>
                {t('ui.character.cancel')}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const InternalImplantTitle = (props: { name: string; icon: string }) => (
  <span>
    <Icon name={props.icon} style={{ marginRight: '4px' }} />
    {props.name}
  </span>
);

// Various helpers

// Slot bitflags -- these must match DM defines in code\__DEFINES\inventory.dm
const SLOT_LEGS = (1 << 3) | (1 << 4); // LEG_LEFT | LEG_RIGHT

// ── Slot predicates ───────────────────────────────────────────────────────────
const isLegSlot = (slot_flag?: number) =>
  !!slot_flag && (slot_flag & SLOT_LEGS) !== 0;
const isLeft = (item: AugmentSlot) => item.slot?.startsWith('Left') ?? false;
const isRight = (item: AugmentSlot) => item.slot?.startsWith('Right') ?? false;
const isCenter = (item: AugmentSlot) => !isLeft(item) && !isRight(item);
const isBodypart = (item: AugmentSlot) => item.is_bodypart;
const isImplant = (item: AugmentSlot) => !item.is_bodypart;

// ── Display helpers ───────────────────────────────────────────────────────────
const augDisplayName = (aug: AugmentItem, showCost?: boolean) =>
  showCost && aug.cost
    ? `${aug.name} (${aug.cost > 0 ? '+' : ''}${aug.cost})`
    : aug.name;

/** True when the options list has more than just the default "None" entry */
const hasAnyOptions = (options: AugmentItem[] | null | undefined) =>
  (options?.length ?? 0) > 1;

// ── Filtering ─────────────────────────────────────────────────────────────────
const filterBySpecies = <T extends { recommended_species: string | null }>(
  items: T[],
  species: string,
  allowMismatched: boolean,
): T[] => {
  if (allowMismatched) return items;
  return items.filter(
    (item) =>
      !item.recommended_species ||
      item.recommended_species.split(',').includes(species),
  );
};

const isAugAllowed = (
  aug: AugmentItem,
  species: string,
  ckey: string,
  slot_flag?: number,
  digi_legs?: BooleanLike,
  taur_legs?: BooleanLike,
): boolean => {
  if (isLegSlot(slot_flag) && digi_legs && !aug.has_digi) return false;
  if (isLegSlot(slot_flag) && taur_legs) return false;
  if (aug.species_blacklist?.[species]) return false;
  if (aug.species_whitelist && !aug.species_whitelist[species]) return false;
  if (aug.ckey_whitelist && !aug.ckey_whitelist.includes(ckey)) return false;
  return true;
};

const showsInBodyPartsTab = (bodypart: BodypartData, taur_legs: BooleanLike) =>
  hasAnyOptions(bodypart.aug_options) ||
  (!!taur_legs && isLegSlot(bodypart.slot_flag));

/** Resolves internal implant slots into AugmentData with filtered options and selected aug */
const buildInternalImplantData = (
  items: AugmentSlot[],
  augments: Record<string, string>,
  species: string,
  ckey: string,
): AugmentData[] =>
  items.map((item) => {
    const chosen = augments?.[item.slot] ?? null;
    const aug_options = (item.aug_options ?? []).filter((aug) =>
      isAugAllowed(aug, species, ckey),
    );
    return {
      ...item,
      aug_options,
      selectedAug:
        aug_options.find((aug) => aug.path === chosen) ?? aug_options[0],
    };
  });

// Markings
const markingLayerLabels = [
  'Bodyparts',
  'Body adjacent',
  'Body',
  'Eyes',
  'Front mutations',
  'Damage',
  'Under clothes',
  'Uniform',
  'Anus',
  'Vagina',
  'Penis',
  'Nipples',
  'Bandage',
  'ID',
  'ID card',
  'High bodyparts',
  'Gloves',
  'Shoes',
  'Low facemask',
  'Ears',
  'Low neck',
  'Suit',
  'Glasses',
  'Belt',
  'Suit storage',
  'Neck',
  'Back',
  'Beneath hair',
  'Hair',
  'Facemask',
  'Head',
  'Outer hair',
  'Handcuffs',
  'Legcuffs',
  'Hands',
  'Body front',
  'Above glasses',
  'Above head',
  'Wounds',
  'Halo',
];

const markingLayerOptions = markingLayerLabels.map(
  (label, index) => `L${index + 1} ${label}`,
);

const getMarkingLayerOption = (layer?: number) => {
  const sanitizedLayer = Math.max(1, Math.min(layer || 1, 40));
  return markingLayerOptions[sanitizedLayer - 1];
};

const getMarkingLayerDisplay = (layer?: number) =>
  `L${Math.max(1, Math.min(layer || 1, 40))}`;

const Markings = (props: {
  body_zone: string;
  chosen_markings: Marking[] | null;
  marking_choices: string[];
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { body_zone, chosen_markings, marking_choices, act } = props;
  const { t } = usePreferencesLocalization();
  return (
    <Stack fill vertical>
      <Stack.Item>{t('ui.character.limbs_markings_label')}:</Stack.Item>
      {(chosen_markings ?? []).map((marking) => {
        return (
          <Stack.Item key={marking.marking_id}>
            <Stack fill>
              <Stack.Item grow style={{ minWidth: 0, overflow: 'hidden' }}>
                <Dropdown
                  className="PreferencesMenu__AugmentsDropdown"
                  width="100%"
                  options={marking_choices}
                  selected={marking.name}
                  displayText={marking.name}
                  //maxItems={7}
                  //searchInput
                  //styledInput
                  onSelected={(value) =>
                    act('change_marking', {
                      bodypart_slot: body_zone,
                      marking_id: marking.marking_id,
                      marking_name: value,
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Tooltip
                  content={t('ui.character.limbs_marking_layer_tooltip')}
                  position="bottom"
                >
                  <Dropdown
                    width="60px"
                    options={markingLayerOptions}
                    selected={getMarkingLayerOption(marking.layer)}
                    displayText={getMarkingLayerDisplay(marking.layer)}
                    onSelected={(value) => {
                      const layerMatch = String(value).match(/^L(\d+)/i);
                      const layerValue = layerMatch
                        ? parseInt(layerMatch[1], 10)
                        : 1;
                      act('change_marking_layer', {
                        bodypart_slot: body_zone,
                        marking_id: marking.marking_id,
                        layer: layerValue,
                      });
                    }}
                  />
                </Tooltip>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() =>
                    act('color_marking', {
                      bodypart_slot: body_zone,
                      marking_id: marking.marking_id,
                    })
                  }
                >
                  <ColorBox color={marking.color} />
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color={marking.emissive ? 'good' : 'bad'}
                  tooltip={t('ui.character.limbs_emissive_tooltip')}
                  onClick={() =>
                    act('change_emissive', {
                      bodypart_slot: body_zone,
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
                  color="bad"
                  onClick={() =>
                    act('remove_marking', {
                      bodypart_slot: body_zone,
                      marking_id: marking.marking_id,
                    })
                  }
                >
                  -
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
      <Stack.Item>
        <Button
          color="good"
          onClick={() => act('add_marking', { bodypart_slot: body_zone })}
        >
          +
        </Button>
      </Stack.Item>
    </Stack>
  );
};

// Limb augments section

const BodypartAugmentSection = (props: {
  limb: BodypartData;
  budgetBalance: number;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const server_data = useServerPrefs()?.limbs_and_markings;
  if (!server_data) return null;

  const { limb } = props;
  const showCost = !!data.quirk_points_enabled;
  const displayName = (aug: AugmentItem) => augDisplayName(aug, showCost);
  const balance = props.budgetBalance;
  const aug_options = limb.aug_options ?? [];
  const implant_options = limb.implant_options ?? [];

  const stylesForAug = (aug: AugmentItem | undefined) =>
    (server_data.robotic_styles ?? []).filter((style) => {
      if (!aug?.allows_styles && style.name !== 'None') return false;
      if (limb.slot_flag && !(style.supported_slots & limb.slot_flag))
        return false;
      if (isLegSlot(limb.slot_flag) && data.digi_legs && !style.has_digi)
        return false;
      return true;
    });

  const available_styles = useMemo(
    () => stylesForAug(limb.selectedAug),
    [
      server_data.robotic_styles,
      limb.selectedAug,
      limb.slot_flag,
      data.digi_legs,
    ],
  );
  const isTaurRestrictedLeg = !!data.taur_legs && isLegSlot(limb.slot_flag);

  return (
    <div style={{ marginBottom: '1.5em' }}>
      <Section fill title={limb.slot}>
        <Stack fill vertical>
          {isTaurRestrictedLeg ? (
            <LabeledDropdown
              label={`${t('ui.character.limbs_augmentation_label')}:`}
              options={[t('ui.character.limbs_not_available')]}
              selected={t('ui.character.limbs_not_available')}
              displayText={t('ui.character.limbs_not_available')}
              disabled
              //searchInput
              //maxItems={7}
              onSelected={() => {}}
            />
          ) : (
            <LabeledDropdown
              label={`${t('ui.character.limbs_augmentation_label')}:`}
              options={aug_options.map((aug) => displayName(aug))}
              selected={
                limb.selectedAug ? displayName(limb.selectedAug) : undefined
              }
              displayText={
                limb.selectedAug ? displayName(limb.selectedAug) : undefined
              }
              tooltip={limb.selectedAug?.extra_info}
              //searchInput
              //maxItems={7}
              onSelected={(name) => {
                const option = aug_options.find(
                  (aug) => displayName(aug) === name,
                );
                if (option?.path === limb.selectedAug?.path) return;
                if (
                  showCost &&
                  (option?.cost ?? 0) > 0 &&
                  balance -
                    (option?.cost ?? 0) +
                    (limb.selectedAug?.cost ?? 0) <
                    0
                )
                  return;
                act('set_bodypart_aug', {
                  slot: limb.slot,
                  augment_path: option?.path ?? null,
                });
              }}
            />
          )}
          {limb.selectedAug?.path &&
            limb.selectedAug?.allows_styles !== 0 &&
            (available_styles.length <= 1 ? (
              <LabeledDropdown
                label={`${t('ui.character.limbs_style_label')}:`}
                options={[t('ui.character.limbs_no_available_styles')]}
                selected={t('ui.character.limbs_no_available_styles')}
                displayText={t('ui.character.limbs_no_available_styles')}
                //searchInput
                //maxItems={7}
                disabled
                onSelected={() => {}}
              />
            ) : (
              <LabeledDropdown
                label={`${t('ui.character.limbs_style_label')}:`}
                options={available_styles.map((style) => style.name)}
                selected={limb.chosen_style?.name ?? 'None'}
                displayText={limb.chosen_style?.name ?? 'None'}
                searchInput
                onSelected={(value) => {
                  if (value === limb.chosen_style?.name) return;
                  act('set_bodypart_aug_style', {
                    slot: limb.slot,
                    style_name: value,
                  });
                }}
              />
            ))}
          {limb.selectedAug?.allows_implants !== 0 &&
            (limb.has_implant ? (
              <LabeledDropdown
                label={`${t('ui.character.limbs_implant_slot')}:`}
                options={implant_options.map((aug) => displayName(aug))}
                selected={
                  limb.selectedImplant
                    ? displayName(limb.selectedImplant)
                    : undefined
                }
                displayText={
                  limb.selectedImplant
                    ? displayName(limb.selectedImplant)
                    : undefined
                }
                //searchInput
                //maxItems={7}
                tooltip={limb.selectedImplant?.extra_info}
                onSelected={(name) => {
                  const option = implant_options.find(
                    (aug) => displayName(aug) === name,
                  );
                  if (
                    showCost &&
                    (option?.cost ?? 0) > 0 &&
                    balance -
                      (option?.cost ?? 0) +
                      (limb.selectedImplant?.cost ?? 0) <
                      0
                  )
                    return;
                  if (option?.path === limb.selectedImplant?.path) return;
                  act('set_internal_implant_aug', {
                    internal_implant_slot: `${limb.slot} implant`,
                    augment_path: option?.path ?? null,
                  });
                }}
              />
            ) : (
              <LabeledDropdown
                label={`${t('ui.character.limbs_implant_slot')}:`}
                options={[t('ui.character.limbs_none_available')]}
                selected={t('ui.character.limbs_none_available')}
                displayText={t('ui.character.limbs_none_available')}
                //searchInput
                //maxItems={7}
                disabled
                onSelected={() => {}}
              />
            ))}
        </Stack>
      </Section>
    </div>
  );
};

// Internal implant augments

const InternalImplantSection = (props: {
  internal_implant: AugmentData;
  budgetBalance: number;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const { internal_implant } = props;
  const showCost = !!data.quirk_points_enabled;
  const displayName = (aug: AugmentItem) => augDisplayName(aug, showCost);
  const balance = props.budgetBalance;
  const aug_options = internal_implant.aug_options ?? [];
  return (
    <div style={{ marginBottom: '1.5em' }}>
      <Section
        fill
        title={
          <InternalImplantTitle
            name={internal_implant.slot}
            icon={internal_implant.icon ?? ''}
          />
        }
      >
        <LabeledDropdown
          label={`${t('ui.character.limbs_implant_label')}:`}
          options={aug_options.map(displayName)}
          selected={
            internal_implant.selectedAug
              ? displayName(internal_implant.selectedAug)
              : undefined
          }
          displayText={
            internal_implant.selectedAug
              ? displayName(internal_implant.selectedAug)
              : undefined
          }
          //searchInput
          //maxItems={7}
          onSelected={(name) => {
            const option = aug_options.find((aug) => displayName(aug) === name);
            if (
              showCost &&
              (option?.cost ?? 0) > 0 &&
              balance -
                (option?.cost ?? 0) +
                (internal_implant.selectedAug?.cost ?? 0) <
                0
            )
              return;
            if (option?.path === internal_implant.selectedAug?.path) return;
            act('set_internal_implant_aug', {
              internal_implant_slot: internal_implant.slot,
              augment_path: option?.path ?? null,
            });
          }}
        />
      </Section>
    </div>
  );
};

const MarkingsColumn = (props: {
  limbs: BodypartData[];
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { t } = usePreferencesLocalization();
  return (
    <Section fill scrollable title={t('ui.character.limbs_markings_title')}>
      {props.limbs.map((bodypart) => (
        <div key={bodypart.slot} style={{ marginBottom: '1.5em' }}>
          <Section fill title={bodypart.slot}>
            <Markings
              body_zone={bodypart.body_zone ?? bodypart.slot}
              chosen_markings={bodypart.chosen_markings}
              marking_choices={bodypart.marking_choices}
              act={props.act}
            />
          </Section>
        </div>
      ))}
    </Section>
  );
};

const BodyPartsColumn = (props: {
  limbs: BodypartData[];
  budgetBalance: number;
}) => {
  const { t } = usePreferencesLocalization();
  return (
    <Section fill scrollable title={t('ui.character.limbs_augmentations')}>
      <QuirkBalance
        budgetBalance={props.budgetBalance}
        style={{ marginBottom: '1em' }}
      />
      {props.limbs.map((bodypart) => (
        <BodypartAugmentSection
          key={bodypart.slot}
          limb={bodypart}
          budgetBalance={props.budgetBalance}
        />
      ))}
    </Section>
  );
};

const InternalImplantsColumn = (props: {
  internal_implants: AugmentData[];
  budgetBalance: number;
}) => {
  const { t } = usePreferencesLocalization();
  return (
    <Section
      fill
      scrollable
      title={t('ui.character.limbs_internal_implants')}
    >
      {props.internal_implants.map((internal_implant) => (
        <InternalImplantSection
          key={internal_implant.slot}
          internal_implant={internal_implant}
          budgetBalance={props.budgetBalance}
        />
      ))}
    </Section>
  );
};

const QuirkBalance = (props: {
  budgetBalance: number;
  style?: Record<string, unknown>;
}) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  if (!data.quirk_points_enabled) return null;
  return (
    <Section
      align="center"
      title={t('ui.character.limbs_quirk_points_balance')}
      style={props.style}
    >
      <Stack justify="center">
        <Box
          bold
          className="PreferencesMenu__Augments__PointsValue"
          fontSize="1.2em"
          py={0.5}
          style={{ width: '20%', alignItems: 'center' }}
        >
          {props.budgetBalance}
        </Box>
      </Stack>
    </Section>
  );
};

// Things that live in the center columns of the various tabs, below the character preview

const CenterColumnExtras = (props: {
  tab: AugmentsTab | null;
  center: BodypartData[];
  budgetBalance: number;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { data } = useBackend<PreferencesMenuData>();

  if (props.tab === AugmentsTab.BodyParts) {
    return (
      <>
        {props.center
          .filter((bodypart) => showsInBodyPartsTab(bodypart, data.taur_legs))
          .map((bodypart) => (
            <BodypartAugmentSection
              key={bodypart.slot}
              limb={bodypart}
              budgetBalance={props.budgetBalance}
            />
          ))}
      </>
    );
  }

  if (props.tab === AugmentsTab.InternalImplants) {
    return (
      <QuirkBalance
        budgetBalance={props.budgetBalance}
        style={{ marginTop: '1em' }}
      />
    );
  }

  if (props.tab === AugmentsTab.Markings) {
    return (
      <>
        {props.center.map((bodypart) => (
          <div key={bodypart.slot} style={{ marginBottom: '1.5em' }}>
            <Section fill title={bodypart.slot}>
              <Markings
                body_zone={bodypart.body_zone ?? bodypart.slot}
                chosen_markings={bodypart.chosen_markings}
                marking_choices={bodypart.marking_choices}
                act={props.act}
              />
            </Section>
          </div>
        ))}
      </>
    );
  }

  return null;
};

// The character preview section at the top of the center column
const PreviewSection = () => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { t, localizeCharacterDataById } = usePreferencesLocalization(data);
  const previewDropdownOptions = data.preview_options.map((option) => ({
    value: option,
    displayText: data.preview_option_ids?.[option]
      ? localizeCharacterDataById(data.preview_option_ids[option], option)
      : localizeCharacterDataById(`preview_option_${option}`, option),
  }));
  const selectedPreviewText =
    previewDropdownOptions.find(
      (option) => option.value === data.preview_selection,
    )?.displayText ?? data.preview_selection;

  return (
  <Section fill title={t('ui.character.limbs_character_preview')} align="center">
    <Stack vertical fill>
      <Stack.Item grow align="center">
        <CharacterPreview
          height="100%"
          width="280px"
          id={data.character_preview_view}
        />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item align="center">
        <Dropdown
          className="PreferencesMenu__AugmentsDropdown PreferencesMenu__AugmentsDropdown--preview"
          width="160px"
          displayText={selectedPreviewText}
          selected={data.preview_selection}
          options={previewDropdownOptions}
          onSelected={(value) =>
            act('update_preview', {
              updated_preview: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  </Section>
  );
};

// Root page

export enum AugmentsTab {
  Markings = 0,
  BodyParts = 1,
  InternalImplants = 2,
}

export const LimbsPage = ({
  onTabChange,
}: {
  onTabChange?: (tab: AugmentsTab) => void;
}) => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { t } = usePreferencesLocalization(data);
  const serverPrefs = useServerPrefs();
  const server_data = serverPrefs?.limbs_and_markings;
  const budgetBalance = getCombinedQuirkAugmentBalance(data, serverPrefs);
  const [tab, setTab] = useState<AugmentsTab>(AugmentsTab.Markings);
  const [pendingPreset, setPendingPreset] = useState<string | null>(null);
  const hasWarnedRef = useRef(false);

  const handleTab = (next: AugmentsTab) => {
    setTab(next);
    onTabChange?.(next);
  };

  // Resets the preset warning when a marking is manually changed (e.g. not using the preset dropdown)
  const actAndResetPresetWarning = (
    action: string,
    params?: Record<string, unknown>,
  ) => {
    if (
      [
        'add_marking',
        'remove_marking',
        'change_marking',
        'color_marking',
        'change_emissive',
      ].includes(action)
    ) {
      hasWarnedRef.current = false;
    }
    act(action, params);
  };

  const pendingPresetStyle = {
    position: 'fixed' as const,
    top: '60%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: '400px',
    zIndex: 100,
  };

  // Build all column data, splitting augment_items into bodyparts and internal implants
  const columns: ColumnData | null = useMemo(() => {
    if (!server_data?.augment_items) return null;

    const species =
      data.species_id ?? data.character_preferences?.misc?.species ?? '';
    const ckey = data.ckey ?? '';
    const allowMismatched = !!data.allow_mismatched_parts;

    // Filter marking choices and presets by species/mismatched parts
    const markingChoices: Record<string, string[]> = {};
    for (const [slot, choices] of Object.entries(
      data.marking_choices ?? server_data.marking_choices ?? {},
    )) {
      markingChoices[slot] = filterBySpecies(
        choices,
        species,
        allowMismatched,
      ).map((choice) => choice.name);
    }
    const filteredMarkingPresets = (
      data.marking_presets ??
      server_data.marking_presets ??
      []
    ).map((preset) => preset.name);

    const styles = server_data.robotic_styles ?? [];

    const limbs: BodypartData[] = server_data.augment_items
      .filter(isBodypart)
      .map((item) => {
        const aug_options = (item.aug_options ?? []).filter((aug) =>
          isAugAllowed(
            aug,
            species,
            ckey,
            item.slot_flag,
            data.digi_legs,
            data.taur_legs,
          ),
        );
        const implant_options = (item.implant_options ?? []).filter((aug) =>
          isAugAllowed(
            aug,
            species,
            ckey,
            item.slot_flag,
            data.digi_legs,
            data.taur_legs,
          ),
        );
        const chosen_style_name = data.augment_styles?.[item.slot] ?? null;
        const augByPath = aug_options.length
          ? Object.fromEntries(aug_options.map((aug) => [aug.path, aug]))
          : {};
        const implantByPath = implant_options.length
          ? Object.fromEntries(implant_options.map((aug) => [aug.path, aug]))
          : {};
        return {
          ...item,
          aug_options,
          implant_options,
          chosen_markings: (data.markings?.[item.body_zone ?? item.slot] ??
            null) as Marking[] | null,
          chosen_style:
            styles.find((style) => style.name === chosen_style_name) ?? null,
          marking_choices: markingChoices[item.body_zone ?? item.slot] ?? [],
          selectedAug:
            augByPath[data.augments?.[item.slot] ?? ''] ?? aug_options[0],
          selectedImplant:
            implantByPath[data.augments?.[`${item.slot} implant`] ?? ''] ??
            implant_options[0] ??
            null,
        };
      });

    const internal_implants = server_data.augment_items.filter(isImplant);
    const mid = Math.ceil(internal_implants.length / 2);

    return {
      left: limbs.filter(isLeft),
      right: limbs.filter(isRight),
      center: limbs.filter(isCenter),
      internalImplants: {
        left: buildInternalImplantData(
          internal_implants.slice(0, mid),
          data.augments ?? {},
          species,
          ckey,
        ),
        right: buildInternalImplantData(
          internal_implants.slice(mid),
          data.augments ?? {},
          species,
          ckey,
        ),
      },
      filteredMarkingPresets,
    };
  }, [server_data, data]);

  const columnForTab = (
    limbs: BodypartData[],
    internal_implants: AugmentData[],
  ) => {
    if (tab === AugmentsTab.Markings)
      return <MarkingsColumn limbs={limbs} act={actAndResetPresetWarning} />;
    if (tab === AugmentsTab.BodyParts)
      return (
        <BodyPartsColumn
          limbs={limbs.filter((b) => showsInBodyPartsTab(b, data.taur_legs))}
          budgetBalance={budgetBalance}
        />
      );
    if (tab === AugmentsTab.InternalImplants)
      return (
        <InternalImplantsColumn
          internal_implants={internal_implants}
          budgetBalance={budgetBalance}
        />
      );
    return null;
  };

  return (
    <>
      {pendingPreset && (
        <div style={pendingPresetStyle}>
          <PresetConfirmPopup
            preset={pendingPreset}
            onConfirm={() => {
              hasWarnedRef.current = true;
              act('set_preset', { preset: pendingPreset });
              setPendingPreset(null);
            }}
            onCancel={() => setPendingPreset(null)}
          />
        </div>
      )}
      <Stack fill vertical className="PreferencesMenu__Augments">
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                selected={tab === AugmentsTab.Markings}
                onClick={() => handleTab(AugmentsTab.Markings)}
                fluid
                align="center"
                fontSize="14px"
              >
                {t('ui.character.limbs_markings_title')}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                selected={tab === AugmentsTab.BodyParts}
                onClick={() => handleTab(AugmentsTab.BodyParts)}
                fluid
                align="center"
                fontSize="14px"
              >
                {t('ui.character.limbs_body_parts')}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                selected={tab === AugmentsTab.InternalImplants}
                onClick={() => handleTab(AugmentsTab.InternalImplants)}
                fluid
                align="center"
                fontSize="14px"
              >
                {t('ui.character.limbs_internal_implants')}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            {/* Left column */}
            <Stack.Item minWidth="33%">
              {columnForTab(
                columns?.left ?? [],
                columns?.internalImplants.left ?? [],
              )}
            </Stack.Item>

            {/* Center column — fixed width so CharacterPreview anchors correctly */}
            <Stack.Item width="300px">
              <Stack vertical fill>
                {/* Preview: takes 45% of the column height */}
                <Stack.Item
                  height="45%"
                  style={{ overflow: 'hidden', position: 'relative' }}
                >
                  <PreviewSection />
                </Stack.Item>

                {/* Extras: anything rendering below the preview, takes remaining space */}
                {columns &&
                  (tab !== AugmentsTab.InternalImplants ||
                    !!data.quirk_points_enabled) && (
                    <Stack.Item height="55%" style={{ overflow: 'hidden' }}>
                      <Section fill scrollable>
                        {tab === AugmentsTab.Markings && (
                          <>
                            <Box mb={1}>
                              <Dropdown
                                className="PreferencesMenu__AugmentsDropdown PreferencesMenu__AugmentsDropdown--preset"
                                width="100%"
                                options={columns.filteredMarkingPresets}
                                selected={null}
                                placeholder={t('ui.character.limbs_apply_preset_placeholder')}
                                //maxItems={7}
                                //searchInput
                                //styledInput
                                onSelected={(value) => {
                                  if (!hasWarnedRef.current)
                                    setPendingPreset(value);
                                  else act('set_preset', { preset: value });
                                }}
                              />
                            </Box>
                            <Divider />
                          </>
                        )}
                        <CenterColumnExtras
                          tab={tab}
                          center={columns.center}
                          budgetBalance={budgetBalance}
                          act={actAndResetPresetWarning}
                        />
                      </Section>
                    </Stack.Item>
                  )}
              </Stack>
            </Stack.Item>

            {/* Right column */}
            <Stack.Item minWidth="33%">
              {columnForTab(
                columns?.right ?? [],
                columns?.internalImplants.right ?? [],
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
};
