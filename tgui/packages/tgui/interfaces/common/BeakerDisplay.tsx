import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { usePreferencesLocalization } from '../localization';

export type BeakerReagent = {
  name: string;
  volume: number;
};

export type Beaker = {
  maxVolume: number;
  pH: number;
  currentVolume: number;
  contents: BeakerReagent[];
};

type BeakerProps = {
  beaker: Beaker;
  replace_contents?: BeakerReagent[];
  title_label?: string;
  showpH?: BooleanLike;
  showInsertButton?: boolean;
  hasBeakerInHand?: BooleanLike;
};

export const BeakerDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const { beaker, replace_contents, title_label, showpH } = props;
  const beakerContents = replace_contents || beaker?.contents || [];

  return (
    <LabeledList>
      <LabeledList.Item
        label={t('ui.common.beaker')}
        buttons={
          !!beaker && (
            <Button icon="eject" onClick={() => act('eject')}>
              {t('ui.common.eject')}
            </Button>
          )
        }
      >
        {title_label ||
          (!!beaker && (
            <>
              <AnimatedNumber initial={0} value={beaker.currentVolume} />/
              {beaker.maxVolume} {t('ui.common.units')}
            </>
          )) ||
          t('ui.common.no_beaker')}
      </LabeledList.Item>
      <LabeledList.Item label={t('ui.common.contents')}>
        <Box color="label">
          {(!title_label && !beaker && t('ui.common.not_available_short')) ||
            (beakerContents.length === 0 && t('ui.common.nothing'))}
        </Box>
        {beakerContents.map((chemical) => (
          <Box key={chemical.name} color="label">
            <AnimatedNumber initial={0} value={chemical.volume} />{' '}
            {t('ui.common.units')} {t('ui.common.of_reagent')}{' '}
            {chemical.name}
          </Box>
        ))}
        {beakerContents.length > 0 && !!showpH && (
          <Box>
            pH:
            <AnimatedNumber value={beaker.pH} />
          </Box>
        )}
      </LabeledList.Item>
    </LabeledList>
  );
};

export const BeakerSectionDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    beaker,
    replace_contents,
    title_label,
    showpH,
    showInsertButton = false,
    hasBeakerInHand,
  } = props;

  const beakerContents = replace_contents || beaker?.contents || [];
  const isBeakerLoaded = !!beaker;

  return (
    <Section
      title={title_label || t('ui.common.beaker')}
      buttons={
        isBeakerLoaded ? (
          <>
            <Box inline color="label" mr={2}>
              {beaker.currentVolume} / {beaker.maxVolume} {t('ui.common.units')}
            </Box>
            <Button icon="eject" onClick={() => act('eject')}>
              {t('ui.common.eject')}
            </Button>
          </>
        ) : (
          showInsertButton && (
            <Button
              icon="eject"
              onClick={() => act('insert')}
              style={{
                opacity: hasBeakerInHand ? 1 : 0.5,
              }}
              tooltip={
                !hasBeakerInHand && t('ui.common.hold_container_in_hand')
              }
              tooltipPosition="bottom-start"
            >
              {t('ui.common.insert')}
            </Button>
          )
        )
      }
    >
      <Box color="label">
        {(!beaker && t('ui.common.no_beaker_loaded')) ||
          (beakerContents.length === 0 && t('ui.common.nothing'))}
      </Box>
      {beakerContents.map((chemical) => (
        <Box key={chemical.name} color="label">
          <AnimatedNumber initial={0} value={chemical.volume} />{' '}
          {t('ui.common.units')} {t('ui.common.of_reagent')} {chemical.name}
        </Box>
      ))}
      {beakerContents.length > 0 && !!showpH && (
        <Box>
          pH:
          <AnimatedNumber value={beaker.pH} />
        </Box>
      )}
    </Section>
  );
};
