# frozen_string_literal: true

# This class is responsible for building the AMA Request Issue Response.

#:reek:TooManyInstanceVariables
class Api::V3::Issues::Ama::VbmsAmaDtoBuilder
  attr_reader :hash_response

  def initialize(veteran, page, per_page=nil)
    @page = page
    @veteran_participant_id = veteran.participant_id.to_s
    @request_issue_count = total_request_issue_count
    @request_issues = serialized_request_issues
    @offset = per_page || RequestIssue.default_per_page
    @total_number_of_pages = (@request_issue_count / @offset.to_f).ceil
    @legacy_appeals_present_boolean = legacy_appeals_present?(veteran)
    @hash_response = build_hash_response
  end

  private

  def total_request_issue_count
    RequestIssue.where(veteran_participant_id: @veteran_participant_id).count
  end

  def serialized_request_issues(page = @page)
    serialized_data = Api::V3::Issues::Ama::RequestIssueSerializer.new(
      RequestIssue.includes(:decision_issues)
      .where(veteran_participant_id: @veteran_participant_id)
      .where(benefit_type: %w[compensation pension fiduciary])
      .page(page)
    ).serializable_hash[:data]

    serialized_data.map { |issue| issue[:attributes] }
  end

  def legacy_appeals_present?(veteran)
    LegacyAppeal.veteran_has_appeals_in_vacols?(veteran.file_number)
  end

  def build_hash_response
    if @page > @total_number_of_pages
      @page = @total_number_of_pages
      @request_issues = serialized_request_issues(@total_number_of_pages)
    end
    json_response
  end

  def json_response
    {
      "page": @page,
      "total_number_of_pages": @total_number_of_pages,
      "total_request_issues_for_vet": @request_issue_count,
      "max_request_issues_per_page": @offset,
      "veteran_participant_id": @veteran_participant_id,
      "legacy_appeals_present": @legacy_appeals_present_boolean,
      "request_issues": @request_issues
    }
  end
end
