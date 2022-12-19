# frozen_string_literal: true

class BvaIntakePendingTab < QueueTab
  validate :assignee_is_organization

  attr_accessor :show_reader_link_column, :allow_bulk_assign

  def label
    COPY::ORGANIZATIONAL_QUEUE_PAGE_PENDING_TAB_TITLE
  end

  def self.tab_name
    Constants.QUEUE_CONFIG.PENDING_TASKS_TAB_NAME
  end

  def description
    format(COPY::ORGANIZATIONAL_QUEUE_PAGE_BVA_PENDING_TASKS_DESCRIPTION, assignee.name)
  end

  def tasks
    # Original
    # on_hold_task_children.open
    # With includes added again since it gets eaten by on_hold_task_children
    # on_hold_task_children.includes(*task_includes).open
    # with join for sorting without nasty case statement
    on_hold_task_children.open.includes(*task_includes, :cancelled_by).joins(:ama_appeal)
  end

  def column_names
    BvaIntake::COLUMN_NAMES
  end

  def default_sorting_column
    QueueColumn.from_name(Constants.QUEUE_CONFIG.COLUMNS.RECEIPT_DATE_INTAKE.name)
  end
end
