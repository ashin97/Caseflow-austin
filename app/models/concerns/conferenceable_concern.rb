# frozen_string_literal: true

module ConferenceableConcern
  extend ActiveSupport::Concern

  DEFAULT_SERVICE = "pexp"

  included do
    has_one :meeting_type, as: :conferenceable

    before_create :set_default_meeting_type
  end

  def set_default_meeting_type
    MeetingType.create!(service_name: DEFAULT_SERVICE, conferenceable: self)
  end
end
