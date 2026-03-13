import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useState,
} from 'react';
import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { usePreferencesLocalization } from '../localization';
import type { ParticleUIData } from './data';
import {
  EntryCoord,
  EntryFloat,
  EntryGradient,
  EntryIcon,
  EntryIconState,
  EntryTransform,
} from './EntriesBasic';
import {
  EntryGeneratorNumbersList,
  FloatGenerator,
  FloatGeneratorColor,
} from './EntriesGenerators';
import { ShowDesc } from './Tutorial';

type ParticleEditContext = {
  desc: string;
  setDesc: Dispatch<SetStateAction<string>>;
};

export const ParticleContext = createContext({} as ParticleEditContext);

export const ParticleEdit = (props) => {
  const { act, data } = useBackend<ParticleUIData>();
  const { t } = usePreferencesLocalization(data);
  const [desc, setDesc] = useState('');

  const {
    width,
    height,
    count,
    spawning,
    bound1,
    bound2,
    gravity,
    gradient,
    transform,

    icon,
    icon_state,
    lifespan,
    fade,
    fadein,
    color,
    color_change,
    position,
    velocity,
    scale,
    grow,
    rotation,
    spin,
    friction,

    drift,
  } = data.particle_data;

  return (
    <ParticleContext.Provider value={{ desc, setDesc }}>
      <Window
        title={t('ui.particle_editor.target_particles').replace(
          '{target}',
          data.target_name,
        )}
        width={940}
        height={890}
      >
        {desc ? <ShowDesc /> : null}
        <Window.Content scrollable>
          <LabeledList>
            <Section
              title={t('ui.particle_editor.affects_entire_set')}
              buttons={
                <>
                  <Button
                    icon={'question'}
                    onClick={() => setDesc('generator')}
                    tooltip={t('ui.particle_editor.generator_information')}
                  />
                  <Button
                    icon={'sync'}
                    onClick={() => act('new_type')}
                    tooltip={t('ui.common.change_type')}
                  />
                  <Button
                    icon={'x'}
                    color={'red'}
                    onClick={() => act('delete_and_close')}
                    tooltip={t('ui.particle_editor.delete_and_close_ui')}
                  />
                </>
              }
            >
              <EntryFloat
                name={t('ui.particle_editor.width')}
                var_name={'width'}
                float={width}
              />
              <EntryFloat
                name={t('ui.particle_editor.height')}
                var_name={'height'}
                float={height}
              />
              <EntryFloat
                name={t('ui.particle_editor.count')}
                var_name={'count'}
                float={count}
              />
              <EntryFloat
                name={t('ui.particle_editor.spawning')}
                var_name={'spawning'}
                float={spawning}
              />
              <EntryCoord
                name={t('ui.particle_editor.bound_corner_1')}
                var_name={'bound1'}
                coord={bound1}
              />
              <EntryCoord
                name={t('ui.particle_editor.bound_corner_2')}
                var_name={'bound2'}
                coord={bound2}
              />
              <EntryCoord
                name={t('ui.particle_editor.gravity')}
                var_name={'gravity'}
                coord={gravity}
              />
              <EntryGradient
                name={t('ui.particle_editor.gradient')}
                var_name={'gradient'}
                gradient={gradient}
              />
              <EntryTransform
                name={t('ui.particle_editor.transform')}
                var_name={'transform'}
                transform={transform}
              />
            </Section>
            <Section title={t('ui.particle_editor.evaluated_on_particle_creation')}>
              <EntryIcon
                name={t('ui.common.icon')}
                var_name={'icon'}
                icon_state={icon}
              />
              <EntryIconState
                name={t('ui.particle_editor.icon_state')}
                var_name={'icon_state'}
                icon_state={icon_state}
              />
              <FloatGenerator
                name={t('ui.particle_editor.lifespan')}
                var_name={'lifespan'}
                float={lifespan}
              />
              <FloatGenerator
                name={t('ui.particle_editor.fade_out')}
                var_name={'fade'}
                float={fade}
              />
              <FloatGenerator
                name={t('ui.particle_editor.fade_in')}
                var_name={'fadein'}
                float={fadein}
              />
              <FloatGeneratorColor
                name={t('ui.common.color')}
                var_name={'color'}
                float={color}
              />
              <FloatGenerator
                name={t('ui.particle_editor.color_change')}
                var_name={'color_change'}
                float={color_change}
              />
              <EntryGeneratorNumbersList
                name={t('ui.common.position')}
                var_name={'position'}
                allow_z
                input={position}
              />
              <EntryGeneratorNumbersList
                name={t('ui.common.velocity')}
                var_name={'velocity'}
                allow_z
                input={velocity}
              />
              <EntryGeneratorNumbersList
                name={t('ui.common.scale')}
                var_name={'scale'}
                allow_z={false}
                input={scale}
              />
              <EntryGeneratorNumbersList
                name={t('ui.particle_editor.grow')}
                var_name={'grow'}
                allow_z={false}
                input={grow}
              />
              <FloatGenerator
                name={t('ui.common.rotation')}
                var_name={'rotation'}
                float={rotation}
              />
              <FloatGenerator
                name={t('ui.particle_editor.spin')}
                var_name={'spin'}
                float={spin}
              />
              <FloatGenerator
                name={t('ui.particle_editor.friction')}
                var_name={'friction'}
                float={friction}
              />
            </Section>
            <Section title={t('ui.particle_editor.evaluated_every_tick')}>
              <EntryGeneratorNumbersList
                name={t('ui.particle_editor.drift')}
                var_name={'drift'}
                allow_z
                input={drift}
              />
            </Section>
          </LabeledList>
        </Window.Content>
      </Window>
    </ParticleContext.Provider>
  );
};
