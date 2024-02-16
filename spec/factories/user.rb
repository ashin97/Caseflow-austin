# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    css_id { "CSS_ID#{generate :css_id}" }

    station_id { User::BOARD_STATION_ID }
    full_name { "Lauren Roth" }

    transient do
      vacols_uniq_id { nil }
    end

    factory :default_user do
      css_id { "DEFAULT_USER" }
      full_name { "Lauren Roth" }
      email { "test@example.com" }
      roles { ["Certify Appeal"] }
    end

    factory :hearings_coordinator do
      css_id { "BVATWARNER" }
      full_name { "Thomas Warner" }
      email { "thomas.warner@example.com" }
      roles { ["Assign Hearings"] }
    end

    factory :intake_user do
      css_id { "BVATWARNER" }
      full_name { "Sandra Warner" }
      email { "sandra.warner@example.com" }
      roles { ["Mail Intake"] }
    end

    factory :intake_admin_user do
      css_id { "INTAKEADMINUSER" }
      full_name { "Shirley Warner" }
      email { "shirley.warner@example.com" }
      roles { ["Admin Intake"] }
    end

    factory :correspondence_auto_assignable_user do
      after(:create) do |u|
        # Member of InboundOpsTeam
        org_user = OrganizationsUser.find_or_create_by!(organization: InboundOpsTeam.singleton, user: u)

        org_permission = OrganizationPermission.find_or_create_by!(
          organization: InboundOpsTeam.singleton,
          permission: Constants.ORGANIZATION_PERMISSIONS.auto_assign
        ) do |op|
          op.enabled = true
          op.description = Faker::Fantasy::Tolkien.poem
        end

        # Has auto-assign permission
        OrganizationUserPermission.find_or_create_by!(
          organization_permission: org_permission,
          organizations_user: org_user
        ) do |oup|
          oup.permitted = true
        end
      end

      trait :super_user do
        after(:create) do |u|
          OrganizationsUser.find_or_create_by!(organization: InboundOpsTeam.singleton, user: u).update!(admin: true)
          OrganizationsUser.find_or_create_by!(organization: BvaIntake.singleton, user: u).update!(admin: true)
          OrganizationsUser.find_or_create_by!(organization: MailTeam.singleton, user: u).update!(admin: true)
        end
      end

      trait :nod_enabled do
        after(:create) do |u|
          org_user = OrganizationsUser.find_or_create_by!(organization: InboundOpsTeam.singleton, user: u)

          org_permission = OrganizationPermission.find_or_create_by!(
            organization: InboundOpsTeam.singleton,
            permission: Constants.ORGANIZATION_PERMISSIONS.receive_nod_mail
          ) do |op|
            op.enabled = true
            op.description = Faker::Fantasy::Tolkien.poem
          end

          OrganizationUserPermission.find_or_create_by!(
            organization_permission: org_permission,
            organizations_user: org_user
          ) do |oup|
            oup.permitted = true
          end
        end
      end
    end

    trait :inactive do
      status { "inactive" }
    end

    trait :vso_role do
      roles { ["VSO"] }
    end

    trait :judge do
      with_judge_team
      roles { ["Hearing Prep"] }
    end

    trait :ama_only_judge do
      after(:create) do |judge|
        JudgeTeam.for_judge(judge)&.update(ama_only_push: true, ama_only_request: true) ||
          JudgeTeam.create_for_judge(judge, ama_only_push: true, ama_only_request: true)
      end

      roles { ["Hearing Prep"] }
    end

    trait :with_vacols_judge_record do
      after(:create) do |user|
        create(:staff, :judge_role, user: user)
      end
    end

    trait :with_judge_team do
      after(:create) do |judge|
        JudgeTeam.for_judge(judge) || JudgeTeam.create_for_judge(judge)
      end
    end

    trait :with_vacols_attorney_record do
      after(:create) do |user|
        create(:staff, :attorney_role, user: user)
      end
    end

    trait :with_vacols_acting_judge_record do
      after(:create) do |user|
        create(:staff, :attorney_judge_role, user: user)
      end
    end

    trait :vlj_support_user do
      after(:create) do |user|
        Colocated.singleton.add_user(user)
      end
    end

    after(:create) do |user, evaluator|
      if evaluator.vacols_uniq_id
        create(:staff, slogid: evaluator.vacols_uniq_id, user: user)
      end
    end
  end
end
