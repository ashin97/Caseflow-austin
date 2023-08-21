const fs = require('fs');
const faker = require('faker');

const generateConferenceLinks = () => {
  let webexLinks = [];

  for (let id = 1; id <= 10; id++) {
    webexLinks.push({
      id: faker.random.uuid(),
      meetingNumber: faker.random.number(),
      title: faker.company.catchPhrase(),
      password: faker.internet.password(),
      meetingType: 'meetingSeries',
      state: 'active',
      timezone: 'Asia/Shanghai',
      start: '2023-11-01T20:00:00+08:00',
      end: '2023-11-01T21:00:00+08:00',
      hostUserId: faker.finance.account(),
      hostDisplayName: faker.name.findName(),
      hostEmail: faker.internet.email(),
      hostKey: faker.random.number(),
      siteUrl: 'ciscofedsales.webex.com',
      webLink: faker.internet.url(),
      sipAddress: faker.internet.email(),
      dialInIpAddress: faker.internet.ip(),
      enabledAutoRecordMeeting: faker.random.boolean(),
      allowAnyUserToBeCoHost: faker.random.boolean(),
      allowFirstUserToBeCoHost: faker.random.boolean(),
      allowAuthenticatedDevices: faker.random.boolean(),
      enabledJoinBeforeHost: faker.random.boolean(),
      joinBeforeHostMinutes: faker.random.number({ min: 0, max: 10 }),
      enableConnectAudioBeforeHost: faker.random.boolean(),
      excludePassword: faker.random.boolean(),
      publicMeeting: faker.random.boolean(),
      enableAutomaticLock: faker.random.boolean(),
      automaticLockMinutes: faker.random.number({ min: 1, max: 10 }),
      unlockedMeetingJoinSecurity: 'allowJoinWithLobby',
      telephony: {
        accessCode: faker.random.number({ min: 100000, max: 999999 }).toString(),
        callInNumbers: [
          {
            label: 'United States Toll',
            callInNumber: '+1-415-527-5035',
            tollType: 'toll',
          },
          {
            label: 'United States Toll (Washington D.C.)',
            callInNumber: '+1-202-600-2533',
            tollType: 'toll',
          },
        ],
        links: [
          {
            rel: 'globalCallinNumbers',
            href:
              `/v1/meetings/${faker.random.uuid()}/globalCallinNumbers`,
            method: 'GET',
          },
        ],
      },
      meetingOptions: {
        enabledChat: faker.random.boolean(),
        enabledVideo: faker.random.boolean(),
        enabledNote: faker.random.boolean(),
        noteType: 'allowAll',
        enabledFileTransfer: faker.random.boolean(),
        enabledUCFRichMedia: faker.random.boolean(),
      },
      attendeePrivileges: {
        enabledShareContent: faker.random.boolean(),
        enabledSaveDocument: faker.random.boolean(),
        enabledPrintDocument: faker.random.boolean(),
        enabledAnnotate: faker.random.boolean(),
        enabledViewParticipantList: faker.random.boolean(),
        enabledViewThumbnails: faker.random.boolean(),
        enabledRemoteControl: faker.random.boolean(),
        enabledViewAnyDocument: faker.random.boolean(),
        enabledViewAnyPage: faker.random.boolean(),
        enabledContactOperatorPrivately: faker.random.boolean(),
        enabledChatHost: faker.random.boolean(),
        enabledChatPresenter: faker.random.boolean(),
        enabledChatOtherParticipants: faker.random.boolean(),
      },
      sessionTypeId: faker.random.number({ min: 1, max: 5 }),
      scheduledType: 'meeting',
      simultaneousInterpretation: {
        enabled: faker.random.boolean(),
      },
      enabledBreakoutSessions: faker.random.boolean(),
      audioConnectionOptions: {
        audioConnectionType: 'webexAudio',
        enabledTollFreeCallIn: faker.random.boolean(),
        enabledGlobalCallIn: faker.random.boolean(),
        enabledAudienceCallBack: faker.random.boolean(),
        entryAndExitTone: 'beep',
        allowHostToUnmuteParticipants: faker.random.boolean(),
        allowAttendeeToUnmuteSelf: faker.random.boolean(),
        muteAttendeeUponEntry: faker.random.boolean(),
      },
    });
  }

  return webexLinks;
};

// Generate the data
const data = {
  conferenceLinks: generateConferenceLinks(),
  // ... other data models
};

// Check if the script is being run directly
if (require.main === module) {
  fs.writeFileSync('mocks/webex-mocks/webex-mock.json', JSON.stringify(data, null, 2));
  // eslint-disable-next-line no-console
  console.log('Generated new data in webex-mock.json');
}

