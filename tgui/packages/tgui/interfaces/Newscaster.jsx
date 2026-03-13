/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @author Changes Shadowh4nD/jlsnow301
 * @license MIT
 */

import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Image,
  LabeledList,
  Modal,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { usePreferencesLocalization } from './localization';
import { processedText } from '../process';
import { BountyBoardContent } from './BountyBoard';
import { LoadingScreen } from './common/LoadingScreen';
import { UserDetails } from './Vending';

const CENSOR_MESSAGE =
  'This channel has been deemed as threatening to \
  the welfare of the station, and marked with a Nanotrasen D-Notice.';

export const Newscaster = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const NEWSCASTER_SCREEN = 1;
  const BOUNTYBOARD_SCREEN = 2;
  const [screenmode, setScreenmode] = useSharedState(
    'tab_main',
    NEWSCASTER_SCREEN,
  );

  return (
    <>
      <NewscasterChannelCreation />
      <NewscasterCommentCreation />
      <Stack fill vertical>
        <NewscasterWantedScreen />
        <Stack.Item>
          <Tabs fluid textAlign="center">
            <Tabs.Tab
              color="Green"
              selected={screenmode === NEWSCASTER_SCREEN}
              onClick={() => setScreenmode(NEWSCASTER_SCREEN)}
            >
              {t('ui.newscaster.title')}
            </Tabs.Tab>
            <Tabs.Tab
              Color="Blue"
              selected={screenmode === BOUNTYBOARD_SCREEN}
              onClick={() => setScreenmode(BOUNTYBOARD_SCREEN)}
            >
              {t('ui.newscaster.bounty_board')}
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item grow>
          {screenmode === NEWSCASTER_SCREEN && <NewscasterContent />}
          {screenmode === BOUNTYBOARD_SCREEN && <BountyBoardContent />}
        </Stack.Item>
      </Stack>
    </>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterChannelCreation = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const [lockedmode, setLockedmode] = useState(true);
  const [cross_sector, setcross_sector] = useState(false);
  const { creating_channel, awaiting_approval, name, desc } = data;

  if (awaiting_approval) {
    return (
      <LoadingScreen label={t('ui.newscaster.awaiting_central_command_approval')} />
    );
  }

  if (!creating_channel) {
    return null;
  }

  return (
    <Modal textAlign="center" mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            {t('ui.newscaster.enter_channel_name_here')}
            <Button
              color="red"
              icon="times"
              position="relative"
              top="20%"
              left="15%"
              onClick={() => act('cancelCreation')}
            />
          </Box>
          <TextArea
            height="40px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={42}
            onBlur={(value) =>
              act('setChannelName', {
                channeltext: value,
              })
            }
          >
            {t('ui.newscaster.channel_name')}
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box pb={1}>{t('ui.newscaster.enter_channel_description_here')}</Box>
          <TextArea
            height="150px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onBlur={(value) =>
              act('setChannelDesc', {
                channeldesc: value,
              })
            }
          >
            {t('ui.newscaster.channel_description')}
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Section>
            {t('ui.newscaster.set_channel_public_or_private')}
            <Box pt={1}>
              <Button
                selected={!lockedmode}
                disabled={cross_sector}
                onClick={() => setLockedmode(false)}
              >
                {t('ui.common.public')}
              </Button>
              <Button
                selected={!!lockedmode}
                disabled={cross_sector}
                onClick={() => setLockedmode(true)}
              >
                {t('ui.common.private')}
              </Button>
            </Box>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={cross_sector}
            onClick={() => {
              setcross_sector(!cross_sector);
              setLockedmode(true);
            }}
            tooltip={t('ui.newscaster.cross_sector_requires_approval')}
            tooltipPosition="bottom-start"
          >
            {t('ui.newscaster.make_cross_sector')}
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              onClick={() =>
                act('createChannel', {
                  cross_sector: cross_sector,
                  lockedmode: lockedmode,
                })
              }
            >
              {t('ui.newscaster.submit_channel')}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

/** The modal menu that contains the prompts to making new comments. */
const NewscasterCommentCreation = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { creating_comment, viewing_message } = data;
  if (!creating_comment) {
    return null;
  }
  return (
    <Modal textAlign="center" mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            {t('ui.newscaster.enter_comment')}
            <Button
              color="red"
              position="relative"
              icon="times"
              top="20%"
              left="25%"
              onClick={() => act('cancelCreation')}
            />
          </Box>
          <TextArea
            height="120px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onBlur={(value) =>
              act('setCommentBody', {
                commenttext: value,
              })
            }
          >
            {t('ui.newscaster.channel_name')}
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              onClick={() =>
                act('createComment', {
                  messageID: viewing_message,
                })
              }
            >
              {t('ui.newscaster.submit_comment')}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const NewscasterWantedScreen = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    viewing_wanted,
    photo_data,
    security_mode,
    wanted = [],
    criminal_name,
    crime_description,
  } = data;
  if (!viewing_wanted) {
    return null;
  }
  return (
    <Modal textAlign="center" mr={1} width={25}>
      {wanted.map((activeWanted) => (
        <>
          <Stack vertical>
            <Stack.Item>
              <Box bold color="red">
                {activeWanted.active
                  ? t('ui.newscaster.active_wanted_issue')
                  : t('ui.newscaster.dismissed_wanted_issue')}
                <Button
                  color="red"
                  position="relative"
                  icon="times"
                  top="20%"
                  left="15%"
                  onClick={() => act('cancelCreation')}
                />
              </Box>
              {!!activeWanted.criminal && (
                <>
                  <Section>
                    <Box bold>{activeWanted.criminal}</Box>
                    <Box italic>{activeWanted.crime}</Box>
                  </Section>
                  <Image src={activeWanted.image ? activeWanted.image : null} />
                  <Box italic>
                    Posted by{' '}
                    {activeWanted.author
                      ? activeWanted.author
                      : t('ui.common.not_available')}
                  </Box>
                </>
              )}
            </Stack.Item>
          </Stack>
          <Divider />
        </>
      ))}
      {security_mode ? (
        <>
          <LabeledList>
            <LabeledList.Item label={t('ui.newscaster.criminal_name')}>
              <Button
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCriminalName')}
              >
                {criminal_name ? criminal_name : ` ${t('ui.common.not_available')}`}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={t('ui.newscaster.criminal_activity')}>
              <Button
                nowrap={false}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCrimeData')}
              >
                {crime_description
                  ? crime_description
                  : ` ${t('ui.common.not_available')}`}
              </Button>
            </LabeledList.Item>
          </LabeledList>
          <Section>
            <Button
              icon="camera"
              selected={photo_data}
              disabled={!security_mode}
              onClick={() => act('togglePhoto')}
            >
              {photo_data
                ? t('ui.newscaster.remove_photo')
                : t('ui.newscaster.attach_photo')}
            </Button>
            <Button
              disabled={!security_mode}
              icon="volume-up"
              onClick={() => act('submitWantedIssue')}
            >
              {t('ui.newscaster.set_wanted_issue')}
            </Button>
            <Button
              disabled={!security_mode}
              icon="times"
              color="red"
              onClick={() => act('clearWantedIssue')}
            >
              {t('ui.newscaster.clear_wanted')}
            </Button>
          </Section>
        </>
      ) : (
        <Box>
          {wanted.map((activeWanted) =>
            activeWanted.active
              ? t('ui.newscaster.contact_security_if_spotted')
              : t('ui.newscaster.no_wanted_issue_posted'),
          )}
        </Box>
      )}
    </Modal>
  );
};

