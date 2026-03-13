import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const skillgreen = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const skillyellow = {
  color: '#FFDB58',
  fontWeight: 'bold',
};

export const SkillPanel = (props) => {
  const { t } = usePreferencesLocalization();
  const { act, data } = useBackend();
  const skills = data.skills || [];
  return (
    <Window title={t('ui.skill_panel.manage_skills')} width={600} height={500}>
      <Window.Content scrollable>
        <Section title={skills.playername}>
          <LabeledList>
            {skills.map((skill) => (
              <LabeledList.Item key={skill.name} label={skill.name}>
                <span style={skillyellow}>{skill.desc}</span>
                <br />
                <Level skill_lvl_num={skill.lvlnum} skill_lvl={skill.lvl} />
                <br />
                {t('ui.skill_panel.total_experience')}: [{skill.exp} XP]
                <br />
                {t('ui.skill_panel.xp_to_next_level')}:
                {skill.exp_req !== 0 ? (
                  <span>
                    [{skill.exp_prog} / {skill.exp_req}]
                  </span>
                ) : (
                  <span style={skillgreen}>[{t('ui.skill_panel.maxed')}]</span>
                )}
                <br />
                {t('ui.skill_panel.overall_skill_progress')}: [{skill.exp} / {skill.max_exp}]
                <ProgressBar value={skill.exp_percent} color="good" />
                <br />
                <Button
                  content={t('ui.skill_panel.adjust_exp')}
                  onClick={() =>
                    act('adj_exp', {
                      skill: skill.path,
                    })
                  }
                />
                <Button
                  content={t('ui.skill_panel.set_exp')}
                  onClick={() =>
                    act('set_exp', {
                      skill: skill.path,
                    })
                  }
                />
                <Button
                  content={t('ui.skill_panel.set_level')}
                  onClick={() =>
                    act('set_lvl', {
                      skill: skill.path,
                    })
                  }
                />
                <br />
                <br />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Level = (props) => {
  const { t } = usePreferencesLocalization();
  const { skill_lvl_num, skill_lvl } = props;
  return (
    <Box inline>
      {t('ui.common.level')}: [
      <Box inline bold textColor={`hsl(${skill_lvl_num * 50}, 50%, 50%)`}>
        {skill_lvl}
      </Box>
      ]
    </Box>
  );
};
