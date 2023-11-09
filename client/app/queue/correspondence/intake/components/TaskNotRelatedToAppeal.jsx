import React, { useState } from 'react';
import TextareaField from '../../../../components/TextareaField';
import ReactSelectDropdown from '../../../../components/ReactSelectDropdown';
import PropTypes from 'prop-types';
import Button from '../../../../components/Button';

const TaskNotRelatedToAppeal = (props) => {

  const dropdownOptions = [
    { value: 0, label: 'CAVC Correspondence' },
    { value: 1, label: 'Congressional interest' },
    { value: 2, label: 'Death certificate' },
    { value: 3, label: 'FOIA request' },
    { value: 4, label: 'Other motion' },
    { value: 5, label: 'Power of attorney-related' },
    { value: 6, label: 'Privacy act request' },
    { value: 7, label: 'Privacy complaint' },
    { value: 8, label: 'Status inquiry' }
  ];

  const [selectedTaskType, setSelectedTaskType] = useState(-1);
  const [instructionText, setInstructionText] = useState('');
  const handleChangeTaskType = (newType) => {
    setSelectedTaskType(newType);
  };

  const handleChangeInstructionText = (newText) => {
    setInstructionText(newText);
  };

  return (
    <div key={props.key} style={{ display: 'block', marginRight: '2rem' }}>
      <div className="gray-border"
        style={{ display: 'block', padding: '2rem 2rem', marginLeft: '3rem', width: '50rem' }}>
        <div
          style={
            { width: '45rem' }
          }
        >
          <ReactSelectDropdown
            options={dropdownOptions}
            defaultValue={{ value: -1, label: 'Select...' }}
            label="Task"
            style={{ width: '50rem' }}
            onChangeMethod={(selectedOption) => handleChangeTaskType(selectedOption.value)}
            className="date-filter-type-dropdown"
          />
          <div style={{ padding: '1.5rem' }} />
          <TextareaField
            name="Task Information"
            label="Provide context and instruction on this task"
            defaultText=""
            value={instructionText}
            onChange={handleChangeInstructionText}
          />
          <Button
            name="Add"
            styling={{ style: { paddingLeft: '0rem', paddingRight: '0rem' } }}
            classNames={['cf-btn-link', 'cf-left-side']} >
            Add autotext
          </Button>
          <Button
            name="Remove"
            styling={{ style: { paddingLeft: '0rem', paddingRight: '0rem' } }}
            onClick={props.removeTask}
            classNames={['cf-btn-link', 'cf-right-side']} >
            <i className="fa fa-trash-o" aria-hidden="true"></i> Remove task
          </Button>
        </div>
      </div>
    </div>
  );
};

TaskNotRelatedToAppeal.propTypes = {
  removeTask: PropTypes.func,
  key: PropTypes.object,
};

export default TaskNotRelatedToAppeal;
