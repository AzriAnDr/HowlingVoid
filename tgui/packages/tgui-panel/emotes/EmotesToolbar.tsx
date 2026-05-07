import { useAtomValue } from 'jotai';
import { useRef, useState } from 'react';
import { Button, Flex, Section } from 'tgui-core/components';
import { type EmoteInfo, emotesListAtom } from './atoms';

interface EmoteEntry {
  key: string;
  name: string;
  message?: string;
  color?: string;
  effect?: string;
}

const COOLDOWN_DURATION = 1000; // 1 second

export const EmotesToolbar = () => {
  const emotesList = useAtomValue(emotesListAtom);
  const [cooldowns, setCooldowns] = useState<Record<string, boolean>>({});
  const [draggedKey, setDraggedKey] = useState<string | null>(null);
  const [dragOverKey, setDragOverKey] = useState<string | null>(null);
  const dragStartPos = useRef<{ x: number; y: number } | null>(null);

  const emoteList: EmoteEntry[] = Object.entries(emotesList).map(
    ([key, info]: [string, EmoteInfo]) => ({
      key,
      name: String(info.name),
      message: info.message ? String(info.message) : undefined,
      color: info.color ? String(info.color) : undefined,
      effect: info.effect ? String(info.effect) : undefined,
    }),
  );

  if (!emoteList.length) {
    return (
      <Section>
        <Flex align="center">
          <Flex.Item mx={0.5} mt={1}>
            <Button
              icon="plus"
              color="green"
              tooltip="Add an emote to the panel"
              onClick={() => Byond.sendMessage('emotes/create')}
            />
          </Flex.Item>
        </Flex>
      </Section>
    );
  }

  const emoteCreate = () => Byond.sendMessage('emotes/create');

  const emoteExecute = (key: string) => {
    if (cooldowns[key]) return;

    Byond.sendMessage('emotes/execute', { key });

    setCooldowns((prev) => ({ ...prev, [key]: true }));
    setTimeout(() => {
      setCooldowns((prev) => ({ ...prev, [key]: false }));
    }, COOLDOWN_DURATION);
  };

  const emoteContextAction = (key: string) =>
    Byond.sendMessage('emotes/contextAction', { key });

  const handleDragStart = (e: React.DragEvent, key: string) => {
    setDraggedKey(key);
    dragStartPos.current = { x: e.clientX, y: e.clientY };
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', key);
  };

  const handleDragOver = (e: React.DragEvent, key: string) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    if (draggedKey && key !== draggedKey) {
      setDragOverKey(key);
    }
  };

  const handleDragLeave = () => {
    setDragOverKey(null);
  };

  const handleDrop = (e: React.DragEvent, targetKey: string) => {
    e.preventDefault();
    if (!draggedKey || draggedKey === targetKey) {
      setDraggedKey(null);
      setDragOverKey(null);
      return;
    }

    const currentOrder = emoteList.map((emote) => emote.key);
    const draggedIndex = currentOrder.indexOf(draggedKey);
    const targetIndex = currentOrder.indexOf(targetKey);

    if (draggedIndex === -1 || targetIndex === -1) {
      setDraggedKey(null);
      setDragOverKey(null);
      return;
    }

    const newOrder = [...currentOrder];
    newOrder.splice(draggedIndex, 1);
    newOrder.splice(targetIndex, 0, draggedKey);

    Byond.sendMessage('emotes/reorder', { order: newOrder });

    setDraggedKey(null);
    setDragOverKey(null);
  };

  const handleDragEnd = () => {
    setDraggedKey(null);
    setDragOverKey(null);
    dragStartPos.current = null;
  };

  return (
    <Section>
      <Flex align="center" style={{ flexWrap: 'wrap' }}>
        {emoteList.map((emote) => (
          <Flex.Item mx={0.5} mt={1} key={emote.key}>
            <div
              draggable
              onDragStart={(e) => handleDragStart(e, emote.key)}
              onDragOver={(e) => handleDragOver(e, emote.key)}
              onDragLeave={handleDragLeave}
              onDrop={(e) => handleDrop(e, emote.key)}
              onDragEnd={handleDragEnd}
              style={{
                opacity: draggedKey === emote.key ? 0.5 : 1,
                transform:
                  dragOverKey === emote.key ? 'translateX(4px)' : undefined,
                transition: 'transform 0.15s ease, opacity 0.15s ease',
                cursor: 'grab',
              }}
            >
              <Button
                content={emote.name}
                onClick={() => emoteExecute(emote.key)}
                onContextMenu={(e) => {
                  e.preventDefault();
                  emoteContextAction(emote.key);
                }}
                tooltip={(() => {
                  const lines = [
                    emote.message
                      ? `[${emote.key}] ${emote.message}`
                      : `*${emote.key}`,
                  ];
                  if (emote.effect) lines.push(`Effect: *${emote.effect}`);
                  lines.push('(Drag to reorder, right-click for options)');
                  return lines.join('\n');
                })()}
                disabled={cooldowns[emote.key]}
                style={{
                  backgroundColor: emote.color || undefined,
                  borderLeft:
                    dragOverKey === emote.key
                      ? '2px solid #4af'
                      : '2px solid transparent',
                }}
              />
            </div>
          </Flex.Item>
        ))}
        <Flex.Item mx={0.5} mt={1}>
          <Button
            icon="plus"
            color="green"
            tooltip="Add an emote to the panel"
            onClick={() => emoteCreate()}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};
