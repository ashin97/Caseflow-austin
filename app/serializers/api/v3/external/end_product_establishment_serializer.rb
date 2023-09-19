# frozen_string_literal: true

class Api::V3::External::EndProductEstablishmentSerializer
	include FastJsonapi::ObjectSerializer
	attributes :id, :synced_status, :reference_id
	has_many :request_issues, serializer: ::Api::V3::External::RequestIssueSerializer
end
