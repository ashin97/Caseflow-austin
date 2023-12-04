import React from 'react';
import { useSelector } from 'react-redux';
import { COLORS } from 'app/constants/AppConstants';
import { PencilIcon } from 'app/components/icons/PencilIcon';
import { css } from 'glamor';
import LinkToAppeal from '../../../../../hearings/components/assignHearings/LinkToAppeal';
import HearingBadge from '../../../../../components/badges/HearingBadge/HearingBadge';
import DocketTypeBadge from '../../../../../components/DocketTypeBadge';
// import Badge from '../../../../../components/badges/Badge';

const styling = { backgroundColor: COLORS.GREY_BACKGROUND, border: 'none' };

const ConfirmTasksRelatedToAnAppeal = () => {
  const tasks = useSelector((state) => state.intakeCorrespondence.newAppealRelatedTasks);
  const taskIds = useSelector((state) => state.intakeCorrespondence.taskRelatedAppealIds);
  const fetchedAppeals = useSelector((state) => state.intakeCorrespondence.fetchedAppeals);
  const rowObjects = taskIds.map((task, index) => {
    return (
      <>
        <thead style={{}}>
          <tr style={{ height: '100px',  display: 'flex', flexDirection: 'column'}}>
            <th style={styling}></th>
            Appeal {index + 1} Tasks
            <b>Linked appeal</b>
            {/* <HearingBadge name="help" number={123} /> */}
            <LinkToAppeal>

            <DocketTypeBadge name="Help" number={'1234'} />
              <b>{fetchedAppeals.find((appeal) => appeal.id === task).docketNumber}</b></LinkToAppeal>
          </tr>
        </thead>
        <tr>
          <td
            style={{ backgroundColor: COLORS.GREY_BACKGROUND, borderTop: 'none', width: '20%' }}>
            <b>Additional Tasks</b>
          </td>
          <td style={{ backgroundColor: COLORS.GREY_BACKGROUND, borderTop: 'none' }}>
            <b>Task Instructions or Context</b>
          </td>
        </tr>
        {/* {tasks.filter((taskById) => taskById.appealId === task.appealId)} */}
        {tasks.filter((taskById) => taskById.appealId === task).map((taskById) =>
          <tr>
            <td
              style={{ backgroundColor: COLORS.GREY_BACKGROUND, borderTop: '1px solid #dee2e6', width: '20%' }}>
              {taskById.type}
            </td>
            <td style={{ backgroundColor: COLORS.GREY_BACKGROUND, borderTop: '1px solid #dee2e6' }}>
              {taskById.content}
            </td>
          </tr>)}

      </>
    );
  });

  return (
    <>
      <div>
        <div style={{ position: 'relative', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
          <h2 style={{ display: 'inline', marginBottom: '2rem' }}>Tasks not related to an Appeal</h2>
          <a href="#task-not-related-to-an-appeal">
            <span style={{ position: 'absolute' }}><PencilIcon size={25} /></span>
            <span {...css({ marginLeft: '24px' })}>Edit section</span>
          </a>
        </div>
        <div
          style={{ background: COLORS.GREY_BACKGROUND, padding: '2rem', paddingTop: '0.5rem', marginBottom: '2rem' }}>
          <table className="usa-table-borderless">

            <tbody>
              {rowObjects}
            </tbody>
          </table>
        </div>
      </div></>
  );
};

export default ConfirmTasksRelatedToAnAppeal;
