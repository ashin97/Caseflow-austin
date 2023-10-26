import React from 'react';
import PropTypes from 'prop-types';
import { sprintf } from 'sprintf-js';

import QueueSelectorDropdown from './QueueSelectorDropdown';
import COPY from '../../../COPY';

export default class QueueOrganizationDropdown extends React.Component {
  render = () => {
    const { organizations, featureToggles } = this.props;
    const url = window.location.pathname.split('/');
    const location = url[url.length - 1];
    const queueHref = (location === 'queue') ? '#' : '/queue';
    let correspondenceItems = {};

    if (organizations.length < 1) {
      return null;
    }

    const queueItem = {
      key: '0',
      href: queueHref,
      label: COPY.CASE_LIST_TABLE_QUEUE_DROPDOWN_OWN_CASES_LABEL
    };

    const organizationItems = organizations.map((org, index) => {
      // If the url is a specified path, use it over the organization route
      const orgHref = org.url.includes('/') ? org.url : `/organizations/${org.url}`;

      return {
        key: (index + 1).toString(),
        href: (location === org.url) ? '#' : orgHref,
        label: sprintf(COPY.CASE_LIST_TABLE_QUEUE_DROPDOWN_TEAM_CASES_LABEL, org.name)
      };
    });

    let items = [queueItem, ...organizationItems];

    if (/*featureToggles.correspondence_queue && */organizations[0].name === 'Mail') {
      const orgHref = 'queue/correspondences/';

      correspondenceItems = {
        key: (2).toString(),
        href: orgHref,
        label: sprintf(COPY.CASE_LIST_TABLE_QUEUE_DROPDOWN_CORRESPONDENCE_CASES)
      };

      items = [...items, correspondenceItems];
    }

    return <QueueSelectorDropdown items={items} />;
  }
}

QueueOrganizationDropdown.propTypes = {
  organizations: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string.isRequired,
    url: PropTypes.string.isRequired
  })),
  featureToggles: PropTypes.object
};
