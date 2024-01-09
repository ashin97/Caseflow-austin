import React from 'react';
import PropTypes from 'prop-types';
import BatchSize from './BatchSize';
import DocketTimeGoals from './DocketTimeGoals';
import AffinityDays from './AffinityDays';
import LeverButtonsWrapper from './LeverButtonsWrapper';
import ExclusionTable from './ExclusionTable';
import { sectionTitles } from '../constants';

const InteractableLeverWrapper = ({ levers, leverStore, isAdmin }) => {

  return (
    <div>
      <ExclusionTable isAdmin={isAdmin} />
      <BatchSize isAdmin={isAdmin} />
      <AffinityDays leverList={levers.affinityLevers} leverStore={leverStore} isAdmin={isAdmin} />
      <DocketTimeGoals
        leverList={levers.docketLeversObject}
        leverStore={leverStore}
        isAdmin={isAdmin}
        sectionTitles={sectionTitles} />
      {isAdmin ? <LeverButtonsWrapper leverStore={leverStore} /> : ''}
    </div>
  );
};

InteractableLeverWrapper.propTypes = {
  levers: PropTypes.object.isRequired,
  leverStore: PropTypes.any,
  isAdmin: PropTypes.bool,
};

export default InteractableLeverWrapper;
