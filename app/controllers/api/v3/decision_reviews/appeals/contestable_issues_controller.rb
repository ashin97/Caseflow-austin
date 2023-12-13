# frozen_string_literal: true
require "#{Rails.root}/app/serializers/api/v3/contestable_issue_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/claimant_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/decision_issue_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/higher_level_review_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/legacy_appeal_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/legacy_related_issue_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/request_issue_serializer.rb"
require "#{Rails.root}/app/serializers/api/v3/veteran_serializer.rb"

module Api
  module V3
    module DecisionReviews
      module Appeals
        class ContestableIssuesController < BaseContestableIssuesController
          include ApiV3FeatureToggleConcern

          before_action only: [:index] do
            api_released?(:api_v3_appeals_contestable_issues)
          end

          private

          def standin_decision_review
            @standin_decision_review ||= Appeal.new(
              veteran_file_number: veteran.file_number,
              receipt_date: receipt_date
            )
          end
        end
      end
    end
  end
end
