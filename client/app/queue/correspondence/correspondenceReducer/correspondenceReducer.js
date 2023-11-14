import { update } from '../../../util/ReducerUtil';
import { ACTIONS } from './correspondenceConstants';

export const initialState = {
  correspondences: [],
  radioValue: '2',
  toggledCheckboxes: [],
  unrelatedTasks: []

};

export const intakeCorrespondenceReducer = (state = initialState, action = {}) => {
  switch (action.type) {
  case ACTIONS.LOAD_CORRESPONDENCES:
    return update(state, {
      correspondences: {
        $set: action.payload.correspondences
      }
    });

  case ACTIONS.LOAD_VET_CORRESPONDENCE:
    return update(state, {
      vetCorrespondences: {
        $set: action.payload.vetCorrespondences
      }
    });

  case ACTIONS.UPDATE_RADIO_VALUE:
    return update(state, {
      radioValue: {
        $set: action.payload.radioValue
      }
    });

  case ACTIONS.SAVE_CHECKBOX_STATE:
    if (action.payload.isChecked) {
      return update(state, {
        toggledCheckboxes: {
          $push: [action.payload.id]
        }
      });
    }

    return update(state, {
      toggledCheckboxes: {
        $set: state.toggledCheckboxes.filter((id) => id !== action.payload.id)
      }
    });

  case ACTIONS.CLEAR_CHECKBOX_STATE:
    return update(state, {
      toggledCheckboxes: {
        $set: []
      }
    });

  case ACTIONS.SET_UNRELATED_TASKS:
    console.log('The action.payload is: ' + action.payload.tasks);

    return update(state, {
      unrelatedTasks: {
        $set: [...action.payload.tasks]
      }
    });

  default:
    return state;
  }
};

export default intakeCorrespondenceReducer;
