import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const NtosScipaper = (props) => {
  return (
    <NtosWindow width={600} height={600}>
      <NtosWindow.Content scrollable>
        <NtosScipaperContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const PaperPublishing = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    title,
    author,
    etAlia,
    abstract,
    fileList = [],
    expList = [],
    allowedTiers = [],
    allowedPartners = [],
    gains,
    selectedFile,
    selectedExperiment,
    tier,
    selectedPartner,
    coopIndex,
    fundingIndex,
  } = data;
  return (
    <>
      <Section title={t('ui.ntos_scipaper.submission_form')}>
        {fileList.length === 0 && (
          <NoticeBox>
            {t('ui.ntos_scipaper.use_data_disk_notice')}
          </NoticeBox>
        )}
        <LabeledList>
          <LabeledList.Item
            label={t('ui.ntos_scipaper.file_required')}
            buttons={
              <Button
                tooltip={t('ui.ntos_scipaper.file_tooltip')}
                icon="info-circle"
              />
            }
          >
            <Box position="relative" top="8px">
              <Dropdown
                width="100%"
                options={Object.keys(fileList)}
                selected={selectedFile}
                onSelected={(ordfile_name) =>
                  act('select_file', {
                    selected_uid: fileList[ordfile_name],
                  })
                }
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.ntos_scipaper.experiment_required')}
            buttons={
              <Button
                tooltip={t('ui.ntos_scipaper.experiment_tooltip')}
                icon="info-circle"
              />
            }
          >
            <Box position="relative" top="8px">
              <Dropdown
                width="100%"
                options={Object.keys(expList)}
                selected={selectedExperiment}
                onSelected={(experiment_name) =>
                  act('select_experiment', {
                    selected_expath: expList[experiment_name],
                  })
                }
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.ntos_scipaper.tier_required')}
            buttons={
              <Button
                tooltip={t('ui.ntos_scipaper.tier_tooltip')}
                icon="info-circle"
              />
            }
          >
            <Box position="relative" top="8px">
              <Dropdown
                width="100%"
                options={allowedTiers.map((number) => String(number))}
                selected={String(tier)}
                onSelected={(new_tier) =>
                  act('select_tier', {
                    selected_tier: Number(new_tier),
                  })
                }
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.ntos_scipaper.partner_required')}
            buttons={
              <Button
                tooltip={t('ui.ntos_scipaper.partner_tooltip')}
                icon="info-circle"
              />
            }
          >
            <Box position="relative" top="8px">
              <Dropdown
                width="100%"
                options={Object.keys(allowedPartners)}
                selected={selectedPartner}
                onSelected={(new_partner) =>
                  act('select_partner', {
                    selected_partner: allowedPartners[new_partner],
                  })
                }
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label={t('ui.ntos_scipaper.principal_author')}
            buttons={
              <Button
                tooltip={t('ui.ntos_scipaper.multiple')}
                selected={etAlia}
                icon="users"
                onClick={() => act('et_alia')}
              />
            }
          >
            <Input
              mt={2}
              fluid
              value={author}
              onBlur={(value) =>
                act('rewrite', {
                  author: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.title')}>
            <Input
              fluid
              value={title}
              onBlur={(value) =>
                act('rewrite', {
                  title: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.abstract')}>
            <Input
              fluid
              value={abstract}
              onBlur={(value) =>
                act('rewrite', {
                  abstract: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={t('ui.ntos_scipaper.expected_results')} key="rewards">
        <Stack fill>
          <Stack.Item grow>
            <Button
              tooltip={t('ui.ntos_scipaper.cooperation_tooltip')}
              icon="info-circle"
            />
            {` ${t('ui.ntos_scipaper.cooperation')}: `}
            <BlockQuote>{gains[coopIndex]}</BlockQuote>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              tooltip={t('ui.ntos_scipaper.funding_tooltip')}
              icon="info-circle"
            />
            {` ${t('ui.ntos_scipaper.funding')}: `}
            <BlockQuote>{gains[fundingIndex]}</BlockQuote>
          </Stack.Item>
        </Stack>
        <br />
        <Button
          lineHeight={3}
          icon="upload"
          textAlign="center"
          fluid
          onClick={() => act('publish')}
        >
          {t('ui.ntos_scipaper.publish_paper')}
        </Button>
      </Section>
    </>
  );
};

const PaperBrowser = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { publishedPapers, coopIndex, fundingIndex } = data;
  if (publishedPapers.length === 0) {
    return <NoticeBox>{t('ui.ntos_scipaper.no_published_papers')}</NoticeBox>;
  } else {
    return publishedPapers.map((paper) => (
      <Collapsible
        key={String(paper.experimentName + paper.tier)}
        title={paper.title}
      >
        <Section>
          <LabeledList>
            <LabeledList.Item label={t('ui.ntos_scipaper.topic')}>
              {`${paper.experimentName} - ${paper.tier}`}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.author')}>
              {paper.author + (paper.etAlia ? ' et al.' : '')}
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.ntos_scipaper.partner')}>{paper.partner}</LabeledList.Item>
            <LabeledList.Item label={t('ui.ntos_scipaper.yield')}>
              <LabeledList>
                <LabeledList.Item label={t('ui.ntos_scipaper.cooperation')}>
                  {paper.gains[coopIndex]}
                </LabeledList.Item>
                <LabeledList.Item label={t('ui.ntos_scipaper.funding')}>
                  {paper.gains[fundingIndex]}
                </LabeledList.Item>
              </LabeledList>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.common.abstract')}>
              {paper.abstract}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Collapsible>
    ));
  }
};
const ExperimentBrowser = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { experimentInformation = [] } = data;
  return experimentInformation.map((experiment) => (
    <Section title={experiment.name} key={experiment.name}>
      {experiment.description}
      <br />
      <LabeledList>
        {Object.keys(experiment.target).map((tier) => (
          <LabeledList.Item
            key={tier}
            label={
              'Optimal ' +
              experiment.prefix +
              ` ${t('ui.ntos_scipaper.amount_tier')} ` +
              String(Number(tier) + 1)
            }
          >
            {`${experiment.target[tier]} ${experiment.suffix}`}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  ));
};

const PartnersBrowser = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    partnersInformation,
    coopIndex,
    fundingIndex,
    purchaseableBoosts = [],
    relations = [],
    visibleNodes = [],
  } = data;
  return partnersInformation.map((partner) => (
    <Section title={partner.name} key={partner.path}>
      <Collapsible title={`${t('ui.ntos_scipaper.relations')}: ${relations[partner.path]}`}>
        <LabeledList>
          <LabeledList.Item label={t('ui.common.description')}>
            {partner.flufftext}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ntos_scipaper.relations')}>
            {relations[partner.path]}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ntos_scipaper.cooperation_bonus')}>
            {`${partner.multipliers[coopIndex]}x`}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ntos_scipaper.funding_bonus')}>
            {`${partner.multipliers[fundingIndex]}x`}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ntos_scipaper.accepted_experiments')}>
            {partner.acceptedExperiments.map((experiment_name) => (
              <Box key={experiment_name}>{experiment_name}</Box>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.ntos_scipaper.technology_sharing')}>
            <Table>
              {partner.boostedNodes.map((node) => (
                <Table.Row key={node.id}>
                  <Table.Cell>
                      {visibleNodes.includes(node.id)
                        ? node.name
                        : t('ui.common.unknown_technology')}
                    </Table.Cell>
                  <Table.Cell>
                    <Button
                      fluid
                      tooltipPosition="left"
                      textAlign="center"
                      disabled={
                        !purchaseableBoosts[partner.path].includes(node.id)
                      }
                      content={t('ui.common.purchase')}
                      tooltip={`${t('ui.ntos_scipaper.discount')}: ${node.discount}`}
                      onClick={() =>
                        act('purchase_boost', {
                          purchased_boost: node.id,
                          boost_seller: partner.path,
                        })
                      }
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>
    </Section>
  ));
};

export const NtosScipaperContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { currentTab, has_techweb } = data;
  return (
    <>
      {!has_techweb && (
        <Section title={t('ui.ntos_scipaper.no_techweb_detected')} key="rewards">
          {t('ui.ntos_scipaper.sync_to_techweb')}
        </Section>
      )}
      <Tabs key="navigation" fluid align="center">
        <Tabs.Tab
          selected={currentTab === 1}
          onClick={() =>
            act('change_tab', {
              new_tab: 1,
            })
          }
        >
          {t('ui.ntos_scipaper.tab_publish_papers')}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 2}
          onClick={() =>
            act('change_tab', {
              new_tab: 2,
            })
          }
        >
          {t('ui.ntos_scipaper.tab_publications')}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 3}
          onClick={() =>
            act('change_tab', {
              new_tab: 3,
            })
          }
        >
          {t('ui.common.experiments')}
        </Tabs.Tab>
        <Tabs.Tab
          selected={currentTab === 4}
          onClick={() =>
            act('change_tab', {
              new_tab: 4,
            })
          }
        >
          {t('ui.ntos_scipaper.tab_scientific_partners')}
        </Tabs.Tab>
      </Tabs>
      {currentTab === 1 && <PaperPublishing />}
      {currentTab === 2 && <PaperBrowser />}
      {currentTab === 3 && <ExperimentBrowser />}
      {currentTab === 4 && <PartnersBrowser />}
    </>
  );
};
