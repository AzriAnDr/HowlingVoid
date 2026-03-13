// THIS IS A NOVA SECTOR UI FILE
import { Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { usePreferencesLocalization } from './localization';
import type { Objective } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
};

export const Rules = (props) => {
  const { data } = useBackend<Info>();
  const { t } = usePreferencesLocalization(data);
  const { antag_name } = data;
  const specialRules = t('ui.antaginfo_rules.special_rules');
  const specialRulesLink = t('ui.antaginfo_rules.special_rules_and_metaprotections');
  switch (antag_name) {
    case 'Abductor Agent':
    case 'Abductor Scientist':
    case 'Abductor Solo':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Abductors!_Station_Threat*2">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Drifting Contractor':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Contractor!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Cortical Borer':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Cortical_Borer!_PERMANENT_MECHANICAL_STATE">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Venus Human Trap':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Man_Eaters!_PERMANENT_MECHANICAL_STATE">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Obsessed':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Obsessed!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Revenant':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Revenant!_PERMANENT_MECHANICAL_STATE">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Space Dragon':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Space_Dragon!_PERMANENT_MECHANICAL_STATE">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Space Pirate':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Space_Pirates!_Station_Threat*2">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Blob':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Blob!_PERMANENT_MECHANICAL_STATE">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Changeling':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Changeling!_Station_Threat">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'ClockCult':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Clockcult_(OPFOR)">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'AssaultOps':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Assault_Ops!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Heretic':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Heretic!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Malf AI':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Malf_AI!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Morph':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Morphling!_Station_Threat*2">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Nightmare':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Nightmare!_Station_Threat">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Ninja':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Space_Ninja">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    case 'Wizard':
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Wizard!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
    default:
      return (
        <Stack vertical>
          <Stack.Item bold>{specialRules}</Stack.Item>
          <Stack.Item>
            {
              <a href="https://wiki.novasector13.com/index.php/Antagonist_Policy#Traitor!">
                {specialRulesLink}
              </a>
            }
          </Stack.Item>
        </Stack>
      );
  }
};
