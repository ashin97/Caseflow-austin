# frozen_string_literal: true

class Notification < CaseflowRecord
  include HearingLinkableConcern

  self.ignored_columns = ["notification_events_id"]
end
