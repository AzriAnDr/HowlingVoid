// THIS IS A NOVA SECTOR UI FILE
import { Fragment, useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

const brassColor = '#DFC69C';
const tinkerCache = '#B5FD9D';
const replicaFab = '#DED09F';
const clockMarauder = '#FF9D9D';

const convertPower = (power_in) => {
  const units = ['W', 'kW', 'MW', 'GW'];
  let power = 0;
  let value = power_in;
  while (value >= 1000 && power < units.length) {
    power++;
    value /= 1000;
  }
  return Math.round((value + Number.EPSILON) * 100) / 100 + units[power];
};

export const ClockworkSlab = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [selectedTab, setSelectedTab] = useState('Servitude');
  const updateSelectedTab = (tab) => {
    setSelectedTab(tab);
  };
  return (
    <Window theme="clockwork" width={860} height={700}>
      <Window.Content>
        <Section
          title={
            <Box inline color={'good'}>
              <Icon name={'cog'} rotation={0} spin={1} />
              {` ${t('ui.clockwork.slab_title')} `}
              <Icon name={'cog'} rotation={35} spin={1} />
            </Box>
          }
        >
          <ClockworkButtonSelection updateSelectedTab={updateSelectedTab} />
        </Section>
        <div className="ClockSlab__left">
          <Section height="100%" overflowY="auto">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Section>
        </div>
        <div className="ClockSlab__right">
          <div className="ClockSlab__stats">
            <Section height="100%">
              <ClockworkOverview />
            </Section>
          </div>
          <div className="ClockSlab__current">
            <Section
              height="100%"
              overflowY="auto"
              title={t('ui.clockwork.help_title')}
            >
              <ClockworkHelp />
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const ClockworkHelp = (props) => {
  const { t } = usePreferencesLocalization();
  return (
    <>
      <Collapsible title={t('ui.clockwork.where_to_start')} color="average" open={1}>
        <Section>
          {t('ui.clockwork.help_start_desc_1')}
          <br />
          {t('ui.clockwork.help_start_desc_2')} <br />
          {t('ui.clockwork.help_start_desc_3')}
          <br />
          <b>
            {t('ui.clockwork.help_start_install')}&nbsp;
            <font color={brassColor}>{t('ui.clockwork.integration_cogs')}&nbsp;</font>
            {t('ui.clockwork.help_start_install_suffix')}
          </b>
          <br />
        </Section>
      </Collapsible>
      <Collapsible title={t('ui.clockwork.unlocking_scriptures')} color="average">
        <Section>
          {t('ui.clockwork.help_unlock_desc_1')} <b>{t('ui.clockwork.cogs')}</b> {t('ui.clockwork.help_unlock_desc_2')}
          <br />
          {t('ui.clockwork.help_unlock_invoke')}&nbsp;
          <font color={brassColor}>
            <b>{t('ui.clockwork.integration_cog')}&nbsp;</b>
          </font>
          {t('ui.clockwork.help_unlock_place')}&nbsp;
          <b>{t('ui.clockwork.apc')}&nbsp;</b>
          {t('ui.clockwork.help_unlock_place_suffix')}
          <br />
          {t('ui.clockwork.help_unlock_slice')}&nbsp;
          <b>{t('ui.clockwork.apc')}&nbsp;</b>
          {t('ui.clockwork.help_unlock_with')}&nbsp;
          <b>{t('ui.clockwork.integration_cog')}&nbsp;</b>
          {t('ui.clockwork.help_unlock_insert')}
          <br />
        </Section>
      </Collapsible>
      <Collapsible title={t('ui.clockwork.research')} color="average">
        <Section>
          {t('ui.clockwork.help_research_desc_1')}
          <br />
          {t('ui.clockwork.the')}&nbsp;
          <font color={brassColor}>
            <b>{t('ui.clockwork.technologists_lectern')}&nbsp;</b>
          </font>
          {t('ui.clockwork.help_research_desc_2')}
          <br />
          {t('ui.clockwork.help_research_desc_3')}
          <br />
        </Section>
      </Collapsible>
      <Collapsible title={t('ui.clockwork.defense')} color="average">
        <Section>
          <b>
            {t('ui.clockwork.help_defense_desc_1')}
          </b>
          <br />
          <b>
            <font color={brassColor}>{t('ui.clockwork.structures')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_defense_structures_desc')}
          <br />
          <b>
            <font color={brassColor}>{t('ui.clockwork.traps')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_defense_traps_desc_1')}{' '}
          <font color={tinkerCache}>{t('ui.clockwork.tinkerers_cache')}</font>. {t('ui.clockwork.help_defense_traps_desc_2')}
          <br />
          <b>
            <font color={clockMarauder}>{t('ui.clockwork.clockwork_marauder')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_defense_marauder_desc')}
          <br />
          <br />
        </Section>
      </Collapsible>
      <Collapsible title={t('ui.clockwork.tips')} color="average">
        <Section>
          <b>
            <font color={brassColor}>{t('ui.clockwork.vitality')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_tips_vitality_desc_1')}{' '}
          <font color={clockMarauder}>{t('ui.clockwork.clockwork_marauders')}</font>, {t('ui.clockwork.help_tips_vitality_desc_2')}{' '}
          <font color={brassColor}>{t('ui.clockwork.vitality_sigil')}</font>.
          <br />
          <b>
            <font color={brassColor}>{t('ui.clockwork.power')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_tips_power_desc')}
          <br />
          <b>
            <font color={brassColor}>{t('ui.clockwork.your_base')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_tips_base_desc')}
          <br />
          <b>
            <font color={replicaFab}>{t('ui.clockwork.replica_fabricator')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_tips_replica_desc_1')}{' '}
          <font color={tinkerCache}>{t('ui.clockwork.tinkerers_cache')}</font>. {t('ui.clockwork.help_tips_replica_desc_2')}
          <br />
          <b>
            <font color={brassColor}>{t('ui.clockwork.narsie')}:&nbsp;</font>
          </b>
          {t('ui.clockwork.help_tips_narsie_desc')}
          <br />
          <br />
        </Section>
      </Collapsible>
    </>
  );
};

const ClockworkSpellList = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { selectedTab } = props;
  const { scriptures = [] } = data;
  return (
    <Table>
      {scriptures.map((script) =>
        script.type === selectedTab ? (
          <Fragment key={script}>
            <Table.Row>
              <Table.Cell bold>{script.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  color={script.purchased ? 'default' : 'average'}
                  content={
                    script.purchased
                      ? `${t('ui.clockwork.invoke')} ${convertPower(script.cost)}`
                      : `${script.cog_cost} ${t('ui.clockwork.cogs')}`
                  }
                  tooltip={
                    script.research_required
                      ? t('ui.clockwork.research_required_tooltip')
                      : script.tip
                  }
                  disabled={script.research_required}
                  onClick={() =>
                    act('invoke', {
                      scriptureType: script.typepath,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>{script.desc}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  content={t('ui.clockwork.quickbind')}
                  disabled={!script.purchased}
                  onClick={() =>
                    act('quickbind', {
                      scriptureType: script.typepath,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Cell>
              <Divider />
            </Table.Cell>
          </Fragment>
        ) : (
          <Box key={script} />
        ),
      )}
    </Table>
  );
};

const ClockworkOverview = (props) => {
  const { data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { power, cogs, vitality, max_power, max_vitality } = data;
  return (
    <Box>
      <Box color="good" bold fontSize="16px">
        {t('ui.clockwork.celestial_gateway_report')}
      </Box>
      <Divider />
      <ClockworkOverviewStat
        title={t('ui.clockwork.cogs')}
        amount={cogs}
        maxAmount={10}
        iconName="cog"
        unit=""
      />
      <ClockworkOverviewStat
        title={t('ui.clockwork.power')}
        amount={power}
        maxAmount={max_power}
        iconName="battery-half "
        overrideText={convertPower(power)}
      />
      <ClockworkOverviewStat
        title={t('ui.clockwork.vitality')}
        amount={vitality}
        maxAmount={max_vitality}
        iconName="tint"
        unit="u"
      />
    </Box>
  );
};

const ClockworkOverviewStat = (props) => {
  const { title, iconName, amount, maxAmount, unit, overrideText } = props;
  return (
    <Box height="22px" fontSize="16px">
      <Stack>
        <Stack.Item width="8%">
          <Icon name={iconName} rotation={0} spin={0} />
        </Stack.Item>
        <Stack.Item width="20%">{title}</Stack.Item>
        <Stack.Item width="80%">
          <ProgressBar
            value={amount}
            minValue={0}
            maxValue={maxAmount}
            ranges={{
              good: [maxAmount / 2, Infinity],
              average: [maxAmount / 4, maxAmount / 2],
              bad: [-Infinity, maxAmount / 4],
            }}
          >
            {overrideText ? overrideText : `${amount} ${unit}`}
          </ProgressBar>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const ClockworkButtonSelection = (props) => {
  const { t } = usePreferencesLocalization();
  const { updateSelectedTab } = props;
  const tabs = [
    { id: 'Servitude', label: t('ui.clockwork.tab_servitude') },
    { id: 'Preservation', label: t('ui.clockwork.tab_preservation') },
    { id: 'Structures', label: t('ui.clockwork.tab_structures') },
  ];
  const setSelectedTab = (tab) => {
    updateSelectedTab(tab);
  };
  return (
    <Table>
      <Table.Row>
        {tabs.map((tab) => (
          <Table.Cell key={tab.id} collapsing>
            <Button fluid onClick={() => setSelectedTab(tab.id)}>
              {tab.label}
            </Button>
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};
