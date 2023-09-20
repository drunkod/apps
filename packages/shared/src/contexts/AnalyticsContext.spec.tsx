import React, { ReactElement, ReactNode, useContext, useEffect } from 'react';
import nock from 'nock';
import { fireEvent, render, waitFor } from '@testing-library/preact';
import { QueryClient } from 'react-query';
import AnalyticsContext, { AnalyticsContextProvider } from './AnalyticsContext';
import { AnalyticsContextData } from '../hooks/analytics/useAnalyticsContextData';
import { SettingsContextData } from './SettingsContext';
import { AuthContextData } from './AuthContext';
import { AnonymousUser } from '../lib/user';
import { AnalyticsEvent } from '../hooks/analytics/useAnalyticsQueue';
import { BootApp, Visit } from '../lib/boot';
import { waitForNock } from '../../__tests__/helpers/utilities';
import { TestBootProvider } from '../../__tests__/helpers/boot';

let queryClient: QueryClient;
const getPage = jest.fn();

beforeEach(() => {
  jest.restoreAllMocks();
  jest.clearAllMocks();
  nock.cleanAll();
  queryClient = new QueryClient();
});

const settings: SettingsContextData = {
  spaciness: 'roomy',
  loadedSettings: true,
  setTheme: jest.fn(),
  themeMode: 'light',
  insaneMode: true,
  showTopSites: true,
  toggleInsaneMode: jest.fn(),
  openNewTab: true,
  setSpaciness: jest.fn(),
  toggleOpenNewTab: jest.fn(),
  toggleShowTopSites: jest.fn(),
};

const AnalyticsContextTester = ({
  callback,
}: {
  callback: (contextData: AnalyticsContextData) => unknown;
}): ReactElement => {
  const contextData = useContext(AnalyticsContext);

  useEffect(() => {
    callback(contextData);
    // @NOTE see https://dailydotdev.atlassian.net/l/cp/dK9h1zoM
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return <></>;
};

const TestComponent = ({
  children,
  authContext,
}: {
  children: ReactNode;
  authContext: Pick<
    AuthContextData,
    'user' | 'anonymous' | 'tokenRefreshed' | 'visit'
  >;
}): ReactElement => (
  <TestBootProvider
    client={queryClient}
    settings={settings}
    auth={{
      shouldShowLogin: false,
      showLogin: jest.fn(),
      logout: jest.fn(),
      updateUser: jest.fn(),
      getRedirectUri: jest.fn(),
      closeLogin: jest.fn(),
      trackingId: authContext.user?.id || authContext.anonymous?.id,
      ...authContext,
    }}
  >
    <AnalyticsContextProvider
      app={BootApp.Test}
      getPage={getPage}
      deviceId="123"
    >
      {children}
    </AnalyticsContextProvider>
  </TestBootProvider>
);

const baseAnonymous: AnonymousUser = {
  id: 'u',
  referrer: 'ido',
  firstVisit: new Date(Date.UTC(2021, 7, 28)).toISOString(),
};

const baseVisit: Visit = {
  visitId: 'v',
  sessionId: 's',
};

const mockEventsEndpoint = (takeSnapshot = true) => {
  nock('http://localhost:3000')
    .post('/e', (body: { events: AnalyticsEvent[] }) => {
      if (takeSnapshot) {
        // Reset time based properties
        expect(
          body.events.map((event) => {
            expect(event.event_id).toBeDefined();
            expect(event.event_timestamp).toBeDefined();
            expect(event.device_id).toBeDefined();
            return {
              ...event,
              event_id: '',
              event_timestamp: '',
              device_id: '',
            };
          }),
        ).toMatchSnapshot();
      }
      return true;
    })
    .reply(200, 'OK');
};

it('should batch events before sending', async () => {
  mockEventsEndpoint();
  const callback = ({ trackEvent }: AnalyticsContextData) => {
    trackEvent({ event_name: 'e1' });
    trackEvent({ event_name: 'e2' });
  };

  render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        tokenRefreshed: true,
        visit: baseVisit,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitForNock();
});

it('should add relevant properties when user is signed-in', async () => {
  mockEventsEndpoint();
  const callback = ({ trackEvent }: AnalyticsContextData) => {
    trackEvent({ event_name: 'e1' });
  };
  render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        visit: baseVisit,
        user: {
          id: 'u',
          createdAt: new Date(Date.UTC(2021, 7, 29)).toISOString(),
          email: 'u@a.com',
          image: 'https://image.com',
          name: 'U',
          providers: ['github'],
        },
        tokenRefreshed: true,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitForNock();
});

it('should send events in different batches', async () => {
  let done = false;
  const callback = async ({ trackEvent }: AnalyticsContextData) => {
    mockEventsEndpoint();
    trackEvent({ event_name: 'e1' });
    await new Promise((resolve) => setTimeout(resolve, 600));
    mockEventsEndpoint();
    trackEvent({ event_name: 'e2' });
    done = true;
  };

  render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        tokenRefreshed: true,
        visit: baseVisit,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitFor(() => expect(done).toBeTruthy());
  await waitForNock();
});

it('should send event with duration', async () => {
  nock('http://localhost:3000')
    .post('/e', (body: { events: AnalyticsEvent[] }) => {
      expect(body.events[0].event_duration).toBeTruthy();
      return true;
    })
    .reply(200, 'OK');

  const callback = async ({
    trackEventStart,
    trackEventEnd,
  }: AnalyticsContextData) => {
    trackEventStart('event', { event_name: 'e1' });
    await new Promise((resolve) => setTimeout(resolve, 10));
    trackEventEnd('event');
  };

  render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        tokenRefreshed: true,
        visit: baseVisit,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitForNock();
});

it('should send pending events when page becomes invisible', async () => {
  window.navigator.sendBeacon = jest.fn();

  const callback = async ({ trackEventStart }: AnalyticsContextData) => {
    trackEventStart('event', { event_name: 'e1' });
    await new Promise((resolve) => setTimeout(resolve, 10));
    fireEvent(
      window,
      new CustomEvent('statechange', {
        bubbles: true,
        detail: {
          oldState: 'active',
          newState: 'hidden',
        },
      }),
    );
  };

  render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        tokenRefreshed: true,
        visit: baseVisit,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitFor(() => expect(window.navigator.sendBeacon).toBeCalledTimes(1));
});

it('should send pending events when user information is fetched', async () => {
  let done = false;
  const callback = async ({ trackEvent }: AnalyticsContextData) => {
    trackEvent({ event_name: 'e1' });
    // Wait for debounce to finish
    await new Promise((resolve) => setTimeout(resolve, 100));
    done = true;
  };

  const { rerender } = render(
    <TestComponent
      authContext={{
        anonymous: baseAnonymous,
        tokenRefreshed: false,
        visit: baseVisit,
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitFor(() => expect(done).toBeTruthy());
  mockEventsEndpoint();
  rerender(
    <TestComponent
      authContext={{
        anonymous: {
          ...baseAnonymous,
          id: 'u2',
        },
        tokenRefreshed: true,
        visit: {
          sessionId: 's2',
          visitId: 'v2',
        },
      }}
    >
      <AnalyticsContextTester callback={callback} />
    </TestComponent>,
  );
  await waitForNock();
});
