import { createDropdownInput, type Feature } from '../../base';

export const interface_language: Feature<string> = {
  name: 'Interface Language',
  category: 'LANGUAGE',
  component: createDropdownInput({
    english: 'English',
    russian: 'Russian',
  }),
};
