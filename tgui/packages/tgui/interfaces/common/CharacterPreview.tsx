import { ByondUi } from 'tgui-core/components';

export const CharacterPreview = (props: {
  width?: string;
  height: string;
  id: string | null;
}) => {
  const { width = '272px' } = props;
  return (
    <ByondUi
      width={width}
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
