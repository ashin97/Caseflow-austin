import React from 'react';
import PropTypes from 'prop-types';
import { LeverCancelButton } from './LeverButtons';
import { LeverSaveButton } from './LeverModal';
import { css } from 'glamor';

const saveButtonStyling = css({
  display: 'inline-block',
  float: 'right',
  paddingRight: '20px',
});
const cancelButtonStyling = css({
  display: 'inline-block',
  paddingLeft: '20px',
});

const buttonWrapperStyling = css({
  paddingBottom: '10px',
  marginBottom: '10px'
});

const LeverButtonsWrapper = (props) => {
  const { leverStore } = props;

  const cancelButton = <LeverCancelButton leverStore={leverStore} />;
  const saveButton = <LeverSaveButton leverStore={leverStore} />;

  return (
    <div {...buttonWrapperStyling}>
      <div {...cancelButtonStyling}>{cancelButton}</div>
      <div {...saveButtonStyling}>{saveButton}</div>
    </div>
  );
};

LeverButtonsWrapper.propTypes = {
  leverStore: PropTypes.any
};

export default LeverButtonsWrapper;
