# frozen_string_literal: true

# Correspondence is a top level object similar to Appeals.
# Serves as a collection of all data related to Correspondence workflow
class Correspondence < CaseflowRecord
  has_paper_trail

  has_many :correspondence_documents
  belongs_to :correspondence_type
  belongs_to :prior_correspondence, class_name: "Correspondence", optional: true
  belongs_to :package_document_type
  belongs_to :correspondence_type
  belongs_to :package_document_type
  belongs_to :veteran
end
