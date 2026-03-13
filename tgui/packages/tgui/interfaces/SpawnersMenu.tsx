import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';
import { usePreferencesLocalization } from './localization';

type Data = {
  spawners: Spawner[];
};

type Spawner = {
  name: string;
  amount_left: number;
  infinite: BooleanLike;
} & Partial<{
  desc: string;
  you_are_text: string;
  flavor_text: string;
  important_text: string;
}>;

export const SpawnersMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { t } = usePreferencesLocalization(data);
  const { spawners = [] } = data;

  return (
    <Window title={t('ui.spawners_menu.title')} width={700} height={525}>
      <Window.Content scrollable>
        <Stack vertical>
          {spawners.map((spawner) => (
            <Stack.Item key={spawner.name}>
              <Section
                fill
                // Capitalizes the spawner name
                title={capitalizeAll(spawner.name)}
                buttons={
                  <Stack>
                    {spawner.infinite ? (
                      <Stack.Item fontSize="14px" color="green">
                        {t('ui.common.infinite')}
                      </Stack.Item>
                    ) : (
                      <Stack.Item fontSize="14px" color="green">
                        {spawner.amount_left} {t('ui.common.left')}
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button
                        content={t('ui.common.jump')}
                        onClick={() =>
                          act('jump', {
                            name: spawner.name,
                          })
                        }
                      />
                      <Button
                        content={t('ui.common.spawn')}
                        onClick={() =>
                          act('spawn', {
                            name: spawner.name,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                }
              >
                <LabeledList>
                  {spawner.desc ? (
                    <LabeledList.Item label={t('ui.common.description')}>
                      {spawner.desc}
                    </LabeledList.Item>
                  ) : (
                    <div>
                      <LabeledList.Item label={t('ui.spawners_menu.origin')}>
                        {spawner.you_are_text || t('ui.common.unknown')}
                      </LabeledList.Item>
                      <LabeledList.Item label={t('ui.spawners_menu.directives')}>
                        {spawner.flavor_text || t('ui.common.none')}
                      </LabeledList.Item>
                      <LabeledList.Item color="bad" label={t('ui.spawners_menu.conditions')}>
                        {spawner.important_text || t('ui.common.none')}
                      </LabeledList.Item>
                    </div>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
