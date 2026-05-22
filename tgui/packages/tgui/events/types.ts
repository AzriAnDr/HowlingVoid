import type { ExtractAtomValue } from 'jotai';
import type { sendAct } from './act';
import type { backendStateAtom } from './store';

type BinaryIO = 0 | 1;

type Client = {
  address: string;
  ckey: string;
  computer_id: string;
  interface_language?: string;
};

type IFace = {
  layout: string;
  name: string;
};

type TguiWindow = {
  backdrop?: string;
  backdrop_display_names?: Record<string, string>;
  backdrop_options?: string[];
  fancy: BinaryIO;
  key: string;
  locked: BinaryIO;
  scale: BinaryIO;
  size: [number, number];
  theme?: string;
  theme_display_names?: Record<string, string>;
  theme_options?: string[];
};

type User = {
  name: string;
  observer: number;
};

export type Config = {
  client: Client;
  interface: IFace;
  refreshing: BinaryIO;
  status: number;
  title: string;
  user: User;
  window: TguiWindow;
};

export type DebugState = {
  debugLayout: boolean;
  kitchenSink: boolean;
};

export type BackendState<TData> = ExtractAtomValue<typeof backendStateAtom> & {
  act: typeof sendAct;
  data: TData;
};
