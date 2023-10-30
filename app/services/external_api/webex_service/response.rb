# frozen_string_literal: true

class ExternalApi::WebexService::Response
  attr_reader :resp, :code

  DEFAULT_ERROR_BODY = {
    message: "Either an error message was not provided or one could not be located.",
    descriptions: []
  }.freeze

  def initialize(resp)
    @resp = resp
    @code = @resp.code
  end

  def data
    fail NotImplementedError
  end

  def error
    check_for_errors
  end

  def success?
    !resp.error?
  end

  private

  def check_for_errors
    return if success?

    parsed_messages = parse_error_message

    Caseflow::Error::WebexApiError.new(
      code: code,
      message: parsed_messages.dig(:message),
      descriptions: parsed_messages.dig(:descriptions)
    )
  end

  def parse_error_message
    return DEFAULT_ERROR_BODY if resp.raw_body.empty?

    begin
      body = JSON.parse(resp.raw_body)
      if !invalid_token
        {
          message: body.dig(:message),
          descriptions: body.dig(:errors)&.pluck(:description)&.compact
        }
      end
    rescue JSON::ParserError
      DEFAULT_ERROR_BODY
    end
  end


  # rerun checks
  def invalid_token
    body = JSON.parse(resp.raw_body)
    if body["error_description"] == "The access token expired"
      fail Caseflow::Error::WebexInvalidTokenError.new(
        code: @code,
        message: body["error"],
        descriptions: body["error_description"]
      )
    end

    nil
  end
end
