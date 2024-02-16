# frozen_string_literal: true

class OrganizationCorrespondenceActionRequiredTasksTab < CorrespondenceQueueTab
  validate :assignee_is_organization

  def label
    Constants.QUEUE_CONFIG.CORRESPONDENCE_ACTION_REQUIRED_TASKS_LABEL
  end

  def self.tab_name
    Constants.QUEUE_CONFIG.CORRESPONDENCE_ACTION_REQUIRED_TASKS_TAB_NAME
  end

  def description
    Constants.QUEUE_CONFIG.CORRESPONDENCE_ACTION_REQUIRED_TASKS_DESCRIPTION
  end

  def tasks
    if RequestStore[:current_user].mail_supervisor?
      CorrespondenceTask
      .includes(*task_includes)
      .where(
        type: [SplitPackageTask.name, ReassignPackageTask.name, RemovePackageTask.name, MergePackageTask.name]
      )
      .where(assigned_to: assignee)
      .active
    else
      CorrespondenceTask
      .includes(*task_includes)
      .where(type: [SplitPackageTask.name, ReassignPackageTask.name, MergePackageTask.name])
      .where(assigned_to: assignee)
      .active
    end
  end

  def column_names
    [
      Constants.QUEUE_CONFIG.COLUMNS.VETERAN_DETAILS.name,
      Constants.QUEUE_CONFIG.COLUMNS.VA_DATE_OF_RECEIPT.name,
      Constants.QUEUE_CONFIG.COLUMNS.DAYS_WAITING_CORRESPONDENCE.name,
      Constants.QUEUE_CONFIG.COLUMNS.TASK_ASSIGNED_BY.name,
      Constants.QUEUE_CONFIG.COLUMNS.ACTION_TYPE.name,
      Constants.QUEUE_CONFIG.COLUMNS.NOTES.name
    ]
  end
end
