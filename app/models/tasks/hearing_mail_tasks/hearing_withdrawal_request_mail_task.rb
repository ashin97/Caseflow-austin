# frozen_string_literal: true

##
# Task to process a hearing withdrawal request received via the mail
#
# When this task is created:
#   - It's parent task is set as the RootTask of the associated appeal
#   - The task is assigned to the MailTeam to track where the request originated
#   - A child task of the same name is created and assigned to the HearingAdmin organization
##
class HearingWithdrawalRequestMailTask < HearingRequestMailTask
  prepend HearingWithdrawn

  class << self
    def label
      COPY::HEARING_WITHDRAWAL_REQUEST_MAIL_TASK_LABEL
    end

    def allow_creation?(*)
      true
    end
  end

  TASK_ACTIONS = [
    Constants.TASK_ACTIONS.CHANGE_TASK_TYPE.to_h,
    Constants.TASK_ACTIONS.COMPLETE_AND_WITHDRAW.to_h,
    Constants.TASK_ACTIONS.ASSIGN_TO_TEAM.to_h,
    Constants.TASK_ACTIONS.ASSIGN_TO_PERSON.to_h,
    Constants.TASK_ACTIONS.CANCEL_TASK.to_h
  ].freeze

  # Purpose: Determines the actions a user can take depending on their permissions and the state of the appeal
  # Params: user - The current user object
  # Return: The task actions array of objects
  def available_actions(user)
    return [] unless user.in_hearing_admin_team?

    if active_schedule_hearing_task || hearing_scheduled_and_awaiting_disposition?
      TASK_ACTIONS
    else
      [
        Constants.TASK_ACTIONS.CHANGE_TASK_TYPE.to_h,
        Constants.TASK_ACTIONS.CANCEL_TASK.to_h
      ]
    end
  end

  # Purpose: Updates the current state of the appeal
  # Params: params - The update params object
  #         user - The current user object
  # Return: The current hwr task and newly created tasks
  def update_from_params(params, user)
    if params[:status] == Constants.TASK_STATUSES.completed
      created_tasks = update_hearing_and_cancel_tasks
      update_self_and_parent_mail_task(user: user, params: params)

      [self] + (created_tasks || [])
    else
      super(params, user)
    end
  end

  private

  # Purpose: Wrapper for updating hearing, canceling hearing tasks, and creating evidence submission task
  # Params: None
  # Return: Returns the newly created evidence submission task if AMA appeal
  def update_hearing_and_cancel_tasks
    multi_transaction do
      mark_hearing_cancelled if open_hearing
      cancel_active_hearing_tasks
      maybe_evidence_task = withdraw_hearing(hearing_task.parent)

      [maybe_evidence_task].compact
    end
  end

  # Purpose: Sets the previous hearing's disposition to cancelled and cleans up virtual hearing
  # Params: None
  # Return: Nil
  def mark_hearing_cancelled
    update_hearing(disposition: Constants.HEARING_DISPOSITION_TYPES.cancelled)
    clean_up_virtual_hearing(open_hearing)
  end

  # Purpose: Cancels HearingTask, either child AssignHearingDispositionTask or ScheduleHearingTask
  # Params: None
  # Return: True if HearingRelatedMailTasks cancelled, otherwise nil
  def cancel_active_hearing_tasks
    hearing_task.cancel_task_and_child_subtasks
    cancel_hearing_related_mail_tasks
  end

  # Purpose: Cancels any active HearingRelatedMailTasks on appeal
  # Params: None
  # Return: True if HearingRelatedMailTasks cancelled, otherwise nil
  def cancel_hearing_related_mail_tasks
    return if hearing_related_mail_tasks.empty?

    hearing_related_mail_tasks.update_all(status: Constants.TASK_STATUSES.cancelled)
  end

  # Purpose: Grabs any active HearingRelatedMailTasks on appeal
  # Params: None
  # Return: Array of HearingRelatedMailTask objects
  def hearing_related_mail_tasks
    appeal.tasks.where(type: HearingRelatedMailTask.name)&.active
  end

  # Purpose: Appends instructions on to the instructions provided in the mail task
  # Params: instructions - String for instructions
  # Return: instructions string
  def format_instructions_on_completion(params)
    markdown_to_append = <<~EOS

      ***

      ###### Mark as complete and withdraw hearing:

      **DETAILS**
      #{params[:instructions]}
    EOS

    [instructions[0] + markdown_to_append]
  end
end
