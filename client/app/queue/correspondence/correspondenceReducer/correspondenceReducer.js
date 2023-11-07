import { update } from '../../../util/ReducerUtil';
import { ACTIONS } from './correspondenceConstants';

export const initialState = {
  correspondences: [],
  toggledCheckboxes: []
};

export const intakeCorrespondenceReducer = (state = initialState, action = {}) => {
  switch (action.type) {
  case ACTIONS.LOAD_CURRENT_CORRESPONDENCE:
    return update(state, {
      currentCorrespondence: {
        $set: action.payload.currentCorrespondence
      }
    });

  case ACTIONS.LOAD_CORRESPONDENCES:
    return update(state, {
      correspondences: {
        $set: action.payload.correspondences
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

  default:
    return state;
  }
};

export default intakeCorrespondenceReducer;
