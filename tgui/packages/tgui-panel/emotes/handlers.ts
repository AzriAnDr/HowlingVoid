import { store } from '../events/store';
import { type EmoteInfo, emotesListAtom } from './atoms';

export function setEmotesList(
  payload: Record<string, EmoteInfo> | null,
): void {
  store.set(emotesListAtom, payload ?? {});
}
