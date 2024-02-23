# frozen_string_literal: true

module DistributionConcern
  extend ActiveSupport::Concern

  private

  def assign_judge_tasks_for_appeals(appeals, judge)
    appeals.map do |appeal|
      # If an appeal does not have an open DistributionTask, then it has already been distributed by automatic
      # case distribution and a new JudgeAssignTask should not be created. This should only occur if two users
      # request a distribution simultaneously.
      if appeal.tasks.open.of_type(:DistributionTask).any? && appeal.can_redistribute_appeal?
        distribution_task_assignee_id = appeal.tasks.of_type(:DistributionTask).first.assigned_to_id
        Rails.logger.info("Calling JudgeAssignTaskCreator for appeal #{appeal.id} with judge #{judge.css_id}")
        JudgeAssignTaskCreator.new(appeal: appeal,
                                   judge: judge,
                                   assigned_by_id: distribution_task_assignee_id).call
      else
        msg = "Appeal ID #{appeal.id} cannot be distributed. Check its task tree and manually remediate if necessary"
        title = "Appeal unable to be distributed"
        SlackService.new(url: slack_url).send_notification(msg, title)

        nil
      end
    end
  end

  def assign_sct_tasks_for_appeals(appeals)
    appeals.map do |appeal|
      next nil unless appeal.tasks.open.of_type(:DistributionTask).any?

      distribution_task_assignee_id = appeal.tasks.of_type(:DistributionTask).first.assigned_to_id
      Rails.logger.info("Calling SpecialtyCaseTeamAssignTaskCreator for appeal #{appeal.id}")
      SpecialtyCaseTeamAssignTaskCreator.new(appeal: appeal,
                                             assigned_by_id: distribution_task_assignee_id).call
    end
  end

  def cancel_previous_judge_assign_task(appeal, judge_id)
    appeal.tasks.of_type(:JudgeAssignTask).where.not(assigned_to_id: judge_id).update(status: :cancelled)
  end

  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  # rubocop:disable Metrics/MethodLength
  # :reek:FeatureEnvy
  def create_sct_appeals(appeals_args, limit)
    appeals = appeals(appeals_args)
      .limit(limit)
      .includes(:request_issues)

    sct_appeals = if FeatureToggle.enabled?(:specialty_case_team_distribution, user: RequestStore.store[:current_user])
                    sct_appeals = appeals.select(&:sct_appeal?)
                    appeals -= sct_appeals
                    sct_appeals
                  else
                    []
                  end

    if sct_appeals.any?
      loop do
        inner_appeals = appeals(appeals_args)
          .limit(limit - appeals.count)
          .includes(:request_issues)
          .where("appeals.id NOT IN (?)", appeals.pluck(:id) + sct_appeals.pluck(:id))

        break unless inner_appeals.exists?

        inner_sct_appeals = inner_appeals.select(&:sct_appeal?)
        inner_appeals -= inner_sct_appeals
        appeals += inner_appeals
        sct_appeals += inner_sct_appeals

        break if appeals.count >= limit
      end
    end

    [appeals, sct_appeals]
  end
  # rubocop:enable Metrics/MethodLength
end
