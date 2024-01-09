# frozen_string_literal: true

# Represents a record in a join table used to associate an entity with
# a specific hearing
class HearingLink < CaseflowRecord
  belongs_to :hearing_linkable, polymorphic: true
end
