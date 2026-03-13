// THIS IS A NOVA SECTOR UI FILE
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

let palette;

export const MilkingMachine = (props) => {
  const { data } = useBackend();
  const { machine_color } = data;

  colorChange(machine_color);

  return (
    <Window resizable width={570} height={375}>
      <Window.Content
        fontSize="14px"
        backgroundColor={palette.WindowBackgroundColor}
      >
        <MilkingMachineContent />
      </Window.Content>
    </Window>
  );
};

const MilkingMachineContent = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization();
  const {
    mobName,
    mobCanLactate,
    beaker,
    BeakerName,
    beakerMaxVolume,
    beakerCurrentVolume,
    mode,
    milkTankMaxVolume,
    milkTankCurrentVolume,
    girlcumTankMaxVolume,
    girlcumTankCurrentVolume,
    semenTankMaxVolume,
    semenTankCurrentVolume,
    current_vessel,
    current_selected_organ,
    current_selected_organ_name,
    current_breasts,
    current_testicles,
    current_vagina,
    machine_color,
  } = data;

  return (
    <Stack vertical textColor={palette.TextColor}>
      <Stack.Item>
        <Stack>
          <Stack.Item grow textAlign="center">
            {!data.mobName && (
              <Section backgroundColor={palette.SectionBackgroundColor}>
                {t('ui.milking_machine.no_creature_in_machine_loaded')}
              </Section>
            )}
            {data.mobName && (
              <Section backgroundColor={palette.SectionBackgroundColor}>
                {t('ui.common.name')}: {mobName}
              </Section>
            )}
          </Stack.Item>
          <Stack.Item align="center">
            {mobName && (
              <Button
                icon="eject"
                content={t('ui.milking_machine.eject_creature')}
                textAlign="center"
                backgroundColor={palette.ButtonBackGroundColor}
                onClick={() => act('ejectCreature')}
              />
            )}
            {!mobName && (
              <Button
                icon="eject"
                content={t('ui.milking_machine.eject_creature')}
                textAlign="center"
                backgroundColor={palette.ButtonBackGroundColor}
                disabled
              />
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Stack vertical>
              <Stack.Item>
                <Section
                  bold
                  backgroundColor={palette.SectionBackgroundColor}
                  textAlign="center"
                >
                  {t('ui.milking_machine.machine_control')}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow={1}>
                    <Stack vertical>
                      <Stack.Item>
                        {modeButtonStates('Off', data, palette, t)}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item grow={2}>
                    <Stack vertical>
                      <Stack.Item>
                        <Section
                          backgroundColor={palette.SectionBackgroundColor}
                          textAlign="center"
                        >
                          {t('ui.common.state')}: {mode}
                        </Section>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item grow>
                    {modeButtonStates('Low', data, palette, t)}
                  </Stack.Item>
                  <Stack.Item grow>
                    {modeButtonStates('Medium', data, palette, t)}
                  </Stack.Item>
                  <Stack.Item grow>
                    {modeButtonStates('Hard', data, palette, t)}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Section
                  bold
                  backgroundColor={palette.SectionBackgroundColor}
                  textAlign="center"
                >
                  {t('ui.milking_machine.organ_control')}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow={2}>
                    <Stack vertical>
                      <Stack>
                        <Stack.Item grow>
                          {current_selected_organ !== null && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.unplug')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOff}
                                textColor={palette.ControlButtonOffText}
                                bold
                                onClick={() => act('unplug')}
                              />
                            </Box>
                          )}
                          {current_selected_organ === null && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.unplug')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                              />
                            </Box>
                          )}
                        </Stack.Item>
                        <Stack.Item grow>
                          {current_selected_organ === null && (
                            <Section
                              backgroundColor={palette.SectionBackgroundColor}
                              textAlign="center"
                            >
                              {t('ui.milking_machine.organ')}: {t('ui.common.none')}
                            </Section>
                          )}
                          {current_selected_organ !== null && (
                            <Section
                              backgroundColor={palette.SectionBackgroundColor}
                              textAlign="center"
                            >
                              {t('ui.milking_machine.organ')}: {current_selected_organ}
                            </Section>
                          )}
                        </Stack.Item>
                      </Stack>
                      <Stack>
                        <Stack.Item grow>
                          {current_selected_organ !== 'the breasts' &&
                            current_breasts !== null && (
                              <Box as="div" m={1}>
                                <Button
                                  content={t('ui.milking_machine.breasts')}
                                  textAlign="center"
                                  width="100%"
                                  backgroundColor={palette.ControlButtonOff}
                                  textColor={palette.ControlButtonOffText}
                                  bold
                                  onClick={() => act('setBreasts')}
                                />
                              </Box>
                            )}
                          {current_selected_organ === 'the breasts' && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.breasts')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                              />
                            </Box>
                          )}
                          {current_vagina === null && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.breasts')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                                disabled
                              />
                            </Box>
                          )}
                        </Stack.Item>
                        <Stack.Item grow>
                          {current_selected_organ !== 'the vagina' &&
                            current_vagina !== null && (
                              <Box as="div" m={1}>
                                <Button
                                  content={t('ui.milking_machine.vagina')}
                                  textAlign="center"
                                  width="100%"
                                  backgroundColor={palette.ControlButtonOff}
                                  textColor={palette.ControlButtonOffText}
                                  bold
                                  onClick={() => act('setVagina')}
                                />
                              </Box>
                            )}
                          {current_selected_organ === 'the vagina' && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.vagina')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                              />
                            </Box>
                          )}
                          {current_vagina === null && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.vagina')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                                disabled
                              />
                            </Box>
                          )}
                        </Stack.Item>
                        <Stack.Item grow>
                          {current_selected_organ !== 'the testicles' &&
                            current_testicles !== null && (
                              <Box as="div" m={1}>
                                <Button
                                  content={t('ui.milking_machine.testicles')}
                                  textAlign="center"
                                  width="100%"
                                  backgroundColor={palette.ControlButtonOff}
                                  textColor={palette.ControlButtonOffText}
                                  bold
                                  onClick={() => act('setTesticles')}
                                />
                              </Box>
                            )}
                          {current_selected_organ === 'the testicles' && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.testicles')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                              />
                            </Box>
                          )}
                          {current_testicles === null && (
                            <Box as="div" m={1}>
                              <Button
                                content={t('ui.milking_machine.testicles')}
                                textAlign="center"
                                width="100%"
                                backgroundColor={palette.ControlButtonOn}
                                textColor={palette.ControlButtonOnText}
                                bold
                                disabled
                              />
                            </Box>
                          )}
                        </Stack.Item>
                      </Stack>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical>
              <Stack.Item>
                {beaker !== null && (
                  <Section
                    bold
                    backgroundColor={palette.SectionBackgroundColor}
                    textAlign="center"
                  >
                    {t('ui.common.beaker')}: {BeakerName}
                  </Section>
                )}
                {beaker === null && (
                  <Section
                    bold
                    backgroundColor={palette.SectionBackgroundColor}
                    textAlign="center"
                  >
                    {t('ui.common.beaker')}: {t('ui.common.none')}
                  </Section>
                )}
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow>
                    {beaker !== null && (
                      <Section
                        backgroundColor={palette.SectionBackgroundColor}
                        textAlign="center"
                      >
                        {t('ui.common.volume')}: {Math.round(beakerCurrentVolume)} /{' '}
                        {Math.round(beakerMaxVolume)}
                      </Section>
                    )}
                    {beaker === null && (
                      <Section
                        backgroundColor={palette.SectionBackgroundColor}
                        textAlign="center"
                      >
                        {t('ui.common.volume')}: n/a
                      </Section>
                    )}
                  </Stack.Item>
                  <Stack.Item align="center">
                    {beaker !== null && (
                      <Button
                        icon="eject"
                        content={t('ui.milking_machine.eject_beaker')}
                        textAlign="center"
                        backgroundColor={palette.ButtonBackGroundColor}
                        onClick={() => act('ejectBeaker')}
                      />
                    )}
                    {beaker === null && (
                      <Button
                        icon="eject"
                        content={t('ui.milking_machine.eject_beaker')}
                        textAlign="center"
                        backgroundColor={palette.ButtonBackGroundColor}
                        disabled
                      />
                    )}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Section
                  bold
                  backgroundColor={palette.SectionBackgroundColor}
                  textAlign="center"
                >
                  {t('ui.milking_machine.tanks_status')}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow basis="1rem">
                        {current_vessel === 'MilkContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.milk')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOn}
                              textColor={palette.ControlButtonOnText}
                              bold
                            />
                          </Box>
                        )}
                        {current_vessel !== 'MilkContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.milk')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOff}
                              textColor={palette.ControlButtonOffText}
                              bold
                              onClick={() => act('setMilk')}
                            />
                          </Box>
                        )}
                      </Stack.Item>
                      <Stack.Item grow basis="1rem">
                        <Section
                          backgroundColor={palette.SectionBackgroundColor}
                          textAlign="center"
                        >
                          {Math.round(milkTankCurrentVolume)} /{' '}
                          {Math.round(milkTankMaxVolume)}
                        </Section>
                      </Stack.Item>
                      <Stack.Item align="center">
                        <Button
                          content="50"
                          minWidth="30pt"
                          textAlign="center"
                          backgroundColor={palette.ButtonBackGroundColor}
                          onClick={() => act('transfer', { amount: 50 })}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow basis="1rem">
                        {current_vessel === 'GirlcumContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.girlcum')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOn}
                              textColor={palette.ControlButtonOnText}
                              bold
                            />
                          </Box>
                        )}
                        {current_vessel !== 'GirlcumContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.girlcum')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOff}
                              textColor={palette.ControlButtonOffText}
                              bold
                              onClick={() => act('setGirlcum')}
                            />
                          </Box>
                        )}
                      </Stack.Item>
                      <Stack.Item grow basis="1rem">
                        <Section
                          backgroundColor={palette.SectionBackgroundColor}
                          textAlign="center"
                        >
                          {Math.round(girlcumTankCurrentVolume)} /{' '}
                          {Math.round(girlcumTankMaxVolume)}
                        </Section>
                      </Stack.Item>
                      <Stack.Item align="center">
                        <Button
                          content="100"
                          minWidth="30pt"
                          textAlign="center"
                          backgroundColor={palette.ButtonBackGroundColor}
                          onClick={() => act('transfer', { amount: 100 })}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow basis="1rem">
                        {current_vessel === 'SemenContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.semen')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOn}
                              textColor={palette.ControlButtonOnText}
                              bold
                            />
                          </Box>
                        )}
                        {current_vessel !== 'SemenContainer' && (
                          <Box as="div" m={1}>
                            <Button
                              content={t('ui.milking_machine.semen')}
                              textAlign="center"
                              width="100%"
                              backgroundColor={palette.ControlButtonOff}
                              textColor={palette.ControlButtonOffText}
                              bold
                              onClick={() => act('setSemen')}
                            />
                          </Box>
                        )}
                      </Stack.Item>
                      <Stack.Item grow basis="1rem">
                        <Section
                          backgroundColor={palette.SectionBackgroundColor}
                          textAlign="center"
                        >
                          {Math.round(semenTankCurrentVolume)} /{' '}
                          {Math.round(semenTankMaxVolume)}
                        </Section>
                      </Stack.Item>
                      <Stack.Item align="center">
                        <Button
                          content={t('ui.common.all')}
                          minWidth="30pt"
                          textAlign="center"
                          backgroundColor={palette.ButtonBackGroundColor}
                          onClick={() => act('transfer', { amount: 1000 })}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const modeLabel = (name, t) => {
  if (name === 'Off') return t('ui.common.off');
  if (name === 'Low') return t('ui.common.low');
  if (name === 'Medium') return t('ui.common.medium');
  if (name === 'Hard') return t('ui.common.high');
  return name;
};

