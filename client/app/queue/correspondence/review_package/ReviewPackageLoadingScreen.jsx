import * as React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import LoadingDataDisplay from '../../../components/LoadingDataDisplay';
import { LOGO_COLORS } from '../../../constants/AppConstants';
import ApiUtil from '../../../util/ApiUtil';

import {
  setCorrespondence,
  setCorrespondenceDocuments,
  setPackageDocumentType,
  setVeteranInformation
} from '../correspondenceReducer/reviewPackageActions';
import WindowUtil from '../../../util/WindowUtil';

class ReviewPackageLoadingScreen extends React.PureComponent {

  createLoadPromise = async () => {
    return await ApiUtil.get(
      `/queue/correspondence/${this.props.correspondence_uuid}`).then(
      (response) => {
        /* eslint-disable no-unused-vars, camelcase */
        const {
          correspondence,
          correspondence_documents,
          package_document_type,
          general_information
        } = response.body;

        this.props.setCorrespondence(correspondence);
        this.props.setCorrespondenceDocuments(correspondence_documents);
        this.props.setPackageDocumentType(package_document_type);
        this.props.setVeteranInformation(general_information);
      }
    );
  }

  render = () => {
    const failStatusMessageChildren = <div>
      It looks like Caseflow was unable to load this correspondence<br />
      Please <a onClick={WindowUtil.reloadWithPOST}>refresh the page</a> and try again.
    </div>;

    const loadingDataDisplay = <LoadingDataDisplay
      createLoadPromise={this.createLoadPromise}
      loadingComponentProps={{
        spinnerColor: LOGO_COLORS.QUEUE.ACCENT,
        message: 'Loading review package...'
      }}
      failStatusMessageProps={{
        title: 'Unable to load correspondence'
      }}
      failStatusMessageChildren={failStatusMessageChildren}>
      {this.props.children}
    </LoadingDataDisplay>;

    return <div className="usa-grid">
      {loadingDataDisplay}
    </div>;
  };
}

ReviewPackageLoadingScreen.propTypes = {
  correspondence_uuid: PropTypes.string,
  children: PropTypes.node,
  setCorrespondence: PropTypes.func,
  setCorrespondenceDocuments: PropTypes.func,
  setPackageDocumentType: PropTypes.func,
  setVeteranInformation: PropTypes.func
};

const mapDispatchToProps = (dispatch) => bindActionCreators({
  setCorrespondence,
  setCorrespondenceDocuments,
  setPackageDocumentType,
  setVeteranInformation
}, dispatch);

export default (connect(null, mapDispatchToProps)(ReviewPackageLoadingScreen));