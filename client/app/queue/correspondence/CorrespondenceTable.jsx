import React from 'react';
import QueueTable from '../QueueTable';
import PropTypes from 'prop-types';
import Link from '@department-of-veterans-affairs/caseflow-frontend-toolkit/components/Link';

const CorrespondenceTable = (props) => {

  const columns = [
    {
      name: 'veteranDetails',
      header: 'Veteran Details',
      align: 'left',
      valueName: 'veteranDetails',
      getSortValue: (row) => row.firstName,
      backendCanSort: true,
      valueFunction: (row) => (
        <Link href={`/queue/correspondence/${row.correspondenceUuid}/review_package`}>
          {`${row.firstName} ${row.lastName} (${row.fileNumber})`}
        </Link>
      )
    },

    {
      name: 'packageDocumentType',
      header: 'Package Document Type ',
      align: 'left',
      columnName: 'packageDocumentType',
      valueName: 'packageDocumentType',
      enableFilter: true,
      anyFiltersAreSet: true,
      tableData: props.vetCorrespondences,
      label: 'Filter by package document type',
      getSortValue: (row) => row.packageDocumentType,
      filterValueTransform: (columnValue) => {
        return String(columnValue);
      },
      backendCanSort: true
    },
    {
      name: 'cmPacketNumber',
      header: 'CM Packet Number ',
      align: 'left',
      valueName: 'cmPacketNumber',
      getSortValue: (row) => row.cmPacketNumber,
      backendCanSort: true
    }
  ];

  return (
    <QueueTable
      className="assign-correspondence-table"
      columns={columns}
      rowObjects={props.vetCorrespondences}
      summary="scheduled-hearings-table"
      enablePagination
    />
  );
};

CorrespondenceTable.propTypes = {
  hearingScheduleColumns: PropTypes.array,
  hearingScheduleRows: PropTypes.array,
  onApply: PropTypes.func,
  loadVetCorrespondence: PropTypes.func,
  vetCorrespondences: PropTypes.array,
  history: PropTypes.object,
  user: PropTypes.shape({
    userCanBuildHearingSchedule: PropTypes.bool
  })
};

export default CorrespondenceTable;
