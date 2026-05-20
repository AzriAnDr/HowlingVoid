import { Box, Button, Flex, LabeledList } from 'tgui-core/components';

import { usePreferencesLocalization } from '../localization';
import { useRemappedBackend } from './helpers';
import { useTechWebRoute } from './hooks';
import { TechwebRouter } from './Router';

const formatDeciseconds = (deciseconds = 0) => {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return `${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
};

export function TechwebContent(props) {
  const { act, data } = useRemappedBackend();
  const { t } = usePreferencesLocalization(data, 'rnd');
  const {
    d_disk,
    node_cache,
    points_last_tick,
    point_types_abbreviations = [],
    points,
    queue_nodes = [],
    sec_protocols,
    storytellerPatentDescription,
    storytellerPatentLabel,
    storytellerPatentModifier,
    storytellerPatentRemaining,
    storytellerTechwebBounty,
    t_disk,
  } = data;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  return (
    <Flex direction="column" className="Techweb__Viewport" height="100%">
      <Flex.Item className="Techweb__HeaderSection">
        <Flex className="Techweb__HeaderContent">
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label={t('ui.techweb.security')}>
                <span
                  className={`Techweb__SecProtocol ${
                    !!sec_protocols && 'engaged'
                  }`}
                >
                  {sec_protocols
                    ? t('ui.techweb.engaged')
                    : t('ui.techweb.disengaged')}
                </span>
              </LabeledList.Item>
              {Object.keys(points).map((k) => (
                <LabeledList.Item key={k} label={point_types_abbreviations[k]}>
                  <b>{points[k]}</b>
                  {!!points_last_tick[k] && ` (+${points_last_tick[k]}/sec)`}
                </LabeledList.Item>
              ))}
              {!!storytellerTechwebBounty && (
                <LabeledList.Item label={t('ui.techweb.patent_payout', 'Patent Payout')}>
                  <b>{storytellerTechwebBounty}</b>
                </LabeledList.Item>
              )}
              {!!storytellerPatentLabel && (
                <LabeledList.Item
                  label={t('ui.techweb.patent_flow', 'Patent Flow')}
                >
                  <span
                    className={
                      (storytellerPatentModifier || 1) >= 1
                        ? 'color-good'
                        : 'color-bad'
                    }
                  >
                    {storytellerPatentLabel}
                    {!!storytellerPatentRemaining &&
                      ` (${formatDeciseconds(storytellerPatentRemaining)} left)`}
                  </span>
                  {!!storytellerPatentDescription && (
                    <Box color="label">{storytellerPatentDescription}</Box>
                  )}
                </LabeledList.Item>
              )}
              <LabeledList.Item label={t('ui.techweb.queue')}>
                {queue_nodes.length !== 0
                  ? Object.keys(queue_nodes).map((node_id) => (
                      <Button
                        key={node_id}
                        tooltip={`${t('ui.techweb.added_by')}: ${queue_nodes[node_id]}`}
                      >
                        {node_cache[node_id].name}
                      </Button>
                    ))
                  : t('ui.techweb.empty', 'Empty')}
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
          <Flex.Item grow />
          <Flex.Item>
            <Button fluid onClick={() => act('toggleLock')} icon="lock">
              {t('ui.techweb.lock_console')}
            </Button>
            {d_disk && (
              <Flex.Item>
                <Button
                  fluid
                  onClick={() =>
                    setTechwebRoute({ route: 'disk', diskType: 'design' })
                  }
                >
                  {t('ui.techweb.design_disk_inserted')}
                </Button>
              </Flex.Item>
            )}
            {t_disk && (
              <Flex.Item>
                <Button
                  fluid
                  onClick={() =>
                    setTechwebRoute({ route: 'disk', diskType: 'tech' })
                  }
                >
                  {t('ui.techweb.tech_disk_inserted')}
                </Button>
              </Flex.Item>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__RouterContent" height="100%">
        <TechwebRouter />
      </Flex.Item>
    </Flex>
  );
}
