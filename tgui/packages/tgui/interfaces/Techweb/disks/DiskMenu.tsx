import { Button, Flex, Tabs } from 'tgui-core/components';

import { usePreferencesLocalization } from '../../localization';
import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import { TechwebDesignDisk, TechwebTechDisk } from './disks';

type Props = {
  diskType: string;
};

export function TechwebDiskMenu(props: Props) {
  const { act, data } = useRemappedBackend();
  const { t } = usePreferencesLocalization(data, 'rnd');
  const { diskType } = props;
  const { t_disk, d_disk } = data;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  // Check for the disk actually being inserted
  if ((diskType === 'design' && !d_disk) || (diskType === 'tech' && !t_disk)) {
    return null;
  }

  const DiskContent =
    (diskType === 'design' && TechwebDesignDisk) || TechwebTechDisk;

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {diskType === 'tech'
              ? t('ui.techweb.tech_disk', 'Tech Disk')
              : t('ui.techweb.design_disk', 'Design Disk')}
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab selected>{t('ui.techweb.stored_data')}</Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            {diskType === 'tech' && (
              <Button icon="save" onClick={() => act('loadTech')}>
                {t('ui.techweb.web_to_disk')}
              </Button>
            )}
            <Button
              icon="upload"
              onClick={() => act('uploadDisk', { type: diskType })}
            >
              {t('ui.techweb.disk_to_web')}
            </Button>
            <Button
              icon="eject"
              onClick={() => {
                act('ejectDisk', { type: diskType });
                setTechwebRoute({ route: '' });
              }}
            >
              {t('ui.common.eject')}
            </Button>
            <Button icon="home" onClick={() => setTechwebRoute({ route: '' })}>
              {t('ui.common.home')}
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow className="Techweb__OverviewNodes">
        <DiskContent />
      </Flex.Item>
    </Flex>
  );
}
