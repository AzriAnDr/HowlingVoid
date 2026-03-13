import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { getGasLabel } from '../../constants';
import { usePreferencesLocalization } from '../localization';

export type VentProps = {
  refID: string;
  long_name: string;
  power: BooleanLike;
  overclock: BooleanLike;
  integrity: number;
  checks: number;
  excheck: BooleanLike;
  incheck: BooleanLike;
  direction: number;
  external: number;
  internal: number;
  extdefault: number;
  intdefault: number;
};

export type ScrubberProps = {
  refID: string;
  long_name: string;
  power: BooleanLike;
  scrubbing: BooleanLike;
  widenet: BooleanLike;
  filter_types: {
    gas_id: string;
    gas_name: string;
    enabled: BooleanLike;
  }[];
};

export const Vent = (props: VentProps) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    refID,
    long_name,
    power,
    overclock,
    integrity,
    checks,
    excheck,
    incheck,
    direction,
    external,
    internal,
    extdefault,
    intdefault,
  } = props;
  return (
    <Section
      title={decodeHtmlEntities(long_name)}
      buttons={
        <>
          <Button
            icon={power ? 'power-off' : 'times'}
            selected={power}
            disabled={integrity <= 0}
            content={power ? t('ui.common.on') : t('ui.common.off')}
            onClick={() =>
              act('power', {
                ref: refID,
                val: Number(!power),
              })
            }
          />
          <Button
            icon="gauge-high"
            color={overclock ? 'green' : 'yellow'}
            disabled={integrity <= 0}
            onClick={() =>
              act('overclock', {
                ref: refID,
              })
            }
            tooltip={`${overclock ? t('ui.common.disable') : t('ui.common.enable')} ${t('ui.atmos.overclocking')}`}
          />
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.common.integrity')}>
          <p
            title={
              'Overclocking will allow the vent to overpower extreme pressure conditions. However, it will also cause the vent to become damaged over time and eventually fail. The lower the integrity, the less effective the vent will be when in normal operation.'
            }
          >
            {(integrity * 100).toFixed(2)}%
          </p>
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.mode')}>
          <Button
            icon="sign-in-alt"
            content={
              direction
                ? t('ui.atmos.pressurizing')
                : t('ui.atmos.siphoning')
            }
            color={!direction && 'danger'}
            onClick={() =>
              act('direction', {
                ref: refID,
                val: Number(!direction),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.atmos.pressure_regulator')}>
          <Button
            icon="sign-in-alt"
            content={t('ui.common.internal')}
            selected={incheck}
            onClick={() =>
              act('incheck', {
                ref: refID,
                val: checks,
              })
            }
          />
          <Button
            icon="sign-out-alt"
            content={t('ui.common.external')}
            selected={excheck}
            onClick={() =>
              act('excheck', {
                ref: refID,
                val: checks,
              })
            }
          />
        </LabeledList.Item>
        {!!incheck && (
          <LabeledList.Item label={t('ui.atmos.internal_target')}>
            <NumberInput
              value={Math.round(internal)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(value) =>
                act('set_internal_pressure', {
                  ref: refID,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={intdefault}
              content={t('ui.common.reset')}
              onClick={() =>
                act('reset_internal_pressure', {
                  ref: refID,
                })
              }
            />
          </LabeledList.Item>
        )}
        {!!excheck && (
          <LabeledList.Item label={t('ui.atmos.external_target')}>
            <NumberInput
              value={Math.round(external)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(value) =>
                act('set_external_pressure', {
                  ref: refID,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={extdefault}
              content={t('ui.common.reset')}
              onClick={() =>
                act('reset_external_pressure', {
                  ref: refID,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const Scrubber = (props: ScrubberProps) => {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();
  const { long_name, power, scrubbing, refID, widenet, filter_types } = props;
  return (
    <Section
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          content={power ? t('ui.common.on') : t('ui.common.off')}
          selected={power}
          onClick={() =>
            act('power', {
              ref: refID,
              val: Number(!power),
            })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label={t('ui.common.mode')}>
          <Button
            icon={scrubbing ? 'filter' : 'sign-in-alt'}
            color={!scrubbing && 'danger'}
            content={
              scrubbing
                ? t('ui.atmos.scrubbing')
                : t('ui.atmos.siphoning')
            }
            onClick={() =>
              act('scrubbing', {
                ref: refID,
                val: Number(!scrubbing),
              })
            }
          />
          <Button
            icon={widenet ? 'expand' : 'compress'}
            selected={widenet}
            content={
              widenet
                ? t('ui.atmos.expanded_range')
                : t('ui.atmos.normal_range')
            }
            onClick={() =>
              act('widenet', {
                ref: refID,
                val: Number(!widenet),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label={t('ui.common.filters')}>
          {(scrubbing &&
            filter_types.map((filter) => (
              <Button
                key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                tooltip={filter.gas_name}
                selected={filter.enabled}
                onClick={() =>
                  act('toggle_filter', {
                    ref: refID,
                    val: filter.gas_id,
                  })
                }
              >
                {getGasLabel(filter.gas_id, filter.gas_name)}
              </Button>
            ))) ||
            t('ui.common.not_available_short')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
