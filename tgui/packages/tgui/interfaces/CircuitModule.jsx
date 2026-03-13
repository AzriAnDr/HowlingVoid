import { Button, Dropdown, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const CircuitModule = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { input_ports, output_ports, global_port_types } = data;
  return (
    <Window width={600} height={300}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Button
              content={t('ui.circuit_module.view_internal_circuit')}
              textAlign="center"
              fluid
              onClick={() => act('open_internal_circuit')}
            />
          </Stack.Item>
          <Stack.Item>
            <Stack width="100%">
              <Stack.Item basis="50%">
                <Section title={t('ui.circuit_module.input_ports')}>
                  <Stack vertical>
                    {input_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() =>
                          act('remove_input_port', {
                            port_id: index + 1,
                          })
                        }
                        onSetType={(type) =>
                          act('set_port_type', {
                            port_id: index + 1,
                            is_input: true,
                            port_type: type,
                          })
                        }
                        onEnter={(e, value) =>
                          act('set_port_name', {
                            port_id: index + 1,
                            is_input: true,
                            port_name: value,
                          })
                        }
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        content={t('ui.circuit_module.add_input_port')}
                        color="good"
                        icon="plus"
                        onClick={() => act('add_input_port')}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item basis="50%">
                <Section title={t('ui.circuit_module.output_ports')}>
                  <Stack vertical>
                    {output_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() =>
                          act('remove_output_port', {
                            port_id: index + 1,
                          })
                        }
                        onSetType={(type) =>
                          act('set_port_type', {
                            port_id: index + 1,
                            is_input: false,
                            port_type: type,
                          })
                        }
                        onEnter={(e, value) =>
                          act('set_port_name', {
                            port_id: index + 1,
                            is_input: false,
                            port_name: value,
                          })
                        }
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        content={t('ui.circuit_module.add_output_port')}
                        color="good"
                        icon="plus"
                        onClick={() => act('add_output_port')}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PortEntry = (props) => {
  const { t } = usePreferencesLocalization();
  const {
    onRemove,
    onEnter,
    onSetType,
    name,
    datatype,
    datatypeOptions = [],
    ...rest
  } = props;

  return (
    <Stack.Item {...rest}>
      <Stack>
        <Stack.Item grow>
          <Input
            placeholder={t('ui.common.name')}
            value={name}
            onChange={onEnter}
            fluid
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            selected={datatype}
            options={datatypeOptions}
            onSelected={onSetType}
          />
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="red" onClick={onRemove} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
