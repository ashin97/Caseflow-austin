# frozen_string_literal: true

class CreateHearingsLinkableJoinTable < Caseflow::Migration
  def change
    # Question: Should the primary key be a composite key consisting of [hearing_id, hearing_linkable_id]?
    # Pros: Faster read speeds
    # Cons: Much slower insertions
    create_table :hearing_links, &:timestamps

    add_reference :hearing_links, :linked_hearing, polymorphic: true, index: false
    add_reference :hearing_links, :hearing_linkable, polymorphic: true, index: false

    add_safe_index :hearing_links,
                   [:linked_hearing_id, :linked_hearing_type],
                   name: "hearing_linkable_items_association_idx"
    add_safe_index :hearing_links,
                   [:hearing_linkable_id, :hearing_linkable_type],
                   name: "hearing_links_on_hearing_id_and_hearing_type"
  end
end