const NewscasterContent = (props) => {
  const { data } = useBackend();
  const { current_channel = {} } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <NewscasterChannelSelector />
          </Stack.Item>
          <Stack.Item grow={2}>
            <Stack fill vertical>
              <Stack.Item>
                <UserDetails />
              </Stack.Item>
              <Stack.Item grow>
                <NewscasterChannelBox
                  channelName={current_channel.name}
                  channelOwner={current_channel.owner}
                  channelDesc={current_channel.desc}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <NewscasterChannelMessages />
      </Stack.Item>
    </Stack>
  );
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    channelName,
    channelDesc,
    channelLocked,
    channelAuthor,
    channelCensored,
    receivingCrossSector,
    viewing_channel,
    admin_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section fill title={channelName}>
      <Stack fill vertical>
        <Stack.Item grow>
          {channelCensored ? (
            <Section>
              <BlockQuote color="red">
                <b>{t('ui.common.attention')}:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>
          ) : (
            <Section fill scrollable>
              <BlockQuote italic fontSize={1.2} wrap>
                {decodeHtmlEntities(channelDesc)}
              </BlockQuote>
            </Section>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              disabled={
                (channelLocked && channelAuthor !== user.name) ||
                channelCensored ||
                receivingCrossSector
              }
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1}
            >
              {t('ui.newscaster.submit_story')}
            </Button>
            <Button
              icon="camera"
              selected={photo_data}
              disabled={
                (channelLocked && channelAuthor !== user.name) ||
                channelCensored ||
                receivingCrossSector
              }
              onClick={() => act('togglePhoto')}
            >
              {t('ui.newscaster.select_photo')}
            </Button>
            {!!admin_mode && (
              <Button
                icon="ban"
                tooltip={t('ui.newscaster.censor_whole_channel_tooltip')}
                disabled={!admin_mode || !viewing_channel}
                onClick={() =>
                  act('channelDNotice', {
                    secure: admin_mode,
                    channel: viewing_channel,
                  })
                }
              >
                {t('ui.newscaster.d_notice')}
              </Button>
            )}
          </Box>
          <Box>
            <Button
              icon="newspaper"
              tooltip={paper <= 0 ? t('ui.newscaster.insert_paper_first') : ''}
              disabled={paper <= 0}
              onClick={() => act('printNewspaper')}
            >
              {t('ui.newscaster.print_newspaper')}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const { channels = [], viewing_channel, wanted = [] } = data;
  return (
    <Section minHeight="100%" width={`${window.innerWidth - 410}px`}>
      <Tabs vertical>
        {wanted.map((activeWanted) => (
          <Tabs.Tab
            pt={0.75}
            pb={0.75}
            mr={1}
            key={activeWanted.index}
            icon={activeWanted.active ? 'skull-crossbones' : null}
            textColor={activeWanted.active ? 'red' : 'grey'}
            onClick={() => act('toggleWanted')}
          >
            {t('ui.newscaster.wanted_issue')}
          </Tabs.Tab>
        ))}
        {channels.map((channel) => (
          <Tabs.Tab
            key={channel.index}
            pt={0.75}
            pb={0.75}
            mr={1}
            selected={viewing_channel === channel.ID}
            icon={channel.censored ? 'ban' : null}
            textColor={channel.censored ? 'red' : 'white'}
            onClick={() =>
              act('setChannel', {
                channel: channel.ID,
              })
            }
          >
            {channel.name}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          pt={0.75}
          pb={0.75}
          mr={1}
          textColor="white"
          color="Green"
          onClick={() => act('startCreateChannel')}
        >
          {t('ui.newscaster.create_channel')}
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (props) => {
  const { act, data } = useBackend();
  const { t } = usePreferencesLocalization(data);
  const {
    messages = [],
    viewing_channel,
    admin_mode,
    channelCensored,
    receivingCrossSector,
    channelLocked,
    channelAuthor,
    user,
  } = data;
  if (channelCensored) {
    return (
      <Section color="red">
        <b>{t('ui.common.attention')}:</b> {t('ui.newscaster.comments_cannot_be_read')}
        <br />
        {t('ui.newscaster.have_a_secure_day')}
      </Section>
    );
  }
  const visibleMessages = messages.filter(
    (message) => message.ID !== viewing_channel,
  );
  return (
    <Section>
      {visibleMessages.map((message) => {
        return (
          <Section
            key={message.index}
            textColor="white"
            title={
              <i>
                {message.censored_author ? (
                  <Box textColor="red">
                    {t('ui.newscaster.by_redacted')} <b>{t('ui.newscaster.d_notice_notice')}</b>.
                  </Box>
                ) : (
                  <>
                    {`${t('ui.newscaster.by')} ${message.auth} ${t('ui.newscaster.at')} ${message.time}`}
                  </>
                )}
              </i>
            }
            buttons={
              <>
                {!!admin_mode && (
                  <Button
                    icon="comment-slash"
                    tooltip={t('ui.newscaster.censor_story')}
                    disabled={!admin_mode}
                    onClick={() =>
                      act('storyCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                {!!admin_mode && (
                  <Button
                    icon="user-slash"
                    tooltip={t('ui.newscaster.censor_author')}
                    disabled={!admin_mode}
                    onClick={() =>
                      act('authorCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                <Button
                  icon="comment"
                  tooltip={t('ui.newscaster.leave_a_comment')}
                  disabled={
                    message.censored_author ||
                    message.censored_message ||
                    user.name === 'Unknown' ||
                    (!!channelLocked && channelAuthor !== user.name)
                  }
                  onClick={() =>
                    act('startComment', {
                      messageID: message.ID,
                    })
                  }
                />
              </>
            }
          >
            <BlockQuote>
              {message.censored_message ? (
                <Section textColor="red">
                  {t('ui.newscaster.message_deemed_dangerous')}{' '}
                  <b>{t('ui.newscaster.d_notice')}</b>.
                </Section>
              ) : (
                <Section pl={1}>
                  <Box dangerouslySetInnerHTML={processedText(message.body)} />
                </Section>
              )}
              {message.photo !== null && !message.censored_message && (
                <Image src={message.photo} />
              )}
              {!!message.comments && (
                <Box>
                  {message.comments.map((comment) => (
                    <BlockQuote key={comment.index}>
                      <Box italic textColor="white">
                        {`${t('ui.newscaster.by')} ${comment.auth} ${t('ui.newscaster.at')} ${comment.time}`}
                      </Box>
                      <Section ml={2.5}>
                        <Box
                          dangerouslySetInnerHTML={processedText(comment.body)}
                        />
                      </Section>
                    </BlockQuote>
                  ))}
                </Box>
              )}
            </BlockQuote>
            <Divider />
          </Section>
        );
      })}
    </Section>
  );
};
