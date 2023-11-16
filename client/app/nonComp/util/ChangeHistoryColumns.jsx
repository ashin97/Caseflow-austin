
import PropTypes from 'prop-types';
import * as React from 'react';
import moment from 'moment';
import { capitalize, startCase } from 'lodash';
import BENEFIT_TYPES from 'constants/BENEFIT_TYPES';

const detailKeys = ['benefitType', 'issueType', 'issueDescription', 'decisionDate'];

const DetailsList = ({ event }) => {

  const formatValue = (key, value) => {
    if (key === 'decisionDate') {
      return moment(value).utc().
        format('MM/DD/YY');
    }

    if (key === 'benefitType') {
      return BENEFIT_TYPES[value] || value;
    }

    return value;
  };

  const listStyle = {
    display: 'block',
    lineHeight: 1
    // marginBottom: '10px'
  };

  const detailsObject = Object.entries(event).
    filter(([key]) => detailKeys.includes(key)).
    reduce((obj, [key, value]) => {
      obj[key] = value;

      return obj;
    }, {});

  console.log(detailsObject);

  // This currently relies on the object.entries remaining in the same order which is not ideal
  // Could probably map into the object based on a keys array instead

  // Object.entries(event.details).slice(0, 3).
  return (
    <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
      {Object.entries(detailsObject).
        map(([key, value]) => (
          <li key={key} style={listStyle}>
            <strong>{capitalize(startCase(key))}:</strong> {formatValue(key, value)}
          </li>
        ))}
      {event.eventType === 'Withdrew Issue' && (
        <li key="withdrawnDate" style={listStyle}>
          <strong>Withdrawl request date:</strong> {moment(event.details.withdrawlRequestDate).utc().
            format('MM/DD/YY')}
        </li>
      )}
      {event.eventType === 'Removed Issue' && (
        <li key="removedDate" style={listStyle}>
          <strong>Removed request date:</strong> {moment(event.details.withdrawlRequestDate).utc().
            format('MM/DD/YY')}
        </li>
      )}
      {event.eventType === 'Completed Disposition' && (
        <>
          <li key="disposition" style={listStyle}>
            <strong>Disposition:</strong> {event.details.disposition}
          </li>
          <li key="decisionDescription" style={listStyle}>
            <strong>Decision description:</strong> {event.details.decisionDescription}
          </li>
        </>
      )}
    </ul>
  );
};

DetailsList.propTypes = {
  event: PropTypes.shape({
    details: PropTypes.shape({
      decisionDescription: PropTypes.any,
      disposition: PropTypes.any,
      withdrawlRequestDate: PropTypes.any
    }),
    eventType: PropTypes.string,
  })
};

const renderEventDetails = (event) => {
  let renderBlock = null;

  switch (event.eventType) {
  case 'added_decision_date':
  case 'added_issue':
  case 'added_issue_without_decision_date':
  case 'completed_disposition':
  case 'withdrew_issue':
  case 'removed_issue':
    renderBlock = <DetailsList event={event} />;
    break;

  case 'claim_creation':
    renderBlock = 'Claim created.';
    break;

  case 'completed':
    renderBlock = <>
      <span>Claim closed.</span>
      <br />
      <span><strong>Claim decision date:</strong> {moment(event.details.decisionDate).utc().
        format('MM/DD/YY')}</span>
    </>;
    break;

  case 'cancelled':
    renderBlock = 'Claim closed.';
    break;

  case 'incomplete':
    renderBlock = 'Claim can not be processed until decision date is entered.';
    break;

  case 'in_progress':
    renderBlock = 'Claim can be processed';
    break;

  default:
    // Code to handle unexpected keys
    renderBlock = 'Unknown event type';
    break;
  }

  return renderBlock;

};

// const formatUserName = (userName) => {
//   const splitNames = userName.split(' ');
//   const last = splitNames.pop();

//   return [splitNames.map((remainingName) => `${remainingName[0] }.`), last].join(' ');
// };

export const userColumn = (events) => {
  return {
    header: 'User',
    name: 'user',
    enableFilter: true,
    label: 'Filter by user',
    valueName: 'user',
    columnName: 'eventUser',
    tableData: events,
    valueFunction: (event) => event.eventUserName,
    getSortValue: (event) => event.eventUserName
  };
};

export const dateTimeColumn = () => {
  return {
    header: 'Date and Time',
    name: 'dateTime',
    valueFunction: (event) => moment(event.eventDate).utc().
      format('MM/DD/YY, HH:mm'),
    // Might need to do date stuff to sort as well?
    getSortValue: (event) => event.eventDate
  };
};

export const activityColumn = (events) => {
  return {
    header: 'Activity',
    name: 'activity',
    enableFilter: true,
    label: 'Filter by activity',
    valueName: 'activity',
    columnName: 'eventType',
    anyFiltersAreSet: true,
    tableData: events,
    valueFunction: (event) => event.readableEventType,
    getSortValue: (event) => event.readableEventType
  };
};

// TODO: This is the column that needs the most work since the display will change based on the activity type
export const detailsColumn = () => {
  return {
    header: 'Details',
    name: 'details',
    valueFunction: (event) => {
      return renderEventDetails(event);
    }
  };
};
