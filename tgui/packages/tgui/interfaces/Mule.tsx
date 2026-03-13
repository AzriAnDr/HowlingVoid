import {
  Button,
  Dropdown,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { usePreferencesLocalization } from './localization';

type Data = {
  powerStatus: BooleanLike;
  cellPercent: number | null;
  load: BooleanLike;
  locked: BooleanLike;
  siliconUser: BooleanLike;
  mode: string;
  modeStatus: string;
  autoReturn: BooleanLike;
  autoPickup: BooleanLike;
  reportDelivery: BooleanLike;
  destination: string | null;
  destinationsList: string[];
  homeDestination: string | null;
  botId: string;
  allowPossession: BooleanLike;
  possessionEnabled: BooleanLike;
  paiInserted: BooleanLike;
};

const MuleControls = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    load,
    autoReturn,
    autoPickup,
    reportDelivery,
    destination,
    homeDestination,
    botId,
    allowPossession,
    possessionEnabled,
    paiInserted,
    destinationsList = [],
  } = data;

  return (
    <>
      <Section
        title={t('ui.mule.controls')}
        buttons={
          <>
            {!!load && (
              <Button icon="eject" onClick={() => act('unload')}>
                {t('ui.common.unload')}
              </Button>
            )}
            {!!paiInserted && (
              <Button icon="eject" onClick={() => act('eject_pai')}>
                {t('ui.mule.eject_pai')}
              </Button>
            )}
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label={t('ui.common.id')}>
            <Button onClick={() => act('setid')}>{botId}</Button>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.home')}>
            <Button onClick={() => act('sethome')}>{homeDestination}</Button>
          </LabeledList.Item>
          <LabeledList.Item label={t('ui.common.destination')}>
            <Dropdown
              over
              selected={destination || t('ui.common.none')}
              options={destinationsList}
              width="188px"
              onSelected={(value) => act('destination', { value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={t('ui.common.settings')}>
        <Button.Checkbox checked={autoReturn} onClick={() => act('autored')}>
          {t('ui.mule.auto_return')}
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={autoPickup} onClick={() => act('autopick')}>
          {t('ui.mule.auto_pickup')}
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={reportDelivery} onClick={() => act('report')}>
          {t('ui.mule.report_delivery')}
        </Button.Checkbox>
        <br />
        {!!allowPossession && (
          <Button.Checkbox
            checked={possessionEnabled}
            onClick={() => act('toggle_personality')}
          >
            {t('ui.mule.download_personality')}
          </Button.Checkbox>
        )}
      </Section>
      <Section title={t('ui.common.actions')}>
        <Stack style={{ padding: '0px 30px' }}>
          <Stack.Item grow>
            <Button
              width="60px"
              icon="stop"
              color="bad"
              onClick={() => act('stop')}
            >
              {t('ui.common.stop')}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              width="60px"
              icon="play"
              color="average"
              onClick={() => act('go')}
            >
              {t('ui.common.go')}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button width="60px" icon="home" onClick={() => act('home')}>
              {t('ui.common.home')}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

export const Mule = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const {
    powerStatus,
    cellPercent,
    load,
    mode,
    modeStatus,
    locked,
    siliconUser,
  } = data;

  const mulebotLocked = locked && !siliconUser;

  return (
    <Window width={350} height={500}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        <Section
          title={t('ui.common.status')}
          buttons={
            <>
              <Button icon="fa-poll-h" onClick={() => act('rename')}>
                {t('ui.common.rename')}
              </Button>
              {!mulebotLocked && (
                <Button
                  icon={powerStatus ? 'power-off' : 'times'}
                  selected={powerStatus}
                  onClick={() => act('on')}
                >
                  {powerStatus ? t('ui.common.on') : t('ui.common.off')}
                </Button>
              )}
            </>
          }
        >
          <ProgressBar
            value={cellPercent ? cellPercent / 100 : 0}
            color={cellPercent ? 'good' : 'bad'}
          />
          <Stack mt={1}>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label={t('ui.common.mode')} color={modeStatus}>
                  {mode}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow ml="40%">
              <LabeledList>
                <LabeledList.Item
                  label={t('ui.common.load')}
                  color={load ? 'good' : 'average'}
                >
                  {load || t('ui.common.none')}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        {!mulebotLocked && <MuleControls />}
      </Window.Content>
    </Window>
  );
};
