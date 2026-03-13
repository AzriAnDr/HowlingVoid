import { useState } from 'react';
import { Button, Dropdown, Modal, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import { BlendModes, type Plane } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export function PlaneMenus() {
  const { connectionOpen, infoOpen } = usePlaneDebugContext();

  return (
    <>
      {!!connectionOpen && <AddConnectionModal />}
      {!!infoOpen && <InfoModal />}
    </>
  );
}

function AddConnectionModal() {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { activePlane, setActivePlane, setConnectionOpen, planesProcessed } =
    usePlaneDebugContext();
  const currentPlane = planesProcessed[activePlane as number];
  const optionMap: Record<string, number> = {};
  const [selectedTarget, setSelectedTarget] = useState<number>();
  const [selectedBlend, setSelectedBlend] = useState<string>('BLEND_DEFAULT');

  const selectablePlanes: Plane[] = [];
  for (const key in planesProcessed) {
    const plane: Plane = planesProcessed[key];
    if (plane !== currentPlane) {
      selectablePlanes.push(plane);
      optionMap[plane.name] = plane.plane;
    }
  }

  const planeOptions: Array<string> = selectablePlanes
    .sort((a, b) => {
      if (a.depth !== b.depth) {
        return a.depth - b.depth;
      }

      return a.plane - b.plane;
    })
    .map((a) => a.name);

  return (
    <Modal p={1}>
      <Section
        fill
        title={`${t('ui.plane_master_debug.add_relay_from')} ${currentPlane.name}`}
        buttons={
          <Button
            icon="close"
            color="bad"
            onClick={() => {
              setConnectionOpen(false);
              setActivePlane(undefined);
            }}
          />
        }
      >
        <Stack fill vertical>
          <Stack.Item>
            <Dropdown
              options={planeOptions}
              selected={
                selectedTarget !== undefined
                  ? planesProcessed[selectedTarget].name
                  : t('ui.plane_master_debug.select_target')
              }
              width="300px"
              onSelected={(value) => setSelectedTarget(optionMap[value])}
            />
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              options={Object.keys(BlendModes).filter((x) =>
                Number.isNaN(Number(x)),
              )}
              selected={selectedBlend}
              width="300px"
              onSelected={(value) => setSelectedBlend(value)}
            />
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Button
              color="good"
              onClick={() => {
                act('connect_relay', {
                  source: activePlane,
                  target: selectedTarget,
                  mode: BlendModes[selectedBlend],
                });
                setConnectionOpen(false);
                setActivePlane(undefined);
              }}
            >
              {t('ui.common.confirm')}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
}

function InfoModal() {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { setInfoOpen } = usePlaneDebugContext();
  return (
    <Modal
      position="absolute"
      top="100px"
      right="180px"
      left="180px"
      bottom="100px"
    >
      <Section
        fill
        scrollable
        title={t('ui.plane_master_debug.information_panel')}
        buttons={
          <Button
            icon="times"
            tooltip={t('ui.common.close')}
            onClick={() => setInfoOpen(false)}
          />
        }
      >
        <h3>{t('ui.plane_master_debug.what_is_this')}</h3>
        {t('ui.plane_master_debug.what_is_this_desc_1')} <br />
        {t('ui.plane_master_debug.what_is_this_desc_2')} <br />
        <br />
        <h3>{t('ui.plane_master_debug.how_to_use')}</h3> <br />
        {t('ui.plane_master_debug.how_to_use_desc_1')}
        <br />
        <br />
        {t('ui.plane_master_debug.how_to_use_desc_2')} <br />
        <br />
        {t('ui.plane_master_debug.render_target_connection_prefix')}{' '}
        <code>render_target</code> {t('ui.plane_master_debug.render_target_connection_suffix')}
        <br />
        {t('ui.plane_master_debug.node_colors_desc')} <br />
        {t('ui.plane_master_debug.node_side_desc')} <br />
        <br />
        {t('ui.plane_master_debug.add_relay_help')} <br />
        <br />
        {t('ui.plane_master_debug.open_plane_sidebar_help')} <br />
        <br />
        {t('ui.plane_master_debug.recycle_help')} <br />
        <br />
        <h3>{t('ui.plane_master_debug.what_is_plane_master')}</h3>
        {t('ui.plane_master_debug.plane_master_desc_1')} <br />
        {t('ui.plane_master_debug.plane_master_desc_2_prefix')}{' '}
        <code>plane</code> {t('ui.plane_master_debug.plane_master_desc_2_mid')}{' '}
        <code>/atom</code>. <br />
        <br />
        {t('ui.plane_master_debug.setup_step_1_prefix')} <code>PLANE_MASTER</code>{' '}
        {t('ui.plane_master_debug.setup_step_1_mid')} <code>plane</code>{' '}
        {t('ui.plane_master_debug.setup_step_1_suffix')} <br />
        {t('ui.plane_master_debug.setup_step_2')} <br />
        <br />
        {t('ui.plane_master_debug.setup_step_3_prefix')} <code>PLANE_MASTER</code>
        {t('ui.plane_master_debug.setup_step_3_suffix')} <br />
        {t('ui.plane_master_debug.setup_step_4')} <br />
        <br />
        {t('ui.plane_master_debug.plane_var_note_prefix')} <code>plane</code>{' '}
        {t('ui.plane_master_debug.plane_var_note_suffix')} <br />
        {t('ui.plane_master_debug.layering_note')} <br />
        <br />
        {t('ui.plane_master_debug.hard_effects_note_1')} <br />
        {t('ui.plane_master_debug.hard_effects_note_2')} <br />
        {t('ui.plane_master_debug.hard_effects_note_3')} <br />
        <br />
        {t('ui.plane_master_debug.relay_question_1')} <br />
        {t('ui.plane_master_debug.relay_question_2')} <br />
        <br />
        <h3>{t('ui.plane_master_debug.render_targets_and_relays')}</h3>
        <br />
        {t('ui.plane_master_debug.rendering_note_1')} <br />
        {t('ui.plane_master_debug.rendering_note_2_prefix')} <code>render_target</code>{' '}
        {t('ui.plane_master_debug.rendering_note_2_mid')} <code>render_source</code>.
        <br />
        <br />
        {t('ui.plane_master_debug.rendering_note_3_prefix')} <code>render_target</code>{' '}
        {t('ui.plane_master_debug.rendering_note_3_mid')}
        <b>{t('ui.common.not')}</b> {t('ui.plane_master_debug.rendering_note_3_suffix')}
        <br />
        <br />
        {t('ui.plane_master_debug.rendering_note_4_prefix')} <code>render_source</code>
        {t('ui.plane_master_debug.rendering_note_4_suffix')} <br />
        <br />
        {t('ui.plane_master_debug.rendering_note_5_prefix')} <code>plane</code>{' '}
        {t('ui.plane_master_debug.rendering_note_5_suffix')} <br />
        <br />
        {t('ui.plane_master_debug.rendering_note_6')} <br />
        {t('ui.plane_master_debug.rendering_note_7')} <br />
        <br />
        <h3>{t('ui.plane_master_debug.applying_effects')}</h3> <br />
        {t('ui.plane_master_debug.effects_note_1')} <br />
        <br />
        {t('ui.plane_master_debug.effects_note_2')} <br />
        {t('ui.plane_master_debug.effects_note_3')} <br />
        <br />
        {t('ui.plane_master_debug.effects_note_4')} <br />
        {t('ui.plane_master_debug.effects_note_5')} <br />
        <br />
        {t('ui.plane_master_debug.effects_note_6')} <br />
        <br />
      </Section>
    </Modal>
  );
}
