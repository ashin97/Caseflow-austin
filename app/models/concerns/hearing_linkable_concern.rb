# frozen_string_literal: true

module HearingLinkableConcern
  extend ActiveSupport::Concern

  included do
    has_one :hearing_link, as: :hearing_linkable

    delegate :linked_hearing, to: :hearing_link, allow_nil: true
  end

  def link_to_hearing(hearing)
    HearingLink.create!(
      hearing_linkable: self,
      hearing: hearing
    )
  end
end
