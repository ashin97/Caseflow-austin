import { ACTIONS } from './correspondenceConstants';

export const loadCorrespondences = (correspondences) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.LOAD_CORRESPONDENCES,
      payload: {
        correspondences
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

export const setTaskRelatedAppealIds = (appealIds) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_TASK_RELATED_APPEAL_IDS,
      payload: {
        appealIds
      }
    });
  };

export const setUnrelatedTasks = (tasks) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_UNRELATED_TASKS,
      payload: {
        tasks
      }
    });
  };

export const setFetchedAppeals = (appeals) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_FETCHED_APPEALS,
      payload: {
        appeals
      }
    });
  };

export const saveMailTaskState = (name, isChecked) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SAVE_MAIL_TASK_STATE,
      payload: {
        name,
        isChecked
      }
    });
  };

export const addNewAppealRelatedTask = (id, appealId, type, content) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.ADD_NEW_APPEAL_RELATED_TASK,
      payload: {
        id, appealId, type, content
      }
    });
  };

export const removeNewAppealRelatedTask = (id) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.REMOVE_NEW_APPEAL_RELATED_TASK,
      payload: {
        id
      }
    });
  };
