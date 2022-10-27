/* eslint-disable max-len */
import React from 'react';
import PropTypes from 'prop-types';
import { ICON_SIZES, COLORS } from '../../constants/AppConstants';

export const MagnifyingGlassIcon = (props) => {
  const { color, size, className } = props;

  return <svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 216 146" className={className}>
    <path fill={color} d="M172.77 123.025L144.825 95.08c6.735-9.722 10.104-20.56 10.104-32.508
    0-7.767-1.51-15.195-4.527-22.283-3.014-7.09-7.088-13.2-12.22-18.336s-11.243-9.207-18.33-12.22c-7.09-3.016-14.52-4.523-22.286-4.523-7.768
    0-15.196 1.508-22.284 4.523-7.09 3.014-13.2 7.088-18.332 12.22-5.132 5.134-9.206 11.245-12.22 18.333-3.015 7.088-4.522 14.515-4.522 22.282
    0 7.766 1.507 15.192 4.522 22.282 3.014 7.088 7.088 13.197 12.22 18.33 5.134 5.134 11.245 9.207 18.333 12.222 7.09 3.015
    14.516 4.522 22.283 4.522 11.95 0 22.786-3.37 32.51-10.105l27.943 27.863c1.955 2.064 4.397 3.096 7.332 3.096 2.824 0 5.27-1.03
    7.332-3.096 2.064-2.063 3.096-4.508 3.096-7.332 0-2.877-1.002-5.322-3.013-7.33zm-49.413-34.668C116.214 95.5 107.62 99.07 97.57
    99.07c-10.048 0-18.643-3.57-25.786-10.713C64.64 81.214 61.07 72.62 61.07 62.57c0-10.047 3.572-18.643 10.714-25.785C78.926 29.642
    87.522 26.07 97.57 26.07c10.048 0 18.643 3.573 25.787 10.715 7.143 7.142 10.715 15.738 10.715 25.786 0 10.05-3.573 18.647-10.715
    25.79z" />
  </svg>;
};
MagnifyingGlassIcon.propTypes = {

  /**
  Sets size of the component. Default value is 'ICON_SIZES.MEDIUM'.
  */
  size: PropTypes.number,

  /**
  Sets color of the component. Default value is 'COLORS.GREY_MEDIUM'.
  */
  color: PropTypes.string,

  /**
  Adds class to the component. Default value is ''.
  */
  className: PropTypes.string
};
MagnifyingGlassIcon.defaultProps = {
  size: ICON_SIZES.MEDIUM,
  color: COLORS.GREY_MEDIUM,
  className: ''
};
