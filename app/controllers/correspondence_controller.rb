# frozen_string_literal: true

class CorrespondenceController < ApplicationController
  before_action :verify_feature_toggle

  def correspondence_cases
    render 'correspondence_cases'
  end

  private

  def verify_feature_toggle
    # return true if verify_authorized_roles("Mail Intake") #&& FeatureToggle.enabled?(:correspondence_queue, user: current_user)
    if FeatureToggle.enabled?(:correspondence_queue)
      Rails.logger.info("User with roles #{current_user.roles.join(', ')} "\
        "couldn't access #{request.original_url}")

      session["return_to"] = request.original_url
      redirect_to "/unauthorized"
    end
  end
end
