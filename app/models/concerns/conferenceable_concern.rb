# frozen_string_literal: true

module ConferenceableConcern
  extend ActiveSupport::Concern

  DEFAULT_SERVICE = "pexip"

  included do
    has_one :meeting_type, as: :conferenceable

    after_create :set_default_meeting_type

    delegate :conference_provider, to: :meeting_type, allow_nil: true
  end

  def set_default_meeting_type
    unless meeting_type
      MeetingType.create!(
        service_name: created_by.conference_provider || DEFAULT_SERVICE,
        conferenceable: self
      )

      reload_meeting_type
    end
  end
end
