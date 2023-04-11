# frozen_string_literal: true

# :nocov:
class ClaimsEvidenceCaseflowLogger
  def log(event, data)
    case event
    when :request
      status = data[:response_code]

      if status != 200
        Rails.logger.error(
          "ClaimsEvidence HTTP Error #{status} (#{data.pretty_inspect})"
        )
      else
        Rails.logger.info(
          "ClaimsEvidence HTTP Success #{status} (#{data.pretty_inspect})"
        )
      end
    end
  end
end
  # :nocov:

class Fakes::ClaimsEvidenceService

  def self.document_types
    JSON.parse(IO.binread(File.join(Rails.root, "lib", "fakes", "data", "DOCUMENT_TYPES.json")))["documentTypes"]
  end

  def self.alt_document_types
    JSON.parse(IO.binread(File.join(Rails.root, "lib", "fakes", "data", "DOCUMENT_TYPES.json")))["alternativeDocumentTypes"]
  end
end
