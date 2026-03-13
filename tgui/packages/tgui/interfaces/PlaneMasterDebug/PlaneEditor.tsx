import {
  Box,
  Button,
  LabeledList,
  Section,
  Slider,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';
import type { Plane } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export function PlaneEditor() {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const { activePlane, planesProcessed, setPlaneOpen } = usePlaneDebugContext();

  const currentPlane: Plane = planesProcessed[activePlane as number];
  const doc_html = {
    __html: currentPlane.documentation,
  };

  return (
    <Section
      fill
      scrollable
      width="450px"
      position="absolute"
      top="0px"
      right="0px"
      backgroundColor="#121212"
      title={`${t('ui.plane_master.plane_master')}: ${currentPlane.name}`}
      buttons={
        <Button
          icon="times"
          tooltip={t('ui.common.close')}
          onClick={() => setPlaneOpen(false)}
        />
      }
    >
      <Section title={t('ui.common.information')}>
        <Box dangerouslySetInnerHTML={doc_html} />
        <br />
        <LabeledList>
          <LabeledList.Divider />
          <Tooltip
            content={t('ui.plane_master.tooltip_plane')}
            position="right"
          >
            <LabeledList.Item label={t('ui.plane_master.plane')}>
              {currentPlane.plane}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content={t('ui.plane_master.tooltip_offset')}
            position="right"
          >
            <LabeledList.Item label={t('ui.plane_master.offset')}>
              {currentPlane.offset}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content={t('ui.plane_master.tooltip_render_target')}
            position="right"
          >
            <LabeledList.Item label={t('ui.plane_master.render_target')}>
              {currentPlane.render_target
                ? `"${currentPlane.render_target}"`
                : t('ui.common.none')}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content={t('ui.plane_master.tooltip_blend_mode')}
            position="right"
          >
            <LabeledList.Item label={t('ui.plane_master.blend_mode')}>
              {currentPlane.blend_mode}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content={t('ui.plane_master.tooltip_forced_hidden')}
            position="right"
          >
            <LabeledList.Item label={t('ui.plane_master.forced_hidden')}>
              {currentPlane.force_hidden ? t('ui.common.true') : t('ui.common.false')}
            </LabeledList.Item>
          </Tooltip>
        </LabeledList>
        <br />
        <Section title={t('ui.common.visuals')}>
          <Button
            tooltip={t('ui.plane_master.tooltip_view_variables')}
            mr="5px"
            mb="5px"
            onClick={() =>
              act('vv_plane', {
                edit: currentPlane.plane,
              })
            }
          >
            {t('ui.plane_master.view_variables')}
          </Button>
          <Button
            tooltip={t('ui.plane_master.tooltip_edit_filters')}
            mr="5px"
            mb="5px"
            onClick={() =>
              act('edit_filters', {
                edit: currentPlane.plane,
              })
            }
          >
            {t('ui.plane_master.edit_filters')}
          </Button>
          <Button
            tooltip={t('ui.plane_master.tooltip_edit_color_matrix')}
            mr="5px"
            mb="5px"
            onClick={() =>
              act('edit_color_matrix', {
                edit: currentPlane.plane,
              })
            }
          >
            {t('ui.plane_master.edit_color_matrix')}
          </Button>
          <Slider
            value={currentPlane.alpha}
            minValue={0}
            maxValue={255}
            step={1}
            stepPixelSize={1.9}
            onChange={(_event, value) =>
              act('set_alpha', { edit: currentPlane.plane, alpha: value })
            }
          >
            {t('ui.plane_master.alpha')} ({currentPlane.alpha})
          </Slider>
        </Section>
      </Section>
    </Section>
  );
}
