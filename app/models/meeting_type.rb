# frozen_string_literal: true

class MeetingType < CaseflowRecord
  belongs_to :conferenceable, polymorphic: true

  enum service_name: { pexip: 0, webex: 1 }

  scope :pexip, -> { where(service_name: "pexip") }
  scope :webex, -> { where(service_name: "webex") }

  alias_attribute :conference_provider, :service_name
end
