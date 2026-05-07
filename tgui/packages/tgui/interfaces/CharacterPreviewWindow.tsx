import { useEffect, useState } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CharacterPreview } from './common/CharacterPreview';
import { usePreferencesLocalization } from './localization';

type PreviewAnimationData = {
  delays?: number[] | null;
  frames: number;
  height: number;
  rewind?: unknown;
  width: number;
};

type CharacterPreviewWindowData = {
  preview_item_animations_enabled?: boolean | number;
  preview_animations?: Record<string, PreviewAnimationData | null> | null;
  preview_direction?: string | null;
  preview_url?: string | null;
  preview_urls?: Record<string, string | null> | null;
};

const PREVIEW_DIRECTION_CYCLE = ['south', 'west', 'north', 'east'];

function rotatePreviewDirection(direction: string | null | undefined, step: -1 | 1) {
  const currentDirection = (direction || PREVIEW_DIRECTION_CYCLE[0]).toLowerCase();
  const currentIndex = PREVIEW_DIRECTION_CYCLE.indexOf(currentDirection);
  const safeIndex = currentIndex >= 0 ? currentIndex : 0;
  const nextIndex =
    (safeIndex + step + PREVIEW_DIRECTION_CYCLE.length) %
    PREVIEW_DIRECTION_CYCLE.length;

  return PREVIEW_DIRECTION_CYCLE[nextIndex];
}

export function CharacterPreviewWindow() {
  const { act, data } = useBackend<CharacterPreviewWindowData>();
  const { t } = usePreferencesLocalization(data);
  const [previewDirection, setPreviewDirection] = useState(
    (data.preview_direction || PREVIEW_DIRECTION_CYCLE[0]).toLowerCase(),
  );

  useEffect(() => {
    setPreviewDirection(
      (data.preview_direction || PREVIEW_DIRECTION_CYCLE[0]).toLowerCase(),
    );
  }, [data.preview_direction]);

  return (
    <Window width={760} height={840} title={t('ui.character.limbs_character_preview')}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack justify="center">
              <Stack.Item>
                <Button.Checkbox
                  className={`PreferencesMenu__Toggle ${
                    data.preview_item_animations_enabled
                      ? 'PreferencesMenu__Toggle--checked'
                      : ''
                  }`}
                  checked={!!data.preview_item_animations_enabled}
                  tooltip={t('ui.character.preview_item_animations_tooltip')}
                  onClick={() => act('toggle_preview_item_animations')}
                >
                  {t('ui.character.preview_item_animations_label')}
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <div
              style={{
                width: '100%',
                height: '100%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <div
                style={{
                  width: '100%',
                  maxWidth: '680px',
                  aspectRatio: '1 / 1',
                  background: '#000',
                  overflow: 'hidden',
                }}
              >
                <CharacterPreview
                  animationMap={data.preview_animations}
                  direction={previewDirection}
                  imageMap={data.preview_urls}
                  imageUrl={data.preview_url}
                  height="100%"
                  width="100%"
                />
              </div>
            </div>
          </Stack.Item>
          <Stack.Item>
            <Stack justify="center" mt={1}>
              <Stack.Item>
                <Button
                  icon="undo"
                  onClick={() => {
                    const nextDirection = rotatePreviewDirection(previewDirection, 1);
                    act('prime_preview_direction', {
                      direction: nextDirection,
                    });
                  }}
                >
                  Rotate Left
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="repeat"
                  onClick={() => {
                    const nextDirection = rotatePreviewDirection(previewDirection, -1);
                    act('prime_preview_direction', {
                      direction: nextDirection,
                    });
                  }}
                >
                  Rotate Right
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
