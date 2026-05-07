import { atom } from 'jotai';

export type EmoteInfo = {
  name: string;
  message?: string;
  color?: string;
  effect?: string;
};

/** Keyed by emote key, value is the emote display info. */
export const emotesListAtom = atom<Record<string, EmoteInfo>>({});

/** Whether the emotes toolbar panel is visible. */
export const emotesVisibleAtom = atom<boolean>(false);
