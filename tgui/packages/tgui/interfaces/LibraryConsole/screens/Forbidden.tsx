import { useBackend } from 'tgui/backend';
import { Box, Button, Modal, Stack } from 'tgui-core/components';
import { usePreferencesLocalization } from '../../localization';

const description =
  'Abf vqrnz cebprffhf pbzchgngvbanyvf fghqrer vapvcvrzhf\nCebprffhf pbzchgngvbanyrf fhag erf nofgenpgnr dhnr pbzchgngberf vapbyhag\nHg ribyihag, cebprffhf nyvn nofgenpgn dhnr qngn znavchyner qvphaghe\nRibyhgvbavf cebprffhf qvevtvghe cre rkrzcyhz erthynr cebtenzzngvf ibpngv\nUbzvarf cebtenzzngn nq cebprffhf erpgbf rssvpvhag\nEriren fcvevghf pbzchgngbevv phz vapnagnzragvf pbavhatvzhf\nCebprffhf pbzchgngvbanyvf rfg zhyghz fvzvyvf vqrnr irarsvpnr fcvevghf\nivqrev nhg gnatv aba cbgrfg\nAba rfg rk zngrevn pbzcbfvgn\nFrq vq cynpreng vcfhz\nAba cbgrfg bcrenev bchf vagryyrpghnyr\nErfcbaqrev cbgrfg\nZhaqhz nssvprer cbgrfg rebtnaqb crphavnz nq evcnz iry cre oenppuvhz \nebobgv snoevpnaqb zbqrenaqb\nPbafvyvvf hgvzhe cebprffvohf nhthenaqv fhag fvphg vapnagnzragn irarsvpvv';

export function Forbidden(props) {
  usePreferencesLocalization();
  return (
    <Box className="LibraryComputer__CultNonsense" preserveWhitespace>
      {description}
      <ForbiddenModal />
    </Box>
  );
}

function ForbiddenModal(props) {
  const { act } = useBackend();
  const { t } = usePreferencesLocalization();

  return (
    <Modal>
      <Box className="LibraryComputer__CultText" fontSize="28px">
        {t('ui.library.accessing_forbidden_lore_vault')}
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.4}>
        {t('ui.library.confirm_forbidden_lore')}
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.2} bold>
        {t('ui.library.forbidden_lore_disclaimer')}
      </Box>
      <Stack justify="center" align="center">
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="check"
            color="good"
            fontSize="20px"
            onClick={() => act('lore_spawn')}
            lineHeight={2}
          >
            {t('ui.library.assent')}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="times"
            color="bad"
            fontSize="20px"
            onClick={() => act('lore_deny')}
            lineHeight={2}
          >
            {t('ui.common.decline')}
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
