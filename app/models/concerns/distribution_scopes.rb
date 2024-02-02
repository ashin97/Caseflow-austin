# frozen_string_literal: true

module DistributionScopes # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  # Below methods are for docket.rb

  def priority
    include_aod_motions
      .where("advance_on_docket_motions.created_at > appeals.established_at")
      .where("advance_on_docket_motions.granted = ?", true)
      .or(include_aod_motions.where("people.date_of_birth <= ?", 75.years.ago))
      .or(include_aod_motions.where("appeals.stream_type = ?", Constants.AMA_STREAM_TYPES.court_remand))
      .group("appeals.id")
  end

  def nonpriority
    include_aod_motions
      .where("people.date_of_birth > ? or people.date_of_birth is null", 75.years.ago)
      .where.not("appeals.stream_type = ?", Constants.AMA_STREAM_TYPES.court_remand)
      .group("appeals.id")
      .having("count(case when advance_on_docket_motions.granted "\
        "\n and advance_on_docket_motions.created_at > appeals.established_at then 1 end) = ?", 0)
  end

  def include_aod_motions
    joins(:claimants)
      .joins("LEFT OUTER JOIN people on people.participant_id = claimants.participant_id")
      .joins("LEFT OUTER JOIN advance_on_docket_motions on advance_on_docket_motions.person_id = people.id")
  end

  def ready_for_distribution
    joins(:tasks)
      .group("appeals.id")
      .having("count(case when tasks.type = ? and tasks.status = ? then 1 end) >= ?",
              DistributionTask.name, Constants.TASK_STATUSES.assigned, 1)
  end

  # This is specifically referring to CAVC genpop, not hearings
  def genpop
    joins(with_assigned_distribution_task_sql)
      .where(
        "appeals.stream_type != ? OR distribution_task.assigned_at <= ?",
        Constants.AMA_STREAM_TYPES.court_remand,
        Constants.DISTRIBUTION.cavc_affinity_days.days.ago
      )
  end

  def with_original_appeal_and_judge_task
    joins("LEFT JOIN cavc_remands ON cavc_remands.remand_appeal_id = appeals.id")
      .joins("LEFT JOIN appeals AS original_cavc_appeal ON original_cavc_appeal.id = cavc_remands.source_appeal_id")
      .joins(
        "LEFT JOIN tasks AS original_judge_task ON original_judge_task.appeal_id = original_cavc_appeal.id
         AND original_judge_task.type = 'JudgeDecisionReviewTask'
         AND original_judge_task.status = 'completed'"
      )
  end

  # Within the first 21 days, the appeal should be distributed only to the issuing judge.
  # This is specifically referring to CAVC genpop, not hearings
  def non_genpop_for_judge(judge)
    joins(with_assigned_distribution_task_sql)
      .with_original_appeal_and_judge_task
      .where("distribution_task.assigned_at > ?", Constants.DISTRIBUTION.cavc_affinity_days.days.ago)
      .where(original_judge_task: { assigned_to_id: judge.id })
  end

  def ordered_by_distribution_ready_date
    joins(:tasks)
      .group("appeals.id")
      .order(
        Arel.sql("max(case when tasks.type = 'DistributionTask' then tasks.assigned_at end)")
      )
  end

  def non_ihp
    joins(:tasks)
      .group("appeals.id")
      .having("count(case when tasks.type = ? then 1 end) = ?",
              InformalHearingPresentationTask.name, 0)
  end

  # Below methods are for hearing_request_distribution_query.rb

  def most_recent_hearings
    query = <<-SQL
      INNER JOIN
      (SELECT h.appeal_id, max(hd.scheduled_for) as latest_scheduled_for
      FROM hearings h
      JOIN hearing_days hd on h.hearing_day_id = hd.id
      GROUP BY
      h.appeal_id
      ) as latest_date_by_appeal
      ON appeals.id = latest_date_by_appeal.appeal_id
      AND hearing_days.scheduled_for = latest_date_by_appeal.latest_scheduled_for
    SQL

    joins(query, hearings: :hearing_day)
  end

  def tied_to_distribution_judge(judge)
    joins(with_assigned_distribution_task_sql)
      .where(hearings: { disposition: "held", judge_id: judge.id })
      .where("distribution_task.assigned_at > ?", Constants::DISTRIBUTION["hearing_case_affinity_days"].days.ago)
  end

  def tied_to_ineligible_judge
    where(hearings: { disposition: "held", judge_id: HearingRequestDistributionQuery.ineligible_judges_id_cache })
      .where("1 = ?", FeatureToggle.enabled?(:acd_cases_tied_to_judges_no_longer_with_board) ? 1 : 0)
  end

  # If an appeal has exceeded the affinity, it should be returned to genpop.
  def exceeding_affinity_threshold
    joins(with_assigned_distribution_task_sql)
      .where(hearings: { disposition: "held" })
      .where("distribution_task.assigned_at <= ?", Constants::DISTRIBUTION["hearing_case_affinity_days"].days.ago)
  end

  # Historical note: We formerly had not_tied_to_any_active_judge until CASEFLOW-1928,
  # when that distinction became irrelevant because cases become genpop after 30 days anyway.
  def not_tied_to_any_judge
    where(hearings: { disposition: "held", judge_id: nil })
  end

  def with_no_hearings
    left_joins(:hearings).where(hearings: { id: nil })
  end

  def with_no_held_hearings
    left_joins(:hearings).where.not(hearings: { disposition: "held" })
  end

  def with_held_hearings
    where(hearings: { disposition: "held" })
  end

  # Below methods are used in both docket.rb and hearing_request_distribution_query.rb

  def with_assigned_distribution_task_sql
    # both `appeal_type` and `appeal_id` necessary due to composite index
    <<~SQL
      INNER JOIN tasks AS distribution_task
      ON distribution_task.appeal_type = 'Appeal'
      AND distribution_task.appeal_id = appeals.id
      AND distribution_task.type = 'DistributionTask'
      AND distribution_task.status = 'assigned'
    SQL
  end
end
