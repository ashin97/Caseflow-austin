import React, { useMemo, useState } from 'react';
import PropTypes from 'prop-types';
import { useFormContext } from 'react-hook-form';
import { capitalize } from 'lodash';
import format from 'date-fns/format';
import parseISO from 'date-fns/parseISO';
import { TaskSelectionTable } from './TaskSelectionTable';

export const TasksToCancel = ({ tasks, existingValues, setSelectedCancelTaskIds }) => {
  const { control } = useFormContext();
  const fieldName = 'cancelTaskIds';
  const [cancelTaskIds, setCancelTaskIds] = useState(existingValues?.cancelTaskIds || [])

  const formattedTasks = useMemo(() => {
    return tasks.map((task) => ({
      ...task,
      taskId: parseInt(task.taskId, 10),
      status: capitalize(task.status),
      createdAt: format(parseISO(task.createdAt), 'MM/dd/yyyy'),
    }));
  }, [tasks]);

  setSelectedCancelTaskIds(cancelTaskIds)

  // Code from https://github.com/react-hook-form/react-hook-form/issues/1517#issuecomment-662386647
  const handleCheck = (changedId, checked) => {
    if (checked) {
      setCancelTaskIds(cancelTaskIds.filter((taskId) => taskId !== changedId))
    } else {
      setCancelTaskIds([...cancelTaskIds, changedId])
    }
    setSelectedCancelTaskIds(cancelTaskIds)
    return cancelTaskIds;
  };

  return (
    <TaskSelectionTable
      control={control}
      onCheckChange={handleCheck}
      tasks={formattedTasks}
      selectedTaskIds={selectedTaskIds}
      selectionField={fieldName}
      selectedCancelTaskIds={cancelTaskIds}
    />
  );
};

TasksToCancel.propTypes = {
  tasks: PropTypes.array,
  existingValues: PropTypes.object,
  setSelectedCancelTaskIds: PropTypes.func,
};

