import AppSegment from '@department-of-veterans-affairs/caseflow-frontend-toolkit/components/AppSegment';
import React, { useEffect, useState } from 'react';
import ReviewPackageData from './ReviewPackageData';
import ReviewPackageCaseTitle from './ReviewPackageCaseTitle';
import Button from '../../../components/Button';
import ReviewForm from './ReviewForm';
import { CmpDocuments } from './CmpDocuments';
import ApiUtil from '../../../util/ApiUtil';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

export const CorrespondenceReviewPackage = (props) => {
  const [reviewDetails, setReviewDetails] = useState({
    veteran_name: {},
    dropdown_values: [],
  });
  const [editableData, setEditableData] = useState({
    notes: '',
    veteran_file_number: '',
    default_select_value: ''
  });
  const [apiResponse, setApiResponse] = useState(null);
  const [disableButton, setDisableButton] = useState(false);

  const fetchData = async () => {
    const correspondence = props;

    try {
      const response = await ApiUtil.get(
        `/queue/correspondence/${correspondence.correspondence_uuid}`
      );

      setApiResponse(response.body.general_information);
      const data = response.body.general_information;

      setReviewDetails({
        veteran_name: data.veteran_name || {},
        dropdown_values: data.correspondence_types || [],
      });

      setEditableData({
        notes: data.notes,
        veteran_file_number: data.file_number,
        default_select_value: data.correspondence_type_id,
      });
    } catch (error) {
      throw error();
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const isEditableDataChanged = () => {
    const notesChanged = editableData.notes !== apiResponse.notes;
    const fileNumberChanged = editableData.veteran_file_number !== apiResponse.file_number;
    const selectValueChanged = editableData.default_select_value !== apiResponse.correspondence_type_id;

    return notesChanged || fileNumberChanged || selectValueChanged;
  };

  useEffect(() => {
    if (apiResponse) {
      const hasChanged = isEditableDataChanged();

      setDisableButton(hasChanged);
    }
  }, [editableData, apiResponse]);

  const intakeLink = `/queue/correspondence/${props.correspondence_uuid}/intake`;

  return (
    <React.Fragment>
      <AppSegment filledBackground>
        <ReviewPackageCaseTitle />
        <ReviewPackageData
          correspondence={props.correspondence}
          packageDocumentType={props.packageDocumentType} />
        <ReviewForm
          {...{
            reviewDetails,
            setReviewDetails,
            editableData,
            setEditableData,
            disableButton,
            setDisableButton,
            fetchData
          }}
          {...props}
        />
        <CmpDocuments documents={props.correspondenceDocuments} />
      </AppSegment>
      <div className="cf-app-segment">
        <div className="cf-push-left">
          <a href="/queue/correspondence">
            <Button
              name="Cancel"
              href="/queue/correspondence"
              classNames={['cf-btn-link']}
            />
          </a>
        </div>
        <div className="cf-push-right">
          { (props.packageDocumentType.name === '10182') && (
            <Button
              name="Intake appeal"
              styling={{ style: { marginRight: '2rem' } }}
              classNames={['usa-button-secondary']}
            />
          )}
          <a href={intakeLink}>
            {/* hard coded UUID to link to multi_correspondence.rb data */}
            <Button
              name="Create record"
              classNames={['usa-button-primary']}
              href={intakeLink}
            />
          </a>
        </div>
      </div>
    </React.Fragment>
  );
};

CorrespondenceReviewPackage.propTypes = {
  correspondence_uuid: PropTypes.string,
  correspondence: PropTypes.object,
  correspondenceDocuments: PropTypes.arrayOf(PropTypes.object),
  packageDocumentType: PropTypes.object,
};

const mapStateToProps = (state) => ({
  correspondence: state.reviewPackage.correspondence,
  correspondenceDocuments: state.reviewPackage.correspondenceDocuments,
  packageDocumentType: state.reviewPackage.packageDocumentType
});

export default connect(
  mapStateToProps,
  null,
)(CorrespondenceReviewPackage);
