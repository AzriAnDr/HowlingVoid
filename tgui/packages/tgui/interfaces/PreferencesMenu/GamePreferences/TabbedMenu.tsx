import { type ComponentProps, type ReactNode, useRef } from 'react';
import { Button, type Flex, Input, Section, Stack } from 'tgui-core/components';
import { usePreferencesLocalization } from '../localization';

type TabbedMenuProps = {
  categoryEntries: [string, ReactNode[]][];
  contentProps?: ComponentProps<typeof Flex>;
  searchText?: string;
  setSearchText?: (text: string) => void;
  interfaceLanguage?: 'english' | 'russian';
  className?: string;
};

export function TabbedMenu(props: TabbedMenuProps) {
  const sectionRef = useRef<HTMLDivElement>(null);
  const categoryRefs = useRef<Record<string, HTMLDivElement | null>>({});
  const { t } = usePreferencesLocalization();
  const translateCategory = (category: string) =>
    t(`ui.game.category.${category.toLowerCase()}`, category);

  const searchPlaceholder = t('ui.game.search_placeholder');

  return (
    <Stack
      className={`PreferencesMenu__GameTabbed${props.className ? ` ${props.className}` : ''}`}
      vertical
      fill
    >
      <Stack.Item>
        <Stack fill px={5}>
          {props.categoryEntries.map(([category, children]) => (
            <Stack.Item key={category} grow basis="content">
              <Button
                className="PreferencesMenu__GameTabbed__CategoryButton"
                align="center"
                fontSize="1.2em"
                fluid
                disabled={children.length === 0}
                onClick={() => {
                  const offsetTop = categoryRefs.current[category]?.offsetTop;
                  if (offsetTop === undefined) {
                    return;
                  }

                  const currentSection = sectionRef.current;
                  if (!currentSection) {
                    return;
                  }

                  currentSection.scrollTop = offsetTop;
                }}
              >
                {translateCategory(category)}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>

      {!!props.setSearchText && (
        <Stack.Item px={2} pl={5} pr={5}>
          <Input
            className="PreferencesMenu__GameTabbed__Search"
            fluid
            height="2em"
            fontSize="1.2em"
            placeholder={searchPlaceholder}
            value={props.searchText}
            onChange={props.setSearchText}
          />
        </Stack.Item>
      )}

      <Stack.Item
        className="PreferencesMenu__GameTabbed__Content"
        grow
        ref={sectionRef}
        position="relative"
        overflowY="scroll"
        {...props.contentProps}
      >
        <Stack vertical fill px={2}>
          {props.categoryEntries.map(([category, children]) => {
            if (children.length === 0) return null;
            return (
              <div
                key={category}
                ref={(ref) => {
                  categoryRefs.current[category] = ref;
                }}
              >
                <Section
                  className="PreferencesMenu__GameTabbed__Section"
                  fill
                  title={translateCategory(category)}
                >
                  {children}
                </Section>
              </div>
            );
          })}
        </Stack>
      </Stack.Item>
    </Stack>
  );
}



