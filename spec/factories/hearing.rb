FactoryBot.define do
  factory :hearing do
    transient do
      case_hearing { create(:case_hearing, user: current_user) }
    end

    appeal do
      create(:legacy_appeal, vacols_case: create(:case_with_form_9, case_issues:
        [create(:case_issue), create(:case_issue)], case_hearings: [case_hearing]))
    end
    vacols_id { case_hearing.hearing_pkseq }
  end
end