const modeButtonStates = (Name, data, palette, t) => {
  const { act } = useBackend();
  const ModeNameCapital = capitalize(data.mode);
  const action = `set${Name}Mode`;

  if (
    data.mobName !== null &&
    ModeNameCapital !== Name &&
    data.current_selected_organ !== null
  ) {
    return (
      <Box as="div" m={1}>
        <Button
          content={modeLabel(Name, t)}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOff}
          textColor={palette.ControlButtonOffText}
          bold
          onClick={() => act(action)}
        />
      </Box>
    );
  } else if (
    data.mobName !== null &&
    ModeNameCapital === Name &&
    data.current_selected_organ !== null
  ) {
    return (
      <Box as="div" m={1}>
        <Button
          content={modeLabel(Name, t)}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOn}
          textColor={palette.ControlButtonOnText}
          bold
        />
      </Box>
    );
  } else if (
    ModeNameCapital !== Name &&
    (data.current_selected_organ === null) === true
  ) {
    return (
      <Box as="div" m={1}>
        <Button
          content={modeLabel(Name, t)}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOn}
          textColor={palette.ControlButtonOnText}
          bold
          disabled
        />
      </Box>
    );
  } else if (ModeNameCapital === Name && data.current_selected_organ === null) {
    return (
      <Box as="div" m={1}>
        <Button
          content={modeLabel(Name, t)}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOn}
          textColor={palette.ControlButtonOnText}
          bold
        />
      </Box>
    );
  }
};

