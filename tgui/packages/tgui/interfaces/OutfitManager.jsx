import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { usePreferencesLocalization } from './localization';

export const OutfitManager = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { outfits } = data;
  return (
    <Window
      title={t('ui.outfit_manager.title')}
      width={300}
      height={300}
      theme="admin"
    >
      <Window.Content>
        <Section
          fill
          scrollable
          title={t('ui.outfit_manager.custom_outfit_manager')}
          buttons={
            <>
              <Button
                icon="file-upload"
                tooltip={t('ui.outfit_manager.load_outfit_from_file')}
                tooltipPosition="left"
                onClick={() => act('load')}
              />
              <Button
                icon="copy"
                tooltip={t('ui.outfit_manager.copy_existing_outfit')}
                tooltipPosition="left"
                onClick={() => act('copy')}
              />
              <Button
                icon="plus"
                tooltip={t('ui.outfit_manager.create_new_outfit')}
                tooltipPosition="left"
                onClick={() => act('new')}
              />
            </>
          }
        >
          <Stack vertical>
            {outfits?.map((outfit) => (
              <Stack.Item key={outfit.ref}>
                <Stack>
                  <Stack.Item
                    grow={1}
                    shrink={1}
                    style={{
                      overflow: 'hidden',
                      whiteSpace: 'nowrap',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    <Button
                      fluid
                      style={{
                        overflow: 'hidden',
                        whiteSpace: 'nowrap',
                        textOverflow: 'ellipsis',
                      }}
                      content={outfit.name}
                      onClick={() => act('edit', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      icon="save"
                      tooltip={t('ui.outfit_manager.save_outfit_to_file')}
                      tooltipPosition="left"
                      onClick={() => act('save', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      color="bad"
                      icon="trash-alt"
                      tooltip={t('ui.outfit_manager.delete_outfit')}
                      tooltipPosition="left"
                      onClick={() => act('delete', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
