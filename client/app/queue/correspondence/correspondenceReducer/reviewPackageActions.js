import { ACTIONS } from './reviewPackageConstants';

export const setCorrespondence = (correspondence) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_CORRESPONDENCE,
      payload: {
        correspondence
      }
    });
  };

export const setCorrespondenceDocuments = (correspondenceDocuments) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_CORRESPONDENCE_DOCUMENTS,
      payload: {
        correspondenceDocuments
      }
    });
  };

export const setPackageDocumentType = (packageDocumentType) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_PACKAGE_DOCUMENT_TYPE,
      payload: {
        packageDocumentType
      }
    });
  };

export const setVeteranInformation = (veteranInfo) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_VETERAN_INFORMATION,
      payload: {
        veteranInfo
      }
    });
  };

export const updateCmpInformation = (packageDocumentType, date) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.UPDATE_CMP_INFORMATION,
      payload: {
        packageDocumentType,
        date
      }
    });
  };

export const updateDocumentTypeName = (newName, index) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.UPDATE_DOCUMENT_TYPE_NAME,
      payload: {
        newName,
        index
      }
    });
  };

export const updateLastAction = (currentAction) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.REMOVE_PACKAGE_ACTION,
      payload: {
        currentAction
      }
    });
  };

export const setReasonRemovePackage = (reasonForRemove) =>
  (dispatch) => {
    dispatch({
      type: ACTIONS.SET_REASON_REMOVE_PACKAGE,
      payload: {
        reasonForRemove
      }
    });
  };