const organButtonStates = (Name, data, palette) => {
  const { act } = useBackend();
  let OrganNameCapital;
  if (data.current_selected_organ_name !== null) {
    OrganNameCapital = capitalize(data.current_selected_organ_name);
  } else {
    OrganNameCapital = '';
  }
  const action = `set${Name}`;

  if (
    OrganNameCapital !== Name &&
    data.current_breasts !== null &&
    data.mobCanLactate === true
  ) {
    return (
      <Box as="div" m={1}>
        <Button
          content={Name}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOff}
          textColor={palette.ControlButtonOffText}
          bold
          onClick={() => act(action)}
        />
      </Box>
    );
  } else if (OrganNameCapital === Name) {
    return (
      <Box as="div" m={1}>
        <Button
          content={Name}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOn}
          textColor={palette.ControlButtonOnText}
          bold
        />
      </Box>
    );
  } else if (
    data.current_selected_organ_name === null ||
    (OrganNameCapital !== Name && data.mobCanLactate === false)
  ) {
    return (
      <Box as="div" m={1}>
        <Button
          content={Name}
          textAlign="center"
          width="100%"
          backgroundColor={palette.ControlButtonOn}
          textColor={palette.ControlButtonOnText}
          bold
          disabled
        />
      </Box>
    );
  }
};

const capitalize = (g) => {
  if (typeof g !== 'string') return '';
  return g.charAt(0).toUpperCase() + g.slice(1);
};

const colorChange = (g) => {
  if (g === 'pink') {
    palette = {
      WindowBackgroundColor: '#403840',
      SectionBackgroundColor: '#1f071f',
      ButtonBackGroundColor: '#6067C4',
      TextColor: '#f5e8fa',
      ControlButtonOffText: '#00b050',
      ControlButtonOff: '#003020',
      ControlButtonOnText: '#ffffff',
      ControlButtonOn: '#00b050',
    };
    return;
  } else if (g === 'teal') {
    palette = {
      WindowBackgroundColor: '#002b34',
      SectionBackgroundColor: '#000b14',
      ButtonBackGroundColor: '#6067C4',
      TextColor: '#cef7ff',
      ControlButtonOffText: '#0096b3',
      ControlButtonOff: '#00404d',
      ControlButtonOnText: '#e2faff',
      ControlButtonOn: '#00abcd',
    };
    return;
  }
};
