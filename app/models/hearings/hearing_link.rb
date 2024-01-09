# frozen_string_literal: true

# Represents a record in a join table used to associate an entity with
# a specific hearing
class HearingLink < CaseflowRecord
  belongs_to :hearing_linkable, polymorphic: true
  belongs_to :linked_hearing, polymorphic: true

  alias_attribute :hearing, :linked_hearing
  alias_attribute :linked_item, :hearing_linkable
end
