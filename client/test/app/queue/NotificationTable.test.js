import React from 'react';
import { render, screen } from '@testing-library/react';
import { axe } from 'jest-axe';
import ApiUtil from '../../../app/util/ApiUtil';
import NotificationTable from '../../../app/queue/components/NotificationTable';
import { notifications } from '../../data/notifications';

const createSpyGet = (data) => {
  return jest.spyOn(ApiUtil, 'get').
    mockImplementation(() => new Promise((resolve) => resolve({ body: data })));
};

const setup = () => {
  const props = {
    appealId: 'e1bdff31-4268-4fd4-a157-ebbd48013d91'
  };

  return render(
    <NotificationTable {...props} />
  );
};

beforeEach(() => {
  createSpyGet(notifications);
});

afterEach(() => {
  jest.clearAllMocks();
});

describe('NotificationTable', () => {
  it('first event row should be the earliest notification sent', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[0].textContent).toBe('Appeal decision mailed (Non-contested claims)');
  });

  it('first notification date row should be the earliest date', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[1].textContent).toBe('10/27/2022');
  });

  it('last notification date row should be the latest date of the first page of records', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[85].textContent).toBe('11/01/2022');
  });

  it('first notification type row should be email type', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[2].textContent).toBe('Email');
  });

  it('second notification type row should be text type', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[8].textContent).toBe('Text');
  });

  it('first recipient information row should be a dashed line', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[3].textContent).toBe('—');
  });

  it('second recipient information row should be a phone number', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[9].textContent).toBe('2468012345');
  });

  it('Sent status row should show Pending Delivery', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[4].textContent).toBe('Pending Delivery');
  });

  it('Delivered status row should show delivered', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[10].textContent).toBe('Delivered');
  });

  it('Temporary Failure status row should show pending delivery', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[16].textContent).toBe('Pending Delivery');
  });

  it('Permanent Failure status row should show failed delivery', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[22].textContent).toBe('Failed Delivery');
  });

  it('Technical Failure status row should show failed delivery', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[28].textContent).toBe('Failed Delivery');
  });

  it('Preferences Declined status row should show opted out', async () => {
    setup();
    const cell = await screen.findAllByRole('gridcell');

    expect(cell[40].textContent).toBe('Opted-out');
  });

  it('matches snapshot', () => {
    const { container } = setup();

    expect(container).toMatchSnapshot();
  });

  it('Virtual passes ally testing', async () => {
    const { container } = setup();
    const results = await axe(container);

    expect(results).toHaveNoViolations();
  });
});
