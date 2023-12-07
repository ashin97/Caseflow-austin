# frozen_string_literal: true

module Seeds
  class CasesTiedToJudgesNoLongerWithBoard < Base
    APPEALS_LIMIT = 50

    def initialize
      initialize_inactive_cf_user_and_inactive_admin_judge_team_file_number_and_participant_id
      initialize_active_cf_user_and_non_admin_judge_team_file_number_and_participant_id
      initialize_active_cf_user_and_inactive_judge_team_file_number_and_participant_id
      initialize_active_judge_file_number_and_participant_id
    end

    def seed!
      RequestStore[:current_user] = User.find_by_css_id("CASEFLOW1")
      create_legacy_appeals
      create_ama_appeals
    end

    private

    def find_veteran(file_number)
      Veteran.find_by(file_number: format("%<n>09d", n: file_number + 1))
    end

    def initialize_inactive_cf_user_and_inactive_admin_judge_team_file_number_and_participant_id
      @inactive_cf_user_and_inactive_admin_judge_team_file_number ||= 300_000_000
      @inactive_cf_user_and_inactive_admin_judge_team_participant_id ||= 400_000_000

      while find_veteran(@inactive_cf_user_and_inactive_admin_judge_team_file_number)
        @inactive_cf_user_and_inactive_admin_judge_team_file_number += 2000
        @inactive_cf_user_and_inactive_admin_judge_team_participant_id += 2000
      end
    end

    def initialize_active_cf_user_and_non_admin_judge_team_file_number_and_participant_id
      @active_cf_user_and_non_admin_judge_team_file_number ||= 301_000_000
      @active_cf_user_and_non_admin_judge_team_participant_id ||= 500_000_000

      while find_veteran(@active_cf_user_and_non_admin_judge_team_file_number)
        @active_cf_user_and_non_admin_judge_team_file_number += 2000
        @active_cf_user_and_non_admin_judge_team_participant_id += 2000
      end
    end

    def initialize_active_cf_user_and_inactive_judge_team_file_number_and_participant_id
      @active_cf_user_and_inactive_judge_team_file_number ||= 302_000_000
      @active_cf_user_and_inactive_judge_team_participant_id ||= 700_000_000

      while find_veteran(@active_cf_user_and_inactive_judge_team_file_number)
        @active_cf_user_and_inactive_judge_team_file_number += 2000
        @active_cf_user_and_inactive_judge_team_participant_id += 2000
      end
    end

    def initialize_active_judge_file_number_and_participant_id
      @file_number ||= 303_000_200
      @participant_id ||= 800_000_000

      while find_veteran(@file_number)
        @file_number += 2000
        @participant_id += 2000
      end
    end

    def create_veteran(options = {})
      params = {
        file_number: format("%<n>09d", n: options[:file_number]),
        participant_id: format("%<n>09d", n: options[:participant_id])
      }
      create(:veteran, params.merge(options))
    end

    def find_or_create_active_judge(css_id, full_name)
      User.find_by_css_id(css_id) ||
        create(:user, :judge, :with_vacols_judge_record, css_id: css_id, full_name: full_name)
    end

    def inactive_cf_user_and_inactive_admin_judge_team
      @inactive_cf_user_and_inactive_admin_judge_team ||= begin
        judge = find_or_create_active_judge("INACTIVECFJUDGE", "Judge InactiveInCF User")
        judge.update_status!("inactive") if judge.active?
        judge
      end
    end

    # Active Caseflow User who is not the admin of any JudgeTeam.
    def active_cf_user_and_non_admin_judge_team
      @active_cf_user_and_non_admin_judge_team ||= begin
        judge = find_or_create_active_judge("ACTIVEJUDGETEAM", "Judge WithJudgeTeam Active")
        judge_team = JudgeTeam.for_judge(judge)

        user = create(:user, :with_vacols_attorney_record, css_id: "ACTIVEATTY", "Attorney OnJudgeTeam Active")
        judge_team.add_user(user)

        user
      end
    end

    # Active Caseflow User who is the admin of an Inactive JudgeTeam and a non-admin of another JudgeTeam
    def active_cf_user_and_inactive_judge_team
      @active_cf_user_and_inactive_judge_team ||= begin
        user = create(:user,
                      :judge,
                      :with_vacols_acting_judge_record,
                      css_id: "ATTYWITHJUDGETEAM",
                      full_name: "Attorney WithInactiveJudgeTeam Affinity")

        JudgeTeam.for_judge(user).inactive!
        another_judge = find_or_create_active_judge("ACTIVEJUDGETEAM", "Judge WithJudgeTeam Active")
        another_judge_team = JudgeTeam.for_judge(another_judge)
        another_judge_team.add_user(user)

        user
      end
    end

    def active_judge_hearing_affinity_45_days
      @active_judge_hearing_affinity_45_days ||= find_or_create_active_judge("JUDGEHEARING1", "Judge Hearings45Days Affinity")
    end

    def active_judge_hearing_affinity_65_days
      @active_judge_hearing_affinity_65_days ||= find_or_create_active_judge("JUDGEHEARING2", "Judge Hearings65Days Affinity")
    end

    def create_legacy_appeals
      Timecop.travel(65.days.ago)
      APPEALS_LIMIT.times.each do |_offset|
        # Create the veteran for this legacy appeal
        veteran = create_veteran_for_inactive_cf_user_and_inactive_admin_judge_team

        # AC1: create legacy appeals ready to be distributed that have a hearing held by an inactive judge
        legacy_appeal = create_vacols_entries(veteran, "RO17")

        ## Hearing held by inactive judge
        create(
          :case_hearing,
          :disposition_held,
          folder_nr: legacy_appeal.vacols_id,
          user: inactive_cf_user_and_inactive_admin_judge_team
        )
      end
      Timecop.return
    end

    def create_veteran_for_inactive_cf_user_and_inactive_admin_judge_team
      @inactive_cf_user_and_inactive_admin_judge_team_file_number += 1
      @inactive_cf_user_and_inactive_admin_judge_team_participant_id += 1
      create_veteran(
        file_number: @inactive_cf_user_and_inactive_admin_judge_team_file_number,
        participant_id: @inactive_cf_user_and_inactive_admin_judge_team_participant_id
      )
    end

    def create_vacols_entries(veteran, regional_office)
      correspondent = create(:correspondent,
                             snamef: veteran.first_name, snamel: veteran.last_name,
                             ssalut: "", ssn: veteran.file_number)
      vacols_case = create_video_vacols_case(veteran,
                                             correspondent,
                                             inactive_cf_user_and_inactive_admin_judge_team)

      # Create the legacy_appeal, this doesn't fail with index problems, so no need to retry
      legacy_appeal = create(
        :legacy_appeal,
        :with_root_task,
        vacols_case: vacols_case,
        closest_regional_office: regional_office
      )
      create(:available_hearing_locations, regional_office, appeal: legacy_appeal)

      # Return the legacy_appeal
      legacy_appeal
    end

    # Creates the video hearing request
    def create_video_vacols_case(veteran, correspondent, judge)
      create(
        :case,
        :assigned,
        :video_hearing_requested,
        :type_original,
        user: judge,
        correspondent: correspondent,
        bfcorlid: "#{veteran.file_number}S",
        case_issues: create_list(:case_issue, 3, :compensation)
      )
    end

    # AC 2-6
    def create_ama_appeals
      APPEALS_LIMIT.times.each do |_offset|
        create_ama_appeals_for_active_judge
        create_ama_appeals_for_inactive_cf_user_and_inactive_admin_judge_team
        create_ama_appeals_for_active_cf_user_and_non_admin_judge_team
        create_ama_appeals_for_active_cf_user_and_inactive_judge_team
      end
    end

    def create_ama_appeals_for_inactive_cf_user_and_inactive_admin_judge_team
      veteran = create_veteran_for_inactive_cf_user_and_inactive_admin_judge_team
      create_ama_appeals_ready_to_distribute_45_days(inactive_cf_user_and_inactive_admin_judge_team, veteran)
    end

    def create_ama_appeals_for_active_judge
      create_ama_appeals_ready_to_distribute_45_days(
        active_judge_hearing_affinity_45_days,
        create_veteran_for_active_judge
      )

      create_ama_appeals_ready_to_distribute_65_days(
        active_judge_hearing_affinity_65_days,
        create_veteran_for_active_judge
      )
    end

    def create_veteran_for_active_judge
      @file_number += 1
      @participant_id += 1
      create_veteran(file_number: @file_number, participant_id: @participant_id)
    end

    def create_ama_appeals_for_active_cf_user_and_non_admin_judge_team
      veteran = create_veteran_for_active_cf_user_and_non_admin_judge_team
      create_ama_appeals_ready_to_distribute_45_days(active_cf_user_and_non_admin_judge_team, veteran)
    end

    def create_veteran_for_active_cf_user_and_non_admin_judge_team
      @active_cf_user_and_non_admin_judge_team_file_number += 1
      @active_cf_user_and_non_admin_judge_team_participant_id += 1
      create_veteran(
        file_number: @active_cf_user_and_non_admin_judge_team_file_number,
        participant_id: @active_cf_user_and_non_admin_judge_team_participant_id
      )
    end

    def create_ama_appeals_for_active_cf_user_and_inactive_judge_team
      veteran = create_veteran_for_active_cf_user_and_inactive_judge_team
      create_ama_appeals_ready_to_distribute_45_days(active_cf_user_and_inactive_judge_team, veteran)
    end

    def create_veteran_for_active_cf_user_and_inactive_judge_team
      @active_cf_user_and_inactive_judge_team_file_number += 1
      @active_cf_user_and_inactive_judge_team_participant_id += 1
      create_veteran(
        file_number: @active_cf_user_and_inactive_judge_team_file_number,
        participant_id: @active_cf_user_and_inactive_judge_team_participant_id
      )
    end

    # AC2,4,5,6: ready to distribute for less than 60 days
    def create_ama_appeals_ready_to_distribute_45_days(judge, veteran)
      Timecop.travel(45.days.ago)
      create(:appeal,
             :advanced_on_docket_due_to_motion,
             :with_post_intake_tasks,
             :held_hearing_and_ready_to_distribute,
             :hearing_docket,
             tied_judge: judge,
             veteran: veteran,
             receipt_date: 2.years.ago)
      Timecop.return
    end

    # AC3: ready to distribute for more than 60 days
    def create_ama_appeals_ready_to_distribute_65_days(judge, veteran)
      Timecop.travel(65.days.ago)
      create(:appeal,
             :advanced_on_docket_due_to_motion,
             :with_post_intake_tasks,
             :held_hearing_and_ready_to_distribute,
             :hearing_docket,
             tied_judge: judge,
             veteran: veteran,
             receipt_date: 2.years.ago)
      Timecop.return
    end
  end
end
