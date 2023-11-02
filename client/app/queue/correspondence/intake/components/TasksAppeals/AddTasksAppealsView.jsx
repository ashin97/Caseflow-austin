import React, { useState } from 'react';
// import React from 'react';
import Checkbox from '../../../../../components/Checkbox';
import Dropdown from '../../../../../components/Dropdown';
// import SearchBar from '../../../../../components/SearchBar';
import TextareaField from '../../../../../components/TextareaField';
import Button from '../../../../../components/Button';

const mailTasksLeft = [
  'Change of address',
  'Evidence or argument',
  'Returned or undeliverable mail'
];

const mailTasksRight = [
  'Sent to ROJ',
  'VACOLS updated',
  'Associated with Claims Folder'
];

export const AddTasksAppealsView = () => {
  const [addTask, setAddTask] = useState([{ dummyObject: 'string' }]);
  const clickAddTask = () => {
    // const clickButt = () => {
    console.log("we added a task *evil laugh*");
    // setAddTask([...{ addedTask: [] }]);
  };

  return (
    <div className="gray-border" style={{ marginBottom: '2rem', padding: '3rem 4rem' }}>
      <h1 style={{ marginBottom: '10px' }}>Review Tasks & Appeals</h1>
      <p>Review any previously complete tasks by the mail team and add new tasks for
      either the mail package or for linked appeals, if any.</p>
      <div>
        <h2 style={{ margin: '25px auto 15px auto' }}>Mail Tasks</h2>
        <div className="gray-border" style={{ padding: '0rem 2rem' }}>
          <p style={{ marginBottom: '0.5rem' }}>Select any tasks completed by the Mail team for this correspondence.</p>
          <div style={{ display: 'inline-block', marginRight: '14rem' }}>
            {mailTasksLeft.map((name, index) => {
              return (
                <Checkbox
                  key={index}
                  name={name}
                  label={name}
                />
              );
            })}
          </div>
          <div style={{ display: 'inline-block' }}>
            {mailTasksRight.map((name, index) => {
              return (
                <Checkbox
                  key={index}
                  name={name}
                  label={name}
                />
              );
            })}
          </div>
        </div>

        <h2 style={{ margin: '3rem auto 1rem auto'}}>Tasks not related to an Appeal</h2>
        <p style={{ marginTop: '0rem', marginBottom: '2rem' }} onClick={() => (console.log("onClick worked"))}>
          Add new tasks related to this correspondence or to an appeal not yet created in Caseflow.
        </p>
        <div />

        <Button
          type="button"
          onClick={() => {clickAddTask()}}
          // onClick={clickAddTask}
          name="addTasks"
          classNames={['cf-left-side']}>
            + Add tasks
        </Button>
        {false && <div className="gray-border" style={{ padding: '0rem 0rem' }}>
          <div style={{ width: '100%', height: 'auto', backgroundColor: 'white', paddingBottom: '3rem' }}>
            <div style={{ backgroundColor: '#f1f1f1', width: '100%', height: '50px', paddingTop: '1.5rem' }}>
              <b style={{
                verticalAlign: 'center',
                paddingLeft: '2.5rem',
                paddingTop: '1.5rem',
                border: '0',
                paddingBottom: '1.5rem',
                paddingRight: '5.5rem'
              }}>New Tasks</b>
            </div>
            <div style={{ width: '100%', height: '1rem' }} />
            {/* <p style={{ textAlign: 'left', paddingLeft: '10px', height: '5px' }}>Search document contents</p>
            <span style={{
              width: '75%',
              display: 'flex',
              justifyContent: 'flex-end'
            }}>
            </span> */}
            { addTask.map((currentTask, i) => (
              <div style={{ display: 'inline-block', marginRight: '2rem' }}>
                <div className="gray-border" style={{ padding: '2rem 2rem', marginLeft: '3rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'flex-end', paddingLeft: '1rem', marginLeft: '0.5rem', minWidth: '500px' }}>
                    <Dropdown
                      name="Task"
                      label="Task"
                      options={[['Option1', 'Option 1'], ['Option 2'], ['Option 3']]}
                      defaultText="Select..."
                      style={{ display: 'flex', width: '100%', marginRight: '1rem' }}
                      // onChange={(option) => onClickIssueAction(issue.index, option)}
                    />
                    <div style={{ marginRight: '10rem' }} />
                    <hr />
                    <TextareaField
                      name="Task Information"
                      label="Provide context and instruction on this task"
                      defaultText=""
                    />
                  </div>
                </div>
              </div>
            ))}
            {/* <div style={{ display: 'inline-block' }}>
              <div className="gray-border" style={{ padding: '2rem 2rem', marginLeft: '3rem' }}>
                <div style={{ display: 'flex', justifyContent: 'flex-end', paddingLeft: '1rem', marginLeft: '0.5rem', minWidth: '500px' }}>
                  <Dropdown
                    name="Task"
                    label="Task"
                    options={[['Option1', 'Option 1'], ['Option 2'], ['Option 3']]}
                    defaultText="Select..."
                    style={{ display: 'flex', width: '100%' }}
                    // onChange={(option) => onClickIssueAction(issue.index, option)}
                  />
                  <div style={{ marginRight: '10rem' }} />
                  <hr />
                  <TextareaField
                    name="Task Information"
                    label="Provide context and instruction on this task"
                    defaultText=""
                  />
                </div>
              </div>
            </div> */}
            <Button
              // style={{ margin: '2rem 2rem 2rem 2rem', padding: '2rem 2rem 2rem 2rem' }}
              // style={{ display: 'flex', flex-direction: 'g' }}
              type="button"
              onClick={() => (console.log("onClick worked"))}
              name="addTasks"
              classNames={['cf-left-side']}>
                + Add tasks
            </Button>
          </div>
        </div> }
      </div>
    </div>
  );
};

AddTasksAppealsView.propTypes = {

};

export default AddTasksAppealsView;
