import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const STAT_NAMES = ['Conscious', 'Soft Critical', 'Unconscious', 'Dead'];
const STAT_COLORS = ['good', 'average', 'bad', 'bad'];
const TIER_NAMES = ['', 'Basic', 'Standard', 'Upgraded'];
const TIER_COLORS = ['', 'average', 'good', 'green'];

export const Autodoc = (props) => {
  const { act, data } = useBackend();
  const {
    hasOccupant,
    isOperating,
    automaticMode,
    releaseNotice,
    revivalMode,
    siloConnected,
    researchTier = 1,
    malfunctioning,
    permanentlyBroken,
    interferenceRange = 75,
    healRateModifier = 1,
    materialEfficiency = 1,
    surgerySpeed = 1,
    storedBlood = 0,
    rawBlood = 0,
    bloodCapacity = 0,
    storedSynthflesh = 0,
    synthfleshCapacity = 0,
    organicMode = false,
    synthfleshUseRate = 1,
    occupant,
    surgeryQueue = [],
    activeProcs = [],
    activeSurgery,
    availableProcedures = [],
    isFastUnit = false,
  } = data;

  const disabled = !!malfunctioning || !!permanentlyBroken;

  return (
    <Window width={540} height={780} title="Autodoc Medical System">
      <Window.Content scrollable>
        <Stack vertical fill>
          {/* Permanent Breakdown */}
          {!!permanentlyBroken && (
            <Stack.Item>
              <NoticeBox color="bad">
                <Box bold textAlign="center" fontSize={1.4}>
                  <Icon name="skull-crossbones" mr={1} />
                  SYSTEM DESTROYED — NON-FUNCTIONAL
                  <Icon name="skull-crossbones" ml={1} />
                </Box>
                <Box textAlign="center" mt={1}>
                  This unit has suffered catastrophic failure and cannot be
                  repaired. It must be physically destroyed and replaced.
                </Box>
              </NoticeBox>
            </Stack.Item>
          )}

          {/* Active Malfunction */}
          {!!malfunctioning && (
            <Stack.Item>
              <NoticeBox color="bad">
                <Box bold textAlign="center" fontSize={1.4}>
                  <Icon name="radiation" mr={1} />
                  CRITICAL SYSTEM MALFUNCTION
                  <Icon name="radiation" ml={1} />
                </Box>
                <Box textAlign="center" mt={1}>
                  Emergency lockdown active. Patient is being burned alive.
                  Destroy the machine to extract the patient!
                </Box>
              </NoticeBox>
            </Stack.Item>
          )}

          {/* Warnings */}
          {!!revivalMode && !malfunctioning && !permanentlyBroken && (
            <Stack.Item>
              <NoticeBox color="bad">
                <Box bold textAlign="center" fontSize={1.2}>
                  <Icon name="heartbeat" mr={1} />
                  EMERGENCY REVIVAL PROTOCOL ACTIVE
                  <Icon name="heartbeat" ml={1} />
                </Box>
              </NoticeBox>
            </Stack.Item>
          )}

          {/* Machine Status */}
          {!permanentlyBroken && (
            <Stack.Item>
              <Section title="System Status">
                <LabeledList>
                  <LabeledList.Item
                    label={isFastUnit ? 'Bluespace Storage' : 'Ore Silo'}
                    color={
                      isFastUnit ? 'good' : siloConnected ? 'good' : 'bad'
                    }
                  >
                    {isFastUnit ? 'Connected' : siloConnected ? 'Connected' : 'Disconnected'}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Research Tier"
                    color={TIER_COLORS[researchTier] || 'average'}
                  >
                    T{researchTier} — {TIER_NAMES[researchTier] || 'Unknown'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Healing Rate">
                    {Math.round(healRateModifier * 100)}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Material Efficiency">
                    {Math.round((1 / materialEfficiency) * 100)}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Surgery Speed">
                    {Math.round((1 / surgerySpeed) * 100)}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Interference Range">
                    {interferenceRange} tiles
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Storage">
                    {isFastUnit ? (
                      <Box inline color="green" bold>
                        Unlimited
                      </Box>
                    ) : bloodCapacity > 0 ? (
                      <ProgressBar
                        value={storedBlood}
                        minValue={0}
                        maxValue={bloodCapacity}
                        ranges={{
                          good: [bloodCapacity * 0.5, Infinity],
                          average: [
                            bloodCapacity * 0.15,
                            bloodCapacity * 0.5,
                          ],
                          bad: [-Infinity, bloodCapacity * 0.15],
                        }}
                      >
                        {storedBlood} / {bloodCapacity} u
                      </ProgressBar>
                    ) : (
                      <Box inline color="bad">
                        No Large Beaker
                      </Box>
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item label="Synthflesh">
                    {isFastUnit ? (
                      <Box inline color="green" bold>
                        Unlimited
                      </Box>
                    ) : synthfleshCapacity > 0 ? (
                      <ProgressBar
                        value={storedSynthflesh}
                        minValue={0}
                        maxValue={synthfleshCapacity}
                        ranges={{
                          good: [synthfleshCapacity * 0.5, Infinity],
                          average: [
                            synthfleshCapacity * 0.15,
                            synthfleshCapacity * 0.5,
                          ],
                          bad: [-Infinity, synthfleshCapacity * 0.15],
                        }}
                      >
                        {storedSynthflesh} / {synthfleshCapacity} u
                      </ProgressBar>
                    ) : (
                      <Box inline color="bad">
                        No Beaker
                      </Box>
                    )}
                  </LabeledList.Item>
                  {!isFastUnit && rawBlood > 0 && (
                    <LabeledList.Item label="Processing">
                      <Box inline color="average">
                        <Icon name="sync" spin mr={1} />
                        {rawBlood} u converting...
                      </Box>
                    </LabeledList.Item>
                  )}
                  {!isFastUnit && bloodCapacity > 0 && (
                    <LabeledList.Item label="Blood Packs">
                      <Button
                        icon="eject"
                        content="Eject Packs"
                        disabled={disabled}
                        onClick={() => act('eject_blood')}
                      />
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}

          {/* Controls */}
          <Stack.Item>
            <Section
              title="Controls"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={automaticMode ? 'robot' : 'hand-paper'}
                      content={automaticMode ? 'Automatic' : 'Manual'}
                      color={automaticMode ? 'green' : 'blue'}
                      disabled={isOperating || disabled}
                      onClick={() => act('toggle_mode')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon={organicMode ? 'seedling' : 'robot'}
                      content={organicMode ? 'Organic Mode' : 'Synthetic Mode'}
                      color={organicMode ? 'green' : 'blue'}
                      disabled={isOperating || disabled}
                      onClick={() => act('toggle_organic_mode')}
                      tooltip={
                        organicMode
                          ? 'Organic mode: uses synthflesh for organs and limbs'
                          : 'Synthetic mode: uses ore silo for cybernetic parts'
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon={releaseNotice ? 'bell' : 'bell-slash'}
                      content={releaseNotice ? 'Notices On' : 'Notices Off'}
                      selected={releaseNotice}
                      onClick={() => act('toggle_notice')}
                    />
                  </Stack.Item>
                </Stack>
              }
            />
          </Stack.Item>

          {/* Patient Info */}
          <Stack.Item>
            <Section
              title={
                hasOccupant && occupant
                  ? `Patient: ${occupant.name}`
                  : 'No Patient'
              }
              buttons={
                !!hasOccupant && (
                  <Box
                    inline
                    bold
                    color={STAT_COLORS[occupant?.stat] || 'good'}
                  >
                    {STAT_NAMES[occupant?.stat] || 'Unknown'}
                  </Box>
                )
              }
            >
              {hasOccupant && occupant ? (
                <PatientInfo occupant={occupant} />
              ) : (
                <Box color="label" textAlign="center" py={2}>
                  <Icon name="user-slash" size={3} mb={1} />
                  <br />
                  No patient detected. Place a patient inside the autodoc to
                  begin.
                </Box>
              )}
            </Section>
          </Stack.Item>

          {/* Active Procedures */}
          {!!isOperating && (
            <Stack.Item>
              <Section title="Active Procedures">
                {activeSurgery && (
                  <Box color="good" bold mb={1}>
                    <Icon name="spinner" spin mr={1} />
                    Surgery: {activeSurgery}
                  </Box>
                )}
                {activeProcs.map((proc) => (
                  <Box key={proc.type} color="average">
                    <Icon name="sync" spin mr={1} />
                    {proc.name}
                  </Box>
                ))}
                {!activeSurgery && activeProcs.length === 0 && (
                  <Box color="label">Processing...</Box>
                )}
              </Section>
            </Stack.Item>
          )}

          {/* Surgery Queue */}
          <Stack.Item>
            <Section
              title="Surgery Queue"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="sync"
                      content="Rescan"
                      disabled={!hasOccupant || isOperating || disabled}
                      onClick={() => act('rescan')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="trash"
                      content="Clear"
                      color="bad"
                      disabled={!hasOccupant || isOperating || disabled}
                      onClick={() => act('clear_queue')}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              {surgeryQueue.length > 0 ? (
                surgeryQueue.map((surgery) => (
                  <Box key={surgery.type} mb={0.5}>
                    <Button
                      icon="times"
                      color="bad"
                      disabled={isOperating}
                      onClick={() =>
                        act('remove_procedure', { type: surgery.type })
                      }
                    />
                    {' ' + surgery.name}
                  </Box>
                ))
              ) : (
                <Box color="label" textAlign="center">
                  No procedures queued.
                </Box>
              )}
            </Section>
          </Stack.Item>

          {/* Available Procedures (Manual Mode) */}
          {!automaticMode &&
            !!hasOccupant &&
            !isOperating &&
            availableProcedures.length > 0 && (
              <Stack.Item>
                <Section title="Available Procedures">
                  {availableProcedures.map((proc) => (
                    <Button
                      key={proc.type}
                      icon="plus"
                      content={proc.name}
                      mb={0.5}
                      onClick={() =>
                        act('add_procedure', {
                          type: proc.type,
                          name: proc.name,
                        })
                      }
                    />
                  ))}
                </Section>
              </Stack.Item>
            )}

          {/* Action Buttons */}
          <Stack.Item>
            <Section>
              <Stack fill>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="play"
                    content="Begin Surgery"
                    color="green"
                    disabled={
                      !hasOccupant ||
                      isOperating ||
                      surgeryQueue.length === 0 ||
                      disabled
                    }
                    onClick={() => act('start_surgery')}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="eject"
                    content="Eject Patient"
                    color="bad"
                    disabled={!hasOccupant || disabled}
                    onClick={() => act('eject')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};

const PatientInfo = (props) => {
  const { occupant } = props;
  const {
    wounds = [],
    missingOrgans = [],
    failingOrgans = [],
    missingLimbs = [],
  } = occupant;

  return (
    <>
      {/* Dead patient warning */}
      {occupant.stat === 3 && (
        <Box color="bad" bold textAlign="center" mb={1} fontSize={1.1}>
          <Icon name="skull-crossbones" mr={1} />
          PATIENT DECEASED
        </Box>
      )}
      <ProgressBar
        value={occupant.health}
        minValue={-100}
        maxValue={occupant.maxHealth}
        ranges={{
          good: [50, Infinity],
          average: [0, 50],
          bad: [-Infinity, 0],
        }}
      >
        Health: {Math.round(occupant.health)}
      </ProgressBar>
      <Box mt={1} />
      <LabeledList>
        <LabeledList.Item label="Brute">
          <ProgressBar
            value={occupant.bruteLoss}
            minValue={0}
            maxValue={occupant.maxHealth}
            color="bad"
          >
            {Math.round(occupant.bruteLoss)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Burn">
          <ProgressBar
            value={occupant.fireLoss}
            minValue={0}
            maxValue={occupant.maxHealth}
            color="bad"
          >
            {Math.round(occupant.fireLoss)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Toxin">
          <ProgressBar
            value={occupant.toxLoss}
            minValue={0}
            maxValue={occupant.maxHealth}
            color="bad"
          >
            {Math.round(occupant.toxLoss)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Oxygen">
          <ProgressBar
            value={occupant.oxyLoss}
            minValue={0}
            maxValue={occupant.maxHealth}
            color="bad"
          >
            {Math.round(occupant.oxyLoss)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Blood"
          color={
            occupant.bloodVolume < occupant.bloodVolumeNormal ? 'bad' : 'good'
          }
        >
          {Math.round(occupant.bloodVolume)} / {occupant.bloodVolumeNormal} u
        </LabeledList.Item>
      </LabeledList>

      {/* Wounds */}
      {wounds.length > 0 && (
        <Section title={`Wounds (${wounds.length})`} mt={1}>
          {wounds.map((wound, index) => (
            <Box key={index} color="bad">
              <Icon name="band-aid" mr={1} />
              {wound.name} — {wound.location}
            </Box>
          ))}
        </Section>
      )}

      {/* Missing Organs */}
      {missingOrgans.length > 0 && (
        <Section title={`Missing Organs (${missingOrgans.length})`} mt={1}>
          {missingOrgans.map((organ, index) => (
            <Box key={index} color="bad">
              <Icon name="exclamation-triangle" mr={1} />
              {organ}
            </Box>
          ))}
        </Section>
      )}

      {/* Failing Organs */}
      {failingOrgans.length > 0 && (
        <Section title={`Failing Organs (${failingOrgans.length})`} mt={1}>
          {failingOrgans.map((organ, index) => (
            <Box key={index} color="orange">
              <Icon name="heartbeat" mr={1} />
              {organ} — Organ Failure
            </Box>
          ))}
        </Section>
      )}

      {/* Missing Limbs */}
      {missingLimbs.length > 0 && (
        <Section title={`Missing Limbs (${missingLimbs.length})`} mt={1}>
          {missingLimbs.map((limb, index) => (
            <Box key={index} color="bad">
              <Icon name="exclamation-triangle" mr={1} />
              {limb}
            </Box>
          ))}
        </Section>
      )}
    </>
  );
};

const StatsReference = () => {
  const TIERS = ['T1', 'T2', 'T3', 'T4'];

  const renderGroup = (title, rows) => (
    <>
      <Table.Row>
        <Table.Cell header colSpan={5} bold color="label" pt={1} pb={0}>
          {title}
        </Table.Cell>
      </Table.Row>
      {rows.map((row, i) => (
        <Table.Row key={i}>
          <Table.Cell pl={1} color="label">
            {row.label}
          </Table.Cell>
          {row.values.map((val, j) => (
            <Table.Cell key={j} textAlign="center">
              {val}
            </Table.Cell>
          ))}
        </Table.Row>
      ))}
    </>
  );

  return (
    <Collapsible title="Component Reference">
      <Table>
        <Table.Row header>
          <Table.Cell collapsing />
          {TIERS.map((t) => (
            <Table.Cell key={t} bold textAlign="center" header>
              {t}
            </Table.Cell>
          ))}
        </Table.Row>
        {renderGroup('Servo Motors (\u00d72)', [
          { label: 'Healing Rate', values: ['1.0\u00d7', '1.5\u00d7', '2.0\u00d7', '2.5\u00d7'] },
          {
            label: 'Synthflesh \u2014 Organ',
            values: ['40u', '32u', '24u', '16u'],
          },
          {
            label: 'Synthflesh \u2014 Limb',
            values: ['80u', '64u', '48u', '32u'],
          },
          {
            label: 'Synthflesh \u2014 Dehusk',
            values: ['120u', '96u', '72u', '48u'],
          },
        ])}
        {renderGroup('Matter Bins (\u00d72)', [
          {
            label: 'Material Cost',
            values: ['130%', '100%', '70%', '40%'],
          },
        ])}
        {renderGroup('Micro Laser (\u00d71)', [
          {
            label: 'Surgery Speed',
            values: ['100%', '125%', '167%', '250%'],
          },
        ])}
        {renderGroup('Scanning Module (\u00d71)', [
          {
            label: 'Interference Range',
            values: ['130t', '110t', '90t', '70t'],
          },
        ])}
      </Table>
    </Collapsible>
  );
};
