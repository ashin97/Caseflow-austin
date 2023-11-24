import { ACTIONS } from './correspondenceConstants';

export const loadCurrentCorrespondence = (currentCorrespondence) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.LOAD_CURRENT_CORRESPONDENCE,
      payload: {
        currentCorrespondence
      }
    });
  };

export const loadCorrespondences = (correspondences) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.LOAD_CORRESPONDENCES,
      payload: {
        correspondences
      }
    });
  };

export const loadVeteranInformation = (veteranInformation) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.LOAD_VETERAN_INFORMATION,
      payload: {
        veteranInformation
      }
    });
  };

export const loadVetCorrespondence = (vetCorrespondences) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.LOAD_VET_CORRESPONDENCE,
      payload: {
        vetCorrespondences
      }
    });
  };

export const updateRadioValue = (value) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.UPDATE_RADIO_VALUE,
      payload: value
    });
};
export const saveCheckboxState = (id, isChecked) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SAVE_CHECKBOX_STATE,
      payload: {
        id, isChecked
      }
    });
  };

export const clearCheckboxState = () =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.CLEAR_CHECKBOX_STATE,
    });
  };